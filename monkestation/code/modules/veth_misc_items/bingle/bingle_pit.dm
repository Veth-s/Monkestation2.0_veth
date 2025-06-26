GLOBAL_LIST_EMPTY(bingle_pit_mobs)

/obj/structure/bingle_hole
	name = "bingle pit"
	desc = "An all-consuming pit of endless horrors... and bingles."
	armor_type = /datum/armor/structure_bingle_hole
	max_integrity = 500
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	icon_state = "binglepit"
	light_color = LIGHT_COLOR_BABY_BLUE
	light_outer_range = 5
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER + 0.1
	var/item_value_consumed = 0
	var/max_item_value = 300
	var/bingles_ready = 0
	var/datum/mind/bingleprime = null
	var/bingle_per_item_value = 30
	var/list/pit_contents_mobs = list()
	var/list/pit_contents_items = list()
	var/obj/effect/abstract/bingle_pit_storage/pit_storage
	var/ghost_edible = FALSE
	var/static/datum/team/bingles/bingle_team
	var/current_pit_size = 1 // 1 = 1x1, 2 = 2x2, 3 = 3x3 can go higher
	var/list/pit_overlays = list()
	var/last_bingle_spawn_value = 0

/obj/structure/bingle_hole/examine(mob/user)
	. = .. ()
	if(IS_BINGLE(user) || !isliving(user))
		. += span_alert("The bingle pit has [item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")


/obj/structure/bingle_hole/proc/spit_em_out()
	if(!pit_storage)
		return
	for(var/atom/movable/A in pit_storage.contents)
		A.forceMove(get_turf(src))
		var/dir = pick(GLOB.alldirs)
		var/turf/target = get_edge_target_turf(src, dir)
		if(ismob(A) || isobj(A))
			A.throw_at(target, rand(1,5), rand(1,5))

/datum/armor/structure_bingle_hole
	energy = 50
	bomb = 50
	bio = 100
	fire = 30
	acid = 80

/obj/structure/bingle_hole/Initialize(mapload)
	. = ..()
	// Create the pit storage turf if it doesn't exist
	if(!pit_storage)
		pit_storage = new /obj/effect/abstract/bingle_pit_storage(src)
	AddComponent(/datum/component/aura_healing, range = 3, simple_heal = 5, limit_to_trait = TRAIT_HEALS_FROM_BINGLE_HOLES, healing_color = COLOR_BLUE_LIGHT)
	START_PROCESSING(SSfastprocess, src)

/obj/structure/bingle_hole/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	spit_em_out()
	return ..()

/obj/structure/bingle_hole/process(seconds_per_tick)
	for(var/turf/pit in get_all_pit_turfs())
		for(var/atom/item in pit.contents)
			if(ismob(item) || isobj(item))
				if(istype(item, /mob/living/basic/bingle))
					continue
				swallow(item)

	// Spawn a new bingle every 20 item value
	while(item_value_consumed - last_bingle_spawn_value >= 20)
		spawn_bingle_from_ghost()
		last_bingle_spawn_value += 20

	// Grow pit as before
	if(item_value_consumed >= 200)
		grow_pit(3)
	else if(item_value_consumed >= 100)
		grow_pit(2)

	// Evolve bingles and buff if item_value_consumed >= 100
	var/datum/team/bingles/bingles_team = bingle_team
	for(var/mob/living/basic/bingle/bong in bingles_team.members)
		if(item_value_consumed >= 100)
			bong.icon_state = "bingle_armored"
			bong.maxHealth = 300
			bong.health = max(bong.health, 300)
			bong.obj_damage = 100
			bong.melee_damage_lower = 50
			bong.melee_damage_upper = 60
			bong.armour_penetration = 20
		SEND_SIGNAL(bong, BINGLE_EVOLVE)

/obj/structure/bingle_hole/proc/swallow(atom/item)
	if(ismob(item))
		var/mob/swallowed_mob = item
		if(item_value_consumed < 10) //change to 50
			var/dir = pick(GLOB.alldirs)
			var/turf/target = get_edge_target_turf(src, dir)
			swallowed_mob.throw_at(target, rand(1,5), rand(1,5))
			to_chat("The pit has not swallowed enough items to accept creatures yet!")
			return
		if(!(swallowed_mob in pit_contents_mobs))
			pit_contents_mobs += swallowed_mob
			item_value_consumed += 10 // Only increment if newly added!
		ADD_TRAIT(swallowed_mob, TRAIT_IMMOBILIZED, BINGLE_PIT_TRAIT)
		var/matrix/matrix_one = matrix()
		var/matrix/matrix_two = matrix()
		matrix_one.Scale(0,0)
		matrix_two.Scale(1,1)
		animate(swallowed_mob, transform = matrix_one, time = 1 SECONDS)
		if(pit_storage)
			swallowed_mob.forceMove(pit_storage)
		else
			qdel(swallowed_mob)
		animate(swallowed_mob, transform = matrix_two, time = 0.1 SECONDS)
	else if(isobj(item))
		var/obj/swallowed_obj = item
		if(!(swallowed_obj in pit_contents_items))
			pit_contents_items += swallowed_obj
			item_value_consumed++ // Only increment if newly added!
		var/matrix/matrix_one = matrix()
		var/matrix/matrix_two = matrix()
		matrix_one.Scale(0,0)
		matrix_two.Scale(1,1)
		animate(swallowed_obj, transform = matrix_one, time = 1 SECONDS)
		if(pit_storage)
			swallowed_obj.forceMove(pit_storage)
		else
			qdel(swallowed_obj)
		animate(swallowed_obj, transform = matrix_two, time = 0.1 SECONDS)

