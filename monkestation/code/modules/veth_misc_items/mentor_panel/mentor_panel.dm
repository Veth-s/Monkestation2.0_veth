// Datum to represent a single mentor ticket
/datum/mentor_ticket
	var/id
	var/ckey
	var/message
	var/status = MHELP_STATUS_OPEN
	var/opened_time
	var/list/responses = list()
	var/assigned_mentor

	// Status constants
	#define MHELP_STATUS_OPEN "open"
	#define MHELP_STATUS_CLOSED "closed"
	#define MHELP_STATUS_RESOLVED "resolved"

/datum/mentor_ticket/New(ticket_id, creator_ckey, initial_msg)
	id = ticket_id
	ckey = creator_ckey
	message = initial_msg
	opened_time = world.time

/datum/mentor_ticket/proc/add_response(mentor_ckey, response_text)
	responses += list(list(
		"mentor" = mentor_ckey,
		"message" = response_text,
		"time" = world.time
	))

/datum/mentor_ticket/proc/close(closer_ckey, reason)
	status = MHELP_STATUS_CLOSED
	add_response(closer_ckey, "Ticket closed: [reason]")

// Mentor ticket manager singleton
GLOBAL_DATUM_INIT(mentor_tickets, /datum/mentor_ticket_manager, new)

/datum/mentor_ticket_manager
	var/list/tickets = list()
	var/next_ticket_id = 1

/datum/mentor_ticket_manager/proc/create_ticket(ckey, message)
	var/datum/mentor_ticket/ticket = new(next_ticket_id++, ckey, message)
	tickets += ticket
	return ticket

/datum/mentor_ticket_manager/proc/get_ticket(id)
	for(var/datum/mentor_ticket/T in tickets)
		if(T.id == id)
			return T
	return null

/datum/mentor_ticket_manager/proc/get_active_tickets()
	. = list()
	for(var/datum/mentor_ticket/T in tickets)
		if(T.status == MHELP_STATUS_OPEN)
			. += T

// TGUI Backend
/datum/mentor_ticket_manager/ui_state(mob/user)
	return GLOB.mentor_state

/datum/mentor_ticket_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MentorPanel")
		ui.open()

/datum/mentor_ticket_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/tickets_data = list()

	for(var/datum/mentor_ticket/T in tickets)
		tickets_data += list(list(
			"id" = T.id,
			"ckey" = T.ckey,
			"message" = T.message,
			"status" = T.status,
			"time" = T.opened_time,
			"responses" = T.responses,
			"assigned_mentor" = T.assigned_mentor
		))

	data["tickets"] = tickets_data
	return data

/datum/mentor_ticket_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/mentor_ticket/ticket = get_ticket(params["ticket_id"])

	switch(action)
		if("respond")
			if(!ticket)
				return
			var/response = params["response"]
			ticket.add_response(usr.ckey, response)
			return TRUE

		if("close")
			if(!ticket)
				return
			var/reason = params["reason"]
			ticket.close(usr.ckey, reason)
			return TRUE

		if("assign")
			if(!ticket)
				return
			ticket.assigned_mentor = usr.ckey
			return TRUE
