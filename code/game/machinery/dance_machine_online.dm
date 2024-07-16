#define SONG_TITLE 1
#define SONG_START 2
#define SONG_END 3
#define SONG_URL 4


/obj/machinery/jukebox_online
	name = "Online Jukebox"
	desc = "A music player. This one has a massive selection."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "jukebox"
	verb_say = "intones"
	density = TRUE
	var/active = FALSE
	var/stop = 0
	var/volume = 70
	var/datum/sound/playingsound = null
	var/list/songdata = list()
	var/soundchannel = 0

/obj/machinery/jukebox_online/on_attack_hand(mob/living/user, act_intent, unarmed_attack_flags)
	


/obj/machinery/jukebox_online/parse_url(string/url)
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(src, span_boldwarning("yt-dlp was not configured, action unavailable")) //Check config.txt for the INVOKE_YOUTUBEDL value
		return FALSE
	if(length(url))
		url = trim(url)
		if(findtext(url, ":") && !findtext(url, GLOB.is_http_protocol))
			to_chat(src, span_boldwarning("Non-http(s) URIs are not allowed."))
			to_chat(src, span_warning("For yt-dlp shortcuts like ytsearch: please use the appropriate full url from the website."))
			return FALSE
		var/shell_scrubbed_input = shell_url_scrub(url)
		var/list/output = world.shelleo("[ytdl] --format \"bestaudio\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		var/stderr = output[SHELLEO_STDERR]
		if(!errorlevel)
			var/list/data
			try
				data = json_decode(stdout)
			catch(var/exception/e)
				to_chat(src, span_boldwarning("yt-dlp JSON parsing FAILED:"))
				to_chat(src, span_warning("[e]: [stdout]"))
				return FALSE

			if (data["url"])
				var/storeddata = list()
				storeddata[SONG_TITLE] = data["title"]
				storeddata[SONG_START] = data["start_time"]
				storeddata[SONG_END] = data["end_time"]
				storeddata[SONG_URL] = data["webpage_url"]
				songdata += storeddata

/obj/machinery/jukebox_online/it_begins()
	soundchannel = pick(SSjukeboxes.freejukeboxchannels)
	SSjukeboxes.freejukeboxchannels -= soundchannel



/obj/machinery/jukebox_online/its_over()

	playsound(src, 'sound/machines/terminal_off.ogg', 50, 1)

#undef SONG_TITLE
#undef SONG_START
#undef SONG_END
#undef SONG_URL
