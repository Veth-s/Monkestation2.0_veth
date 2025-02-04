/* CYBERNETICS TO ADD THAT ARE NOT STOLEN FROM CYBERPUNK
    Leg that makes you move slightly faster
    Leg cybernetic implant that removes your footstep sound
    Monowire arm implants 🙂
    A heart implant that gives you more stamina
    An appendix that will inject you with some healy chems on a cooldown if you drop below 25% health
    Lung implant that makes you take reduced oxydamage,
    A “double heart” heart that lowers your safe blood levels,  (lets you bleed more for less effects)IE death normally occurs at 340 blood for example and that and all other blood levels maybe get -60 blood trigger points
    Single use heal implant that destroys itself on trigger (easiest shit ever to code)
    Berserk mod (like sandevestan but instead it makes you hit faster, harder, and take less stamina but stuns you after effect ends like changeling muscle stims
    Cybernetic that makes you move faster at 30%-0% health
    Cybernetic that makes you attack slightly faster (syndi only?)
    Pain editor implant - reduces all pain quicker
    Legs that let you like charge or somethin
    Implant that will electric shock the closest person near you once if you drop below 50% health and it has a 5 min cooldown
PEPS knockout arm inplant
*/
/obj/item/organ/internal/cyberimp/leg/zoomieleg
	name = "honeycomb leg augmentator"
	desc = "A leg implant designed by Honeycomb Co. to make the user run that little bit faster!"
	encode_info = AUGMENT_NT_LOWLEVEL
	double_legged = FALSE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'monkestation/code/modules/cybernetics_expanded/placeholder.dmi'
	icon_state = "1"

/obj/item/organ/internal/cyberimp/leg/zoomieleg/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	var/owner_cms = M.cached_multiplicative_slowdown
	owner_cms -= 0.3

/obj/item/organ/internal/cyberimp/leg/zoomieleg/emp_act(severity)
	. = ..()
	var/mob/owner = ownerlimb.owner
	var/owner_cms = owner.cached_multiplicative_slowdown
	owner_cms += 0.3

/obj/item/organ/internal/cyberimp/leg/zoomieleg/Remove(mob/living/carbon/M, special)
	var/owner_cms = owner.cached_multiplicative_slowdown
	owner_cms += 0.3
	return ..()

/obj/item/organ/internal/cyberimp/leg/silent_step
	name = "honeycomb extra-cushioned feet pads"
	desc = "A leg implant designed by Honeycombo Co. to make you realllll sneaky..."
	encode_info  = AUGMENT_NT_HIGHLEVEL
	double_legged = TRUE
	w_class = WEIGHT_CLASS_SMALL
	icon = 'monkestation/code/modules/cybernetics_expanded/placeholder.dmi'
	icon_state = "1"

/obj/item/organ/internal/cyberimp/leg/silent_step/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(owner,TRAIT_SILENT_FOOTSTEPS,type)

/obj/item/organ/internal/cyperimp/leg/silent_step/update_implants()
	. = ..()
	if(!check_compatibility())
		REMOVE_TRAIT(owner,TRAIT_SILENT_FOOTSTEPS,type)
		return
	ADD_TRAIT(owner,TRAIT_SILENT_FOOTSTEPS,type)


/obj/item/organ/internal/cyberimp/leg/silent_step/emp_act(severity)
	. = ..()
