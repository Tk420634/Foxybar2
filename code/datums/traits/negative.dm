//predominantly negative traitsvalue = -1

/datum/quirk/blooddeficiency
	name = "Acute Blood Deficiency"
	desc = "My body struggles to produce enough blood to sustain itself. Whilst not fatal, not treating your condition and getting wounded will send you into an un-recoverable death-spiral!"
	value = -30
	category = "Health Quirks"
	mechanics = "My blood will constantly drop to 30% of blood capacity. Replenishing your lost blood will also make you hungry!"
	conflicts = list()
	gain_text = span_danger("I feel your vigor slowly fading away.")
	lose_text = span_notice("I feel vigorous again.")
	antag_removal_text = "My antagonistic nature has removed your blood deficiency."
	medical_record_text = "Patient struggles to maintain an optimal blood volume, requires transfusions and iron supplements."

/datum/quirk/blooddeficiency/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(NOBLOOD in H.dna.species.species_traits) //can't lose blood if your species doesn't have any
		return
	else
		if(H.blood_volume > BLOOD_VOLUME_SYMPTOMS_DEBILITATING) // If blood volume is higher than (30%), do stuff. You can survive with this blood level but it sucks.
			H.blood_volume -= 0.275	//WARNING! PR #843 HAS DONE A LOT OF STUFF TO BLOOD SO CHECK IT BEFORE CHANGING THIS ! ! You regenerate 2.5 blood if you're fed.

