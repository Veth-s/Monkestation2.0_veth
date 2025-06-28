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
	var/ghost_edible = FALSE
	var/static/datum/team/bingles/bingle_team
	var/current_pit_size = 1 // 1 = 1x1, 2 = 2x2, 3 = 3x3 can go higher
	var/list/pit_overlays = list()
	var/last_bingle_spawn_value = 0
	var/last_bingle_poll_value = 0


/obj/structure/bingle_hole/examine(mob/user)
	. = .. ()
	if(IS_BINGLE(user) || !isliving(user))
		. += span_alert("The bingle pit has [item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")


/obj/structure/bingle_hole/proc/spit_em_out()
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return

	// Find all turfs in the bingle pit area
	for(var/turf/T in world)
		if(!istype(get_area(T), /area/station/bingle_pit))
			continue
		// Move all movables on this turf back to the pit
		for(var/atom/movable/A in T)
			A.forceMove(target_turf)
			var/dir = pick(GLOB.alldirs)
			var/turf/edge = get_edge_target_turf(src, dir)
			if(ismob(A) || isobj(A))
				A.throw_at(edge, rand(1,5), rand(1,5))

	// Clear the pit contents lists
	pit_contents_mobs.Cut()
	pit_contents_items.Cut()

/datum/armor/structure_bingle_hole
	energy = 50
	bomb = 50
	bio = 100
	fire = 30
	acid = 80

/obj/structure/bingle_hole/Initialize(mapload)
	. = ..()
	if(bingleprime)
		for(var/datum/antagonist/antag in bingleprime.antag_datums)
			if(istype(antag, /datum/antagonist/bingle))
				bingle_team = antag.get_team()
				break

	// Create the pit storage turf if it doesn't exist
	AddComponent(/datum/component/aura_healing, range = 3, simple_heal = 5, limit_to_trait = TRAIT_HEALS_FROM_BINGLE_HOLES, healing_color = COLOR_BLUE_LIGHT)
	START_PROCESSING(SSfastprocess, src)

/obj/structure/bingle_hole/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	spit_em_out()
	// Gib all bingles in the world on pit destruction
	for(var/mob/living/basic/bingle/B in world)
		if(B)
			B.gib()
	// Remove all overlays on pit destruction
	for(var/obj/structure/bingle_pit_overlay/O in pit_overlays)
		if(O)
			qdel(O)
	pit_overlays.Cut()
	return ..()

/obj/structure/bingle_hole/process(seconds_per_tick)
	for(var/turf/pit in get_all_pit_turfs())
		// Gather items to swallow first, then process them asynchronously
		var/list/to_swallow = list()
		for(var/atom/item in pit.contents)
			if(item == src) // Prevent the pit from swallowing itself
				continue
			if(istype(item, /obj/structure/bingle_pit_overlay)) // Prevent swallowing overlays
				continue
			if(ismob(item) && istype(item, /mob/living))
				if(istype(item, /mob/living/basic/bingle))
					continue
				to_swallow += item
			else if(isobj(item) && istype(item, /obj/item))
				to_swallow += item

		// Async swallow: process one per tick to avoid stutter
		if(length(to_swallow))
			spawn(0)
				for(var/atom/A in to_swallow)
					if(!A || QDELETED(A)) continue
					swallow(A)
					sleep(1) // Yield to avoid lag

	// Only poll for a new bingle every 30 item value, and only once per threshold
	if(item_value_consumed - last_bingle_poll_value >= 30)
		spawn_bingle_from_ghost()
		last_bingle_poll_value += 30

	// Grow pit as before
	if(item_value_consumed >= 200)
		grow_pit(3)
	else if(item_value_consumed >= 100)
		grow_pit(2)

	// Evolve bingles and buff if item_value_consumed >= 100
	var/datum/team/bingles/bingles_team = bingle_team
	if(bingles_team)
		for(var/mob/living/basic/bingle/bong in bingles_team.members)
			if(item_value_consumed >= 100)
				bong.icon_state = "bingle_armored"
				bong.maxHealth = 300
				bong.health = max(bong.health, 300)
				bong.obj_damage = 100
				bong.melee_damage_lower = 50
				bong.melee_damage_upper = 60
				bong.armour_penetration = 20
				bong.evolved = TRUE

			SEND_SIGNAL(bong, BINGLE_EVOLVE)

