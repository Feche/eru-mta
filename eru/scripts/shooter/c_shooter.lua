local COOLDOWN_TIME = 2500
local KILL_MSG_TIME = 3000

local jumpTick = getTickCount()
local shootTick = getTickCount()
local currentCooldown = COOLDOWN_TIME
local handler = false

local killed = {}
local vehsowner = {}

local gProjectiles = {}

addEvent("race:onPlayerWin", true)
addEvent("race:onRaceMapStart")
addEvent("race:onRaceMapStop")

addEvent("lobby:onPlayerJoinLobby")

setDevelopmentMode(true)

addEventHandler("race:onPlayerWin", root,
	function()
		currentCooldown = 1
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Shooter" then
			bindKey("lctrl", "down", shootProyectile)
			bindKey("rctrl", "down", shootProyectile)
			bindKey("lalt", "down", shootProyectile)
			bindKey("mouse1", "down", shootProyectile)
			bindKey("mouse2", "down", shootProyectile)
			bindKey("lshift", "down", jumpPlayer)
			bindKey("rshift", "down", jumpPlayer)
			outputChatBox("Shoot by pressing CTRL/ALT, jump pressing SHIFT", 255, 255, 0)
			if not handler then
				addEventHandler("onClientPreRender", root, drawShooter)
				handler = true
			end
			killed = {}
			local vehicles = getElementsByType("vehicle", true)
			for i = 1, #vehicles do
				vehsowner[vehicles[i]] = getVehicleController(vehicles[i])
			end
			currentCooldown = COOLDOWN_TIME
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "Shooter" then
			unbindKey("lctrl", "down", shootProyectile)
			unbindKey("rctrl", "down", shootProyectile)
			unbindKey("lalt", "down", shootProyectile)
			unbindKey("mouse1", "down", shootProyectile)
			unbindKey("mouse2", "down", shootProyectile)
			unbindKey("lshift", "down", jumpPlayer)
			unbindKey("rshift", "down", jumpPlayer)
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		unbindKey("lctrl", "down", shootProyectile)
		unbindKey("rctrl", "down", shootProyectile)
		unbindKey("lalt", "down", shootProyectile)
		unbindKey("mouse1", "down", shootProyectile)
		unbindKey("mouse2", "down", shootProyectile)
		unbindKey("lshift", "down", jumpPlayer)
		unbindKey("rshift", "down", jumpPlayer)
		if handler then
			removeEventHandler("onClientPreRender", root, drawShooter)
			handler = false
		end
	end
)

addEventHandler("onClientExplosion", root,
	function(x, y, z, tp)
		if tp == 2 then -- Rocket
			local vehicles = getElementsByType("vehicle", true)
			for i = 1, #vehicles do
				local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(vehicles[i]))
				if dist <= 10 then
					setTimer(
						function(source, vehicle)
							if getElementHealth(vehicle) == 0 then
								if source ~= vehsowner[vehicle] then
									addToKillList(getPlayerName(source), getPlayerName(vehsowner[vehicle]))
									if source == localPlayer then
										triggerServerEvent("shooter:addPlayerShooterKill", source)
									end
								else
									addToKillList(getPlayerName(source))
								end
							end
						end
					, 1000, 1, source, vehicles[i])
				end
			end
		end
	end
)

addEventHandler("onClientElementDestroy", root,
	function()
		-- Remove projectile on explosion
		for i = 1, #gProjectiles do
			if gProjectiles[i] == source then
				table.remove(gProjectiles, i)
				break
			end
		end
	end
)

addEventHandler("onClientProjectileCreation", root,
	function()
		table.insert(gProjectiles, source)
	end
)

