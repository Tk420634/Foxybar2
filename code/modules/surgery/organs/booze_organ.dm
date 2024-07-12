/* 
 * File:   booze_organ.dm
 * Author: Dan "WildBill" Wilson
 * Date: 2019-09-15
 * License: QDWPL - See the QDWPL.txt file for more information
 * 
 * Purpose:
 * This file contains the code for the booze organ, which is a stand-in for your blood alcohol level.
 * It handles converting alcoholic drinks you drink into a value to adjust the owner's drunkenness variable.
 * 
 * So the way it works, every drinkable drink has a set of vars:
 * - Target Drunkenness: The amount of drunkenness that the drink will try to adjust your drunkenness to.
 *   For instance, light beer might have a target drunkenness of 15, while straight whiskey might have a target drunkenness of 50.
 * - Ideal Volume: The volume of the drink that will adjust your drunkenness to the target drunkenness at the target rate.
 *   For instance, a drink with a TD of 15 and a TV of 100 will adjust your drunkenness to 15 if you have 100 units of it drank
 *   at the target rate. If you have significantly more, it'll adjust your drunkenness above the TD instead of just hovering around it.
 * - Volume: The amount of the drink you have drank.
 *   This is used to calculate the drunkenness adjustment, as well as dilution to determine how the mixed drinks work.
 *   You can pound lots of hard liquor and get trashed, or take a shot of hard liquor and a shot of water and get a bit tipsy.
 * - Metabolization Rate: The rate at which the drink is processed by the booze organ.
 *   All the drinks drank will add their volumes and such on drink, and then leave them alone so they can still do whatever it is they do.
 * 
 * The rate of application of drunkenness, in a vacuum, is the Target Drunkenness divided by the Ideal Volume.
 * So, if you have a drink with a TD of 15 and a TV of 100, you'll get 0.15 drunkenness per unit of the drink drank.
 * And if it has a metabolization rate of 5, it will take 20 life ticks to endrunkenify you to 15 drunkenness.
 * 
 * On life, the booze organ will calculate the drunkenness adjustment based on the drinks you've drank, and adjust your drunkenness.
 * It will calculate this based on the owner's drunkenness, the proportion of the drink you've drank, and the target drunkenness of the drink.
 * It will also deplete all of the drinks by a percentage, so everything will reach 0 at the same time more or less.
 * The depletion rate is based on the weighted average of the metabolization rates of the drinks you've drank.
 * The calculations will take this into account, so if you have a tiny drink of something powerful with a high metabolization rate,
 * and a big drink of something weak with a low metabolization rate, they both will apply their proportional drunkenness adjustments.
 * 
 *  */


/obj/item/organ/blood_alcohol_processor
	name = "metaphysical embodiment of the concept of drunkenness"
	desc = "This 'sorta organ' isnt really an organ, but it's a stand-in for your blood alcohol level. Without this, you'd be sober as a judge."
	icon_state = "liver"
	w_class = WEIGHT_CLASS_NORMAL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_BAC
	color = "#FF00FF" // pank as hell

	maxHealth = 100000
	healing_factor = 100
	decay_factor = 0
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/iron = 5)

	/// drink datums
	/// format: list(/datum/reagent/thingidrank = /datum/boozedrink) // the first is a path, the second is an initialized datum
	var/list/drank = list()



/obj/item/organ/blood_alcohol_processor/on_life()
	. = ..()
	if(!. || !owner)//can't process reagents with a failing liver (but its a sodie organ)
		return
	var/healt = liquor_act()
	if(!healt)
		return

/obj/item/organ/blood_alcohol_processor/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!. || QDELETED(owner))
		return

/obj/item/organ/blood_alcohol_processor/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_CARBON_REAGENT_PRE_ADD,PROC_REF(bank_sauce))

/obj/item/organ/blood_alcohol_processor/Remove(special = FALSE)
	UnregisterSignal(owner, COMSIG_CARBON_REAGENT_PRE_ADD)
	return ..()

/obj/item/organ/blood_alcohol_processor/proc/bank_sauce(datum/source, datum/reagent/liquin, method = TOUCH, volin = 0) // hey, banksauce, michael here
	if(!owner || QDELETED(owner) || !istype(liquin) || volin <= 0) // no owner, no reagent, no volume, no
		return
	if(handle_special_case(liquin, volin)) // if it's a special case, handle it and return
		return // things like antihol, asprin, etc
	if(!istype(liquin, /datum/reagent/consumable) && !istype(liquin, /datum/reagent/water)) // only consumables and water count
		return
	var/datum/boozedrink/drink = get_drink(liquin)
	if(!drink)
		return
	drink.add_volume(volin)

/// the big belbeefer of the booze organ functionality
/obj/item/organ/blood_alcohol_processor/proc/liquor_act()
	if(!owner || QDELETED(owner))
		return 0
	var/owner_drunkenness = owner.drunkenness
	var/total_weight = 0
	var/total_metabolization_rate = 0
	var/target_drunkenness = 0
	var/ideal_volume = 0
	var/total_volume = 0
	for(var/drink in drank)
		if(drink && drink.volume > 0.05)
			total_weight += drink.weight
			total_metabolization_rate += drink.metabolization_rate
			target_drunkenness += drink.target_drunkenness * drink.volume
			ideal_volume += drink.ideal_volume
			total_volume += drink.volume







/datum/boozedrink
	var/target_drunkenness = 0
	var/ideal_volume = 0
	var/volume = 0
	var/metabolization_rate = 0
	var/weight = 1

/datum/boozedrink/New(datum/reagent/booz) // heres to us
	. = ..()
	if(istype(booz, /datum/reagent/consumable/ethanol))
		setup_liquor(booz)
	else if(istype(booz, /datum/reagent/consumable) || istype(booz, /datum/reagent/water))
		setup_nonliquor(booz)

/// We were passed an actual fair drinkum of the alcohol
/datum/boozedrink/proc/setup_liquor(datum/reagent/consumable/ethanol)
	if(!istype(ethanol))
		return // oops
	target_drunkenness = ethanol.booze_target_drunkenness
	ideal_volume = ethanol.booze_ideal_volume
	weight = ethanol.booze_weight
	metabolization_rate = ethanol.metabolization_rate

/// We were passed a non-alcoholic consumable, so just make stuff up from its foodability
/datum/boozedrink/proc/setup_nonliquor(datum/reagent/consumable/food)
	if(!istype(food))
		return // oops
	// target drunkenness is gonna be 0, because it's not alcohol
	target_drunkenness = 0
	// ideal volume is irrelevant, because it's not alcohol
	ideal_volume = 0
	// consumables have nutriment_factor, which we can use as its weight
	weight = (food.nutriment_factor / 8) // most foods have a nutriment factor of 15, so this will be 1.875ish
	// metabolization rate is the same as the food's metabolization rate, cus it has it
	metabolization_rate = food.metabolization_rate

/datum/boozedrink/proc/add_volume(v)
	volume += v

/datum/boozedrink/proc/deplete_by_mult(factor)
	volume *= factor






