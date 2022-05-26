sx, sy = guiGetScreenSize()
local SECONDS_OFFSET = 5000

local mapLoaded = false
local mapDestroyed = false
local pickupRot = 0
local gPickups = {}
local gMarkers = {}
local camFaded = false

pVeh = nil -- Shared with c_rewind.lua
canpressB = true -- Shared with c_rewind.lua

local mapInfo = 
{
	progress = 0,
	show = false,
	mapname = "",
	timesplayed = "",
	toptimes = "",
	likes = "",
	diskiles = "",
	author = ""
}

local cCountdown = 
{
	countdown = 3,
	countdownTick = 0,
	handler = false,
	progress = 0,
	goup = true,
	timers = {}
}

gRace =
{
	timeLeftTick = 0,
	timePassed = 0,
	timePassedTick = 0,
	timeLeft = 0,
	raceStarted = false,
	progress = 0,
	hurryUpProgress = 0,
	hurryUpUp = false
}

gRaceUI =
{
	enabled = true,
	height = 0,
	targetUI = nil,
	oldHealth = 0,
	healthProgress = 0,
	oldNOS = 0,
	nosProgress = 0,
	mapName = "",
	nextMap = nil
}

local gRadar =
{
	masktexture = nil,
	texture = nil,
	shader = nil
}

gCamera = 
{
	set = false,
	matrix = {}
}

addEvent("race:loadRaceMap", true)
addEvent("race:onRaceMapStop", true)
addEvent("race:onClientCountdownUpdate", true)
addEvent("race:onRaceMapStart", true)
addEvent("race:onTimeLeftUpdate", true)

addEvent("race:updateNextMap", true)

addEvent("lobby:onPlayerJoinGamemode", true)
addEvent("lobby:onPlayerJoinLobby")

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		local g_ModelForPickupType = { nitro = 2221, repair = 2222, vehiclechange = 2223 }
		for name, id in pairs(g_ModelForPickupType) do
			engineImportTXD(engineLoadTXD("files/models/" ..name.. ".txd"), id)
			engineReplaceModel(engineLoadDFF("files/models/" ..name.. ".dff", id), id)
		end
		setCameraClip(false, false)
		setBlurLevel(0)
		toggleControl("enter_exit", false)
		bindKey("enter", "down", handleRaceKill)
	--	bindKey("f", "down", handleRaceKill)
		setTimer(disableCollisions, 100, 0)
		--
		setAmbientSoundEnabled("general", false)
		setAmbientSoundEnabled("gunfire", false)
		-- RIMS --
		-- 1025
		local txd = engineLoadTXD("files/wheels/J2_wheels.txd")
		engineImportTXD(txd, 1025)
		local dff = engineLoadDFF("files/wheels/wheel_or1.dff", 0)
		engineReplaceModel(dff, 1025)
		-- 1073
		dff = engineLoadDFF("files/wheels/wheel_sr6.dff", 0)
		engineReplaceModel(dff, 1073)
		-- 1074
		dff = engineLoadDFF("files/wheels/wheel_sr3.dff", 0)
		engineReplaceModel(dff, 1074)
		-- 1075
		dff = engineLoadDFF("files/wheels/wheel_sr2.dff", 0)
		engineReplaceModel(dff, 1075)
		-- 1076
		dff = engineLoadDFF("files/wheels/wheel_lr4.dff", 0)
		engineReplaceModel(dff, 1076)
		-- 1077
		dff = engineLoadDFF("files/wheels/wheel_lr1.dff", 0)
		engineReplaceModel(dff, 1077)
		-- 1078
		dff = engineLoadDFF("files/wheels/wheel_lr3.dff", 0)
		engineReplaceModel(dff, 1078)
		-- 1079
		dff = engineLoadDFF("files/wheels/wheel_sr1.dff", 0)
		engineReplaceModel(dff, 1079)
		-- 1080
		dff = engineLoadDFF("files/wheels/wheel_sr5.dff", 0)
		engineReplaceModel(dff, 1080)
		-- 1081
		dff = engineLoadDFF("files/wheels/wheel_sr4.dff", 0)
		engineReplaceModel(dff, 1081)
		-- 1082
		dff = engineLoadDFF("files/wheels/wheel_gn1.dff", 0)
		engineReplaceModel(dff, 1082)
		-- 1083
		dff = engineLoadDFF("files/wheels/wheel_lr2.dff", 0)
		engineReplaceModel(dff, 1083)
		-- 1084
		dff = engineLoadDFF("files/wheels/wheel_lr5.dff", 0)
		engineReplaceModel(dff, 1084)
		-- 1085
		dff = engineLoadDFF("files/wheels/wheel_gn2.dff", 0)
		engineReplaceModel(dff, 1085)
		-- 1096
		dff = engineLoadDFF("files/wheels/wheel_gn3.dff", 0)
		engineReplaceModel(dff, 1096)
		-- 1097
		dff = engineLoadDFF("files/wheels/wheel_gn4.dff", 0)
		engineReplaceModel(dff, 1097)
		-- 1098
		dff = engineLoadDFF("files/wheels/wheel_gn5.dff", 0)
		engineReplaceModel(dff, 1098)
		--
		txd = engineLoadTXD("files/infernus/mod.txd", 411)
		engineImportTXD(txd, 411)
		dff = engineLoadDFF("files/infernus/mod.dff", 411)
		engineReplaceModel(dff, 411)
		--
		setElementData(localPlayer, "spectators", 0)
		-- Radar
		gRadar.masktexture = dxCreateTexture("files/img/radar/circle_mask.png")
		gRadar.texture = dxCreateTexture("files/img/radar/radar.jpg")
		gRadar.shader = dxCreateShader("files/shaders/radar/hud_mask.fx")
		dxSetShaderValue(gRadar.shader, "sPicTexture", gRadar.texture)
		dxSetShaderValue(gRadar.shader, "sMaskTexture", gRadar.masktexture)
		-- Disable clouds
		local cloudshader = dxCreateShader("files/shaders/neon/default.fx")
		local texture = dxCreateRenderTarget(1, 1, true)
		dxSetShaderValue(cloudshader, "gTexture", texture)
		engineApplyShaderToWorldTexture(cloudshader, "cloud*")
		-- Disable radio
		setRadioChannel(0) 
		addEventHandler("onClientPlayerRadioSwitch", root, function() cancelEvent() end) 
	end
)

