local MAX_TIME = 600000 -- Max race duration (10 mins - in ms)
MAP_FOLDER = "6jS5ksjYAY" -- used for map songs -- Shared with s_training.lua
--local MAX_TIME = 10000 -- Max race duration (10 mins - in ms)

local startCountdownTimer = {}
gServerGamemodes = -- Shared with s_toptimes.lua
{
	["Deathmatch A"] = {},
	["Deathmatch B"] = {},
	["Oldschool A"] = {},
	["Oldschool B"] = {},
	["Destruction Derby A"] = {},
	["Destruction Derby B"] = {},
	["Training"] = {},
	["Race"] = {},
	["Shooter"] = {},
	["Hunter"] = {},
	["Trials"] = {},
	["OJ"] = {},
	["Freeroam"] = {}
}

gClientData = -- Shared with s_training.lua
{
	["Deathmatch A"] = {},
	["Deathmatch B"] = {},
	["Oldschool A"] = {},
	["Oldschool B"] = {},
	["Destruction Derby A"] = {},
	["Destruction Derby B"] = {},
	["Training"] = {},
	["Race"] = {},
	["Shooter"] = {},
	["Hunter"] = {},
	["Trials"] = {},
	["OJ"] = {},
	["Freeroam"] = {}
}

local gGamemodePlayers =
{
	["Deathmatch A"] = {},
	["Deathmatch B"] = {},
	["Oldschool A"] = {},
	["Oldschool B"] = {},
	["Destruction Derby A"] = {},
	["Destruction Derby B"] = {},
	["Training"] = {},
	["Race"] = {},
	["Shooter"] = {},
	["Hunter"] = {},
	["Trials"] = {},
	["OJ"] = {},
	["Freeroam"] = {}
}

local gElements = {}

pVeh = {}

local gDimensions =
{
	["Lobby"] = 0,
	["Deathmatch A"] = 1,
	["Deathmatch B"] = 2,
	["Oldschool A"] = 3,
	["Oldschool B"] = 4,
	["Destruction Derby A"] = 5,
	["Destruction Derby B"] = 6,
	["Training"] = 7,
	["Race"] = 8,
	["Shooter"] = 9,
	["Hunter"] = 10,
	["Trials"] = 11,
	["OJ"] = 12,
	["Freeroam"] = 13
}

addEvent("lobby:onClientClickLobbyGamemode", true)
addEvent("lobby:onPlayerJoinLobby", true)
addEvent("lobby:setMatrixOnServer", true)

addEvent("race:onClientRequestSpawn", true)
addEvent("race:onPlayerRequestKill", true)
addEvent("race:warpPedIntoVehicle", true)
addEvent("race:onPlayerReachHunter", true)

addEvent("race:onPlayerWin")
addEvent("race:onRaceMapStart")

addEventHandler("onResourceStart", resourceRoot,
	function()
		for i = 1, 10 do
			outputDebugString(" ")
		end
		outputDebugString("------------------ RACE SCRIPT STARTED ------------------")
		--
		for i = 1, 10 do
			outputChatBox(" ")
		end
		--
		local tick = getTickCount()
		local players = getElementsByType("player")
		for i = 1, #players do
			local source = players[i]
			pVeh[source] = createVehicle(411, math.random(50),  math.random(50), 5)
			setElementData(source, "veh", pVeh[source])
			setElementData(source, "room_id", "Joined")
			setElementData(source, "onlinetime", "0:00")
			setElementData(source, "training.owner", false)
		end
		setElementData(root, "maxplayers", getMaxPlayers())
		setElementData(root, "servername", getServerName())
		--
		gGamemodePlayers["Lobby"] = {}
		-- Gamemode states
		for id in pairs(gServerGamemodes) do
			setGamemodeState(id, "stopped")
			gGamemodePlayers[id] = {}
		end
		setServerPassword("")
		setGameType("beta v0.1")
		setMapName("www.eru-crew.com")
		setFPSLimit(51)
		startResource(getResourceFromName("scriptloader"))
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		stopResource(getResourceFromName("scriptloader"))
	end
)

addEventHandler("onPlayerJoin", root,
	function()	
		pVeh[source] = createVehicle(411, math.random(50), math.random(50), 5)
		setElementData(source, "veh", pVeh[source])
		setPlayerNametagShowing(source, false)
		setElementData(source, "playername", getPlayerName(source))
		setElementData(source, "onlinetime", "0:00")
		setElementData(source, "room_id", "Joined")
	end
)

