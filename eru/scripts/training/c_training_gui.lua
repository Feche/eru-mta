local sMaps = {}

local CHANGEMAP_KEY = "F2"

local alpha = 200
local swidth, sheight = 450, 600
local tick = 0

addEvent("onPlayerClickGui")
addEvent("onClientCharacterEdit")

addEvent("lobby:onPlayerClickTraining")

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		sMaps = getElementData(root, "dm.odm.maps")
		-- Solo window
		createWindowsGui(swidth, sheight, alpha, "Select the map", "training.solo")
		createWindowsText(0, 50, swidth, sheight, "Double-click on the map that you wish to train.", "default", 1, "center", "top", "training.solo")
		createScrollGui((swidth / 2) - ((swidth - 50) / 2), 70, swidth - 50, sheight - 100, "training.solo.scroll", "training.solo", 1)
		scrollGuiAddTable("training.solo.scroll", sMaps, 17)
		createWindowsText(0, 510, swidth, sheight, "Search:", "default", 1, "center", "top", "training.solo")
		createWindowsEdit(swidth / 2 - 110, 530, 220, 22, 25, "training.solo.search", "training.solo", "training.solo.scroll")
		createWindowsButton(swidth / 2 - 50, 560, 100, 30, "Go back", "default-bold", 1, "center", "center", "training.solo", "training.solo.back")
		-- Solo window
		createWindowsGui(swidth, sheight, alpha, "Select the map", "training.solo2")
		createWindowsText(0, 50, swidth, sheight, "Double-click on the map that you wish to train.", "default", 1, "center", "top", "training.solo2")
		createScrollGui((swidth / 2) - ((swidth - 50) / 2), 70, swidth - 50, sheight - 100, "training.solo.scroll2", "training.solo2", 1)
		scrollGuiAddTable("training.solo.scroll2", sMaps, 17)
		createWindowsText(0, 512, swidth, sheight, "Search:", "default", 1, "center", "top", "training.solo2")
		createWindowsEdit(swidth / 2 - 110, 530, 220, 22, 25, "training.solo.search2", "training.solo2", "training.solo.scroll2")
		createWindowsButton(swidth / 2 - 50, 560, 100, 30, "Close", "default-bold", 1, "center", "center", "training.solo2", "training.solo.back2")
		bindKey("F2", "down", openMapChange)
	end
)

addEventHandler("lobby:onPlayerClickTraining", root,
	function()
		stopLobby()
		setElementData(localPlayer, "room_id", "Training")
		setElementData(localPlayer, "state", "selecting")
		setTimer(setGuiVisible, 200, 1, "training.solo", true) -- Avoid double click bug
	end
)

addEventHandler("onPlayerClickGui", root,
	function(tp, id, text)
		if tp == "button" then
			if id == "training.solo.back" then
				setGuiVisible("training.solo", false)
				setTimer(startLobby, 200, 1)
				setElementData(localPlayer, "state", "lobby")
				setElementData(localPlayer, "room_id", "Lobby")
			elseif id == "training.solo.back2" then
				setGuiVisible("training.solo2", false)
			end
		elseif tp == "scroll" then
			if id == "training.solo.scroll" then
				local mapname = text
				setTimer(triggerServerEvent, 1000, 1, "training:onPlayerRequestSolo", localPlayer, mapname)
				showNotificationToPlayer("Loading map " ..mapname, "info")
				setGuiVisible("training.solo", false)
			elseif id == "training.solo.scroll2" then -- Player changing map
				local mapname = text
				setTimer(
					function()
						triggerServerEvent("training:onPlayerRequestSolo", localPlayer, mapname)
						setElementAlpha(pVeh, 255)
					end
				, 2000, 1)
				setGuiVisible("training.solo2", false)
				showNotificationToPlayer("Loading map " ..mapname, "info")
				setElementFrozen(pVeh, true)
				setElementAlpha(pVeh, 150)
			end
		end
	end
)

addEventHandler("onClientCharacterEdit", root,
	function(editid, text)
		if editid == "training.solo.search" then
			local search = {}
			for i = 1, #sMaps do
				if sMaps[i] then
					if string.find(sMaps[i]:lower(), text:lower(), 1, true) then
						table.insert(search, sMaps[i])
					end
				end
			end
			if #search == 0 then
				search[1] = "- Nothing found."
			end
			scrollGuiAddTable("training.solo.scroll", search, 17)
		elseif editid == "training.solo.search2" then
			local search = {}
			for i = 1, #sMaps do
				if sMaps[i] then
					if string.find(sMaps[i]:lower(), text:lower(), 1, true) then
						table.insert(search, sMaps[i])
					end
				end
			end
			if #search == 0 then
				search[1] = "- Nothing found."
			end
			scrollGuiAddTable("training.solo.scroll2", search, 17)
		end
	end	
)

function openMapChange()
	local tp = getElementData(localPlayer, "room_id")
	if tp:find("Training_S_", 1, true) then
		local ms = getTickCount() - tick
		if ms <= 10000 then
			ms = math.floor((10000 - ms) / 1000) + 1
			showNotificationToPlayer("Please wait " ..ms.. " " ..(ms == 1 and "second." or "seconds."), "error")
		else
			setGuiVisible("training.solo2", not isGuiVisible("training.solo2"))
			tick = getTickCount()
		end
	end
end