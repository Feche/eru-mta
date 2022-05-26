local sx, sy = guiGetScreenSize()
local _gIDS = {}

local sPanels = {}
local selectedtab = nil

addEventHandler("onClientRender", root,
	function()
		local cx, cy = getCursorPosition()
		cx = cx and cx * sx or 0
		cy = cy and cy * sy or 0
		for _, panel in pairs(sPanels) do
			if panel.show then
				-- Main window
				local x, y = panel.x, panel.y 
				dxDrawRoundedRectangle(panel.x, panel.y, panel.w, panel.h, tocolor(panel.r, panel.g, panel.b, panel.a), 8)
				-- Tabs
				local offstx = 0
				for tabid, tab in pairs(panel.tabs) do
					local xx, yy = x + offstx, y - tab.height - 2
					local w = dxGetTextWidth(tab.name, tab.size, "default-bold") + 20
					-- Tab animation
					local r, g, b = interpolateBetween(tab.r, tab.g, tab.b, tab.tr, tab.tg, tab.tb, tab.progress, "Linear")
					if cx >= xx and cx <= xx + w and cy >= yy and cy <=  yy + tab.height then
						tab.progress = tab.progress + 0.08 > 1 and 1 or tab.progress + 0.08
					else
						tab.progress = tab.progress - 0.08 < 0 and 0 or tab.progress - 0.08
					end
					dxDrawRoundedRectangle(xx, yy, w, tab.height, tocolor(r, g, b, tab.a), 8, "top")
					dxDrawText(tab.name, xx, yy, xx + w, yy + tab.height, selectedtab == tabid and tocolor(tab.sr, tab.sg, tab.sb, 255) or tocolor(tab.tr, tab.tg, tab.tb, 255), tab.size, tab.font, "center", "center")
					offstx = offstx + w + 2
					--
					if selectedtab == tabid then
						-- Rectangles
						for _, rectangle in pairs(tab.rectangles) do
							dxDrawRoundedRectangle(x + rectangle.x, y + rectangle.y, rectangle.width, rectangle.height, rectangle.color, 8)
						end
						-- Scrolls
						for _, scroll in pairs(tab.scrolls) do
							for m = 1, scroll.maxtoshow do
								if not scroll.progress[m] then scroll.progress[m] = 0 end
								local xx, yy = x + scroll.x, y + scroll.y + ((m - 1) * (scroll.height))
								if cx >= xx and cx <= xx + scroll.width and cy >= yy and cy <=  yy + scroll.height then
									scroll.progress[m] = scroll.progress[m] + 0.08 > 1 and 1 or scroll.progress[m] + 0.08
								else
									scroll.progress[m] = scroll.progress[m] - 0.08 < 0 and 0 or scroll.progress[m] - 0.08
								end
								local r, g, b
								if m % 2 == 0 then
									r, g, b = scroll.r1, scroll.g1, scroll.b1 
								else
									r, g, b = scroll.b2, scroll.g2, scroll.b2
								end
								local rr, gg, bb 
								if scroll.selectedpos == m then
									rr, gg, bb = interpolateBetween(scroll.sr, scroll.sg, scroll.sb, scroll.tr, scroll.tg, scroll.tb, scroll.progress[m], "Linear") 
								else
									rr, gg, bb = interpolateBetween(r, g, b, scroll.tr, scroll.tg, scroll.tb, scroll.progress[m], "Linear")
								end
								if m == 1 then
									dxDrawRoundedRectangle(xx, yy, scroll.width, scroll.height, tocolor(rr, gg, bb, scroll.a), 8, "top")
								elseif m == scroll.maxtoshow then
									dxDrawRoundedRectangle(xx, yy, scroll.width, scroll.height, tocolor(rr, gg, bb, scroll.a), 8, "bottom")
								else
									dxDrawRectangle(xx, yy, scroll.width, scroll.height, tocolor(rr, gg, bb, scroll.a))
								end
								dxDrawText(scroll.tbl[m + scroll.scrollidx] or "-", xx, yy, xx + scroll.width, yy + scroll.height, -1, 1, "default-bold", "center", "center", false, false, false, true)
								-- Scroll index
								if m == 1 then
									if #scroll.tbl > scroll.maxtoshow then
										local step = ((scroll.maxtoshow * scroll.height) - 16) / (#scroll.tbl - scroll.maxtoshow)
										dxDrawRectangle(xx + scroll.width + 1, scroll.y + panel.y + 8 + (step * scroll.scrollidx), 5, 5, tocolor(255, 165, 0, 255))
									end
								end
							end
						end
						-- Texts
						for _, text in pairs(tab.texts) do
							dxDrawText(text.text, x + text.x, y + text.y, x + text.x + text.endx, y + text.y + text.endy, tocolor(text.r, text.g, text.b, 255), text.size, text.font, text.alignx, text.aligny, false, text.wordbreak, false, not text.wordbreak)
						end
						-- Edits
						for _, edit in pairs(tab.edits) do
							dxDrawRoundedRectangle(x + edit.x, y + edit.y, edit.width, edit.height, tocolor(255, 255, 255, 100), 8)
							if edit.ismemo then
								dxDrawText(edit.text, x + edit.x + 5, y + edit.y, x + edit.x + edit.width, y + edit.y + edit.height, tocolor(180, 180, 180, 255), 1, "default", "left", "top", false, true)
							else
								dxDrawText(edit.text, x + edit.x, y + edit.y, x + edit.x, y + edit.y + edit.height, tocolor(180, 180, 180, 255), 1, "default", "left", "center")
							end
							if edit.selected then
								local offstx = edit.ismemo and 0 or dxGetTextWidth(edit.text, 1, "default")
								offstx = edit.ismemo and #edit.text > 0 and sx + 300 or offstx
								dxDrawText("|", x + edit.x + offstx, y + edit.y, x + edit.x + edit.width, y + edit.y + edit.height, -1, 1, "default", "left", edit.ismemo and "top" or "center", false, true)
							end
						end
						-- Lines
						for _, line in pairs(tab.lines) do
							dxDrawLine(x + line.x, y + line.y, x + line.width + line.x, y + line.y, line.color)
						end
						-- Buttons
						for _, button in pairs(tab.buttons) do
							if button.visible then
								if cx >= x + button.x and cx <= x + button.x + button.width and cy >= y + button.y and cy <= y + button.y + button.height then
									button.progress = button.progress + 0.08 > 1 and 1 or button.progress + 0.08
								else
									button.progress = button.progress - 0.08 < 0 and 0 or button.progress - 0.08
								end
								local r, g, b = interpolateBetween(button.r, button.g, button.b, button.pr, button.pg, button.pb, button.progress, "Linear")
								dxDrawRoundedRectangle(x + button.x, y + button.y, button.width, button.height, tocolor(r, g, b, button.a), 15)
								dxDrawText(button.text, x + button.x, y + button.y, x + button.x + button.width, y + button.y + button.height, -1, 1, "default-bold", "center", "center")
							end
						end
						-- Toggles
						for _, toggle in pairs(tab.toggles) do
							if toggle.state then
								toggle.progress = toggle.progress + 0.08 > 1 and 1 or toggle.progress + 0.08
							else
								toggle.progress = toggle.progress - 0.08 < 0 and 0 or toggle.progress - 0.08
							end
							dxDrawLine(x + toggle.x, y + toggle.y, x + toggle.x + toggle.width, y + toggle.y, tocolor(toggle.lr, toggle.lg, toggle.lb, toggle.a), toggle.height / 2.5)
							local xpos = interpolateBetween(x + toggle.x, 0, 0, x + toggle.x + toggle.width - toggle.height, 0, 0, toggle.progress, "Linear")
							local r, g, b = interpolateBetween(toggle.dr, toggle.dg, toggle.db, toggle.ar, toggle.ag, toggle.ab, toggle.progress, "Linear")
							dxDrawRectangle(xpos, y + toggle.y - toggle.height / 2, toggle.height, toggle.height, tocolor(r, g, b, 255))
							dxDrawText(toggle.text, x + toggle.x, y + toggle.y - (toggle.height + (toggle.height / 2)), x + toggle.x + toggle.width, y + toggle.y - (toggle.height + (toggle.height / 2)), -1, toggle.fsize, toggle.ftype, "center", "top")
							dxDrawText(toggle.description, x + toggle.x - 30, y + toggle.y + toggle.height - (toggle.height / 2) + 5, x + toggle.x + toggle.width + 30, y + toggle.y + toggle.height - (toggle.height / 2) + 5, -1, 1, "default", "center", "top", false, true)
						end
						-- Browser
						if tab.browser then
							dxDrawImage(x + tab.browser.x, y + tab.browser.y, tab.browser.width, tab.browser.height, tab.browser.browser)
							if tab.browser.showbuttons then 
								local r, g, b
								-- Back
								if cx >= x + tab.browser.buttons.back.x and cx <= x + tab.browser.buttons.back.x + 40 and cy >= y + tab.browser.buttons.back.y and cy <= y + tab.browser.buttons.back.y + 40 then
									tab.browser.buttons.back.progress = tab.browser.buttons.back.progress + 0.08 > 1 and 1 or tab.browser.buttons.back.progress + 0.08
								else
									tab.browser.buttons.back.progress = tab.browser.buttons.back.progress - 0.08 < 0 and 0 or tab.browser.buttons.back.progress - 0.08
								end
								r, g, b = interpolateBetween(40, 40, 40, 60, 60, 60, tab.browser.buttons.back.progress, "Linear")
								dxDrawRectangle(x + tab.browser.buttons.back.x, y + tab.browser.buttons.back.y - 5, 40, 40, tocolor(r, g, b, 150))
								dxDrawText("<", x + tab.browser.buttons.back.x, y + tab.browser.buttons.back.y - 5, x + tab.browser.buttons.back.x + 40, y + tab.browser.buttons.back.y - 5 + 40, -1, 2, "default-bold", "center", "center")
								-- Forward
								if cx >= x + tab.browser.buttons.forward.x and cx <= x + tab.browser.buttons.forward.x + 40 and cy >= y + tab.browser.buttons.forward.y and cy <= y + tab.browser.buttons.forward.y + 40 then
									tab.browser.buttons.forward.progress = tab.browser.buttons.forward.progress + 0.08 > 1 and 1 or tab.browser.buttons.forward.progress + 0.08
								else
									tab.browser.buttons.forward.progress = tab.browser.buttons.forward.progress - 0.08 < 0 and 0 or tab.browser.buttons.forward.progress - 0.08
								end
								r, g, b = interpolateBetween(40, 40, 40, 60, 60, 60, tab.browser.buttons.forward.progress, "Linear")
								dxDrawRectangle(x + tab.browser.buttons.forward.x, y + tab.browser.buttons.forward.y - 5, 40, 40, tocolor(r, g, b, 150))
								dxDrawText(">", x + tab.browser.buttons.forward.x, y + tab.browser.buttons.forward.y - 5, x + tab.browser.buttons.forward.x + 40, y + tab.browser.buttons.forward.y - 5 + 40, -1, 2, "default-bold", "center", "center")
								-- Refresh
								if cx >= x + tab.browser.buttons.refresh.x and cx <= x + tab.browser.buttons.refresh.x + 40 and cy >= y + tab.browser.buttons.refresh.y and cy <= y + tab.browser.buttons.refresh.y + 40 then
									tab.browser.buttons.refresh.progress = tab.browser.buttons.refresh.progress + 0.08 > 1 and 1 or tab.browser.buttons.refresh.progress + 0.08
								else
									tab.browser.buttons.refresh.progress = tab.browser.buttons.refresh.progress - 0.08 < 0 and 0 or tab.browser.buttons.refresh.progress - 0.08
								end
								r, g, b = interpolateBetween(40, 40, 40, 60, 60, 60, tab.browser.buttons.refresh.progress, "Linear")
								dxDrawRectangle(x + tab.browser.buttons.refresh.x, y + tab.browser.buttons.refresh.y - 5, 40, 40, tocolor(r, g, b, 150))
								dxDrawImage(x + tab.browser.buttons.refresh.x + 5, y + tab.browser.buttons.refresh.y - 5 + 4, 32, 32, "files/img/browser/refresh.png")
								-- Other buttons
								for id, button in pairs(tab.browser.buttons.others) do
									if cx >= button.x + x and cx <= button.x + 40 + x and cy >= y + tab.browser.buttons.refresh.y and cy <= y + tab.browser.buttons.refresh.y + 40 then
										button.progress = button.progress + 0.08 > 1 and 1 or button.progress + 0.08
									else
										button.progress = button.progress - 0.08 < 0 and 0 or button.progress - 0.08
									end
									r, g, b = interpolateBetween(40, 40, 40, 60, 60, 60, button.progress, "Linear")
									dxDrawRectangle(x + button.x, y + tab.browser.buttons.back.y - 5, 40, 40, tocolor(r, g, b, 150))
									if button.imgsrc then
										local x, y = x + button.x, y + tab.browser.buttons.back.y - 5
										if button.whiteback then
											dxDrawRectangle(x + button.offx + 5, y + button.offy + 5, button.width - 10, button.height - 10, -1)
										end
										dxDrawImage(x + button.offx, y + button.offy, button.width, button.height, button.imgsrc)
									end
								end
							end
							-- Edit URL
							if tab.browser.guiedit then
								if not guiGetVisible(tab.browser.guiedit) then
									guiSetVisible(tab.browser.guiedit, true)
								end
								guiSetText(tab.browser.guiedit, getBrowserURL(tab.browser.browser))
							end
						end
						-- Combo box
						for i = 1, #tab.combobox do
							if not guiGetVisible(tab.combobox[i]) then
								guiSetVisible(tab.combobox[i], true)
							end
						end
					else
						-- Hide browser URL edit (changing tab)
						if tab.browser then
							if tab.browser.guiedit then
								if guiGetVisible(tab.browser.guiedit) then
									guiSetVisible(tab.browser.guiedit, false)
								end
							end
						end
						-- Hide combobox (changing tab)
						for i = 1, #tab.combobox do
							if guiGetVisible(tab.combobox[i]) then
								guiSetVisible(tab.combobox[i], false)
							end
						end
					end
				end
			else
				for tabid, tab in pairs(panel.tabs) do
					-- Hide browser URL edit
					if tab.browser then
						if tab.browser.guiedit then
							if guiGetVisible(tab.browser.guiedit) then
								guiSetVisible(tab.browser.guiedit, false)
							end
						end
					end
					-- Hide combobox
					for i = 1, #tab.combobox do
						if guiGetVisible(tab.combobox[i]) then
							guiSetVisible(tab.combobox[i], false)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientClick", root,
	function(button, state, cx, cy)
		if state == "up" then
			for _, panel in pairs(sPanels) do
				if panel.show then
					local offstx = 0
					for tabid, tab in pairs(panel.tabs) do
						-- Tabs
						local xx, yy = panel.x + offstx, panel.y - tab.height - 2
						local w = dxGetTextWidth(tab.name, tab.size, "default-bold") + 20
						-- Tab animation
						if cx >= xx and cx <= xx + w and cy >= yy and cy <=  yy + tab.height then
							selectedtab = tabid
							triggerEvent("dx:onPlayerClickTab", localPlayer, tabid)
							return
						end
						offstx = offstx + w + 2
						--
						if selectedtab == tabid then				
							-- Edits
							for id, edit in pairs(tab.edits) do
								if cx >= edit.x + panel.x and cx <= edit.x + panel.x + edit.width and cy >= edit.y + panel.y and cy <= edit.y + panel.y + edit.height then
									edit.selected = true
									triggerEvent("dx:onPlayerClick", localPlayer, id)
								else
									edit.selected = false
								end
							end
							-- Scrolls
							for id, scroll in pairs(tab.scrolls) do
								for i = 1, scroll.maxtoshow do
									local starty = scroll.y + ((i - 1) * scroll.height)
									if cx >= scroll.x + panel.x and cx <= scroll.x + panel.x + scroll.width and cy >= starty + panel.y and cy <= starty + panel.y + scroll.height then
										triggerEvent("dx:onPlayerClick", localPlayer, id, scroll.tbl[i + scroll.scrollidx], i)
										return
									end
								end
							end
							-- Buttons
							for id, button in pairs(tab.buttons) do
								if button.visible then
									if cx >= button.x + panel.x and cx <= button.x + panel.x + button.width and cy >= button.y + panel.y and cy <= button.y + panel.y + button.height then
										triggerEvent("dx:onPlayerClick", localPlayer, id)
										return
									end
								end
							end
							-- Toggles
							for id, toggle in pairs(tab.toggles) do
								if cx >= toggle.x + panel.x and cx <= toggle.x + panel.x + toggle.width and cy >= toggle.y + panel.y - (toggle.height / 2) and cy <= toggle.y + panel.y + (toggle.height / 2) then
									toggle.state = not toggle.state
									triggerEvent("dx:onPlayerClick", localPlayer, id, toggle.state)
									return
								end
							end
							-- Browser buttons
							if tab.browser then
								if cx >= panel.x + tab.browser.x and cx <= panel.x + tab.browser.x + tab.browser.width and cy >= panel.y + tab.browser.y and cy <= panel.y + tab.browser.y + tab.browser.height then
									injectBrowserMouseUp(tab.browser.browser, button)
								end
								if tab.browser.showbuttons then
									-- Back
									if cx >= panel.x + tab.browser.buttons.back.x and cx <= panel.x + tab.browser.buttons.back.x + 40 and cy >= panel.y + tab.browser.buttons.back.y and cy <= panel.y + tab.browser.buttons.back.y + 40 then
										navigateBrowserBack(tab.browser.browser)
										return
									end
									-- Forward
									if cx >= panel.x + tab.browser.buttons.forward.x and cx <= panel.x + tab.browser.buttons.forward.x + 40 and cy >= panel.y + tab.browser.buttons.forward.y and cy <= panel.y + tab.browser.buttons.forward.y + 40 then
										navigateBrowserForward(tab.browser.browser)
										return
									end
									-- Refresh
									if cx >= panel.x + tab.browser.buttons.refresh.x and cx <= panel.x + tab.browser.buttons.refresh.x + 40 and cy >= panel.y + tab.browser.buttons.refresh.y and cy <= panel.y + tab.browser.buttons.refresh.y + 40 then
										reloadBrowserPage(tab.browser.browser)
										return
									end
									-- Other buttons
									for id, button in pairs(tab.browser.buttons.others) do
										if cx >= button.x + panel.x and cx <= button.x + 40 + panel.x and cy >= panel.y + tab.browser.buttons.refresh.y and cy <= panel.y + tab.browser.buttons.refresh.y + 40 then
											triggerEvent("dx:onPlayerClick", localPlayer, id)
											return
										end
									end
								end
							end
						end
					end
				end
			end
		else
			for _, panel in pairs(sPanels) do
				if panel.show then
					for tabid, tab in pairs(panel.tabs) do
						if selectedtab == tabid then
							-- Browser buttons
							if tab.browser then
								if cx >= panel.x + tab.browser.x and cx <= panel.x + tab.browser.x + tab.browser.width and cy >= panel.y + tab.browser.y and cy <= panel.y + tab.browser.y + tab.browser.height then
									injectBrowserMouseDown(tab.browser.browser, button)
								end
								return
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
		for _, panel in pairs(sPanels) do
			if panel.show then
				for tabid, tab in pairs(panel.tabs) do
					if selectedtab == tabid then
						for id, edit in pairs(tab.edits) do
							if edit.selected then
								if #edit.text < edit.maxcharacters then
									edit.text = edit.text.. "" ..key
									triggerEvent("dx:onPlayerType", localPlayer, id, edit.text)
								end
								return
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientKey", root,
	function(key, state)
		if key == "backspace" and state then
			for _, panel in pairs(sPanels) do
				if panel.show then
					for tabid, tab in pairs(panel.tabs) do
						if selectedtab == tabid then
							for id, edit in pairs(tab.edits) do
								if edit.selected then
									edit.text = edit.text:sub(0, #edit.text - 1)
									triggerEvent("dx:onPlayerType", localPlayer, id, edit.text)
									return
								end
							end
						end
					end
				end
			end
		elseif key == "mouse_wheel_down" or key == "mouse_wheel_up" then
			for _, panel in pairs(sPanels) do
				if panel.show then
					for tabid, tab in pairs(panel.tabs) do
						if selectedtab == tabid then
							-- Browser
							if tab.browser then
								if key == "mouse_wheel_down" then
									injectBrowserMouseWheel(tab.browser.browser, -60, 0)
									return
								elseif key == "mouse_wheel_up" then
									injectBrowserMouseWheel(tab.browser.browser, 60, 0)
									return
								end
							end
							-- Scroll
							for _, scroll in pairs(tab.scrolls) do
								local starty = scroll.y + panel.y
								local endy = scroll.y + (scroll.height * scroll.maxtoshow) + panel.y
								local cx, cy = getCursorPosition()
								cx = cx and cx * sx or 0
								cy = cy and cy * sy or 0
								if cx >= scroll.x + panel.x and cx <= scroll.x + panel.x + scroll.width and cy >= starty and cy <= endy then
									if key == "mouse_wheel_down" then
										if scroll.scrollidx == (#scroll.tbl - scroll.maxtoshow) or #scroll.tbl < scroll.maxtoshow then return end
										scroll.scrollidx = scroll.scrollidx + 1
										return
									elseif key == "mouse_wheel_up" then
										if scroll.scrollidx == 0 then return end
										scroll.scrollidx = scroll.scrollidx - 1
										return
									end
								end
							end
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientCursorMove", root,
	function(_, _, cx, cy)
		for _, panel in pairs(sPanels) do
			if panel.show then
				for tabid, tab in pairs(panel.tabs) do
					if selectedtab == tabid then
						-- Browser
						if tab.browser then
							local x, y = panel.x + tab.browser.x, panel.y + tab.browser.y
							if cx >= x and cx <= x + tab.browser.width and cy >= y and cy <= y + tab.browser.height then
								injectBrowserMouseMove(tab.browser.browser, cx - x, cy - y) 
							end
						end
					end
				end
			end
		end
	end
)

function dxCreatePanelWindow(x, y, w, h, r, g, b, a)
	local panelid = getRandomID()
	sPanels[panelid] = { x = x, y = y, w = w, h = h, r = r, g = g, b = b, a = a, show = false, progress = 0, tabs = {} }
	return panelid
end

function dxCreatePanelTab(panelid, name)
	local tabid = getRandomID(true)
	sPanels[panelid].tabs[tabid] = { name = name, font = "default-bold", size = 1, height = 30, r = 0, g = 0, b = 0, a = 200, sr = 255, sg = 165, sb = 0, tr = 255, tg = 255, tb = 255, selected = false, progress = 0, scrolls = {}, texts = {}, buttons = {}, edits = {}, rectangles = {}, lines = {}, toggles = {}, browser, combobox = {} }
	return tabid
end

function dxTabSetFont(tabid, font, size)
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].font = font
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].size = size
end

function dxTabSetColor(tabid, r, g, b)
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].r = r
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].g = g
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].b = b
end

