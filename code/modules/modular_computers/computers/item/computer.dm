// This is the base type of computer
// Other types expand it - tablets and laptops are subtypes
// consoles use "procssor" item that is held inside it.
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop"
	light_on = FALSE
	integrity_failure = 0.5
	max_integrity = 100
	armor_type = /datum/armor/item_modular_computer
	light_system = OVERLAY_LIGHT_DIRECTIONAL

	///The ID currently stored in the computer.
	var/obj/item/card/id/computer_id_slot
	///The disk in this PDA. If set, this will be inserted on Initialize.
	var/obj/item/computer_disk/inserted_disk
	///The power cell the computer uses to run on.
	var/obj/item/stock_parts/cell/internal_cell = /obj/item/stock_parts/cell
	///A pAI currently loaded into the modular computer.
	var/obj/item/pai_card/inserted_pai
	///Does the console update the crew manifest when the ID is removed?
	var/crew_manifest_update = FALSE

	///The amount of storage space the computer starts with.
	var/max_capacity = 128
	///The amount of storage space we've got filled
	var/used_capacity = 0
	///List of stored files on this drive. Use `store_file` and `remove_file` instead of modifying directly!
	var/list/datum/computer_file/stored_files = list()

	///Non-static list of programs the computer should recieve on Initialize.
	var/list/datum/computer_file/starting_programs = list()
	///Static list of default programs that come with ALL computers, here so computers don't have to repeat this.
	var/static/list/datum/computer_file/default_programs = list(
		/datum/computer_file/program/themeify,
		/datum/computer_file/program/ntnetdownload,
		/datum/computer_file/program/filemanager,
	)

	///The program currently active on the tablet.
	var/datum/computer_file/program/active_program
	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/idle_threads = list()
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 2

	///Flag of the type of device the modular computer is, deciding what types of apps it can run.
	var/hardware_flag = NONE
//	Options: PROGRAM_ALL | PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET

	///The theme, used for the main menu and file browser apps.
	var/device_theme = PDA_THEME_NTOS

	///Bool on whether the computer is currently active or not.
	var/enabled = FALSE
	///If the screen is open, only used by laptops.
	var/screen_on = TRUE

	///Looping sound for when the computer is on.
	var/datum/looping_sound/computer/soundloop
	///Whether or not this modular computer uses the looping sound
	var/looping_sound = TRUE

	///If the computer has a flashlight/LED light built-in.
	var/has_light = FALSE
	/// If the computer's flashlight/LED light has forcibly disabled for a temporary amount of time.
	COOLDOWN_DECLARE(disabled_time)
	/// How far the computer's light can reach, is not editable by players.
	var/comp_light_luminosity = 3
	/// The built-in light's color, editable by players.
	var/comp_light_color = "#FFFFFF"

	///The last recorded amount of power used.
	var/last_power_usage = 0
	///Power usage when the computer is open (screen is active) and can be interacted with.
	var/base_active_power_usage = 75
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 5

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console & Tablet)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	///If set, what the icon_state will be if the computer is unpowered.
	var/icon_state_unpowered
	///If set, what the icon_state will be if the computer is powered.
	var/icon_state_powered
	///Icon state overlay when the computer is turned on, but no program is loaded (programs override this).
	var/icon_state_menu = "menu"

	///The full name of the stored ID card's identity. These vars should probably be on the PDA.
	var/saved_identification
	///The job title of the stored ID card
	var/saved_job

	///The 'computer' itself, as an obj. Primarily used for Adjacent() and UI visibility checks, especially for computers.
	var/obj/physical
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 5

	///If hit by a Clown virus, remaining honks left until it stops.
	var/honkvirus_amount = 0
	///Whether the PDA can still use NTNet while out of NTNet's reach.
	var/long_ranged = FALSE
	/// Allow people with chunky fingers to use?
	var/allow_chunky = FALSE

	///The amount of paper currently stored in the PDA
	var/stored_paper = 10
	///The max amount of paper that can be held at once.
	var/max_paper = 30

