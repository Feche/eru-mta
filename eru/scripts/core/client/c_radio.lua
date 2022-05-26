local SHOW_BOX_DURATION = 20 -- 20 sec

local enabled = "radio"

local cRadio = 
{ 
	sound = nil, 
	radiourl = nil,
	showradiobox = false,
	title = "No song on queue",
	requestedby = "-",
	duration = 0,
	durationtick = getTickCount(),
	thumbnail = "files/img/misc/noicon.png",
	timer = nil,
	textwidth = math.floor(dxGetTextWidth("No song on queue", 1.2, "default-bold")),
	render = nil,
	sync = false,
	timepassed = 1,
	musicon = true,
	musictxtprogress = 0,
	musictxttick = getTickCount(),
	musicgoup = false,
	showqueue = false,
	showqueueprogress = 0,
	songqueue = {}
}

local cMusic =
{
	sound = nil,
	soundurl = nil
}

local width, height = 300, 80
local renderw, renderh = width - 64 - 10, 40
local x, y = sx - 320, sy - height - 15
local tx = 0
local offsty = height

addEvent("radio:playRadioSong", true)
addEvent("radio:updateClientSongQueue", true)

addEvent("login:onPlayerLoginEx")

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		cRadio.render = dxCreateRenderTarget(renderw, renderh, true)
		bindKey("num_0", "down", openMusicBox)
		bindKey("m", "down", toggleMusic)
		bindKey("ralt", "down", showMusicQueue)
	end
)

addEventHandler("login:onPlayerLoginEx", root,
	function()
		if not isElement(cRadio.sound) then
			triggerServerEvent("radio:onPlayerRequestSync", localPlayer)
		end
	end
)

addEventHandler("radio:playRadioSong", root,
	function(url, title, requestedby, thumbnail, duration, timepassed)
		if url == "stop" then
			if isElement(cRadio.sound) then
				stopSound(cRadio.sound)
			end
			if title then
				cRadio.title = "Loading next song"
				cRadio.requestedby = "Loading.."
				cRadio.textwidth = math.floor(dxGetTextWidth("Loading next song", 1.2, "default-bold"))
			else
				cRadio.title = "No song on queue"
				cRadio.requestedby = "-"
				cRadio.textwidth = math.floor(dxGetTextWidth("No song on queue", 1.2, "default-bold"))
			end
			cRadio.duration = 1
			cRadio.thumbnail = "files/img/misc/noicon.png"
		else
			cRadio.sound = playSound(url)
			cRadio.radiourl = url
			if cRadio.sound then
				showRadioSong(thumbnail, title, requestedby, duration)
				if timepassed then
					cRadio.durationtick = getTickCount() - timepassed
					cRadio.sync = true
					cRadio.timepassed = math.floor(timepassed / 1000)
				end
				if getEnabled() ~= "radio" then
					stopSound(cRadio.sound)
				end
			else
				outputChatBox("[RADIO] Error while trying to play song " ..title, 255, 0, 0)
			end
		end
	end
)

addEventHandler("radio:updateClientSongQueue", root,
	function(songqueue)
		cRadio.songqueue = songqueue
		outputDebugString("[RADIO] Received song queue update")
	end
)

addEventHandler("onClientSoundStream", root,
	function()
		if source == cRadio.sound then
			if cRadio.sync then
				setTimer(
					function()
						if setSoundPosition(cRadio.sound, cRadio.timepassed) then
							outputDebugString("[RADIO] Setting stream position on second " ..cRadio.timepassed)
						else
							outputDebugString("[RADIO] Could not set stream position on second " ..cRadio.timepassed)
						end
					end
				, 5000, 1)
			end
		end
	end
)