function dxTabSetAlpha(tabid, a)
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].a = a
end

function dxTabSetSelectedColor(tabid, r, g, b)
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].sr = r
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].sg = g
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].sb = b
end

function dxTabSetTransitionColor(tabid, r, g, b)
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].tr = r
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].tg = g
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].tb = b
end

function dxCreateScroll(tabid, x, y, width, height, maxtoshow)
	local scrollid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].scrolls[scrollid] = { x = x, y = y, width = width, height = height, maxtoshow = maxtoshow, r1 = 30, b1 = 30, g1 = 30, r2 = 60, b2 = 60, g2 = 60, tr = 239, tg = 127, tb = 36, sr = 255, sb = 200, sg = 100, a = 200, scrollidx = 0, selectedpos = 0, tbl = {}, progress = {} }
	return scrollid
end

function dxScrollSetSelected(scrollid, pos)
	local tabid = getTabIDfromScrollID(scrollid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].scrolls[scrollid].selectedpos = pos
end

function dxScrollGetSelected(scrollid)
	local tabid = getTabIDfromScrollID(scrollid)
	local panelid = getPanelIDfromTabID(tabid)
	local scroll = sPanels[panelid].tabs[tabid].scrolls[scrollid]
	return scroll.selectedpos > 0 and scroll.tbl[scroll.selectedpos + scroll.scrollidx] or false
