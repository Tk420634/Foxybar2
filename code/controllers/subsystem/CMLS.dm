SUBSYSTEM_DEF(CMLS)
	name = "CMLS"
	flags = SS_BACKGROUND|SS_NO_FIRE
	init_order = INIT_ORDER_CMLS

	var/num_ammo_states = 0

	var/list/ammos = list()
	var/list/ammodesigns = list()
	var/list/design_cats = list()
	var/list/all_C = list()
	var/list/all_M = list()
	var/list/all_L = list()
	var/list/all_S = list()

	var/list/data_for_tgui = list()

	var/compact_ammo_per_box = 60
	var/compact_ammo_price_per_box = 10
	var/compact_ammo_per_crate = 600
	var/compact_ammo_price_per_crate = 100

	var/medium_ammo_per_box = 30
	var/medium_ammo_price_per_box = 15
	var/medium_ammo_per_crate = 300
	var/medium_ammo_price_per_crate = 150

	var/long_ammo_per_box = 20
	var/long_ammo_price_per_box = 20
	var/long_ammo_per_crate = 200
	var/long_ammo_price_per_crate = 200

	var/shotgun_ammo_per_box = 12
	var/shotgun_ammo_price_per_box = 24
	var/shotgun_ammo_per_crate = 120
	var/shotgun_ammo_price_per_crate = 240

/datum/controller/subsystem/CMLS/Initialize(start_timeofday)
	InitGunNerdStuff()
	. = ..()

/datum/controller/subsystem/CMLS/proc/InitGunNerdStuff()
	if(LAZYLEN(ammos))
		QDEL_LIST_ASSOC_VAL(ammos)
	ammos = list()
	for(var/flt in subtypesof(/datum/ammo_kind))
		new flt() // it knows what its do
	to_chat(world, span_boldnotice("Initialized [LAZYLEN(ammos)] different ammo kinds! 🔫🐈"))

/datum/controller/subsystem/CMLS/proc/GetAmmoTypeDesigns()
	if(!LAZYLEN(ammodesigns))
		InitGunNerdStuff()
	return ammodesigns

///////////////////////////BULLETS///////////////////////////
/datum/controller/subsystem/CMLS/proc/SetupBullet(obj/item/ammo_casing/generic/AC, kind)
	if(!istype(AC) || !kind)
		return
	var/datum/ammo_kind/ammou = GetAmmokind(kind)
	if(!ammou)
		return
	ammou.SetupBullet(AC)

/datum/controller/subsystem/CMLS/proc/SkinBullet(obj/item/ammo_casing/generic/AC, kind)
	if(!istype(AC) || !kind)
		return
	var/datum/ammo_kind/ammou = GetAmmokind(kind)
	if(!ammou)
		return
	ammou.SkinBullet(AC)

/datum/controller/subsystem/CMLS/proc/UpdateBullet(obj/item/ammo_casing/generic/AC)
	if(!istype(AC))
		return
	var/datum/ammo_kind/ammou = GetAmmokind(AC.caliber)
	if(!ammou)
		return
	ammou.UpdateBullet(AC)

///////////////////////////BOXES///////////////////////////
/datum/controller/subsystem/CMLS/proc/SetupBox(obj/item/ammo_box/generic/mag, kind, CorB = AMMOBOX_IS_BOX)
	if(!istype(mag) || !kind)
		return
	var/datum/ammo_kind/ammou = GetAmmokind(kind)
	if(!ammou)
		return
	ammou.SetupBox(mag, CorB)

/datum/controller/subsystem/CMLS/proc/SkinBox(obj/item/ammo_box/generic/mag, kind, bullets_too, CorB = AMMOBOX_IS_BOX)
	if(!istype(mag) || !kind)
		return
	var/datum/ammo_kind/ammou = GetAmmokind(kind)
	if(!ammou)
		return
	ammou.SkinBox(mag, CorB)

/datum/controller/subsystem/CMLS/proc/UpdateBox(obj/item/ammo_box/generic/mag, CorB = AMMOBOX_IS_BOX)
	if(!istype(mag))
		return
	var/datum/ammo_kind/ammou = GetAmmokind(mag.ammo_kind)
	if(!ammou)
		return
	ammou.UpdateBox(mag, CorB)

///////////////////////////RESKINS///////////////////////////
/// attempts to have the user transform a bullet into a different kind of bullet of the same CMLS type
/// brings up a dialog for the user to select a new bullet kind
/datum/controller/subsystem/CMLS/proc/ReskinBullet(mob/user, obj/item/ammo_casing/generic/AC)
	if(!user)
		return
	if(!istype(AC))
		to_chat(user, span_alert("That's not a kind of bullet you can reskin!"))
		return
	var/datum/ammo_kind/curr_ammou = GetAmmokindByType(AC.caliber)
	if(!curr_ammou)
		to_chat(user, span_alert("That bullet doesn't have a valid ammo kind!"))
		return
	var/list/prechoices
	switch(AC.caliber)
		if(AC.caliber == CALIBER_COMPACT)
			prechoices = SSCMLS.all_C
		if(AC.caliber == CALIBER_MEDIUM)
			prechoices = SSCMLS.all_M
		if(AC.caliber == CALIBER_LONG)
			prechoices = SSCMLS.all_L
		if(AC.caliber == CALIBER_SHOTGUN)
			prechoices = SSCMLS.all_S
		else
			to_chat(user, span_alert("That bullet doesn't have a valid CMLS type!"))
			return
	for(var/ammokind in prechoices)
		var/datum/ammo_kind/ammou = prechoices[ammokind]
		prechoices[ammou.name] = ammokind
	var/mychoose = tgui_input_list(user, "Choose a new bullet type for your [AC.name]!", "Pick a [AC.caliber] cartridge", prechoices)
	if(!mychoose)
		to_chat(user, span_alert("Never mind!!"))
		return
	var/ammokind_back = prechoices[mychoose]
	if(!ammokind_back)
		to_chat(user, span_alert("That's not a valid choice!"))
		return
	var/datum/ammo_kind/ammou = GetAmmokind(ammokind_back)
	if(!ammou)
		to_chat(user, span_alert("That's not a valid choice! ERROR CODE: SLICK SAUCY BANANA WHEEL"))
		return
	to_chat(user, span_success("You've reskinned your [AC.name] into \a [ammou.name]!"))
	ammou.
	SkinBullet(AC, ammokind_back)

