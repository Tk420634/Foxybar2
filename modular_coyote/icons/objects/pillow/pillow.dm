//butts
//Pillow and pillow related items
/obj/item/pillow
	name = "pillow"
	desc = "A soft and fluffy pillow. You can smack someone with this!"
	icon = 'modular_coyote/icons/objects/pillow/bed.dmi'
	icon_state = "pillow_1_t"
	lefthand_file = 'modular_coyote/icons/objects/pillow/pillow_lefthand.dmi'
	righthand_file = 'modular_coyote/icons/objects/pillow/pillow_righthand.dmi'
	force = 10
	w_class = WEIGHT_CLASS_NORMAL
	damtype = STAMINA
	pokesound = 'sound/items/pillow_hit.ogg'
	hitsound = 'sound/items/pillow_hit.ogg'
	///pillow tag is attached to it
	var/obj/item/clothing/neck/pillow_tag/pillow_trophy
	///for selecting the various sprite variation, defaults to the blank white pillow
	var/variation = 1

/obj/item/pillow/Initialize(mapload)
	. = ..()
	pillow_trophy = new(src)

/obj/item/pillow/Destroy(force)
	. = ..()
	QDEL_NULL(pillow_trophy)

/obj/item/pillow/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/clothing/neck/pillow_tag))
		if(!pillow_trophy)
			user.transferItemToLoc(W, src)
			pillow_trophy = W
			to_chat(user, span_green("You reattach the tag to the pillow! :)"))
			update_icon()
			return
		else
			to_chat(user, span_notice("There's already a tag there, and federal law prohibits any number of pillow tags that isn't exactly one!"))
			return
	return ..()

/obj/item/pillow/examine(mob/user)
	. = ..()
	if(pillow_trophy)
		. += span_notice("There's a tag attached to the pillow sporting a bunch of scary text about federal pillow laws about tags and how you'll totally go to jail if you remove it.")
		if(pillow_trophy.ownermessage)
			var/uwrote = "written"
			if(pillow_trophy.ownerckey == user.ckey)
				uwrote = "you wrote"
			. += span_notice("Under all that legal stuff, you see something [uwrote]: [pillow_trophy.ownermessage].")
		. += span_notice("Alt-Click the pillow to rip that sucker off!")
		if(pillow_trophy.ownerckey == user.ckey)
			. += span_notice("Ctrl-Shift-Click the pillow to customize the tag!")
		else
			. += span_notice("Ctrl-Shift-Click the pillow to customize the tag and claim the pillow as your own!")
	else
		. += span_alert("Someone tore the tag off this pillow! Don't let the Feds see! They'll be very upset!")
		. += span_notice("Quick, find it and stick it back on!")

/obj/item/pillow/CtrlShiftClick(mob/user)
	. = ..()
	if(!pillow_trophy)
		to_chat(user, span_alert("There's no tag! Oh no!"))
		return
	pillow_trophy.ownify(user, src)

/obj/item/pillow/AltClick(mob/user)
	. = ..()
	if(!pillow_trophy)
		to_chat(user, span_alert("There's no tag! Oh no!"))
		return
	to_chat(user, span_notice("You start ripping off the tag. This is illegal, you know!"))
	if(!do_after(user, 2 SECONDS, TRUE, src, TRUE, null, null, null, TRUE, TRUE, TRUE, TRUE, TRUE))
		to_chat(user, span_green("You leave the tag alone."))
		return
	to_chat(user, span_danger("You rip the tag off the pillow! You've done it now, the pillow tag feds will be furious if they find out!"))
	ADD_TRAIT(user, TRAIT_PILLOW_CRIMINAL, src)
	user.put_in_hands(pillow_trophy)
	pillow_trophy = null
	playsound(user,'sound/items/poster_ripped.ogg', 50)
	update_icon()
	return

/obj/item/pillow/update_icon_state()
	. = ..()
	if(!pillow_trophy)
		icon_state = "pillow_[variation]"
		inhand_icon_state = "pillow_no_t"
	else
		icon_state = "pillow_[variation]_t"
		inhand_icon_state = "pillow_t"


/obj/item/pillow/random

/obj/item/pillow/random/Initialize(mapload)
	. = ..()
	variation = rand(1, 4)
	icon_state = "pillow_[variation]_t"

