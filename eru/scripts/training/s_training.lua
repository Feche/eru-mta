local START_DIMEN, END_DIMEN = 200, 1000

local gUsedDimensions = {}
local gPlayerTimeOnTraining = {}
local gCurrentTrainingMaps = {}

addEvent("training:onPlayerRequestSolo", true)

addEvent("lobby:onPlayerJoinLobby", true)

-- MAP CHANGE
addEventHandler("training:onPlayerRequestSolo", root,
	function(mapname)
		local tp = getPlayerGamemode(source)
		if tp:find("Training_S_") then -- Player is training, he is changing from map
			triggerClientEvent(source, "race:onRaceMapStop", source)
		end
		local resname = getResourceNameFromMapname(mapname)
		removePlayerFromGamemode(source, tp)
		if not gCurrentTrainingMaps[resname] then
			local dimension = getNewDimension()
			tp = "Training_S_" ..dimension
			setElementDimension(source, dimension)
			setElementDimension(pVeh[source], dimension)
			setGamemodeState(tp, "stopped")
			addPlayerToGamemode(source, tp)
			startTrainingMap(resname, mapname, tp, dimension)
			triggerClientEvent(source, "race:loadRaceMap", source, gClientData[tp], tp, dimension)
		else
			tp = gCurrentTrainingMaps[resname]
			local dimension = gServerGamemodes[tp].dimension
			setElementDimension(source, dimension)
			setElementDimension(pVeh[source], dimension)
			addPlayerToGamemode(source, tp)
			triggerClientEvent(source, "lobby:onPlayerJoinGamemode", source, tp, 0, 0, "map started")
			triggerClientEvent(source, "race:loadRaceMap", source, gClientData[tp], tp, dimension)
		end
		addPlayerMapsTrained(source)
		setPlayerState(source, "training")
		if not gPlayerTimeOnTraining[source] then
			gPlayerTimeOnTraining[source] = getTickCount()
		end	
	end
)

addEventHandler("onPlayerQuit", root,
	function(quittp)
		if gPlayerTimeOnTraining[source] then
			addPlayerTrainingTime(source, getTickCount() - gPlayerTimeOnTraining[source])
			gPlayerTimeOnTraining[source] = nil
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		if gPlayerTimeOnTraining[source] then
			addPlayerTrainingTime(source, getTickCount() - gPlayerTimeOnTraining[source])
			gPlayerTimeOnTraining[source] = nil
		end
	end
)

function startTrainingMap(resname, mapname, tp, dimension)
	gCurrentTrainingMaps[resname] = tp
	local tbl = loadMapFile(resname)
	gServerGamemodes[tp] = {}
	gServerGamemodes[tp].objects = tbl.objects
	gServerGamemodes[tp].removeobjects = tbl.removeobjects
	gServerGamemodes[tp].spawnpoints = tbl.spawnpoints
	gServerGamemodes[tp].pickups = tbl.pickups
	gServerGamemodes[tp].markers = tbl.markers
	gServerGamemodes[tp].vehicles = tbl.vehicles
	gServerGamemodes[tp].checkpoints = tbl.checkpoints
	gServerGamemodes[tp].sscripts = tbl.sscripts
	gServerGamemodes[tp].cscripts = tbl.cscripts
	gServerGamemodes[tp].files = tbl.files
	gServerGamemodes[tp].resname = resname
	gServerGamemodes[tp].mapname = mapname
	gServerGamemodes[tp].dimension = dimension
	setElementData(root, "gServerGamemodes", gServerGamemodes, false) -- shared with s_scriptloader.lua
	-- Data for the client
	gClientData[tp] = {}
	gClientData[tp].objects = tbl.objects
	gClientData[tp].removeobjects = tbl.removeobjects
	gClientData[tp].pickups = tbl.pickups
	gClientData[tp].markers = tbl.markers
	gClientData[tp].vehicles = tbl.vehicles
	gClientData[tp].checkpoints = tbl.checkpoints
	gClientData[tp].cscripts = tbl.cscripts
	gClientData[tp].deathlist = {}
	gClientData[tp].resname = resname
	gClientData[tp].mapname = mapname
	gClientData[tp].maxtime = 9999999
	gClientData[tp].songurl = nil
	gClientData[tp].mapinfo = gServerGamemodes[tp].mapinfo
	gClientData[tp].forecast = getResourceTimeWeather(resname)
	gClientData[tp].files = {} -- Files src for client to check
	for i = 1, #tbl.files do
		if not tbl.files[i].filesrc:find(".mp3") and not tbl.files[i].filesrc:find(".ogg") then -- Don't send music to clients
			gClientData[tp].files[i] = { filesrc = tbl.files[i].filesrc, md5 = tbl.files[i].md5 }
		else
			gClientData[tp].songurl = "http://192.171.18.139/" ..MAP_FOLDER.. "/maps/" ..getResourceCategory(resname).. "/" ..resname.. "/" ..tbl.files[i].filesrc
		end
	end
	--
	startRaceCountdown(tp)
	outputChatBox("--- Welcome to training mode ---", source, 255, 255, 255)
	outputChatBox("Use /sw [id] to save a warp", source, 255, 255, 255)
	outputChatBox("Use /lw [id] to load a warp", source, 255, 255, 255)
	outputChatBox("Use /dw [id] to delete a warp", source, 255, 255, 255)
	outputChatBox("Use /fix to fix your car and add NOS", source, 255, 255, 255)
	outputChatBox("Use /spec [name] to spectate a player", source, 255, 255, 255)
	outputChatBox("Press F2 to change the current map, or press L to go back to lobby", source, 255, 255, 255)
end

function stopTraining(tp) -- Called from s_core.lua
	for resname in pairs(gCurrentTrainingMaps) do
		if gCurrentTrainingMaps[resname] == tp then
			gCurrentTrainingMaps[resname] = nil
			break
		end
	end
	local dimension = tp:gsub("Training_S_", "")
	gUsedDimensions[dimension] = nil
	deleteGamemode(tp)
end

function getNewDimension()
	while true do
		local idx = math.random(START_DIMEN, END_DIMEN)
		if not gUsedDimensions[idx] then
			gUsedDimensions[idx] = true
			return idx
		end
	end
end