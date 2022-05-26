local KEY_REWIND = "b"

local record = false
backwards = false -- Shared with c_core.lua
local backidx = 0
local oldmodel = 0

showrewindtxt = false -- shared with c_core.lua
local rewindtxtprogress = 0
local goup = true
local specplayer = nil

local prevx, prevy, prevz = 0, 0, 0

local gWarps = {}
local lastwarp = nil

local gData = {}

local lasttick = getTickCount()

addEvent("race:onRaceMapStart", true)
addEvent("race:onRaceMapStop", true)
addEvent("race:startRewindRecording", true)

addEvent("lobby:onPlayerJoinLobby")

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" or tp:find("Training") then
			gData = {}
			gWarps = {}
			record = true
			showrewindtxt = false
			oldmodel = 0
			setVehicleDamageProof(pVeh, false)
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function()
		gData = {}
		record = false
		backwards = false
		showrewindtxt = false
		gWarps = {}
		lastwarp = nil
		oldmodel = 0
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		record = false
		backwards = false
		showrewindtxt = false
		gWarps = {}
		lastwarp = nil
		oldmodel = 0
	end
)

addEventHandler("race:startRewindRecording", root, -- Used for when a player enters a gamemode
	function()
		gData = {}
		record = true
		showrewindtxt = false
		oldmodel = 0
	end
)

addEventHandler("onClientRender", root,
	function()
		if record then
			local state = getElementData(localPlayer, "state")
			if state == "alive" or state == "training" and pVeh then
				local modelid = getElementModel(pVeh)
				if modelid == 425 then return end -- Don't record hunter
				local x, y, z = getElementPosition(pVeh)
				if prevx == x and prevy == y and prevz == z then return end
				local health = getElementHealth(pVeh)
				if health <= 250 then return end
				local rx, ry, rz = getElementRotation(pVeh)
				local vx, vy, vz = getElementVelocity(pVeh)
				local avx, avy, avz = getElementAngularVelocity(pVeh)
				table.insert(gData, { modelid = modelid, x = x, y = y, z = z, rx = rx, ry = ry, rz = rz, vx = vx, vy = vy, vz = vz, avx = avx, avy = avy, avz = avz, health = health, nitro = { level = getVehicleNitroLevel(pVeh), active = isVehicleNitroActivated(pVeh) } })
				prevx = x
				prevy = y
				prevz = z
			end
		elseif backwards then
			local data = gData[backidx]
			if not data then return end
			table.remove(gData, backidx)
			setElementPosition(pVeh, data.x, data.y, data.z)
			setElementRotation(pVeh, data.rx, data.ry, data.rz)
			setVehicleEngineState(pVeh, true)
			if oldmodel ~= data.modelid then
				oldmodel = data.modelid
				setElementModel(pVeh, data.modelid)
			end
			if data.health == 1000 then
				fixVehicle(pVeh)
			else
				setElementHealth(pVeh, data.health)
			end
			if data.nitro.level then
				if not getVehicleNitroLevel(pVeh) then
					addVehicleUpgrade(pVeh, 1010)
				end
				setVehicleNitroLevel(pVeh, data.nitro.level)
			else
				removeVehicleUpgrade(pVeh, 1010)
			end
			setVehicleNitroActivated(pVeh, data.nitro.active)
			backidx = backidx - 1
			setTimer(setCameraTarget, 150, 1, localPlayer)
		end
		-- Travelling in time text
		if showrewindtxt then
			if goup then
				rewindtxtprogress = rewindtxtprogress + 0.1 > 1 and 1 or rewindtxtprogress + 0.1
				if rewindtxtprogress == 1 then
					goup = false
				end
			else
				rewindtxtprogress = rewindtxtprogress - 0.1 < 0 and 0 or rewindtxtprogress - 0.1
				if rewindtxtprogress == 0 then
					goup = true
				end
			end
			dxDrawText("Travelling in time..", 0, 0, sx, sy - 20, tocolor(255, 255, 255, 255 * rewindtxtprogress), 1.6, "roboto-medium", "center", "bottom")
		end
		if specplayer then
			dxDrawText(getPlayerName(specplayer), 0, 0, sx, sy - 80, tocolor(255, 255, 255, 255), 2, "roboto-medium", "center", "bottom", false, false, false, true)
		end
	end
)

