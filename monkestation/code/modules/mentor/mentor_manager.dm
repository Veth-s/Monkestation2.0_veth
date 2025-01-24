///Requests from Mentorhelps
#define REQUEST_MENTORHELP "request_mentorhelp"

/// Verb for opening the requests manager panel
/client/proc/mentor_requests()
	set name = "Mentor Manager"
	set desc = "Open the mentor manager panel to view all requests during this round"
	set category = "Mentor"

	SSblackbox.record_feedback("tally", "mentor_verb", 1, "Mentor Manager")
	GLOB.mentor_requests.ui_interact(usr)

GLOBAL_DATUM_INIT(mentor_requests, /datum/request_manager/mentor, new)

/datum/request
	var/identifier
	var/request_type
	var/client/request_owner
	var/creation_time
	var/claimed_by_ckey
	var/list/conversation_history = list()

/datum/request/proc/add_message_to_history(sender_ckey, message_text)
	conversation_history += list(list(
		"sender" = sender_ckey,
		"message" = message_text,
		"timestamp_str" = gameTimestamp(wtime = world.time)
	))

/datum/request_manager/mentor
	var/list/mentor_requests = list()
	var/datum/request/current_request = null
	var/list/answered_requests = list()

/datum/request_manager/mentor/proc/create_request(client/requesting_client, request_type, message_text, additional_info)
	if(!requesting_client || !message_text)
		return

	var/datum/request/new_request = new()
	new_request.identifier = "[world.time]-[requesting_client.ckey]"
	new_request.request_type = request_type
	new_request.request_owner = requesting_client
	new_request.owner_ckey = requesting_client.ckey
	new_request.owner_name = requesting_client.mob?.name || requesting_client.ckey
	new_request.message = message_text  // Now matches the var name in /datum/request
	new_request.additional_information = additional_info
	new_request.creation_time = world.time

	if(!mentor_requests[requesting_client.ckey])
		mentor_requests[requesting_client.ckey] = list()
	mentor_requests[requesting_client.ckey] += new_request

	return new_request

/datum/request_manager/mentor/proc/mentorhelp(client/requester, message)
	var/sanitized_message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	create_request(requester, REQUEST_MENTORHELP, sanitized_message)

/datum/request_manager/mentor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestManagerMonke2")
		ui.open()

/datum/request_manager/mentor/ui_state(mob/user)
	return GLOB.admin_state

/datum/request_manager/mentor/ui_static_data(mob/user)
	var/list/data = list()
	data["current_user"] = user.ckey
	return data

/datum/request_manager/mentor/ui_data(mob/user)
	var/list/data = list(
		"requests" = list(),
		"current_user" = user.ckey
	)

	for(var/ckey in mentor_requests)
		for(var/datum/request/current_request as anything in mentor_requests[ckey])
			if(current_request.request_type != REQUEST_MENTORHELP)
				continue

			var/list/request_data = list(
				"id" = current_request.identifier,
				"req_type" = current_request.request_type,
				"owner" = current_request.request_owner ? "[REF(current_request.request_owner)]" : null,
				"owner_ckey" = current_request.owner_ckey,
				"owner_name" = current_request.owner_name,
				"message" = current_request.message,
				"additional_info" = current_request.additional_information,
				"timestamp" = current_request.creation_time,
				"timestamp_str" = gameTimestamp(wtime = current_request.creation_time),
				"claimed_by" = current_request.claimed_by_ckey,
				"answer_status" = (current_request.identifier in answered_requests) ? "ANSWERED" : "NOT ANSWERED"
			)
			data["requests"] += list(request_data)

	return data

/datum/request_manager/mentor/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/client/mentor_client = usr.client
	var/datum/request/target_request = locate(params["id"])

	if(!target_request)
		return

	switch(action)
		if("reply")
			if(!mentor_client)
				return
			if(params["mark_answered"])
				answered_requests |= target_request.identifier
			mentor_client.cmd_mentor_pm(target_request.owner_ckey, params["message"])
			target_request.add_message_to_history(mentor_client.ckey, params["message"])
			return TRUE

		if("follow")
			if(!target_request.request_owner || !target_request.request_owner.mob)
				return
			mentor_client.mentor_follow(target_request.request_owner.mob)
			return TRUE

		if("claim")
			if(!target_request.claimed_by_ckey)
				target_request.claimed_by_ckey = mentor_client.ckey
				to_chat(mentor_client, span_notice("You have claimed the request from [target_request.owner_ckey]."))
				return TRUE

		if("unclaim")
			if(target_request.claimed_by_ckey == mentor_client.ckey)
				target_request.claimed_by_ckey = null
				to_chat(mentor_client, span_notice("You have unclaimed the request from [target_request.owner_ckey]."))
				return TRUE

		if("view_conversation")
			current_request = target_request
			var/datum/tgui/window = new(usr, src, "RequestConversation")
			window.set_autoupdate(TRUE)
			window.open()
			return TRUE

#undef REQUEST_MENTORHELP
