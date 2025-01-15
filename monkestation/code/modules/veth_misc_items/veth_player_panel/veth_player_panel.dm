/datum/player_panel_veth/ //required for tgui component
	var/title = "Veth's Ultimate Player Panel"

/client/proc/player_panel_veth() //proc for verb in game tab

	set name = "Player Panel Veth"
	set category = "Admin.Game"
	set desc = "Updated Player Panel with TGUI. Currently in testing."

	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/player_panel_veth/tgui = new(usr)
	tgui.ui_interact(usr)
	to_chat(src, span_interface("VUAP has been opened!"), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "VUAP")

/datum/player_panel_veth/ui_data(mob/user)
	var/list/PlayerData = list()
	var/mobs = sort_mobs()
	for (var/mob/M in mobs)
		if (M.ckey)
			PlayerData += list(list(
				"name" = M.name || "No Character",
				"job" = M.job || "No Job",
				"ckey" = M.ckey || "No Ckey",
				"is_antagonist" = is_special_character(M, allow_fake_antags = TRUE),
				"last_ip" = M.lastKnownIP ||	 "No Last Known IP",
				"ref" = REF(M)
			))
	return list(
		"Data" = PlayerData
	)

/datum/player_panel_veth/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(params["selectedPlayerCkey"]) //gets the mob datum from the ckey in client datum which we've saved. if there's a better way to do this please let me know
	switch(action) //switch for all the actions from the frontend - all of the Topic() calls check rights & log inside themselves.
		if("sendPrivateMessage")
			usr.client.cmd_admin_pm(M.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("follow")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Now following [M.ckey].", confidential = TRUE)
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			to_chat(usr, "Smiting [M.ckey].", confidential = TRUE)
		if("refresh")
			ui.send_update()
			return
		if("oldPP")
			usr.client.holder.Topic(null, list(
				"adminplayeropts" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("checkPlayers")
			usr.client.check_players() //logs/rightscheck inside the proc
			return
		if("checkAntags")
			usr.client.check_antagonists() //logs/rightscheck inside the proc
			return
		if("faxPanel")
			usr.client.fax_panel() //logs/rightscheck inside the proc
			return
		if("gamePanel")
			usr.client.game_panel() //logs/rightscheck inside the proc
			return
		if("comboHUD")
			usr.client.toggle_combo_hud() //logs/rightscheck inside the proc
			return
		if("adminVOX")
			usr.client.AdminVOX() //logs/rightscheck inside the proc
			return
		if("generateCode")
			usr.client.generate_code() //logs/rightscheck inside the proc
			return
		if("viewOpfors")
			usr.client.view_opfors() //logs/rightscheck inside the proc
			return
		if("openAdditionalPanel") //logs/rightscheck inside the proc
			usr.client.selectedPlayerCkey = params["selectedPlayerCkey"]
			usr.client.vuap_open()
			return
		if("createCommandReport")
			usr.client.cmd_admin_create_centcom_report() //logs/rightscheck inside the proc
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes") //i'm pretty sure this checks rights inside the proc but to be safe
			if(!check_rights(NONE))
				return
			browse_messages(target_ckey = M.ckey)
			return
		if("vv") //logs/rightscheck inside the proc
			usr.client.debug_variables(M)
			return
		if("tp")
			usr.client.holder.Topic(null, list(
				"traitor" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return

/datum/player_panel_veth/ui_interact(mob/user, datum/tgui/ui)

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VethPlayerPanel")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/player_panel_veth/ui_state(mob/user)
	return GLOB.admin_state


/client //this is needed to hold the selected player ckey for moving to and from pp/vuap
	var/selectedPlayerCkey = ""

/client/proc/vuap_open_context(mob/M in GLOB.mob_list) //this is the proc for the right click menu
	set category = null
	set name = "Open New Player Panel"
	if(!check_rights(NONE))
		return
	usr.client.selectedPlayerCkey = M.ckey
	usr.client.vuap_open()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "VUAP")

/datum/vuap_personal

/*features that need to add

logsweep
rightscheck sweep

Some (poor) explanation of what's going on -
player_panel_veth is the new tgui version of the player panel, it also includes some most pressed verbs
I've tried to comment in as much stuff as possible so it can be changed in the future is necessary
Vuap_personal is the new tgui version of the options panel. It basically does everything the same way the player panel does
minus some features that the player panel didn't have I guess.
the client/var/selectedPlayerCkey is used to hold the selected player ckey for moving to and from pp/vuap






*/
/datum/vuap_personal/ui_data(mob/user)
	var/ckey = usr.client?.selectedPlayerCkey
	if(!ckey)
		return list("Data" = list())
	var/mob/player = get_mob_by_ckey(ckey)
	var/client/C = player?.client
	// Fallback values for player data
	var/list/PlayerData = list(
		"characterName" = "No Character",
		"ckey" = ckey || "Unknown",
		"ipAddress" = "0.0.0.0",
		"CID" = "NO_CID",
		"gameState" = "Unknown",
		"byondVersion" = "0.0.0",
		"mobType" = "null",
		"firstSeen" = "Never",
		"accountRegistered" = "Unknown",
		"muteStates" = list(
			"ic" = FALSE,
			"ooc" = FALSE,
			"pray" = FALSE,
			"adminhelp" = FALSE,
			"deadchat" = FALSE,
			"webreq" = FALSE
		)
	)

	// Only update values if we have valid data
	if(player && C)
		PlayerData["characterName"] = player.real_name || "No Character"
		PlayerData["ipAddress"] = C.address || "0.0.0.0"
		PlayerData["CID"] = C.computer_id || "NO_CID"
		PlayerData["gameState"] = istype(player) ? "Active" : "Unknown"
		PlayerData["byondVersion"] = "[C.byond_version || 0].[C.byond_build || 0]"
		PlayerData["mobType"] = "[initial(player.type)]" || "null"
		PlayerData["firstSeen"] = C.account_join_date || "Never"
		PlayerData["accountRegistered"] = C.account_age || "Unknown"
		// Safely check mute states
		if(C.prefs)
			PlayerData["muteStates"] = list(
				"ic" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_IC),
				"ooc" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_OOC),
				"pray" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_PRAY),
				"adminhelp" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_ADMINHELP),
				"deadchat" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_DEADCHAT),
				"webreq" = !isnull(C.prefs.muted) && (C.prefs.muted & MUTE_INTERNET_REQUEST),
			)
	return list("Data" = PlayerData)