end

function dxScrollSetTable(scrollid, tbl)
	local tabid = getTabIDfromScrollID(scrollid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].scrolls[scrollid].tbl = tbl
end

function dxCreateTextLabel(tabid, text, x, y, size, font)
	local textid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].texts[textid] = { text = text, x = x, y = y, r = 255, g = 255, b = 255, size = size, font = font, endx = 0, endy = 0, alignx = "left", aligny = "top", wordbreak = false }
	return textid
end

function dxTextSetText(textid, text)
	local tabid = getTabIDfromTextID(textid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].texts[textid].text = text
end

function dxTextSetWordbreak(textid, bool)
	local tabid = getTabIDfromTextID(textid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].texts[textid].wordbreak = bool
end

function dxTextSetAlignment(textid, endx, endy, alignx, aligny)
	local tabid = getTabIDfromTextID(textid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].texts[textid].endx = endx
	sPanels[panelid].tabs[tabid].texts[textid].endy = endy
	sPanels[panelid].tabs[tabid].texts[textid].alignx = alignx
	sPanels[panelid].tabs[tabid].texts[textid].aligny = aligny
end

function dxCreateRectangle(tabid, x, y, width, height, color)
	local rectangleid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].rectangles[rectangleid] = { x = x, y = y, width = width, height = height, color = color }
	return rectangleid