addEventHandler("onPlayerQuit", root,
	function(quittp)
		local tp = getPlayerGamemode(source)
		destroyElement(pVeh[source]) 
		--
		removePlayerFromGamemode(source, tp)
		-- if map state is not set to map started
		if not tp:find("Training_S_", 1, true) then -- Training doesn't need checking
			local state = getGamemodeState(tp)
			if state == "map started" or state == "map finished" then
				handleRaceKill(source)
			else
				if getPlayerState(source) == "alive" then
					removeFromAlive(source, tp) -- Remove from alive
				end
			end
		end
		if tp ~= "Lobby" then
			-- Notification show
			triggerClientEventForGamemode(root, tp, "notification:showPlayerJoinLeaveGamemode", getPlayerName(source).. " #FFFFFFleft (" ..quittp.. ")", false)
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		local state = getPlayerState(source)
		if state == "garage" then return end
		local tp = getPlayerGamemode(source)
		setElementDimension(source, 0)
		setElementDimension(pVeh[source], 0)
		setElementFrozen(pVeh[source], true)
		--
		removePlayerFromGamemode(source, tp) -- Remove from the gamemode that he was playing
		if not tp:find("Training_S_", 1, true) then -- Training doesn't need checking
			local state = getGamemodeState(tp)
			if state == "map started" or state == "map finished" then
				handleRaceKill(source, true) -- Avoid spectate start
			else
				if getPlayerState(source) == "alive" then
					removeFromAlive(source, tp) -- Remove from alive
				end
			end
		end
		-- Notification show
		if tp ~= "Lobby" then
			triggerClientEventForGamemode(root, tp, "notification:showPlayerJoinLeaveGamemode", getPlayerName(source).. " #FFFFFFleft (lobby)", false)
		end
		--
		addPlayerToGamemode(source, "Lobby")
		setPlayerState(source, "lobby")
		--
		setElementData(source, "playername", getPlayerName(source))
		setElementPosition(pVeh[source], math.random(50), math.random(50), 5)
		spawnPlayer(source, getElementPosition(pVeh[source]))
	end
)

addEventHandler("onPlayerWasted", root,
	function()
		setTimer(
			function(source)
				if isElement(source) then
					local dimension = getElementDimension(pVeh[source])
					spawnPlayer(source, math.random(50), math.random(50), 5)
					setElementDimension(source, dimension)
					if dimension == getGamemodeDimension("Shooter") then -- Add delay to shooter, so shooter kill detector works
						setTimer(
							function()
								if isElement(pVeh[source]) then
									fixVehicle(pVeh[source])
								end
							end
						, 2000, 1)
					else
						fixVehicle(pVeh[source])
					end
				--	warpPedIntoVehicle(source, pVeh[source])
				end
			end
		, 50, 1, source)
	--	handleRaceKill(source, tp) -- called from client
	end
)

-- Player selects gamemode
addEventHandler("lobby:onClientClickLobbyGamemode", root,
	function(tp)
		triggerClientEvent(source, "lobby:onPlayerJoinGamemode", source, tp, (gClientData[tp].maxtime or 0) - (getTickCount() - (gServerGamemodes[tp].timelefttick or 0)), getTickCount() - (gServerGamemodes[tp].timepassedtick or 0), getGamemodeState(tp))
		triggerEvent("lobby:onPlayerJoinGamemode", source, tp)
		-- Set dimension according to gamemode clicked
		setElementDimension(source, getGamemodeDimension(tp))
		setElementDimension(pVeh[source], getGamemodeDimension(tp))
		removePlayerFromGamemode(source, "Lobby")
		addPlayerToGamemode(source, tp) -- Add the player to the new gamemode
		local state = getGamemodeState(tp)
		if state == "stopped" then -- If state is stopped, start new map
			startLobbyMap(tp)
		else -- Else sync data to client
			gClientData[tp].deathlist = {} -- bad code, re syncs everytime that a new player joins gamemode
			for i = 1, #gServerGamemodes[tp].deathlist do
				gClientData[tp].deathlist[i] = gServerGamemodes[tp].deathlist[i] -- Sync deathlist
			end
			triggerClientEvent(source, "race:loadRaceMap", source, gClientData[tp], tp, state)
		end
		-- Notification show
		triggerClientEventForGamemode(root, tp, "notification:showPlayerJoinLeaveGamemode", getPlayerName(source).. " #FFFFFFhas joined", true)
	--	showNotificationToPlayer(source, "Press L to go back to lobby", "info")
		outputChatBox("Hold L or F1 to return to lobby", source, 255, 255, 255, true)
		updateNextMapClient(tp, source)
	end
)

