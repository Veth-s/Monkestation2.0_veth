/datum/action/cooldown/slasher/envelope_darkness
	name = "Darkness Shroud"
	desc = "Become masked in the light and visible in the dark."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS


/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	START_PROCESSING(SSprocessing, src)

/datum/action/cooldown/slasher/envelope_darkness/process()
	var/turf/below_turf = get_turf(owner)
	var/turf_light_level = below_turf.get_lumcount()
	if(turf_light_level && turf_light_level == 0)
		owner.alpha = 255
	else if (turf_light_level && 0.1 <= turf_light_level <= 0.3)
		owner.alpha = 150
	else if (turf_light_level && 0.4 <= turf_light_level <= 0.6)
		owner.alpha = 75
	else if (turf_light_level && 0.7 <= turf_light_level)
		owner.alpha = 0


/datum/action/cooldown/slasher/envelope_darkness/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
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

/datum/action/cooldown/slasher/envelope_darkness/proc/bullet_impact(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	return COMPONENT_BULLET_PIERCED