/// attempts to have the user transform a box into a different kind of box of the same CMLS type
/// brings up a dialog for the user to select a new box kind
/datum/controller/subsystem/CMLS/proc/ReskinBox(mob/user, obj/item/ammo_box/generic/mag)
	if(!user)
		return
	if(!istype(mag))
		to_chat(user, span_alert("That's not a kind of box you can reskin!"))
		return
	var/datum/ammo_kind/curr_ammou = GetAmmokind(mag.ammo_kind)
	if(!curr_ammou)
		to_chat(user, span_alert("That box doesn't have a valid ammo kind!"))
		return
	var/list/prechoices
	switch(mag.caliber)
		if(mag.caliber == CALIBER_COMPACT)
			prechoices = SSCMLS.all_C
		if(mag.caliber == CALIBER_MEDIUM)
			prechoices = SSCMLS.all_M
		if(mag.caliber == CALIBER_LONG)
			prechoices = SSCMLS.all_L
		if(mag.caliber == CALIBER_SHOTGUN)
			prechoices = SSCMLS.all_S
		else
			to_chat(user, span_alert("That box doesn't have a valid CMLS type!"))
			return
	for(var/ammokind in prechoices)
		var/datum/ammo_kind/ammou = prechoices[ammokind]
		prechoices[ammou.name] = ammokind
	var/mychoose = tgui_input_list(user, "Choose what your ammo box holds and converts any compatible ammo into!", "Pick a [mag.caliber] box", prechoices)
	if(!mychoose)
		to_chat(user, span_alert("Never mind!!"))
		return
	var/ammokind_back = prechoices[mychoose]
	if(!ammokind_back)
		to_chat(user, span_alert("That's not a valid choice!"))
		return
	var/datum/ammo_kind/ammou = GetAmmokind(ammokind_back)
	if(!ammou)
		to_chat(user, span_alert("That's not a valid choice! ERROR CODE: SPANKY SWANKY SALAD SHOOTER"))
		return
	to_chat(user, span_success("Your ammobox now holds (and will convert any compatible ammo) into \a [ammou.name]!"))
	SkinBox(mag, ammokind_back, TRUE)

/datum/controller/subsystem/CMLS/proc/RandomizeBox(obj/item/ammo_box/generic/mag)
	if(!istype(mag))
		return
	var/caliber = LAZYACCESS(mag.caliber, 1)
	var/list/topickfrom
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			topickfrom = SSCMLS.all_C
		if(caliber == CALIBER_MEDIUM)
			topickfrom = SSCMLS.all_M
		if(caliber == CALIBER_LONG)
			topickfrom = SSCMLS.all_L
		if(caliber == CALIBER_SHOTGUN)
			topickfrom = SSCMLS.all_S
		else
			return
	SetupBox(mag, safepick(topickfrom))

/datum/controller/subsystem/CMLS/proc/RandomizeBullet(obj/item/ammo_casing/generic/AC)
	if(!istype(AC))
		return
	var/caliber = LAZYACCESS(AC.caliber, 1)
	var/list/topickfrom
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			topickfrom = SSCMLS.all_C
		if(caliber == CALIBER_MEDIUM)
			topickfrom = SSCMLS.all_M
		if(caliber == CALIBER_LONG)
			topickfrom = SSCMLS.all_L
		if(caliber == CALIBER_SHOTGUN)
			topickfrom = SSCMLS.all_S
		else
			return
	SetupBullet(AC, safepick(topickfrom))

/datum/controller/subsystem/CMLS/proc/GetAmmokind(kind)
	var/datum/ammo_kind/ammou = LAZYACCESS(ammos, kind)
	if(!ammou)
		ammou = GetAmmokindByName(kind)
		if(!ammou)
			message_admins("Ammo kind [kind] not found!")
			CRASH("Ammo kind [kind] not found!")
	return ammou

/datum/controller/subsystem/CMLS/proc/GetAmmokindByName(ammoname)
	for(var/datum/ammo_kind/ammou in ammos)
		if(ammou.name == ammoname)
			return ammou
	return null

/datum/controller/subsystem/CMLS/proc/GetAmmokindByType(ammo_type)
	for(var/datum/ammo_kind/ammou in ammos)
		if(istype(ammou, ammo_type))
			return ammou
	return null

#define FULL_STATE "full" // mandatory Full state for icons
#define EMPTY_STATE "empty" // mandatory Empty state for icons
#define BOX_STATE "box" // mandatory Box state for icons
#define CRATE_STATE "crate" // mandatory Crate state for icons
#define BULLET_STATE "bullet" // mandatory Bullet state for icons

#define BULLET_TAG "bullet"
#define CRATE_TAG "crate"
#define BOX_TAG "box"

#define PARTIAL_TAG "partial" // default state if no specific partials are found
#define PARTIAL_COUNT_TAG "count"
#define PARTIAL_PERCENT_TAG "percent"