addEventHandler("race:loadRaceMap", root,
	function(data, tp, state)
		-- Client side functions that must NOT be always executed go here (these can be altered by map settings)
		setMinuteDuration(600000) -- 10 minutes = 1 ingame minute
		setTime(22, 0)
		setWeather(0)
		setWaveHeight(0)
		setCloudsEnabled(false)
		--
		loadRaceMap(data, tp)
		loadMapSong(data.songurl)
		--
		gRaceUI.mapName = data.mapname and data.mapname or "???"
		if state ~= "map started" and state ~= "map finished" then
			gRace.timeLeft = data.maxtime
		else
			setTimer(function() mapInfo.show = false end, 5000, 1)
		end
		fadeCameraEx(true)
		-- Map info data
		if data.mapinfo then
			mapInfo.mapname = data.mapinfo.mapname
			mapInfo.timesplayed = data.mapinfo.timesplayed
			mapInfo.likes = data.mapinfo.likes
			mapInfo.dislikes = data.mapinfo.dislikes
			mapInfo.toptimes = data.mapinfo.toptimes
			mapInfo.author = data.mapinfo.author
			mapInfo.show = true
		end
		-- Client side functions that must be ALWAYS executed go here
		setPedCanBeKnockedOffBike(localPlayer, false)
	end
)

addEventHandler("race:onRaceMapStart", root,
	function()
		clearDeathList()
		gRace.raceStarted = true
		gRace.timeLeftTick = getTickCount()
		gRace.timePassedTick = getTickCount()
		gRace.timePassed = 0
		showDeathlist(true)
		mapInfo.show = false
		setElementData(localPlayer, "spectators", 0)
	end
)

addEventHandler("race:onRaceMapStop", root,
	function()
		stopMapSong()
		destroyRaceMap()
		fadeCameraEx(false)
		gRace.raceStarted = false
		setCameraMatrix(getCameraMatrix()) -- Freeze camera
		showDeathlist(false)
		setElementFrozen(pVeh, true)
		mapInfo.show = false
		stopCountdown()
		gRaceUI.mapName = ""
		gRaceUI.nextMap = ""
		showBlackWhite()
	end
)

addEventHandler("race:onClientCountdownUpdate", root,
	function(update)
		if not cCountdown.handler then
			addEventHandler("onClientRender", root, drawCountdown)
			cCountdown.handler = true
		end
		if update > 0 then
			playSoundFrontEnd(44)
		elseif update == 0 then
			playSoundFrontEnd(45)
		end
		cCountdown.countdown = update
		cCountdown.progress = update == -1 and 1 or 0
		cCountdown.goup = update == -1 and false or true
	end
)

addEventHandler("race:onTimeLeftUpdate", root,
	function(newtime)
		gRace.timeLeft = newtime
		gRace.timeLeftTick = getTickCount()
	end
)

addEventHandler("race:updateNextMap", root,
	function(mapname)
		if gRaceUI.nextMap == mapname then return end
		gRaceUI.nextMap = mapname
	end
)