addEventHandler("race:onClientRequestSpawn", root,
	function()
		local tp = getPlayerGamemode(source)
		local state = getGamemodeState(tp)
		if tp == "Shooter" or tp:find("Destruction Derby") or tp == "Hunter" then
			if state == "map started" then
				setPlayerState(source, "joined")
				triggerClientEvent(source, "race:startRaceSpectate", source)
			else
				spawnRacePlayer(source, tp)
			end
		elseif tp == "OJ" then -- OJ
			if state == "map started" then
				setPlayerState(source, "joined")
				triggerClientEvent(source, "race:startRaceSpectate", source)
			else
				handleOJSpawn(source, gServerGamemodes[tp].spawnpoints) -- send data to s_oj.lua - handleOJSpawn calls back spawnRacePlayer
			end
		else -- DM, ODM, etc
 			spawnRacePlayer(source, tp)
		end
		local dimension = getElementDimension(source) -- For training maps
		setElementDimension(source, getGamemodeDimension(tp) or dimension)
		setElementDimension(pVeh[source], getGamemodeDimension(tp) or dimension)
		triggerEvent("race:onPlayerSpawning", source)
	--	triggerClientEvent(source, "race:onPlayerSpawning", source, tp) 
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		gServerGamemodes[tp].deathidx = #getGamemodeAlivePlayers(tp)
	end
)

addEventHandler("race:onPlayerReachHunter", root,
	function(tp)
		local state = getPlayerState(source)
		if not tp:find("Training_S_", 1, true) then
			if state == "training" then
				handleRaceKill(source)
			elseif state == "alive" then
				if #getGamemodeAlivePlayers(tp) == 1 then
					changeLobbyMap(tp)
				end
			end
		end
	end
)

addEventHandler("race:onPlayerWin", root,
	function(tp)
		local name = getPlayerName(source)
		setTimer(addToDeathlist, 500, 1, name, tp, true) -- Prevents bug, winner doesn't appear first if timer isn't set
		if getElementModel(pVeh[source]) == 425 then
			changeLobbyMap(tp)
		end
	end
)

addEventHandler("race:onPlayerRequestKill", root, 
	function()
		handleRaceKill(source) -- Client side because of chatbox input text
	end
)

addEventHandler("race:warpPedIntoVehicle", root,
	function()
		if isElement(pVeh[source]) then
			warpPedIntoVehicle(source, pVeh[source])
			outputDebugString("[RACE] Warping player '" ..getPlayerNameNoColor(source).. "' into vehicle '" ..getVehicleName(pVeh[source]).. "'")
		end
	end
)

addEventHandler("onElementModelChange", root,
	function()
		if getElementType(source) == "vehicle" then
			setTimer(
				function(source)
					if isElement(source) then
						for i = 0, 5 do
							setVehicleDoorState(source, i, 0)
						end
					end
				end
			, 100, 1, source)
		end
	end
)