/obj/effect/abstract/bingle_pit_storage
	name = "bingle pits"
	desc = "The bottome of the bingle pit. It's slightly squelchy."
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/bingle_pit_storage/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SECLUDED_LOCATION, INNATE_TRAIT)

/obj/effect/abstract/bingle_pit_storage/Entered(atom/movable/arrived)
	. = ..()
	if(is_reserved_level(loc.z) && !istype(get_area(loc), /area/shuttle))
		qdel(arrived)
		return
	LAZYADD(GLOB.bingle_pit_mobs[get_chasm_category(loc)], arrived)

/obj/effect/abstract/bingle_pit_storage/Exited(atom/movable/gone)
	. = ..()
	if(isliving(gone))
		LAZYREMOVE(GLOB.bingle_pit_mobs[get_chasm_category(loc)], gone)

/obj/structure/bingle_hole/proc/grow_pit(new_size)
	if(current_pit_size >= new_size)
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return

	// Remove old overlays
	for(var/obj/effect/bingle_pit_overlay/O in pit_overlays)
		qdel(O)
	pit_overlays.Cut()

	// If size is 1x1, use the default icon and no overlays
	if(new_size == 1)
		src.icon_state = "binglepit"
		current_pit_size = 1
		return

	// For larger sizes, set the center to blank/transparent and use overlays
	src.icon_state = "" // Or a transparent/empty state if you have one

	var/half = (new_size - 1) / 2
	for(var/dx = -half to half)
		for(var/dy = -half to half)
			var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
			if(!T)
				continue
			if(dx == 0 && dy == 0)
				continue // skip the origin tile

			var/icon_state = "core"
			// Corners
			if(dx == -half && dy == -half)
				icon_state = "corner_northwest"
			else if(dx == half && dy == -half)
				icon_state = "corner_northeast"
			else if(dx == -half && dy == half)
				icon_state = "corner_southwest"
			else if(dx == half && dy == half)
				icon_state = "corner_southeast"
			// Edges
			else if(dy == -half)
				icon_state = "edge_north"
			else if(dy == half)
				icon_state = "edge_south"
			else if(dx == -half)
				icon_state = "edge_west"
			else if(dx == half)
				icon_state = "edge_east"

			var/obj/effect/bingle_pit_overlay/overlay = new(T)
			overlay.icon_state = icon_state
			pit_overlays += overlay

	current_pit_size = new_size

/obj/effect/bingle_pit_overlay
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit_overlay.dmi'
	layer = TURF_LAYER + 0.11
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

/obj/structure/bingle_hole/proc/get_all_pit_turfs()
	var/list/turfs = list(get_turf(src))
	for(var/obj/effect/bingle_pit_overlay/O in pit_overlays)
		turfs += get_turf(O)
	return turfs

/obj/structure/bingle_hole/proc/spawn_bingle_from_ghost()
    var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
        question = "Do you want to play as a Bingle?",
        role = ROLE_BINGLE,
        check_jobban = ROLE_BINGLE,
        poll_time = 20 SECONDS,
        alert_pic = /mob/living/basic/bingle,
        role_name_text = "bingle"
    )

    if(!length(candidates))
        return

    var/mob/dead/observer/selected = pick_n_take(candidates)
    var/datum/mind/player_mind = new /datum/mind(selected.key)
    player_mind.active = TRUE

    var/turf/spawn_loc = get_turf(src) // Use the pit's location
    if(isnull(spawn_loc))
        return

    var/mob/living/basic/bingle/bingle = new(spawn_loc)
    player_mind.transfer_to(bingle)
    player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/bingle))
    player_mind.special_role = ROLE_BINGLE
    player_mind.add_antag_datum(/datum/antagonist/bingle)
    message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into Bingle (pit spawn).")
    log_game("[key_name(bingle)] was spawned as Bingle by the pit.")
