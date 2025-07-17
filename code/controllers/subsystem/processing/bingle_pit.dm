PROCESSING_SUBSYSTEM_DEF(bingle_pit)
	name = "Bingle Pit Processing"
	wait = 0.2 SECONDS
	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_HIBERNATE
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
