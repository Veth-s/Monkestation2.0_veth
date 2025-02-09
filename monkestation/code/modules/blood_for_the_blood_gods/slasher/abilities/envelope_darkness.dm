/datum/action/cooldown/slasher/envelope_darkness
	name = "Darkness Shroud"
	desc = "Become masked in the light and visible in the dark."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS
	var/processing = FALSE


/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	if(processing == TRUE)
		break_envelope()
		processing = FALSE
		build_all_button_icons()
	RegisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(break_envelope))
	RegisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT,  PROC_REF(break_envelope))
	START_PROCESSING(SSfastprocess, src)
	processing = TRUE
	build_all_button_icons()

/datum/action/cooldown/slasher/envelope_darkness/process()
	var/turf/below_turf = get_turf(owner)
	var/turf_light_level = below_turf.get_lumcount()
	// Convert light level to alpha inversely (darker = more visible)
	owner.alpha = clamp(200 * (1 - turf_light_level), 0, 200)
	build_all_button_icons()



/datum/action/cooldown/slasher/envelope_darkness/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	owner.alpha = 255
	STOP_PROCESSING(SSfastprocess, src)

/datum/action/cooldown/slasher/envelope_darkness/proc/break_envelope(datum/source, damage_amount, damagetype)
	SIGNAL_HANDLER
	if(damage_amount < 50)
		return
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	var/mob/living/owner_mob = owner
	for(var/i = 1 to 4)
		owner_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))


	var/datum/antagonist/slasher/slasher = owner_mob.mind?.has_antag_datum(/datum/antagonist/slasher)

	slasher?.reduce_fear_area(15, 4)
	owner_mob.alpha = 255
	STOP_PROCESSING(SSfastprocess, src)

	unset_click_ability(owner_mob, refund_cooldown = FALSE)


/datum/action/cooldown/slasher/envelope_darkness/proc/bullet_impact(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	return COMPONENT_BULLET_PIERCED
