#define ARCADE_WEIGHT_TRICK 4
#define ARCADE_WEIGHT_USELESS 2
#define ARCADE_WEIGHT_RARE 1
#define ARCADE_RATIO_PLUSH 0.20 // average 1 out of 6 wins is a plush.

/obj/machinery/computer/arcade
	name = "random arcade"
	desc = "random arcade machine"
	icon_state = "arcade"
	icon_keyboard = null
	icon_screen = "invaders"
	clockwork = TRUE //it'd look weird
	var/list/prizes = list(
		/obj/item/stack/f13Cash/random = ARCADE_WEIGHT_TRICK,
		/obj/item/stack/f13Cash/random = ARCADE_WEIGHT_USELESS,
		/obj/item/stack/f13Cash/random = ARCADE_WEIGHT_RARE,
	)
	connectable = FALSE

	light_color = LIGHT_COLOR_GREEN

/obj/machinery/computer/arcade/proc/Reset()
	return

/obj/machinery/computer/arcade/Initialize()
	. = ..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/list/gameodds = list(/obj/item/circuitboard/computer/arcade/battle = 33,
								/obj/item/circuitboard/computer/arcade/orion_trail = 33,
								)
		var/thegame = pickweight(gameodds)
		var/obj/item/circuitboard/CB = new thegame()
		var/obj/machinery/computer/arcade/A = new CB.build_path(loc, CB)
		A.setDir(dir)
		return INITIALIZE_HINT_QDEL
	//The below object acts as a spawner with a wide array of possible picks, most being uninspired references to past/current player characters.
	//Nevertheless, this keeps its ratio constant with the sum of all the others prizes.
	prizes[/obj/effect/spawner/lootdrop/plush] = counterlist_sum(prizes) * ARCADE_RATIO_PLUSH
	Reset()

/obj/machinery/computer/arcade/proc/prizevend(mob/user, list/rarity_classes)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "arcade", /datum/mood_event/arcade)

	if(!contents.len)
		var/list/toy_raffle
		if(rarity_classes)
			for(var/A in prizes)
				if(prizes[A] in rarity_classes)
					LAZYSET(toy_raffle, A, prizes[A])
		if(!toy_raffle)
			toy_raffle = prizes
		var/prizeselect = pickweight(toy_raffle)
		new prizeselect(src)

	var/atom/movable/prize = pick(contents)
	visible_message(span_notice("[src] dispenses [prize]!"), span_notice("I hear a chime and a clunk."))

	prize.forceMove(get_turf(src))

/obj/machinery/computer/arcade/emp_act(severity)
	. = ..()

	if(stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return

	var/empprize = null
	var/num_of_prizes = rand(round(severity/50),round(severity/100))
	for(var/i = num_of_prizes; i > 0; i--)
		empprize = pickweight(prizes)
		new empprize(loc)
	explosion(loc, -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)

/obj/machinery/computer/arcade/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/arcadeticket))
		var/obj/item/stack/arcadeticket/T = O
		var/amount = T.get_amount()
		if(amount <2)
			to_chat(user, span_warning("I need 2 tickets to claim a prize!"))
			return
		prizevend(user)
		T.pay_tickets()
		T.update_icon()
		O = T
		to_chat(user, span_notice("I turn in 2 tickets to the [src] and claim a prize!"))
		return