///
/// HI HELLO WELCOME TO DAN AND BUNNY'S CLEVER CMLS AMMO SPRITE AUTOGENERATION SYSTEM YES
/// Is this you: I ADDED IN A NEW AMMO GUN AND NOW ITS INVISIBLE>?????
/// Invisible your ammo no more, cus we've got a system that'll make sure your ammo is visible and pretty IF you follow the rules!!!
/// Rule 1: ALL AMMO ICONS GO IN /icons/obj/ammo/
///         this is cus we're gonna have one DMI per (visually distinct) ammo type, and we want them all in one place
///         this brings me to...
/// Rule 2: ONE AMMO TYPE PER DMI
///         this is so the automatic sprite compilation system can work its magic without me having to learn *actual* magic
///         trust me you'll thank me later
/// Rule 3: ICON STATES HAVE A RIGID NAMING STRUCTURE THAT MUST BE FOLLOWED
///         the system works off of a system of text identifiers in the sprite names themselves, which define what the sprite is for
///         that's right, the name itself defines if the sprite is an a bullet, a crate, a half-full ammobox, a speedloader with 2/16 bullets, etc
///         the system is as follows:
/// - All box and crate states follow the format "[crate or box]-[when to display it]"
///   - crate-full, box-empty, box-partial, crate-partial-percent-25, etc.
///   - There *must* be a box-full, box-empty, crate-full, and crate-empty state for the system to work
///     - if you don't have these, the system will spam the admins and default to plushies and everyone will laugh
///   - if you have a partial, you have two options: vague partial, or a specific(ish) partial
///     - vague partials are defined with box-partial or crate-partial, and are used to handle cases not handled by more specific partials
///       - It'll be used for any ammo count higher than the highest specific count partial (unless your highest count is equal to the ammo count (though in that case, the full state will be used))
///       - It'll be used for any ammo percentage higher than the highest specific percent partial (unless you have a 100 percent partial)
///       - It'll be used if there are no specific partials set
///       - If there is no vague partial, the system will use the full state instead for ammo values between full and empty
///     - specific partials have two formats: count-# or percent-#
///       - count-# is used for specific(ish) bullet counts, like box-partial-count-5
///       - if you have count partials, and the ammo count does not match any of them, the system will round up to the next highest valid partial
///     - percent-# is used for specific(ish) percentages of ammo in a box or crate, like box-partial-percent-25
///       - if you have percent partials, the system will round the ammo count to a percentage, then find the highest partial that is less than or equal to that percentage
///       - if you have count partials set, those states will be used *if* the ammo count is equal to a valid count state, otherwise it defaults to the percent partials
///       - Be sure to include a 100 percent partial, to handle cases above the highest partial
///         - not required tho, it'll just default to the broad partial if it exists, or the full state otherwise
/// - All bullet states follow the format "bullet-[full or empty]"
///   - bullet-full, bullet-empty, etc.
///   - There *must* be a bullet-full and bullet-empty state for the system to work
/// Rule 4: Have fun! =3

//////////////////
/// AMMO KINDS ///
/// ////////// ///
/// Defines the different kinds of functionally identical ammo types to be used by the CMLS system.
/// Defines its name, flavoring, CMLS status, and other largely meaningless properties.
/// Also defines the icon states for the ammo and the box, which are used to visually represent the ammo in the game.
/// so it does both box and bullet! wow!
/datum/ammo_kind
	var/name = "Gun Bullet"
	var/flavor = "Some kind of bullet, designed in 1925 by Jean-Krousing von de la Krouse III as a way to turn brass into lead. \
		From the moment he laid eyes on the newest creation by Stubby Jack, he knew what he needed to do, and that was create the best \
		way to turn brass into lead. And so, he did. And it was good. And it was called the Gun Bullet."
	var/box_name = null // set if you want te box to have a custom name
	var/box_flavor = null // set if you want the box to have a custom flavor
	var/caliber = CALIBER_COMPACT
	var/ammo_icon = 'icons/obj/ammo/compact.dmi' /// you'll want a separate DMI for each *visually distinct* ammo type
	// var/bullet_icon_state_prefix = "bullet"
	// var/box_icon_state_prefix = "box"
	// var/crate_icon_state_prefix = "crate"
	/// Two mandatory, required states for the icon are "full" and "empty", without these it will default to plushes and everyone will laugh
	/// The system will auto-detect extra sprites and add them to a handy list, so don't touch this (it'll just be overwritten)
	/// TODO: document it :^)
	var/holder_states = list()

	var/has_box = TRUE
	var/has_crate = TRUE
	var/has_bullet = TRUE

	var/box_raw_cost = 0
	var/box_copper_cost = 0
	var/box_siver_cost = 0
	var/box_gold_cost = 0
	var/crate_raw_cost = 0
	var/crate_copper_cost = 0
	var/crate_siver_cost = 0
	var/crate_gold_cost = 0

