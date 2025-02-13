/obj/effect/unholy_spawn
	name = "unholy"
	icon = 'monkestation/icons/obj/effects/96x96.dmi'
	icon_state = "beamin"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = 0

/obj/effect/unholy_spawn/Initialize()
	playsound(src,'monkestation/sound/misc/adminspawn1.ogg',50,1)
	QDEL_IN(src, 20)
	. = ..()
	return INITIALIZE_HINT_NORMAL
