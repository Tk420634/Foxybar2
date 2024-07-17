/obj/effect/sound_emitter
	name = "sound emitter"
	desc = "Shh! Just pretend I'm a rock."
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	layer = MID_LANDMARK_LAYER
	invisibility = INVISIBILITY_ABSTRACT //This is what makes it unseeable
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// The looping sound it'll play forever.
	var/datum/looping_sound/snd
	/// If every sound rock with the same loop datum thing should sync their output sounds
	var/synchronize = TRUE

/obj/effect/sound_emitter/Initialize()
	. = ..()
	if(!ispath(snd))
		return
	if(synchronize)
		soundify()
	else
		unique_soundify()

/obj/effect/sound_emitter/Destroy()
	SSweather.remove_sound_rock(src, snd)
	if(istype(snd))
		QDEL_NULL(snd)
	..()

/obj/effect/sound_emitter/ex_act(severity) // if ratley nukes a pond, all the little critter in it are fuckin dead
	if(severity >= 3)
		return
	qdel(src)

/obj/effect/sound_emitter/proc/unique_soundify()
	if(!ispath(snd))
		return
	snd = new snd(list(src))
	snd.start()

/obj/effect/sound_emitter/proc/soundify(datum/looping_sound/override)
	if(ispath(override, /datum/looping_sound))
		SSweather.remove_sound_rock(src, snd)
		snd = override
	SSweather.add_sound_rock(src, snd) // yes, ssweather

/obj/effect/sound_emitter/debug
	name = "sound emitter (debug)"
	desc = "Hi, I'm a debug sound emitter. I'm here to help you debug your sound emitters. I'm not actually a sound emitter, though. I'm just a rock."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	invisibility = 0
	snd = /datum/looping_sound/ambient/debug3


/obj/effect/sound_emitter/frogs
	name = "sound emitter (frogs)"
	desc = "Sound emitter for frog noises, even if no frogs."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/frogs
	synchronize = FALSE

/obj/effect/sound_emitter/crows
	name = "sound emitter (crows)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/ambient/critters/birds/crow/louder
	synchronize = FALSE

/obj/effect/sound_emitter/birds
	name = "sound emitter (birds)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/ambient/critters/birds/louder
	synchronize = FALSE


/obj/effect/sound_emitter/creek
	name = "sound emitter (creek)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/creek
	synchronize = TRUE

//Foxybar Soundrocks//

/obj/effect/sound_emitter/foxybar/
	name = "sound emitter (creek)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar
	synchronize = TRUE

/datum/looping_sound/soundrock/foxybar
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds
	vary = TRUE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(15) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(70, 70)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/machines/glassclink.ogg', 1 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/clock
	name = "sound emitter (clock)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/clock
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/clock
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = TRUE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(5) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(4, 8)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/machines/clocktick.ogg', 1 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/hottub
	name = "sound emitter (hottub)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/hottub
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/hottub
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = TRUE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(9) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(10, 20)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/hottub.ogg', 4 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/computer
	name = "sound emitter (computer)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/computer
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/computer
	chance = 20 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = TRUE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(3) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(5, 8)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/effects/bootup.ogg', 5 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/ceilingfan
	name = "sound emitter (ceilingfan)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/ceilingfan
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/ceilingfan
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = FALSE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(10) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(80, 100)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/ceilingfan.ogg', 2 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/airconditioner
	name = "sound emitter (airconditioner)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/airconditioner
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/airconditioner
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = FALSE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(5) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(15, 15)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/airconditioner.ogg', 2.5 SECONDS, 1), //sound, how long it plays, weighted play 
		)

/obj/effect/sound_emitter/foxybar/machinery
	name = "sound emitter (machinery)"
	desc = "Sound emitter for some sort of noise."
	icon = 'modular_coyote/icons/objects/c13ammo.dmi'
	icon_state = "rock"
	snd = /datum/looping_sound/soundrock/foxybar/machinery
	synchronize = TRUE


/datum/looping_sound/soundrock/foxybar/machinery
	chance = 100 //% to play per time passing on the sound loop entry, in this case every 1 seconds.  If it doesn't get a true then it still uses the last played sounds time.
	vary = FALSE //wink wonk versus wInK wOnK
	extra_range = SOUND_DISTANCE(5) //flat out, this is 15 tiles from the sound rock itself
	volume = SOUND_LOOP_VOL_RANGE(25, 25)
	direct = FALSE 
	managed = FALSE //true = sound dies when you leave the area, must be direct to use. 
	loop_delay = 0
	mid_sounds = list(
		SOUND_LOOP_ENTRY('sound/machinery.ogg', 2.5 SECONDS, 1), //sound, how long it plays, weighted play 
		)

