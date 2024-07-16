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
	var/sound/playingsound = null
	var/list/songdata = list()
	var/soundchannel = 0

/obj/machinery/jukebox_online/on_attack_hand(mob/living/user, act_intent, unarmed_attack_flags)
	var/pwdoutput = world.shelleo("pwd")
	to_chat(user, pwdoutput[1] + pwdoutput[2] + pwdoutput[3])
	var/songinput = input(user, "Enter URL (supported sites only, leave blank to stop playing)", "Online Jukebox") as text|null
	if(isnull(songinput) || !length(songinput))
		stop = world.time + 100
	var/adminmessage = "<span class=\"admin\">[user.name] wants to play <a href=\"[songinput]\"></></span>"
	for(var/admin in GLOB.admins.Copy())
		to_chat(admin, adminmessage, confidential = TRUE)


/obj/machinery/jukebox_online/proc/parse_url(var/url)
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
		var/list/output = world.shelleo("[ytdl] --format \"bestaudio\" -P \"./config/jukebox_music/online\" --dump-single-json --no-playlist -- \"[shell_scrubbed_input]\"")
		var/errorlevel = output[SHELLEO_ERRORLEVEL]
		var/stdout = output[SHELLEO_STDOUT]
		//var/stderr = output[SHELLEO_STDERR]
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

/obj/machinery/jukebox_online/proc/it_begins()
	soundchannel = pick(SSjukeboxes.freejukeboxchannels)
	SSjukeboxes.freejukeboxchannels -= soundchannel
	var/soundtoplay = sound(file("config/jukebox_music/online/" + songdata[1][SONG_TITLE]))
	var/jukeboxturf = get_turf(src)

	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		if(!(M.client.prefs.toggles & SOUND_INSTRUMENTS) || !M.can_hear())
			M.stop_sound_channel(soundchannel)
			continue
		if(src.z == M.z)	//todo - expand this to work with mining planet z-levels when robust jukebox audio gets merged to master
			playingsound.status = SOUND_UPDATE
		else
			playingsound.status = SOUND_MUTE | SOUND_UPDATE	//Setting volume = 0 doesn't let the sound properties update at all, which is lame.

		M.playsound_local(jukeboxturf, null, 100, channel = soundchannel, S = soundtoplay)
		CHECK_TICK

/obj/machinery/jukebox_online/proc/its_over()

	playsound(src, 'sound/machines/terminal_off.ogg', 50, 1)
	SSjukeboxes.freejukeboxchannels += soundchannel

#undef SONG_TITLE
#undef SONG_START
#undef SONG_END
#undef SONG_URL