addEventHandler("onClientRender", root,
	function()
		dxSetRenderTarget(cRadio.render, true)
		local str = cRadio.title
		if cRadio.textwidth > renderw then
			tx = tx == -cRadio.textwidth and renderw + 5 or tx - 1
		else
			tx = 0
		end
		dxDrawText(str, tx + 5, 0, tx + cRadio.textwidth + 5, 50, -1, 1.2, "default-bold", "left", "center", true)
		dxSetRenderTarget()
		--
		if cRadio.showradiobox then
			if offsty ~= 0 then
				offsty = offsty == 0 and 0 or offsty - 1
			end
		else
			offsty = offsty > height + 15 and height + 15 or offsty + 1
		end
		if offsty == height + 15 then
			cRadio.showqueue = false
		end
		dxDrawRoundedRectangle(x, y + offsty, width, height, tocolor(0, 0, 0, 200), 10)
		if cRadio.thumbnail then
			local ww, hh, offy = 64, 64, 0
			if type(cRadio.thumbnail) == "string" then
				ww, hh = 64, 48
				offy = 7
			end
			dxDrawImage(x + 10, y + 8 + offsty + offy, ww, hh, cRadio.thumbnail)
		end
		local xx, yy = x + 64 + 10, y - 10 + offsty
		dxDrawImage(xx, yy, renderw, renderh, cRadio.render)
		dxDrawText(cRadio.requestedby, xx, yy + 38, xx + (width - 64 - 10), yy, -1, 1, "default", "center", "top", false, false, false, true)
		dxDrawRectangle(xx + 12, yy + 75, 200, 6, tocolor(255, 255, 255, 200)) -- Background
		local timepassed = getTickCount() - cRadio.durationtick
		if not isElement(cRadio.sound) then
			timepassed = 1
		end
		dxDrawRectangle(xx + 12, yy + 75, (timepassed / cRadio.duration) * 200, 6, tocolor(255, 165, 0, 255))
		timepassed = timepassed > cRadio.duration and cRadio.duration or timepassed
		dxDrawText(msToTimeStr(timepassed, true), xx + 12, yy + 60, xx + 200, yy + 40, -1, 1, "default-bold", "left")
		dxDrawText(msToTimeStr(cRadio.duration, true), xx + 12, yy + 60, xx + 212, yy + 40, -1, 1, "default-bold", "right")
		-- Queue
		if cRadio.showqueue then
			cRadio.showqueueprogress = cRadio.showqueueprogress + 0.08 > 1 and 1 or cRadio.showqueueprogress + 0.08
		else
			cRadio.showqueueprogress = cRadio.showqueueprogress - 0.08 < 0 and 0 or cRadio.showqueueprogress - 0.08
		end
		local idx = #cRadio.songqueue
		local h = (idx - 1) * 35
		local boxy = y + offsty - (h + 5)
		dxDrawRoundedRectangle(x, boxy, width, h, tocolor(0, 0, 0, 200 * cRadio.showqueueprogress), 10)
		for i = 1, idx - 1 do
			local offyy = ((i - 1) * 35)
			dxDrawText("- " ..cRadio.songqueue[i].title, x + 10, boxy + offyy + 2, x + width, y + offsty + offyy + 2, tocolor(255, 255, 255, 255 * cRadio.showqueueprogress), 1, "default-bold", "left", "top", true)
			dxDrawText("Requested by " ..cRadio.songqueue[i].requestedby ..(i == idx - 1 and " #FFFFFF- next to play" or ""), x + 10, boxy + offyy + 17, x + width, y + offsty + offyy + 17, tocolor(255, 255, 255, 255 * cRadio.showqueueprogress), 1, "default", "left", "top", false, false, false, true)
		end
		-- Song volume
		local song
		if getEnabled() == "radio" then
			song = cRadio.sound
		elseif getEnabled() == "mapsong" then
			song = cMusic.sound
		end
		if not cRadio.musicon then
			if isElement(song) then
				local volume = getSoundVolume(song)
				if volume > 0 then
					setSoundVolume(song, volume - 0.2)
				end
			end
		else
			if isElement(song) then
				local volume = getSoundVolume(song)
				if volume < 1 then
					setSoundVolume(song, volume + 0.2)
				end
			end
		end
		-- Text
		if cRadio.musicgoup then
			cRadio.musictxtprogress = cRadio.musictxtprogress + 0.08 > 1 and 1 or cRadio.musictxtprogress + 0.08
		else
			cRadio.musictxtprogress = cRadio.musictxtprogress - 0.08 < 0 and 0 or cRadio.musictxtprogress - 0.08
		end
		--
		if cRadio.musictxtprogress == 1 then
			if getTickCount() - cRadio.musictxttick >= 3000 then
				cRadio.musicgoup = false
			else
				cRadio.musicgoup = true
			end
		end
		--
		local str = "music " ..(cRadio.musicon and "#00FF00ON" or "#FF0000OFF")
		local size = interpolateBetween(0, 0, 0, 2, 0, 0, cRadio.musictxtprogress, "Linear")
		dxDrawText(str:gsub("#%x%x%x%x%x%x", ""), 4, 4, sx + 4, sy - 150 + 4, tocolor(0, 0, 0, 255), size, "bankgothic", "center", "bottom", false, false, false, false)
		dxDrawText(str, 0, 0, sx, sy - 150, -1, size, "bankgothic", "center", "bottom", false, false, false, true)
	end
)