function spawnRacePlayer(source, tp, spawnid)
	if not gServerGamemodes[tp] then return end
	local spawns = gServerGamemodes[tp].spawnpoints
	if #spawns == 0 then
		outputChatBox("[ERROR] Map has no spawnpoints, changing to a random map in 2 seconds..", root, 255, 0, 0)
		setTimer(changeLobbyMap, 2000, 1, tp)
		return
	end
	spawnid = spawnid and spawnid or math.random(#spawns)
	local spawn = spawns[spawnid]
	local modelid, x, y, z, rotx, roty, rotz = spawn.modelid, spawn.posx, spawn.posy, spawn.posz, spawn.rotx, spawn.roty, spawn.rotz
	spawnVehicle(pVeh[source], tonumber(x), tonumber(y), tonumber(z), tonumber(rotx) or 0, tonumber(roty) or 0, tonumber(rotz) or 0)
	setElementInterior(pVeh[source], 0)
	setElementModel(pVeh[source], modelid)
	fixVehicle(pVeh[source])
	removeVehicleUpgrade(pVeh[source], 1010)
	setVehicleOverrideLights(pVeh[source], 2)
	setElementFrozen(pVeh[source], true)
	setVehicleEngineState(pVeh[source], true)
	setVehicleDamageProof(pVeh[source], true)
	if getVehicleType(pVeh[source]) ~= "Helicopter" then
		toggleControl(source, "vehicle_secondary_fire", true)
	end
	--
	setElementPosition(source, x, y, z)
	setPedStat(source, 160, 1000)
	setPedStat(source, 229, 1000)
	setPedStat(source, 230, 1000)
	setElementHealth(source, 100)
--	setCameraTarget(source)
	-- Check if map is started, or not
	local state = getGamemodeState(tp)
	if state ~= "map started" and state ~= "map finished" then
		addToAlive(source, tp)
	else
		-- Player joins as 'training'
		setPlayerState(source, "training")
		setElementAlpha(pVeh[source], 150)
		setElementPosition(pVeh[source], x, y, z + 1)
		setTimer( -- Let player load objects
			function(source)
				if isElement(source) then
					setElementFrozen(pVeh[source], false)
					setElementAlpha(pVeh[source], 255)
					setVehicleDamageProof(pVeh[source], false)
				end
			end
			, 2000, 1, source) 
		triggerClientEvent(source, "race:startRewindRecording", source)
	end
	-- Clothes
	addPedClothes(source, "garageleg", "garagetr", 17)
	addPedClothes(source, "moto", "moto", 16)
	setPedStat(source, 23, 1000)
end

function handleRaceKill(source, fromlobby)
	local state = getPlayerState(source)
	if state == "alive" or state == "training" then
		local tp = getPlayerGamemode(source)
		local gamestate = getGamemodeState(tp)
		if gamestate == "map started" or gamestate == "map finished" then
			addPlayerDeath(source, tp)
			local oldstate = state -- Store state on variable since we are changing it below
			removeFromAlive(source, tp)
			setPlayerState(source, "dead")
			if #getGamemodeAlivePlayers(tp) == 0 then
				if #getGamemodePlayers(tp) > 0 then -- only change if there are players on gamemode
					changeLobbyMap(tp)
				end
			else
				if tp == "OJ" then
					handleOJKill(source)
				end
				if isElement(pVeh[source]) then -- checking to avoid errors when player disconnects
					local _, _, rotz = getElementRotation(pVeh[source])
					setElementRotation(pVeh[source], 0, 0, rotz)
				--	fixVehicle(pVeh[source])
					setElementFrozen(pVeh[source], true)
					setElementInterior(pVeh[source], 100) -- Hide vehicle from other players
					setElementModel(pVeh[source], 441)
					setElementPosition(source, math.random(50), math.random(50), 7)
					if not fromlobby then
						triggerClientEvent(source, "race:startRaceSpectate", source) -- avoid spectate start 
					end
				end
				if oldstate == "alive" then
					-- Deathlist
					triggerEvent("race:onPlayerDead", source, tp, gServerGamemodes[tp].deathidx)
					addToDeathlist(getPlayerName(source), tp)
				end
			end
		end
	end
end

---------------------------------- MAP CHANGE ----------------------------------

function startLobbyMap(tp)
	if #getGamemodePlayers(tp) == 0 then
		stopLobbyMap(tp)
		return outputDebugString("[RACE] startLobbyMap: aborting load because of no players on gamemode '" ..tp.. "'")
	end
	setGamemodeState(tp, "starting") 
	local resname, mapname = getNextMap(tp)
	-- This part is cloned in s_training.lua, make changes there too
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
	gServerGamemodes[tp].alive = {}
	gServerGamemodes[tp].deathlist = {}
	gServerGamemodes[tp].resname = resname
	gServerGamemodes[tp].mapname = mapname
	local tmp = getMapInfo(resname)
	local tt = getMapToptimes(resname)
	gServerGamemodes[tp].mapinfo = { mapname = mapname, likes = tmp.likes, dislikes = tmp.dislikes, timesplayed = tmp.timesplayed, toptimes = tt and #tt or 0, author = getResourceAuthor(resname) }
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
	gClientData[tp].maxtime = MAX_TIME
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
	triggerClientEventForGamemode(root, tp, "race:loadRaceMap", gClientData[tp], tp)
	updateNextMapClient(tp)
	if isTimer(startCountdownTimer[tp]) then
		killTimer(startCountdownTimer[tp])
	end
	triggerEvent("race:onRaceMapStarting", root, tp, resname)
	triggerClientEventForGamemode(root, tp, "race:onRaceMapStarting", tp, resname)
	startCountdownTimer[tp] = setTimer(
		function() 
			startRaceCountdown(tp) 
		end
	, 6000, 1) -- Cooldown, let players load the map
	outputDebugString("[RACE] startLobbyMap: starting '" ..tp.. "' map '" ..resname.. "'")
end

local changeLobbytimer = {}
function changeLobbyMap(tp)
	local resname = gServerGamemodes[tp].resname
	setTimer(
		function(resname)
			triggerClientEventForGamemode(root, tp, "race:onRaceMapStop", tp, resname)
		end
	, 500, 1, resname)
	triggerEvent("race:onRaceMapStop", root, tp, resname)
	function changeLobbyMap_internal(tp)
		if tp == "Lobby" then return end -- Do nothing for lobbie, map change not needeed xd
		outputDebugString("[RACE] changeLobbyMap: changing '" ..tp.. "' map..")
		-- Setting gamemode state
		setGamemodeState(tp, "changing map")
		-- Kill countdown timer
		if isTimer(gServerGamemodes[tp].countdowntimer) then 
			killTimer(gServerGamemodes[tp].countdowntimer)
		end
		-- Kill end race timer
		if isTimer(gServerGamemodes[tp].endracetimer) then
			killTimer(gServerGamemodes[tp].endracetimer)
		end
		startLobbyMap(tp)
	end
	if isTimer(changeLobbytimer[tp]) then
		killTimer(changeLobbytimer[tp])
	end
	changeLobbytimer[tp] = setTimer(changeLobbyMap_internal, 2200, 1, tp)
end

function stopLobbyMap(tp)
	if tp == "Lobby" then return end -- Lobby does not need map change
	if tp:find("Training_S_", 1, true) then  -- Training maps are handled on s_training.lua
		stopTraining(tp)
		return
	end 
	setGamemodeState(tp, "stopped")
	-- Kill countdown timer
	if isTimer(gServerGamemodes[tp].countdowntimer) then 
		killTimer(gServerGamemodes[tp].countdowntimer)
		triggerClientEventForGamemode(root, tp, "race:onClientCountdownUpdate", -1) -- Remove countdown
	end
	-- Kill end race timer
	if isTimer(gServerGamemodes[tp].endracetimer) then
		killTimer(gServerGamemodes[tp].endracetimer)
	end
	--
	local resname = gServerGamemodes[tp].resname
	setTimer(
		function(resname)
			triggerClientEventForGamemode(root, tp, "race:onRaceMapStop", tp, resname)
		end
	, 500, 1, resname)
	triggerEvent("race:onRaceMapStop", root, tp, resname)
	gServerGamemodes[tp] = {}
	outputDebugString("[RACE] stopLobbyMap: stopping '" ..tp.. "' map")
end

function startRaceCountdown(tp)
	if isTimer(gServerGamemodes[tp].countdowntimer) then 
		killTimer(gServerGamemodes[tp].countdowntimer) 
	end
	-- Setting gamemode state
	setGamemodeState(tp, "countdown")
	--
	local c_idx = 4
	gServerGamemodes[tp].countdowntimer = setTimer(
		function()
			c_idx = c_idx - 1
			triggerClientEventForGamemode(root, tp, "race:onClientCountdownUpdate", c_idx)
			if c_idx == 0 then
				-- Setting gamemode state
				setGamemodeState(tp, "map started") 
				gServerGamemodes[tp].timelefttick = getTickCount()
				gServerGamemodes[tp].timepassedtick = getTickCount()
				--
				triggerEvent("race:onRaceMapStart", root, tp) -- server
				local players = getGamemodePlayers(tp)
				for i = 1, #players do
					setElementFrozen(pVeh[players[i]], false)
					setElementFrozen(players[i], false)
					setVehicleDamageProof(pVeh[players[i]], false)
				--	warpPedIntoVehicle(players[i], pVeh[players[i]]) -- just in case..
					triggerClientEvent(players[i], "race:onRaceMapStart", players[i], tp)
				end
				if not tp:find("Training_S_", 1, true) then -- Training maps have infinite duration
					gServerGamemodes[tp].endracetimer = setTimer(finishTheRace, MAX_TIME, 1, tp)
				end
			elseif c_idx == -1 then
				killTimer(gServerGamemodes[tp].countdowntimer)
				triggerClientEventForGamemode(root, tp, "race:onClientCountdownUpdate", c_idx) -- allow 'GO' to render on client screen
			end
		end
	, 1000, 0)
end

function showNotificationToPlayer(to, text, tp)
	triggerClientEvent(to, "notification:showNotificationToPlayer", to, text, tp)
end

function setGamemodeTimeLeft(mins, tp)
	local newtime = mins * 60000
	killTimer(gServerGamemodes[tp].endracetimer) -- Kill previous timer
	gClientData[tp].maxtime = newtime
	gServerGamemodes[tp].timelefttick = getTickCount()
	gServerGamemodes[tp].endracetimer = setTimer(finishTheRace, newtime, 1, tp) -- Set the new timer
	triggerClientEventForGamemode(root, tp, "race:onTimeLeftUpdate", newtime)
end

function finishTheRace(tp)
	if tp == "OJ" then
		handleOJMapFinish()
	else
		changeLobbyMap(tp)
		showNotificationToGamemode("Time is over, changing map", tp, "warning")
	end
end

---------------------------------- UTILS ----------------------------------

function triggerClientEventForGamemode(to, tp, str, ...)
	local players = getGamemodePlayers(tp)
	if players then
		for i = 1, #players do
			triggerClientEvent(players[i], str, players[i], ...)
		end
	end
end

function outputChatBoxToGamemode(str, tp)
	local players = getGamemodePlayers(tp)
	if players then
		for i = 1, #players do
			outputChatBox(str, players[i], 255, 255, 255, true)
		end
	end
end

function showNotificationToGamemode(str, tp, notificationtp) -- Info, warning and error notification types
	local players = getGamemodePlayers(tp)
	for i = 1, #players do
		showNotificationToPlayer(players[i], str, notificationtp)
	end
end

function getPlayerGamemode(source)
	return getElementData(source, "room_id") or "Joined"
end

function getGamemodePlayers(tp)
	return gGamemodePlayers[tp]
end

function addPlayerToGamemode(source, tp)
	if not gGamemodePlayers[tp] then
		gGamemodePlayers[tp] = {}
	end
	gGamemodePlayers[tp][#gGamemodePlayers[tp] + 1] = source
	setElementData(source, "room_id", tp)
	setElementData(source, "state", "joining")
	outputDebugString("[LOBBY] addPlayerToGamemode: '" ..getPlayerNameNoColor(source).. "' joined '" ..tp.. "' gamemode")
end

function removePlayerFromGamemode(source, tp)
	if tp == "Joined" then return end
	for i = 1, #gGamemodePlayers[tp] do
		if gGamemodePlayers[tp][i] == source then	
			if (#gGamemodePlayers[tp] - 1) == 0 then
				-- If no players on current gamemode, stop the map
				stopLobbyMap(tp)
			end
			table.remove(gGamemodePlayers[tp], i)
			outputDebugString("[LOBBY] removePlayerFromGamemode: removed player '" ..getPlayerNameNoColor(source).. "' from '" ..tp.. "' gamemode")
			return
		end
	end
end

function getRaceCheckpoints()
	if not gServerGamemodes["Race"].checkpoints then return end
	return #gServerGamemodes["Race"].checkpoints
end

function getGamemodeResourceName(tp)
	if not gServerGamemodes[tp] then return end
	return gServerGamemodes[tp].resname
end

function setGamemodeState(tp, state)
	if not isElement(gElements[tp]) then
		gElements[tp] = createElement("Gamemode", tp)
	--	outputDebugString("[RACE] setGamemodeState: creating element for '" ..tp.. "'")
	end
	setElementData(gElements[tp], "room_state", state)
end

function deleteGamemode(tp)
	if isTimer(gServerGamemodes[tp].countdowntimer) then
		killTimer(gServerGamemodes[tp].countdowntimer)
	end
	destroyElement(gElements[tp])
	gElements[tp] = nil
	gServerGamemodes[tp] = nil
	outputDebugString("[RACE] deleteGamemode: deleted gamemode '" ..tp.. "'")
end

function getGamemodeState(tp)
	if tp == "Lobby" or tp == "Joined" then return end -- Ignore lobby & joined gameomdes
	if not isElement(gElements[tp]) then
		return outputDebugString("[RACE] getGamemodeState: error while getting gamemode state for '" ..tp.. "', element not created.")
	end
	return getElementData(gElements[tp], "room_state")
end

function setPlayerState(source, state)
	return setElementData(source, "state", state)
end

function getPlayerState(source, state)
	return getElementData(source, "state")
end

function getRaceTimePassed(tp)
	return getTickCount() - (gServerGamemodes[tp].timepassedtick or 0)
end

function addToAlive(source, tp)
	if tp:find("Training_S_", 1, true) then
		setPlayerState(source, "training")
	else
		local idx = #gServerGamemodes[tp].alive
		for i = 1, idx do
			if gServerGamemodes[tp].alive[i] == source then
				return
			end
		end
		-- Player is not in alive, add him
		gServerGamemodes[tp].alive[idx + 1] = source 
		setPlayerState(source, "alive")
	end
end

function removeFromAlive(source, tp)
	if tp == "Joined" or tp == "Lobby" then return end
	local idx = gServerGamemodes[tp].alive and #gServerGamemodes[tp].alive or 0
	for i = 1, idx do
		if gServerGamemodes[tp].alive[i] == source then
	---		outputDebugString("[RACE] removeFromAlive removed " ..getPlayerNameNoColor(gServerGamemodes[tp].alive[i]))
			table.remove(gServerGamemodes[tp].alive, i)
			if #gServerGamemodes[tp].alive == 1 then
				local gamestate = getGamemodeState(tp)
				if gamestate == "map started" then
					if tp == "OJ" then
						handleOJKill(gServerGamemodes[tp].alive[1], true)
					elseif tp ~= "Race" then
						triggerClientEventForGamemode(root, tp, "race:onPlayerWin", gServerGamemodes[tp].alive[1], getPlayerName(gServerGamemodes[tp].alive[1]))
						triggerEvent("race:onPlayerWin", gServerGamemodes[tp].alive[1], tp)
						setGamemodeState(tp, "map finished")
						if tp == "Shooter" or tp:find("Destruction Derby") or tp == "Hunter" then -- Map ends for shooter, hunter, dd
							changeLobbyMap(tp)
						end
					end
				end
			end
			return
		end
	end
end

function getGamemodeAlivePlayers(tp)
	return gServerGamemodes[tp].alive or {}
end

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function addToDeathlist(name, tp)
	if tp ~= "Race" then
		if gServerGamemodes[tp].deathidx > 0 then
			local str = gServerGamemodes[tp].deathidx.. ": " ..name
			triggerClientEventForGamemode(root, tp, "deathlist:addNameToDeathlist", str)
			table.insert(gServerGamemodes[tp].deathlist, str)
		end
		gServerGamemodes[tp].deathidx = gServerGamemodes[tp].deathidx and gServerGamemodes[tp].deathidx - 1 or 0
	end
end

function kickPlayerToLobby(source)
	triggerClientEvent(source, "lobby:kickPlayerToLobby", source)
end

_getPlayerName = getPlayerName
function getPlayerName(source)
	local pStats = getPlayerStats(source)
	if pStats then
		local team = getPlayerTeam(source)
		local r, g, b = 255, 255, 255
		if team then
			r, g, b = getTeamColor(team)
		end
		return RGBToHex(r, g, b).. "" ..pStats.player.name
	else
		return _getPlayerName(source)
	end
end

function getPlayerNameNoColor(source)
	return getPlayerName(source):gsub("#%x%x%x%x%x%x", "")
end

function RGBToHex(red, green, blue, alpha)
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

function getGamemodeDimension(tp)
	return gDimensions[tp]
end

function msToMinutesSeconds(ms)
	local s = math.floor(ms / 1000)
	local seconds = math.fmod(s, 60)
	local minutes = math.floor(s / 60)
	if minutes < 0 then minutes = 0 end
	if seconds < 0 then seconds = 0 end
	local str
	if minutes == 0 and seconds <= 30 then
		if #tostring(seconds) == 1 then
			seconds = "0" ..seconds
		end
		str = "#FF0000" ..minutes.. ":" ..seconds
	else
		if #tostring(seconds) == 1 then
			seconds = "0" ..seconds
		end
		str = minutes.. ":" ..seconds
	end
	return str
end

function GetFileExtension(url)
  return url:match("^.+(%..+)$")
end