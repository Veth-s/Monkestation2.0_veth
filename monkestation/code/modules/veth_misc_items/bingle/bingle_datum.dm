#define BINGLE_EVOLVE "bingle evolve"

/datum/antagonist/bingle
	name = "\improper Bingle"
	show_in_antagpanel = TRUE
	roundend_category =  "bingles"
	antagpanel_category =  ANTAG_GROUP_BINGLES
	job_rank = ROLE_BINGLE
	antag_hud_name = "bingle"
	show_name_in_check_antagonists =  TRUE
	hud_icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/bingle_hud.dmi'
	show_to_ghosts = TRUE
	var/static/datum/team/bingles/dont_bungle_the_bingle
	var/obj/structure/bingle_hole/pit_check

/datum/antagonist/bingle/get_preview_icon()
	return finish_preview_icon(icon('monkestation/code/modules/veth_misc_items/bingle/icons/bingles.dmi', "bingle"))

/datum/antagonist/bingle/on_gain()
	ADD_TRAIT(owner, TRAIT_BINGLE, "bingle")
	ADD_TRAIT(owner, TRAIT_CLUMSY, "bingle")
	ADD_TRAIT(owner, TRAIT_DUMB, "bingle")
	ADD_TRAIT(owner, TRAIT_NO_PAIN_EFFECTS, "bingle")
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, "bingle")
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "bingle")
	ADD_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, "bingle")
	ADD_TRAIT(owner, TRAIT_HEALS_FROM_BINGLE_HOLES, "bingle")
	AddComponent(/datum/component/swarming, 16, 16)
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(LifeTick))
	RegisterSignal(owner, BINGLE_EVOLVE, PROC_REF(evolve))
	var/mob/living/basic/bingle/bingle = owner

	for(var/datum/quirk/quirk as anything in bingle.quirks)
		bingle.remove_quirk(quirk)
	if(!dont_bungle_the_bingle)
		dont_bungle_the_bingle = new

	dont_bungle_the_bingle.add_member(owner)
	return ..()

/datum/antagonist/bingle/greet()
	. = ..()
	to_chat(owner.current, span_warning("<B>You are a [name]! You must feed the pit at any cost!"))

/datum/antagonist/bingle/get_team()
	return dont_bungle_the_bingle

/datum/antagonist/bingle/proc/LifeTick(mob/living/source, seconds_between_ticks, times_fired)
	SIGNAL_HANDLER

	if(source.istate & source.istate == ISTATE_HARM)
		source.icon_state = "bingle_combat"
	else
		source.icon_state = "bingle"

/datum/antagonist/bingle/proc/evolve()
	SIGNAL_HANDLER
	var/mob/living/basic/bingle/bongle = owner.current
	bongle.maxHealth = 300
	bongle.health = 300
	bongle.obj_damage = 100
	bongle.melee_damage_lower = 50
	bongle.melee_damage_upper = 60
	bongle.armour_penetration = 20

/datum/action/cooldown/bingle/spawn_hole
	name = "Spawn Bingle Pit"
	desc = "Spawn the pit that you need to fill with items!"
	button_icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	button_icon_state = "binglepit"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bingle/spawn_hole/Activate(atom/target)
	if(!isliving(owner))
		return FALSE
	var/turf/selected_turf = get_turf(owner)
	if(!check_hole_spawn(selected_turf))
		to_chat(owner, span_warning("This area doesn't have enough space to spawn a bingle pit! It needs a total of 3 by 3 meters of space!"))
		return FALSE
	spawn_hole(selected_turf)

/datum/action/cooldown/bingle/spawn_hole/proc/check_hole_spawn(turf/selected_turf)
	var/list/direction_list = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	for(var/direction in direction_list)
		var/turf/checker = get_step(selected_turf, direction)
		if(!checker || checker.density)
			return FALSE
	return TRUE

/datum/action/cooldown/bingle/spawn_hole/proc/spawn_hole(turf/selected_turf)
	var/datum/antagonist/bingle/bingle_datum = IS_BINGLE(owner)
	if(!selected_turf)
		to_chat(owner, span_notice("No selected turf found!"))
		return
	var/obj/structure/bingle_hole/hole = new(selected_turf)
	hole.bingleprime = owner
	bingle_datum.pit_check = hole
	Remove(owner)