// /obj/item/clothing/suit/pillow_suit
// 	name = "pillow suit"
// 	desc = "Part man, part pillow. All CARNAGE!"
// 	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
// 	cold_protection = CHEST|GROIN|ARMS|LEGS //a pillow suit must be hella warm
// 	allowed = list(/obj/item/pillow) //moar pillow carnage
// 	icon = 'icons/obj/bed.dmi'
// 	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
// 	icon_state = "pillow_suit"
// 	armor_type = /datum/armor/suit_pillow_suit
// 	var/obj/item/pillow/unstoppably_plushed

// /datum/armor/suit_pillow_suit
// 	melee = 5
// 	acid = 75

// /obj/item/clothing/suit/pillow_suit/Initialize(mapload)
// 	. = ..()
// 	unstoppably_plushed = new(src)
// 	AddComponent(/datum/component/bumpattack, proxy_weapon = unstoppably_plushed, valid_inventory_slot = ITEM_SLOT_OCLOTHING)

// /obj/item/clothing/suit/pillow_suit/Destroy()
// 	. = ..()
// 	QDEL_NULL(unstoppably_plushed)

// /obj/item/clothing/head/pillow_hood
// 	name = "pillow hood"
// 	desc = "The final piece of the pillow juggernaut"
// 	body_parts_covered = HEAD
// 	icon = 'icons/obj/bed.dmi'
// 	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
// 	icon_state = "pillowcase_hat"
// 	body_parts_covered = HEAD
// 	flags_inv = HIDEHAIR|HIDEEARS
// 	armor_type = /datum/armor/head_pillow_hood

// /datum/armor/head_pillow_hood
// 	melee = 5
// 	acid = 75

/obj/item/clothing/neck/pillow_tag
	name = "pillow tag"
	desc = "A tag required by federal law to be on every pillow sold after the '90s. If removed, please consult a lawyer."
	icon = 'modular_coyote/icons/objects/pillow/bed.dmi'
	icon_state = "pillow_tag"
	mob_overlay_icon = 'icons/mob/clothing/neck.dmi'
	body_parts_covered = NECK
	var/ownermessage
	var/ownerckey
	var/originalownerckey

/obj/item/clothing/neck/pillow_tag/attack_self(mob/user)
	. = ..()
	ownify(user)

/obj/item/clothing/neck/pillow_tag/proc/ownify(mob/user, obj/item/pillow/attached)
	if(!user.ckey || !user.client)
		return
	if(!originalownerckey)
		to_chat(user, span_notice("You claim the pillow[attached?"":" tag"] as your own."))
		originalownerckey = user.ckey
		ownerckey = user.ckey
	if(ownerckey && ownerckey != user.ckey)
		to_chat(user, span_alert("Rip a pillow tag off and break federal law, that's fine. Steal said tag from someone else, sure. But to vandalize it as well? Hardcore~"))
		to_chat(user, span_notice("You claim the pillow[attached?"":" tag"] as your own."))
		var/mob/oldowner = ckey2mob(ownerckey)
		if(oldowner)
			to_chat(oldowner, span_message("You feel a vague feeling of loss."))
		ownerckey = user.ckey
	var/def_or_show = alert(
		user,
		"Deface the tag, or show it off?",
		"Crime or Brag?",
		"Deface",
		"Show",
		"Cancel!",
	)
	switch(def_or_show)
		if("Deface")
			var/defolt = ownermessage ? ownermessage : "Property of [user.name][prob(25)?"":" (if found, please return to [user.name])"]"
			var/newmsg = input(
				user,
				"What do you want to write?",
				"Vandalize illegal materials",
				defolt,
				) as null|text
			if(!newmsg)
				to_chat(user, span_notice("Never mind!!"))
				return
			to_chat(user, span_green("You scratch out '[ownermessage]' and write in '[newmsg]'."))
			ownermessage = newmsg
		if("Show")
			if(attached)
				user.visible_message(
					span_notice("[user] holds up [attached], and shows off how its tag says:") +" [ownermessage]",
					span_notice("You hold up [attached], showing off how its tag says:") +" [ownermessage]",
				)
			else
				user.visible_message(
					span_notice("[user] holds up a severed pillow tag and shows off what's written:") +" [ownermessage]" + "[prob(20)?" \nDon't tell the feds!":""]",
					span_notice("You hold up a severed pillow tag and shows off what's written:") +" [ownermessage]",
				)
		else

/obj/item/pillow/clown
	name = "clown pillow"
	desc = "Daww look at that little clown!"
	icon_state = "pillow_5_t"
	variation = 5

/obj/item/pillow/mime
	name = "mime pillow"
	desc = "Daww look at that little mime!"
	icon_state = "pillow_6_t"
	variation = 6