/datum/quirk/depression
	name = "Mood - Depressive" //mood dude
	desc = "I sometimes just hate life, and get a mood debuff for it."
	mob_trait = TRAIT_DEPRESSION
	value = -22
	category = "Emotional Quirks"
	mechanics = "Every tick you have a chance to get hit with a pretty big negative moodlet. Yeah. Depression kind of sucks, who'da'thunk'it?"
	conflicts = list(
		/datum/quirk/optimist,
	)
	gain_text = span_danger("I start feeling depressed.")
	lose_text = span_notice("I no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder, causing them to experience acute episodes of depression."
	mood_quirk = TRUE

/datum/quirk/depression/on_process()
	if(prob(0.05))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/pessimist
	name = "Mood - Pessimist"
	desc = "I sometimes just sort of hate life, and get a mood debuff for it."
	mob_trait = TRAIT_PESSIMIST
	value = -11
	category = "Emotional Quirks"
	mechanics = "Every tick you have a chance to be hit with a negative moodlet. Yeah. It sucks being a downer all the time."
	conflicts = list(
)
	gain_text = span_danger("I start feeling depressed.")
	lose_text = span_notice("I no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a mood disorder, causing them to experience episodes of depression like symptoms."
	mood_quirk = TRUE

/datum/quirk/pessimist/on_process()
	if(prob(0.05))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "pessimist", /datum/mood_event/pessimism)

/*
/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "I am the current owner of an heirloom, passed down for generations. You have to keep it safe!"
	value = -11
	category = "Emotional Quirks"
	mechanics = "As it stands this will give you a random item from a list to keep track of, remind Fenny constantly that it should be broken down into multiple different items or like a labeller to make any one item your squishy."
	conflicts = list(/datum/quirk/apathetic)
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	var/obj/item/heirloom
	var/where

GLOBAL_LIST_EMPTY(family_heirlooms)

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type
	switch(quirk_holder.mind.assigned_role)
		if("Scribe")
			heirloom_type = pick(/obj/item/trash/f13/electronic/toaster, /obj/item/screwdriver/crude, /obj/item/toy/tragicthegarnering)
		if("Knight")
			heirloom_type = /obj/item/gun/ballistic/automatic/toy/pistol
		if("BoS Off-Duty")
			heirloom_type = /obj/item/toy/figure/borg
		if("Sheriff")
			heirloom_type = /obj/item/clothing/accessory/medal/silver
		if("Deputy")
			heirloom_type = /obj/item/clothing/accessory/medal/bronze_heart
		if("Texarkana Trade Worker")
			heirloom_type = /obj/item/coin/plasma
		if("Town Doctor")
			heirloom_type = pick(/obj/item/clothing/neck/stethoscope,/obj/item/toy/tragicthegarnering)
		if("Senior Doctor")
			heirloom_type = pick(/obj/item/toy/nuke, /obj/item/wrench/medical, /obj/item/clothing/neck/tie/horrible)
		if("Prime Legionnaire")
			heirloom_type = pick(/obj/item/melee/onehanded/machete, /obj/item/melee/onehanded/club/warclub, /obj/item/clothing/accessory/talisman, /obj/item/toy/plush/mr_buckety)
		if("Recruit Legionnaire")
			heirloom_type = pick(/obj/item/melee/onehanded/machete, /obj/item/melee/onehanded/club/warclub, /obj/item/clothing/accessory/talisman,/obj/item/clothing/accessory/skullcodpiece/fake)
		if("Den Mob Boss")
			heirloom_type = /obj/item/lighter/gold
		if("Den Doctor")
			heirloom_type = /obj/item/card/id/dogtag/MDfakepermit
		if("Farmer")
			heirloom_type = pick(/obj/item/hatchet, /obj/item/shovel/spade, /obj/item/toy/plush/beeplushie)
		if("Janitor")
			heirloom_type = /obj/item/mop
		if("Security Officer")
			heirloom_type = /obj/item/clothing/accessory/medal/silver/valor
		if("Scientist")
			heirloom_type = /obj/item/toy/plush/slimeplushie
		if("Assistant")
			heirloom_type = /obj/item/clothing/gloves/cut/family
		if("Chaplain")
			heirloom_type = /obj/item/camera/spooky/family
		if("Captain")
			heirloom_type = /obj/item/clothing/accessory/medal/gold/captain/family
	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/card/id/rusted,
		/obj/item/card/id/rusted/fadedvaultid,
		/obj/item/clothing/gloves/ring/silver,
		/obj/item/toy/figure/detective,
		/obj/item/toy/tragicthegarnering,
		)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	GLOB.family_heirlooms += heirloom
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/post_add()
	if(where == "in your backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, span_boldnotice("There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!"))
	var/list/family_name = splittext(quirk_holder.real_name, " ")
	heirloom.name = "\improper [family_name[family_name.len]] family [heirloom.name]"

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/clone_data()
	return heirloom

/datum/quirk/family_heirloom/on_clone(data)
	heirloom = data
*/

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper" //hard consider redesigning, since this is a flat update. ~TK
	desc = "I sleep like a rock! Whenever you're put to sleep, you sleep for a little bit longer."
	value = -11
	category = "Functional Quirks"
	mechanics = "If you use the sleep verb you sleep for longer, but don't heal any more than you would normally. If you use sleep-toggle it takes you longer to wake up."
	conflicts = list(
	)
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("I feel sleepy.")
	lose_text = span_notice("I feel awake again.")
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/*
/datum/quirk/brainproblems
	name = "Brain Tumor"
	desc = "I have a little friend in your brain that keeps growing back! Mannitol will keep it at bay, but it can't be cured!"
	value = -30 // Constant brain DoT until 75 brain damage. Brains have 200 health
	category = "Health Quirks"
	mechanics = "My brain has a tumor that will grow quickly while it's small, but will slow down over time. \
				While not lethal in the scope of a single round, you will want to frequently take mannitol or \
				you will suffer frequent, debilitating debuffs."
	conflicts = list(

	)
	gain_text = span_danger("I feel smooth.")
	lose_text = span_notice("I feel wrinkled again.")
	medical_record_text = "Patient has a tumor in their brain that is slowly driving them to brain death."
	COOLDOWN_DECLARE(annoying_message)

/datum/quirk/brainproblems/on_process()
	//Deal fast brain damage at the start and ramp it down over time so it takes a long time to reach the cap.
	var/bdam = quirk_holder.getOrganLoss(ORGAN_SLOT_BRAIN)
	switch(bdam)
		if(0 to 25)
			quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.3)
		if(25 to 50)
			quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25)
		if(50 to 75)
			quirk_holder.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)
	if((bdam > 25) && COOLDOWN_FINISHED(src, annoying_message))
		COOLDOWN_START(src, annoying_message, 3 MINUTES)
		to_chat(quirk_holder, span_danger("I really need some mannitol!"))
*/
/*
/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted - Corrected"
	desc = "I am nearsighted without prescription glasses, but spawn with a pair."
	value = -11
	category = "Vision Quirks"
	mechanics = "My vision is blurry at a distance, but you have glasses you spawn with that can fix that."
	conflicts = list(
		/datum/quirk/noglasses,
		/datum/quirk/badeyes,
		/datum/quirk/blindness,
	)
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("I start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/quirk/nearsighted/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/glasses = new(get_turf(H))
	if(!H.equip_to_slot_if_possible(glasses, SLOT_GLASSES))
		H.put_in_hands(glasses)
*/

/datum/quirk/noglasses
	name = "Nearsighted - No Glasses"
	desc = "I am nearsighted and without prescription glasses, you should find a pair."
	value = -15
	category = "Vision Quirks"
	mechanics = "My vision is blurred, but you either never had or lost your glasses.  Good luck!"
	conflicts = list(
		/datum/quirk/badeyes,
	)
	gain_text = span_danger("Things far away from you start looking blurry.")
	lose_text = span_notice("I start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/quirk/noglasses/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/badeyes
	name = "Nearsighted - Trashed Vision"
	desc = "I am badly nearsighted without prescription glasses, so much so that it's kind of a miracle you're still alive. You defintiely don't have any corrective lenses, but they would help."
	value = -32
	category = "Vision Quirks"
	mechanics = "Bro your eyes are straight up having a bad time, your vision is absolutely recked and you have no immediate way of helping it."
	conflicts = list(
		/datum/quirk/noglasses,

	)
	gain_text = span_danger("Things far away from you start looking VERY blurry.")
	lose_text = span_notice("I start seeing faraway things normally again.")
	medical_record_text = "Patient requires prescription glasses in order to counteract sort of ridiculous levels of nearsightedness."

/datum/quirk/badeyes/add()
	quirk_holder.become_mega_nearsighted(ROUNDSTART_TRAIT)

/*
/datum/quirk/nyctophobia
	name = "Phobia - The Dark"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -11 // Refer to traumas.dm if balancing point values for phobias. If its too weak, it might be missing some triggers.
	category = "Phobia Quirks"
	mechanics = "I must walk carefully through dark areas and will feel a sense of panic when you do. Don't turn the lights out."
	conflicts = list(/datum/quirk/lightless)
	medical_record_text = "Patient demonstrates a fear of the dark."

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(quirk_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_holder, span_warning("Easy, easy, take it slow... you're in the dark..."))
			quirk_holder.toggle_move_intent()
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
*/

/datum/quirk/lightless
	name = "Light Sensitivity"
	desc = "Bright lights irritate you. Your eyes start to water, your skin feels itchy against the photon radiation, and your hair gets dry and frizzy. Maybe it's a medical condition."
	value = -22
	category = "Vision Quirks"
	mechanics = "While in bright light without sunglasses, you get a negative moodlet and your eyes go blurry. Are you part molerat?"
	conflicts = list()
	gain_text = span_danger("The light begins to hurt your eyes...")
	lose_text = span_notice("My eyes no longer sting in the light.")
	medical_record_text = "Patient has acute light sensitivity, and insists it is physically harmful."

/datum/quirk/lightless/on_process()
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/sunglasses = H.get_item_by_slot(SLOT_GLASSES)

	if(lums >= 0.8) // Eyeblur for those ill prepared
		if(!istype(sunglasses, /obj/item/clothing) || sunglasses?.tint < 1)
			if(quirk_holder.eye_blurry < 10)
				quirk_holder.eye_blurry = 10
			SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "brightlight", /datum/mood_event/brightlight)
	if(lums >= 0.6) // Accuracy gets kicked in the teeth regardless of sunglasses. A bit stronger than regular poor aim. Also stacks.
		ADD_TRAIT(quirk_holder, TRAIT_LIGHT_SENSITIVITY, TRAIT_GENERIC)
	if(lums <= 0.6)
		REMOVE_TRAIT(quirk_holder, TRAIT_LIGHT_SENSITIVITY, TRAIT_GENERIC)

/datum/quirk/lightburning
	name = "Shadow Creature"
	desc = "I am a shadey creature! Bright lights burn you, the shadows mend you."
	value = -33 // This can kill you, which is extremely bad, and makes city play somewhat impossible
	category = "Health Quirks"
	mechanics = "While in the light, you slowly wither away, but the reverse happens in the dark, healing you and giving you nutrition."
	conflicts = list()

/datum/quirk/lightburning/add()
	var/mob/living/carbon/human/H = quirk_holder
	H.AddElement(/datum/element/photosynthesis, 0.5, 0.5, 0.5, 0.5, 1, 0, 0.2, 0.2) // Set it a bit higher, since finding true dark areas (totally 0) is near impossible

/datum/quirk/lightburning/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H.RemoveElement(/datum/element/photosynthesis, 0.5, 0.5, 0.5, 0.5, 1, 0, 0.2, 0.2)

/*
/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -65
	category = "Lifepath Quirks"
	mechanics = "I am mechanically stopped from hurting things, or throwing things that could."
	conflicts = list(
		/datum/quirk/nonviolent_lesser
	)
	mob_trait = TRAIT_PACIFISM
	gain_text = span_danger("I feel repulsed by the thought of violence!")
	lose_text = span_notice("I think you can defend yourself again.")
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."
	antag_removal_text = "My antagonistic nature has caused you to renounce your pacifism."

/datum/quirk/nonviolent_lesser
	name = "Pacifist - Lesser"
	desc = "I think that hurting sapient living beings is wrong, but defending yourself from fauna is your goddamn American right."
	value = -35
	category = "Lifepath Quirks"
	mechanics = "I can hurt simplemobs, but in case you hurt a carbon you'll shake and temporarely be afraid of doing harm for little time."
	conflicts = list(
		/datum/quirk/nonviolent
	)
	mob_trait = TRAIT_PACIFISM_LESSER
	gain_text = span_danger("Hurting sapient creatures is wrong!")
	lose_text = span_notice("Actually... I think I like violence...")
	medical_record_text = "Patient cannot bring themselves to cause physical harm to sapient creatures."
	antag_removal_text = "My antagonistic nature has caused you to renounce your pacifism and choose violence."
*/
/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "My legs do not function. Nothing will ever fix this. Luckily you found a wheelchair."
	value = -40
	category = "Health Quirks"
	mechanics = "My legs just flat out don't work."
	conflicts = list(
	)
	mob_trait = TRAIT_PARA
	human_only = TRUE
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."

/datum/quirk/paraplegic/add()
	var/datum/brain_trauma/severe/paralysis/paraplegic/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/on_spawn()
	if(quirk_holder.client)
		var/modified_limbs = quirk_holder.client.prefs.modified_limbs
		if(!(modified_limbs[BODY_ZONE_L_LEG] == LOADOUT_LIMB_AMPUTATED && modified_limbs[BODY_ZONE_R_LEG] == LOADOUT_LIMB_AMPUTATED && !isjellyperson(quirk_holder)))
			if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
				quirk_holder.buckled.unbuckle_mob(quirk_holder)

			var/turf/T = get_turf(quirk_holder)
			var/obj/structure/chair/spawn_chair = locate() in T

			var/obj/vehicle/ridden/wheelchair/wheels = new(T)
			if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
				wheels.setDir(spawn_chair.dir)

			wheels.buckle_mob(quirk_holder)

			// During the spawning process, they may have dropped what they were holding, due to the paralysis
			// So put the things back in their hands.

			for(var/obj/item/I in T)
				if(I.fingerprintslast == quirk_holder.ckey)
					quirk_holder.put_in_hands(I)

