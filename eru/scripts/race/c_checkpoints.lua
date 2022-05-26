local RACE_DIMENSION = 4
CHECKPOINTS_TO_SHOW = 1

local gCheckpoints = {}
local checkIDX = 0
local position = 1

local totalcheckpoints = 1
local cprogress = 0
local pwidth, pheight = 400, 30
local currentw = 1
local oldidx = 0

local drawhandler = false

local myCheckpoints = {}

addEvent("race:onRaceMapStart", true)
addEvent("lobby:onPlayerJoinGamemode", true)

addEvent("race:onPlayerRespawn")
addEvent("race:onSpectateStart")
addEvent("race:onSpectateStop")

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Race" then
			if not drawhandler then	
				addEventHandler("onClientPreRender", root, drawRaceCheckpointData)
				drawhandler = true
			end
			setElementData(localPlayer, "check.idx", 0)
			setElementData(localPlayer, "rank", 1)
			checkIDX = 0
		end
	end
)

addEventHandler("lobby:onPlayerJoinGamemode", root,
	function(tp)
		if tp == "Race" then
			if not drawhandler then	
				addEventHandler("onClientPreRender", root, drawRaceCheckpointData)
				addEventHandler("onClientMarkerHit", root, checkCheckpointHit)
				drawhandler = true
				currentw = 1
				checkIDX = 0
				position = 1
				oldidx = 0
				setElementData(localPlayer, "check.idx", 0)
				setElementData(localPlayer, "rank", 1)
				gCheckpoints = {}
				myCheckpoints = {}
			end
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		removeEventHandler("onClientMarkerHit", root, checkCheckpointHit)
		currentw = 1
		checkIDX = 0
		position = 1
		oldidx = 0
		setElementData(localPlayer, "check.idx", 0)
		setElementData(localPlayer, "rank", 1)
		gCheckpoints = {}
		myCheckpoints = {}
	end
)

addEventHandler("race:onRaceMapStop", root,
	function()
		currentw = 1
		checkIDX = 0
		position = 1
		oldidx = 0
		setElementData(localPlayer, "check.idx", 0)
		setElementData(localPlayer, "rank", 1)
		gCheckpoints = {}
		myCheckpoints = {}
	end
)

addEventHandler("race:onPlayerRespawn", root,
	function(tp)
		if tp == "Race" then
			checkIDX = getElementData(localPlayer, "check.idx")
			position = getElementData(localPlayer, "rank")
			cprogress = 0
		end
	end
)

addEventHandler("race:onSpectateStart", root,
	function()
		if getElementData(localPlayer, "room_id") == "Race" then
			for i = 1, #gCheckpoints do
				myCheckpoints[i] = getElementDimension(gCheckpoints[i])
			end
			local spec, target = isSpectating()
			checkIDX = getElementData(target, "check.idx")
			oldidx = 0
			syncVisibleCheckpoints(checkIDX)
		end
	end
)

addEventHandler("race:onSpectateStop", root,
	function()
		if getElementDimension(localPlayer) == RACE_DIMENSION then
			for i = 1, #gCheckpoints do
				if isElement(gCheckpoints[i]) then
					setElementDimension(gCheckpoints[i], myCheckpoints[i])
				end
			end
		end
	end
)

function checkCheckpointHit(player, matchingdimension)
	if matchingdimension then
		if player == localPlayer then
			if source == gCheckpoints[checkIDX + 1] then
				cprogress = 0
				checkIDX = checkIDX + 1
				setElementDimension(source, 100)
				playSoundFrontEnd(43)
				if isElement(gCheckpoints[checkIDX + CHECKPOINTS_TO_SHOW]) then
					setElementDimension(gCheckpoints[checkIDX + CHECKPOINTS_TO_SHOW], RACE_DIMENSION)   
				end
				if checkIDX == #gCheckpoints then
					triggerServerEvent("race:checkForWinner", localPlayer)
					setElementData(localPlayer, "state", "finished")
				end
				setElementData(localPlayer, "check.idx", checkIDX)
				triggerServerEvent("race:onPlayerHitCheckpoint", localPlayer)
			else
				showNotificationToPlayer("You missed a checkpoint", "error")
			end
		end
	end
end

function drawRaceCheckpointData()
	local spec, target = isSpectating()
	if spec then
		checkIDX = getElementData(target, "check.idx")
		if checkIDX ~= oldidx then
			oldidx = checkIDX
			cprogress = 0
			syncVisibleCheckpoints(checkIDX)
		end
		position = getElementData(target, "rank")
	else
		position = getElementData(localPlayer, "state") == "alive" and getElementData(localPlayer, "rank") or "-"
	end
	if gRace.progress == 0 then
		removeEventHandler("onClientPreRender", root, drawRaceCheckpointData)
		drawhandler = false
	end
	cprogress = cprogress + 0.08 > 1 and 1 or cprogress + 0.08
	local scale = pwidth / (totalcheckpoints == 0 and 1 or totalcheckpoints)
	local y = interpolateBetween(sy + 36, 0, 0, sy - 41, 0, 0, gRace.progress, "Linear")
	local w = interpolateBetween(currentw, 0, 0, (scale * checkIDX) == 0 and 1 or (scale * checkIDX), 0, 0, cprogress, "Linear")
	if cprogress == 1 then
		currentw = w 
	end
	local x
	x = sx / 2 - pwidth / 2
	y = y + 10
	dxDrawRoundedRectangle(x, y, pwidth, pheight, tocolor(0, 0, 0, 150), 10)
	dxDrawRoundedRectangle(x + 5, y + 5, w - 10, pheight - 10, tocolor(253, 106, 2, 255), 10)
	local rank = type(position) == "number" and ((position < 10 or position > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[position % 10] or 'th') or position
	dxDrawText("Position: " ..position.. "" ..rank.. "\nCheckpoint: " ..checkIDX.. "/" ..totalcheckpoints, 0, 0, sx, sy - 38, tocolor(255, 255, 255, 255 * gRace.progress), 1.4, "roboto-bold", "center", "bottom")
end

function syncCheckpointsWithCore(checkpoints) -- Sent from race_c.lua
	gCheckpoints = checkpoints
	totalcheckpoints = #gCheckpoints
	for i = 1, #gCheckpoints do
		if gCheckpoints[i + 1] then
			setMarkerTarget(gCheckpoints[i], getElementPosition(gCheckpoints[i + 1]))
		end
	end
	if isElement(gCheckpoints[#gCheckpoints]) then -- Not all maps have checkpoints
		setMarkerIcon(gCheckpoints[#gCheckpoints], "finish") -- last checkpoint is the finish line
	end
end

function syncVisibleCheckpoints(idx) -- When player spectates another player, sync the checkpoints
	for i = 1, #gCheckpoints do -- Hide all checkpoints
		setElementDimension(gCheckpoints[i], 100)
	end
	--
	idx = idx == 0 and 1 or idx
	for i = idx + 1, idx + CHECKPOINTS_TO_SHOW do
		if isElement(gCheckpoints[i]) then
			setElementDimension(gCheckpoints[i], getElementDimension(localPlayer))
		end
	end
end