/datum/ammo_kind/New()
	. = ..()
	CompileStates()
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			box_raw_cost == CMLS.compact_ammo_price_per_box
			crate_raw_cost == CMLS.compact_ammo_price_per_crate
		if(caliber == CALIBER_MEDIUM)
			box_raw_cost == CMLS.medium_ammo_price_per_box
			crate_raw_cost == CMLS.medium_ammo_price_per_crate
		if(caliber == CALIBER_LONG)
			box_raw_cost == CMLS.long_ammo_price_per_box
			crate_raw_cost == CMLS.long_ammo_price_per_crate
		if(caliber == CALIBER_SHOTGUN)
			box_raw_cost == CMLS.shotgun_ammo_price_per_box
			crate_raw_cost == CMLS.shotgun_ammo_price_per_crate
	box_gold_cost = round(raw_cost / 100)
	box_silver_cost = round((raw_cost - (box_gold_cost * 100)) / 10)
	box_copper_cost = round(raw_cost - (box_gold_cost * 100) - (box_silver_cost * 10))
	crate_gold_cost = round(crate_raw_cost / 100)
	crate_silver_cost = round((crate_raw_cost - (crate_gold_cost * 100)) / 10)
	crate_copper_cost = round(crate_raw_cost - (crate_gold_cost * 100) - (crate_silver_cost * 10))

	SSCMLS.ammos[type] = src
	switch(CMLS)
		if(CMLS == CALIBER_COMPACT)
			SSCMLS.all_C[type] = src
		if(CMLS == CALIBER_MEDIUM)
			SSCMLS.all_M[type] = src
		if(CMLS == CALIBER_LONG)
			SSCMLS.all_L[type] = src
		if(CMLS == CALIBER_SHOTGUN)
			SSCMLS.all_S[type] = src

/// reads our DMI and compiles a list of states for the icon
/datum/ammo_kind/proc/CompileStates()
	var/list/my_states = icon_states(ammo_icon)
	/// plushie error if the icon is valid (game wont compile if the icon doesnt exist), or it lacks the mandatory states (full and empty)
	if(!LAZYLEN(my_states)
		|| (has_bullet 
			&& !("[BULLET_STATE]-[FULL_STATE]" in my_states)
			|| !("[BULLET_STATE]-[EMPTY_STATE]" in my_states))
		|| (has_box
			&& !("[BOX_STATE]-[FULL_STATE]" in my_states)
			|| !("[BOX_STATE]-[EMPTY_STATE]" in my_states))
		|| (has_crate
			&& !("[CRATE_STATE]-[FULL_STATE]" in my_states)
			|| !("[CRATE_STATE]-[EMPTY_STATE]" in my_states))
		|| (!has_bullet && !has_box && !has_crate)
		)
		ammo_icon = 'icon/obj/plushes.dmi'
		holder_states = list(
			BULLET_CAT = list(
				STATE_FULL = "hairball",
				STATE_EMPTY = "fermis",
			),
			BOX_CAT = list(
				STATE_FULL = "kobold",
				STATE_EMPTY = "fox",
			),
			CRATE_CAT = list(
				STATE_FULL = "bird",
				STATE_EMPTY = "sergal",
			),
		) // default to plushes if we can't find the icon
		message_admins("No states found for [name]!")
		CRASH("No states found for [name]!")
	/// just to flex my dikc about how many codersprites we have
	if(has_bullet)
		holder_states[BULLET_CAT] = list(
				STATE_FULL = "bullet-full",
				STATE_EMPTY = "bullet-empty",
			)
		SSCMLS.num_ammo_states += 2
	if(has_box)
		holder_states[BOX_CAT] = list(
				STATE_FULL = "box-full",
				STATE_EMPTY = "box-empty",
			)
		SSCMLS.num_ammo_states += 2
	if(has_crate)
		holder_states[CRATE_CAT] = list(
				STATE_FULL = "crate-full",
				STATE_EMPTY = "crate-empty",
			)
		SSCMLS.num_ammo_states += 2
	/// the standard "fulls" and "emptys" are just assumed to be there by the code. You *did* add em right?
	/// Now check for extra partials and add them to the list
	var/list/newstates = list()
	for(var/istate in my_states)
		var/list/partial_breakup = splittext(istate, "-")
		if(LAZYACCESS(partial_breakup, 1) != PARTIAL_TAG)
			continue
		partial_breakup.Cut(1,2) // its gonna be the same for all of them
		if(!LAZYLEN(partial_breakup)) // it was a broad partial
			if(!islist(newstates[PARTIAL_TAG]))
				newstates[PARTIAL_TAG] = list()
			newstates[PARTIAL_TAG] = partial_breakup[2] // there can be only one
			SSCMLS.num_ammo_states += 1
			continue
		// a specific partial! maybe. first entry should be count or percent, the second a number
		/// strip out any non-numaerical characters from the second entry
		var/nunum = ""
		for(var/i in 1 to LAZYLEN(partial_breakup[2]))
			if(partial_breakup[2][i] in list("0","1","2","3","4","5","6","7","8","9")) // brilliant
				nunum = "[nunum][partial_breakup[2][i]]"
		if(!nunum)
			continue
		if(partial_breakup[1] == PARTIAL_COUNT_TAG)
			if(!islist(newstates[PARTIAL_COUNT_TAG]))
				newstates[PARTIAL_COUNT_TAG] = list()
			newstates[PARTIAL_COUNT_TAG]["[nunum]"] = istate
			SSCMLS.num_ammo_states += 1
			continue
		if(partial_breakup[1] == PARTIAL_PERCENT_TAG)
			if(!islist(newstates[PARTIAL_PERCENT_TAG]))
				newstates[PARTIAL_PERCENT_TAG] = list()
			newstates[PARTIAL_PERCENT_TAG]["[nunum]"] = istate
			SSCMLS.num_ammo_states += 1
			continue
	/// now sort the partials
	/// order count partials in order from smallest to biggest
	if(LAZYLEN(newstates[PARTIAL_COUNT_TAG]))
		var/list/countstates = CrudeInsertionSort(newstates[PARTIAL_COUNT_TAG])
		newstates[PARTIAL_COUNT_TAG] = countstates
	/// order percent partials in order from smallest to biggest
	if(LAZYLEN(newstates[PARTIAL_PERCENT_TAG]))
		var/list/percentstates = CrudeInsertionSort(newstates[PARTIAL_PERCENT_TAG])
		newstates[PARTIAL_PERCENT_TAG] = percentstates
	/// now we add the new states to the holder
	holder_states = newstates