function loadMapSong(soundurl)
	if getEnabled() == "mapsong" then
		if soundurl then
			cMusic.sound = playSound(soundurl)
			if not cRadio.musicon then
				setSoundVolume(cMusic.sound, 0)
			end
		end
	end
	cMusic.soundurl = soundurl
end

function stopMapSong()
	if getEnabled() == "mapsong" then
		if isElement(cMusic.sound) then
			stopSound(cMusic.sound)
			cMusic.soundurl = nil
		end
	end
end

function showRadioSong(thumbnail, title, requestedby, duration)
	cRadio.title = title
	cRadio.requestedby = requestedby
	cRadio.duration = duration * 1000
	if isElement(cRadio.thumbnail) then -- Destroy previous thumbnail, if there is
		stopSound(cRadio.thumbnail)
	end
	if thumbnail then -- Check if server sent the thumbnail
		cRadio.thumbnail = dxCreateTexture(thumbnail)
	else
		cRadio.thumbnail = "files/img/misc/noicon.png"
	end
	cRadio.durationtick = getTickCount()
	if getEnabled() == "radio" then
		if not cRadio.showradiobox then
			if cRadio.musicon then
				cRadio.showradiobox = true
				setSoundVolume(cRadio.sound, 1)
				cRadio.timer = setTimer(function() cRadio.showradiobox = false end, SHOW_BOX_DURATION * 1000, 1)
			else
				cRadio.showradiobox = false
				setSoundVolume(cRadio.sound, 0)
			end
		end
	end
	cRadio.textwidth = math.floor(dxGetTextWidth(title, 1.2, "default-bold"))
	tx = renderw + 5
end

function openMusicBox()
	if isTimer(cRadio.timer) then
		killTimer(cRadio.timer)
	end
	if getEnabled() == "radio" then
		cRadio.showradiobox = not cRadio.showradiobox
	end
end

function toggleMusic()
	cRadio.musicon = not cRadio.musicon
	cRadio.musictxttick = getTickCount()
	cRadio.musicgoup = true
end

---------

function setRadioEnabled()
	if isElement(cMusic.sound) then
		stopSound(cMusic.sound)
	end
	if cRadio.radiourl then
		cRadio.sound = playSound(cRadio.radiourl)
	end
	enabled = "radio"
	cRadio.musicon = true
end

function setMapSongEnabled()
	if isElement(cRadio.sound) then
		stopSound(cRadio.sound)
	end
	if cMusic.soundurl then
		cMusic.sound = playSound(cMusic.soundurl)
	end
	enabled = "mapsong"
	cRadio.musicon = true
	cRadio.showradiobox = false
end

function getEnabled()
	return enabled
end

function showMusicQueue()
	if cRadio.showradiobox then
		if (#cRadio.songqueue - 1) <= 0 then
			return showNotificationToPlayer("There are no songs on queue", "error")
		end
		cRadio.showqueue = not cRadio.showqueue
	end
end