addEventHandler("onClientRender", root,
	function()
		-- Map info
		if mapInfo.show then
			mapInfo.progress = mapInfo.progress + 0.08 > 1 and 1 or mapInfo.progress + 0.08
		else
			mapInfo.progress = mapInfo.progress - 0.08 < 0 and 0 or mapInfo.progress - 0.08
		end
		if mapInfo.progress > 0 then
			dxDrawText(mapInfo.mapname, 0, 0, sx, sy - 115, tocolor(255, 165, 0, 255 * mapInfo.progress), 1.4, "roboto-bold", "center", "bottom")
			dxDrawText(mapInfo.timesplayed.. " times played\n" ..mapInfo.toptimes.. " toptimes\n" ..mapInfo.likes.. " likes - " ..mapInfo.dislikes.. " dislikes\nAuthor is " ..mapInfo.author, 0, 0, sx, sy - 30, tocolor(255, 255, 255, 255 * mapInfo.progress), 1.4, "roboto-medium", "center", "bottom")
		end
		-- Pickup rotation and vehicle name
		pickupRot = pickupRot + 1 > 360 and 0 or pickupRot + 4
		for i = 1, #gPickups do
			if gPickups[i].text then
				if isElement(pVeh) then
					local dist = getDistanceBetweenPoints3D(gPickups[i].x, gPickups[i].y, gPickups[i].z, getElementPosition(pVeh))
					if dist <= 35 then
						local x, y = getScreenFromWorldPosition(gPickups[i].x, gPickups[i].y, gPickups[i].z + 1)
						if x and y then
							local alpha = 255 - (dist * 7)
							alpha = alpha < 35 and 35 or alpha
							dxDrawText(gPickups[i].text, x, y, x, y, tocolor(255, 255, 255, alpha), 1.2, "roboto-medium", "center", "center")
						end
					end
				end
			end
			setElementRotation(gPickups[i].obj, 0, 0, pickupRot)
		end
		-- Draw nametags
		if camFaded then -- Draw only if screen is faded out
			local players = getElementsByType("player", root, true) -- Draw only streamed players
			for i = 1, #players do
				local state = getElementData(players[i], "state")
				if players[i] ~= localPlayer then 
					if state == "alive" or state == "training" then -- Draw nametag only if player is alive or training
						local veh = getPedOccupiedVehicle(players[i])
						local source = veh and veh or players[i]
						if getElementInterior(source) == 0 then
							local x, y, z = getElementPosition(source)
							local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer))
							if dist <= 45 then
								x, y = getScreenFromWorldPosition(x, y, z + 1.2)
								if x then
									x = math.floor(x)
									y = math.floor(y)
									local alpha = 255 - (dist * 4.8)
									dxDrawText(getPlayerNameNoColor(players[i]), x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, alpha), 1.4, "roboto-bold", "center", "center")
									dxDrawText(getPlayerName(players[i]), x, y, x, y, tocolor(255, 255, 255, alpha), 1.4, "roboto-bold", "center", "center", false, false, false, true)
								end
							end
						end
					end
				end
			end
		end
		local timeleft = gRace.timeLeft - (getTickCount() - gRace.timeLeftTick)
		-- Hurry up text
		local tp = getElementData(localPlayer, "room_id")
		if not tp:find("Training_S_", 1, true) then
			local state = getElementData(localPlayer, "state")
			if timeleft <= 30000 and gRace.raceStarted and (state == "alive" or state == "training") then
				if gRace.hurryUpUp then
					gRace.hurryUpProgress = gRace.hurryUpProgress + 0.04 > 1 and 1 or gRace.hurryUpProgress + 0.04
					if gRace.hurryUpProgress == 1 then
						gRace.hurryUpUp = false
					end
				else
					gRace.hurryUpProgress = gRace.hurryUpProgress - 0.04 < 0 and 0 or gRace.hurryUpProgress - 0.04
					if gRace.hurryUpProgress == 0 then
						gRace.hurryUpUp = true
					end
				end
				local size = interpolateBetween(1, 0, 0, 2, 0, 0, gRace.hurryUpProgress, "Linear")
				dxDrawText("Hurry up!", 0, 0, sx, sy - 150, tocolor(255, 0, 0, 255), size, "bankgothic", "center", "bottom")
			end
		end
		if not gRaceUI.enabled then return end -- If raceui is disabled, don't draw
		-- Draw time passed
		local x = sx / 2
		local y = 0
		local str = nil
		if gRace.raceStarted then
			gRace.progress = gRace.progress + 0.06 > 1 and 1 or gRace.progress + 0.06
		else
			gRace.progress = gRace.progress - 0.06 < 0 and 0 or gRace.progress - 0.06
		end
	--	y = interpolateBetween(-height, 0, 0, y, 0, 0, gRace.progress, "Linear")
		local timepassed = (getTickCount() - gRace.timePassedTick) + gRace.timePassed
		if gRace.raceStarted then
			if gRace.timeLeft == 9999999 then
				str = msToTimeStr(timepassed)
			else
				str = msToTimeStr(timepassed).. " - " ..msToMinutesSeconds(timeleft)
			end
		end
		drawMapRectangle(x, y, str, 3)
		if not isElement(gRaceUI.targetUI) then -- Check if target is an element or warnings shows up
			gRaceUI.targetUI = getElementData(localPlayer, "veh")
		end 
		-- Draw race UI
		-- Map name
		drawMapRectangle(-1, sy - 30, gRaceUI.mapName, 1)
		-- Next map
		local progress = drawMapRectangle(-1, sy - 58, gRaceUI.nextMap, 2)
		-- Radar
		local posx = 5
		local height = sx > 1360 and 236 or 216
		posx = interpolateBetween(-height - 10, 0, 0, posx, 0, 0, gRace.progress, "Linear") 
		local posy = sy - height - 35 + interpolateBetween(0, 0, 0, -30, 0, 0, progress or 0, "Linear")
		local centerleft = posx + height / 2
		local centertop = posy + height / 2
		local blipsize = height / 16
		local lpsize = height / 10
		local a = 255
		-- Draw localPlayer position
		local x, y = getElementPosition(gRaceUI.targetUI)
		x = x / 6000
		y = y / -6000
		-- Rotate to camera direction
		local _, _, camrot = getElementRotation(getCamera())
		dxSetShaderValue(gRadar.shader, "gUVRotAngle", math.rad(-camrot))
		local dimension = getElementDimension(localPlayer)
		local aceleration = 0
		if dimension == 8 or dimension == 13 then -- Race and freeroam has minimap activated
			dxDrawImage(posx, posy, height, height, gRadar.shader, 0, 0, 0, tocolor(255, 255, 255, 230))
			aceleration = getVehicleVelocity(gRaceUI.targetUI, true)
			aceleration = aceleration > 0.1 and 0.1 or aceleration
		else
			dxDrawImage(posx, posy, height, height, "files/img/radar/background.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		end
		local zoom = 0.08 + aceleration
		dxSetShaderValue(gRadar.shader, "gUVPosition", x, y)
		dxSetShaderValue(gRadar.shader, "gUVScale", zoom, zoom)
		local range = (230 / 0.08) * zoom
		-- NOS
		local vehnos = getVehicleNitroLevel(gRaceUI.targetUI) or 0
		if gRaceUI.oldNOS ~= vehnos then
			gRaceUI.nosProgress = gRaceUI.nosProgress + 0.04 > 1 and 1 or gRaceUI.nosProgress + 0.04
			if gRaceUI.nosProgress == 1 then
				gRaceUI.oldNOS = vehnos
				gRaceUI.nosProgress = 0
			end
		end
		local nos = interpolateBetween(gRaceUI.oldNOS, 0, 0, vehnos, 0, 0, gRaceUI.nosProgress, "Linear")
		drawCircleProgress(posx - 2, posy - 4, height + 4, height + 8, nos * 100, 180, 360, { 0, 76, 152 }) -- drawCircleProgress(x, y, w, h, percent, startangle, endangle, r, g, b, a)
		-- Health
		local vehhealth = (getElementHealth(gRaceUI.targetUI) - 250) / 750
		vehhealth = vehhealth < 0 and 0 or vehhealth
		if gRaceUI.oldHealth ~= vehhealth then
			gRaceUI.healthProgress = gRaceUI.healthProgress + 0.04 > 1 and 1 or gRaceUI.healthProgress + 0.04
			if gRaceUI.healthProgress == 1 then
				gRaceUI.oldHealth = vehhealth
				gRaceUI.healthProgress = 0
			end
		end
		local health = interpolateBetween(gRaceUI.oldHealth, 0, 0, vehhealth, 0, 0, gRaceUI.healthProgress, "Linear")
		drawCircleProgress(posx + 2, posy - 4, height + 4, height + 8, health * 100, 180, 0, { 206, 107, 3 }) -- drawCircleProgress(x, y, w, h, percent, startangle, endangle, r, g, b, a)
		-- Vehicle speed
		local x = interpolateBetween(70, 0, 0, 0, 0, 0, gRace.progress, "Linear") + 5
		local speed = getVehicleSpeed(gRaceUI.targetUI)
		dxDrawText(speed, 0 - 45 + x + 1, 0 + 1, sx - 55 + x + 1, sy - 30 + 1, tocolor(0, 0, 0, 255), 1.8, "roboto-medium", "right", "bottom")
		dxDrawText(speed, 0 - 45 + x, 0, sx - 55 + x, sy - 30, tocolor(255, 255, 255, 255), 1.8, "roboto-medium", "right", "bottom")
		dxDrawText("km/h", 0 - 50 + x + 1, 0 + 1, sx - 5 + x + 1, sy - 32 + 1, tocolor(0, 0, 0, 255), 1.4, "roboto-medium", "right", "bottom")
		dxDrawText("km/h", 0 - 50 + x, 0, sx - 5 + x, sy - 32, tocolor(255, 255, 255, 255), 1.4, "roboto-medium", "right", "bottom")
		local players = getElementsByType("player", root, true)
		for i = 1, #players do
			if players[i] ~= localPlayer then
				local px, py = getElementPosition(players[i])
				local x, x = getElementPosition(localPlayer)
				local distance = getDistanceBetweenPoints2D(x, y, px, py)
			--	dxDrawRectangle(posx + x, posy + y, 6, 6, -1)
			end
		end
		--
	--	dxDrawImage(posx, posy, height, height, "files/img/radar.png")
		local merged = {}
		local players = getElementsByType("player")
		local markers = getElementsByType("marker")
		local projectiles = getProjectiles()
		for i = 1, #players do merged[#merged + 1] = players[i] end
		for i = 1, #markers do merged[#merged + 1] = markers[i] end
		for _, pj in pairs(projectiles) do merged[#merged + 1] = pj end
		if not isElement(gRaceUI.targetUI) then return end
		local radarTarget = getElementType(gRaceUI.targetUI) == "vehicle" and gRaceUI.targetUI or getVehicleController(gRaceUI.targetUI)
		local px, py, pz = getElementPosition(radarTarget)
		local _, _, pr = getElementRotation(radarTarget)
		local cx, cy, _, tx, ty = getCameraMatrix()
		local north = findRotation(cx, cy, tx, ty)
		for i = 1, #merged do -- Checkpoints for race
			if getElementType(merged[i]) == "marker" then -- Race checkpoints
				if getElementDimension(merged[i]) == 4 then -- 4 is race dimension
					local bsize = 10
					local ex, ey, ez = getElementPosition(merged[i])
					local dist = getDistanceBetweenPoints2D(px, py, ex, ey)
					if dist > range then
						dist = tonumber(range)
					end
					local angle = 180 - north + findRotation(px, py, ex, ey)
					local cblipx, cblipy = getDistanceRotation(0, 0, height * (dist / range) / 2, angle)
					local blipx = centerleft + cblipx - (bsize / 2)
					local blipy = centertop + cblipy - (bsize / 2)
					dxDrawRectangle(blipx - 2, blipy - 2, bsize + 4, bsize + 4, tocolor(0, 0, 0, 255))
					dxDrawRectangle(blipx, blipy, bsize, bsize, tocolor(255, 255, 0, 255))
				end
			-- Shooter projectiles
			elseif getElementType(merged[i]) == "projectile" then
				local bsize = 10
				local ex, ey, ez = getElementPosition(merged[i])
				local dist = getDistanceBetweenPoints2D(px, py, ex, ey)
				if dist > range then
					dist = tonumber(range)
				end
				local angle = 180 - north + findRotation(px, py, ex, ey)
				local cblipx, cblipy = getDistanceRotation(0, 0, height * (dist / range) / 2, angle)
				local blipx = centerleft + cblipx - (bsize / 6)
				local blipy = centertop + cblipy - (bsize / 6)
			--	a = 255 - (dist * 1.2)
			--	a = a < 100 and 100 or a
				dxDrawRectangle(blipx, blipy, bsize, bsize, tocolor(255, 0, 0, a))
			else -- Players
				local veh = getPedOccupiedVehicle(merged[i])
				if (getElementData(merged[i], "state") == "alive" or (getElementData(merged[i], "room_id") or ""):find("Training_S_", 1, true)) and veh and veh ~= pVeh and getElementDimension(merged[i]) == getElementDimension(radarTarget) then
					local _, _, rot = getElementRotation(veh)
					local ex, ey, ez = getElementPosition(veh)
					local dist = getDistanceBetweenPoints2D(px, py, ex, ey)
					if dist > range then
						dist = tonumber(range)
					end
					local angle = 180 - north + findRotation(px, py, ex, ey)
					local cblipx, cblipy = getDistanceRotation(0, 0, height * (dist / range) / 2, angle)
					local blipx = centerleft + cblipx - (blipsize / 2)
					local blipy = centertop + cblipy - (blipsize / 2)
					local r, g, b, a = 255, 255, 255, 255
					if getPlayerTeam(merged[i]) then
						r, g, b = getTeamColor(getPlayerTeam(merged[i]))
					end
					if getElementModel(veh) == 425 then
						r, g, b, a = 255, 0, 0, 200
					end
					local boffst = 0
					if getElementData(root, "oj.target") == merged[i] then
						r, g, b, a = 255, 0, 0, 255
						boffst = 8
					end
					local img = "files/img/radar/blip.png"
					if (ez - pz) >= 5 then
						img = "files/img/radar/blipup.png"
					elseif (ez - pz) <= -5 then
						img = "files/img/radar/blipdown.png"
					end
			--		a = 255 - (dist * 1.2)
			--		a = a < 150 and 150 or a
					dxDrawImage(blipx, blipy, blipsize + boffst, blipsize + boffst, img, north - rot + 45, 0, 0, tocolor(r, g, b, a))
				end
			end
		end
		dxDrawImage(centerleft - (lpsize / 2), centertop - (lpsize / 2), lpsize, lpsize, "files/img/radar/local.png", north-pr)
		-- Avoids explosion camera bug
		if gCamera.set then
			if getCameraTarget() ~= pVeh then return end
			setCameraMatrix(unpack(gCamera.matrix))
		end
	end
)

addEventHandler("onClientPlayerDamage", root,
	function()
		if source == localPlayer then
			setElementHealth(localPlayer, 100) -- prevents drowning
		end
	end
)

addEventHandler("onClientColShapeHit", root,
	function(element)
		if pVeh ~= element then
			return
		end
		for i = 1, #gPickups do
			if gPickups[i].col == source then
				handleHitPickup(gPickups[i])
				break
			end
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		if mapLoaded then
			destroyRaceMap()
			stopCountdown()
		end
		mapInfo.show = false
		gRace.raceStarted = false
		gRaceUI.mapName = ""
		gRaceUI.nextMap = ""
		clearDeathList()
		stopMapSong()
		setTimer(stopBlackWhite, 100, 1)
		-- If he was on trials, re-enable buttons
		toggleControl("vehicle_left", true)
		toggleControl("vehicle_right", true)
	end
)

addEventHandler("lobby:onPlayerJoinGamemode", root,
	function(tp, timeleft, timepassed, racestarted, nextmap)
		gRace.timeLeftTick = getTickCount()
		gRace.timeLeft = timeleft or 0
		gRace.timePassedTick = getTickCount()
		gRace.timePassed = timepassed or 0
		gRaceUI.targetUI = pVeh
	--	setCameraTarget(localPlayer)
		if racestarted == "map started" or racestarted == "map finished" then
			gRace.raceStarted = true
		else
			gRace.raceStarted = false
		end
		gRaceUI.nextMap = nextmap
	end
)

-- Anti bounce -- DISABLED
--[[addEventHandler("onClientVehicleCollision", root,
	function(object)
		if not isElement(object) or not isElement(source) then return end
		if getElementType(object) == "object" and getElementType(source) == "vehicle" and source == pVeh then
			local tx, ty, tz = getVehicleTurnVelocity(source) 
			if ((math.abs(ty) > 0.1 and math.abs(tz) > 0.001) or (math.abs(ty) > 0.001 and math.abs(tz) > 0.1)) then	
				local vx, vy, vz = getElementVelocity(source)
				setVehicleTurnVelocity(source, 0, 0, 0) 
				setElementVelocity(source, vx * 1.01, vy * 1.01, vz)
				outputDebugString("[ANTIBOUNCE] Bounce prevented by script")
			end
		end
	end
)]]

addEventHandler("onClientPlayerWasted", localPlayer,
	function()
		gCamera.set = true
		gCamera.matrix = { getCameraMatrix() }
		handleRaceKill()
--		setTimer(fixVehicle, 1000, 1, pVeh) -- Avoid explosion bug
	end
)

local gNOS = getTickCount()
function handleHitPickup(pickup)
	if pickup.tp == "vehiclechange" then
		if getElementModel(pVeh) ~= pickup.modelid then
			g_PrevVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(pVeh)
			-- Set timer to prevent bugs
			setTimer(
				function()
					setElementModel(pVeh, pickup.modelid)
					alignVehicleWithUp()
					checkHeliControls()
					vehicleChanging(pickup.modelid)
					setVehicleUpgrades()
					if getTickCount() - gNOS <= 200 then
						addVehicleUpgrade(pVeh, 1010)
					end
				end
			, 100, 1)
			playSoundFrontEnd(46)
			if pickup.modelid == 425 then
				triggerServerEvent("race:onPlayerReachHunter", localPlayer, getElementData(localPlayer, "room_id"))
			end
		end
	elseif pickup.tp == "nitro" then
		gNOS = getTickCount()
		addVehicleUpgrade(pVeh, 1010)
		playSoundFrontEnd(46)
	elseif pickup.tp == "repair" then
		fixVehicle(pVeh)
		playSoundFrontEnd(46)
	end
end

function setVehicleUpgrades()
	local pStats = getElementData(localPlayer, "stats")
	if pStats.vehicle.wheel > 0 then
		addVehicleUpgrade(pVeh, pStats.vehicle.wheel)
	end
	if type(pStats.vehicle.paint) == "table" then
		local r, g, b = unpack(pStats.vehicle.paint)
		setVehicleColor(pVeh, r, g, b, r, g, b, r, g, b, r, g, b)
	end
end

function checkHeliControls()
	setHelicopterRotorSpeed(pVeh, 0.2)
	if getVehicleType(pVeh) == "Helicopter" then
		toggleControl("vehicle_secondary_fire", false)
	else
		toggleControl("vehicle_secondary_fire", true)
	end
end

function vehicleChanging(newModel)
	local newVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(pVeh)
	local x, y, z = getElementPosition(pVeh)
	if g_PrevVehicleHeight and newVehicleHeight > g_PrevVehicleHeight then
		z = z - g_PrevVehicleHeight + newVehicleHeight
	end
	z = z + 1
	setElementPosition(pVeh, x, y, z)
	g_PrevVehicleHeight = nil
end

local tick_respawn = getTickCount()
function handleRaceKill(key)
	local state = getElementData(localPlayer, "state")
	if state == "alive" or state == "training" then
		local tick = getTickCount()
		if tick - tick_respawn >= 3000 then
			if backwards then return end -- do not kill if player is in water and rewinding - variable from c_rewind.lua
			if getElementData(localPlayer, "room_id"):find("Training_S_") then -- Player is training, don't kill him
				setElementFrozen(pVeh, true)
				setElementAlpha(pVeh, 150)
				setTimer(respawnTrainingPlayer, 1200, 1) -- Prevents bug when vehicle explodes
			else -- Player is on 'normal' gameplay
				if key then
					if not isChatBoxInputActive() then
						triggerServerEvent("race:onPlayerRequestKill", localPlayer) -- Freeze camera with setCameraMatrix 1 sec
					end
				else
					triggerServerEvent("race:onPlayerRequestKill", localPlayer)
				end
			end
		--	setCameraMatrix(getCameraMatrix()) -- currently disabled becouse if player presses enter on countdown, camera will stay static
			canpressB = false
			setTimer(function() canpressB = true end, 1000, 1) -- Prevents bug where when player presses B when he is on setCameraMatrix from dead
			tick_respawn = tick
		end
	end
end

function drawCountdown()
	if cCountdown.goup then
		cCountdown.progress = cCountdown.progress + 0.08 > 1 and 1 or cCountdown.progress + 0.08
		if cCountdown.progress == 1 then
			cCountdown.goup = false
		end
	end
	--
	if cCountdown.countdown == -1 then
		cCountdown.progress = cCountdown.progress - 0.08 < 0 and 0 or cCountdown.progress - 0.08
		if cCountdown.progress == 0 then
			stopCountdown()
			return
		end
	end
	local width = 400 * cCountdown.progress
	local x, y = sx / 2 - width / 2, sy / 2 - width / 2
	dxDrawImage(x, y, width, width, "files/img/race/countdown/" ..(cCountdown.countdown == -1 and 0 or cCountdown.countdown).. ".png", 0, 0, 0, tocolor(255, 255, 255, 200 * cCountdown.progress))
end

function stopCountdown()
	if cCountdown.handler then
		removeEventHandler("onClientRender", root, drawCountdown)
		cCountdown.handler = false
	end
end

function disableCollisions()
	local ghostmode = true
	local tp = getElementData(localPlayer, "room_id")
	if tp == "Shooter" then
		ghostmode = getElementData(root, "shooter.ghostmode")
	elseif tp == "OJ" then 
		ghostmode = getElementData(root, "oj.ghostmode")
	elseif tp == "Destruction Derby A" then
		ghostmode = getElementData(root, "dda.ghostmode")
	elseif tp == "Destruction Derby B" then
		ghostmode = getElementData(root, "ddb.ghostmode")
	end
	local vehicles = getElementsByType("vehicle", root, true)
	for i = 1, #vehicles do
		for k = 1, #vehicles do
			setElementCollidableWith(vehicles[i], vehicles[k], getElementInterior(vehicles[i]) == 100 and false or not ghostmode)
		end
		-- Disable blades collisions
		if getVehicleType(vehicles[i]) == "Helicopter" then
			setHeliBladeCollisionsEnabled(vehicles[i], not ghostmode)
		end
	end
	local players = getElementsByType("player", root, true)
	for i = 1, #players do
		setElementCollisionsEnabled(players[i], players[i] == localPlayer and true or false)
	end
end

---------------------------------- LOAD/DESTROY OBJS & SPAWN ----------------------------------

function loadPlayerSpawn()
	triggerServerEvent("race:onClientRequestSpawn", localPlayer)
	setTimer(
		function()
			local cam = getCamera()
			setElementPosition(cam, getElementPosition(pVeh))
			setCameraTarget(localPlayer)
			removeBlackWhite()
		end
	, 200, 1)
	g_PrevVehicleHeight = nil
	gCamera.set = false
end

function destroyRaceMap()
	if not mapDestroyed then
		exports.scriptloader:unloadClientScripts()
		-- Destroy objects & pickups
		local obj = getElementsByType("object")
		for i = 1, #obj do
			destroyElement(obj[i])
		end
		-- Destroy colshapes
		local col = getElementsByType("colshape")
		for i = 1, #col do
			destroyElement(col[i])
		end
		-- Destroy checkpoints & markers
		local marker = getElementsByType("marker")
		for i = 1, #marker do
			destroyElement(marker[i])
		end
		-- Destroy vehicles
		local vehicle = getElementsByType("vehicle")
		for i = 1, #vehicle do
			destroyElement(vehicle[i])
		end
		-- Destroy peds
		local ped = getElementsByType("ped")
		for i = 1, #ped do
			destroyElement(ped[i])
		end
		gPickups = {}
		mapLoaded = false
		mapDestroyed = true
		outputDebugString("[RACE] destroyRaceMap: destroyed current map")
	end
end

function loadRaceMap(data, tp)
	if not mapLoaded then	
		gMarkers = {}
		local dimension = getElementDimension(localPlayer)
		local pickupmodel = { ["nitro"] = 2221, ["repair"] = 2222, ["vehiclechange"] = 2223 }
		local objects = data.objects
		local removeobjects = data.removeobjects
		local pickups = data.pickups
		local checkpoints = data.checkpoints
		local markers = data.markers
		local vehicles = data.vehicles
		local scripts = data.cscripts
		local resname = data.resname
		local mapname = data.mapname
		local files = data.files
		local deathlist = data.deathlist
		local c = 0
		-- Set time and weather based on meta.xml
		-- Weather
		if data.forecast[1] then
			setWeather(data.forecast[1])
			outputDebugString("[RACE] Weather set to " ..data.forecast[1])
		end
		-- Time
		if data.forecast[2] then
			setTime(data.forecast[2], data.forecast[3] or 0)
			outputDebugString("[RACE] Time set to " ..data.forecast[2].. ":" ..data.forecast[3] or 0)
		end
		-- Create objects
		createStreamedObjects(objects) -- calls to c_streamer.lua
		-- Remove world objects
		for i = 1, #removeobjects do
			removeWorldModel(removeobjects[i].modelid, removeobjects[i].radius, removeobjects[i].posx, removeobjects[i].posy, removeobjects[i].posz)
		end
		setOcclusionsEnabled(#removeobjects == 0)
	--	outputDebugString("[RACE] loadRaceMap: created " ..c.. " objects")
		-- Create pickups
		for i = 1, #pickups do
			local modelid = pickupmodel[pickups[i].type]
			local obj = createObject(modelid, pickups[i].posx, pickups[i].posy, pickups[i].posz, pickups[i].rotx, pickups[i].roty, pickups[i].rotz, true)
			if obj then
				setElementInterior(obj, pickups[i].interior or 0)
				setElementDimension(obj, dimension)
				local col = createColSphere(pickups[i].posx, pickups[i].posy, pickups[i].posz, 3.5)
				gPickups[#gPickups + 1] = { x = pickups[i].posx, y = pickups[i].posy, z = pickups[i].posz, col = col, obj = obj, tp = pickups[i].type, modelid = pickups[i].modelid, text = pickups[i].type == "vehiclechange" and getVehicleNameFromModel(pickups[i].modelid) or false }
			end
		end
		-- Create checkpoints
		local tbl = {}
		local colors = { { 255, 0, 0 }, { 0, 255, 0}, { 0, 0, 255 } }
		local r, g, b = unpack(colors[math.random(#colors)])
		for i = 1, #checkpoints do
			local marker = createMarker(checkpoints[i].posx, checkpoints[i].posy, checkpoints[i].posz, "checkpoint", 6, r, g, b, 255)
			if marker then
				setElementInterior(marker, checkpoints[i].interior or 0)
				setElementDimension(marker, dimension)
				if tp == "Race" then
					if i > CHECKPOINTS_TO_SHOW then
						setElementDimension(marker, 100)
					end
				end
				tbl[#tbl + 1] = marker
			end
		end
		if tp == "Race" then
			syncCheckpointsWithCore(tbl) -- Send checkpoints to c_checkpoints.lua
		elseif tp == "Trials" then
			triggerEvent("trials:manageCheckpoints", root, tbl)
		end
		-- Create marker
		for i = 1, #markers do
			local r, g, b = hex2rgb(markers[i].color)
			local a = markers[i].alpha
			local marker = createMarker(markers[i].posx, markers[i].posy, markers[i].posz, markers[i].type, markers[i].size, r, g, b, a)
			setElementInterior(marker, markers[i].interior or 0)
			setElementDimension(marker, dimension)
			table.insert(gMarkers, { id = markers[i].id, marker = marker })
		end
		-- Create vehicles
		for i = 1, #vehicles do
			local veh = createVehicle(vehicles[i].modelid, vehicles[i].posx, vehicles[i].posy, vehicles[i].posz, vehicles[i].rotx, vehicles[i].roty, vehicles[i].rotz)
			if veh then
				setElementInterior(veh, vehicles[i].interior or 0)
				setElementDimension(veh, dimension)
				setVehiclePaintjob(veh, vehicles[i].paintjob or 0)
			end
		end
		-- Check files --> c_loadscript.lua
		if exports.scriptloader:checkClientFiles(files, resname, scripts) then -- If files don't exist, download them and then later load the scripts 
			-- Load scripts if files exists
			exports.scriptloader:loadClientScripts()
		end
		-- Load deathlist
		if deathlist then -- Deathlist not present on solo training
			for i = 1, #deathlist do
				addNameToDeathlist(deathlist[i])
			end
		end
		-- Load spawn
		loadPlayerSpawn()
		--
		mapLoaded = true
		mapDestroyed = false
	end
end

-- Get current alive players for the gamemode that localPlayer is in
function getGamemodeAlivePlayers()
	local alive = {}
	local players = getElementsByType("player")
	local localRoom = getElementData(localPlayer, "room_id")
	for i = 1, #players do
		if getElementData(players[i], "room_id") == localRoom and getElementData(players[i], "state") == "alive" then
			alive[#alive + 1] = { source = players[i], name = getPlayerName(players[i]) }
		end
	end
	return alive
end

function fadeCameraEx(bool)
	camFaded = bool
--	fadeCamera(bool)
end

function setRaceUIEnabled(bool)
	gRaceUI.enabled = bool
end

addCommandHandler("getpos",
	function()
		local x, y, z = getElementPosition(localPlayer)
		outputChatBox(x.. " " ..y.. " " ..z)
	end
)

function warpPlayerIntoVehicle()
	local state = getElementData(localPlayer, "state")
	if isElement(pVeh) and state == "alive" or state == "training" then
		if not getPedOccupiedVehicle(localPlayer) then
			triggerServerEvent("race:warpPedIntoVehicle", localPlayer)
		end
	end
end
setTimer(warpPlayerIntoVehicle, 500, 0)

function checkPedInWater()
	local veh = pVeh
	if isElement(veh) and isElementInWater(veh) and getVehicleType(veh) ~= "Boat" then
		handleRaceKill()
	end
end
setTimer(checkPedInWater, 500, 0)

function getVehicleSpeed(veh)
	if not veh then return 0 end
	local vx, vy, vz = getElementVelocity(veh)
	return math.floor(math.sqrt(vx * vx + vy * vy + vz * vz) * 161)
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

---------------------------------- MATH ----------------------------------

function rem(a, b)
	local result = a - b * math.floor(a / b)
	if result >= b then
		result = result - b
	end
	return result
end

function hex2rgb(hex, alpha)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function msToTimeStr(timeMs, noms)
	local minutes = math.floor(timeMs / 60000)
	timeMs = timeMs - minutes * 60000
	local seconds = math.floor(timeMs / 1000)
	timeMs = timeMs - seconds * 1000
	local miliseconds = math.floor(timeMs / 10)
	if seconds < 10 then
		seconds = "0" ..seconds
	end
	if miliseconds < 10 then
		miliseconds = "0" ..miliseconds
	end
	if noms then
		return minutes.. ":" ..seconds
	else
		return minutes.. ":" ..seconds.. ":" ..miliseconds
	end
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
		str = minutes.. ":" ..seconds
	else
		if #tostring(seconds) == 1 then
			seconds = "0" ..seconds
		end
		str = minutes.. ":" ..seconds
	end
	return str
end

function dxDrawRoundedRectangle(x, y, rx, ry, color, radius, postgui, tp)
	tp = type(postgui) == "string" and postgui or tp
	postgui = type(postgui) == "boolean" and postgui or false
	tp = tp and tp or "all"
	local width = rx
	local startx = x
    rx = rx - radius * 2
    ry = ry - radius * 2
    x = x + radius
    y = y + radius

    if (rx >= 0) and (ry >= 0) then
		if tp == "all" then
			dxDrawRectangle(x, y, rx, ry, color, postgui, false)
			dxDrawRectangle(x, y - radius, rx, radius, color, postgui, false)
			dxDrawRectangle(x, y + ry, rx, radius, color, postgui, false)
			dxDrawRectangle(x - radius, y, radius, ry, color, postgui, false)
			dxDrawRectangle(x + rx, y, radius, ry, color, postgui, false)

			dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, postgui)
			dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, postgui)
			dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, postgui)
			dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, postgui)
		elseif tp == "top" then
			dxDrawRectangle(x, y, rx, ry, color, postgui, false)
			dxDrawRectangle(x, y - radius, rx, radius, color, postgui, false)
			dxDrawRectangle(startx, y + ry, width, radius, color, postgui, false)
			dxDrawRectangle(x - radius, y, radius, ry, color, postgui, false)
			dxDrawRectangle(x + rx, y, radius, ry, color,postgui, false)
			
			dxDrawCircle(x, y, radius, 180, 270, color, color, 7, 1, postgui)
			dxDrawCircle(x + rx, y, radius, 270, 360, color, color, 7, 1, postgui)
		elseif tp == "bottom" then
			dxDrawRectangle(x, y, rx, ry, color, postgui, false)
			dxDrawRectangle(startx, y - radius, width, radius, color, postgui, false)
			dxDrawRectangle(x, y + ry, rx, radius, color, postgui, false)
			dxDrawRectangle(x - radius, y, radius, ry, color, postgui, false)
			dxDrawRectangle(x + rx, y, radius, ry, color, postgui, false)
			
			dxDrawCircle(x + rx, y + ry, radius, 0, 90, color, color, 7, 1, postgui)
			dxDrawCircle(x, y + ry, radius, 90, 180, color, color, 7, 1, postgui)
		end
    end
end

function errorMsg()
	outputChatBox("You can't do that.", 255, 0, 0)
end

function findRotation(x1, y1, x2, y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end
	return t
end

function getDistanceRotation(x, y, dist, angle)
	local a = math.rad(90 - angle)
	local dx = math.cos(a) * dist
	local dy = math.sin(a) * dist
	return x+dx, y+dy
end

_getPlayerName = getPlayerName
function getPlayerName(source)
	if not isElement(source) then return end
	local pStats = getElementData(source, "stats")
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

_getElementByID = getElementByID
function getElementByID(id)
	for i = 1, #gMarkers do
		if gMarkers[i].id == id then
			return gMarkers[i].marker
		end
	end
end

function getPlayerMoney()
	return getElementData(localPlayer, "stats").player.money
end

function RGBToHex(red, green, blue, alpha)
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end
end

-- Radar
function getVehicleVelocity(veh, multiply)
	if not veh then return 0 end
	local vx, vy, vz = getElementVelocity(veh)
	return math.sqrt(vx * vx + vy * vy + vz * vz) * (multiply and 0.05 or 1)
end

function directionToRotation2D( x, y )
	return rem( math.atan2( y, x ) * (360/6.28) - 90, 360 )
end

function alignVehicleWithUp()
	local vehicle = pVeh
	local matrix = getElementMatrix( vehicle )
	local Right = Vector3D:new( matrix[1][1], matrix[1][2], matrix[1][3] )
	local Fwd	= Vector3D:new( matrix[2][1], matrix[2][2], matrix[2][3] )
	local Up	= Vector3D:new( matrix[3][1], matrix[3][2], matrix[3][3] )

	local Velocity = Vector3D:new( getElementVelocity( vehicle ) )
	local rz

	if Velocity:Length() > 0.05 and Up.z < 0.001 then
		-- If velocity is valid, and we are upside down, use it to determine rotation
		rz = directionToRotation2D( Velocity.x, Velocity.y )
	else
		-- Otherwise use facing direction to determine rotation
		rz = directionToRotation2D( Fwd.x, Fwd.y )
	end

	setElementRotation( vehicle, 0, 0, rz )
end

Vector3D = {
	new = function(self, _x, _y, _z)
		local newVector = { x = _x or 0.0, y = _y or 0.0, z = _z or 0.0 }
		return setmetatable(newVector, { __index = Vector3D })
	end,

	Copy = function(self)
		return Vector3D:new(self.x, self.y, self.z)
	end,

	Normalize = function(self)
		local mod = self:Length()
		self.x = self.x / mod
		self.y = self.y / mod
		self.z = self.z / mod
	end,

	Dot = function(self, V)
		return self.x * V.x + self.y * V.y + self.z * V.z
	end,

	Length = function(self)
		return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
	end,

	AddV = function(self, V)
		return Vector3D:new(self.x + V.x, self.y + V.y, self.z + V.z)
	end,

	SubV = function(self, V)
		return Vector3D:new(self.x - V.x, self.y - V.y, self.z - V.z)
	end,

	CrossV = function(self, V)
		return Vector3D:new(self.y * V.z - self.z * V.y,
							self.z * V.x - self.x * V.z,
							self.x * V.y - self.y * V.z)
	end,

	Mul = function(self, n)
		return Vector3D:new(self.x * n, self.y * n, self.z * n)
	end,

	Div = function(self, n)
		return Vector3D:new(self.x / n, self.y / n, self.z / n)
	end,
}

local gHeli = { 548, 425, 417, 487, 488, 497, 563, 447, 469 }
function isHelicopter(modelid)
	for i = 1, #gHeli do
		if gHeli[i] == modelid then
			return true
		end
	end
	return false
end

function drawCircleProgress(x, y, w, h, percent, startangle, endangle, rgba)
	local totalangle = math.abs(endangle - startangle)
	local r, g, b, a = unpack(rgba)
	local invert = startangle > endangle and startangle or 0
	if invert > 0 then
		local angle = startangle - ((percent / 100) * startangle)
		for i = endangle, startangle do
			if i < angle then
				dxDrawImage(x, y, w, h, "files/img/misc/6px.png", i, 0, 0, tocolor(40, 40, 40, a or 255), true) -- Background color
			else
				dxDrawImage(x, y, w, h, "files/img/misc/6px.png", i, 0, 0, tocolor(r, g, b, a or 255), true)
			end
		end
	else
		local angle = (totalangle * (percent / 100)) + startangle
		for i = startangle, endangle do
			if i > angle then
				dxDrawImage(x, y, w, h, "files/img/misc/6px.png", i, 0, 0, tocolor(40, 40, 40, a or 255), true) -- Background color
			else
				dxDrawImage(x, y, w, h, "files/img/misc/6px.png", i, 0, 0, tocolor(r, g, b, a or 255), true)
			end
		end
		if percent > 0 then
			dxDrawImage(x, y, w, h, "files/img/misc/6px.png", angle, 0, 0, tocolor(r, g, b, a or 255), true)
		end
	end
end

local icon = {}
function drawMapRectangle(x, y, text, i)
	text = text and text or ""
	if not gRace.raceStarted and text ~= "" then return end
	local speed = 0.04
	if not icon[i] then
		icon[i] = { progress = { 0, 0, 0 }, w = 0, oldw = 0, name = "", oldname = "", state = "open" }
	else
		if #text == 0 then
			icon[i].state = "close"
		else
			if not icon[i].state then
				icon[i].state = "open"
			end
		end
	end
	if icon[i].state == "open" then
		icon[i].progress[2] = icon[i].progress[2] + speed > 1 and 1 or icon[i].progress[2] + speed
		if icon[i].progress[2] == 1 then
			icon[i].progress[1] = icon[i].progress[1] + speed > 1 and 1 or icon[i].progress[1] + speed
		end
	elseif icon[i].state == "close" then
		icon[i].progress[1] = icon[i].progress[1] - speed < 0 and 0 or icon[i].progress[1] - speed
		if icon[i].progress[1] == 0 then
			icon[i].progress[2] = icon[i].progress[2] - speed < 0 and 0 or icon[i].progress[2] - speed
			if icon[i].progress[2] == 0 then
				icon[i].oldw = 0
				icon[i].w = 0
				icon[i].oldname = ""
				icon[i].name = ""
				icon[i].state = nil
			end
		end
	elseif icon[i].state == "resize" then	
		icon[i].progress[3] = icon[i].progress[3] + speed > 1 and 1 or icon[i].progress[3] + speed
	end
	if icon[i].name ~= text then
		icon[i].oldw = icon[i].w
		icon[i].w = dxGetTextWidth(text, 1, "roboto") + (text == "" and 0 or (i == 3 and 8 or 12))
		icon[i].oldname = icon[i].name
		icon[i].name = text
		if text == "" then
			icon[i].state = "close"
		else
			if icon[i].progress[1] == 1 then
				icon[i].state = "resize"
				icon[i].progress[3] = 0
			end
		end
	end
	local w
	if icon[i].state == "close" or icon[i].state == "open" then
		w = math.floor(interpolateBetween(0, 0, 0, icon[i].state == "close" and icon[i].oldw or icon[i].w, 0, 0, icon[i].progress[1], "Linear"))
	else
		w = math.floor(interpolateBetween(icon[i].oldw, 0, 0, icon[i].w, 0, 0, icon[i].progress[3], "Linear"))
	end
	local alpha = 255 * icon[i].progress[2]
	if i == 3 then
		x = math.floor((x - w / 2) - 24) 
	end
	if icon[i].progress[1] > 0 then
		dxDrawImage(x + w, y, 32, 32, "files/img/race/border.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	end
	for i = 1, w do
		dxDrawImage(x + i, y, 32, 32, "files/img/race/rectangle.png", 0, 0, 0)
	end
	dxDrawImage(x, y, 32, 32, "files/img/race/mapbackground.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	if i == 1 then
		dxDrawImage(x + 8, y + 8, 16, 16, "files/img/race/map.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	elseif i == 2 then
		dxDrawImage(x + 9, y + 8, 16, 16, "files/img/race/next.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	elseif i == 3 then
		dxDrawImage(x + 7.5, y + 7, 16, 16, "files/img/race/timeleft.png", 0, 0, 0, tocolor(255, 255, 255, alpha))
	end
	local str = #text > 0 and text or icon[i].oldname
	dxDrawText(str, x + 30, y, x + 22.5 + w, y + 32, -1, 1, "roboto", "center", "center", true, false, false, false)
	return icon[i].progress[1]
end
--setTimer(function() gRaceUI.mapName = #gRaceUI.mapName > 0 and "" or "TESGINTT" end, 2500, 1)

--
-- Synced with server functions
--

_setElementModel = setElementModel
function setElementModel(source, modelid, sync)
	if sync == false then
		_setElementModel(source, modelid)
	else
		triggerServerEvent("loadscript:syncClientToServer", source, "setElementModel", modelid)
	end
end

_addVehicleUpgrade = addVehicleUpgrade
function addVehicleUpgrade(source, upgradeid)
	if isElementLocal(source) then 
		_addVehicleUpgrade(source, upgradeid)
	else
		triggerServerEvent("loadscript:syncClientToServer", source, "addVehicleUpgrade", upgradeid)
	end
end

_setVehicleColor = setVehicleColor
function setVehicleColor(source, ...)
	if isElementLocal(source) then 
		_setVehicleColor(source, ...)
	else
		triggerServerEvent("loadscript:syncClientToServer", source, "setVehicleColor", ...)
	end
end

_setElementInterior = setElementInterior
function setElementInterior(source, ...)
	if isElementLocal(source) then
		_setElementInterior(source, ...)
	else
		triggerServerEvent("loadscript:syncClientToServer", source, "setElementInterior", ...)
	end
end

function setElementFrozen(source, bool)
	triggerServerEvent("loadscript:syncClientToServer", source, "setElementFrozen", bool)
end