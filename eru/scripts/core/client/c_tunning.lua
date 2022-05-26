local ROAD_LENGHT = 171.01
local TOTAL_DVO = 0
local TOTAL_PAINTS = 0
local TOTAL_LIGHTS = 4
local NUMBER_ROADS = 10
local gRoads = 0
local vWheels =
{
	1025, 1082,
	1073, 1083,
	1074, 1084,
	1075, 1085,
	1076, 1096,
	1077, 1097,
	1078, 1098,
	1079, 
	1080,
	1081,
	  -1
}
local wheelidx = 18
local dvoidx = 64
local paintidx = 24
local lightidx = 0

local btnzPrgz = {}

gTune =
{
	buttons = {},
	handler = false,
	road = {},
	vehicle = nil,
	ped = nil,
	selected = 0,
	camprogress = 0,
	camprogressup = false,
	mainprogress = 0,
	menuesprogress = 0
}

local oldx, oldy, oldz = 0, 0, 0

local wheelButton = {}
local lightButton = {}
local paintButton = {}
local plateButton = {}
local frontLightButton = {}

local nitrotimer = nil

addEvent("cpicker:onPickerColorChange")
addEvent("cpicker:onClientClickButton")

local starttick = getTickCount()
local starty = 0
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- Wheels
		local x = sx / 2 - 118
		wheelButton[1] = { x = x, y = sy - 50, width = 45, height = 45, progress = 0 }
		wheelButton[2] = { x = x + 200, y = sy - 50, width = 45, height = 45, progress = 0 }
		wheelButton[3] = { x = x + 60, y = sy - 34, width = 130, height = 30, progress = 0 }
		-- Lights
		lightButton[1] = { x = x, y = sy - 50, width = 45, height = 45, progress = 0 }
		lightButton[2] = { x = x + 200, y = sy - 50, width = 45, height = 45, progress = 0 }
		lightButton[3] = { x = x + 65, y = sy - 34, width = 120, height = 30, progress = 0 }
		-- Paint
		paintButton[1] = { x = x, y = sy - 50, width = 45, height = 45, progress = 0 }
		paintButton[2] = { x = x + 200, y = sy - 50, width = 45, height = 45, progress = 0 }
		paintButton[3] = { x = x + 65, y = sy - 34, width = 120, height = 30, progress = 0 }
		-- Front light
		frontLightButton[1] = { x = x, y = sy - 50, width = 45, height = 45, progress = 0 }
		frontLightButton[2] = { x = x + 200, y = sy - 50, width = 45, height = 45, progress = 0 }
		frontLightButton[3] = { x = x + 65, y = sy - 34, width = 120, height = 30, progress = 0 }
		--
		for i = 1, 6 do
			btnzPrgz[i] = 0
		end
		--
		pickervehcolor = createColorPicker(10, sy - 304 - 10, 200, "Select the color")
		colorPickerAddButton(pickervehcolor, 328, 264, 80, 25, "Buy [$25k]", "Normal color")
		colorPickerAddButton(pickervehcolor, 328, 264 - 40, 80, 25, "Buy [$150k]", "")
		colorPickerAddButton(pickervehcolor, 328, 264 - 70, 80, 25, "Remove paint", "Animated color")
		--
		pickernoscolor = createColorPicker(10, sy - 304 - 10, 200, "Select the color")
		colorPickerAddButton(pickernoscolor, 328, 264, 80, 25, "Buy [$45k]", "NOS color")
		--
		pickerlightcolor = createColorPicker(10, sy - 304 - 10, 200, "Select the color")
		colorPickerAddButton(pickerlightcolor, 328, 264, 80, 25, "Buy [$20k]", "Light color")
		colorPickerAddButton(pickerlightcolor, 328, 264 - 40, 80, 25, "Buy [$60k]", "")
		colorPickerAddButton(pickerlightcolor, 328, 264 - 70, 80, 25, "Remove", "Animated light")
		local width, height = 200, 50
		plateButton = { x = sx / 2 - width / 2, y = sy - ((330 / 1080) * sy), width = width, height = height, selected = false, progress = 1, buyprogress = 0, text = "" }
		--
		TOTAL_DVO = getElementData(localPlayer, "total.dvos") + 1
		TOTAL_PAINTS = getElementData(localPlayer, "total.paints") + 1
	end
)

addEventHandler("cpicker:onPickerColorChange", root,
	function(r, g, b)
		-- Paint
		if gTune.selected == 3 then
			removeVehiclePaint(gTune.vehicle)
			setVehicleColor(gTune.vehicle, r, g, b, r, g, b, r, g, b, r, g, b)
		-- NOS
		elseif gTune.selected == 4 then
			setVehicleNitroColor(r, g, b)
		-- Front ligths
		elseif gTune.selected == 6 then
			setVehicleHeadLightColor(gTune.vehicle, r, g, b)
		end
	end
)

addEventHandler("cpicker:onClientClickButton", root,
	function(bttntext)
		-- Nos color
		if bttntext == "Buy [$45k]" then
			local r, g, b = getPickerRGB(pickernoscolor)
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "nos", _, r, g, b)
		-- Plate text
		elseif bttntext == "Buy plate [$10k]" then
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "plate", plateButton.text)
		-- Paint
		elseif bttntext == "Remove paint" then
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "paint", -1)
			removeVehiclePaint(gTune.vehicle)
			removeVehiclePaint(pVeh)
		elseif bttntext == "Buy [$150k]" then
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "paint", paintidx)
		elseif bttntext == "Buy [$25k]" then
			local r, g, b = getPickerRGB(pickervehcolor)
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "paint", 100, r, g, b)
			removeVehiclePaint(gTune.vehicle)
			removeVehiclePaint(pVeh)
		-- Front lights
		elseif bttntext == "Remove" then
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "front lights", -1)
			setVehicleHeadLightColor(gTune.vehicle, 255, 255, 255)
			setVehicleHeadlightAnim(gTune.vehicle, 100)
		elseif bttntext == "Buy [$60k]" then
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "front lights", lightidx)
		elseif bttntext == "Buy [$20k]" then
			local r, g, b = getPickerRGB(pickerlightcolor)
			triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "front lights", 100, r, g, b)
		end
	end
)

