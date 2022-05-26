local cSpectate =
{
	handler = false,
	timer = nil,
	target = nil,
	targetPlayers = {},
	targetName = "",
	targetIDX = 1,
	progress = 0,
	goup = false,
	disableRespawn = false,
	oldSpectator = nil
}

addEvent("race:startRaceSpectate", true)
addEvent("race:onRaceMapStop", true)
addEvent("lobby:onPlayerJoinLobby", true)

addEventHandler("race:onRaceMapStop", root,
	function()
		spectateStop()
		setElementData(localPlayer, "spectators", 0)
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		spectateStop()
	end
)

function drawSpectate()
	local tp = getElementData(localPlayer, "room_id")
	if cSpectate.goup then
		cSpectate.progress = cSpectate.progress + 0.08 > 1 and 1 or cSpectate.progress + 0.08
	else
		cSpectate.progress = cSpectate.progress - 0.08 < 0 and 0 or cSpectate.progress - 0.08
		if cSpectate.progress == 0 then
			removeEventHandler("onClientRender", root, drawSpectate)
			cSpectate.handler = false
		end
	end
	local offst = tp == "Race" and 92 or 0
	dxDrawText(cSpectate.targetName, 0, 0, sx, sy - 80 - offst, tocolor(255, 255, 255, 255 * cSpectate.progress), 2, "roboto-medium", "center", "bottom", false, false, false, true)
	if not cSpectate.disableRespawn then
		if tp == "Race" then
			dxDrawText("Press #808080B #FFFFFFto respawn", 0, 0, sx, sy - offst, tocolor(255, 255, 255, 255 * cSpectate.progress), 1.6, "roboto", "center", "bottom", false, false, false, true)
		else
			dxDrawText("Hold #808080B #FFFFFFto rewind\nPress #808080N #FFFFFFto spawn from start", 0, 0, sx, sy - offst, tocolor(255, 255, 255, 255 * cSpectate.progress), 1.6, "roboto", "center", "bottom", false, false, false, true)
		end
	end
end

function spectateStart()
	gCamera.set = false
	local state = getElementData(localPlayer, "state")
--	if state ~= "dead" then return end -- Prevents bug
	if state == "lobby" then return end -- Prevents bug, from starting spectate if player joins lobby
	if not cSpectate.handler then
		addEventHandler("onClientRender", root, drawSpectate)
		cSpectate.handler = true
	end
	local tp = getElementData(localPlayer, "room_id")
	if tp == "Shooter" or tp == "OJ" or tp:find("Destruction Derby") or tp == "Hunter" then
		cSpectate.disableRespawn = true
	else
		cSpectate.disableRespawn = false
	end
	bindKey("arrow_l", "up", changeSpectateTarget)
	bindKey("arrow_r", "up", changeSpectateTarget)
--	bindKey("b", "up", requestRespawn)
	cSpectate.oldSpectator = nil
	cSpectate.progress = 0
	cSpectate.goup = true
	cSpectate.timer = setTimer(updateTargetPlayers, 500, 0)
	-- Pick random player
	updateTargetPlayers()
	setTimer(spectateSetRandomPlayer, 200, 1) -- Avoid explosion camera bug
	triggerEvent("race:onSpectateStart", localPlayer)
	setElementData(localPlayer, "spectators", 0)
--	setCameraInterior(0)
--	outputDebugString("[SPECTATE] Starting spectate..")
end
addEventHandler("race:startRaceSpectate", root, spectateStart) -- Called from server

function spectateStop()
	cSpectate.goup = false
	gRaceUI.targetUI = pVeh
	unbindKey("arrow_l", "up", changeSpectateTarget)
	unbindKey("arrow_r", "up", changeSpectateTarget)
--	unbindKey("b", "up", requestRespawn)
--	setCameraTarget(localPlayer)
	if isTimer(cSpectate.timer) then
		killTimer(cSpectate.timer)
	end
	triggerEvent("race:onSpectateStop", localPlayer) -- Used for race gamemode
--	outputDebugString("[SPECTATE] Stopping spectate..")
	if isElement(cSpectate.oldSpectator) then
		local spectators = getElementData(cSpectate.oldSpectator, "spectators")
		spectators = spectators - 1
		setElementData(cSpectate.oldSpectator, "spectators", spectators)
	end
	cSpectate.oldSpectator = nil
end

function isSpectating()
	return cSpectate.goup, cSpectate.target
end

function spectateSetRandomPlayer()
	if #cSpectate.targetPlayers > 0 then
		local rand = math.random(#cSpectate.targetPlayers)
		setCameraTarget(cSpectate.targetPlayers[rand].source)
		addSpectatorToPlayer(cSpectate.targetPlayers[rand].source)
		cSpectate.targetName = cSpectate.targetPlayers[rand].name
		cSpectate.target = cSpectate.targetPlayers[rand].source
		cSpectate.targetIDX = rand
	---	outputDebugString("[SPECTATE] Changing to random player")
	end
end

function updateTargetPlayers()
	cSpectate.targetPlayers = getGamemodeAlivePlayers()
	-- If current spectating player dies, spectate another random player
	if isElement(cSpectate.target) then 
		if getElementData(cSpectate.target, "state") ~= "alive" then
			spectateSetRandomPlayer()
		end
		gRaceUI.targetUI = getPedOccupiedVehicle(cSpectate.target) -- Update target ui (veh speed & health)
	end
end

function changeSpectateTarget(key)
	if #cSpectate.targetPlayers <= 1 then return end
	if key == "arrow_r" then -- Next
		cSpectate.targetIDX = cSpectate.targetIDX + 1
		if cSpectate.targetIDX > #cSpectate.targetPlayers then cSpectate.targetIDX = 1 end
	elseif key == "arrow_l" then -- Previous
		cSpectate.targetIDX = cSpectate.targetIDX - 1
		if cSpectate.targetIDX == 0 then cSpectate.targetIDX = #cSpectate.targetPlayers end
	end
	setCameraTarget(cSpectate.targetPlayers[cSpectate.targetIDX].source)
	addSpectatorToPlayer(cSpectate.targetPlayers[cSpectate.targetIDX].source)
	cSpectate.targetName = cSpectate.targetPlayers[cSpectate.targetIDX].name
	cSpectate.target = cSpectate.targetPlayers[cSpectate.targetIDX].source
--	outputDebugString("[SPECTATE] Changing target to '" ..cSpectate.targetName.. "'")
end

function addSpectatorToPlayer(source)
	if isElement(cSpectate.oldSpectator) then
		local spectators = getElementData(cSpectate.oldSpectator, "spectators")
		spectators = spectators - 1
		setElementData(cSpectate.oldSpectator, "spectators", spectators)
	end
	local spectators = getElementData(source, "spectators")
	spectators = spectators + 1
	setElementData(source, "spectators", spectators)
	cSpectate.oldSpectator = source
end

function requestRespawn() -- Players presses N key
	spectateStop()
	loadPlayerSpawn()
	triggerEvent("race:onPlayerRespawn", localPlayer, getElementData(localPlayer, "room_id"))
end