/datum/armor/item_modular_computer
	bullet = 20
	laser = 20
	energy = 100

/obj/item/modular_computer/Initialize(mapload)
	. = ..()

	START_PROCESSING(SSobj, src)
	if(!physical)
		physical = src
	set_light_color(comp_light_color)
	set_light_range(comp_light_luminosity)
	if(looping_sound)
		soundloop = new(src, enabled)
	UpdateDisplay()
	if(has_light)
		add_item_action(/datum/action/item_action/toggle_computer_light)
	if(inserted_disk)
		inserted_disk = new inserted_disk(src)
	if(internal_cell)
		internal_cell = new internal_cell(src)

	install_default_programs()
	register_context()
	update_appearance()

/obj/item/modular_computer/proc/install_default_programs()
	SHOULD_CALL_PARENT(FALSE)
	for(var/programs in default_programs + starting_programs)
		var/datum/computer_file/program_type = new programs
		store_file(program_type)

/obj/item/modular_computer/Destroy()
	STOP_PROCESSING(SSobj, src)
	close_all_programs()
	//Some components will actually try and interact with this, so let's do it later
	QDEL_NULL(soundloop)
	QDEL_LIST(stored_files)

	if(istype(inserted_disk))
		QDEL_NULL(inserted_disk)
	if(istype(inserted_pai))
		QDEL_NULL(inserted_pai)
	if(computer_id_slot)
		QDEL_NULL(computer_id_slot)

	physical = null
	return ..()

/obj/item/modular_computer/pre_attack_secondary(atom/A, mob/living/user, params)
	if(active_program?.tap(A, user, params))
		user.do_attack_animation(A) //Emulate this animation since we kill the attack in three lines
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1) //Likewise for the tap sound
		addtimer(CALLBACK(src, PROC_REF(play_ping)), 0.5 SECONDS, TIMER_UNIQUE) //Slightly delayed ping to indicate success
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

// shameless copy of newscaster photo saving

/obj/item/modular_computer/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("\icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

/**
 * Plays a ping sound.
 *
 * Timers runtime if you try to make them call playsound. Yep.
 */
/obj/item/modular_computer/proc/play_ping()
	playsound(loc, 'sound/machines/ping.ogg', get_clamped_volume(), FALSE, -1)

/obj/item/modular_computer/get_cell()
	return internal_cell

/obj/item/modular_computer/AltClick(mob/user)
	. = ..()
	if(issilicon(user))
		return FALSE
	if(!user.can_perform_action(src))
		return FALSE

	if(RemoveID(user))
		return TRUE

	if(istype(inserted_pai)) // Remove pAI
		user.put_in_hands(inserted_pai)
		balloon_alert(user, "removed pAI")
		inserted_pai = null
		update_appearance(UPDATE_ICON)
		return TRUE

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. //guess what
/obj/item/modular_computer/GetAccess()
	if(computer_id_slot)
		return computer_id_slot.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	RETURN_TYPE(/obj/item/card/id)
	if(computer_id_slot)
		return computer_id_slot
	return ..()

/obj/item/modular_computer/get_id_examine_strings(mob/user)
	. = ..()
	if(computer_id_slot)
		. += "\The [src] is displaying [computer_id_slot]."
		. += computer_id_slot.get_id_examine_strings(user)

/obj/item/modular_computer/proc/print_text(text_to_print, paper_title = "")
	if(!stored_paper)
		return FALSE

	var/obj/item/paper/printed_paper = new /obj/item/paper(drop_location())
	printed_paper.add_raw_text(text_to_print)
	if(paper_title)
		printed_paper.name = paper_title
	printed_paper.update_appearance()
	stored_paper--
	return TRUE

/**
 * InsertID
 * Attempt to insert the ID in either card slot.
 * Args:
 * inserting_id - the ID being inserted
 * user - The person inserting the ID
 */
/obj/item/modular_computer/InsertID(obj/item/card/inserting_id, mob/user)
	//all slots taken
	if(computer_id_slot)
		return FALSE

	computer_id_slot = inserting_id
	if(user)
		if(!user.transferItemToLoc(inserting_id, src))
			return FALSE
		to_chat(user, span_notice("You insert \the [inserting_id] into the card slot."))
	else
		inserting_id.forceMove(src)

	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	update_appearance()
	update_slot_icon()
	return TRUE

/**
 * Removes the ID card from the computer, and puts it in loc's hand if it's a mob
 * Args:
 * user - The mob trying to remove the ID, if there is one
 */
/obj/item/modular_computer/RemoveID(mob/user)
	if(!computer_id_slot)
		return ..()

	if(crew_manifest_update)
		GLOB.manifest.modify(computer_id_slot.registered_name, computer_id_slot.assignment, computer_id_slot.get_trim_assignment())

	if(user && !issilicon(user) && in_range(src, user))
		user.put_in_hands(computer_id_slot)
	else
		computer_id_slot.forceMove(drop_location())

	computer_id_slot = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	balloon_alert(user, "removed ID")
	to_chat(user, span_notice("You remove the card from the card slot."))

	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	update_slot_icon()
	update_appearance()
	return TRUE

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && usr.can_perform_action(src))
		return attack_self(M)
	return ..()

