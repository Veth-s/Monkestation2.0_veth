/mob/living/basic/bingle/
	name = "bingle"
	real_name = "bingle"
	desc = "A funny lil blue guy."
	speak_emote = list("screeches", "whines", "blurbles", "bingles")
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/bingles.dmi'
	icon_state = "bingle"
	icon_living = "bingle"
	icon_dead = "bingle"
	istate = ISTATE_HARM

	mob_biotypes = MOB_BEAST
	pass_flags = PASSTABLE

	maxHealth = 150
	health = 150
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = TCMB

	obj_damage = 70
	melee_damage_lower = 30
	melee_damage_upper = 30
	melee_attack_cooldown = CLICK_CD_MELEE

	lighting_cutoff_red = 10
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 35

	attack_verb_continuous = "bings"
	attack_verb_simple = "bing"
	attack_sound = 'sound/effects/blobattack.ogg' //'monkestation/code/moduoles/veth_misc_items/bingle/sound/bingle_attack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = null

	light_outer_range = 4

/mob/living/basic/bingle/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	if(!isliving(target))
		return ..()
	var/mob/living/mob_target = target
	mob_target.Disorient(6 SECONDS, 5, paralyze = 10 SECONDS, stack_status = FALSE)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	return ..()