/datum/ammo_kind/proc/CrudeInsertionSort(list/countstates)
	if(!LAZYLEN(countstates))
		return list()
	var/list/ordered = list()
	ordered.len = LAZYLEN(countstates)
	var/i = 1
	var/safety_counter = 100
	while(LAZYLEN(countstates) && safety_counter--)
		var/lowest = null
		for(var/istate in countstates)
			var/ttn = text2num(istate)
			if(!lowest) // THATS RIGHT WE USING INSERTION SORT BAYBEE
				lowest = text2num(istate)
			if(ttn < lowest)
				lowest = ttn
		if(lowest == null)
			break // just error, idfk
		ordered[i] = countstates["[lowest]"]
		countstates -= ordered[i]
		i++
	return ordered

/// converts A and B from text to numbers, then returns a Tim sort friendly comparison that'll sort from smallest at the top to biggest at the bottom
/proc/cmp_text2num(A, B) // COOL PROC DIDNT USE
	return text2num(A) - text2num(B)

/datum/ammo_kind/proc/GetBulletName(obj/item/ammo_casing/AC)
	if(!AC)
		return "[name] cartridge"
	if(!AC.BB)
		return "Spent [name] casing"
	return "[name] cartridge"

/datum/ammo_kind/proc/GetBulletFlavor(obj/item/ammo_casing/AC)
	if(!AC)
		return "Probably a bullet? Not sure"
	var/descout = span_notice("This is a <u>[span_green("[capitalize("[caliber]")]")]</i>! It'll fit in any gun or box that can hold <u>[span_green("[capitalize("[caliber]")]")]</i>!")
	descout = "[descout]\n[flavor]"
	return flavor

/datum/ammo_kind/proc/GetBulletIcon()
	return ammo_icon

/datum/ammo_kind/proc/GetBulletIconState(obj/item/ammo_casing/AC)
	if(!AC)
		return "[BULLET_STATE]-[EMPTY_STATE]"
	if(!AC.BB)
		return "[BULLET_STATE]-[EMPTY_STATE]"
	return "[BULLET_STATE]-[FULL_STATE]"

/datum/ammo_kind/proc/GetBoxName(obj/item/ammo_box/generic/mag)
	return box_name || "Box of [name]"

/datum/ammo_kind/proc/GetBoxFlavor(obj/item/ammo_box/generic/mag)
	if(!mag)
		return "A box of ammo. It's a box, and it supposedly holds ammo. Neat!"
	var/descout = span_notice("This is a <u>[span_green("[capitalize("[caliber]")]")]</i> box! It'll hold any <u>[span_green("[capitalize("[caliber]")]")]</i> ammo!")
	descout = "[descout]\n[box_flavor ? box_flavor : flavor]"
	return descout

/datum/ammo_kind/proc/GetBoxIcon()
	return ammo_icon

/datum/ammo_kind/proc/GetBoxIconState(obj/item/ammo_box/generic/mag, box_or_crate_override)
	if(!mag)
		return holder_states[BOX_CAT]["[EMPTY_STATE]"]
	var/mag_size = mag.max_ammo
	var/mag_loaded = mag.ammo_count(TRUE) // also get empties for revolvers (not that it matters)
	var/CB = box_or_crate_override || mag.box_or_crate || AMMOBOX_IS_BOX
	/// first, check if we are full!
	if(mag_loaded >= mag_size)
		return holder_states["[CB]"][FULL_STATE]
	/// then, check if we are empty!
	if(mag_loaded < 1)
		return holder_states["[CB]"][EMPTY_STATE]
	/// finally, we are partial! We'll default to the broad partial, or "Full" if there is no broad partial, if there isnt a valid partial
	/// first check if we have a specific match in the specifics
	if(LAZYLEN(holder_states[PARTIAL_COUNT_TAG]))
		var/countstat = holder_states[PARTIAL_COUNT_TAG]["[mag_loaded]"]
		if(countstat)
			return countstat
		var/smallest_found = 0
		//  now check if we have a count partial that is higher than the current ammo count
		for(var/specific_state in holder_states[PARTIAL_COUNT_TAG])
			var/thisnum = text2num(specific_state)
			if(!isnum(thisnum))
				continue
			if(thisnum < mag_loaded)
				continue
			if(!smallest_found)
				smallest_found = thisnum
			if(thisnum < smallest_found)
				smallest_found = thisnum
		if(smallest_found && holder_states[PARTIAL_COUNT_TAG]["[smallest_found]"])
			return holder_states[PARTIAL_COUNT_TAG]["[smallest_found]"]
		/// if we're still here, we dont have a count partial greater than the current ammo count
		/// so, we'll check the percentages
	// if not, check the percentages
	if(LAZYLEN(holder_states[PARTIAL_PERCENT_TAG]))
		var/smallest_found = 0
		var/percent = round((mag_loaded / mag_size) * 100)
		if(percent > 100) // we can't have more than 100% ammo, so if we do
			percent = 100
		var/exactstate = holder_states[PARTIAL_PERCENT_TAG]["[percent]"]
		if(exactstate)
			return exactstate
		/// we'll round that that
		for(var/valid_percents in holder_states[PARTIAL_PERCENT_TAG])
			var/vp_num = text2num(valid_percents)
			if(!isnum(vp_num))
				continue
			if(vp_num < percent)
				continue
			if(!smallest_found)
				smallest_found = vp_num
			if(vp_num < smallest_found)
				smallest_found = vp_num
		if(smallest_found && holder_states[PARTIAL_PERCENT_TAG]["[smallest_found]"])
			return holder_states[PARTIAL_PERCENT_TAG]["[smallest_found]"]
	return holder_states[PARTIAL_TAG] || "[CB]-[FULL_STATE]" // default to full if we don't have a broad partial

