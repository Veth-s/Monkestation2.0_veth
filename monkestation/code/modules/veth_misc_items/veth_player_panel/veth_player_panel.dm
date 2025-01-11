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
	switch(action)
		if("sendPrivateMessage")
			var/ckey = params["selectedPlayerCkey"]
			var/message = params["inputMessage"]
			usr.client.cmd_admin_pm(ckey, message)
			return
		if("follow")
			var/ckey = params["selectedPlayerCkey"]
			ADMIN_FLW(ckey)
			to_chat(usr, "Now following [ckey].", confidential = TRUE)
			return
		if("smite")
			var/ckey = params["selectedPlayerCkey"]
			usr.client.smite(ckey)
			to_chat(usr, "Smiting [ckey].", confidential = TRUE)
		if("refresh")
			ui.send_update()
			return
		if("oldPP")
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

/*features that need to be add
frontend lol
info for IP/CID on vuap
related by ip/cid
health status/damages for frontend
chemscan button





*/
/datum/vuap_personal/ui_data(mob/user)
    var/ckey = usr.client.selectedPlayerCkey
    var/mob/player = GLOB.directory[ckey]
    var/client/C = player.client

    world.log << "Debug: Processing ui_data for [ckey]"

    var/list/PlayerData = list(
        "characterName" = player.real_name,
        "ckey" = ckey,
        "ipAddress" = C.address,
        "CID" = C.computer_id,
        "gameState" = "Active",
        "dbLink" = "",
        "byondVersion" = "[C.byond_version].[C.byond_build]",
        "mobType" = "[player.type]",
        "relatedByCid" = C.related_accounts_cid,
        "relatedByIp" = C.related_accounts_ip,
        "firstSeen" = "Unknown",
        "accountRegistered" = "Unknown",
        "muteStates" = list(
            "ic" = (C.prefs.muted & MUTE_IC),
            "ooc" = (C.prefs.muted & MUTE_OOC),
            "pray" = (C.prefs.muted & MUTE_PRAY),
            "adminhelp" = (C.prefs.muted & MUTE_ADMINHELP),
            "deadchat" = (C.prefs.muted & MUTE_DEADCHAT),
            "webreq" = FALSE
        )
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
		// Punish Section
		if("kick")
			var/reason = params["reason"] || "No reason provided"
			del(M.client)
			message_admins("[key_name_admin(usr)] kicked [key_name_admin(M)] from the game. Reason: [reason]")
			return
		if("ban")
			//usr.client.cmd_admin_ban(M)
			return
		if("prison")
			//usr.client.cmd_admin_prison(M)
			return
		if("smite")
			usr.client.smite(M)
			return

		// Message Section
		if("pm")
			usr.client.cmd_admin_pm(M.ckey, params["message"])
			return
		if("sm")
			usr.client.cmd_admin_subtle_message(M)
			return
		if("narrate")
			//usr.client.cmd_admin_narrate(M)
			return
		if("playsoundto")
			var/sound = params["sound"]
			if(sound)
				SEND_SOUND(M, sound(sound))
			return

		// Movement Section
		if("jumpto")
			usr.client.jumptomob(M)
			return
		if("get")
			usr.client.Getmob(M)
			return
		if("send")
			//usr.client.cmd_admin_send(M)
			return
		if("lobby")
			if(!isobserver(M))
				M.Move(get_turf(locate("landmark*Lobby")))
			return
		if("flw")
			//usr.client.cmd_admin_follow(M)
			return

		// Info Section
		if("vv")
			usr.client.debug_variables(M)
			return
		if("tp")
			//usr.client.show_traitor_panel(M)
			return
		if("skills")
			//usr.client.cmd_view_skills(M)
			return
		if("logs")
			//usr.client.show_player_logs(M)
			return
		if("notes")
			//usr.client.browse_messages(target_ckey = M.ckey)
			return

		// Transformation Section
		if("makeghost")
			M.ghostize(can_reenter_corpse = TRUE)
			return
		if("makehuman")
			//usr.client.cmd_admin_humanize(M)
			return
		if("makemonkey")
			//usr.client.cmd_admin_monkeyize(M)
			return
		if("makeborg")
			usr.client.cmd_admin_robotize(M)
			return
		if("makeai")
			//usr.client.cmd_admin_aiize(M)
			return

		// Misc Section
		if("language")
			// Implement language panel logic
			return
		if("forcesay")
			var/message = params["message"]
			if(message)
				M.say(message, forced = TRUE)
			return
		if("applyquirks")
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				//H.client?.prefs?.apply_character_preferences_to(H)
			return
		if("thunderdome1")
			//usr.client.cmd_admin_thunderdome(M, 1)
			return
		if("thunderdome2")
			//usr.client.cmd_admin_thunderdome(M, 2)
			return
		if("commend")
			//usr.client.cmd_admin_commend(M)
			return
		if("playtime")
			//usr.client.cmd_view_playtime(M)
			return
		if("thunderdomeadmin")
			//usr.client.cmd_admin_thunderdome(M, "admin")
			return
		if("thunderdomeobserver")
			//usr.client.cmd_admin_thunderdome(M, "observer")
			return

		// Mute Controls
		if("toggleMute")
			var/muteType = params["type"]
			switch(muteType)
				if("ic")
					if(M.client.prefs.muted & MUTE_IC)
						M.client.prefs.muted &= ~MUTE_IC
					else
						M.client.prefs.muted |= MUTE_IC
				if("ooc")
					if(M.client.prefs.muted & MUTE_OOC)
						M.client.prefs.muted &= ~MUTE_OOC
					else
						M.client.prefs.muted |= MUTE_OOC
				if("pray")
					if(M.client.prefs.muted & MUTE_PRAY)
						M.client.prefs.muted &= ~MUTE_PRAY
					else
						M.client.prefs.muted |= MUTE_PRAY
				if("adminhelp")
					if(M.client.prefs.muted & MUTE_ADMINHELP)
						M.client.prefs.muted &= ~MUTE_ADMINHELP
					else
						M.client.prefs.muted |= MUTE_ADMINHELP
				if("deadchat")
					if(M.client.prefs.muted & MUTE_DEADCHAT)
						M.client.prefs.muted &= ~MUTE_DEADCHAT
					else
						M.client.prefs.muted |= MUTE_DEADCHAT
				if("webreq")
					// Implement webreq mute logic if available
					return
			message_admins("[key_name_admin(usr)] has [(M.client.prefs.muted & text2num(muteType)) ? "muted" : "unmuted"] [key_name_admin(M)] from [muteType]")
			return

		if("toggleAllMutes")
			if(M.client.prefs.muted)
				M.client.prefs.muted = 0
			else
				M.client.prefs.muted = MUTE_IC|MUTE_OOC|MUTE_PRAY|MUTE_ADMINHELP|MUTE_DEADCHAT
			message_admins("[key_name_admin(usr)] has [(M.client.prefs.muted) ? "muted" : "unmuted"] [key_name_admin(M)] from everything")
			return


		// Mute Controls
		if("toggleMute")
			var/type = params["type"]
			// Add mute toggle logic here based on type
			switch(type)
				if("ic")

					return

				if("ooc")

					return

				if("pray")

					return

				if("adminhelp")

					return

				if("webreq")

					return

				if("deadchat")

					return
			return
		if("toggleAllMutes")
			// Add toggle all mutes logic here
			return

/datum/vuap_personal/ui_state(mob/user)
	return GLOB.admin_state

/client/proc/vuap_open(var/selectedCkey = null)
	if (!check_rights(NONE))
		message_admins("[key_name(src)] attempted to use VUAP without sufficient rights.")
		return
	var/datum/vuap_personal/tgui = new(usr)
	tgui.ui_interact(usr)


