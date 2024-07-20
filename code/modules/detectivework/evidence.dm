//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	inhand_icon_state = ""
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack(obj/item/I, mob/user,proximity)
	. = ..()
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return TRUE

/obj/item/evidencebag/handle_atom_del(atom/A)
	cut_overlays()
	w_class = initial(w_class)
	icon_state = initial(icon_state)
	desc = initial(desc)

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored == TRUE)
		return

	if(istype(I, /obj/item/evidencebag))
		to_chat(user, span_notice("I find putting an evidence bag in another evidence bag to be slightly absurd."))
		return TRUE //now this is podracing

	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, span_notice("[I] won't fit in [src]."))
		return

	if(contents.len)
		to_chat(user, span_notice("[src] already has something inside it."))
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(SEND_SIGNAL(I.loc, COMSIG_CONTAINS_STORAGE))	//in a container.
			SEND_SIGNAL(I.loc, COMSIG_TRY_STORAGE_TAKE, I, src, FALSE)
		if(!user.dropItemToGround(I))
			return

	user.visible_message("[user] puts [I] into [src].", span_notice("I put [I] inside [src]."),\
	span_italic("I hear a rustle as someone puts something into a plastic bag."))

	icon_state = "evidence"

	var/mutable_appearance/in_evidence = new(I)
	in_evidence.plane = FLOAT_PLANE
	in_evidence.layer = FLOAT_LAYER
	in_evidence.pixel_x = 0
	in_evidence.pixel_y = 0
	add_overlay(in_evidence)
	add_overlay("evidence")	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.forceMove(src)
	w_class = I.w_class
	return TRUE

/obj/item/evidencebag/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("[user] takes [I] out of [src].", span_notice("I take [I] out of [src]."),\
		span_italic("I hear someone rustle around in a plastic bag, and remove something."))
		cut_overlays()	//remove the overlays
		user.put_in_hands(I)
		w_class = WEIGHT_CLASS_TINY
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"
	return

/obj/item/storage/box/evidence
	name = "evidence bag box"
	desc = "A box claiming to contain evidence bags."

/obj/item/storage/box/evidence/New()
	new /obj/item/evidencebag(src)
	new /obj/item/evidencebag(src)
	new /obj/item/evidencebag(src)
	new /obj/item/evidencebag(src)
	new /obj/item/evidencebag(src)
	new /obj/item/evidencebag(src)
	..()
	return
