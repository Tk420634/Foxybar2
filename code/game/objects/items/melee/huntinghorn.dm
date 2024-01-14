#define HH_WIELD_TIME (2 SECONDS)

/obj/item/huntinghorn
	name = "hunting horn"
	icon_state = "louisville"
	wielded_icon = "louisville2"
	icon = 'icons/fallout/objects/melee/twohanded.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/melee2h_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/melee2h_righthand.dmi'
	mob_overlay_icon = 'icons/fallout/onmob/backslot_weapon.dmi'

	force = 20
	throwforce = 20
	force_unwielded = 20
	force_wielded = 40
	sharpness = SHARP_NONE
	weapon_special_component = /datum/component/weapon_special/single_turf

	var/readytoplay = TRUE
	var/list/notes = list()
	var/currentnote = 1
	var/list/datum/huntinghornsong/songlist = list(/datum/huntinghornsong,)
	var/list/datum/status_effect/music/currenteffects = list()
	var/datum/song/handheld/intrument
	var/allowed_instrument_ids = "guitar"

/obj/item/huntinghorn/Initialize()
	..()
	intrument = new(src, allowed_instrument_ids)
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/wield_horn)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/unwield_horn)

/obj/item/huntinghorn/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=20, force_wielded=40)

/obj/item/huntinghorn/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_TWOHANDED_WIELD)
	UnregisterSignal(src, COMSIG_TWOHANDED_UNWIELD)

/obj/item/huntinghorn/attack_self(mob/user)
	if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE))
		set_note(user, ++currentnote)
		return

	if(!isliving(user) || user.stat || user.restrained())
		return
	//user.set_machine(instrument)
	intrument.ui_interact(user)

/obj/item/huntinghorn/proc/set_note(mob/user, to_set)
	currentnote = to_set
	if(currentnote > 3)
		currentnote = 1
	switch(currentnote)
		if(1)
			to_chat(user, span_info("You prepare a low note."))
			return
		if(2)
			to_chat(user, span_info("You prepare a middle note."))
			return
		if(3)
			to_chat(user, span_info("You prepare a high note."))
			return

	
/obj/item/huntinghorn/proc/wield_horn(mob/user)
	SIGNAL_HANDLER

	spawn(HH_WIELD_TIME)
		if((user.get_active_held_item() == src) && wielded)
			set_ready_to_play(user, TRUE)

/obj/item/huntinghorn/proc/unwield_horn(mob/user)
	SIGNAL_HANDLER

	set_ready_to_play(user, FALSE)

/obj/item/huntinghorn/proc/set_ready_to_play(mob/user, set_to)
	if(readytoplay == set_to)
		return
	readytoplay = set_to
	if(readytoplay)
		to_chat(user, span_info("You're ready to perform!"))
	else
		to_chat(user, span_info("You relax, finished with your performance for now."))
	currenteffects.Cut()
	notes.Cut()

/obj/item/huntinghorn/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!readytoplay || !CheckAttackCooldown(user, target))
		return
	notes.Add(currentnote)
	if(length(notes) > 3)
		notes.Cut(1,length(notes)-2)
	for(var/datum/huntinghornsong/song in songlist)
		if(song.check_notes(notes))
			add_song_effect(user, song)

/obj/item/huntinghorn/proc/add_song_effect(mob/user, datum/huntinghornsong/song)
	var/datum/status_effect/music/effect = song.effect
	if(currenteffects.Find(effect))
		return
	currenteffects += effect
	to_chat(user, span_info("You've prepared the [capitalize(song.name)]!"))

/datum/huntinghornsong
	var/name = "indescribable song"
	var/list/required_notes = list(1, 1, 1)
	var/datum/status_effect/music/effect = /datum/status_effect/music

/datum/huntinghornsong/proc/check_notes(list/notes)
	if(notes ~= required_notes)
		return TRUE
	return FALSE
