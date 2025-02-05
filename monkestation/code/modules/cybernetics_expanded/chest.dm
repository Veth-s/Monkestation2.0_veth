/*
 A heart implant that gives you more stamina
    An appendix that will inject you with some healy chems on a cooldown if you drop below 25% health
    Lung implant that makes you take reduced oxydamage,
    A “double heart” heart that lowers your safe blood levels,  (lets you bleed more for less effects)IE death normally occurs at 340 blood for example and that and all other blood levels maybe get -60 blood trigger points
    Single use heal implant that destroys itself on trigger (easiest shit ever to code)
    Berserk mod (like sandevestan but instead it makes you hit faster, harder, and take less stamina but stuns you after effect ends like changeling muscle stims
    Cybernetic that makes you move faster at 30%-0% health
	Implant that will electric shock the closest person near you once if you drop below 50% health and it has a 5 min cooldown

*/
/obj/item/organ/internal/cyberimp/chest/honeycomb_stamina_supplier
	name = "honeycomb stamina supplier"
	desc = "A Honeycomb Co-operative stamina supplier, extending the users supply of stamina"
	icon = 'monkestation/code/modules/cybernetics_expanded/placeholder.dmi'
	icon_state = "1"
	encode_info = AUGMENT_NT_LOWLEVEL_LINK
	///how much extra stamina a mob gets.
	var/stamina_bonus = 50

/obj/item/organ/internal/cyberimp/chest/honeycomb_stamina_supplier/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	if(.)
		owner.stamina.set_maximum(owner.stamina.maximum + stamina_bonus)

/obj/item/organ/internal/cyberimp/chest/honeycomb_stamina_supplier/Remove(mob/living/carbon/M, special = 0)
	owner.stamina.set_maximum(owner.stamina.maximum - stamina_bonus)
	. = ..()

/obj/item/organ/internal/cyberimp/chest/honeycomb_helppendix
	name = "honeycomb helppendix"
	desc = "A Honeycomb Co-operative brand super appendix, which injects you with small amounts of chemicals upon hitting half life!"
	icon = 'monkestation/code/modules/cybernetics_expanded/placeholder.dmi'
	icon_state = "1"
	encode_info = AUGMENT_NT_LOWLEVEL
	slot = ORGAN_SLOT_APPENDIX
	zone = BODY_ZONE_PRECISE_GROIN
	var/reagent_list = list(
		/datum/reagent/medicine/c2/convermol = 4,
		/datum/reagent/medicine/c2/libital = 4,
		/datum/reagent/medicine/c2/aiuri = 4,
		/datum/reagent/medicine/c2/multiver = 4,
	)
	var/max_ticks_cooldown = 5 MINUTES
/obj/item/organ/internal/cyberimp/chest/honeycomb_helppendix/proc/on_life()
	if(!check_compatibility())
		return
	if(owner.nutrition > NUTRITION_LEVEL_STARVING && current_ticks_cooldown > 0)

		owner.nutrition -= 5
		owner.adjust_jitter(1)
		current_ticks_cooldown -= SSmobs.wait
		return

	if(current_ticks_cooldown <= 0 && owner.health < 25)
		current_ticks_cooldown = max_ticks_cooldown
		on_effect()

/obj/item/organ/internal/cyberimp/chest/honeycomb_helppendix/proc/on_effect()
	owner.reagents.add_reagent_list(reagent_list)
	overlay = mutable_appearance('icons/effects/effects.dmi', "biogas", ABOVE_MOB_LAYER)
	overlay.color = "#9f04ff"
	RegisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	addtimer(CALLBACK(src, PROC_REF(remove_overlay)),max_ticks_cooldown/2)
	to_chat(owner, "<span class = 'notice'> You feel a rush of adrenaline as your implant activates.")
	return
/obj/item/organ/internal/cyberimp/chest/honeycomb_helppendix/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(overlay)
		overlays += overlay
/obj/item/organ/internal/cyberimp/chest/honeycomb_helppendix/proc/remove_overlay()
	QDEL_NULL(overlay)

	UnregisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS)
/obj/item/organ/internal/lungs/cyberimp/chest/honeycomb_lungs
	name = "honeycomb large lung"
	desc = "A Honeycomb Co-operative brand lung, which makes you breathe real good!"
	icon = 'monkestation/code/modules/cybernetics_expanded/placeholder.dmi'
	icon_state = "1"
	encode_info = AUGMENT_NT_LOWLEVEL
	slot = ORGAN_SLOT_LUNGS
	zone = BODY_ZONE_CHEST
	oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE * 0.9
	oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE * 0.9
	nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE * 0.9
	nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE * 0.9
	co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE * 0.9
	co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE * 0.9
/obj/item/organ/internal/lungs/cyberimp/chest/honeycomb_lungs/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
/obj/item/organ/internal/lungs/cyberimp/chest/honeycomb_lungs/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