function drawTunning()
	if not isElement(gTune.vehicle) then
		return stopTunning()
	end
	-- Reset position if reached end
	local _, vehy = getElementPosition(gTune.vehicle)
--	outputChatBox(vehy)
	if vehy >= (ROAD_LENGHT * NUMBER_ROADS) - 400 then
		local x, y, z = getElementPosition(gTune.vehicle)
		setElementPosition(gTune.vehicle, x, 400, z)
		setElementVelocity(gTune.vehicle, getElementVelocity(gTune.vehicle))
	end
	--
	if gTune.camprogressup then
		gTune.camprogress = gTune.camprogress + 0.08 > 1 and 1 or gTune.camprogress + 0.08
	else
		gTune.camprogress = gTune.camprogress - 0.08 < 0 and 0 or gTune.camprogress - 0.08
	end
	local cx, cy = getCursorPosition()
	cx = cx and cx * sx
	cy = cy and cy * sy
	-- Main menu
	if gTune.selected == 0 then
		local px, py, pz = interpolateBetween(-7, -7, 2, oldx, oldy, oldz, gTune.camprogress, "Linear")
		local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, px, py, pz)
		local vx, vy, vz = getElementPosition(gTune.vehicle)
		local yoffs = 0
		if oldcamy then
			yoffs = interpolateBetween(oldcamy, 0, 0, 0, 0, 0, gTune.mainprogress, "Linear")
			if gTune.mainprogress == 1 then
				oldcamy = nil
			end
		end
		setCameraMatrix(camx, camy, camz, vx, vy + yoffs, vz)
		gTune.mainprogress = gTune.mainprogress + 0.08 > 1 and 1 or gTune.mainprogress + 0.08
		gTune.menuesprogress = gTune.menuesprogress - 0.08 < 0 and 0 or gTune.menuesprogress - 0.08
		dxDrawText("Press #808080right click #ffffffto go back to lobby", 0, 0, sx, sy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1, "default-bold", "center", "top", false, false, false, true)
	else	
		if not cx then return end
		gTune.menuesprogress = gTune.menuesprogress + 0.08 > 1 and 1 or gTune.menuesprogress + 0.08
		gTune.mainprogress = gTune.mainprogress - 0.08 < 0 and 0 or gTune.mainprogress - 0.08
		if gTune.selected ~= 5 and gTune.selected ~= 4 then
			dxDrawText("Press #808080right click #ffffffto go back\nNavigate through modifications with your #808080keyboard arrows #ffffff <- | ->", 0, 0, sx, sy, tocolor(255, 255, 255, 255 * gTune.menuesprogress), 1, "default-bold", "center", "top", false, false, false, true)
		end
		-- Wheels
		if gTune.selected == 1 then
			local ofx, ofy = interpolateBetween(-7, -7, 2, -10, 0, 2, gTune.camprogress, "Linear")
			oldx, oldy, oldz = -10, 0, 2
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, 2)
			setCameraMatrix(camx, camy, camz, getElementPosition(gTune.vehicle))
			--
			local x, y, w, h = wheelButton[1].x, wheelButton[1].y, wheelButton[1].width, wheelButton[1].height
			local r, g, b, a
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				wheelButton[1].progress = wheelButton[1].progress + 0.08 > 1 and 1 or wheelButton[1].progress + 0.08
			else
				wheelButton[1].progress = wheelButton[1].progress - 0.08 < 0 and 0 or wheelButton[1].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, wheelButton[1].progress, "Linear")
			dxDrawText("<", x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText("<", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = wheelButton[2].x, wheelButton[2].y
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				wheelButton[2].progress = wheelButton[2].progress + 0.08 > 1 and 1 or wheelButton[2].progress + 0.08
			else
				wheelButton[2].progress = wheelButton[2].progress - 0.08 < 0 and 0 or wheelButton[2].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, wheelButton[2].progress, "Linear")
			dxDrawText(">", x - 1, y + 1, x - 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText(">", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = wheelButton[3].x, wheelButton[3].y
			if cx >= x and cx <= x + wheelButton[3].width and cy >= y and cy <= y + wheelButton[3].height then
				wheelButton[3].progress = wheelButton[3].progress + 0.08 > 1 and 1 or wheelButton[3].progress + 0.08
			else
				wheelButton[3].progress = wheelButton[3].progress - 0.08 < 0 and 0 or wheelButton[3].progress - 0.08
			end
			r, g, a = interpolateBetween(0, 0, 150, 255, 165, 255, wheelButton[3].progress, "Linear")
			dxDrawRoundedRectangle(x, y, wheelButton[3].width, wheelButton[3].height, tocolor(r, g, 0, a), 10)
			dxDrawText("Buy wheel [$20k]", x, y, x + wheelButton[3].width, y + wheelButton[3].height, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
			dxDrawText(wheelidx.. "/" ..#vWheels, x + 1, y - 24 + 1, x + wheelButton[3].width + 1, y + wheelButton[3].height - 24 + 1, tocolor(0, 0, 0, 255), 1.2, "default-bold", "center", "center")
			dxDrawText(wheelidx.. "/" ..#vWheels, x, y - 24, x + wheelButton[3].width, y + wheelButton[3].height - 24, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
		-- Rear lights
		elseif gTune.selected == 2 then
			local ofx, ofy, ofz = interpolateBetween(-7, -7, 2, 0, -6, 1, gTune.camprogress, "Linear")
			oldx, oldy, oldz = 0, -6, 1
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, ofz)
			setCameraMatrix(camx, camy, camz, getElementPosition(gTune.vehicle))
			--
			local x, y, w, h = lightButton[1].x, lightButton[1].y, lightButton[1].width, lightButton[1].height
			local r, g, b, a
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				lightButton[1].progress = lightButton[1].progress + 0.08 > 1 and 1 or lightButton[1].progress + 0.08
			else
				lightButton[1].progress = lightButton[1].progress - 0.08 < 0 and 0 or lightButton[1].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, lightButton[1].progress, "Linear")
			dxDrawText("<", x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText("<", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = lightButton[2].x, lightButton[2].y
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				lightButton[2].progress = lightButton[2].progress + 0.08 > 1 and 1 or lightButton[2].progress + 0.08
			else
				lightButton[2].progress = lightButton[2].progress - 0.08 < 0 and 0 or lightButton[2].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, lightButton[2].progress, "Linear")
			dxDrawText(">", x - 1, y + 1, x - 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText(">", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = lightButton[3].x, lightButton[3].y
			if cx >= x and cx <= x + lightButton[3].width and cy >= y and cy <= y + lightButton[3].height then
				lightButton[3].progress = lightButton[3].progress + 0.08 > 1 and 1 or lightButton[3].progress + 0.08
			else
				lightButton[3].progress = lightButton[3].progress - 0.08 < 0 and 0 or lightButton[3].progress - 0.08
			end
			r, g, a = interpolateBetween(0, 0, 150, 255, 165, 255, lightButton[3].progress, "Linear")
			dxDrawRoundedRectangle(x, y, lightButton[3].width, lightButton[3].height, tocolor(r, g, 0, a), 10)
			dxDrawText("Buy light [$50k]", x, y, x + lightButton[3].width, y + lightButton[3].height, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
			dxDrawText(dvoidx.. "/" ..TOTAL_DVO, x + 1, y - 24 + 1, x + lightButton[3].width + 1, y + lightButton[3].height - 24 + 1, tocolor(0, 0, 0, 255), 1.2, "default-bold", "center", "center")
			dxDrawText(dvoidx.. "/" ..TOTAL_DVO, x, y - 24, x + lightButton[3].width, y + lightButton[3].height - 24, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
		-- Paint
		elseif gTune.selected == 3 then
			local ofx, ofy, ofz = interpolateBetween(-7, -7, 2, -8, 0, 4, gTune.camprogress, "Linear")
			oldx, oldy, oldz = -8, 0, 4
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, ofz)
			setCameraMatrix(camx, camy, camz, getElementPosition(gTune.vehicle))
			--
			local x, y, w, h = paintButton[1].x, paintButton[1].y, paintButton[1].width, paintButton[1].height
			local r, g, b, a
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				paintButton[1].progress = paintButton[1].progress + 0.08 > 1 and 1 or paintButton[1].progress + 0.08
			else
				paintButton[1].progress = paintButton[1].progress - 0.08 < 0 and 0 or paintButton[1].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, paintButton[1].progress, "Linear")
			dxDrawText("<", x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText("<", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = paintButton[2].x, paintButton[2].y
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				paintButton[2].progress = paintButton[2].progress + 0.08 > 1 and 1 or paintButton[2].progress + 0.08
			else
				paintButton[2].progress = paintButton[2].progress - 0.08 < 0 and 0 or paintButton[2].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, paintButton[2].progress, "Linear")
			dxDrawText(">", x - 1, y + 1, x - 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText(">", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = paintButton[3].x, paintButton[3].y
			dxDrawText(paintidx.. "/" ..TOTAL_PAINTS, x + 1, y + 10 + 1, x + paintButton[3].width + 1, y + paintButton[3].height - 24 + 1, tocolor(0, 0, 0, 255), 1.2, "bankgothic", "center", "center")
			dxDrawText(paintidx.. "/" ..TOTAL_PAINTS, x, y + 10, x + paintButton[3].width, y + paintButton[3].height - 24, tocolor(255, 255, 255, 255), 1.2, "bankgothic", "center", "center")
		-- nos
		elseif gTune.selected == 4 then
			local ofx, ofy, ofz = interpolateBetween(-7, -7, 2, 0, -5, 5, gTune.camprogress, "Linear")
			oldx, oldy, oldz = 0, -5, 5
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, ofz)
			local vx, vy, vz = getElementPosition(gTune.vehicle)
			local smooth = interpolateBetween(0, 0, 0, 2.2, 0, 0, gTune.camprogress, "Linear")
			setCameraMatrix(camx, camy, camz, vx, vy - smooth, vz)
			oldcamy = -2.2
			--
		-- Licence plate
		elseif gTune.selected == 5 then
			local ofx, ofy, ofz = interpolateBetween(-7, -7, 2, 0, -4, 0.4, gTune.camprogress, "Linear")
			oldx, oldy, oldz = 0, -4, 0.4
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, ofz)
			local vx, vy, vz = getElementPosition(gTune.vehicle)
			setCameraMatrix(camx, camy, camz, vx, vy, vz)
			--
			local x, y, width, height = plateButton.x, plateButton.y, plateButton.width, plateButton.height
			dxDrawRoundedRectangle(x, y, width, height, tocolor(0, 0, 0, 220), 10)
			if plateButton.selected then
				plateButton.progress = plateButton.progress - 0.08 < 0 and 0 or plateButton.progress - 0.08
				dxDrawText("|", x, y, x + width + dxGetTextWidth(plateButton.text, 1, "default-bold") + 10, y + height, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
			else
				plateButton.progress = plateButton.progress + 0.08 > 1 and 1 or plateButton.progress + 0.08
			end
			if #plateButton.text > 0 then
				dxDrawText(plateButton.text, x, y, x + width, y + height, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center", "center")
			else
				dxDrawText("Set your plate text", x, y, x + width, y + height, tocolor(255, 255, 255, 255 * plateButton.progress), 1.4, "default-bold", "center", "center")
			end
			-- Button
			if cx >= x + 50 and cx <= x + 160 and cy >= y + 55 and cy <= y + 85 then
				plateButton.buyprogress = plateButton.buyprogress + 0.08 > 1 and 1 or plateButton.buyprogress + 0.08
			else
				plateButton.buyprogress = plateButton.buyprogress - 0.08 < 0 and 0 or plateButton.buyprogress - 0.08
			end
			local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, plateButton.buyprogress, "Linear")
			dxDrawRoundedRectangle(x + 50, y + 55, 110, 30, tocolor(r, g, b, 220), 10)
			dxDrawText("Buy plate [$10k]", x + 50, y + 55, x + 160, y + 85, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "center")
		elseif gTune.selected == 6 then
			local ofx, ofy, ofz = interpolateBetween(-7, -7, 2, 0, 7, 0.4, gTune.camprogress, "Linear")
			oldx, oldy, oldz = 0, 7, 0.4
			local camx, camy, camz = getPositionFromElementOffset(gTune.vehicle, ofx, ofy, ofz)
			local vx, vy, vz = getElementPosition(gTune.vehicle)
			setCameraMatrix(camx, camy, camz, vx, vy, vz)
			--
			local x, y, w, h = frontLightButton[1].x, frontLightButton[1].y, frontLightButton[1].width, frontLightButton[1].height
			local r, g, b, a
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				frontLightButton[1].progress = frontLightButton[1].progress + 0.08 > 1 and 1 or frontLightButton[1].progress + 0.08
			else
				frontLightButton[1].progress = frontLightButton[1].progress - 0.08 < 0 and 0 or frontLightButton[1].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, frontLightButton[1].progress, "Linear")
			dxDrawText("<", x + 1, y + 1, x + 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText("<", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = frontLightButton[2].x, frontLightButton[2].y
			if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
				frontLightButton[2].progress = frontLightButton[2].progress + 0.08 > 1 and 1 or frontLightButton[2].progress + 0.08
			else
				frontLightButton[2].progress = frontLightButton[2].progress - 0.08 < 0 and 0 or frontLightButton[2].progress - 0.08
			end
			r, g, b = interpolateBetween(255, 255, 255, 255, 165, 0, frontLightButton[2].progress, "Linear")
			dxDrawText(">", x - 1, y + 1, x - 1, y + 1, tocolor(0, 0, 0, 255), 2, "bankgothic")
			dxDrawText(">", x, y, x, y, tocolor(r, g, b, 255), 2, "bankgothic")
			x, y = frontLightButton[3].x, frontLightButton[3].y
			dxDrawText(lightidx.. "/" ..TOTAL_LIGHTS, x + 1, y + 10 + 1, x + frontLightButton[3].width + 1, y + frontLightButton[3].height - 24 + 1, tocolor(0, 0, 0, 255), 1.2, "bankgothic", "center", "center")
			dxDrawText(lightidx.. "/" ..TOTAL_LIGHTS, x, y + 10, x + frontLightButton[3].width, y + frontLightButton[3].height - 24, tocolor(255, 255, 255, 255), 1.2, "bankgothic", "center", "center")
		end
	--	setVehicleHeadlightAnim(vehicle, id)
	end
	-- INTERFACE UI
	-- Wheels
	if not cx then return end
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "wheel_lb_dummy", "world"))
	if x then
		local relx, rely = (20 / 1920) * sx, (-12 / 1080) * sy
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + -168, starty + 187
		local linepos = -150
		gTune.buttons[1] = { x = endx + linepos, y = endy - 40, endx = endx, endy = endy, linepos = linepos, tp = "wheels" }
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx + linepos and cx <= endx + linepos + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[1] = btnzPrgz[1] + 0.08 > 1 and 1 or btnzPrgz[1] + 0.08
		else
			btnzPrgz[1] = btnzPrgz[1] - 0.08 < 0 and 0 or btnzPrgz[1] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[1], "Linear")
		dxDrawRoundedRectangle(endx + linepos, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		dxDrawText("WHEELS", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
	-- Back lights
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "bump_rear_dummy", "world"))
	if x then
		local relx, rely = 0, (50 / 1080) * sy
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + 215, starty + 288
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		local linepos = 150
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx and cx <= endx + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[2] = btnzPrgz[2] + 0.08 > 1 and 1 or btnzPrgz[2] + 0.08
		else
			btnzPrgz[2] = btnzPrgz[2] - 0.08 < 0 and 0 or btnzPrgz[2] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[2], "Linear")
		dxDrawRoundedRectangle(endx, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		gTune.buttons[2] = { x = endx, y = endy - 40, tp = "rear lights" }
		dxDrawText("REAR LIGHTS", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
	-- Vehicle paint
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "door_lf_dummy", "world"))
	if x then
		local relx, rely = (-50 / 1920) * sx, 0
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + -200, starty + 190
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		local linepos = -150
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx + linepos and cx <= endx + linepos + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[3] = btnzPrgz[3] + 0.08 > 1 and 1 or btnzPrgz[3] + 0.08
		else
			btnzPrgz[3] = btnzPrgz[3] - 0.08 < 0 and 0 or btnzPrgz[3] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[3], "Linear")
		dxDrawRoundedRectangle(endx + linepos, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		gTune.buttons[3] = { x = endx + linepos, y = endy - 40, tp = "paint" }
		dxDrawText("VEHICLE PAINT", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
	-- Front lights
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "bump_front_dummy", "world"))
	if x then
		local relx, rely = (25 / 1920) * sx, (35 / 1080) * sy
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + -200, starty + -200
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		local linepos = -150
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx + linepos and cx <= endx + linepos + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[4] = btnzPrgz[4] + 0.08 > 1 and 1 or btnzPrgz[4] + 0.08
		else
			btnzPrgz[4] = btnzPrgz[4] - 0.08 < 0 and 0 or btnzPrgz[4] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[4], "Linear")
		dxDrawRoundedRectangle(endx + linepos, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		gTune.buttons[4] = { x = endx + linepos, y = endy - 40, tp = "front lights" }
		dxDrawText("FRONT LIGHTS", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
	-- NOS color
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "bump_rear_dummy", "world"))
	if x then
		local relx, rely = (-150 / 1920) * sx, (20 / 1080) * sy
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + 290, starty + -253
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		local linepos = 150
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx and cx <= endx + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[5] = btnzPrgz[5] + 0.08 > 1 and 1 or btnzPrgz[5] + 0.08
		else
			btnzPrgz[5] = btnzPrgz[5] - 0.08 < 0 and 0 or btnzPrgz[5] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[5], "Linear")
		dxDrawRoundedRectangle(endx, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		gTune.buttons[5] = { x = endx, y = endy - 40, tp = "nos" }
		dxDrawText("NOS COLOR", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
	-- Licence plate
	local x, y = getScreenFromWorldPosition(getVehicleComponentPosition(gTune.vehicle, "bump_rear_dummy", "world"))
	if x then
		local relx, rely = (-120 / 1920) * sx, (100 / 1080) * sy
		local startx, starty = x - relx, y - rely
		local endx, endy = startx + -180, starty + -218
		dxDrawLine(startx, starty, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		local linepos = -150
		dxDrawLine(endx, endy, endx + linepos, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress))
		if cx >= endx + linepos and cx <= endx + linepos + 145 and cy >= endy - 40 and cy <= endy - 40 + 35 then
			btnzPrgz[6] = btnzPrgz[6] + 0.08 > 1 and 1 or btnzPrgz[6] + 0.08
		else
			btnzPrgz[6] = btnzPrgz[6] - 0.08 < 0 and 0 or btnzPrgz[6] - 0.08
		end
		local r, g, b = interpolateBetween(0, 0, 0, 255, 165, 0, btnzPrgz[6], "Linear")
		dxDrawRoundedRectangle(endx + linepos, endy - 40, 145, 35, tocolor(r, g, b, 200 * gTune.mainprogress), 10)
		gTune.buttons[6] = { x = endx + linepos, y = endy - 45, tp = "plate" }
		dxDrawText("LICENCE PLATE", endx + linepos, endy - 45, endx, endy, tocolor(255, 255, 255, 255 * gTune.mainprogress), 1.4, "default-bold", "center", "center")
	end
end

function handleTunningClick(button, state, cx, cy)
	if button == "left" then
		if state == "up" then
			-- Main menu
			if gTune.selected == 0 then
				for i = 1, #gTune.buttons do
					if cx >= gTune.buttons[i].x and cx <= gTune.buttons[i].x + 145 and cy >= gTune.buttons[i].y and cy <= gTune.buttons[i].y + 40 then
						-- Wheels
						if gTune.buttons[i].tp == "wheels" then
							gTune.selected = 1
							gTune.camprogressup = true
							setPedAnalogControlState(gTune.ped, "accelerate", 0)
						-- Rear lights
						elseif gTune.buttons[i].tp == "rear lights" then
							gTune.selected = 2
							gTune.camprogressup = true
						-- Vehicle paint
						elseif gTune.buttons[i].tp == "paint" then
							gTune.selected = 3
							gTune.camprogressup = true
							setPickerVisible(pickervehcolor, true)
						elseif gTune.buttons[i].tp == "nos" then
							gTune.selected = 4
							gTune.camprogressup = true
							setPickerVisible(pickernoscolor, true)
							setVehicleNitroActivated(gTune.vehicle, true)
							setPedAnalogControlState(gTune.ped, "accelerate", 1)
							nitrotimer = setTimer(
								function()
									setVehicleNitroLevel(gTune.vehicle, 1)
									setVehicleNitroActivated(gTune.vehicle, true)
								end
							, 500, 0)
							local pStats = getElementData(localPlayer, "stats")
							if pStats.vehicle.noscolor then
								local r, g, b = unpack(pStats.vehicle.noscolor)
								setPickColor(pickernoscolor, r, g, b)
								setVehicleNitroColor(r, g, b)
							end
						elseif gTune.buttons[i].tp == "plate" then
							gTune.selected = 5
							gTune.camprogressup = true
						elseif gTune.buttons[i].tp == "front lights" then
							gTune.selected = 6
							gTune.camprogressup = true
							setPickerVisible(pickerlightcolor, true)
						end
						return
					end
				end
			-- Wheels
			elseif gTune.selected == 1 then
				for i = 1, #wheelButton do
					if cx >= wheelButton[i].x and cx <= wheelButton[i].x + wheelButton[i].width and cy >= wheelButton[i].y and cy <= wheelButton[i].y + wheelButton[i].height then
						-- Previous wheel
						if i == 1 then
							wheelidx = wheelidx - 1 <= 0 and #vWheels or wheelidx - 1
							addVehicleUpgrade(gTune.vehicle, vWheels[wheelidx])
						elseif i == 2 then
							wheelidx = wheelidx + 1 > #vWheels and 1 or wheelidx + 1
							addVehicleUpgrade(gTune.vehicle, vWheels[wheelidx])
						-- Buy wheel
						elseif i == 3 then
							triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "wheel", vWheels[wheelidx])
						end
					end
				end
			-- Rear lights
			elseif gTune.selected == 2 then
				for i = 1, #lightButton do
					if cx >= lightButton[i].x and cx <= lightButton[i].x + lightButton[i].width and cy >= lightButton[i].y and cy <= lightButton[i].y + lightButton[i].height then
						-- Previous dvo
						if i == 1 then
							dvoidx = dvoidx - 1 <= 0 and TOTAL_DVO or dvoidx - 1
							setVehicleLight(gTune.vehicle, dvoidx)
						elseif i == 2 then
							dvoidx = dvoidx + 1 > TOTAL_DVO and 1 or dvoidx + 1
							setVehicleLight(gTune.vehicle, dvoidx)
						-- Buy rear light
						elseif i == 3 then
							triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "rear light", dvoidx)
						end
					end
				end
			-- Paint DVO
			elseif gTune.selected == 3 then
				for i = 1, #paintButton do
					if cx >= paintButton[i].x and cx <= paintButton[i].x + paintButton[i].width and cy >= paintButton[i].y and cy <= paintButton[i].y + paintButton[i].height then
						-- Previous paint
						if i == 1 then
							paintidx = paintidx - 1 <= 0 and TOTAL_PAINTS or paintidx - 1
							setVehiclePaint(gTune.vehicle, paintidx)
						elseif i == 2 then
							paintidx = paintidx + 1 > TOTAL_PAINTS and 1 or paintidx + 1
							setVehiclePaint(gTune.vehicle, paintidx)
						-- Buy rear light
						elseif i == 3 then
					--		triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "paint", paintidx)
						end
					end
				end
			-- Vehicle plate
			elseif gTune.selected == 5 then
				local bttn = plateButton
				if cx >= bttn.x and cx <= bttn.x + bttn.width and cy >= bttn.y and cy <= bttn.y + bttn.height then
					bttn.selected = true
				else
					bttn.selected = false
				end
				if cx >= plateButton.x + 50 and cx <= plateButton.x + 160 and cy >= plateButton.y + 55 and cy <= plateButton.y + 85 then
					triggerServerEvent("tune:onPlayerRequestBuy", localPlayer, "plate", plateButton.text)
				end
			-- Front lights
			elseif gTune.selected == 6 then
				for i = 1, #frontLightButton do
					if cx >= frontLightButton[i].x and cx <= frontLightButton[i].x + frontLightButton[i].width and cy >= frontLightButton[i].y and cy <= frontLightButton[i].y + frontLightButton[i].height then
						-- Previous light
						if i == 1 then
							lightidx = lightidx - 1 <= 0 and TOTAL_LIGHTS or lightidx - 1
							setVehicleHeadlightAnim(gTune.vehicle, lightidx)
						elseif i == 2 then
							lightidx = lightidx + 1 > TOTAL_LIGHTS and 1 or lightidx + 1
							setVehicleHeadlightAnim(gTune.vehicle, lightidx)
						end
					end
				end
			end
		end
	elseif button == "right" and state == "up" then
		if gTune.selected > 0 then
			gTune.camprogressup = false
			setPedAnalogControlState(gTune.ped, "accelerate", 0.05)
			setElementVelocity(gTune.vehicle, 0, 0.2, 0)
			setPickerVisible(pickervehcolor, false)
			setPickerVisible(pickernoscolor, false)
			setPickerVisible(pickerlightcolor, false)
			setVehicleNitroActivated(gTune.vehicle, false)
			plateButton.selected = false
			if isTimer(nitrotimer) then
				killTimer(nitrotimer)
			end
			gTune.selected = 0
			loadPlayerVehicleUpgrades()
			resetNitroColor()
		else
			stopTunning()
		end
	end
end

function handleTunningKey(button, state)
	if state then
		if button == "arrow_r" then
			-- Wheels
			if gTune.selected == 1 then
				wheelidx = wheelidx + 1 > #vWheels and 1 or wheelidx + 1
				if vWheels[wheelidx] == -1 then 
					removeWheels() 
				else
					addVehicleUpgrade(gTune.vehicle, vWheels[wheelidx]) 
				end
			-- Rear lights
			elseif gTune.selected == 2 then
				dvoidx = dvoidx + 1 > TOTAL_DVO and 1 or dvoidx + 1
				setVehicleLight(gTune.vehicle, dvoidx)
			-- Paint
			elseif gTune.selected == 3 then
				paintidx = paintidx + 1 > TOTAL_PAINTS and 1 or paintidx + 1
				setVehiclePaint(gTune.vehicle, paintidx)
			-- Front lights
			elseif gTune.selected == 6 then
				lightidx = lightidx + 1 > TOTAL_LIGHTS and 1 or lightidx + 1
				setVehicleHeadlightAnim(gTune.vehicle, lightidx)
			end
		elseif button == "arrow_l" then
			if gTune.selected == 1 then
				wheelidx = wheelidx - 1 <= 0 and #vWheels or wheelidx - 1
				if vWheels[wheelidx] == -1 then 
					removeWheels() 
				else
					addVehicleUpgrade(gTune.vehicle, vWheels[wheelidx]) 
				end
			elseif gTune.selected == 2 then
				dvoidx = dvoidx - 1 <= 0 and TOTAL_DVO or dvoidx - 1
				setVehicleLight(gTune.vehicle, dvoidx)
			elseif gTune.selected == 3 then
				paintidx = paintidx - 1 <= 0 and TOTAL_PAINTS or paintidx - 1
				setVehiclePaint(gTune.vehicle, paintidx)
			elseif gTune.selected == 6 then
				lightidx = lightidx - 1 <= 0 and TOTAL_LIGHTS or lightidx - 1
				setVehicleHeadlightAnim(gTune.vehicle, lightidx)
			end	
		-- Vehicle plate
		elseif button == "backspace" then
			plateButton.text = plateButton.text:sub(0, #plateButton.text - 1)
			if #plateButton.text == 0 then
				setVehiclePlateText(gTune.vehicle, "  ERU")
				return
			end
			setVehiclePlateText(gTune.vehicle, plateButton.text)
		end
	end
end

function handleTunningCharacter(key)
-- Vehicle plate
	if gTune.selected == 5 then
		if #plateButton.text == 8 then return end
		plateButton.text = plateButton.text.. "" ..key:upper()
		setVehiclePlateText(gTune.vehicle, plateButton.text)
	end
end

function startTunning()
	if not dvoEnabled then
		showNotificationToPlayer("You have vehicle DVOs disabled, you won't be able to see vehicle DVOs", "error")
	end
	if not gTune.handler then
		addEventHandler("onClientRender", root, drawTunning)
		addEventHandler("onClientClick", root, handleTunningClick)
		addEventHandler("onClientKey", root, handleTunningKey)
		addEventHandler("onClientCharacter", root, handleTunningCharacter)
		gTune.handler = true
	end
	--
	setSkyGradient()
	fadeCamera(true)
	setTimer(showCursor, 1000, 1, true)
	showChat(false)
	--
	for i = 1, NUMBER_ROADS do
		createRoad()
	end
	gTune.vehicle = createVehicle(411, 3766, 400, 273.5)
	setVehiclePlateText(gTune.vehicle, "  ERU")
	gTune.ped = createPed(0, 1354, starty, 786.09997558594)
	warpPedIntoVehicle(gTune.ped, gTune.vehicle)
--	setElementDimension(localPlayer, 0)
	setPedAnalogControlState(gTune.ped, "accelerate", 0.05)
	setElementVelocity(gTune.vehicle, 0, 0.2, 0)
	setVehicleOverrideLights(gTune.vehicle, 2)
	addVehicleUpgrade(gTune.vehicle, 1010)
	setElementInterior(gTune.ped, 100)
	setElementData(localPlayer, "state", "garage")
	guiSetInputMode("no_binds")
	--
	setTimer(loadPlayerVehicleUpgrades, 50, 1) -- Let shader load properly
end

function stopTunning()
	setTimer(
		function()
			if gTune.handler then
				removeEventHandler("onClientRender", root, drawTunning)
				removeEventHandler("onClientClick", root, handleTunningClick)
				removeEventHandler("onClientKey", root, handleTunningKey)
				removeEventHandler("onClientCharacter", root, handleTunningCharacter)
				gTune.handler = false
			end
			--
			c = 0
		--	outputDebugString("Destroying " ..#gTune.road)
			for id, road in pairs(gTune.road) do
				destroyElement(road)
				c = c + 1
			end
			outputDebugString("[TUNNING] Destroyed " ..c.. " objects and " ..gRoads.. " roads")
			destroyElement(gTune.vehicle)
			destroyElement(gTune.ped)
			gTune.road = {}
		--	outputDebugString("Destroyed, sz: " ..#gTune.road)
			gRoads = 0
			startLobby()
		end
	, 1500, 1)
	showCursor(false)
	fadeCamera(false)
	guiSetInputMode("allow_binds")
end

function loadPlayerVehicleUpgrades()
	local pStats = getElementData(localPlayer, "stats")
	-- Wheels
	if pStats.vehicle.wheel > 0 then
		addVehicleUpgrade(gTune.vehicle, pStats.vehicle.wheel)
	else
		removeWheels()
	end
	-- Rear light
	if pStats.vehicle.rearlight > 0 then
		setVehicleLight(gTune.vehicle, pStats.vehicle.rearlight)
	end
	-- Plate text
	if pStats.vehicle.plate then
		setVehiclePlateText(gTune.vehicle, pStats.vehicle.plate)
	end
	-- Paint
	if type(pStats.vehicle.paint) == "number" then
		setVehiclePaint(gTune.vehicle, pStats.vehicle.paint)
	elseif type(pStats.vehicle.paint) == "table" then
		local r, g, b = unpack(pStats.vehicle.paint)
		setVehicleColor(gTune.vehicle, r, g, b, r, g, b, r, g, b, r, g, b)
	else
		removeVehiclePaint(gTune.vehicle)
	end
	-- Headlight color
	if type(pStats.vehicle.frontlight) == "number" then
		setVehicleHeadlightAnim(gTune.vehicle, pStats.vehicle.frontlight)
	elseif type(pStats.vehicle.frontlight) == "table" then
		setVehicleHeadLightColor(gTune.vehicle, unpack(pStats.vehicle.frontlight))
	else
		setVehicleHeadlightAnim(gTune.vehicle, 100)
	end
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

local diff = nil
addCommandHandler("diff",
	function()
		local cx, cy = getCursorPosition()
		cx = cx * sx
		cy = cy * sy
		if not diff then
			diff = {}
			diff[1] = cx
			diff[2] = cy
			outputChatBox("set")
		else
			outputChatBox("x diff: " ..(diff[1] - cx).. " y diff: " ..(diff[2] - cy))
			diff = nil
		end
	end
)

local _getScreenFromWorldPosition = getScreenFromWorldPosition
function getScreenFromWorldPosition(...)
	if not ... then return end
	return _getScreenFromWorldPosition(...)
end

function removeWheels()
	for i = 1, #vWheels - 1 do
		removeVehicleUpgrade(gTune.vehicle, vWheels[i])
	end
end

function createRoad()
	local yoffs = gRoads * ROAD_LENGHT
	table.insert(gTune.road, createObject(2910,3766.0000000,0.0000000 + yoffs,273.0000000,0.0000000,0.0000000,0.0000000)) --object(temp_road) (1)
	table.insert(gTune.road, createObject(16113,3794.5000000,4.3000000 + yoffs,264.0000000,0.0000000,0.0000000,126.0000000)) --object(des_rockgp2_03) (1)
	table.insert(gTune.road, createObject(16113,3795.3000000,47.1000000 + yoffs,264.5000000,0.0000000,0.0000000,131.9970000)) --object(des_rockgp2_03) (2)
	table.insert(gTune.road, createObject(16113,3796.3000000,-36.8000000 + yoffs,264.0000000,0.0000000,0.0000000,125.9970000)) --object(des_rockgp2_03) (3)
	table.insert(gTune.road, createObject(16113,3797.3000000,-72.9000000 + yoffs,264.0000000,0.0000000,0.0000000,125.9970000)) --object(des_rockgp2_03) (4)
	table.insert(gTune.road, createObject(16113,3792.8999000,77.2000000 + yoffs,264.5000000,0.0000000,0.0000000,131.9950000)) --object(des_rockgp2_03) (5)
	table.insert(gTune.road, createObject(16113,3798.1001000,-112.1000000 + yoffs,264.0000000,0.0000000,0.0000000,133.9970000)) --object(des_rockgp2_03) (6)
	table.insert(gTune.road, createObject(16113,3739.6001000,-100.1000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9950000)) --object(des_rockgp2_03) (7)
	table.insert(gTune.road, createObject(16113,3737.5000000,-58.9000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9950000)) --object(des_rockgp2_03) (8)
	table.insert(gTune.road, createObject(16113,3734.8000000,-16.6000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9900000)) --object(des_rockgp2_03) (9)
	table.insert(gTune.road, createObject(16113,3733.5000000,23.7000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9900000)) --object(des_rockgp2_03) (10))
	table.insert(gTune.road, createObject(16113,3738.2000000,61.1000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9900000)) --object(des_rockgp2_03) (11)
	table.insert(gTune.road, createObject(16113,3740.3999000,93.4000000 + yoffs,266.8999900,0.0000000,0.0000000,309.9900000)) --object(des_rockgp2_03) (12)
	table.insert(gTune.road, createObject(703,3783.3000000,69.5000000 + yoffs,272.5000000,0.0000000,0.0000000,0.0000000)) --object(sm_veg_tree7_big) (1)
	table.insert(gTune.road, createObject(703,3787.7000000,-52.1000000 + yoffs,273.6000100,0.0000000,0.0000000,0.0000000)) --object(sm_veg_tree7_big) (2)
	table.insert(gTune.road, createObject(703,3744.8999000,2.7000000 + yoffs,274.3999900,0.0000000,0.0000000,0.0000000)) --object(sm_veg_tree7_big) (3)
	table.insert(gTune.road, createObject(703,3745.8999000,67.0000000 + yoffs,274.6000100,0.0000000,0.0000000,0.0000000)) --object(sm_veg_tree7_big) (4)
	table.insert(gTune.road, createObject(3509,3773.8000000,27.3000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(vgsn_nitree_r01) (1)
	table.insert(gTune.road, createObject(3505,3774.3000000,-52.1000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(vgsn_nitree_y01) (1)
	table.insert(gTune.road, createObject(810,3773.7000000,24.0000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (1)
	table.insert(gTune.road, createObject(810,3772.5000000,25.9000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (2)
	table.insert(gTune.road, createObject(810,3772.2000000,27.2000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (6)
	table.insert(gTune.road, createObject(810,3773.8000000,25.4000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (7)
	table.insert(gTune.road, createObject(810,3775.3000000,26.1000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (8)
	table.insert(gTune.road, createObject(810,3774.8000000,24.6000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (9)
	table.insert(gTune.road, createObject(810,3773.0000000,24.7000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (10))
	table.insert(gTune.road, createObject(810,3772.0000000,25.2000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (11)
	table.insert(gTune.road, createObject(810,3771.6001000,26.2000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (16)
	table.insert(gTune.road, createObject(810,3775.0000000,25.8000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (19)
	table.insert(gTune.road, createObject(810,3773.8999000,-53.6000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (20))
	table.insert(gTune.road, createObject(810,3773.1001000,-53.2000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (21)
	table.insert(gTune.road, createObject(810,3772.8999000,-51.7000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (22)
	table.insert(gTune.road, createObject(810,3772.5000000,-52.4000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (24)
	table.insert(gTune.road, createObject(810,3775.0000000,-53.8000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (25)
	table.insert(gTune.road, createObject(810,3773.6001000,-50.8000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (26)
	table.insert(gTune.road, createObject(810,3775.0000000,-50.8000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (28)
	table.insert(gTune.road, createObject(810,3772.2000000,28.4000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (29)
	table.insert(gTune.road, createObject(810,3773.6001000,29.0000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (30))
	table.insert(gTune.road, createObject(810,3774.3000000,28.7000000 + yoffs,273.1000100,0.0000000,0.0000000,0.0000000)) --object(genveg_bush14) (31)
	table.insert(gTune.road, createObject(823,3774.1001000,-54.6000000 + yoffs,275.8999900,0.0000000,0.0000000,0.0000000)) --object(genveg_tallgrass07) (1)
	table.insert(gTune.road, createObject(823,3774.1001000,25.1000000 + yoffs,275.8999900,0.0000000,0.0000000,0.0000000)) --object(genveg_tallgrass07) (2)
	table.insert(gTune.road, createObject(823,3747.8000000,-46.1000000 + yoffs,276.2999900,0.0000000,0.0000000,0.0000000)) --object(genveg_tallgrass07) (3)
	table.insert(gTune.road, createObject(823,3785.3999000,50.7000000 + yoffs,274.0000000,0.0000000,0.0000000,0.0000000)) --object(genveg_tallgrass07) (4)
	table.insert(gTune.road, createObject(823,3748.5000000,-77.4000000 + yoffs,278.3999900,0.0000000,0.0000000,0.0000000)) --object(genveg_tallgrass07) (5)
	table.insert(gTune.road, createObject(3276,3775.2000000,-71.0000000 + yoffs,274.0000000,0.0000000,0.0000000,270.0000000)) --object(cxreffencesld) (1)
	table.insert(gTune.road, createObject(3276,3775.3000000,10.1000000 + yoffs,274.0000000,0.0000000,0.0000000,270.0000000)) --object(cxreffencesld) (2)
	table.insert(gTune.road, createObject(3276,3775.3000000,-15.2000000 + yoffs,274.0000000,0.0000000,0.0000000,270.0000000)) --object(cxreffencesld) (3)
	table.insert(gTune.road, createObject(3276,3775.3000000,-37.7000000 + yoffs,274.0000000,0.0000000,0.0000000,270.0000000)) --object(cxreffencesld) (4)
	table.insert(gTune.road, createObject(3276,3774.8999000,44.1000000 + yoffs,274.0000000,0.0000000,0.0000000,270.0000000)) --object(cxreffencesld) (5)
	table.insert(gTune.road, createObject(3276,3774.8999000,67.8000000 + yoffs,274.0000000,0.0000000,0.0000000,272.0000000)) --object(cxreffencesld) (6)
	table.insert(gTune.road, createObject(3877,3775.1001000,55.7000000 + yoffs,274.7999900,0.0000000,0.0000000,0.0000000)) --object(sf_rooflite) (1)
	table.insert(gTune.road, createObject(3877,3775.1001000,-2.6000000 + yoffs,274.7999900,0.0000000,0.0000000,0.0000000)) --object(sf_rooflite) (2)
	table.insert(gTune.road, createObject(3877,3775.1001000,-26.3000000 + yoffs,274.7999900,0.0000000,0.0000000,0.0000000)) --object(sf_rooflite) (3)
	table.insert(gTune.road, createObject(3877,3775.3000000,-83.8000000 + yoffs,274.7999900,0.0000000,0.0000000,0.0000000)) --object(sf_rooflite) (4)
	gRoads = gRoads + 1
	--
	if gRoads == ROAD_LENGHT then
		outputDebugString("[TUNNING] Created " ..#gTune.road.. " objects and " ..gRoads.. " roads")
	end
end