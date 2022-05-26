local carfade = {}
local carhide = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		bindKey("F3", "down", setCarFadeEnabled)
		bindKey("F4", "down", setCarHideEnabled)
	end
)

function setCarFadeEnabled()
	local status = getCarFadeEnabled()
	setCarFadeState(not status)
	outputChatBox("* Car fade is now " ..(carfade.enabled and "enabled" or "disabled"), 255, 255, 255)
	dxToggleSetState(fadecars, carfade.enabled)
end

function getCarFadeEnabled()
	return carfade.enabled
end

function setCarFadeState(bool)
	if bool then
		if not carfade.handler then
			addEventHandler("onClientRender", root, fadeCars)
			carfade.handler = true
		end
	else
		if carfade.handler then
			removeEventHandler("onClientRender", root, fadeCars)
			carfade.handler = false
			-- Restore alpha
			local players = getElementsByType("player")
			for i = 1, #players do
				setElementAlpha(players[i], 255)
			end
			local vehicles = getElementsByType("vehicle")
			for i = 1, #vehicles do
				if vehicles[i] ~= pVeh then
					setElementAlpha(vehicles[i], 255)
				end
			end
		end
	end
	carfade.enabled = bool
	panelsettings.fadecars = bool
end

function setCarHideEnabled()
	local status = not getCarHideEnabled()
	setCarHideState(status)
	if carhide.enabled then
		hideCars()
	end
	dxToggleSetState(hideplayers, carhide.enabled)
	outputChatBox("* Car hide is now " ..(carhide.enabled and "enabled" or "disabled"), 255, 255, 255)
end

function getCarHideEnabled()
	return carhide.enabled
end

function setCarHideState(bool)
	if bool then
		if not isTimer(carhide.timer) then
			carhide.timer = setTimer(hideCars, 100, 0)
		end
	else
		if isTimer(carhide.timer) then
			killTimer(carhide.timer)
			-- Restore dimension
			local vehicles = getElementsByType("vehicle")
			for i = 1, #vehicles do
				if vehicles[i] ~= pVeh then
					setElementDimension(vehicles[i], getElementDimension(localPlayer))
				end
			end
			local players = getElementsByType("player")
			for i = 1, #players do
				setElementDimension(players[i], getElementDimension(localPlayer))
			end
		end
	end
	carhide.enabled = bool
	panelsettings.carhide = bool
end

function fadeCars()
	if not pVeh then return end
	local vehicles = getElementsByType("vehicle", root, true) -- only streamed vehicles
	local x, y, z = getElementPosition(pVeh)
	for i = 1, #vehicles do
		if vehicles[i] ~= pVeh and not isElementLocal(vehicles[i]) then
			local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(vehicles[i]))
			local alpha = 80 + (dist * 3.5)
			alpha = alpha > 255 and 255 or alpha
			local int = getElementInterior(pVeh)
			alpha = int == 100 and 255 or alpha
			setElementAlpha(vehicles[i], alpha)
			local player = getVehicleController(vehicles[i])
			if player then
				setElementAlpha(player, alpha)
			end
		end
	end
end

function hideCars()
	if not pVeh then return end
	local int = getElementInterior(pVeh)
	local pdim = getElementDimension(localPlayer)
	local dimension = int == 100 and pdim or 100
	if pdim == 5 or pdim == 6 or getElementModel(pVeh) == 425 then -- disable for shooter and oj and hunter
		dimension = pdim
	end
	-- Hide vehicles
	local vehicles = getElementsByType("vehicle", root, true) -- only streamed vehicles
	for i = 1, #vehicles do
		if vehicles[i] ~= pVeh then
			setElementDimension(vehicles[i], dimension)
		end
	end
	-- Hide players
	local players = getElementsByType("player") -- only streamed players
	for i = 1, #players do
		if players[i] ~= localPlayer then
			setElementDimension(players[i], dimension)
		end
	end
end