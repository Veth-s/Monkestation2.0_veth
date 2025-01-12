/datum/player_panel_veth/ //required for tgui component
	var/title = "Veth's Ultimate Player Panel"

/client/proc/player_panel_veth()

	set name = "Player Panel Veth"
	set category = "Admin"
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
			PlayerData += list(list(  // Note: Nested list() here
				"name" = M.name,
				"job" = M.job,
				"ckey" = M.ckey,
				"is_antagonist" = is_special_character(M, allow_fake_antags = TRUE),
				"last_ip" = M.lastKnownIP,
				"ref" = REF(M)
			))
	return list(
		"Data" = PlayerData  // Return as named parameter
	)
/datum/player_panel_veth/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!check_rights(NONE))
		return
	var/mob/M = get_mob_by_ckey(params["selectedPlayerCkey"])
	switch(action)
		if("sendPrivateMessage")
			var/ckey = params["selectedPlayerCkey"]
			var/message = params["inputMessage"]
			usr.client.cmd_admin_pm(ckey, message)
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
			usr.client.check_players()
			return
		if("checkAntags")
			usr.client.check_antagonists()
			return
		if("faxPanel")
			usr.client.fax_panel()
			return
		if("gamePanel")
			usr.client.game_panel()
			return
		if("comboHUD")
			usr.client.toggle_combo_hud()
			return
		if("adminVOX")
			usr.client.AdminVOX()
			return
		if("generateCode")
			usr.client.generate_code()
			return
		if("viewOpfors")
			usr.client.view_opfors()
			return
		if("openAdditionalPanel")
			usr.client.selectedPlayerCkey = params["selectedPlayerCkey"]
			usr.client.vuap_open()

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
/datum/vuap_personal

/*features that need to add
frontend lol
info for IP/CID on vuap
related by ip/cid
health status/damages for frontend
chemscan button
popup
spawncookie





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
		PlayerData["characterName"] = player.real_name || "Unknown"
		PlayerData["ipAddress"] = C.address || "0.0.0.0"
		PlayerData["CID"] = C.computer_id || "NO_CID"
		PlayerData["gameState"] = istype(player) ? "Active" : "Unknown"
		PlayerData["byondVersion"] = "[C.byond_version || 0].[C.byond_build || 0]"
		PlayerData["mobType"] = "[player.type]" || "null"
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
		to_chat(usr, "Selected player not found!", confidential = TRUE)
		return
	switch(action)
		if("refresh")
			ui.send_update()
			return
		if("relatedbycid")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "cid",
			"admin_token" = usr.client.holder.href_token
			"client" = REF(M.client)
			))
			return
		if("relatedbyip")
			usr.client.holder.Topic(null, list(
			"showrelatedacc" = "ip",
			"admin_token" = usr.client.holder.href_token
			"client" = REF(M.client)
			))
			return
		// Punish Section
		if("kick")
			usr.client.holder.Topic(null, list(
				"boot2" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("ban")
			usr.client.ban_panel()
			return
		if("prison")
			usr.client.holder.Topic(null, list(
				"sendtoprison" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("unprison")
			//unprison not done lol
			return
		if("smite")
			usr.client.holder.Topic(null, list(
				"adminsmite" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return

		// Message Section
		if("pm")
			usr.client.cmd_admin_pm(M.ckey, params["message"])
			return
		if("sm")
			usr.client.cmd_admin_subtle_message(M)
			return
		if("narrate")
			usr.client.holder.Topic(null, list(
				"narrateto" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("playsoundto")
			var/sound = params["sound"]
			if(sound)
				SEND_SOUND(M, sound(sound))
			return

		// Movement Section //lobby broken
		if("jumpto")
			usr.client.holder.Topic(null, list(
				"jumpto" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("get")
			usr.client.holder.Topic(null, list(
				"getmob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("send")
			usr.client.holder.Topic(null, list(
				"sendmob" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("lobby")
			usr.client.holder.Topic(null, list(
				"sendbacktolobby" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		if("flw")
			usr.client.holder.Topic(null, list(
				"adminplayerobservefollow" = REF(M),
				"admin_token" = usr.client.holder.href_token
			))
			return
		// Info Section
		if("vv")
			usr.client.debug_variables(M)
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


