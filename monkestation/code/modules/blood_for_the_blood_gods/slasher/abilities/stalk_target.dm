/datum/action/cooldown/slasher/stalk_target
	name = "Stalk Target"
	desc = "Get a target to stalk, standing near them for 3 minutes will rip their soul from their body. YOU MUST PROTECT THEM FROM HARM."

	button_icon_state = "slasher_possession"

	cooldown_time = 5 MINUTES

/datum/action/cooldown/slasher/stalk_target/Activate(atom/target)
	. = ..()
	var/list/possible_targets = list()
	for(var/mob/possible_target as anything in GLOB.mob_list)
		//if(possible_target == owner.mind)
			//continue
		if(!ishuman(possible_target))
			continue
		if(possible_target.stat == DEAD)
			continue
		possible_targets += possible_target//.current

	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	if(slasherdatum && slasherdatum.stalked_human)
		qdel(slasherdatum.stalked_human.tracking_beacon)

	var/mob/living/living_target = pick(possible_targets)
	var/mob/living/carbon/human/owner_human = owner
	if(!owner_human.team_monitor)
		owner_human.tracking_beacon = owner_human.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#00660e")
		owner_human.team_monitor = owner_human.AddComponent(/datum/component/team_monitor, "slasher", null, owner_human.tracking_beacon)

	living_target.tracking_beacon = living_target.AddComponent(/datum/component/tracking_beacon, "slasher", null, null, TRUE, "#660000")
	if(slasherdatum)
		slasherdatum.stalked_human = living_target
	owner_human.team_monitor.add_to_tracking_network(living_target.tracking_beacon)
	owner_human.team_monitor.show_hud(owner_human)
	to_chat(owner, span_notice("Your new target is [living_target]."))
	START_PROCESSING(SSprocessing, src)

/datum/action/cooldown/slasher/stalk_target/process()
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	for(var/mob/M in view(10, owner))
		if(M == slasherdatum.stalked_human)
			slasherdatum.time_counter += 1
		else continue
	if(slasherdatum.time_counter >= 10)
		STOP_PROCESSING(SSprocessing, src)
		SoulRip(slasherdatum.stalked_human)
		owner.mind.has_antag_datum(/datum/antagonist/slasher).stalked_human = null
		unset_click_ability(owner, refund_cooldown = FALSE)

/datum/action/cooldown/slasher/stalk_target/proc/SoulRip(mob/living/carbon/human/target)
	target.soul_sucked = TRUE
	if(HAS_TRAIT(target, TRAIT_USES_SKINTONES))
		target.skin_tone = "albino"
		target.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	else
		var/datum/color_palette/generic_colors/located = target.dna.color_palettes[/datum/color_palette/generic_colors]
		located.mutant_color = "#FFFFFF"
	to_chat(target, span_warning("YOU FEEL COLD, AS IF YOUR SOUL HAS BEEN RIPPED FROM YOUR BODY."))
	to_chat(owner, span_warning("YOU SUCCESSFULLY SIPHON THE SOUL OF [target]."))
	target.apply_damage(100, damagetype = BRUTE, spread_damage = TRUE)
	target.set_jitter_if_lower(10 SECONDS)
	target.emote("scream")
	target.say("AAAAAAHHHH!!!", forced = "soulsucked")
	var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
	slasherdatum.souls_sucked++
	slasherdatum.linked_machette.force += 2.5
	slasherdatum.linked_machette.throwforce += 2.5
	slasherdatum.time_counter = 0

