/area/kf	
	name = "knottingham base area"
	icon = 'icons/turf/areas.dmi'
	icon_state = "kfbase"
	color = "#FFFFFF" 
	has_gravity = STANDARD_GRAVITY
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/kf/knottinghamtown
	name = "Knottingham Town"
	color = "#CCAA00"
	ambience_area = list()
	outdoors = 1
	open_space = 1
	blob_allowed = 0
	environment = 16
	weather_tags = list(WEATHER_SAFE)
	ambientmusic = list()

/area/kf/knottinghamforest
	name = "Knottingham Forest"
	color = "#009900"
	ambience_area = list(
		/datum/looping_sound/ambient/critters,
		/datum/looping_sound/ambient/swamp,
		/datum/looping_sound/ambient/critters/birds,
		/datum/looping_sound/ambient/critters/birds/two/birdharder,
		/datum/looping_sound/ambient/critters/birds/crow,
		/datum/looping_sound/ambient/forest,
		/datum/looping_sound/ambient/kf/forestmusic
						)
	outdoors = 1
	open_space = 1
	blob_allowed = 0
	environment = 15
	weather_tags = list(WEATHER_SAFE)
	ambientmusic = list()

/area/kf/knottinghamdungeon
	name = "Dungeon Level 0"
	color = "#800080"
	name = "Knottingham Town"
	color = "#CCAA00"
	ambience_area = list()
	blob_allowed = 0
	environment = 8
	ambientmusic = list()
