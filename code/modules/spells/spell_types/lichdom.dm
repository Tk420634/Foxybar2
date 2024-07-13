/obj/effect/proc_holder/spell/targeted/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an \
	item of your choosing. So long as both your body and the item remain \
	intact and on the same plane you can revive from death, though the time \
	between reincarnations grows steadily with use, along with the weakness \
	that the new skeleton body will experience upon 'birth'. Note that \
	becoming a lich destroys all internal organs except the brain."
	school = "necromancy"
	charge_max = 10
	clothes_req = NONE
	centcom_cancast = 0
	invocation = "NECREM IMORTIUM!"
	invocation_type = "shout"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 10
	include_user = 1

	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "skeleton"

/obj/effect/proc_holder/spell/targeted/lichdom/cast(list/targets,mob/user = usr)
	for(var/mob/M in targets)
		var/list/hand_items = list()
		if(iscarbon(M))
			hand_items = list(M.get_active_held_item(),M.get_inactive_held_item())
		if(!hand_items.len)
			to_chat(M, span_caution("I must hold an item you wish to make your phylactery..."))
			return

		var/obj/item/marked_item

		for(var/obj/item/item in hand_items)
			// I ensouled the nuke disk once. But it's probably a really
			// mean tactic, so probably should discourage it.
			if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP) || SEND_SIGNAL(item, COMSIG_ITEM_IMBUE_SOUL, user))
				continue
			marked_item = item
			to_chat(M, span_warning("I begin to focus your very being into [item]..."))
			break

		if(!marked_item)
			to_chat(M, span_warning("None of the items you hold are suitable for emplacement of your fragile soul."))
			return

		playsound(user, 'sound/effects/pope_entry.ogg', 100)

		if(!do_after(M, 50, needhand=FALSE, target=marked_item))
			to_chat(M, span_warning("My soul snaps back to your body as you stop ensouling [marked_item]!"))
			return

		marked_item.name = "ensouled [marked_item.name]"
		marked_item.desc += "\nA terrible aura surrounds this item, its very existence is offensive to life itself..."
		marked_item.add_atom_colour("#003300", ADMIN_COLOUR_PRIORITY)

		new /obj/item/phylactery(marked_item, M.mind)

		to_chat(M, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!"))
		M.set_species(/datum/species/skeleton/space)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.dropItemToGround(H.w_uniform)
			H.dropItemToGround(H.wear_suit)
			H.dropItemToGround(H.head)
			H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(H), SLOT_WEAR_SUIT)
			H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(H), SLOT_HEAD)
			H.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(H), SLOT_W_UNIFORM)

		// you only get one phylactery.
		M.mind.RemoveSpell(src)


/obj/item/phylactery
	name = "phylactery"
	desc = "Stores souls. Revives liches. Also repels mosquitos."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bluespace"
	color = "#003300"
	light_color = "#003300"
	light_system = MOVABLE_LIGHT
	light_range = 3
	var/resurrections = 0
	var/datum/mind/mind
	var/respawn_time = 1800

	var/static/active_phylacteries = 0

/obj/item/phylactery/Initialize(mapload, datum/mind/newmind)
	. = ..()
	mind = newmind
	name = "phylactery of [mind.name]"

	active_phylacteries++
	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)
	if(initial(SSticker.mode.round_ends_with_antag_death))
		SSticker.mode.round_ends_with_antag_death = FALSE

/obj/item/phylactery/Destroy(force=FALSE)
	STOP_PROCESSING(SSobj, src)
	active_phylacteries--
	GLOB.poi_list -= src
	if(!active_phylacteries)
		SSticker.mode.round_ends_with_antag_death = initial(SSticker.mode.round_ends_with_antag_death)
	. = ..()

/obj/item/phylactery/process()
	if(QDELETED(mind))
		qdel(src)
		return

	if(!mind.current || (mind.current && mind.current.stat == DEAD))
		addtimer(CALLBACK(src,PROC_REF(rise)), respawn_time, TIMER_UNIQUE)

/obj/item/phylactery/proc/rise()
	if(mind.current && mind.current.stat != DEAD)
		return "[mind] already has a living body: [mind.current]"

	var/turf/item_turf = get_turf(src)
	if(!item_turf)
		return "[src] is not at a turf? NULLSPACE!?"

	var/mob/old_body = mind.current
	var/mob/living/carbon/human/lich = new(item_turf)

	lich.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(lich), SLOT_SHOES)
	lich.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(lich), SLOT_W_UNIFORM)
	lich.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(lich), SLOT_WEAR_SUIT)
	lich.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(lich), SLOT_HEAD)

	lich.real_name = mind.name
	mind.transfer_to(lich)
	mind.grab_ghost(force=TRUE)
	lich.hardset_dna(null,null,null,lich.real_name,null, new /datum/species/skeleton/space)
	to_chat(lich, span_warning("My bones clatter and shudder as you are pulled back into this world!"))
	var/turf/body_turf = get_turf(old_body)
	lich.DefaultCombatKnockdown(200 + 200*resurrections)
	resurrections++
	if(old_body && old_body.loc)
		if(iscarbon(old_body))
			var/mob/living/carbon/C = old_body
			for(var/obj/item/W in C)
				C.dropItemToGround(W)
			for(var/X in C.internal_organs)
				var/obj/item/organ/I = X
				I.Remove()
				I.forceMove(body_turf)
		var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
		if(wheres_wizdo)
			old_body.visible_message(span_warning("Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!"))
			body_turf.Beam(item_turf,icon_state="lichbeam",time=10+10*resurrections,maxdistance=INFINITY)
		old_body.dust()


	return "Respawn of [mind] successful."
