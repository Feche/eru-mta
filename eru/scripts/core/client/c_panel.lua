local panel_config_file = "5594318047"

local sx, sy = guiGetScreenSize()
local top5 = {}
panelsettings = {} -- shared with c_settings.lua
local gRankings = nil
local gTeams = {}
local browserpageloaded = false

addEvent("panel:onReceiveMapInfo", true)
addEvent("login:onPlayerLoginEx", true)
addEvent("radio:onPlayerAddSongToRadio", true)
addEvent("panel:onReceiveRankings", true)
addEvent("panel:onReceiveClanInfo", true)
addEvent("panel:onReceiveServerClans", true)
addEvent("panel:onReceiveClanInfoManage", true)

addEvent("dx:onPlayerClick")
addEvent("dx:onPlayerType")
addEvent("dx:onPlayerClickTab")

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		local width, height = 740, 580
		local panelx, panely = sx / 2 - width / 2, sy / 2 - height / 2
		panel = dxCreatePanelWindow(panelx, panely, width, height, 0, 0, 0, 200)
		-- Stats
		statstab = dxCreatePanelTab(panel, "stats")
		playerscroll = dxCreateScroll(statstab, 30, 45, 200, 30, 15)
		dxCreateTextLabel(statstab, "Click on a player to view their stats:", 30, 20, 1, "default")
		dxCreateRectangle(statstab, 10, 10, 240, 560, tocolor(0, 0, 0, 180))
		dxCreateTextLabel(statstab, "Search player:", 90, 515, 1, "default")
		wwwlabel = dxCreateTextLabel(statstab, "www.eru-crew.com", 250, 565, 1, "default")
		dxTextSetAlignment(wwwlabel, 489, 30, "center", "top")
		searchplayeredit = dxCreateEdit(statstab, 56, 535, 150, 22)
		--
		playernamelabel = dxCreateTextLabel(statstab, "", 250, 10, 2, "default")
		dxTextSetAlignment(playernamelabel, 489, 30, "center", "top")
		--
		statslabel1 = dxCreateTextLabel(statstab, "", 250, 55, 1, "default-bold")
		dxTextSetAlignment(statslabel1, 489, 30, "center", "top")
		local left = 10
		local right = 100
		local center = 58
		local yoffst = 180
		-- DM label
		roomsdmtatslabel = dxCreateTextLabel(statstab, "", 250 + left, 190 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsdmtatslabel, 130, 30, "center", "top")
		-- Shooter label
		roomsshootertatslabel = dxCreateTextLabel(statstab, "", 370 + center, 190 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsshootertatslabel, 130, 30, "center", "top")
		-- Old DM label
		roomsodmtatslabel = dxCreateTextLabel(statstab, "", 500 + right, 190 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsodmtatslabel, 130, 30, "center", "top")
		-- Race label
		roomsracetatslabel = dxCreateTextLabel(statstab, "", 250 + left, 280 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsracetatslabel, 130, 30, "center", "top")
		-- OJ label
		roomsojtatslabel = dxCreateTextLabel(statstab, "", 500 + right, 280 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsojtatslabel, 130, 30, "center", "top")
		-- Training label
		roomstrainingtatslabel = dxCreateTextLabel(statstab, "", 370 + center, 280 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomstrainingtatslabel, 130, 30, "center", "top")
		-- Destruction derby
		roomsddtatslabel = dxCreateTextLabel(statstab, "", 250 + left, 100 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomsddtatslabel, 130, 30, "center", "top")
		-- Trials
		roomstrialstatslabel = dxCreateTextLabel(statstab, "", 500 + right, 100 + yoffst, 1, "default-bold")
		dxTextSetAlignment(roomstrialstatslabel, 130, 30, "center", "top")
		--
		statslabel2 = dxCreateTextLabel(statstab, "", 250, 60, 1, "default-bold")
		--
		dxCreateLine(statstab, 290, 45, 405, tocolor(255, 165, 0, 200))
	--	dxCreateLine(statstab, 290, 350, 405, tocolor(255, 165, 0, 200))
		dxCreateLine(statstab, 290, 550, 405, tocolor(255, 165, 0, 200))
		-- Maps
		mapstab = dxCreatePanelTab(panel, "maps")
		dxCreateTextLabel(mapstab, "Click on a map to view its info, press on 'buy' to set as next map.", 35, 20, 1, "default")
		mapscroll = dxCreateScroll(mapstab, 30, 45, 360, 30, 16)
		dxCreateTextLabel(mapstab, "Search:", 45, 550, 1, "default")
		searchmapedit = dxCreateEdit(mapstab, 95, 545, 250, 25)
		-- 
		local xoffst = 48
		yoffst = 20
		dxCreateTextLabel(mapstab, "#ffa500Map info", 490 + xoffst, 50 + yoffst, 1, "default-bold")
		mapinfolabel = dxCreateTextLabel(mapstab, "-\n-\n-\n-", 450 + xoffst, 70 + yoffst, 1, "default")
		dxTextSetAlignment(mapinfolabel, 130, 30, "center", "top")
		dxCreateRectangle(mapstab, 415 + xoffst, 40 + yoffst, 200, 140, tocolor(0, 0, 0, 180))
		yoffst = 80
		dxCreateTextLabel(mapstab, "#ffa500Toptimes", 490 + xoffst, 150 + yoffst, 1, "default-bold")
		dxCreateRectangle(mapstab, 395 + xoffst, 173 + yoffst, 240, 210, tocolor(0, 0, 0, 180))
		for i = 1, 10 do
			top5[i] = { pos = dxCreateTextLabel(mapstab, i.. ":", (i == 10 and 404 or 410) + xoffst, 180 + yoffst, 1, "default"), name = dxCreateTextLabel(mapstab, "-", 420 + xoffst, 180 + yoffst, 1, "default"), time = dxCreateTextLabel(mapstab, "-", 510 + xoffst, 180 + yoffst, 1, "default"), date = dxCreateTextLabel(mapstab, "-", 560 + xoffst, 180 + yoffst, 1, "default") }
			dxTextSetAlignment(top5[i].name, 85, 30, "center", "top")
			yoffst = yoffst + 20
		end
		buymapbutton = dxCreateButton(mapstab, "Buy map [$2k]", 464 + xoffst, 160, 100, 30)
		--
		xoffst = 88
		local yoffst = 30
		settingstab = dxCreatePanelTab(panel, "settings")
		settingslabel = dxCreateTextLabel(settingstab, "Click on the option that you want to enable or disable\nThese settings are saved, and restored when you login.", 0, 0, 1, "default-bold")
		dxTextSetAlignment(settingslabel, 740, 70, "center", "center") 
		fadecars = dxCreateToggle(settingstab, "Car fade", "Don't let others ruin your toptimes by blinding you with their car!", 50 + xoffst, 90 + yoffst, 110, 35)
		dxToggleSetFont(fadecars, "default-bold", 2)
		hideplayers = dxCreateToggle(settingstab, "Hide players", "If you are low on fps, this is your choice.", 50 + xoffst, 220 + yoffst, 110, 35)
		dxToggleSetFont(hideplayers, "default-bold", 2)
		watershader = dxCreateToggle(settingstab, "Water", "This option lets you disable the water shader.", 50 + xoffst, 335 + yoffst, 110, 35)
		dxToggleSetFont(watershader, "default-bold", 2)
		bloomshader = dxCreateToggle(settingstab, "Bloom", "Adds realistic effects to lights and shiny parts.", 220 + xoffst, 90 + yoffst, 110, 35)
		dxToggleSetFont(bloomshader, "default-bold", 2)
		hdrshader = dxCreateToggle(settingstab, "HDR", "Adds a nice contrast tone to the scenario.", 220 + xoffst, 220 + yoffst, 110, 35)
		dxToggleSetFont(hdrshader, "default-bold", 2)
		blur = dxCreateToggle(settingstab, "Blur", "If you like crazy blur effects, be sure to have this activated.", 220 + xoffst, 335 + yoffst, 110, 35)
		dxToggleSetFont(blur, "default-bold", 2)
		decoration = dxCreateToggle(settingstab, "Decoration", "If you suffer from low fps, this might help you to increase them.", 400 + xoffst, 90 + yoffst, 110, 35)
		dxToggleSetFont(decoration, "default-bold", 2)
		raceui = dxCreateToggle(settingstab, "Race UI", "This lets you can disable the race user interface.", 400 + xoffst, 220 + yoffst, 110, 35)
		dxToggleSetFont(raceui, "default-bold", 2)
		--
		radio = dxCreateToggle(settingstab, "Radio", "Enabling the radio, you won't hear map music.", 50 + xoffst, 450 + yoffst, 110, 35)
		dxToggleSetFont(radio, "default-bold", 2)
		mapmusic = dxCreateToggle(settingstab, "Map music", "Enabling the map music, you won't hear the radio.", 220 + xoffst, 450 + yoffst, 110, 35)
		dxToggleSetFont(mapmusic, "default-bold", 2)
		skidmarks = dxCreateToggle(settingstab, "Skidmarks", "Crazy rainbow skidmarks effects!", 400 + xoffst, 335 + yoffst, 110, 35)
		dxToggleSetFont(skidmarks, "default-bold", 2)
		shaders = dxCreateToggle(settingstab, "Disable dvo", "This option disables vehicles DVOs.", 400 + xoffst, 450 + yoffst, 110, 35)
		dxToggleSetFont(shaders, "default-bold", 2)
		--
		browsertab = dxCreatePanelTab(panel, "browser")
		browser = dxCreateBrowser(browsertab, 10, 60, 720, 510, true)
		dxBrowserAddWebURLEdit(browser, 240, 15, 320, 30)
		youtube = dxBrowserAddButton(browser, 1, 8, 38, 24, "files/img/browser/yt.png", 1, true)
		google = dxBrowserAddButton(browser, 4, 4, 32, 32, "files/img/browser/gg.png", 2)
		--
		yoffst = -3
		radiotab = dxCreatePanelTab(panel, "radio")
		radiobrowser = dxCreateBrowser(radiotab, 10, 10, 720, 520, false)
		radiobutton = dxCreateButton(radiotab, "Play song", 635, 535, 80, 40)
		dxCreateTextLabel(radiotab, "- #ffff00Maximum song duration is 6 minutes, and only music is allowed, please follow the rules!", 10, 535 + yoffst, 1, "default-bold")
		dxCreateTextLabel(radiotab, "- To view current song press #808080num_0#ffffff - To view queue, press #808080num_0 #FFFFFFand then #808080left alt", 10, 550 + yoffst, 1, "default-bold")
		dxCreateTextLabel(radiotab, "- To mute the radio, press #808080M", 10, 565 + yoffst, 1, "default-bold")
		--
		xoffst = 50
		rankingstab = dxCreatePanelTab(panel, "rankings")
		rankingcombobox = dxCreateComboBox(rankingstab, panelx / 2, 20, 162, 160, "Money & points")
		guiComboBoxAddItem(rankingcombobox, "Money & points")
		guiComboBoxAddItem(rankingcombobox, "Online & time played")
		guiComboBoxAddItem(rankingcombobox, "Spins & flips")
		guiComboBoxAddItem(rankingcombobox, "Hunters & toptimes")
		guiComboBoxAddItem(rankingcombobox, "Wins & win ratio")
		guiComboBoxAddItem(rankingcombobox, "Maps played & deaths")
		guiComboBoxAddItem(rankingcombobox, "Lotteries won & profit")
		guiComboBoxAddItem(rankingcombobox, "Map likes & dislikes")
		guiComboBoxAddItem(rankingcombobox, "Top maps & shooter kills")
		rankingscroll1 = dxCreateScroll(rankingstab, 10, 85, 355, 30, 15)
		rankingscroll2 = dxCreateScroll(rankingstab, 375, 85, 355, 30, 15)
		rankinglabel1 = dxCreateTextLabel(rankingstab, "#ffa500Most money", 10, 55, 1.2, "default-bold")
		dxTextSetAlignment(rankinglabel1, 355, 30, "center", "top")
		rankinglabel2 = dxCreateTextLabel(rankingstab, "#ffa500Most points", 330, 55, 1.2, "default-bold")
		dxTextSetAlignment(rankinglabel2, 455, 30, "center", "top")
		-- CLAN TAB
		clanstab = dxCreatePanelTab(panel, "clans")
		dxCreateTextLabel(clanstab, "Click on a clan to view their info", 40, 20, 1, "default")
		clanscroll = dxCreateScroll(clanstab, 30, 45, 320, 30, 16)
		dxCreateTextLabel(clanstab, "Search:", 45, 550, 1, "default")
		searchclanedit = dxCreateEdit(clanstab, 95, 545, 220, 25)
		dxTextSetAlignment(dxCreateTextLabel(clanstab, "#ffa500Clan name", 350, 55, 1.2, "default-bold"), 387, 30, "center", "top")
		clanname = dxCreateTextLabel(clanstab, "-", 350, 72, 1, "default-bold")
		dxTextSetAlignment(clanname, 387, 30, "center", "top")
		-- Description
		dxTextSetAlignment(dxCreateTextLabel(clanstab, "#ffa500Description", 350, 100, 1.2, "default-bold"), 387, 30, "center", "top")
		clandescription = dxCreateTextLabel(clanstab, "-", 450, 125, 1, "default")
		dxTextSetAlignment(clandescription, 190, 30, "center", "top")
		dxTextSetWordbreak(clandescription, true)
		-- Stats
		dxTextSetAlignment(dxCreateTextLabel(clanstab, "#ffa500Stats", 350, 220, 1.2, "default-bold"), 387, 30, "center", "top")
		clanstats = dxCreateTextLabel(clanstab, "-\n-\n-\n-\n-", 350, 240, 1, "default-bold")
		dxTextSetAlignment(clanstats, 387, 30, "center", "top")
		-- Members
		clanmembers = dxCreateTextLabel(clanstab, "#ffa500Members", 350, 320, 1.2, "default-bold")
		dxTextSetAlignment(clanmembers, 387, 30, "center", "top")
		clanmembersscroll = dxCreateScroll(clanstab, 455, 345, 180, 30, 6)
		createclanbutton = dxCreateButton(clanstab, "Create clan [$1.5kk]", 610, 545, 125, 30)
		manageclanbutton = dxCreateButton(clanstab, "Manage clan", 360, 545, 100, 30)
		dxSetButtonVisible(manageclanbutton, false)
		leaveclanbutton = dxCreateButton(clanstab, "Leave clan", 360, 545, 100, 30)
		dxSetButtonVisible(leaveclanbutton, false)
		removememberbutton = dxCreateButton(clanstab, "Remove member", 480, 545, 110, 30)
		dxSetButtonVisible(removememberbutton, false)
		-- Create clan
		createclanpanel = dxCreatePanelWindow(sx / 2 - 200, sy / 2 - 360 / 2, 400, 360, 0, 0, 0, 200)
		createclanstab = dxCreatePanelTab(createclanpanel, "create clan")
		yoffst = 20
		local x = 400 / 2 - 160 / 2
		dxTextSetAlignment(dxCreateTextLabel(createclanstab, "#ffa500Create clan", x, 10, 1.4, "default-bold"), 160, 30, "center", "top")
		dxTextSetAlignment(dxCreateTextLabel(createclanstab, "Clan name:", x, 20 + yoffst, 1, "default"), 160, 30, "center", "top")
		clannameedit = dxCreateEdit(createclanstab, x, 40 + yoffst, 160, 20)
		dxSetEditMaxCharacters(clannameedit, 25)
		x = 400 / 2 - 80 / 2
		dxTextSetAlignment(dxCreateTextLabel(createclanstab, "Clan tag:", x, 75 + yoffst, 1, "default"), 80, 30, "center", "top")
		clantagedit = dxCreateEdit(createclanstab, x, 95 + yoffst, 80, 20)
		dxSetEditMaxCharacters(clantagedit, 10)
		x = 400 / 2 - 95 / 2
		dxTextSetAlignment(dxCreateTextLabel(createclanstab, "Clan color: (hex)", x, 130 + yoffst, 1, "default"), 95, 30, "center", "top")
		clancoloredit = dxCreateEdit(createclanstab, x, 150 +  yoffst, 95, 20)
		dxSetEditMaxCharacters(clancoloredit, 7)
		x = 400 / 2 - 250 / 2
		dxTextSetAlignment(dxCreateTextLabel(createclanstab, "Clan description:", x, 190 + yoffst, 1, "default"), 250, 30, "center", "top")
		clandescriptionedit = dxCreateEdit(createclanstab, x, 210 + yoffst, 250, 80, true)
		dxSetEditMaxCharacters(clandescriptionedit, 180)
		confirmclanbutton = dxCreateButton(createclanstab, "Confirm clan", 99, 320, 100, 30)
		cancelclanbutton = dxCreateButton(createclanstab, "Cancel", 219, 320, 80, 30)
		-- Modify clan
		manageclanpanel = dxCreatePanelWindow(sx / 2 - 200, sy / 2 - 360 / 2, 400, 360, 0, 0, 0, 200)
		manageclantab = dxCreatePanelTab(manageclanpanel, "manage clan")
		yoffst = 20
		local x = 400 / 2 - 160 / 2
		dxTextSetAlignment(dxCreateTextLabel(manageclantab, "#ffa500Manage clan", x, 10, 1.4, "default-bold"), 160, 30, "center", "top")
		dxTextSetAlignment(dxCreateTextLabel(manageclantab, "Clan name:", x, 20 + yoffst, 1, "default"), 160, 30, "center", "top")
		manageclannameedit = dxCreateEdit(manageclantab, x, 40 + yoffst, 160, 20)
		dxSetEditMaxCharacters(manageclannameedit, 25)
		x = 400 / 2 - 80 / 2
		dxTextSetAlignment(dxCreateTextLabel(manageclantab, "Clan tag:", x, 75 + yoffst, 1, "default"), 80, 30, "center", "top")
		manageclantagedit = dxCreateEdit(manageclantab, x, 95 + yoffst, 80, 20)
		dxSetEditMaxCharacters(manageclantagedit, 10)
		x = 400 / 2 - 95 / 2
		dxTextSetAlignment(dxCreateTextLabel(manageclantab, "Clan color: (hex)", x, 130 + yoffst, 1, "default"), 95, 30, "center", "top")
		manageclancoloredit = dxCreateEdit(manageclantab, x, 150 +  yoffst, 95, 20)
		dxSetEditMaxCharacters(manageclancoloredit, 7)
		x = 400 / 2 - 250 / 2
		dxTextSetAlignment(dxCreateTextLabel(manageclantab, "Clan description:", x, 190 + yoffst, 1, "default"), 250, 30, "center", "top")
		manageclandescriptionedit = dxCreateEdit(manageclantab, x, 210 + yoffst, 250, 80, true)
		dxSetEditMaxCharacters(manageclandescriptionedit, 180)
		manageconfirmclanbutton = dxCreateButton(manageclantab, "Save changes [$250k]", 80, 320, 150, 30)
		managecancelclanbutton = dxCreateButton(manageclantab, "Cancel", 238, 320, 80, 30)
		--
		helptab = dxCreatePanelTab(panel, "help")
		--
		bindKey("f7", "down", toggleUserPanel)
	end
)