/obj/item/modular_computer/attack_ai(mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(enabled)
		ui_interact(user)
	else if(isAdminGhostAI(user))
		var/response = tgui_alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", list("Yes", "No"))
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/emag_act(mob/user, obj/item/card/emag/emag_card, forced)
	if(!enabled && !forced)
		balloon_alert(user, "turn it on first!")
		return FALSE
	if(obj_flags & EMAGGED)
		balloon_alert(user, "already emagged!")
		if (emag_card)
			to_chat(user, span_notice("You swipe \the [src] with [emag_card]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it."))
		return FALSE

	. = ..()
	obj_flags |= EMAGGED
	device_theme = PDA_THEME_SYNDICATE
	balloon_alert(user, "syndieOS loaded")
	if (emag_card)
		to_chat(user, span_notice("You swipe \the [src] with [emag_card]. A console window momentarily fills the screen, with white text rapidly scrolling past."))
	return TRUE

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	var/healthpercent = round((atom_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

	if(long_ranged)
		. += "It is upgraded with an experimental long-ranged network capabilities, picking up NTNet frequencies while further away."
	. += span_notice("It has [max_capacity] GQ of storage capacity.")

	if(computer_id_slot)
		if(Adjacent(user))
			. += "It has \the [computer_id_slot] card installed in its card slot."
		else
			. += "Its identification card slot is currently occupied."
		. += span_info("Alt-click [src] to eject the identification card.")

/obj/item/modular_computer/examine_more(mob/user)
	. = ..()
	. += "Storage capacity: [used_capacity]/[max_capacity]GQ"

	for(var/datum/computer_file/app_examine as anything in stored_files)
		if(app_examine.on_examine(src, user))
			. += app_examine.on_examine(src, user)

	if(Adjacent(user))
		. += span_notice("Paper level: [stored_paper] / [max_paper].")

/obj/item/modular_computer/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		. = CONTEXTUAL_SCREENTIP_SET

	if(computer_id_slot) // ID get removed first before pAIs
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove ID"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(inserted_pai)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove pAI"
		. = CONTEXTUAL_SCREENTIP_SET

	if(inserted_disk)
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = "Remove Disk"
		. = CONTEXTUAL_SCREENTIP_SET
	return . || NONE

/obj/item/modular_computer/update_icon_state()
	if(!icon_state_powered || !icon_state_unpowered) //no valid icon, don't update.
		return ..()
	icon_state = enabled ? icon_state_powered : icon_state_unpowered
	return ..()

/obj/item/modular_computer/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return

	if(enabled)
		. += active_program ? mutable_appearance(init_icon, active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu)
	if(atom_integrity <= integrity_failure * max_integrity)
		. += mutable_appearance(init_icon, "bsod")
		. += mutable_appearance(init_icon, "broken")

/obj/item/modular_computer/Exited(atom/movable/gone, direction)
	if(internal_cell == gone)
		internal_cell = null
		if(enabled && !use_power())
			shutdown_computer()
	if(computer_id_slot == gone)
		computer_id_slot = null
		update_slot_icon()
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			human_wearer.sec_hud_set_ID()
	if(inserted_pai == gone)
		inserted_pai = null
	if(inserted_disk == gone)
		inserted_disk = null
		update_appearance(UPDATE_ICON)
	return ..()

/obj/item/modular_computer/CtrlShiftClick(mob/user)
	. = ..()
	if(.)
		return
	if(!inserted_disk)
		return
	user.put_in_hands(inserted_disk)
	inserted_disk = null
	playsound(src, 'sound/machines/card_slide.ogg', 50)

/obj/item/modular_computer/proc/turn_on(mob/user, open_ui = TRUE)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(atom_integrity <= integrity_failure * max_integrity)
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src], but it responds with an error code. It must be damaged."))
		else
			to_chat(user, span_warning("You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."))
		return FALSE

	if(use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, span_notice("You send an activation signal to \the [src], turning it on."))
		else
			to_chat(user, span_notice("You press the power button and start up \the [src]."))
		if(looping_sound)
			soundloop.start()
		enabled = TRUE
		update_appearance()
		if(open_ui)
			update_tablet_open_uis(user)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [src] does not respond."))
		return FALSE

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process(seconds_per_tick)
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return

	if(atom_integrity <= integrity_failure * max_integrity)
		shutdown_computer()
		return

	if(active_program && active_program.requires_ntnet && !get_ntnet_status())
		active_program.event_networkfailure(FALSE) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/datum/computer_file/program/idle_programs as anything in idle_threads)
		idle_programs.process_tick(seconds_per_tick)
		idle_programs.ntnet_status = get_ntnet_status()
		if(idle_programs.requires_ntnet && !idle_programs.ntnet_status)
			idle_programs.event_networkfailure(TRUE)

	if(active_program)
		active_program.process_tick(seconds_per_tick)
		active_program.ntnet_status = get_ntnet_status()

	handle_power(seconds_per_tick) // Handles all computer power interaction

/**
 * Displays notification text alongside a soundbeep when requested to by a program.
 *
 * After checking that the requesting program is allowed to send an alert, creates
 * a visible message of the requested text alongside a soundbeep. This proc adds
 * text to indicate that the message is coming from this device and the program
 * on it, so the supplied text should be the exact message and ending punctuation.
 *
 * Arguments:
 * The program calling this proc.
 * The message that the program wishes to display.
 */
/obj/item/modular_computer/proc/alert_call(datum/computer_file/program/origin, alerttext, sound = 'sound/machines/twobeep_high.ogg', vision_distance = DEFAULT_MESSAGE_RANGE)
	if(QDELETED(loc) || QDELETED(origin) || !origin.alert_able || origin.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return FALSE
	playsound(src, sound, 50, TRUE)
	loc.visible_message(span_notice("<img class='icon' src='\ref[src]'> \The [src] displays a [origin.filedesc] notification: [html_encode(alerttext)]"), vision_distance = vision_distance, push_appearance = src)

/obj/item/modular_computer/proc/ring(ringtone, list/balloon_alertees) // bring bring
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	ringtone = "*[ringtone]*"
	audible_message(ringtone)
	for(var/mob/living/alertee in balloon_alertees)
		alertee.balloon_alert(alertee, ringtone)

/obj/item/modular_computer/proc/send_sound()
	playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = device_theme
	data["PC_showbatteryicon"] = !!internal_cell

	if(internal_cell)
		switch(internal_cell.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(internal_cell.percent())]%"
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"

	switch(get_ntnet_status())
		if(NTNET_NO_SIGNAL)
			data["PC_ntneticon"] = "sig_none.gif"
		if(NTNET_LOW_SIGNAL)
			data["PC_ntneticon"] = "sig_low.gif"
		if(NTNET_GOOD_SIGNAL)
			data["PC_ntneticon"] = "sig_high.gif"
		if(NTNET_ETHERNET_SIGNAL)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(length(idle_threads))
		var/list/program_headers = list()
		for(var/datum/computer_file/program/idle_programs as anything in idle_threads)
			if(!idle_programs.ui_header)
				continue
			program_headers.Add(list(list("icon" = idle_programs.ui_header)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [CURRENT_STATION_YEAR]"
	data["PC_showexitprogram"] = !!active_program // Hides "Exit Program" button on mainscreen
	return data

/obj/item/modular_computer/proc/open_program(mob/user, datum/computer_file/program/program, open_ui = TRUE)
	if(program.computer != src)
		CRASH("tried to open program that does not belong to this computer")

	if(!program || !istype(program)) // Program not found or it's not executable program.
		to_chat(user, span_danger("\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE

	// The program is already running. Resume it.
	if(program in idle_threads)
		active_program = program
		program.alert_pending = FALSE
		idle_threads.Remove(program)
		if(open_ui)
			update_tablet_open_uis(user)
		update_appearance(UPDATE_ICON)
		return TRUE

	if(!program.is_supported_by_hardware(hardware_flag, 1, user))
		return FALSE

	if(idle_threads.len > max_idle_programs)
		to_chat(user, span_danger("\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error."))
		return FALSE

	if(program.requires_ntnet && !get_ntnet_status()) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, span_danger("\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning."))
		return FALSE

	if(!program.on_start(user))
		return FALSE

	active_program = program
	program.alert_pending = FALSE
	if(open_ui)
		update_tablet_open_uis(user)
	update_appearance(UPDATE_ICON)
	return TRUE

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status()
	// computers are connected through ethernet
	if(hardware_flag & PROGRAM_CONSOLE)
		return NTNET_ETHERNET_SIGNAL

	// NTNet is down and we are not connected via wired connection. No signal.
	if(!find_functional_ntnet_relay())
		return NTNET_NO_SIGNAL

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !istype(current_turf))
		return NTNET_NO_SIGNAL
	if(is_station_level(current_turf.z))
		if(hardware_flag & PROGRAM_LAPTOP) //laptops can connect to ethernet but they have to be on station for that
			return NTNET_ETHERNET_SIGNAL
		return NTNET_GOOD_SIGNAL
	else if(is_mining_level(current_turf.z))
		return NTNET_LOW_SIGNAL
	else if(long_ranged)
		return NTNET_LOW_SIGNAL
	return NTNET_NO_SIGNAL

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return FALSE

	return SSmodular_computers.add_log("[src]: [text]")

/obj/item/modular_computer/proc/close_all_programs()
	active_program = null
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		idle_threads.Remove(idle)

/obj/item/modular_computer/proc/shutdown_computer(loud = TRUE)
	close_all_programs()
	if(looping_sound)
		soundloop.stop()
	if(physical && loud)
		physical.visible_message(span_notice("\The [src] shuts down."))
	enabled = FALSE
	update_appearance()

///Imprints name and job into the modular computer, and calls back to necessary functions.
///Acts as a replacement to directly setting the imprints fields. All fields are optional, the proc will try to fill in missing gaps.
/obj/item/modular_computer/proc/imprint_id(name = null, job_name = null)
	saved_identification = name || computer_id_slot?.registered_name || saved_identification
	saved_job = job_name || computer_id_slot?.assignment || saved_job
	SEND_SIGNAL(src, COMSIG_MODULAR_PDA_IMPRINT_UPDATED, saved_identification, saved_job)
	UpdateDisplay()

///Resets the imprinted name and job back to null.
/obj/item/modular_computer/proc/reset_imprint()
	saved_identification = null
	saved_job = null
	SEND_SIGNAL(src, COMSIG_MODULAR_PDA_IMPRINT_RESET)
	UpdateDisplay()

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_computer_light))
		toggle_flashlight(user)
		return

	return ..()

/**
 * Toggles the computer's flashlight, if it has one.
 *
 * Called from ui_act(), does as the name implies.
 * It is separated from ui_act() to be overwritten as needed.
*/
/obj/item/modular_computer/proc/toggle_flashlight(mob/user)
	if(!has_light)
		return FALSE
	if(!COOLDOWN_FINISHED(src, disabled_time))
		balloon_alert(user, "disrupted!")
		return FALSE
	set_light_on(!light_on)
	update_appearance()
	update_item_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	return TRUE

//Disables the computer's flashlight/LED light, if it has one, for a given disrupt_duration.
/obj/item/modular_computer/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!has_light)
		return
	set_light_on(FALSE)
	update_appearance()
	update_item_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	COOLDOWN_START(src, disabled_time, disrupt_duration)
	return TRUE

/**
 * Sets the computer's light color, if it has a light.
 *
 * Called from ui_act(), this proc takes a color string and applies it.
 * It is separated from ui_act() to be overwritten as needed.
 * Arguments:
 ** color is the string that holds the color value that we should use. Proc auto-fails if this is null.
*/
/obj/item/modular_computer/proc/set_flashlight_color(color)
	if(!has_light || !color)
		return FALSE
	comp_light_color = color
	set_light_color(color)
	return TRUE

/obj/item/modular_computer/proc/UpdateDisplay()
	if(!saved_identification && !saved_job)
		name = initial(name)
		return
	name = "[saved_identification] ([saved_job])"

/obj/item/modular_computer/attackby(obj/item/attacking_item, mob/user, params)
	// Check for ID first
	if(isidcard(attacking_item) && InsertID(attacking_item, user))
		return

	// Check for cash next
	if(computer_id_slot && iscash(attacking_item))
		var/obj/item/card/id/inserted_id = computer_id_slot.GetID()
		if(inserted_id)
			inserted_id.attackby(attacking_item, user) // If we do, try and put that attacking object in
			return

	// Inserting a pAI
	if(istype(attacking_item, /obj/item/pai_card) && !inserted_pai)
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_pai = attacking_item
		balloon_alert(user, "inserted pai")
		update_appearance(UPDATE_ICON)
		return

	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(ismachinery(loc))
			return
		if(internal_cell)
			to_chat(user, span_warning("You try to connect \the [attacking_item] to \the [src], but its connectors are occupied."))
			return
		if(user && !user.transferItemToLoc(attacking_item, src))
			return
		internal_cell = attacking_item
		to_chat(user, span_notice("You plug \the [attacking_item] to \the [src]."))
		return

	if(istype(attacking_item, /obj/item/photo))
		var/obj/item/photo/attacking_photo = attacking_item
		if(store_file(new /datum/computer_file/picture(attacking_photo.picture)))
			balloon_alert(user, "photo scanned")
		else
			balloon_alert(user, "no space!")
		return

	// Check if any Applications need it
	for(var/datum/computer_file/item_holding_app as anything in stored_files)
		if(item_holding_app.application_attackby(attacking_item, user))
			return

	if(istype(attacking_item, /obj/item/paper))
		//MONKESTATION EDIT START
		// Don't allow plastic cards (including the spare ID safe code biscuits!) to be inserted
		if(istype(attacking_item, /obj/item/paper/paperslip/corporate))
			return
		//MONKESTATION EDIT END
		if(stored_paper >= max_paper)
			balloon_alert(user, "no more room!")
			return
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return FALSE
		balloon_alert(user, "inserted paper")
		qdel(attacking_item)
		stored_paper++
		return
	if(istype(attacking_item, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = attacking_item
		if(bin.total_paper <= 0)
			balloon_alert(user, "empty bin!")
			return
		var/papers_added //just to keep track
		while((bin.total_paper > 0) && (stored_paper < max_paper))
			papers_added++
			stored_paper++
			bin.remove_paper()
		if(!papers_added)
			return
		balloon_alert(user, "inserted paper")
		to_chat(user, span_notice("Added in [papers_added] new sheets. You now have [stored_paper] / [max_paper] printing paper stored."))
		bin.update_appearance()
		return

	// Insert a data disk
	if(istype(attacking_item, /obj/item/computer_disk))
		if(inserted_disk)
			user.put_in_hands(inserted_disk)
			balloon_alert(user, "disks swapped")
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_disk = attacking_item
		playsound(src, 'sound/machines/card_slide.ogg', 50)
		return

	return ..()

/obj/item/modular_computer/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src, user, 20, volume=20)
	internal_cell?.forceMove(drop_location())
	computer_id_slot?.forceMove(drop_location())
	inserted_disk?.forceMove(drop_location())
	inserted_pai?.forceMove(drop_location())
	new /obj/item/stack/sheet/iron(get_turf(loc), steel_sheet_cost)
	user.balloon_alert(user, "disassembled")
	relay_qdel()
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/modular_computer/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("\The [src] does not require repairs."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!tool.tool_start_check(user, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	to_chat(user, span_notice("You begin repairing damage to \the [src]..."))
	if(!tool.use_tool(src, user, 20, volume=50, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	atom_integrity = max_integrity
	to_chat(user, span_notice("You repair \the [src]."))
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/modular_computer/deconstruct(disassembled = TRUE)
	break_apart()
	return ..()

/obj/item/modular_computer/proc/break_apart()
	if(!(flags_1 & NODECONSTRUCT_1))
		physical.visible_message(span_notice("\The [src] breaks apart!"))
		var/turf/newloc = get_turf(src)
		new /obj/item/stack/sheet/iron(newloc, round(steel_sheet_cost / 2))
	relay_qdel()

// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()

///Returns a string of what to send at the end of messenger's messages.
/obj/item/modular_computer/proc/get_messenger_ending()
	return "Sent from my PDA"

/// Returns how relevant the current security level is:
#define ALERT_RELEVANCY_SAFE 0 /// * 0: User is not in immediate danger and not needed for some station-critical task.
#define ALERT_RELEVANCY_WARN 1 /// * 1: Danger is around, but the user is not directly needed to handle it.
#define ALERT_RELEVANCY_PERTINENT 2 /// * 2: Danger is around and the user is responsible for handling it.
/obj/item/modular_computer/proc/get_security_level_relevancy()
	switch(SSsecurity_level.get_current_level_as_number()) // all-hands-on-deck situations, everyone is responsible for combatting a threat
		if(SEC_LEVEL_DELTA, SEC_LEVEL_RED, SEC_LEVEL_EPSILON, SEC_LEVEL_GAMMA, SEC_LEVEL_LAMBDA,)
			return ALERT_RELEVANCY_PERTINENT
		if(SEC_LEVEL_AMBER) // Ongoing medical threat. Medical staff are to contribute.
			if((ACCESS_SECURITY in computer_id_slot?.access) || (ACCESS_MEDICAL in computer_id_slot?.access))
				return ALERT_RELEVANCY_PERTINENT
			else
				return ALERT_RELEVANCY_WARN
		if(SEC_LEVEL_YELLOW) // Ongoing engineering issues. Engineering staff are to contribute.
			if((ACCESS_SECURITY in computer_id_slot?.access) || (ACCESS_ENGINEERING in computer_id_slot?.access))
				return ALERT_RELEVANCY_PERTINENT
			else
				return ALERT_RELEVANCY_WARN
		if(SEC_LEVEL_BLUE) // suspected threat. security needs to be alert and possibly preparing for it, no further concerns
			if(ACCESS_SECURITY in computer_id_slot?.access)
				return ALERT_RELEVANCY_PERTINENT
			else
				return ALERT_RELEVANCY_WARN
		if(SEC_LEVEL_GREEN) // no threats, no concerns
			return ALERT_RELEVANCY_SAFE

	return 0

#undef ALERT_RELEVANCY_SAFE
#undef ALERT_RELEVANCY_WARN
#undef ALERT_RELEVANCY_PERTINENT
