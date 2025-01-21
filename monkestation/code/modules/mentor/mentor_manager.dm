///Requests from Mentorhelps
#define REQUEST_MENTORHELP "request_mentorhelp"

/// Verb for opening the requests manager panel
/client/proc/mentor_requests()
	set name = "Mentor Manager"
	set desc = "Open the mentor manager panel to view all requests during this round"
	set category = "Mentor"

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Mentor Manager") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	GLOB.mentor_requests.ui_interact(usr)


GLOBAL_DATUM_INIT(mentor_requests, /datum/request_manager/mentor, new)

/datum/request_manager/mentor/ui_state(mob/user)
	return GLOB.always_state

/datum/request_manager/mentor/pray(client/C, message, is_chaplain)
	return

/datum/request_manager/mentor/message_centcom(client/C, message)
	return

/datum/request_manager/mentor/message_syndicate(client/C, message)
	return

/datum/request_manager/mentor/nuke_request(client/C, message)
	return

/datum/request_manager/mentor/fax_request(client/requester, message, additional_info)
	return

/datum/request_manager/mentor/music_request(client/requester, message)
	return

/datum/request_manager/mentor/proc/mentorhelp(client/requester, message)
	var/sanitizied_message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	request_for_client(requester, REQUEST_MENTORHELP, sanitizied_message)

/datum/request_manager/mentor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "RequestManagerMonke2")
		ui.open()

/datum/request_manager/mentor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/client/mentor_client = usr.client
	if(!mentor_client || !mentor_client.is_mentor())
		to_chat(mentor_client, "You are not allowed to be using this mentor-only proc. Please report it.", confidential = TRUE)
		return

	var/id = params["id"] != null ? num2text(params["id"]) : null
	if (!id)
		to_chat(mentor_client, "Failed to find a request ID in your action, please report this.", confidential = TRUE)
		CRASH("Received an action without a request ID, this shouldn't happen!")

	var/datum/request/request = !id ? null : requests_by_id[id]
	if(isnull(request))
		return

	switch(action)
		if ("reply")
			// Check if ticket is claimed by someone else
			if(request.claimed_by && request.claimed_by != mentor_client.ckey)
				to_chat(mentor_client, "This ticket is claimed by another mentor.", confidential = TRUE)
				return
			var/datum/request/request = locate(params["id"])
			if(!request)
				return
			if(params["mark_answered"])
				var/list/data = list()
				for (var/ckey in requests)
					for (var/datum/request/R as anything in requests[ckey])
						if(R.id == params["id"])
							data["answer_status"] = "ANSWERED"
							break

				// Update the UI to reflect the change
				ui.update_static_data(usr)
			var/mob/M = request.owner?.mob
			mentor_client.cmd_mentor_pm(M)
			return TRUE
		if ("follow")
			var/mob/M = request.owner?.mob
			mentor_client.mentor_follow(M)
			return TRUE
		if ("claim")
			if(!request.claimed_by)
				request.claimed_by = mentor_client.ckey
				message_mentors("[key_name_admin(mentor_client)] has claimed [key_name_admin(request.owner)]'s mentorhelp.")
			return TRUE
		if ("unclaim")
			if(request.claimed_by == mentor_client.ckey)
				request.claimed_by = null
				message_mentors("[key_name_admin(mentor_client)] has unclaimed [key_name_admin(request.owner)]'s mentorhelp.")
			return TRUE
		if("view_conversation")
			var/datum/request/request = locate(params["id"])
			if(!request)
				return
			ui.close()  // Close the main window
			var/datum/tgui/conversation_window = new(usr, src, "RequestConversation")
			conversation_window.set_autoupdate(TRUE)
			conversation_window.open()
			active_request = request  // Store the active request for the conversation window
			return TRUE

	return ..()
/datum/request_manager/mentor/ui_data_conversation(mob/user)
	if(!active_request)
		return list()

	return list(
		"messages" = active_request.conversation_history,
		"request_id" = active_request.id,
		"owner_ckey" = active_request.owner_ckey
	)

/datum/request_manager/mentor/tgui_interact_conversation(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestConversation")
		ui.open()
/* Broken shit:
reply button doesn't work when claimed
view conversation aint work
answered/notanswered dont work just yet - but this will be fix..
*/
/datum/request_manager/mentor/ui_data(mob/user)
	. = list(
		"requests" = list(),
	)
	for (var/ckey in requests)
		for (var/datum/request/request as anything in requests[ckey])
			if(request.req_type != REQUEST_MENTORHELP)
				continue
			var/list/data = list(
				"id" = request.id,
				"req_type" = request.req_type,
				"owner" = request.owner ? "[REF(request.owner)]" : null,
				"owner_ckey" = request.owner_ckey,
				"owner_name" = request.owner_name,
				"message" = request.message,
				"additional_info" = request.additional_information,
				"timestamp" = request.timestamp,
				"timestamp_str" = gameTimestamp(wtime = request.timestamp),
				"claimed_by" = request.claimed_by,
				"answer_status" = "NOT ANSWERED"
			)
			if(request.id in answered_requests)  // You'll need to maintain this list
				data["answer_status"] = "ANSWERED"
			.["requests"] += list(data)

/datum/request
	var/claimed_by = null
/datum/request_manager/mentor
	var/list/answered_requests = list()

#undef REQUEST_MENTORHELP