/obj/structure/bingle_hole/proc/swallow(atom/item)
	if(ismob(item))
		var/mob/swallowed_mob = item
		if(item_value_consumed < 100)
			var/dir = pick(GLOB.alldirs)
			var/turf/target = get_edge_target_turf(src, dir)
			swallowed_mob.throw_at(target, rand(1,5), rand(1,5))
			to_chat(swallowed_mob, "The pit has not swallowed enough items to accept creatures yet!")
			return
		if(!(swallowed_mob in pit_contents_mobs))
			pit_contents_mobs += swallowed_mob
			item_value_consumed += 10
		var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
		if(bingle_pit_turf)
			swallowed_mob.forceMove(bingle_pit_turf)
		else
			qdel(swallowed_mob)
	else if(isobj(item))
		var/obj/swallowed_obj = item
		if(!(swallowed_obj in pit_contents_items))
			pit_contents_items += swallowed_obj
			item_value_consumed++
		var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
		if(bingle_pit_turf)
			swallowed_obj.forceMove(bingle_pit_turf)
		else
			qdel(swallowed_obj)

/obj/structure/bingle_hole/proc/grow_pit(new_size)
	if(current_pit_size >= new_size)
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return

	// Remove old overlays
	for(var/obj/structure/bingle_pit_overlay/O in pit_overlays)
		qdel(O)
	pit_overlays.Cut()

	// If size is 1x1, use the default icon and no overlays
	if(new_size == 1)
		src.icon_state = "binglepit"
		current_pit_size = 1
		return

	src.icon_state = "" // Make the pit itself invisible

	var/half = (new_size - 1) / 2
	for(var/dx = -half to half)
		for(var/dy = -half to half)
			var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
			if(!T)
				continue

			var/icon_state = "core"
			// Corners (top left and bottom left are correct, swap the other two)
			if(dx == -half && dy == -half)
				icon_state = "corner_east"      // top left (correct)
			else if(dx == half && dy == -half)
				icon_state = "corner_south"     // top right (was corner_west, now corner_south)
			else if(dx == -half && dy == half)
				icon_state = "corner_north"     // bottom left (correct)
			else if(dx == half && dy == half)
				icon_state = "corner_west"      // bottom right (was corner_south, now corner_west)
			// Edges (swap edge_north and edge_south)
			else if(dy == -half)
				icon_state = "edge_south"
			else if(dy == half)
				icon_state = "edge_north"
			else if(dx == -half)
				icon_state = "edge_west"
			else if(dx == half)
				icon_state = "edge_east"
			else
				icon_state = "core"

			var/obj/structure/bingle_pit_overlay/overlay = new(T)
			overlay.icon_state = icon_state
			overlay.parent_pit = src // <-- Link overlay to the main pit
			pit_overlays += overlay

	current_pit_size = new_size

/obj/structure/bingle_pit_overlay
	name = "bingle pit"
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	layer = TURF_LAYER + 0.5
	plane = GAME_PLANE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/obj/structure/bingle_hole/parent_pit = null
	uses_integrity = TRUE

/obj/structure/bingle_pit_overlay/attackby(obj/item/W, mob/user)
	if(parent_pit)
		return parent_pit.attackby(W, user)
	return ..()

/obj/structure/bingle_pit_overlay/attack_hand(mob/user)
	if(parent_pit)
		return parent_pit.attack_hand(user)
	return ..()

/obj/structure/bingle_pit_overlay/bullet_act(var/obj/projectile/P)
	if(parent_pit)
		parent_pit.bullet_act(P)
	else
		..()

/obj/structure/bingle_pit_overlay/take_damage(amount, type, source, flags)
	if(parent_pit)
		parent_pit.take_damage(amount, type, source, flags)
	else
		..()

/obj/structure/bingle_hole/proc/get_all_pit_turfs()
	var/list/turfs = list(get_turf(src))
	for(var/obj/structure/bingle_pit_overlay/O in pit_overlays)
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
	if(item_value_consumed >= 100)
		bingle.icon_state = "bingle_armored"
		bingle.maxHealth = 300
		bingle.health = max(bingle.health, 300)
		bingle.obj_damage = 100
		bingle.melee_damage_lower = 50
		bingle.melee_damage_upper = 60
		bingle.armour_penetration = 20
		bingle.evolved = TRUE
	message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into Bingle (pit spawn).")
	log_game("[key_name(bingle)] was spawned as Bingle by the pit.")

/obj/structure/bingle_hole/proc/get_random_bingle_pit_turf()
	var/list/turfs = list()
	for(var/turf/T in world)
		if(istype(get_area(T), /area/station/bingle_pit))
			turfs += T
	if(!turfs.len)
		return null
	return pick(turfs)

/area/station/bingle_pit
	name = "bingle pit"
	area_flags = NOTELEPORT | EVENT_PROTECTED | ABDUCTOR_PROOF
	has_gravity = TRUE

/obj/structure/bingle_pit_overlay/examine(mob/user)
	. = ..()
	if(parent_pit)
		. += span_alert("The bingle pit has [parent_pit.item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")
