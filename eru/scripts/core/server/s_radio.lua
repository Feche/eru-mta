local API_KEY = "AIzaSyDg9TDhzWE1GCU4jlj1tTduCwGbIh9rTlE" -- Google API key
local TOKEN = "1Grpo0DE9C0KlGPTYlKAVKDRFSjJhiWQ" -- ALSO CHANGE IN fetch.php
local SERVER_CACHE_FOLDER = "c7Dwu7KFCFNgyW" -- ALSO CHANGE IN fetch.php

local MIN_DURATION = 60 -- 60 seconds
local MAX_DURATION = 15 -- 15 minutes
local MAX_SONG_QUEUE = 5 -- 5 songs in queue

local songQueue = {}
local songQClient = {}

addEvent("radio:onPlayerRequestSong", true)
addEvent("radio:onPlayerRequestSync", true)

addEventHandler("radio:onPlayerRequestSong", root,
	function(videoid)
		if isSongOnQueue(videoid) then
			showNotificationToPlayer(source, "Song is already on queue", "error")
			return
		end
		if #songQueue <= MAX_SONG_QUEUE then
			fetchRemote("https://www.googleapis.com/youtube/v3/videos?id=" ..videoid.. "&key=" ..API_KEY.. "&part=snippet,contentDetails", getVideoDuration, "", false, source, videoid)
			showNotificationToPlayer(source, "Processing song, please wait..", "warning")
		else
			showNotificationToPlayer(source, "Song queue is full, please try again later", "error")
		end
	end
)

addEventHandler("radio:onPlayerRequestSync", root,
	function()
		if songQueue[1] then
			triggerClientEvent(source, "radio:playRadioSong", source, "http://192.171.18.139/" ..SERVER_CACHE_FOLDER.. "/song.webm", songQueue[1].title, "Song requested by " ..songQueue[1].requestedby, songQueue[1].thumbnail, songQueue[1].duration, getTickCount() - songQueue[1].starttick)
			updateClientSoundQueueInfo(source)
		end
	end
)

function getVideoDuration(data, _, source, videoid)
	data = fromJSON(data)
	local duration = data.items[1].contentDetails.duration:gsub("PT", "")
	local title = data.items[1].snippet.localized.title
	--[[local catid = tonumber(data.items[1].snippet.categoryId)
	outputDebugString("[RADIO] Video '" ..title.. "' category id is " ..catid)
	if catid ~= 10 then
		return showNotificationToPlayer(source, "Only songs are allowed", "error")
	end]]
	local _, countm = duration:find("M")
	if not countm then
		return  showNotificationToPlayer(source, "Song minimum duration is 1 minute", "error")
	end
	local minutes = duration:sub(1, countm - 1)
	local _, counts = duration:find("S")
	local seconds = 0
	minutes = tonumber(minutes)
	if counts and minutes > 1 then
		seconds = duration:sub(countm + 1, counts - 1)
		seconds = tonumber(seconds)
	end
	local duration = (minutes * 60) + seconds
	if duration <= MAX_DURATION * 60 then
		table.insert(songQueue, { title = title, videoid = videoid, duration = duration, starttick = 0, requestedby = getPlayerName(source), isdownloading = false, thumbnail = nil })
		checkSongQueue()
		if #songQueue > 1 then
			showNotificationToPlayer(source, "The song has been added to queue", "warning")
			updateClientSoundQueueInfo()
		else
			setTimer(showNotificationToPlayer, 2500, 1, source, "Song playing", "info")
		end
		triggerClientEvent(source, "radio:onPlayerAddSongToRadio", source)
	else
		showNotificationToPlayer(source, "The song exceeds the maximum duration (6 mins)", "error")
	end
end

function checkSongQueue()
	if not songQueue[1] then return end
	if songQueue[1].starttick == 0 then
		if not songQueue[1].isdownloading then
			fetchRemote("https://img.youtube.com/vi/" ..songQueue[1].videoid.. "/0.jpg", "default", 10, 15000, downloadThumbnail, "", false, songQueue[1].videoid)
			fetchRemote("http://192.171.18.139/" ..SERVER_CACHE_FOLDER.. "/fetch.php?videourl=https://www.youtube.com/watch?v=" ..songQueue[1].videoid.. "&token=" ..TOKEN, "default", 10, 15000, downloadSong, "", false, source, title, requestedby, duration, songQueue[1].videoid)
			outputDebugString("[RADIO] Requesting server to download song '" ..songQueue[1].title.. "'")
			songQueue[1].isdownloading = true
		end
		return
	end
	if math.floor((getTickCount() - songQueue[1].starttick) / 1000) >= songQueue[1].duration then
		stopCurrentSong()
	end
end
setTimer(checkSongQueue, 2000, 0)

function skipCurrentSong(source)
	if songQueue[1] then
		stopCurrentSong()
		outputChatBox("Current song has been removed by " ..getPlayerNameNoColor(source), root, 255, 255, 0)
	else
		outputChatBox("There are no songs on queue", source, 255, 0, 0)
	end
end
addCommandHandler("removesong", skipCurrentSong)

function downloadSong(data, response, source, title, requestedby, duration, videoid)
	if songQueue[1].videoid ~= videoid then return end -- Check if sended info is from current song (it may had been removed by admin)
	if response == 0 then
		updateClientSoundQueueInfo()
		if songQueue[1] then
			outputDebugString("[RADIO] Song downloaded, sending to clients..")
			triggerClientEvent(root, "radio:playRadioSong", root, "http://192.171.18.139/" ..SERVER_CACHE_FOLDER.. "/song.webm", songQueue[1].title, "Song requested by " ..songQueue[1].requestedby, songQueue[1].thumbnail, songQueue[1].duration)
			songQueue[1].starttick = getTickCount()
		end
	else
		table.remove(songQueue, 1)
		updateClientSoundQueueInfo()
		outputChatBox("There was an error while getting the song, please show this code to administrators if the problem persists [ERROR = #" ..response.. "]", source, 255, 255, 0)
	end
end

function downloadThumbnail(data, response, videoid)
	if response == 0 then
		songQueue[1].thumbnail = data
	else
		songQueue[1].thumbnail = nil
		outputDebugString("[RADIO] Could not load thumbnail for video " ..videoid.. ", error " ..response)
	end
end

function stopCurrentSong()
	table.remove(songQueue, 1)
	triggerClientEvent(root, "radio:playRadioSong", root, "stop", #songQueue >= 1 and true or false)
	updateClientSoundQueueInfo()
end

function updateClientSoundQueueInfo(source)
	if source then
		triggerClientEvent(source, "radio:updateClientSongQueue", source, songQClient)
	else
		songQClient = {}
		for i = 1, #songQueue do
			table.insert(songQClient, 1, { title = songQueue[i].title, requestedby = songQueue[i].requestedby })
		end
		triggerClientEvent(root, "radio:updateClientSongQueue", root, songQClient)
	end
end

function isSongOnQueue(videoid)
	for i = 1, #songQueue do
		if songQueue[i].videoid == videoid then
			return true
		end
	end
	return false
end