/datum/vuap_personal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VUAP_personal")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/vuap_personal/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(usr.client.selectedPlayerCkey)
	if(!M)
		tgui_alert(usr, "Selected player not found!")
		return
	//pretty much all of these actions use the Topic() admin call. This admin call is secure, checks rights, and does stuff the way the old player panel did.
	//see code/modules/admin/topic.dm for more info on how it works.
	//essentially you have to pass a list of parameters to Topic(). It needs to be provided with an admin token to do any of its functions.
	switch(action)
		if("refresh")
			ui.send_update()
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "cid",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(M.client),
			))
			return
		if("relatedbyip")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "ip",
			"admin_token" = usr.client.holder.href_token,
			"client" = REF(M.client),
			))
			return
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list(
				"boot2" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("ban")
			if(!check_rights(R_BAN))
				return
			usr.client.ban_panel()
			SSblackbox.record_feedback("tally", "VUAP", 1, "Ban")
			return
		if("prison")
			usr.client.holder.Topic(null, list(
				"sendtoprison" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("unprison")
			if (is_centcom_level(M.z))
				SSjob.SendToLateJoin(M)
				to_chat(usr, "Unprisoned [M.ckey].", confidential = TRUE)
				message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]")
				log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
			else
				tgui_alert(usr,"[M.name] is not prisoned.")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Unprison")
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		// Message Section
		if("pm")
			if (!check_rights(NONE))
				return
			usr.client.cmd_admin_pm(M.ckey)
			SSblackbox.record_feedback("tally", "VUAP", 1, "PM")
			return
		if("sm")
			usr.client.holder.Topic(null, list(
				"subtlemessage" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("narrate")
			usr.client.holder.Topic(null, list(
				"narrateto" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("playsoundto")
			usr.client.holder.Topic(null, list(
				"playsoundto" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return

		// Movement Section
		if("jumpto")
			usr.client.holder.Topic(null, list(
				"jumpto" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("get")
			usr.client.holder.Topic(null, list(
				"getmob" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("send")
			usr.client.holder.Topic(null, list(
				"sendmob" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("lobby")
			usr.client.holder.Topic(null, list(
				"sendbacktolobby" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("flw")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(M),
				"admin_token" = usr.client.holder.href_token,
			))
			return
		if("cryo")
			M.vv_send_cryo()
			return
		// Info Section
		if("vv") //checks rights inside the proc
			usr.client.debug_variables(M)
			SSblackbox.record_feedback("tally", "VUAP", 1, "VV")
			return
		if("tp")
			usr.client.holder.Topic(null, list(
				"traitor" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("skills")
			usr.client.holder.Topic(null, list(
				"skill" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("logs")
			usr.client.holder.Topic(null, list(
				"individuallog" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("notes")
			if(!check_rights(NONE))
				return
			browse_messages(target_ckey = M.ckey)
			return
		// Transformation Section
		if("makeghost")
			usr.client.holder.Topic(null, list(
				"simplemake" = "observer",
				"mob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("makehuman")
			usr.client.holder.Topic(null, list(
				"simplemake" = "human",
				"mob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("makemonkey")
			usr.client.holder.Topic(null, list(
				"simplemake" = "monkey",
				"mob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("makeborg")
			usr.client.holder.Topic(null, list(
				"simplemake" = "robot",
				"mob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("makeai")
			usr.client.holder.Topic(null, list(
				"makeai" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		//health section
		if("healthscan")
			if(!check_rights(NONE))
				return
			healthscan(usr, M, advanced = TRUE, tochat = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "HealthScan")
		if("chemscan")
			if(!check_rights(NONE))
				return
			chemscan(usr, M)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ChemScan")
		if("aheal")
			usr.client.holder.Topic(null, list(
				"revive" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("giveDisease")
			if(!check_rights(NONE))
				return
			usr.client.give_disease(M)
			SSblackbox.record_feedback("tally", "VUAP", 1, "GiveDisease")
			return
		if("cureAllDiseases")
			if (istype(M, /mob/living))
				var/mob/living/L = M
				L.fully_heal(HEAL_NEGATIVE_DISEASES)
			to_chat(usr, "Cured all negative diseases on [M.ckey].", confidential = TRUE)
			SSblackbox.record_feedback("tally", "VUAP", 1, "CureAllDiseases")
			return
		if("diseasePanel") //rights check inside the proc
			usr.client.diseases_panel(M)
			SSblackbox.record_feedback("tally", "VUAP", 1, "DiseasePanel")
			return
		if("modifytraits")
			usr.client.holder.modify_traits(M)
			SSblackbox.record_feedback("tally", "VUAP", 1, "ModifyTraits")
			return
		// Misc Section
		if("language")
			usr.client.holder.Topic(null, list(
				"languagemenu" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("forcesay")
			usr.client.holder.Topic(null, list(
				"forcespeech" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
		if("applyquirks")
			usr.client.holder.Topic(null, list(
				"applyquirks" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
		if("thunderdome1")
			usr.client.holder.Topic(null, list(
				"tdome1" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdome2")
			usr.client.holder.Topic(null, list(
				"tdome2" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("commend")
			usr.client.holder.Topic(null, list(
				"admincommend" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("playtime")
			usr.client.holder.Topic(null, list(
				"getplaytimewindow" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeadmin")
			usr.client.holder.Topic(null, list(
				"tdomeadmin" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("thunderdomeobserve")
			usr.client.holder.Topic(null, list(
				"tdomeobserver" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("dblink")
			usr.client.holder.Topic(null, list(
				"centcomlookup" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
		if("spawncookie")
			usr.client.holder.Topic(null, list(
				"adminspawncookie" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_IC)
					ui.send_update()
					return
				if("ooc")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_OOC)
					ui.send_update()
					return
				if("pray")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_PRAY)
					ui.send_update()
					return
				if("adminhelp")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ADMINHELP)
					ui.send_update()
					return
				if("deadchat")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_DEADCHAT)
					ui.send_update()
					return
				if("webreq")
					cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_INTERNET_REQUEST)
					ui.send_update()
					return
			return

		if("toggleAllMutes")
			cmd_admin_mute(usr.client.selectedPlayerCkey, MUTE_ALL)
			ui.send_update()
			return


/datum/vuap_personal/ui_state(mob/user)
	return GLOB.admin_state

/client/proc/vuap_open()
	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/vuap_personal/tgui = new(usr)
	tgui.ui_interact(usr)
	SSblackbox.record_feedback("tally", "VUAP", 1, "VUAP_open")


