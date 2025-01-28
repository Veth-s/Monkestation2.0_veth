/datum/action/cooldown/slasher/envelope_darkness
	name = "Darkness Shroud"
	desc = "Become masked in the light and visible in the dark."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS


/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	START_PROCESSING(SSprocessing, src)
//	RegisterSignal(owner, COMSIG_ATOM_GET_EXAMINE_NAME, PROC_REF(check_visibility))
	//RegisterSignal(owner, COMSIG_LIVING_CHECK_HUD_VISABILITY, PROC_REF(check_visibility))

/datum/action/cooldown/slasher/envelope_darkness/process()
	var/turf/below_turf = get_turf(owner)
	var/turf_light_level = below_turf.get_lumcount()
	// Convert light level to alpha inversely (darker = more visible)
	owner.alpha = clamp(200 * (1 - turf_light_level), 0, 200)


/datum/action/cooldown/slasher/envelope_darkness/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	UnregisterSignal(owner, COMSIG_ATOM_GET_EXAMINE_NAME)
	STOP_PROCESSING(SSprocessing, src)

/datum/action/cooldown/slasher/envelope_darkness/proc/break_envelope(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	if(damage < 5)
		return
	var/mob/living/owner_mob = owner
	for(var/i = 1 to 4)
		owner_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))


	var/datum/antagonist/slasher/slasher = owner_mob.mind?.has_antag_datum(/datum/antagonist/slasher)

	slasher?.reduce_fear_area(15, 4)
	STOP_PROCESSING(SSprocessing, src)

/*
/datum/action/cooldown/slasher/envelope_darkness/proc/check_visibility(datum/source)
	SIGNAL_HANDLER
	var/turf/T = get_turf(owner)
	if(T.get_lumcount() < 0.5)
		return COMPONENT_BLOCK_HUD_VIS
*/
/datum/action/cooldown/slasher/envelope_darkness/proc/bullet_impact(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	return COMPONENT_BULLET_PIERCED
