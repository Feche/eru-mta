local sx, sy = guiGetScreenSize()

local gGui = {}

local gType =
{
	windows = 1,
	text = 2,
	scroll = 3
}

local edit =
{
	backspace = false,
	tick = getTickCount()
}

addEventHandler("onClientRender", root,
	function()
		local cx, cy = getCursorPosition()
		cx = (cx or 0) * sx 
		cy = (cy or 0) * sy
		for id in pairs(gGui) do
	--		outputChatBox("GUI id: " ..id.. ", type: " ..gGui[id].type.. ", visible: " ..tostring(gGui[id].showgui))
			-- Opening
			if gGui[id].showgui then
				gGui[id].progress = gGui[id].progress + 0.06
				if gGui[id].progress >= 1 then gGui[id].progress = 1 end
				-- Windows
				if gGui[id].type == gType.windows then
					local alpha = gGui[id].alpha * gGui[id].progress
					dxDrawRectangle(gGui[id].x, gGui[id].y, gGui[id].width, gGui[id].height, tocolor(0, 0, 0, alpha))
					dxDrawText(gGui[id].title, gGui[id].x, gGui[id].y + 5, gGui[id].x + gGui[id].width, gGui[id].y + gGui[id].height, tocolor(255, 255, 255, 255 * gGui[id].progress), 2, "default-bold", "center", "top")
					local y = gGui[id].y + 40
					dxDrawLine(gGui[id].x + 35, y, gGui[id].x + gGui[id].width - 35, y, tocolor(253, 106, 2, alpha))
					-- Texts
					local idx = #gGui[id].text
					if idx > 0 then
						for i = 1, idx do
							local x, y, width, height
							x = gGui[id].text[i].x + gGui[id].x
							y = gGui[id].text[i].y + gGui[id].y
							width =	gGui[id].text[i].width
							height = gGui[id].text[i].height
							dxDrawText(gGui[id].text[i].text, x + 20, y, x + width - 20, y + height, tocolor(255, 255, 255, 255 * gGui[id].progress), gGui[id].text[i].size, gGui[id].text[i].font, gGui[id].text[i].alignx, gGui[id].text[i].aligny, false, true)
						end
					end
					-- Buttons
					idx = #gGui[id].button
					if idx > 0 then
						for i = 1, idx do
							local x, y, width, height
							x = gGui[id].button[i].x + gGui[id].x
							y = gGui[id].button[i].y + gGui[id].y
							width = gGui[id].button[i].width
							height = gGui[id].button[i].height
							local color1
							if cx >= x and cx <= x + width and cy >= y and cy <= y + height then
								color1 = tocolor(128, 128, 128, alpha)
							else
								color1 = tocolor(60, 60, 60, alpha)
							end
							dxDrawRectangle(x, y, width, height, color1)
							dxDrawText(gGui[id].button[i].text, x, y, x + width, y + height, tocolor(255, 255, 255, 255 * gGui[id].progress), gGui[id].button[i].size, gGui[id].button[i].font, gGui[id].button[i].alignx, gGui[id].button[i].aligny)
						end
					end
					-- Scroll
					local x, y
					local alpha = gGui[id].alpha * gGui[id].progress
			--		dxDrawRectangle(x, y, gGui[id].width, gGui[id].height, tocolor(0, 0, 0, alpha))
					-- Draw scrollbar
					local scrollIDX = #gGui[id].scroll
					for i = 1, scrollIDX do
						if gGui[id].scroll[i].tbl then
							local tbl = gGui[id].scroll[i].tbl
							for xx = 1, gGui[id].scroll[i].maxscrolls do
								local idx = gGui[id].scroll[i].tblindex
								local color1, color2
								local offst = 25 * (xx - 1)
								x = gGui[id].scroll[i].x + gGui[id].x
								y = gGui[id].scroll[i].y + gGui[id].y
								if cx >= x and cx <= x + gGui[id].scroll[i].width and cy >= y + offst and cy <= y + offst + 25 then
									color1 = tocolor(255, 153, 51, alpha)
									color2 = tocolor(255, 255, 255, alpha)
								else
									color1 = xx % 2 == 0 and tocolor(10, 10, 10, alpha) or tocolor(20, 20, 20, alpha)
									color2 = tocolor(255, 255, 255, alpha)
								end
								if tbl[xx + idx] then
									if gGui[id].scroll[i].textselected == tbl[xx + idx] then
										color1 = tocolor(255, 178, 108, alpha)
										color2 = tocolor(255, 255, 255, alpha)
									end
								end
								dxDrawRectangle(x, y + offst, gGui[id].scroll[i].width, 25, color1)
								if tbl[xx + idx] then
									dxDrawText(tbl[xx + idx], x + 5, y + offst, x + gGui[id].width, y + 25 + offst, color2, gGui[id].scroll[i].fontsize, "default-bold", "left", "center", false, false, false, true)
								end
								-- Square index
								if xx == 1 then
									local step = ((gGui[id].scroll[i].maxscrolls * 25) - 8) / (#tbl - gGui[id].scroll[i].maxscrolls)
									step = tostring(step) == "inf" and 1 or step
									dxDrawRectangle(x + gGui[id].scroll[i].width, (y + (step * idx)) or 0, 4, 8, tocolor(253, 106, 2, alpha))
								end
							end
						else
							local idx = gGui[id].scroll[i].maxscrolls
							for xx = 1, idx do
								x = gGui[id].scroll[i].x + gGui[id].x
								y = gGui[id].scroll[i].y + gGui[id].y
								local color1, color2
								local offst = 25 * (xx - 1)
								if cx >= x and cx <= x + gGui[id].scroll[i].width and cy >= y + offst and cy <= y + offst + 25 then
									color1 = tocolor(30, 30, 30, alpha)
									color2 = tocolor(51, 153, 255, alpha)
								else
									color1 = xx % 2 == 0 and tocolor(10, 10, 10, alpha) or tocolor(20, 20, 20, alpha)
									color2 = tocolor(255, 255, 255, alpha)
								end
								dxDrawRectangle(x, y + offst, gGui[id].scroll[i].width, 25, color1)
								local str = gGui[id].scroll[i].text[xx] and "- " ..gGui[id].scroll[i].text[xx].str or ""
								local colorcoded = color2 == -1 and true or false
								dxDrawText(colorcoded and str or str:gsub("#%x%x%x%x%x%x", ""), x, y + offst, x + gGui[id].width, y + 25 + offst, color2, 1.2, "default-bold", "left", "center", false, false, false, colorcoded)
							end
						end
					end
					-- Warning label
					local idx = #gGui[id].label
					for i = 1, idx do
						if gGui[id].label[i].showlabel then
							if getTickCount() - gGui[id].label[i].tick < gGui[id].label[i].duration then
								x = gGui[id].label[i].x + gGui[id].x
								y = gGui[id].label[i].y + gGui[id].y
								width = gGui[id].label[i].width
								height = gGui[id].label[i].height
								dxDrawText(gGui[id].label[i].text, x + 1, y + 1, x + width + 1, y + height, tocolor(0, 0, 0, 255), 1, "default-bold", gGui[id].label[i].alignx, gGui[id].label[i].aligny)
								dxDrawText(gGui[id].label[i].text, x, y, x + width, y + height, gGui[id].label[i].color, 1, "default-bold", gGui[id].label[i].alignx, gGui[id].label[i].aligny)
							else
								gGui[id].label[i].showlabel = false
							end
						end
					end
					-- Edit
					local idx = #gGui[id].edit
					for i = 1, idx do
						x = gGui[id].edit[i].x + gGui[id].x
						y = gGui[id].edit[i].y + gGui[id].y
						width = gGui[id].edit[i].width
						height = gGui[id].edit[i].height
					--	dxDrawImage(x, y, width, height, "files/edit.png")
						dxDrawRectangle(x, y, width, height, tocolor(255, 255, 255, 200))
						dxDrawText(gGui[id].edit[i].text, x + 5, y, x + width, y + height, tocolor(80, 80, 80, 255), 1, "default-bold", "left", "center")
						if gGui[id].edit[i].selected then
							local tick = getTickCount()
							-- Blink text position indicator
							if tick - gGui[id].edit[i].tick >= 800 then
								gGui[id].edit[i].alpha = gGui[id].edit[i].alpha == 0 and 255 or 0
								gGui[id].edit[i].tick = tick
							end
							-- Delete text if player presses backspace
							if edit.backspace then
								if tick - edit.tick >= 200 then
									gGui[id].edit[i].text = string.sub(gGui[id].edit[i].text, 0, #gGui[id].edit[i].text - 1)
								end
							end
							local offst = dxGetTextWidth(gGui[id].edit[i].text, 1, "default-bold")
							dxDrawText("|", x + offst + 5, y, x + width + offst, y + height, tocolor(253, 106, 2, gGui[id].edit[i].alpha), 1, "sans", "left", "center")
						end
					end
				end
			-- Closing
			elseif not gGui[id].showgui and gGui[id].progress ~= 0 then
				gGui[id].progress = gGui[id].progress - 0.06
				if gGui[id].progress < 0 then gGui[id].progress = 0 end
				-- Windows
				if gGui[id].type == gType.windows then
					dxDrawRectangle(gGui[id].x, gGui[id].y, gGui[id].width, gGui[id].height, tocolor(0, 0, 0, gGui[id].alpha * gGui[id].progress))
				end
			end
		end
	end
)

addEventHandler("onClientClick", root,
	function(button, state, xx, yy)
		if state == "down" and button == "left" then
			for id in pairs(gGui) do
				if gGui[id].showgui then
					if gGui[id].type == gType.windows then
						-- On player click button
						local idx = #gGui[id].button
						for i = 1, idx do
							local x, y, width, height
							x = gGui[id].button[i].x + gGui[id].x
							y = gGui[id].button[i].y + gGui[id].y
							width = gGui[id].button[i].width
							height = gGui[id].button[i].height
							if xx >= x and xx <= x + width and yy >= y and yy <= y + height then
								if checkLastClick() then
									triggerEvent("onPlayerClickGui", root, "button", gGui[id].button[i].buttonid)
								end
								break
							end
						end
						-- On player click scrollbar item
						local scrollIDX = #gGui[id].scroll
						for i = 1, scrollIDX do
							local idx = gGui[id].scroll[i].maxscrolls
							for xxx = 1, idx do
								x = gGui[id].scroll[i].x + gGui[id].x
								y = gGui[id].scroll[i].y + gGui[id].y + (25 * (xxx - 1))
								width = gGui[id].scroll[i].width
								if xx >= x and xx <= x + width and yy >= y and yy <= y + 25 and isDoubleClick() then
									if checkLastClick() then
										if gGui[id].scroll[i].tbl then
											local idxx = gGui[id].scroll[i].tblindex
											triggerEvent("onPlayerClickGui", root, "scroll", gGui[id].scroll[i].scrollid, gGui[id].scroll[i].tbl[xxx + gGui[id].scroll[i].tblindex])
										else
											triggerEvent("onPlayerClickGui", root, "scroll", gGui[id].scroll[i].scrollid, gGui[id].scroll[i].text[xxx].id)
										end
									end
								end
							end
						end
						-- On player click edit
						local idx = #gGui[id].edit
						for i = 1, idx do
							local x, y, width, height
							x = gGui[id].edit[i].x + gGui[id].x
							y = gGui[id].edit[i].y + gGui[id].y
							width = gGui[id].edit[i].width
							height = gGui[id].edit[i].height
							if xx >= x and xx <= x + width and yy >= y and yy <= y + height then
								gGui[id].edit[i].selected = true
							else
								gGui[id].edit[i].selected = false
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientCharacter", root, 
	function(key)
		if key ~= "?" and key ~= "'" then
			for id in pairs(gGui) do
				if gGui[id].showgui then
					for i = 1, #gGui[id].edit do
						gGui[id].edit[i].text = tostring(gGui[id].edit[i].text) -- If the edit has only numbers, we convert it to string so we avoid errors.
						local str = gGui[id].edit[i].text:gsub("#%x%x%x%x%x%x", "")
						if gGui[id].edit[i].selected and #str < gGui[id].edit[i].maxcharacters then
							gGui[id].edit[i].text = gGui[id].edit[i].text.. "" ..key
							triggerEvent("onClientCharacterEdit", root, gGui[id].edit[i].editid, gGui[id].edit[i].text)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientKey", root, 
	function(key, state)
		if state then
			if key == "backspace" then
				for id in pairs(gGui) do
					if gGui[id].showgui then
						for i = 1, #gGui[id].edit do
							if gGui[id].edit[i].selected then
								edit.backspace = true
								edit.tick = getTickCount()
								gGui[id].edit[i].text = tostring(gGui[id].edit[i].text) -- If the edit has only numbers, we convert it to string so we avoid errors.
								gGui[id].edit[i].text = string.sub(gGui[id].edit[i].text, 0, #gGui[id].edit[i].text - 1)
								triggerEvent("onClientCharacterEdit", root, gGui[id].edit[i].editid, gGui[id].edit[i].text)
							end
						end
					end
				end
			elseif key == "mouse_wheel_down" then
				for id in pairs(gGui) do
					if gGui[id].showgui then
						for i = 1, #gGui[id].scroll do
							if gGui[id].scroll[i] and gGui[id].scroll[i].tbl then
								local cx, cy = getCursorPosition()
								cx = cx * sx
								cy = cy * sy
								local x = gGui[id].scroll[i].x + gGui[id].x
								local y = gGui[id].scroll[i].y + gGui[id].y
								local totalheight = gGui[id].scroll[i].maxscrolls * 25
								if cx >= x and cx <= x + gGui[id].scroll[i].width and cy >= y and cy <= y + totalheight then
									if #gGui[id].scroll[i].tbl < gGui[id].scroll[i].maxscrolls then return end
									gGui[id].scroll[i].tblindex = gGui[id].scroll[i].tblindex + 1 > #gGui[id].scroll[i].tbl - gGui[id].scroll[i].maxscrolls and #gGui[id].scroll[i].tbl - gGui[id].scroll[i].maxscrolls or gGui[id].scroll[i].tblindex + 1 
								end
							end
						end
					end
				end
			elseif key == "mouse_wheel_up" then
				for id in pairs(gGui) do
					if gGui[id].showgui then
						for i = 1, #gGui[id].scroll do
							if gGui[id].scroll[i] and gGui[id].scroll[i].tbl then
								local cx, cy = getCursorPosition()
								cx = cx * sx
								cy = cy * sy
								local x = gGui[id].scroll[i].x + gGui[id].x
								local y = gGui[id].scroll[i].y + gGui[id].y
								local totalheight = gGui[id].scroll[i].maxscrolls * 25
								if cx >= x and cx <= x + gGui[id].scroll[i].width and cy >= y and cy <= y + totalheight then
									if #gGui[id].scroll[i].tbl < gGui[id].scroll[i].maxscrolls then return end
									gGui[id].scroll[i].tblindex = gGui[id].scroll[i].tblindex - 1 < 0 and 0 or gGui[id].scroll[i].tblindex - 1
								end
							end
						end
					end
				end
			end
		else
			if key == "backspace" then
				edit.backspace = false
			end
		end
	end
)

function createWindowsGui(width, height, alpha, title, id)
	if not id then
		outputDebugString("ERROR: No gui ID", 1)
		return
	end
	gGui[id] = { progress = 0, x = sx / 2 - width / 2, y = sy / 2 - height / 2, width = width, height = height, alpha = alpha, title = title, type = gType.windows, showgui = false, text = {}, button = {}, scroll = {}, label = {}, edit = {} }
--	outputDebugString("Windows " ..id.. " created.")
end

function createWindowsText(x, y, width, height, text, font, size, alignx, aligny, parentid)
	local idx = #gGui[parentid].text + 1
	gGui[parentid].text[idx] = { x = x, y = y, width = width, height = height, text = text, font = font, size = size, alignx = alignx, aligny = aligny }
end

function createWindowsButton(x, y, width, height, text, font, size, alignx, aligny, parentid, buttonid)
	local idx = #gGui[parentid].button + 1
	gGui[parentid].button[idx] = { x = x, y = y, width = width, height = height, text = text, font = font, size = size, alignx = alignx, aligny = aligny, buttonid = buttonid }
end

function createScrollGui(x, y, width, height, scrollid, parentid, fontsize)
	local idx = #gGui[parentid].scroll + 1
	gGui[parentid].scroll[idx] = { x = x, y = y, width = width, height = height, scrollid = scrollid, parentid = parentid, showgui = false, text = {}, maxscrolls = 0, tbl = nil, tblindex = 0, textselected = "", fontsize = fontsize or 1.2 }
end

function createWarningLabel(x, y, width, height, alignx, aligny, labelid, parentid)
	local idx = #gGui[parentid].label + 1
	gGui[parentid].label[idx] = { x = x, y = y, width = width, height = height, alignx = alignx, aligny = aligny, labelid = labelid, text = "", color = -1, showlabel = false, duration = 3000, tick = getTickCount() }
end

function createWindowsEdit(x, y, width, height, maxcharacters, editid, parentid)
	local idx = #gGui[parentid].edit + 1
	gGui[parentid].edit[idx] = { x = x, y = y, width = width, height = height, maxcharacters = maxcharacters, editid = editid, parentid = parentid, selected = false, backspace = false, backspacetick = getTickCount(), text = "", tick = getTickCount(), alpha = 0 }
end

function scrollGuiAddText(scrollid, text, textid)
	for id in pairs(gGui) do
		local scrollidx = #gGui[id].scroll
		for i = 1, scrollidx do
			if gGui[id].scroll[i].scrollid == scrollid then
				local idx = #gGui[id].scroll[i].text + 1
				gGui[id].scroll[i].text[idx] = { str = text, id = textid }
				gGui[id].scroll[i].maxscrolls = gGui[id].scroll[i].maxscrolls + 1
				return
			end
		end
	end
end

function scrollGuiAddTable(scrollid, tbl, maxtoshow, dontupdate)
	for id in pairs(gGui) do
		local scrollidx = #gGui[id].scroll
		for i = 1, scrollidx do
			if gGui[id].scroll[i].scrollid == scrollid then
				gGui[id].scroll[i].tbl = tbl
				gGui[id].scroll[i].maxscrolls = maxtoshow
				if not dontupdate then
					gGui[id].scroll[i].tblindex = 0
				end
				return
			end
		end
	end
end

function scrollSetTextSelected(scrollid, text)
	for id in pairs(gGui) do
		local scrollidx = #gGui[id].scroll
		for i = 1, scrollidx do
			if gGui[id].scroll[i].scrollid == scrollid then
				gGui[id].scroll[i].textselected = text
				return
			end
		end
	end
end

function showWarningLabel(labelid, text, color, duration)
	for id in pairs(gGui) do
		local idx = #gGui[id].label
		for i = 1, idx do
			if gGui[id].label[i].labelid == labelid then
				gGui[id].label[i].text = text
				gGui[id].label[i].showlabel = true
				gGui[id].label[i].tick = getTickCount()
				gGui[id].label[i].color = color
				gGui[id].label[i].duration = duration * 1000
				return
			end
		end
	end
end

function scrollGuiSetText(scrollid, text, textid)
	for id in pairs(gGui) do
		local scrollidx = #gGui[id].scroll
		for i = 1, scrollidx do
			if gGui[id].scroll[i].scrollid == scrollid then
				for x = 1, #gGui[id].scroll[i].text do
					if gGui[id].scroll[i].text[x].id == textid then
						gGui[id].scroll[i].text[x].str = text
						return
					end
				end
			end
		end
	end
end

function getGuiEditText(editid)
	for id in pairs(gGui) do
		local idx = #gGui[id].edit
		for i = 1, idx do
			if gGui[id].edit[i].editid == editid then
				return gGui[id].edit[i].text
			end
		end
	end
	return "???"
end

function setGuiEditText(editid, text)
	for id in pairs(gGui) do
		local idx = #gGui[id].edit
		for i = 1, idx do
			if gGui[id].edit[i].editid == editid then
				gGui[id].edit[i].text = text
				return
			end
		end
	end
end

function setWindowsText(id, text)
	gGui[id].text[1].text = text
end

function isGuiVisible(id)
	return gGui[id].showgui
end

function isAnyGuiVisible()
	for id in pairs(gGui) do
		if gGui[id].showgui then 
			return true 
		end
	end
	return false
end

function setGuiVisible(id, status)
	status = status == nil and true or status
	showCursor(status)
	guiSetInputMode(status and "no_binds" or "allow_binds")
	gGui[id].showgui = status
	-- Show parents
	for idx in pairs(gGui) do
		if gGui[idx].parentid == id then
			gGui[idx].showgui = status
		end
	end
end

local click = getTickCount()
function isDoubleClick()
	local timepassed = getTickCount() - click
	click = getTickCount()
	if timepassed <= 220 then
		return true
	end
	return false
end

local tickclick = getTickCount()
function checkLastClick()
	if getTickCount() - tickclick >= 100 then
		tickclick = getTickCount()
		return true
	end
	return false
end