/// full overwrite of the bullet with our bullet data
/// Will change caliber! Be careful!
/datum/ammo_kind/proc/SetupBullet(obj/item/ammo_casing/generic/AC)
	if(!istype(AC))
		return
	AC.ammo_kind = type
	AC.caliber = caliber
	SkinBullet(AC)

/// Sets the non-functional properties of the bullet, like the name, flavor, and icon state
/datum/ammo_kind/proc/SkinBullet(obj/item/ammo_casing/generic/AC)
	if(!istype(AC))
		return
	AC.name = GetBulletName(AC)
	AC.flavor = GetBulletFlavor(AC)
	AC.icon = GetBulletIcon()
	AC.icon_state = GetBulletIconState(AC)

/// Updates the bullet's icon state
/datum/ammo_kind/proc/UpdateBullet(obj/item/ammo_casing/generic/AC)
	if(!istype(AC))
		return
	AC.icon_state = GetBulletIconState(AC)

/// full overwrite of the box with our box data, including ammo count, max, etc
/datum/ammo_kind/proc/SetupBox(obj/item/ammo_box/generic/mag, CorB)
	if(!istype(mag))
		return
	if(CorB)
		mag.box_or_crate = CorB
	mag.ammo_kind = type
	mag.caliber = list(caliber)
	SkinBox(mag)

/// Sets the non-functional properties of the box, like the name, flavor, and icon state
/datum/ammo_kind/proc/SkinBox(obj/item/ammo_box/generic/mag)
	if(!istype(mag))
		return
	mag.name = GetBoxName(mag)
	mag.flavor = GetBoxFlavor(mag)
	mag.icon = GetBoxIcon()
	mag.icon_state = GetBoxIconState(mag)

/// Updates the box's icon state
/datum/ammo_kind/proc/UpdateBox(obj/item/ammo_box/generic/mag)
	if(!istype(mag))
		return
	mag.icon_state = GetBoxIconState(mag)

/// generates some guff for TGUI, for the vendor thing that totally exists
/// actually makes two, one for a box, one for a crate
/datum/ammo_kind/proc/GenerateTGUI()
	var/list/dat = list()
	/// first, the box
	var/cmls
	var/C_M_L_S = "???"
	var/rawcost = SSCMLS.compact_ammo_price_per_box
	var/coppercost = 0
	var/silvercost = 0
	var/goldcost = 0
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			cmls = "Compact Ammo Boxes"
			C_M_L_S = "C"
		if(caliber == CALIBER_MEDIUM)
			cmls = "Medium Ammo Boxes"
			C_M_L_S = "M"
		if(caliber == CALIBER_LONG)
			cmls = "Long Ammo Boxes"
			C_M_L_S = "L"
		if(caliber == CALIBER_SHOTGUN)
			cmls = "Shotgun Ammo Boxes"
			C_M_L_S = "S"
	goldcost = round(rawcost / 100)
	silvercost = round((rawcost - (goldcost * 100)) / 10)
	coppercost = round(rawcost - (goldcost * 100) - (silvercost * 10))
	dat["Category"] = cmls
	dat["Name"] = "[name] Box ([C_M_L_S])"
	dat["Desc"] = flavor
	var/shorteneddesc = flavor
	if(LAZYLEN(shorteneddesc) > 100)
		shorteneddesc = copytext(shorteneddesc, 97) + "..."
	dat["ShortDesc"] = shorteneddesc
	dat["RawCost"] = rawcost
	dat["CopperCost"] = coppercost
	dat["SilverCost"] = silvercost
	dat["GoldCost"] = goldcost
	data_for_tgui["[smls]"] += list(dat)
	/// then, the crate
	dat = list()
	rawcost = SSCMLS.compact_ammo_price_per_crate
	coppercost = 0
	silvercost = 0
	goldcost = 0
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			cmls = "Compact Ammo Crates"
		if(caliber == CALIBER_MEDIUM)
			cmls = "Medium Ammo Crates"
		if(caliber == CALIBER_LONG)
			cmls = "Long Ammo Crates"
		if(caliber == CALIBER_SHOTGUN)
			cmls = "Shotgun Ammo Crates"
	goldcost = round(rawcost / 100)
	silvercost = round((rawcost - (goldcost * 100)) / 10)
	coppercost = round(rawcost - (goldcost * 100) - (silvercost * 10))
	dat["Category"] = cmls
	dat["Name"] = "[name] Crate ([C_M_L_S])"
	dat["Desc"] = flavor
	shorteneddesc = flavor
	if(LAZYLEN(shorteneddesc) > 100)
		shorteneddesc = copytext(shorteneddesc, 97) + "..."
	dat["ShortDesc"] = shorteneddesc
	dat["RawCost"] = rawcost
	dat["CopperCost"] = coppercost
	dat["SilverCost"] = silvercost
	dat["GoldCost"] = goldcost
	data_for_tgui["[smls]"] += list(dat)