end

function dxCreateLine(tabid, x, y, width, color)
	local lineid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].lines[lineid] = { x = x, y = y, width = width, color = color }
	return lineid
end

function dxCreateEdit(tabid, x, y, width, height, ismemo)
	local editid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].edits[editid] = { x = x, y = y, width = width, height = height, selected = false, text = "", maxcharacters = 18, ismemo = ismemo }
	return editid
end

function dxSetEditMaxCharacters(editid, maxcharacters)
	local tabid = getTabIDfromEditID(editid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].edits[editid].maxcharacters = maxcharacters
end

function dxSetEditText(editid, text)
	local tabid = getTabIDfromEditID(editid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].edits[editid].text = text
end

function dxGetEditText(editid)
	local tabid = getTabIDfromEditID(editid)
	local panelid = getPanelIDfromTabID(tabid)
	return sPanels[panelid].tabs[tabid].edits[editid].text
end

function dxCreateButton(tabid, text, x, y, width, height)
	local buttonid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].buttons[buttonid] = { text = text, x = x, y = y, width = width, height = height, progress = 0, r = 50, g = 50, b = 50, pr = 255, pg = 165, pb = 0, a = 200, visible = true }
	return buttonid
end

function dxSetButtonVisible(buttonid, bool)
	local tabid = getTabIDfromButtonID(buttonid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].buttons[buttonid].visible = bool