addEventHandler("onClientKey", root,
	function(key, keystate)
		if guiGetInputMode() == "no_binds" then return end
		if not canpressB then return end
		if isChatBoxInputActive() then return end
		local tp = getElementData(localPlayer, "room_id")
		if tp == "Shooter" or tp == "OJ" then return end -- Don't bind shooter and OJ
		local state = getElementData(localPlayer, "state")
		if state == "dead" or state == "training" then
			if key == KEY_REWIND then
				if tp == "Race" then
					if keystate then
						respawnRace()
					end
				else
					if keystate then -- Player rewinding
						setElementData(localPlayer, "state", "training")
						backwards = true
						record = false
						backidx = #gData
						setElementFrozen(pVeh, false)
						showrewindtxt = true
						spectateStop()
						setVehicleDamageProof(pVeh, true)
						setElementInterior(pVeh, 0)
						if gData[backidx] then
							setElementModel(pVeh, gData[backidx].modelid)
						end
					else
						backwards = false
						record = true
						showrewindtxt = false
						setElementFrozen(pVeh, false)
						setVehicleDamageProof(pVeh, false)
						if gData[backidx] then
							setElementAngularVelocity(pVeh, gData[backidx].avx, gData[backidx].avy, gData[backidx].avz)
							setElementVelocity(pVeh, gData[backidx].vx, gData[backidx].vy, gData[backidx].vz)
							setElementModel(pVeh, gData[backidx].modelid)
						end
					--	spectateStop() -- Prevents bug if player presses B when he is on getCameraMatrix  (from dead)
					end
				end
			elseif key == "n" then
				if keystate then
					requestRespawn()
					gData = {}
				end
			end
		end
	end
)

addCommandHandler("fix",
	function(_, pos)
		if not isTraining() then return errorMsg() end
		fixVehicle(pVeh)
		addVehicleUpgrade(pVeh, 1010)
		playSoundFrontEnd(46)
		showNotificationToPlayer("Vehicle fixed & NOS added", "info")
	end
)

addCommandHandler("spec",
	function(_, name)
		if not isTraining() then return errorMsg() end
		if not name then
			setCameraTarget(localPlayer)
			gRaceUI.targetUI = pVeh
			setElementFrozen(pVeh, false)
			setElementData(localPlayer, "state", "training")
			specplayer = nil
		else
			local target = getPlayerFromPartialName(name)
			if target then
				if target == localPlayer then
					return outputChatBox("You can't spectate yourself", 255, 0, 0)
				end
				if getElementDimension(localPlayer) == getElementDimension(target) then
					setElementFrozen(pVeh, true)
					setCameraTarget(target)
					gRaceUI.targetUI = getPedOccupiedVehicle(target)
					setElementData(localPlayer, "state", "spectating")
					outputChatBox("Now spectating " ..getPlayerNameNoColor(target).. " - use /spec again to restore your camera", 255, 255, 255)
					specplayer = target
				else
					outputChatBox("The player is not on the same map as you.", 255, 0, 0)
				end
			else
				outputChatBox("Invalid player", 255, 0, 0)
			end
		end
	end
)

addCommandHandler("sw",
	function(_, pos)
		if not isTraining() then return errorMsg() end
		pos = pos and tonumber(pos) or pos
		if type(pos) ~= "number" or not pos then
			outputChatBox("Usage: sw [warp number]", 255, 255, 255, true)
			outputChatBox("You can use '/bind 1 sw 1' to automatically save a warp to slot 1 when pressing number '1' button", 255, 255, 255)
			return
		end
		local x, y, z = getElementPosition(pVeh)
		local rx, ry, rz = getElementRotation(pVeh)
		local vx, vy, vz = getElementVelocity(pVeh)
		local avx, avy, avz = getElementAngularVelocity(pVeh)
		gWarps[pos] = { x = x, y = y, z = z, rx = rx, ry = ry, rz = rz, vx = vx, vy = vy, vz = vz, avx = avx, avy = avy, avz = avz, modelid = getElementModel(pVeh) }
		showNotificationToPlayer("Warp saved to slot '" ..pos.. "'", "info")
		lastwarp = pos
	end
)