/// For the lathe to build our ammo without having to make a million other datums, PAUL
/// generates boxes! It's a box generator!
/datum/ammo_kind/proc/GenerateAmmoTypeDesign()
	var/datum/design/ammolathe/amo = new()
	var/C_or_M_or_L_or_S = "???"
	var/compactorsuch = "???"
	switch(caliber)
		if(caliber == CALIBER_COMPACT)
			C_or_M_or_L_or_S = "C"
			compactorsuch = "Compact Ammo"
		if(caliber == CALIBER_MEDIUM)
			C_or_M_or_L_or_S = "M"
			compactorsuch = "Medium Ammo"
		if(caliber == CALIBER_LONG)
			C_or_M_or_L_or_S = "L"
			compactorsuch = "Long Ammo"
		if(caliber == CALIBER_SHOTGUN)
			C_or_M_or_L_or_S = "S"
			compactorsuch = "Shotgun Ammo"
	amo.name = "[GetBoxName()] ([C_or_M_or_L_or_S])"
	amo.id = ckey("[type]_[C_or_M_or_L_or_S]")
	amo.build_path = /obj/item/ammo_box/generic
	var/catbox = "[compactorsuch] Box"
	SSCMLS.design_cats |= catbox
	amo.category = list("initial", "[catbox]")
	amo.ammotype = type
	/// and a crate
	var/datum/design/ammolathe/amo_crate = new()
	amo_crate.name = "[GetBoxName()] Crate ([C_or_M_or_L_or_S])"
	amo_crate.id = ckey("[type]_[C_or_M_or_L_or_S]_crate")
	amo_crate.build_path = /obj/item/ammo_crate/generic
	var/catcrate = "[compactorsuch] Crate"
	amo_crate.category = list("initial", "[catcrate]")
	amo_crate.ammotype = type

/datum/ammo_kind/compact
	name = "Compact Bullet"
	flavor = "A small, compact bullet. It's small, it's compact, and it's a bullet. Back in 2235, the Compact Bullet was designed by \
		Dr. Compact, hero of the Compact Wars, to be the most compact bullet in the galaxy. The sheer compactness of its load complemented \
		its compact design, and it was called the Compact Bullet."
	caliber = CALIBER_COMPACT
	ammo_icon = 'icons/obj/ammo/compact.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/compact/q_9x19mm
	name = "9x19mm Parabellum"
	flavor = "A 9x19mm Parabellum bullet. It's a bullet, and it's 9x19mm. The 9x19mm Parabellum was designed in 1902 by Georg Luger, \
		who was a big fan of the number 9 and the number 1. He combined them into the famed 9x19mm Parabellum, named after his daughter, \
		Parabellum Luger. Often chastized for its lack of stopping power and unlucky number, the 9x19mm Parabellum is still a popular choice \
		for those who like the number 9 and 1."
	caliber = CALIBER_COMPACT
	ammo_icon = 'icons/obj/ammo/compact.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/medium
	name = "Medium Bullet"
	flavor = "A medium bullet. It's not too big, it's not too small, it's just right. The Medium Bullet was designed in 1945 by \
		Arbus Qcmarualsdnxz, world renouned party animal who stacked two compact bullets on top of each other and wondered what if \
		they were one bullet. And so, the Medium Bullet was born."
	caliber = CALIBER_MEDIUM
	ammo_icon = 'icons/obj/ammo/medium.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/medium/q_5_56x45mm
	name = "5.56x45mm NATO"
	flavor = "A 5.56x45mm NATO bullet. A classic bullet found literally anywhere that freedom rings. The 5.56x45mm NATO was designed in 1963 \
		by the Nash Alliance Treaty Organization, a group of wasteland settlements that banded together to fight off the hordes of mutants \
		and raiders. To simplify their production lines, they settled on the 5.56x45mm NATO, a bullet that was as easy to make as it was to \
		kill with. And so, the 5.56x45mm NATO was born."
	caliber = CALIBER_MEDIUM
	ammo_icon = 'icons/obj/ammo/medium.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/long
	name = "Long Bullet"
	flavor = "A long bullet. It's a bullet with a long body and an equally long history. The Long Bullet was originally a handy carrying \
		case for several Compact Bullets, put together as a clever way to recycle old worn out bullets without violating the 79th Amendment. \
		Partway through the Gecko Wars, a wayward enchanted Gecko ballista shell struck an ammo cart full of Compact Bullets, and in the blast \
		melted them all together into several Long Bullets. Now, they didnt have guns that would accept these new Long Bullets, but their \
		heavy, aerodynamic design made them more than a replacement for Ashdown's Tactical Rock Stockpile, and so the Long Bullet was born. \
		Shortly after, the 79th Amendment was repealed, allowing for Long Bullets to actually be used in guns."
	caliber = CALIBER_LONG
	ammo_icon = 'icons/obj/ammo/long.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/long/q_30_06_springfield
	name = ".30-06 Springfield"
	flavor = "A .30-06 Springfield bullet. A classic bullet found in the hands of hunters, soldiers, and the occasional madman. The .30-06 \
		Springfield refers to the date it was designed, Springfield 30th, 6, a good year for high power, low drag bullets. Few can resist the \
		temptation of the .30-06 Springfield, a bullet that has been used to take down everything from deer to tanks."
	caliber = CALIBER_LONG
	ammo_icon = 'icons/obj/ammo/long.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/shotgun
	name = "Shotgun Shell"
	flavor = "A shotgun shell. It's a large shell that emits a spray of smaller bullets. An unlikely creation by the Great Eastern Hiveblob, \
		the Shotgun Shell was designed as a gag for Their annual Hive Day celebration. 35 nodes of the Hiveblob merged and developed a line \
		of party favors for their non-hive guests, among them the Loop-de-Scoop, the Bouncing Bumble, and the Stacked Vixen. While the first \
		two were met with mild amusement, when the Stacked Vixen misfired and ejected its entire payload of Compact Bullets into the 'big bad \
		Queen of the North', it impressed Rusty, the CEO of Rustyville XII: A New Rust at the time, so much that he ordered a million of them. \
		After being rebranded as the 'Shoot-Gun Shell', the Shotgun Shell was born."
	caliber = CALIBER_SHOTGUN
	ammo_icon = 'icons/obj/ammo/shotgun.dmi'
	bullet_icon_state_prefix = "bullet"