end

function dxCreateToggle(tabid, text, description, x, y, width, height)
	local toggleid = getRandomID()
	sPanels[getPanelIDfromTabID(tabid)].tabs[tabid].toggles[toggleid] = { text = text, description = description, x = x, y = y, width = width, height = height, fsize = 1, ftype = "default", progress = 0, lr = 100, lg = 100, lb = 100, dr = 130, dg = 130, db = 130, ar = 255, ag = 165, ab = 0, a = 200, state = false }
	return toggleid
end

function dxToggleSetFont(toggleid, fonttype, size)
	local tabid = getTabIDfromToggleID(toggleid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].toggles[toggleid].ftype = fonttype
	sPanels[panelid].tabs[tabid].toggles[toggleid].fsize = size
end

function dxToggleSetState(toggleid, state)
	local tabid = getTabIDfromToggleID(toggleid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].toggles[toggleid].state = state
end

function dxSetTabSelected(tabid, bool)
	if tabid == nil then
		selectedtab = -1
		return
	end
	selectedtab = tabid
end

function dxCreateBrowser(tabid, x, y, width, height, showbuttons)
	local panelid = getPanelIDfromTabID(tabid)
	local browser = createBrowser(width, height, false)
	sPanels[panelid].tabs[tabid].browser = { showbuttons = showbuttons, browser = browser, guiedit = nil, x = x, y = y, width = width, height = height, buttons = { back = { x = x, y = y - 45, progress = 0 }, forward = { x = x + 45, y = y - 45, progress = 0 }, refresh = { x = x + 90, y = y - 45, progress = 0 }, others = {} } }
	return browser
