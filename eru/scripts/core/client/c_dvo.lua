local gShadersLight = {}
local gShadersPaint = {}
local gShadows = {}
local gNitroShader = nil
local skidmarkShader = nil
dvoEnabled = true
local gAnimations = {}

local nr, ng, nb = nil, nil, nil

local gBeat =
{
	goup = false,
	progress = 0
}

addEvent("tunning:setVehicleDVO", true)

local gOffstHeadlight = 
{
	[1] = { effect = "redFlower", scale = 0.5, scx = 0.57, scy = 0.41 }, 
	[2] = { effect = "redFlower", scale = 1.65, scx = 0.73, scy = 0.74 }, 
	[3] = { effect = "redFlower", scale = 1.6, scx = 0.51, scy = 0.62 }, 
	[4] = { effect = "redFlower", scale = 2.75, scx = 0.04, scy = 0.92 }, 
	[5] = { effect = "redFlower", scale = 1.65, scx = 0.01, scy = 0.77 }, 
	[6] = { effect = "redFlower", scale = 1.05, scx = 0.16, scy = 0.56 }, 
	[7] = { effect = "redFlower", scale = 1.05, scx = 0.03, scy = 0.79 }, 
	[8] = { effect = "redFlower", scale = 1.05, scx = 0.1, scy = 0.57 }, 
	[9] = { effect = "redFlower", scale = 1.05, scx = 0.42, scy = 0.59 }, 
	[10] = { effect = "redFlower", scale = 1.05, scx = 0.72, scy = 0.56 },
	[11] = { effect = "redFlower", scale = 2.7, scx = 0.44, scy = 0.81 }, 	
	[12] = { effect = "redFlower", scale = 1.2, scx = 0, scy = 0.6 }, 
	[13] = { effect = "redFlower", scale = 1.5, scx = 0, scy = 0.69 }, 
	[14] = { effect = "redFlower", scale = 1.1, scx = 0.11, scy = 0.68 }, 
	[15] = { effect = "redFlower", scale = 1.1, scx = 0.14, scy = 0.69 }, 
	[16] = { effect = "redFlower", scale = 1.6, scx = 0, scy = 0.57 }, 
	[17] = { effect = "redFlower", scale = 1.7, scx = 1, scy = 0.48 }, 
	[18] = { effect = "redFlower", scale = 0.75, scx = 0.32, scy = 0.53 }, 
	[19] = { effect = "redFlower", scale = 0.75, scx = 0.8, scy = 0.46 }, 
	--
	[20] = { effect = "greenCircle", scale = 2.85, scx = 0.75, scy = 0.3 }, 
	[21] = { effect = "greenCircle", scale = 2.4, scx = 0.75, scy = 0.14 }, 
	--
	[22] = { effect = "merryXMass", scale = 1, scx = 0.12, scy = 0.35 }, 
	[23] = { effect = "merryXMass", scale = 0.1, scx = 0.87, scy = 0.58 }, 
	--
	[24] = { effect = "verticalStrobes", scale = 1, scx = 0.66, scy = 0.32 }, 
	--
	[25] = { effect = "violetExplosion", scale = 1, scx = 0.5, scy = 0.5 }, 
	[26] = { effect = "violetExplosion", scale = 1, scx = 0.45, scy = 0.38 }, 
	[27] = { effect = "violetExplosion", scale = 1, scx = 1, scy = 0.17 }, 
	[28] = { effect = "violetExplosion", scale = 0.5, scx = 0.78, scy = 0 }, 
	--
	[29] = { effect = "blobsMod", scale = 1, scx = 0.76, scy = 0.14 }, 
	--
	[30] = { effect = "colCircle", scale = 1.05, scx = 0.58, scy = 0.77 }, 
	[31] = { effect = "colCircle", scale = 1.2, scx = 0, scy = 0.22 }, 
	[32] = { effect = "colCircle", scale = 1.7, scx = 0, scy = 1 }, 
	--
	[33] = { effect = "colDonut", scale = 2, scx = 0.46, scy = 0.41 }, 
	[34] = { effect = "colDonut", scale = 0.85, scx = 0.76, scy = 0.13 }, 
	--
	[35] = { effect = "colorDrops", scale = 1, scx = 0, scy = 0 }, 
	[36] = { effect = "colorDrops", scale = 0.25, scx = 0.7, scy = 0.17 }, 
	--
	[37] = { effect = "coolWaves", scale = 1.2, scx = 0.42, scy = 0.14 }, 
	--
	[38] = { effect = "energyField", scale = 1, scx = 0.57, scy = 0 }, 
	[39] = { effect = "energyField", scale = 1, scx = 0.59, scy = 0.16 }, 
	[40] = { effect = "energyField", scale = 4.15, scx = 0.5, scy = 0 }, 
	--
	[41] = { effect = "grayWaves", scale = 1.4, scx = 0.35, scy = 0.1 }, 
	--
	[42] = { effect = "gridWalk", scale = 1, scx = 0.5, scy = 0.5 }, 
	[43] = { effect = "gridWalk", scale = 0.4, scx = 0.58, scy = 0 }, 
	--
	[44] = { effect = "hypnoCircles", scale = 0.5, scx = 0.11, scy = 0.59 }, 
	--
	[45] = { effect = "hypnoWheel", scale = 1, scx = 0, scy = 0 }, 
	[46] = { effect = "hypnoWheel", scale = 1, scx = 1, scy = 1 }, 
	[47] = { effect = "hypnoWheel", scale = 1, scx = 0.76, scy = 0.13 }, 
	--
	[48] = { effect = "noise", scale = 0.5, scx = 0, scy = 0 }, 
	--
	[49] = { effect = "purpleSine", scale = 1, scx = 0.56, scy = 0.13 }, 
	[50] = { effect = "purpleSine", scale = 1.15, scx = 0.29, scy = 0.15 }, 
	--
	[51] = { effect = "sineColors", scale = 1, scx = 0.46, scy = 0.44 }, 
	[52] = { effect = "sineColors", scale = 1, scx = 1, scy = 0.49 }, 
	[53] = { effect = "sineColors", scale = 1, scx = 0, scy = 0.55 }, 
	[54] = { effect = "sineColors", scale = 0.85, scx = 0.5, scy = 0.22 }, 
	[55] = { effect = "sineColors", scale = 0.45, scx = 0.41, scy = 0.17 }, 
	--
	[56] = { effect = "sineWeb", scale = 1, scx = 0, scy = 0 }, 
	[57] = { effect = "sineWeb", scale = 6.2, scx = 0.33, scy = 0.95 }, 
	--
	[58] = { effect = "spin", scale = 1, scx = 0, scy = 0 }, 
	[59] = { effect = "spin", scale = 1, scx = 0.68, scy = 0.34 }, 
	[60] = { effect = "spin", scale = 1.95, scx = 0.46, scy = 0.09 }, 
	--
	[61] = { effect = "tunnel", scale = 1, scx = 0, scy = 0 }, 
	[62] = { effect = "tunnel", scale = 1.05, scx = 0.45, scy = 0.21 }, 
	[63] = { effect = "tunnel", scale = 0.4, scx = 0.74, scy = 0.12 }
}
setElementData(localPlayer, "total.dvos", #gOffstHeadlight, false)

local gOffstColor =
{
	[1] = { effect = "blobs", scale = 4.4, center = 0.5 },
	[2] = { effect = "blobsMod", scale = 6, center = 0.5 },
	[3] = { effect = "colCircle", scale = 0.6, center = 0.5, musicscale =  -0.5 },
	[4] = { effect = "colDonut", scale = 2, center = 0.5 },
	[5] = { effect = "colFractals", scale = 1, center = 0.5 },
	[6] = { effect = "colorDrops", scale = 0.3, center = 0.39 },
	[7] = { effect = "coolWaves", scale = 0.6, center = 0.5 },
	[8] = { effect = "energyField", scale = 0.15, center = 0.48 }, 
	[9] = { effect = "grayWaves", scale = 0.55, center = 0.5 }, 
	[10] = { effect = "gridWalk", scale = 0.3, center = 0.5 }, 
	[11] = { effect = "hypnoCircles", scale = 0.3, center = 0.5 },
	[12] = { effect = "hypnoWheel", scale = 0.15, center = 0.5 },
	[13] = { effect = "noise", scale = 0.5, center = 0.5 },
	[14] = { effect = "purpleSine", scale = 1, center = 0.5 },
	[15] = { effect = "redPlanet", scale = 1, center = 0.5 },
	[16] = { effect = "sineColors", scale = 0.05, center = 0.5 },
	[17] = { effect = "sineWeb", scale = 0.05, center = 0.5 },
	[18] = { effect = "spin", scale = 0.7, center = 0.5 },
	[19] = { effect = "spinNeckl", scale = 0.5, center = 0.5 },
	[20] = { effect = "tunnel", scale = 0.75, center = 0.5 },
	[21] = { effect = "warpedSiveWave", scale = 0.2, center = 0.5 },
	[22] = { effect = "weirdFlower", scale = 0.3, center = 0.5 },
	[23] = { effect = "whiteCircles", scale = 0.3, center = 0.5 },
	[24] = { effect = "blob", scale = nil, center = nil }
}
setElementData(localPlayer, "total.paints", #gOffstColor, false)

addEventHandler("tunning:setVehicleDVO", root,
	function(tp, dvo, r, g, b)
		if tp == "rear lights" then
			setVehicleLight(source, dvo)
		elseif tp == "nos" then
			setVehicleNitroColor(r, g, b)
		elseif tp == "paint" then
			setVehiclePaint(source, dvo)
		elseif tp == "front lights" then
			setVehicleHeadlightAnim(source, dvo)
		end
	end
)

function setVehicleLight(vehicle, dvo)
	if not isElementStreamedIn(vehicle) and vehicle ~= pVeh then return end
	if dvo == (#gOffstHeadlight + 1) then 
		engineRemoveShaderFromWorldTexture(gShadersLight[vehicle], "vehiclelightson128", vehicle)
		destroyElement(gShadersLight[vehicle])
		setElementData(vehicle, "dvo.light", false)
		return
	end
	if isElement(gShadersLight[vehicle]) then
		engineRemoveShaderFromWorldTexture(gShadersLight[vehicle], "vehiclelightson128", vehicle)
		destroyElement(gShadersLight[vehicle])
--		outputDebugString("[DVO] Destroying current shader for vehicle " ..getVehicleName(vehicle))
	end 
	local d = gOffstHeadlight[dvo]
	local shader = dxCreateShader("files/shaders/dvo/" ..d.effect.. ".fx")
	if shader then
		local scale = d.scale
		local centerx, centery = d.scx, d.scy
		dxSetShaderValue(shader, "sTexSize", 1024, 1024)
		dxSetShaderValue(shader, "sScale", scale, scale)
		dxSetShaderValue(shader, "sCenter", centerx, centery)
		engineApplyShaderToWorldTexture(shader, "vehiclelightson128", vehicle)

		gShadersLight[vehicle] = shader
	--	outputDebugString("[DVO] Created shader DVO " ..dvo.. " for vehicle " ..getVehicleName(vehicle))
		setElementData(vehicle, "dvo.light", dvo)
	end
end

function setVehiclePaint(vehicle, dvo)
	if not isElementStreamedIn(vehicle) and vehicle ~= pVeh then return end
	if dvo == (#gOffstColor + 1) then
		removeVehiclePaint(vehicle)
		return
	end
	if isElement(gShadersPaint[vehicle]) then
		engineRemoveShaderFromWorldTexture(gShadersPaint[vehicle], "map", vehicle)
		engineRemoveShaderFromWorldTexture(gShadersPaint[vehicle], "vehiclegrunge256", vehicle)
		destroyElement(gShadersPaint[vehicle])
	--	outputDebugString("[DVO] Destroying current shader for vehicle " ..getVehicleName(vehicle))
	end
	local d = gOffstColor[dvo]
	local shader = dxCreateShader("files/shaders/dvo/" ..d.effect.. ".fx", 0, 0, true)
	if shader then
		local scale = d.scale
		if scale then
			dxSetShaderValue(shader, "sTexSize", 1024, 1024)
			dxSetShaderValue(shader, "sScale", scale, scale)
			dxSetShaderValue(shader, "sCenter", d.center, d.center)
		end
		engineApplyShaderToWorldTexture(shader, "map", vehicle)
		engineApplyShaderToWorldTexture(shader, "vehiclegrunge256", vehicle)
		gShadersPaint[vehicle] = shader
	--	outputDebugString("[DVO] Created shader DVO " ..dvo.. " for vehicle " ..getVehicleName(vehicle))
		setElementData(vehicle, "dvo.paint", dvo)
	end
end

function removeVehiclePaint(vehicle)
	if isElement(gShadersPaint[vehicle]) then
		engineRemoveShaderFromWorldTexture(gShadersPaint[vehicle], "map", vehicle)
		engineRemoveShaderFromWorldTexture(gShadersPaint[vehicle], "vehiclegrunge256", vehicle)
		destroyElement(gShadersPaint[vehicle])
		gShadersPaint[vehicle] = nil
		outputDebugString("[DVO] Destroying current shader for vehicle " ..getVehicleName(vehicle))
		setElementData(vehicle, "dvo.paint", false)
	end
end

function setVehicleNitroColor(r, g, b)
	if not dvoEnabled then return end
	if not isElement(gNitroShader) then
		gNitroShader = dxCreateShader("files/shaders/dvo/nitro.fx")
	end
	nr, ng, nb = r, g, b
	engineApplyShaderToWorldTexture(gNitroShader, "smoke")
	dxSetShaderValue(gNitroShader, "gNitroColor", r / 255, g / 255, b / 255)
end

function resetNitroColor()
	if isElement(gNitroShader) then
		destroyElement(gNitroShader)
	end
	local pStats = getElementData(localPlayer, "stats")
	if pStats.vehicle.noscolor then
		local r, g, b = unpack(pStats.vehicle.noscolor)
		gNitroShader = dxCreateShader("files/shaders/dvo/nitro.fx")
		engineApplyShaderToWorldTexture(gNitroShader, "smoke")
		dxSetShaderValue(gNitroShader, "gNitroColor", r / 255, g / 255, b / 255)
	end
end

addEventHandler("onClientPreRender", root,
	function()
		if gBeat.goup then
			gBeat.progress = gBeat.progress + 0.1 > 1 and 1 or gBeat.progress + 0.1
			if gBeat.progress == 1 then
				gBeat.goup = false
			end
		else
			gBeat.progress = gBeat.progress - 0.1 < 0 and 0 or gBeat.progress - 0.1
		end
		-- Music animation
		local vehicles = getElementsByType("vehicle", root, true)
		for i = 1, #vehicles do
			local dvo = getElementData(vehicles[i], "dvo.paint")
			if dvo then
				local d = gOffstColor[dvo]
				if d.scale then
					if gShadersPaint[vehicles[i]] then
						local scale = interpolateBetween(d.scale, 0, 0, d.musicscale and d.scale * d.musicscale or d.scale * 3, 0, 0, gBeat.progress, "Linear")
						dxSetShaderValue(gShadersPaint[vehicles[i]], "sScale", scale, scale)
					end
				end
			end
		end
		-- Neons
		for veh, value in pairs(gShadows) do
			local x, y, z = getPositionFromElementOffset(veh, 0, 0.8, 0)
			local rx, ry, rz = getElementRotation(veh)
			if not isElement(value.obj) then
				value.obj = createObject(18085, x, y, z)
			end
			local _, _, minz = getElementBoundingBox(veh)
			if minz then
				minz = minz - 0.45
				setElementPosition(value.obj, x, y, z - minz)
				setElementRotation(value.obj, ry, -rx, rz + 90)
			end
		end
		-- Vehicle lights effects
		for veh, anim in pairs(gAnimations) do
			if not isElement(veh) then
				gAnimations[veh] = nil
				return
			end
			local tick = getTickCount()
			-- Police lights
			if anim.id == 1 then
				if tick - anim.tick  >= 800 then
					setVehicleLightState(veh, 0, anim.state and 1 or 0)
					setVehicleLightState(veh, 2, anim.state and 1 or 0)
					setVehicleLightState(veh, 1, anim.state and 0 or 1)
					setVehicleLightState(veh, 3, anim.state and 0 or 1)
					setVehicleHeadLightColor(veh, not anim.state and 255 or 0, 0, anim.state and 255 or 0)
					anim.state = not anim.state
					anim.tick = tick
				end
			-- Flashing lights
			elseif anim.id == 2 then
				if tick - anim.tick  >= 800 then
					local ls = getVehicleLightState(veh, 0) == 0 and 1 or 0
					for i = 0, 3 do
						setVehicleLightState(veh, i, ls)
					end
					anim.tick = tick
				end
			-- Disco headlights
			elseif anim.id == 3 then
				if tick - anim.tick  >= 200 then
					local ls = getVehicleLightState(veh, 2) == 0 and 1 or 0
					setVehicleLightState(veh, 2, ls)
					setVehicleLightState(veh, 3, ls)
					setVehicleLightState(veh, 0, 0)
					setVehicleLightState(veh, 1, 0)
					setVehicleHeadLightColor(veh, math.random(255), math.random(255), math.random(255))
					anim.tick = tick
				end
			-- Pilice 2
			elseif anim.id == 4 then
				if tick - anim.tick  >= 500 then
					local ls = getVehicleLightState(veh, 0)
					setVehicleLightState(veh, 0, ls == 0 and 1 or 0)
					setVehicleLightState(veh, 3, ls == 0 and 1 or 0)
					--
					setVehicleLightState(veh, 1, ls == 1 and 1 or 0)
					setVehicleLightState(veh, 2, ls == 1 and 1 or 0)
					anim.tick = tick
				end
			end
		end
	end
)
 
function setVehicleShadow(veh, dvo) -- Not finished yet
	if not isElementStreamedIn(veh) then return end
	if gShadows[veh] then
		destroyElement(gShadows[veh].shader)
		destroyElement(gShadows[veh].texture)
		destroyElement(gShadows[veh].obj)
		gShadows[veh] = nil
	end
	gShadows[veh] = {}
	local sh = gShadows[veh]
	local x, y, z = getElementPosition(veh)
	sh.obj = createObject(18085, x, y, z)
	sh.texture = dxCreateTexture("files/img/neon/" ..dvo.. ".png")
	sh.shader = dxCreateShader("files/shaders/neon/default.fx")
	dxSetShaderValue(sh.shader, "gTexture", sh.texture)
	engineApplyShaderToWorldTexture(sh.shader, "black256", sh.obj)
	setObjectScale(sh.obj, 0.86)
	setElementDimension(sh.obj, getElementDimension(localPlayer))
	setElementData(veh, "dvo.neon", dvo)
end

addEventHandler("onClientElementStreamIn", root,
	function()
		if not dvoEnabled then return end
		if getElementType(source) ~= "vehicle" then return end
		local dvo = getElementData(source, "dvo.light")
		if dvo then
			setVehicleLight(source, dvo)
		end
		dvo = getElementData(source, "dvo.paint")
		if dvo then
			setVehiclePaint(source, dvo)
		end
		dvo = getElementData(source, "light.effect")
		if dvo then
			setVehicleHeadlightAnim(source, dvo)
		end
		dvo = getElementData(source, "dvo.neon")
		if dvo then
			setVehicleShadow(source, dvo)
		end
	end
)

addEventHandler("onClientElementStreamOut", root,
	function()
		if getElementType(source) ~= "vehicle" then return end
		-- If element streams out, destroy the shader - texture
		-- Rear light DVO
		if isElement(gShadersLight[source]) then
			engineRemoveShaderFromWorldTexture(gShadersLight[source], "vehiclelightson128", source)
			destroyElement(gShadersLight[source])
			gShadersLight[source] = nil
	--		outputDebugString("[DVO] Destroying current shader for vehicle " ..getVehicleName(vehicle))
		end 
		-- Paint DVO
		if isElement(gShadersPaint[source]) then
			engineRemoveShaderFromWorldTexture(gShadersPaint[source], "map", source)
			engineRemoveShaderFromWorldTexture(gShadersPaint[source], "vehiclegrunge256", source)
			destroyElement(gShadersPaint[source])
			gShadersPaint[source] = nil
		--	outputDebugString("[DVO] Destroying current shader for vehicle " ..getVehicleName(vehicle))
		end
		-- Neons
		if gShadows[source] then
			destroyElement(gShadows[source].shader)
			destroyElement(gShadows[source].texture)
			destroyElement(gShadows[source].obj)
			gShadows[source] = nil
		end
		-- Lights
		if gAnimations[source] then
			gAnimations[source] = nil
		end
	end
)

addEventHandler("onClientElementDataChange", root,
	function(key, _, newdvo)
		if not dvoEnabled then return end
		if getElementType(source) ~= "vehicle" then return end
		if source == pVeh or source == gTune.vehicle then return end
		if getElementDimension(source) ~= getElementDimension(localPlayer) then return end
		if key == "dvo.light" then
			setVehicleLight(source, newdvo)
		elseif key == "dvo.paint" then
			setVehiclePaint(source, newdvo)
		elseif key == "light.effect" then
			setVehicleHeadlightAnim(source, newdvo)
		elseif key == "dvo.neon" then
			setVehicleShadow(source, newdvo)
		end
	end
)

function setVehicleHeadlightAnim(vehicle, id)
	if id == 100 and gAnimations[vehicle] then
		gAnimations[vehicle] = nil
		setElementData(vehicle, "light.effect", false)
		for i = 0, 3 do
			setVehicleLightState(vehicle, i, 0)
		end
		return
	end
	gAnimations[vehicle] = { id = id, tick = getTickCount(), state = true }
	setElementData(vehicle, "light.effect", id)
end

function setSkidmarkRainbow(bool)
	if not dvoEnabled then return end
	if bool then
		skidmarkShader = dxCreateShader("files/shaders/skidmarks/skidmarks.fx")
		if skidmarkShader then
			engineApplyShaderToWorldTexture(skidmarkShader, "particleskid")
			applySettings()
		end
	else
		if isElement(skidmarkShader) then
			engineRemoveShaderFromWorldTexture(skidmarkShader, "particleskid")
			destroyElement(skidmarkShader)
		end
	end
end

function applySettings()
	if not skidmarkShader then return end
	local v = {}
	v.hue1 = 0.00
    v.hue2 = 0.02
    v.hue3 = 0.06
    v.hue4 = 0.11
    v.alpha1 = 1.00
    v.alpha2 = 0.84
    v.alpha3 = 0.71
    v.alpha4 = 0.55
    v.saturation = 1.00
    v.lightness = 0.66
    v.pos_changes_hue = 0.39
    v.time_changes_hue = 0.13
    v.filth = 0.06
	dxSetShaderValue(skidmarkShader, "sHSVa1", v.hue1, v.saturation, v.lightness, v.alpha1)
	dxSetShaderValue(skidmarkShader, "sHSVa2", v.hue2, v.saturation, v.lightness, v.alpha2)
	dxSetShaderValue(skidmarkShader, "sHSVa3", v.hue3, v.saturation, v.lightness, v.alpha3)
	dxSetShaderValue(skidmarkShader, "sHSVa4", v.hue4, v.saturation, v.lightness, v.alpha4)
	dxSetShaderValue(skidmarkShader, "sPosAmount", v.pos_changes_hue)
	dxSetShaderValue(skidmarkShader, "sSpeed", v.time_changes_hue)
	dxSetShaderValue(skidmarkShader, "sFilth", v.filth)
end

addEventHandler("onClientSoundBeat", root,
	function(double)
	--	gBeat.goup = true 
	end
)

function RoundNumber(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local max_neons = 9
addCommandHandler("neon",
	function(_, neon)
		if not neon then
			outputChatBox("Usage: neon [1 - " ..max_neons.. "]")
		else
			neon = tonumber(neon)
			if neon > max_neons or neon < 1 then
				outputChatBox("Usage: neon [1 - " ..max_neons.. "]")
			else
				setVehicleShadow(pVeh, neon)
			end
		end
	end
)

function setDVOEnabled(bool)
	dvoEnabled = bool
	if not bool then
		-- Rear lights
		for source, dvo in pairs(gShadersLight) do
			engineRemoveShaderFromWorldTexture(dvo, "vehiclelightson128", source)
			destroyElement(dvo)
		end
		gShadersLight = {}
		-- Paint shader
		for source, paint in pairs(gShadersPaint) do
			engineRemoveShaderFromWorldTexture(paint, "map", source)
			engineRemoveShaderFromWorldTexture(paint, "vehiclegrunge256", source)
			destroyElement(paint)
		end
		gShadersPaint = {}
		-- Neons shader
		for _, sh in pairs(gShadows) do
			engineRemoveShaderFromWorldTexture(sh.shader, "black256", sh.obj)
			destroyElement(sh.obj)
			destroyElement(sh.texture)
			destroyElement(sh.shader)
		end
		gShadows = {}
		-- NOS shader
		if isElement(gNitroShader) then
			engineRemoveShaderFromWorldTexture(gNitroShader, "smoke")
			destroyElement(gNitroShader)
			gNitroShader = nil
		end
		-- Skidmark shader
		if isElement(skidmarkShader) then
			engineRemoveShaderFromWorldTexture(skidmarkShader, "particleskid")
			destroyElement(skidmarkShader)
			skidmarkShader = nil
		end
	else
		-- Restore DVOs
		local vehicles = getElementsByType("vehicle", root, true)
		for i = 1, #vehicles do
			local source = vehicles[i]
			local dvo = getElementData(source, "dvo.light")
			if dvo then
				setVehicleLight(source, dvo)
			end
			dvo = getElementData(source, "dvo.paint")
			if dvo then
				setVehiclePaint(source, dvo)
			end
			dvo = getElementData(source, "light.effect")
			if dvo then
				setVehicleHeadlightAnim(source, dvo)
			end
			dvo = getElementData(source, "dvo.neon")
			if dvo then
				setVehicleShadow(source, dvo)
			end
		end
	end
end