/datum/ammo_kind/shotgun/q_12_gauge
	name = "12 Gauge"
	flavor = "A 12 Gauge shotgun shell. A classic shell found in the hands of hunters, soldiers, and the occasional madman. The 12 Gauge \
		shotgun shell was designed in 1874 by the Winchester Repeating Arms Company, a company that was known for its repeating arms and \
		its company. The 12 Gauge shotgun shell was designed to be a versatile shell that could be used for hunting, sport shooting, and \
		home defense. It was so versatile that it was used in the Winchester Model 1897, a shotgun that was so versatile that it was used \
		in the Winchester Model 1897."
	caliber = CALIBER_SHOTGUN
	ammo_icon = 'icons/obj/ammo/shotgun.dmi'
	bullet_icon_state_prefix = "bullet"



/// and a vending machine for the ammo, cus lathes are for chumps
/obj/structure/CMLS_ammo_vending_machine
	name = "Ammo Vending Machine"
	desc = "An Adventurer's Guild Port-A-Shop Ammo Vendor 2000, linked to the Guild's central armory (courtesey of the Great Eastern Hiveblob). \
		You can buy ammo boxes and crates here!"
	icon = 'icons/obj/ammo/vending_machine.dmi'
	icon_state = "vending_machine"
	max_integrity = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF

/obj/structure/CMLS_ammo_vending_machine/examine(mob/user)
	. = ..()
	. += "This machine is linked with your [span_notice("QuestBank account")], able to purchase things using the cash stored in your \
		[span_notice("Questbook")]. No need to insert coins! If you do try to insert coins, they'll instead be deposited into your \
		[span_notice("QuestBank account")]."
	. += "Ammunition is divided into four categories: [span_notice("Compact")], [span_notice("Medium")], [span_notice("Long")], and \
		[span_notice("Shotgun")]. This part is important, as it defines which guns they'll fit in."
	. += "In each category, there are a list of ammo types that you can purchase. The calibers and such are \
		[span_notice("cosmetic and largely interchangeable")], and can be changed to any other flavor of ammo within its C.M.L.S. category \
		at any time by [span_notice("Alt or Ctrl-Shift clicking")] on the ammo box or bullet."
	. += "Ammo that is loaded into a gun will be automatically converted to the gun's prefered flavor of ammo."

/obj/structure/CMLS_ammo_vending_machine/attackby(obj/item/I, mob/living/user, params, damage_override)
	. = ..()
	if(istype(I, /obj/item/stack/f13Cash))
		DepositCoinsToBank(user, I)

/obj/structure/CMLS_ammo_vending_machine/ui_act(action, params)
	. = ..()
	add_fingerprint(usr)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AmmoVendor2000", capitalize(src.name))
		ui.open()

/obj/structure/CMLS_ammo_vending_machine/ui_data(mob/user)
	. = ..()
	var/datum/quest_book/QB = SSeconomy.get_questbook(user)
	if(!QB)
		.["QBcash"] = "ERROR!!!"
	else
		.["QBcash"] = CREDITS_TO_COINS(QB.unclaimed_points)
	.["Username"] = user.real_name
	.["UserCkey"] = user.ckey

/obj/structure/CMLS_ammo_vending_machine/ui_static_data(mob/user)
	. = ..()
	. = SSCMLS.data_for_tgui

/obj/structure/CMLS_ammo_vending_machine/ui_act(action, params)
	. = ..()
	add_fingerprint(usr)
	. = TRUE
	var/mob/user = ckey2mob(params["UserCkey"]) // arguably better than usr
	if(!user)
		return
	if(action == "PurchaseAmmo")
		var/datum/ammo_kind/AK = SSCMLS.GetAmmoKind(text2path(params["DesiredAmmoKind"]))
		if(!istype(AK))
			to_chat(user, span_alert("That's not something for sale, I think?"))
			return
		PurchaseAmmo(user, AK, params["CrateOrBox"])

/obj/structure/CMLS_ammo_vending_machine/proc/PurchaseAmmo(mob/user, datum/ammo_kind/AK, CorB = "Box")
	if(!user || AK)
		return
	var/datum/quest_book/QB = SSeconomy.get_questbook(user)
	if(!QB)
		to_chat(user, span_alert("You don't have a Questbook! Wierd, cus everyone should have one. Maybe you lost it? Maybe contact an admin?"))
		return
	if(!CanAfford(QB, AK))
		to_chat(user, span_alert("You can't afford that ammo!"))
		return
	var/costus = CorB == "Box" ? AK.box_raw_cost : AK.crate_raw_cost
	QB.adjust_funds(COINS_TO_CREDITS(-costus), update_overall = TRUE)
	var/obj/item/ammo_box/generic/mag = new(get_turf(user))
	AK.SetupMag(mag, CorB)




/obj/structure/CMLS_ammo_vending_machine/proc/DepositCoinsToBank(mob/user, obj/item/stack/f13Cash/coinz)
	var/datum/quest_book/QB = SSeconomy.get_questbook(user)
	if(!QB)
		return
	QB.deposit_coins(coinz)







