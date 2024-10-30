/client/proc/CheckPlayers()
	set name = "Check Players"
	set category = "Admin.Game"
	if(!check_rights(NONE)) // Rights check for admin access
		message_admins("[key_name(usr)] attempted to use CheckPlayers without sufficient rights.")
		return
	var/datum/CheckPlayers/tgui = new(usr)
	tgui.ui_interact(usr)
		// Log the action
	to_chat(src, span_interface("Player statistics alert displayed."), confidential = TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Player Statistics")
	message_admins("[key_name(usr)] checked players.")

/datum/CheckPlayers/ui_data(mob/user)
	var/total_clients = GLOB.player_list.len ? GLOB.player_list.len : 0
	var/living_players = GLOB.alive_player_list.len ? GLOB.alive_player_list.len : 0
	var/dead_players = GLOB.dead_player_list.len ? GLOB.dead_player_list.len : 0
	var/ghost_players = GLOB.current_observers_list.len ? GLOB.current_observers_list.len : 0
	var/living_antags = GLOB.current_living_antags.len ? GLOB.current_living_antags.len : 0
	var/list/message = list()
	message["total_clients"] = total_clients
	message["living_players"] = living_players
	message["dead_players"] = dead_players
	message["ghost_players"] = ghost_players
	message["living_antags"] = living_antags
	// Create the TGUI window and send data to the TypeScript interface
	return message

/datum/CheckPlayers/
	var/mob/ui_user

/datum/CheckPlayers/New(mob/user)
	ui_user = user

/datum/CheckPlayers/ui_close()
	qdel(src)

/datum/CheckPlayers/ui_interact(mob/user, datum/tgui/ui)
	.=..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayerStatistics")
		ui.open()
/datum/CheckPlayers/ui_state(mob/user)
	return GLOB.admin_state

/datum/CheckPlayers/ui_act(action, list/params, datum/tgui/ui)
	.=..()
	if(.)
		return TRUE
	else
		return FALSE




