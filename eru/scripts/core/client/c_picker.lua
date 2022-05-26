local sx, sy = guiGetScreenSize()

local gPickers = {}

local handler = false
local isClicking = false

function createColorPicker(x, y, alpha, title)
	local h, s, v = rgb2hsv(255, 255, 0)
	local idx = #gPickers + 1
	gPickers[idx] = { x = x, y = y, width = 416, height = 304, alpha = alpha, title = title, currentcolor = { 255, 255, 0 }, huecolor = { 255, 255, 0 }, h = h, s = s, v = v, buttons = {}, visible = false, showprogress = 0 }
	return idx
end

function colorPickerAddButton(parentid, x, y, width, height, text, title)
	gPickers[parentid].buttons[#gPickers[parentid].buttons + 1] = { x = x, y = y, text = text, title = title, width = width, height = height, progress = 0 }
end

function setPickerVisible(id, bool)
	gPickers[id].visible = bool
	gPickers[id].showprogress = bool and 0.01 or gPickers[id].showprogress -- Bug fix, 
	if bool then
		if not handler then
			addEventHandler("onClientRender", root, drawPicker)
			addEventHandler("onClientCursorMove", root, mouseMove)
			addEventHandler("onClientClick", root, mouseClick)
			handler = true
		end
	end
end

function mouseMove(cx, cy)
	cx = sx * cx cy = sy * cy
	if not isClicking then return end
	for i = 1, #gPickers do
		local pick = gPickers[i]
		if pick.visible then
			-- Cursor is on sv.png
			if cx >= pick.x + 16 and cx <= pick.x + 16 + 255 and cy >= pick.y + 32 and cy <= pick.y + 32 + 255 then
				local offsetx, offsety = cx - (pick.x + 16), cy - (pick.y + 32)
				pick.s = offsetx / 255
				pick.v = (255 - offsety) / 255
				local r, g, b = hsv2rgb(pick.h, pick.s, pick.v)
				pick.currentcolor = { r, g, b }
				triggerEvent("cpicker:onPickerColorChange", root, r, g, b)
				return
			elseif cx >= pick.x + 288 and cx <= pick.x + 288 + 32 and cy >= pick.y + 32 and cy <= pick.y + 32 + 256 then
				local offset = cy - (pick.y + 32)
				pick.h = (255 - offset) / 255
				local r, g, b = hsv2rgb(pick.h, pick.s, pick.v)
				pick.currentcolor = { r, g, b }
				pick.huecolor = { hsv2rgb(pick.h, 1, 1) }
				triggerEvent("cpicker:onPickerColorChange", root, r, g, b)
				return
			end
		end
	end
end

function mouseClick(button, state, cx, cy)
	if button == "left" and state == "down" then
		isClicking = true
		-- Check if player is pressing any button
		for i = 1, #gPickers do
			local pick = gPickers[i]
			if pick.visible then
				for x = 1, #pick.buttons do
					local bttn = gPickers[i].buttons[x]
					if cx >= pick.x + bttn.x and cx <= pick.x + bttn.x + bttn.width and cy >= pick.y + bttn.y and cy <= pick.y + bttn.y + bttn.height then
						triggerEvent("cpicker:onClientClickButton", root, bttn.text)
						return
					end
				end
			end
		end
	else
		isClicking = false
	end
end

function drawPicker()
	for i = 1, #gPickers do
		local pick = gPickers[i]
		if pick.visible then
			pick.showprogress = pick.showprogress + 0.08 > 1 and 1 or pick.showprogress + 0.08
		else
			pick.showprogress = pick.showprogress - 0.08 < 0 and 0 or pick.showprogress - 0.08
		end
		dxDrawRoundedRectangle(pick.x, pick.y, pick.width, pick.height, tocolor(0, 0, 0, pick.alpha * pick.showprogress), 10)
		dxDrawText(pick.title, pick.x, pick.y + 8, pick.x + pick.width, pick.y + pick.height, tocolor(255, 255, 255, 255 * pick.showprogress), 1, "roboto-bold", "center", "top")
		local r, g, b = unpack(pick.huecolor)
		dxDrawRectangle(pick.x + 16, pick.y + 32, 256, 256, tocolor(r, g, b, 255 * pick.showprogress))
		dxDrawImage(pick.x + 16, pick.y + 32, 256, 256, "files/img/colorpicker/sv.png", 0, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		dxDrawImage(pick.x + 288, pick.y + 32, 32, 256, "files/img/colorpicker/h.png", 0, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		r, g, b = unpack(pick.currentcolor)
		dxDrawRectangle(pick.x + 336, pick.y + 32, 64, 64, tocolor(r, g, b, 255 * pick.showprogress))
		dxDrawText(RGBToHex(r, g, b), pick.x + 336, pick.y + 32, pick.x + 400, pick.y + 96, tocolor(0, 0, 0, 255 * pick.showprogress), 1, "roboto", "center", "center", true, true)
		dxDrawText("R: " ..r, pick.x + 336, pick.y + 110, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		dxDrawText("G: " ..g, pick.x + 336, pick.y + 130, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		dxDrawText("B: " ..b, pick.x + 336, pick.y + 150, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		-- Cursor
		dxDrawImageSection(pick.x + 8 + math.floor(256 * pick.s), pick.y + 24 + (256 - math.floor(256 * pick.v)), 16, 16, 0, 0, 16, 16, "files/img/colorpicker/cursor.png", 0, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		dxDrawImageSection(pick.x + 280, pick.y + 24 + (256 - math.floor(256 * pick.h)), 48, 16, 16, 0, 48, 16, "files/img/colorpicker/cursor.png", 0, 0, 0, tocolor(255, 255, 255, 255 * pick.showprogress))
		-- Buttons
		local cx, cy = getCursorPosition()
		cx = cx and cx * sx or 0
		cy = cy and cy * sy or 0
		for x = 1, #pick.buttons do
			local bttn = pick.buttons[x]
			if cx >= pick.x + bttn.x and cx <= pick.x + bttn.x + bttn.width and cy >= pick.y + bttn.y and cy <= pick.y + bttn.y + bttn.height then
				bttn.progress = bttn.progress + 0.08 > 1 and 1 or bttn.progress + 0.08
			else
				bttn.progress = bttn.progress - 0.08 < 0 and 0 or bttn.progress - 0.08
			end
			local r, g, b = interpolateBetween(10, 10, 10, 255, 165, 0, bttn.progress, "Linear")
			dxDrawRoundedRectangle(pick.x + bttn.x, pick.y + bttn.y, bttn.width, bttn.height, tocolor(r, g, b, 255 * pick.showprogress), 10)
			dxDrawText(bttn.text, pick.x + bttn.x, pick.y + bttn.y, pick.x + bttn.x + bttn.width, pick.y + bttn.y + bttn.height, tocolor(255, 255, 255, 255 * pick.showprogress), 1, "roboto", "center", "center")
			if bttn.title then
				dxDrawText(bttn.title, pick.x + bttn.x, pick.y + bttn.y - 15, pick.x + bttn.x + bttn.width, 0, tocolor(255, 255, 255, 255 * pick.showprogress), 1, "roboto-bold", "center")
			end
		end
		-- Remove handlers if no pickers are open
		if pick.showprogress == 0 and not isThereAnyPickersOpen() then
			if handler then
				removeEventHandler("onClientRender", root, drawPicker)
				removeEventHandler("onClientCursorMove", root, mouseMove)
				removeEventHandler("onClientClick", root, mouseClick)
				handler = false
			end
		end
	end
end

function isThereAnyPickersOpen()
	for i = 1, #gPickers do
		if gPickers[i].showprogress ~= 0 then
			return true
		end
	end
	return false
end

function getPickerRGB(id)
	return unpack(gPickers[id].currentcolor)
end

function setPickColor(id, r, g, b)
	local h, s, v = rgb2hsv(r, g, b)
	gPickers[id].currentcolor = { r, g, b }
	gPickers[id].h = h
	gPickers[id].s = s
	gPickers[id].v = v
	gPickers[id].huecolor = { hsv2rgb(h, 1, 1) }
end

function rgb2hsv(r, g, b)
  r, g, b = r/255, g/255, b/255
  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s 
  local v = max
  local d = max - min
  s = max == 0 and 0 or d/max
  if max == min then 
    h = 0
  elseif max == r then 
    h = (g - b) / d + (g < b and 6 or 0)
  elseif max == g then 
    h = (b - r) / d + 2
  elseif max == b then 
    h = (r - g) / d + 4
  end
  h = h/6
  return h, s, v
end

function hsv2rgb(h, s, v)
  local r, g, b
  local i = math.floor(h * 6)
  local f = h * 6 - i
  local p = v * (1 - s)
  local q = v * (1 - f * s)
  local t = v * (1 - (1 - f) * s)
  local switch = i % 6
  if switch == 0 then
    r = v g = t b = p
  elseif switch == 1 then
    r = q g = v b = p
  elseif switch == 2 then
    r = p g = v b = t
  elseif switch == 3 then
    r = p g = q b = v
  elseif switch == 4 then
    r = t g = p b = v
  elseif switch == 5 then
    r = v g = p b = q
  end
  return math.floor(r*255), math.floor(g*255), math.floor(b*255)
end

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end