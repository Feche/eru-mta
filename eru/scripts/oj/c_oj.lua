local MAX_BARRELS = 3
local BARREL_KEY = "f"

local handler = false
local target = nil
local veh = nil
local oldhealth = 0
local currwidth = 0
local progress = 0

local downprogress = 0
local currenty = 105
local hasnitro = false
local barrels = MAX_BARRELS
local barrelobj = nil

addEvent("race:onRaceMapStart", true)
addEvent("race:onRaceMapStop", true)

addEvent("lobby:onPlayerJoinLobby")

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "OJ" then
			target = getElementData(root, "oj.target")
			veh = getPedOccupiedVehicle(target)
			--
			barrelobj = createObject(1225, 0, 0, 0)
			setElementDimension(barrelobj, 6)
			setElementCollisionsEnabled(barrelobj, false) 
			attachElements(barrelobj, veh, 0, -3)
			--
			if not handler then
				addEventHandler("onClientPreRender", root, drawOJ)
				handler = true
			end
			if target == localPlayer then
				setElementData(target, "oj.barrels", MAX_BARRELS)
				barrels = MAX_BARRELS
			end
			bindKey(BARREL_KEY, "down", dropBarrel)
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "OJ" then
			unbindKey(BARREL_KEY, "down", dropBarrel)
			if isElement(barrelobj) then
				destroyElement(barrelobj)
			end
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		if handler then
			removeEventHandler("onClientPreRender", root, drawOJ)
			handler = false
		end
		unbindKey(BARREL_KEY, "down", dropBarrel)
		if isElement(barrelobj) then
			destroyElement(barrelobj)
		end
	end
)

function dropBarrel()
	if target == localPlayer and getElementDimension(barrelobj) == 6 then
		if barrels > 0 then
			local x, y, z = getPositionInfrontOfElement(pVeh, -3)
			local _, _, minz = getElementBoundingBox(pVeh)
			triggerServerEvent("oj:onOJDropBarrel", localPlayer, { x, y, (z - math.abs(minz)) + 0.5 })
			barrels = barrels - 1
			setElementData(target, "oj.barrels", barrels)
			setElementDimension(barrelobj, 100)
			if barrels > 0 then
				setTimer(
					function()
						if isElement(barrelobj) then
							setElementDimension(barrelobj, 6)
						end
					end
				, 15000, 1)
			end
		else
			showNotificationToPlayer("You don't have any more barrels", "error")
		end	
	end
end

function drawOJ()
	if gRace.progress == 0 then
		removeEventHandler("onClientPreRender", root, drawOJ)
		handler = false
	end
	local x, y
	local www = 0
	x = sx - 170
	y = 0
	downprogress = downprogress + 0.08 > 1 and 1 or downprogress + 0.08
	if getVehicleNitroLevel(veh) then
		if not hasnitro then
			hasnitro = true
			downprogress = 0
		end
		y = interpolateBetween(currenty, 0, 0, 130, 0, 0, downprogress, "Linear")
	else
		if hasnitro then
			hasnitro = false
			downprogress = 0
		end
		y = interpolateBetween(currenty, 0, 0, 105, 0, 0, downprogress, "Linear")
	end
	if downprogress == 1 then
		currenty = y
	end
	local width = dxGetTextWidth(getPlayerNameNoColor(target), 0.6, "bankgothic")
	local height = 12
	local tx = (sx - (170 / 2)) - (width / 2)
	local offx = 0
	if width > 170 then
		offx = (width - 170)
		tx = tx - offx
	end
	dxDrawText(getPlayerNameNoColor(target), tx + 1, y + 1, tx + 1, y + 1, tocolor(0, 0, 0, 255 * gRace.progress), 0.6, "bankgothic", "left", "top")
	dxDrawText(getPlayerName(target), tx, y, tx, y, tocolor(255, 255, 255, 255 * gRace.progress), 0.6, "bankgothic", "left", "top", false, false, false, true)
	-- OJ health
	y = y + 22
	local health = getElementHealth(veh) - 250
	local healthw = (health / 750) * width
	local healthp = (health / 75) * 0.1
	healthp = healthp < 0 and 0 or healthp
	healthw = healthw < 0 and 0 or healthw
	if oldhealth ~= health then
		oldhealth = health
		progress = 0
	end
	progress = progress + 0.08 > 1 and 1 or progress + 0.08
	local www = interpolateBetween(currwidth, 0, 0, healthw, 0, 0, progress, "Linear")
	dxDrawRectangle(tx, y, width, height, tocolor(0, 0, 0, 150))
	local r, g, b = interpolateBetween(255, 0, 0, 0, 240, 0, healthp, "Linear")
	dxDrawRectangle(tx + 2, y + 2, currwidth - 4, height - 4, tocolor(r, g, b, 255 * gRace.progress))
	currwidth = www
	-- Barrels text
	dxDrawText("Barrels: " ..(getElementData(target, "oj.barrels") or "?").. "/" ..MAX_BARRELS, tx, y + 15, tx + width, y, tocolor(255, 255, 255, 255 * gRace.progress), 1, "roboto", "center", "top")
	-- OJ text
	width = dxGetTextWidth("OJ", 1, "bankgothic")
	tx = (sx - (170 / 2)) - (width / 2) - offx
	dxDrawText("OJ", tx + 2, y + 2 - 52, tx + 2, y + 2 - 52, tocolor(0, 0, 0, 255 * gRace.progress), 1, "bankgothic", "left", "top")
	dxDrawText("OJ", tx, y - 52, tx, y - 52, tocolor(255, 255, 255, 255 * gRace.progress), 1, "bankgothic", "left", "top", false, false, false, true)
	-- Drop barrel text
	if target == localPlayer then
		dxDrawText("Press #808080" ..BARREL_KEY:upper().. " #FFFFFFto drop a barrel", 0, 0, sx, sy - 5, tocolor(255, 255, 255, 255 * gRace.progress), 1.6, "roboto", "center", "bottom", false, false, false, true)
	end
end