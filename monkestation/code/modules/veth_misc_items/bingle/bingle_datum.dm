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

	for(var/datum/quirk/quirk as anything in owner.current.quirks)
		owner.current.remove_quirk(quirk)
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