addCommandHandler("lw",
	function(_, pos)
		if not isTraining() then return errorMsg() end
		pos = pos and tonumber(pos) or pos
		if type(pos) ~= "number" or not pos then
			return outputChatBox("Usage: lw [warp number]", 255, 255, 255, true)
		end
		if not gWarps[pos] then
			return showNotificationToPlayer("That warp doesn't exist.", "error")
		end
		setElementPosition(pVeh, gWarps[pos].x, gWarps[pos].y, gWarps[pos].z)
		setElementRotation(pVeh, gWarps[pos].rx, gWarps[pos].ry, gWarps[pos].rz)
		setElementVelocity(pVeh, gWarps[pos].vx, gWarps[pos].vy, gWarps[pos].vz)
		setElementModel(pVeh, gWarps[pos].modelid)
		showNotificationToPlayer("Loaded warp slot '" ..pos.. "'", "info")
	end
)

addCommandHandler("dw",
	function(_, pos)
		if not isTraining() then return errorMsg() end
		pos = pos and tonumber(pos) or pos
		if type(pos) ~= "number" or not pos then
			return outputChatBox("Usage: dw [warp number]", 255, 255, 255, true)
		end
		if not gWarps[pos] then
			return showNotificationToPlayer("That warp doesn't exist.", "error")
		end
		gWarps[pos] = nil
		showNotificationToPlayer("Deleted warp slot '" ..pos.. "'", "info")
	end
)

function respawnTrainingPlayer() -- Used for 'training'
	setElementFrozen(pVeh, false)
	local warp = gWarps[lastwarp]
	if gWarps[lastwarp] then
		setElementPosition(pVeh, warp.x, warp.y, warp.z)
		setElementRotation(pVeh, warp.rx, warp.ry, warp.rz)
		fixVehicle(pVeh)
		addVehicleUpgrade(pVeh, 1010)
		setElementAlpha(pVeh, 150)
		setElementFrozen(pVeh, true)
		setElementModel(pVeh, warp.modelid)
		setVehicleEngineState(pVeh, true)
		setCameraTarget(localPlayer)
		setTimer(
			function()
				setElementFrozen(pVeh, false)
				setElementAlpha(pVeh, 255)
				setTimer(setElementAngularVelocity, 50, 1, pVeh, warp.avx, warp.avy, warp.avz)
				setTimer(setElementVelocity, 50, 1, pVeh, warp.vx, warp.vy, warp.vz)
			end
		, 1000, 1)
		showNotificationToPlayer("Spawning from last saved warp", "info")
	else
		loadPlayerSpawn()
	end
	lasttick = tick
	setElementData(localPlayer, "state", "training")
	gRaceUI.targetUI = pVeh
end

function respawnRace() -- used for 'Race' gamemode
	local idx = #gData - math.random(80, 120)
	local data = gData[idx]
	if not data then
		idx = math.ceil(#gData / 2)
		data = gData[idx]
	end
	if not data then
		return showNotificationToPlayer("You can't respawn", "error")
	end
	setElementPosition(pVeh, data.x, data.y, data.z)
	setElementRotation(pVeh, data.rx, data.ry, data.rz)
	setElementModel(pVeh, data.modelid)
	setCameraTarget(localPlayer)
	if data.health == 1000 then
		fixVehicle(pVeh)
	else
		setElementHealth(pVeh, data.health)
	end
	if data.nitro.level then
		addVehicleUpgrade(pVeh, 1010)
		setVehicleNitroLevel(pVeh, data.nitro.level)
	else
		removeVehicleUpgrade(pVeh, 1010)
	end
	setVehicleNitroActivated(pVeh, data.nitro.active)
	gData = {}
	setElementInterior(pVeh, 0)
	setTimer(
		function()
			if record then
				setElementFrozen(pVeh, false)
				setElementVelocity(pVeh, data.vx, data.vy, data.vz)
			end
		end
	, 1000, 1)
	setElementData(localPlayer, "state", "training")
	triggerEvent("race:onPlayerRespawn", localPlayer, getElementData(localPlayer, "room_id"))
	spectateStop()
	for i = idx, #gData do
		table.remove(gData, i)
	end
end

function isTraining()
	return getElementData(localPlayer, "room_id"):find("Training_S_", 1, true)
end