local width, height = 350, 20
function drawShooter()
	local x, y, sprogress, jprogress
	-- Shoot load
	x = sx / 2 - width / 2
	y = sy - height - height - 10
	local shootTimePassed = shootTick - getTickCount()
	shootTimePassed = currentCooldown - shootTimePassed
	sprogress = ((shootTimePassed / currentCooldown) * 1) - 1
	sprogress = sprogress > 1 and 1 or sprogress
	dxDrawRoundedRectangle(x, y, width, height, tocolor(0, 0, 0, 150), 10)
	dxDrawRoundedRectangle(x + 5, y + 5, (width - 10) * sprogress, height - 10, tocolor(255, 0, 0, 150 * gRace.progress), 5)
	-- Jump load
	local jumpTimePassed = jumpTick - getTickCount()
	jumpTimePassed = currentCooldown - jumpTimePassed
	sprogress = ((jumpTimePassed / currentCooldown) * 1) - 1
	sprogress = sprogress > 1 and 1 or sprogress
	y = sy - height - 5
	dxDrawRoundedRectangle(x, y, width, height, tocolor(0, 0, 0, 150), 10)
	dxDrawRoundedRectangle(x + 5, y + 5, (width - 10) * sprogress, height - 10, tocolor(0, 255, 0, 150 * gRace.progress), 5)
	-- Kill list
	for i, val in pairs(killed) do
		if val.goup then
			val.progress = val.progress + 0.01 > 1 and 1 or val.progress + 0.01
			if val.progress == 1 then
				val.goup = false
				val.tick = getTickCount()
			end
		elseif not val.goup then
			if getTickCount() - val.tick >= KILL_MSG_TIME then
				val.progress = val.progress - 0.01 < 0 and 0 or val.progress - 0.01
				if val.progress == 0 then
					killed[i] = nil
				end
			end
		end
		local y = 200 + ((i - 1) * 28)
		if val.target then
			dxDrawText(val.target, 0, y, sx - 5, y, tocolor(255, 255, 255, 255 * val.progress), 1, "roboto", "right", "center", false, false, false, true)
			local width = dxGetTextWidth(val.target:gsub("#%x%x%x%x%x%x", ""), 1, "roboto") + 5
			dxDrawImage(sx - width - 34, y - 19, 32, 32, "files/img/killmsg/boom.png", 0, 0, 0, tocolor(255, 255, 255, 255 * val.progress))
			local x = sx - width - 36 - dxGetTextWidth(val.killer:gsub("#%x%x%x%x%x%x", ""), 1, "roboto")
			dxDrawText(val.killer, x, y, x, y, tocolor(255, 255, 255, 255 * val.progress), 1, "roboto", "left", "center", false, false, false, true)
		else
			dxDrawText(val.killer, 0, y, sx - 5, y, tocolor(255, 255, 255, 255 * val.progress), 1, "roboto", "right", "center", false, false, false, true)
			local width = dxGetTextWidth(val.killer:gsub("#%x%x%x%x%x%x", ""), 1, "roboto") + 5
			dxDrawImage(sx - width - 26, y - 15, 26, 26, "files/img/killmsg/dead.png", 0, 0, 0, tocolor(255, 255, 255, 255 * val.progress))
		end
	end
	--
	if gRace.progress == 0 then
		removeEventHandler("onClientPreRender", root, drawShooter)
		handler = false
	end
end

function shootProyectile()
	if getElementData(localPlayer, "state") ~= "alive" then return end
	local tick = getTickCount()
	if tick - shootTick >= currentCooldown then
		local x, y, z = getPositionInfrontOfElement(pVeh, 1)
		local proj = createProjectile(pVeh, 19, x, y, z)
--		setElementData(proj, "proj.owner", localPlayer)
		shootTick = tick
	end
end

function jumpPlayer()
	if getElementData(localPlayer, "state") ~= "alive" then return end
	local tick = getTickCount()
	if tick - jumpTick >= currentCooldown then
		local vx, vy, vz = getElementVelocity(pVeh)
		setElementVelocity(pVeh, vx, vy, vz + 0.35)
		jumpTick = tick
	end
end

function addToKillList(killer, target)
	local idx = 0
	while true do
		idx = idx + 1
		if not killed[idx] then
			killed[idx] = { killer = killer, target = target and target or nil, progress = 0, goup = true, tick = getTickCount() }
			break
		end
	end
end

function getProjectiles()
	return gProjectiles
end

function getPositionInfrontOfElement(element, meters)
	if (not element or not isElement(element)) then return false end
	local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end