addEventHandler("login:onPlayerLoginEx", root,
	function()
		loadSettings()
	end
)

addEventHandler("radio:onPlayerAddSongToRadio", root,
	function()
		loadBrowserURL(radiobrowser, "http://www.youtube.com")
	end
)

addEventHandler("panel:onReceiveMapInfo", root,
	function(data)
		local mapinfo = data.mapinfo
		local toptimes = data.maptoptimes
		if not mapinfo then
			mapinfo = {}
			mapinfo.likes = 0
			mapinfo.dislikes = 0
			mapinfo.timesplayed = 0
		end
		dxTextSetText(mapinfolabel, mapinfo.likes.. " like(s)\n" ..mapinfo.dislikes.. " dislike(s)\n" ..mapinfo.timesplayed.. " times played" ..(toptimes and ("\n" ..#toptimes.. " toptimes") or ""))
		if toptimes then
			for i = 1, 10 do
				if toptimes[i] then
					dxTextSetText(top5[i].name, toptimes[i].name)
					dxTextSetText(top5[i].time, toptimes[i].timestr)
					dxTextSetText(top5[i].date, toptimes[i].date)
				else
					dxTextSetText(top5[i].name, "-")
					dxTextSetText(top5[i].time, "-")
					dxTextSetText(top5[i].date, "-")
				end
			end
		end
	end
)

addEventHandler("dx:onPlayerClick", root,
	function(id, text, scrollpos)
		local bool = text
		if id == playerscroll then
			local target = getPlayerFromPartialName(text)
			if target then
				updateStatsForSelectedPlayer(target)
			end
		elseif id == mapscroll then
			if not text then 
				dxScrollSetSelected(mapscroll, 0)
			else
				triggerServerEvent("panel:onPlayerRequestMapInfo", localPlayer, text)
				dxScrollSetSelected(mapscroll, scrollpos)
			end
		elseif id == clanscroll then
			if not text then 
				dxScrollSetSelected(clanscroll, 0)
				dxScrollSetSelected(clanmembersscroll, 0)
				dxTextSetText(clanname, "-")
				dxTextSetText(clandescription, "-")
				dxTextSetText(clanstats, "-\n-\n-\n-\n-")
				dxScrollSetTable(clanmembersscroll, {})
				dxSetButtonVisible(manageclanbutton, false)
				dxSetButtonVisible(leaveclanbutton, false)
				dxSetButtonVisible(removememberbutton, false)
			else
				dxScrollSetSelected(clanscroll, scrollpos)
				dxScrollSetSelected(clanmembersscroll, 0)
				triggerServerEvent("panel:onPlayerRequestClanInfo", localPlayer, text:gsub("#%x%x%x%x%x%x", ""))
			end
		elseif id == clanmembersscroll then
			dxScrollSetSelected(clanmembersscroll, text and scrollpos or 0)
		elseif id == removememberbutton then
			local selected = dxScrollGetSelected(clanmembersscroll)
			if selected then
				triggerServerEvent("panel:onPlayerRequestRemoveMember", localPlayer, selected)
			else
				showNotificationToPlayer("Select a member first", "error")
			end
		elseif id == manageclanbutton then
			dxSetPanelVisible(panel, false)
			dxSetPanelVisible(manageclanpanel, true)
			dxSetTabSelected(manageclantab, true)
			triggerServerEvent("panel:onPlayerRequestClanInfoManage", localPlayer)
		elseif id == managecancelclanbutton then
			dxSetPanelVisible(manageclanpanel, false)
			dxSetPanelVisible(panel, true)
			dxSetTabSelected(clanstab, true)
		elseif id == manageconfirmclanbutton then
			if getPlayerMoney() < 250000 then
				showNotificationToPlayer("You don't have enough money", "error")
			else
				local name = dxGetEditText(manageclannameedit)
				local tag = dxGetEditText(manageclantagedit)
				local color = dxGetEditText(manageclancoloredit)
				local description = dxGetEditText(manageclandescriptionedit)
				if #name == 0 then
					showNotificationToPlayer("Please write a clan name", "error")
				elseif name == "none" then
					showNotificationToPlayer("Invalid team name", "error")
				elseif #tag == 0 then
					showNotificationToPlayer("Please write a clan tag", "error")
				elseif #color == 0 then
					showNotificationToPlayer("Please introduce a clan color", "error")
				elseif #description == 0 then
					showNotificationToPlayer("Please write a clan description", "error")
				else
					if not color:find("#%x%x%x%x%x%x") then
						showNotificationToPlayer("Invalid hex color", "error")
					else
						triggerServerEvent("panel:onPlayerRequestClanModify", localPlayer, name, tag, color, description)
						dxSetPanelVisible(manageclanpanel, false)
						dxSetPanelVisible(panel, true)
						dxSetTabSelected(clanstab, true)
						dxScrollSetSelected(clanscroll, 0)
						dxScrollSetSelected(clanmembersscroll, 0)
						dxTextSetText(clanname, "-")
						dxTextSetText(clandescription, "-")
						dxTextSetText(clanstats, "-\n-\n-\n-\n-")
						dxScrollSetTable(clanmembersscroll, {})
						-- Update clans
						triggerServerEvent("panel:onPlayerRequestServerClans", localPlayer)
					end
				end
			end
		elseif id == buymapbutton then
			if getPlayerMoney() < 2000 then
				showNotificationToPlayer("You don't have enough money", "error")
				return
			end
			local selected = dxScrollGetSelected(mapscroll)
			if selected then
				triggerServerEvent("panel:onPlayerRequestBuyMap", localPlayer, selected)
			else
				showNotificationToPlayer("Select a map first", "error")
			end
		-- Toggles
		elseif id == fadecars then
			setCarFadeState(bool)
			panelsettings.fadecars = bool
		elseif id == hideplayers then
			setCarHideState(bool)
			panelsettings.hideplayers = bool
		elseif id == watershader then
			setWaterShaderStatus(bool)
			panelsettings.watershader = bool
		elseif id == bloomshader then
			switchBloom(bool)
			panelsettings.bloomshader = bool
		elseif id == hdrshader then
			switchContrast(bool)
			panelsettings.hdrshader = bool
		elseif id == blur then
			setBlurLevel(bool and 36 or 0)
			panelsettings.blur = bool
		elseif id == decoration then
			setHideObjectsState(bool)
			panelsettings.decoration = bool
		elseif id == raceui then
			setRaceUIEnabled(bool)
			panelsettings.raceui = bool
		elseif id == skidmarks then
			setSkidmarkRainbow(bool)
			panelsettings.skidmarks = bool
		elseif id == mapmusic then
			panelsettings.mapmusic = bool
			panelsettings.radio = not bool
			dxToggleSetState(radio, not bool)
			updateRadio()
		elseif id == radio then
			panelsettings.radio = bool
			panelsettings.mapmusic = not bool
			dxToggleSetState(mapmusic, not bool)
			updateRadio()
		elseif id == shaders then
			setDVOEnabled(not bool)
			panelsettings.shaders = bool
		-- Browser buttons
		elseif id == youtube then
			loadBrowserURL(browser, "http://www.youtube.com")
		elseif id == google then
			loadBrowserURL(browser, "http://www.m.google.com")
		-- Radio
		elseif id == radiobutton then
			if not songrequested then
				local videourl = getBrowserURL(radiobrowser)
				local _, count = videourl:find("v=")
				if not count then
					showNotificationToPlayer("Please select a valid song", "error")
					return
				end
				local videoid = videourl:sub(count + 1, count + 1 + 11)
				triggerServerEvent("radio:onPlayerRequestSong", localPlayer, videoid)
				songrequested = true
				setTimer(function() songrequested = false end, 1500, 1)
			end
		-- Create clan
		elseif id == createclanbutton then
			if getElementData(localPlayer, "stats").player.clan ~= "none" then
				showNotificationToPlayer("You are already on a clan", "error")
				return
			end
			if getPlayerMoney() < 1500000 then
				showNotificationToPlayer("You don't have enough money", "error")
				return
			end
			dxSetPanelVisible(panel, false)
			dxSetPanelVisible(createclanpanel, true)
			dxSetTabSelected(createclanstab, true)
			dxSetEditText(clancoloredit, "#FFFF00")
		elseif id == cancelclanbutton then
			dxSetPanelVisible(createclanpanel, false)
			dxSetPanelVisible(panel, true)
			dxSetTabSelected(clanstab, true)
		elseif id == confirmclanbutton then
			if getPlayerMoney() >= 1500000 then
				local name = dxGetEditText(clannameedit)
				local tag = dxGetEditText(clantagedit)
				local color = dxGetEditText(clancoloredit)
				local clandescription = dxGetEditText(clandescriptionedit)
				if #name == 0 then
					showNotificationToPlayer("Please write a clan name", "error")
				elseif name == "none" then
					showNotificationToPlayer("Invalid team name", "error")
				elseif #tag == 0 then
					showNotificationToPlayer("Please write a clan tag", "error")
				elseif #color == 0 then
					showNotificationToPlayer("Please introduce a clan color", "error")
				elseif #clandescription == 0 then
					showNotificationToPlayer("Please write a clan description", "error")
				else
					if not color:find("#%x%x%x%x%x%x") then
						showNotificationToPlayer("Invalid hex color", "error")
					else
						triggerServerEvent("panel:onPlayerRequestCreateClan", localPlayer, name, tag, color, clandescription)
						setTimer(
							function()
								if getElementData(localPlayer, "stats").player.clan ~= "none" then
									dxSetPanelVisible(createclanpanel, false)
									dxSetPanelVisible(panel, true)
									dxSetTabSelected(clanstab, true)
									-- Update clans
									triggerServerEvent("panel:onPlayerRequestServerClans", localPlayer)
								end
							end
						, 1000, 1)
					end
				end
			else
				showNotificationToPlayer("Not enough money", "error")
			end
		-- Leave clan
		elseif id == leaveclanbutton then
			triggerServerEvent("panel:onPlayerRequestClanLeave", localPlayer)
			--
			dxScrollSetSelected(clanscroll, 0)
			dxTextSetText(clanname, "-")
			dxTextSetText(clandescription, "-")
			dxTextSetText(clanstats, "-\n-\n-\n-\n-")
			dxScrollSetTable(clanmembersscroll, {})
			dxSetButtonVisible(manageclanbutton, false)
			dxSetButtonVisible(leaveclanbutton, false)
			dxSetButtonVisible(removememberbutton, false)
		end
	end
)

addEventHandler("dx:onPlayerClickTab", root,
	function(tabid)
		if tabid == mapstab then
			local tp = getElementData(localPlayer, "room_id")
			if tp:find("Training_S_", 1, true) then
				dxScrollSetTable(mapscroll, { "To change map press F1" })
			else
				tp = tp:gsub(" A", ""):gsub(" B", "")
				dxScrollSetTable(mapscroll, getElementData(root, tp.. ".maps"))
			end
			dxScrollSetSelected(mapscroll, 0)
			dxSetEditText(searchmapedit, "")
			focusBrowser()
		elseif tabid == statstab then
			updatePanelPlayers()
			updateStatsForSelectedPlayer(localPlayer)
			dxSetEditText(searchplayeredit, "")
			focusBrowser()
		elseif tabid == browsertab then
			focusBrowser(browser)
			if not browserpageloaded then
				loadBrowserURL(browser, "http://www.youtube.com")
				browserpageloaded = true
			end
		elseif tabid == radiotab then
			focusBrowser(radiobrowser)
			loadBrowserURL(radiobrowser, "http://www.youtube.com")
		elseif tabid == rankingstab then
			if not gRankings then
				triggerServerEvent("panel:onPlayerRequestRankings", localPlayer)
			end
		elseif tabid == clanstab then
			triggerServerEvent("panel:onPlayerRequestServerClans", localPlayer)
		end
	end
)

addEventHandler("dx:onPlayerType", root,
	function(id, text)
		if id == searchplayeredit then
			local tbl = {}
			local players = getElementsByType("player")
			for i = 1, #players do
				if string.find(getPlayerNameNoColor(players[i]):lower(), text:lower()) then
					tbl[#tbl + 1] = getPlayerName(players[i])
				end
			end
			dxScrollSetTable(playerscroll, tbl)
		elseif id == searchmapedit then
			local tp = getElementData(localPlayer, "room_id")
			local tbl = {}
			if tp:find("Training_S_", 1, true) then
				tbl[1] = "To change map press F1"
			else
				tp = tp:gsub(" A", ""):gsub(" B", "")
				local maps = getElementData(root, tp.. ".maps")
				for i = 1, #maps do
					if string.find(maps[i]:lower(), text:lower()) then
						tbl[#tbl + 1] = maps[i]
					end
				end
			end
			dxScrollSetTable(mapscroll, tbl)
		elseif id == searchclanedit then
			local tbl = {}
			for clanname, color in pairs(gTeams) do
				if clanname:lower():find(text:lower()) then
					table.insert(tbl, color.. "" ..clanname)
				end
			end
			dxScrollSetTable(clanscroll, tbl)
		end
	end
)

addEventHandler("onClientGUIComboBoxAccepted", root,
	function(combobox)
		if combobox == rankingcombobox then
			local item = guiComboBoxGetSelected(combobox)
			local text = tostring(guiComboBoxGetItemText(combobox, item))
			if text == "Money & points" then
				dxTextSetText(rankinglabel1, "#ffa500Most money")
				dxTextSetText(rankinglabel2, "#ffa500Most points")
				updateRankings(1)
			elseif text == "Online & time played" then
				dxTextSetText(rankinglabel1, "#ffa500Most online")
				dxTextSetText(rankinglabel2, "#ffa500Time played")
				updateRankings(2)
			elseif text == "Spins & flips" then
				dxTextSetText(rankinglabel1, "#ffa500Won flips")
				dxTextSetText(rankinglabel2, "#ffa500Won spins")
				updateRankings(3)
			elseif text == "Hunters & toptimes" then
				dxTextSetText(rankinglabel1, "#ffa500Most hunters")
				dxTextSetText(rankinglabel2, "#ffa500Most toptimes #1")
				updateRankings(4)
			elseif text == "Wins & win ratio" then
				dxTextSetText(rankinglabel1, "#ffa500Most wins")
				dxTextSetText(rankinglabel2, "#ffa500Best win ratio")
				updateRankings(5)
			elseif text == "Maps played & deaths" then
				dxTextSetText(rankinglabel1, "#ffa500Maps played")
				dxTextSetText(rankinglabel2, "#ffa500Most deaths")
				updateRankings(6)
			elseif text == "Lotteries won & profit" then
				dxTextSetText(rankinglabel1, "#ffa500Lotteries won")
				dxTextSetText(rankinglabel2, "#ffa500Lotteries profit")
				updateRankings(7)
			elseif text == "Map likes & dislikes" then
				dxTextSetText(rankinglabel1, "#ffa500Most liked")
				dxTextSetText(rankinglabel2, "#ffa500Most disliked")
				updateRankings(8)
			elseif text == "Top maps & shooter kills" then
				dxTextSetText(rankinglabel1, "#ffa500Most played maps")
				dxTextSetText(rankinglabel2, "#ffa500Most shooter kills")
				updateRankings(9)
			end
		end
	end
)

addEventHandler("panel:onReceiveRankings", root,
	function(data)
		gRankings = data and data or {}
		updateRankings(1)
	end
)

addEventHandler("panel:onReceiveClanInfo", root,
	function(data, accountowner, owner, members)
		dxTextSetText(clanname, data.color.. "" ..data.name.. "\n" ..data.tag)
		dxTextSetText(clandescription, data.description)
		dxTextSetText(clanstats, "Owner is " ..data.color.. "" ..owner.. "\n#ffffffCreated on " ..data.date.. "\n" ..#members.. " members\n" ..data.points.. " points\n$" ..data.cash.. " in cash")
		dxScrollSetTable(clanmembersscroll, members)
		local pStats = getElementData(localPlayer, "stats")
		if accountowner == pStats.account then
			dxSetButtonVisible(manageclanbutton, true)
			dxSetButtonVisible(removememberbutton, true)
		elseif accountowner ~= pStats.account then
			dxSetButtonVisible(manageclanbutton, false)
			dxSetButtonVisible(removememberbutton, false)
		end
		if pStats.player.clan == data.name and accountowner ~= pStats.account then
			dxSetButtonVisible(leaveclanbutton, true)
		elseif pStats.player.clan ~= data.name then
			dxSetButtonVisible(leaveclanbutton, false)
		end
	end
)

addEventHandler("panel:onReceiveServerClans", root,
	function(teams)
		gTeams = {}
		local tbl = {}
		for clanname in pairs(teams) do
			local color = RGBToHex(getTeamColor(teams[clanname]))
			tbl[#tbl + 1] = color.. "" ..clanname
			gTeams[clanname] = color
		end
		dxScrollSetTable(clanscroll, tbl)
	end
)

addEventHandler("panel:onReceiveClanInfoManage", root,
	function(data, clanname)
		dxSetEditText(manageclannameedit, clanname)
		dxSetEditText(manageclantagedit, data.tag)
		dxSetEditText(manageclancoloredit, data.color)
		dxSetEditText(manageclandescriptionedit, data.description)
	end
)

function updateRankings(tp)
	local tbl = {}
	if tp == 1 then
		-- Money
		tbl = {}
		for i = 1, #gRankings[tp].money do
			table.insert(tbl, i.. ": " ..gRankings[tp].money[i].name.. " #ffffff- $" ..gRankings[tp].money[i].money)
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Points
		tbl = {}
		for i = 1, #gRankings[tp].points do
			table.insert(tbl, i.. ": " ..gRankings[tp].points[i].name.. " #ffffff- " ..gRankings[tp].points[i].points.. " points")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 2 then
		-- Most online
		tbl = {}
		for i = 1, #gRankings[tp].mosttimeplayed do
			local days, hours, minutes = disp_time(gRankings[tp].mosttimeplayed[i].mosttimeplayed * 60)
			table.insert(tbl, i.. ": " ..gRankings[tp].mosttimeplayed[i].name.. " #ffffff- " ..hours.. " hour(s) and " ..minutes.. " minute(s)")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Time played
		tbl = {}
		for i = 1, #gRankings[tp].timeplayed do
			local days, hours, minutes = disp_time(gRankings[tp].timeplayed[i].timeplayed * 60)
			table.insert(tbl, i.. ": " ..gRankings[tp].timeplayed[i].name.. " #ffffff- " ..days.. " day(s), " ..hours.. " hour(s) and " ..minutes.. " minute(s)")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 3 then
		-- Flips
		tbl = {}
		for i = 1, #gRankings[tp].flips do
			table.insert(tbl, i.. ": " ..gRankings[tp].flips[i].name.. " #ffffff- " ..gRankings[tp].flips[i].flipswon.. " wins")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Spins
		tbl = {}
		for i = 1, #gRankings[tp].spins do
			table.insert(tbl, i.. ": " ..gRankings[tp].spins[i].name.. " #ffffff- " ..gRankings[tp].spins[i].spinswon.. " wins")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 4 then
		-- Hunters
		tbl = {}
		for i = 1, #gRankings[tp].hunters do
			table.insert(tbl, i.. ": " ..gRankings[tp].hunters[i].name.. " #ffffff- " ..gRankings[tp].hunters[i].hunters.. " hunters reached")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Toptimes
		tbl = {}
		for i = 1, #gRankings[tp].topone do
			table.insert(tbl, i.. ": " ..gRankings[tp].topone[i].name.. " #ffffff- " ..gRankings[tp].topone[i].topone.. " #1 toptimes")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 5 then
		-- Wins
		tbl = {}
		for i = 1, #gRankings[tp].wins do
			table.insert(tbl, i.. ": " ..gRankings[tp].wins[i].name.. " #ffffff- " ..gRankings[tp].wins[i].wins.. " wins")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Win ratio
		tbl = {}
		for i = 1, #gRankings[tp].winratio do
			table.insert(tbl, i.. ": " ..gRankings[tp].winratio[i].name.. " #ffffff- " ..gRankings[tp].winratio[i].winratio.. "% win ratio")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 6 then
		-- Maps played
		tbl = {}
		for i = 1, #gRankings[tp].mapsplayed do
			table.insert(tbl, i.. ": " ..gRankings[tp].mapsplayed[i].name.. " #ffffff- " ..gRankings[tp].mapsplayed[i].mapsplayed.. " maps played")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Deaths
		tbl = {}
		for i = 1, #gRankings[tp].deaths do
			table.insert(tbl, i.. ": " ..gRankings[tp].deaths[i].name.. " #ffffff- " ..gRankings[tp].deaths[i].deaths.. " deaths")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 7 then
		-- Lotteries won
		tbl = {}
		for i = 1, #gRankings[tp].lotterieswon do
			table.insert(tbl, i.. ": " ..gRankings[tp].lotterieswon[i].name.. " #ffffff- " ..gRankings[tp].lotterieswon[i].lotterieswon.. " lotteries won")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Lotteries profit
		tbl = {}
		for i = 1, #gRankings[tp].lotteriesprofit do
			table.insert(tbl, i.. ": " ..gRankings[tp].lotteriesprofit[i].name.. " #ffffff- +$" ..gRankings[tp].lotteriesprofit[i].lotteriesprofit.. " lotteries profit")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 8 then
		-- Map likes
		tbl = {}
		for i = 1, #gRankings[tp].maplikes do
			table.insert(tbl, i.. ": " ..(gRankings[tp].maplikes[i].mapname or "?").. " #ffffff- " ..gRankings[tp].maplikes[i].likes.. " likes")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Map dislikes
		tbl = {}
		for i = 1, #gRankings[tp].mapdislikes do
			table.insert(tbl, i.. ": " ..(gRankings[tp].mapdislikes[i].mapname or "?").. " #ffffff- " ..gRankings[tp].mapdislikes[i].dislikes.. " dislikes")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	elseif tp == 9 then
		-- Top played maps
		tbl = {}
		for i = 1, #gRankings[tp].topmapsplayed do
			table.insert(tbl, i.. ": " ..(gRankings[tp].topmapsplayed[i].mapname or "?").. " #ffffff- " ..gRankings[tp].topmapsplayed[i].timesplayed.. " times")
		end
		dxScrollSetTable(rankingscroll1, tbl)
		-- Top shooter kills
		tbl = {}
		for i = 1, #gRankings[tp].topshooterkills do
			table.insert(tbl, i.. ": " ..gRankings[tp].topshooterkills[i].name.. " #ffffff- " ..gRankings[tp].topshooterkills[i].totalkillsshooter.. " kills")
		end
		dxScrollSetTable(rankingscroll2, tbl)
	end
end

function toggleUserPanel()
	if dxIsPanelVisible(createclanpanel) then return end
	local tp = getElementData(localPlayer, "room_id")
	if tp == "Lobby" or tp == "Joined" then return end
	dxSetPanelVisible(panel, not dxIsPanelVisible(panel))
	if dxIsPanelVisible(panel) then
		dxSetTabSelected(statstab, true)
		updatePanelPlayers()
		updateStatsForSelectedPlayer(localPlayer)
		dxTextSetText(mapinfolabel, "-\n-\n-\n-")
	else
		saveSettings()
		focusBrowser()
		dxSetTabSelected(nil)
	--	loadBrowserURL(browser, "http://www.youtube.com")
		loadBrowserURL(radiobrowser, "http://www.youtube.com")
		--
		dxScrollSetSelected(clanscroll, 0)
		dxScrollSetSelected(clanmembersscroll, 0)
		dxTextSetText(clanname, "-")
		dxTextSetText(clandescription, "-")
		dxTextSetText(clanstats, "-\n-\n-\n-\n-")
		dxScrollSetTable(clanmembersscroll, {})
		dxSetButtonVisible(manageclanbutton, false)
		dxSetButtonVisible(leaveclanbutton, false)
	end
end

function isUserPanelVisible()
	return dxIsPanelVisible(panel)
end

function updateStatsForSelectedPlayer(target)
	local pStats = getElementData(target, "stats")
	if pStats then
		local onlinetime = getElementData(target, "onlinetime")
		local hour, minute = onlinetime:match("(%d+):(%d+)")
		hour = tonumber(hour)
		minute = tonumber(minute)
		--
		local tp = getElementData(target, "room_id")
		local hourstr = "Online for " ..(hour == 0 and minute .." minute(s)" or hour.. " hour(s) and " ..minute.. " minute(s)")
		local playingat = "Currently playing on #808080" ..(tp:find("Training_S_", 1, true) and "Training" or tp).. "#ffffff"
		local memberstr = "Member since " ..pStats.date
		local loginstr = "Logged in " ..pStats.player.logins.. " times"
		local days, hours, minutes = disp_time(pStats.player.timeplayed * 60)
		local timeplayed
		if days > 0 then
			timeplayed = days.. " day(s), " ..hours.. " hour(s) and " ..minutes.. " minutes(s) played on server"
		elseif hours > 0 then
			timeplayed = hours.. " hour(s) and " ..minutes.. " minutes(s) played on server"
		else
			timeplayed = minutes.. " minutes(s) played on server"
		end
		--
		local cashstr = "$" ..pStats.player.money.. " in cash"
		local pointsstr = pStats.player.points.. " points"
		local toptimesstr = pStats.player.topone.. " [#1] toptimes made"
		local huntersstr = pStats.player.hunters.. " hunters reached"
		-- DM
		local mapsplayeddm = pStats.player.mapsplayeddm.. " maps played"
		local winsdm = pStats.player.winsdm.. " wins"
		local deathsdm = pStats.player.deathsdm.. " deaths"
		local winratiodm = math.round((pStats.player.winsdm / pStats.player.mapsplayeddm) * 100, 2).. "% win ratio"
		-- ODM
		local mapsplayedodm = pStats.player.mapsplayedodm.. " maps played"
		local winsodm = pStats.player.winsodm.. " wins"
		local deathsodm = pStats.player.deathsodm.. " deaths"
		local winratioodm = math.round((pStats.player.winsodm / pStats.player.mapsplayedodm) * 100, 2).. "% win ratio"
		-- Shooter
		local mapsplayedshooter = pStats.player.mapsplayedshooter.. " maps played"
		local winsshooter = pStats.player.winsshooter.. " wins"
		local deathsshooter = pStats.player.deathsshooter.. " deaths"
		local winratioshooter = math.round((pStats.player.winsshooter / pStats.player.mapsplayedshooter) * 100, 2).. "% win ratio"
		local totalkillsshooter = pStats.player.totalkillsshooter.. " shooter kills"
		-- Race
		local mapsplayedrace = pStats.player.mapsplayedrace.. " maps played"
		local winsrace = pStats.player.winsrace.. " wins"
		local deathsrace = pStats.player.deathsrace.. " deaths"
		local winratiorace = math.round((pStats.player.winsrace / pStats.player.mapsplayedrace) * 100, 2).. "% win ratio"
		-- OJ
		local mapsplayedoj = pStats.player.mapsplayedoj.. " maps played"
		local winsoj = pStats.player.winsoj.. " wins"
		local deathsoj = pStats.player.deathsoj.. " deaths"
		local winratiooj = math.round((pStats.player.winsoj / pStats.player.mapsplayedoj) * 100, 2).. "% win ratio"
		-- Training
		local days, hours, minutes = disp_time(pStats.player.timespenttraining / 1000)
		local trainingmaps = pStats.player.mapstrained.. " maps trained"
		local trainingtime = ""
		local traininghunters = pStats.player.huntersontraining.. " hunters got on training"
		-- Destruction Derby
		local mapsplayeddd = pStats.player.mapsplayeddd.. " maps played"
		local winsdd = pStats.player.winsdd.. " wins"
		local deathsdd = pStats.player.deathsdd.. " deaths"
		local winratiodd = math.round((pStats.player.winsdd / pStats.player.mapsplayeddd) * 100, 2).. "% win ratio"
		-- Trials
		local mapsplayedtrials = pStats.player.mapsplayedtrials.. " maps played"
		local winstrials = pStats.player.winstrials.. " wins"
		local deathstrials = pStats.player.deathstrials.. " deaths"
		local winratiotrials = math.round((pStats.player.winstrials / pStats.player.mapsplayedtrials) * 100, 2).. "% win ratio"
		if days > 0 then
			trainingtime = days.. " day(s), " ..hours.. " hour(s) and " ..minutes.. " minute(s) training" 
		elseif hours == 0 then
			trainingtime = minutes.. " minute(s) training" 
		else
			trainingtime = hours.. " hour(s) and " ..minutes.. " minute(s) training" 
		end
		-- Lotterie
		local lotteriesplayed = pStats.player.lotteriesplayed.. " lotteries played"
		local lotterieswon = pStats.player.lotterieswon.. " lotteries won"
		local lotteriesprofit = "+$" ..pStats.player.lotteriesprofit.. " lottery profit"
		local lotterieswinratio = math.round((pStats.player.lotterieswon / pStats.player.lotteriesplayed) * 100, 2).. "% lottery win ratio"
		-- Sping & flip
		local flipswon = "Won " ..pStats.player.flipswon.. " flips"
		local spinswon = "Won " ..pStats.player.spinswon.. " spins"
		dxTextSetText(playernamelabel, getPlayerName(target))
		dxTextSetText(statslabel1, memberstr.. "\n" ..loginstr.. "\n\n" ..timeplayed.. "\n" ..hourstr.. "\n" ..playingat.. "\n\n" ..cashstr.. "\n" ..pointsstr.. "\n" ..toptimesstr.. "\n" ..huntersstr.. "\n\n" ..lotteriesplayed.. "\n" ..lotterieswon.. "\n" ..lotteriesprofit.. "\n" ..lotterieswinratio.. "\n\n" ..flipswon.. "\n" ..spinswon)
		-- DM
		dxTextSetText(roomsdmtatslabel, "#ffa500Deathmatch#ffffff\n" ..mapsplayeddm.. "\n" ..winsdm.. "\n" ..deathsdm.. "\n" ..winratiodm)
		-- ODM
		dxTextSetText(roomsodmtatslabel, "#ffa500Oldschool#ffffff\n" ..mapsplayedodm.. "\n" ..winsodm.. "\n" ..deathsodm.. "\n" ..winratioodm)
		-- Shooter
		dxTextSetText(roomsshootertatslabel, "#ffa500Shooter#ffffff\n" ..mapsplayedshooter.. "\n" ..winsshooter.. "\n" ..deathsshooter.. "\n" ..winratioshooter.. "\n" ..totalkillsshooter)
		-- Race
		dxTextSetText(roomsracetatslabel, "#ffa500Race#ffffff\n" ..mapsplayedrace.. "\n" ..winsrace.. "\n" ..deathsrace.. "\n" ..winratiorace)
		-- OJ
		dxTextSetText(roomsojtatslabel, "#ffa500OJ#ffffff\n" ..mapsplayedoj.. "\n" ..winsoj.. "\n" ..deathsoj.. "\n" ..winratiooj)
		-- Training
		dxTextSetText(roomstrainingtatslabel, "#ffa500Training#ffffff\n" ..trainingmaps.. "\n" ..trainingtime.. "\n" ..traininghunters)
		-- Destruction Derby
		dxTextSetText(roomsddtatslabel, "#ffa500Destruction Derby#ffffff\n" ..mapsplayeddd.. "\n" ..winsdd.. "\n" ..deathsdd.. "\n" ..winratiodd)
		-- Trials
		dxTextSetText(roomstrialstatslabel, "#ffa500Trials#ffffff\n" ..mapsplayedtrials.. "\n" ..winstrials.. "\n" ..deathstrials.. "\n" ..winratiotrials)
	else
		dxTextSetText(playernamelabel, "Player not logged")
		dxTextSetText(statslabel1, "-")
		dxTextSetText(roomsdmtatslabel, "-")
		dxTextSetText(roomsodmtatslabel, "-")
	end
end

function math.round(num, idp)
	if idp and idp > 0 then
		local mult = 10^idp
		local value = math.floor(num * mult + 0.5) / mult
		return tostring(value):find("nan") and 0 or value
	end
	return math.floor(num + 0.5)
end

function updatePanelPlayers()
	local tbl = {}
	local players = getElementsByType("player")
	for i = 1, #players do
		tbl[i] = getPlayerName(players[i])
	end
	dxScrollSetTable(playerscroll, tbl)
end

function getPlayerNameNoColor(source)
	return getPlayerName(source):gsub("#%x%x%x%x%x%x", "")
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

function loadSettings()
	panelsettings = { fadecars = true, carhide = false, watershader = true, bloomshader = false, hdrshader = false, blur = false, decoration = true, raceui = true, skidmarks = true, radio = false, mapmusic = true }
	if not fileExists("/files/data/" ..panel_config_file) then
		local file = fileCreate("/files/data/" ..panel_config_file)
		if file then
			fileWrite(file, toJSON(panelsettings))
			fileClose(file)
		end
	else
		local file = fileOpen("/files/data/" ..panel_config_file)
		if file then
			local size = fileGetSize(file)
			if size > 5 then
				panelsettings = fromJSON(fileRead(file, size))
			end
			fileClose(file)
		end
	end
	setCarFadeState(panelsettings.fadecars)
	dxToggleSetState(fadecars, panelsettings.fadecars)
	--
	setCarHideState(panelsettings.carhide)
	dxToggleSetState(hideplayers, panelsettings.carhide)
	--
	setWaterShaderStatus(panelsettings.watershader)	
	dxToggleSetState(watershader, panelsettings.watershader)
	--
	switchBloom(panelsettings.bloomshader)
	dxToggleSetState(bloomshader, panelsettings.bloomshader)
	--
	switchContrast(panelsettings.hdrshader)
	dxToggleSetState(hdrshader, panelsettings.hdrshader)
	--
	setBlurLevel(panelsettings.blur and 36 or 0)
	dxToggleSetState(blur, panelsettings.blur)
	--
--	setHideObjectsState(panelsettings.decoration)
	dxToggleSetState(decoration, panelsettings.decoration)
	--
	setRaceUIEnabled(panelsettings.raceui)
	dxToggleSetState(raceui, panelsettings.raceui)
	--
	setSkidmarkRainbow(panelsettings.skidmarks)
	dxToggleSetState(skidmarks, panelsettings.skidmarks)
	--
	dxToggleSetState(radio, panelsettings.radio)
	dxToggleSetState(mapmusic, panelsettings.mapmusic)
	if panelsettings.mapmusic then
		setMapSongEnabled()
	else
		setRadioEnabled()
	end
	--
	dxToggleSetState(shaders, panelsettings.shaders)
	setDVOEnabled(not panelsettings.shaders)
end

function updateRadio()
	if panelsettings.mapmusic then
		setMapSongEnabled()
	elseif panelsettings.radio then
		setRadioEnabled()
	end
end

function saveSettings()
	if fileExists("/files/data/" ..panel_config_file) then
		fileDelete("/files/data/" ..panel_config_file)
	end
	local file = fileCreate("/files/data/" ..panel_config_file)
	fileWrite(file, toJSON(panelsettings))
	fileClose(file)
end

function disp_time(time) -- uses seconds
  local days = math.floor(time/86400)
  local remaining = time % 86400
  local hours = math.floor(remaining/3600)
  remaining = remaining % 3600
  local minutes = math.floor(remaining/60)
  remaining = remaining % 60
  local seconds = remaining
  if (hours < 10) then
    hours = "0" .. tostring(hours)
  end
  if (minutes < 10) then
    minutes = "0" .. tostring(minutes)
  end
  if (seconds < 10) then
    seconds = "0" .. tostring(seconds)
  end
  return tonumber(days), tonumber(hours), tonumber(minutes)
end