end

function dxBrowserAddButton(browserid, x, y, width, height, imgsrc, idx, whiteback)
	local buttonid = getRandomID()
	local tabid = getTabIDfromBrowser(browserid)
	local panelid = getPanelIDfromTabID(tabid)
	sPanels[panelid].tabs[tabid].browser.buttons.others[buttonid] = { offx = x, offy = y, x = sPanels[panelid].tabs[tabid].browser.x + 90 + (idx * 45), imgsrc = imgsrc, whiteback = whiteback, width = width, height = height, progress = 0 }
	return buttonid
end

function dxBrowserAddWebURLEdit(browserid, x, y, width, height)
	local buttonid = getRandomID()
	local tabid = getTabIDfromBrowser(browserid)
	local panelid = getPanelIDfromTabID(tabid)
	local guiedit = guiCreateEdit(sPanels[panelid].x + x, sPanels[panelid].y + y, width, height, "", false)
	guiEditSetReadOnly(guiedit, true)
	guiSetVisible(guiedit, false)
	sPanels[panelid].tabs[tabid].browser.guiedit = guiedit
end

function dxCreateComboBox(tabid, x, y, width, height, title)
	local panelid = getPanelIDfromTabID(tabid)
	local combo = guiCreateComboBox(sPanels[panelid].x + x, sPanels[panelid].y + y, width, height, title, false)
	sPanels[panelid].tabs[tabid].combobox[#sPanels[panelid].tabs[tabid].combobox + 1] = combo
	guiSetVisible(combo, false)
	return combo
end

function dxSetPanelVisible(id, bool)
	sPanels[id].show = bool
	showCursor(bool)
	guiSetInputMode(bool and "no_binds" or "allow_binds")
end

function dxIsPanelVisible(id)
	return sPanels[id].show
end

function getPanelIDfromTabID(tabid)
	for id in pairs(sPanels) do
		for le in pairs(sPanels[id].tabs) do
			if le == tabid then
				return id
			end
		end
	end
end

function getTabIDfromTextID(textid)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			for id in pairs(sPanels[t].tabs[e].texts) do
				if id == textid then
					return e
				end
			end
		end
	end
end

function getTabIDfromEditID(editid)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			for id in pairs(sPanels[t].tabs[e].edits) do
				if id == editid then
					return e
				end
			end
		end
	end
end

function getTabIDfromButtonID(buttonid)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			for id in pairs(sPanels[t].tabs[e].buttons) do
				if id == buttonid then
					return e
				end
			end
		end
	end
end

function getTabIDfromToggleID(toggleid)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			for id in pairs(sPanels[t].tabs[e].toggles) do
				if id == toggleid then
					return e
				end
			end
		end
	end
end

function getTabIDfromScrollID(scrollid)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			for id in pairs(sPanels[t].tabs[e].scrolls) do
				if id == scrollid then
					return e
				end
			end
		end
	end
end

function getTabIDfromBrowser(browser)
	for t in pairs(sPanels) do
		for e in pairs(sPanels[t].tabs) do
			if sPanels[t].tabs[e].browser then
				if sPanels[t].tabs[e].browser.browser == browser then
					return e
				end
			end
		end
	end
end

function getRandomID(istab)
	local idx = 500
	if istab then
		idx = 1
	end
	while true do
		if not _gIDS[idx] then
			_gIDS[idx] = true
			return idx
		end
		idx = idx + 1
	end
end

function switch_key_val(tbl)
    local rtbl = {}
    for k,v in pairs(tbl) do
        rtbl[v] = k
    end
    return rtbl
end