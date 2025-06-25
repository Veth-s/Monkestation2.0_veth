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
	var/turf/pit = get_turf(src)
	for(var/atom/item in pit.contents)
		if(ismob(item) || isobj(item))
			swallow()
	if(item_value_consumed >= 30) //change to 100 lol
		var/datum/antagonist/bingle/bongle = IS_BINGLE(bingleprime.current)
		var/datum/team/bingles/bingles_team = bongle.get_team()
		for(var/mob/living/basic/bingle/bong in bingles_team.members)
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
		item_value_consumed += 10
		animate(swallowed_mob, transform = matrix_two, time = 0.1 SECONDS)
	else if(isobj(item))
		var/obj/swallowed_obj = item
		var/matrix/matrix_one = matrix()
		var/matrix/matrix_two = matrix()
		matrix_one.Scale(0,0)
		matrix_two.Scale(1,1)
		animate(swallowed_obj, transform = matrix_one, time = 1 SECONDS)
		if(!(swallowed_obj in pit_contents_items))
			pit_contents_items += swallowed_obj
		if(pit_storage)
			swallowed_obj.forceMove(pit_storage)
		else
			qdel(swallowed_obj)
		item_value_consumed += 1
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
