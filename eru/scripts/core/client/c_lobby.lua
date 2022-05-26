local ROW_CARDS = 5 -- 4 cards per row
local WIDTH = (280 / 1920) * sx
local HEIGHT = (280 / 1080) * sy
local OFFST = 10 -- Space between lobby 'cards'
local TOTAL_WIDTH = 0
local TOTAL_HEIGTH = 0
local LOBBY_PROGRESS = 0
local LOBBY_TITLE = "Select the gamemode you want to play"
local SHOW_LOBBY = true
local MAX_PLAYERS = 0
local currtimer = nil

local currplayers = 0
local lobbieplayers = 0
local gamemodePlayers = 
{
	["Deathmatch A"] = 0,
	["Deathmatch B"] = 0,
	["Oldschool A"] = 0,
	["Oldschool B"] = 0,
	["Destruction Derby A"] = 0,
	["Destruction Derby B"] = 0,
	["Training"] = 0,
	["Race"] = 0,
	["Trials"] = 0,
	["Shooter"] = 0,
	["Hunter"] = 0,
	["OJ"] = 0,
	["Freeroam"] = 0
}

local backtoLobby = 
{
	progress1 = 0,
	progress2 = 0,
	progress3 = 0,
	progress3up = true,
	handler = false,
	show = false,
	sent = false,
	tick = 1
}

local MATRIXES = 
{
	{ 2136.8793945313, 1864.9450683594, 11.631510734558, 2048.4584960938, 1899.9764404297, 42.527572631836 },
	{ -359.00405883789, 1905.3551025391, 48.416938781738, -314.79840087891, 1816.1512451172, 57.826000213623 },
	{ 339.61099243164, -1994.8491210938, 21.861011505127, 402.66253662109, -2071.177734375, 7.7735285758972 }
}

local GROUP_IDX = 1
local CARD_IDX = 1
local cLobby = 
{
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {}
}

addEvent("lobby:kickPlayerToLobby", true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		createLobby("Deathmatch", 150, 200, "files/img/lobby/dm.png", false, { "Oldschool B", "Oldschool A", "Deathmatch B", "Deathmatch A" }, 32)
		createLobby("Destruction Derby", 150, 200, "files/img/lobby/olddm.png", false, { "Destruction Derby B", "Destruction Derby A" }, 32)
		createLobby("Training", 150, 200, "files/img/lobby/training.png", false)
		createLobby("Race", 150, 200, "files/img/lobby/race.png", false)
		createLobby("Shooter", 150, 200, "files/img/lobby/shooter.png", false, { "Shooter", "Hunter" }, 16)
		createLobby("OJ", 150, 200, "files/img/lobby/oj.png", false)
		createLobby("Trials", 150, 200, nil, true)
		createLobby("Freeroam", 150, 200, "files/img/lobby/freeroam.png", true)
		createLobby("Tune your ride", 150, 200, nil, false)
		MAX_PLAYERS = getElementData(root, "maxplayers") or "???"
		doPositionCalculation()
		bindKey("l", "both", backToLobby)
		bindKey("F1", "both", backToLobby)
	--	startLobby()
	end
)

function stopLobby()
	SHOW_LOBBY = false
	showCursor(false)
	showChat(true)
	backtoLobby.sent = false
	if isTimer(currtimer) then
		killTimer(currtimer)
	end
	guiSetInputMode("allow_binds")
end

function startLobby()
	addEventHandler("onClientRender", root, drawLobby)
	addEventHandler("onClientCursorMove", root, handleMouseLobby)
	addEventHandler("onClientClick", root, handleClickLobby)
	--
	setCameraTarget(localPlayer)
	local rand = math.random(1, #MATRIXES)
	setTimer(setCameraMatrix, 100, 1, unpack(MATRIXES[rand]))
	currentMatrix = MATRIXES[rand]
	showChat(false)
	setScreenBlurVisible(true)
	resetSkyGradient()
	resetWaterColor()
	setCloudsEnabled(false)
	setElementDimension(localPlayer, 0)
	SHOW_LOBBY = true
	updateLobbiePlayers()
	setTimer(fadeCamera, 200, 1, true) -- Avoid black screen when returning to lobby
	guiSetInputMode("no_binds")
	if not isTimer(currtimer) then
		currtimer = setTimer(updateLobbiePlayers, 1000, 0)
	end
	triggerServerEvent("lobby:onPlayerJoinLobby", localPlayer)
	triggerEvent("lobby:onPlayerJoinLobby", localPlayer)
	backtoLobby.tick = getTickCount()
	if isUserPanelVisible() then
		toggleUserPanel() -- Close user panel if he had it open
	end
	showCursor(true)
--	showChat(true)
end
addEventHandler("lobby:kickPlayerToLobby", root, startLobby)

function drawLobby()
	animateCameraWithCursor(unpack(currentMatrix))
	local progresslvl = 0.04
	if SHOW_LOBBY then
		LOBBY_PROGRESS = LOBBY_PROGRESS + progresslvl > 1 and 1 or LOBBY_PROGRESS + progresslvl
	else
		LOBBY_PROGRESS = LOBBY_PROGRESS - progresslvl < 0 and 0 or LOBBY_PROGRESS - progresslvl
		if LOBBY_PROGRESS == 0 then
			removeEventHandler("onClientRender", root, drawLobby)
			removeEventHandler("onClientCursorMove", root, handleMouseLobby)
			removeEventHandler("onClientClick", root, handleClickLobby)
			setScreenBlurVisible(false)
		end
	end
	setScreenBlurLevel(255 * LOBBY_PROGRESS)
	local cx, cy = getCursorPosition()
	cx = (cx or 0) * sx
	cy = (cy or 0) * sy
	local START_X = (sx / 2) - (TOTAL_WIDTH / 2)
	local START_Y = (sy / 2) - (TOTAL_HEIGTH / 2)
--	dxDrawRectangle(START_X + 5, START_Y, TOTAL_WIDTH - 10 + 1, TOTAL_HEIGTH - 10 + 1, tocolor(0, 0, 0, 150 * LOBBY_PROGRESS))
	--dxDrawLinedRectangle(START_X - 5, START_Y - 10, TOTAL_WIDTH + 10, TOTAL_HEIGTH + 10, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS))
	dxDrawText("Extreme Racers United", 0 + 2, 0 + 2, sx + 2, START_Y + 2, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS), 3, "roboto-bold", "center", "center")
	dxDrawText("Extreme Racers United", 0, 0, sx, START_Y, tocolor(128, 128, 128, 255 * LOBBY_PROGRESS), 3, "roboto-bold", "center", "center")
	dxDrawText("Select the gamemode you want to play:", 0 + 1, 0 + 1, sx + 1, START_Y + 70 + 1, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS), 1.8, "roboto-medium", "center", "center")
	dxDrawText("Select the gamemode you want to play:", 0, 0, sx, START_Y + 70, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), 1.8, "roboto-medium", "center", "center")
	local sz = #cLobby
	for i = 1, #cLobby do
		for c = 1, #cLobby[i] do
			local x = cLobby[i][c].x
			local y = cLobby[i][c].y
			if cLobby[i][c].hovered then
				cLobby[i][c].progress = cLobby[i][c].progress + 0.08 < 1 and cLobby[i][c].progress + 0.08 or 1
			else
				cLobby[i][c].progress = cLobby[i][c].progress - 0.08 > 0 and cLobby[i][c].progress - 0.08 or 0
			end
			local off = interpolateBetween(0, 0, 0, -20, 0, 0, cLobby[i][c].progress, "Linear")
			dxSetRenderTarget(cLobby[i][c].texture, true)
			if cLobby[i][c].imgsrc then
				local hh = scaledSize(30)
				if cLobby[i][c].children then
					local totalChildren = #cLobby[i][c].children
					for ii = 1, totalChildren do
						local cxx, cyy = 0, 0
						if cLobby[i][c].hovered then
							cxx, cyy = cx - x, cy - y
						end
						local ypos = HEIGHT - (ii * hh)
						if cxx >= 0 and cxx <= WIDTH and cyy >= ypos and cyy <= ypos + hh then
							cLobby[i][c].children[ii].progress = cLobby[i][c].children[ii].progress + 0.08 > 1 and 1 or cLobby[i][c].children[ii].progress + 0.08
						else
							cLobby[i][c].children[ii].progress = cLobby[i][c].children[ii].progress - 0.08 < 0 and 0 or cLobby[i][c].children[ii].progress - 0.08
						end
						local r, g, b = interpolateBetween(200, 200, 200, 255, 255, 255, cLobby[i][c].children[ii].progress, "Linear")
						dxDrawImage(0, ypos, WIDTH, hh, "files/img/lobby/lay.png", 0, 0, 0, tocolor(r, g, b, 255 * LOBBY_PROGRESS))
						dxDrawLinedRectangle(0, ypos, WIDTH, hh, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS))
						dxDrawText(cLobby[i][c].children[ii].name, 5, ypos, WIDTH, ypos + hh, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), scaledSize(1.4), "roboto-bold", "left", "center")
						dxDrawText(gamemodePlayers[cLobby[i][c].children[ii].name].. "/" ..cLobby[i][c].maxplayers, 5, ypos, WIDTH - 5, ypos + hh, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), scaledSize(1.4), "roboto-bold", "right", "center")
					end
					dxDrawImage(off / 2, (-(totalChildren * hh) * cLobby[i][c].progress) + off, WIDTH - off, HEIGHT - off, cLobby[i][c].imgsrc, 0, 0, 0, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS))
				else
					dxDrawImage(off / 2, off / 2, WIDTH - off, HEIGHT - off, cLobby[i][c].imgsrc, 0, 0, 0, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS))
				end
			end
			dxSetRenderTarget()
			dxDrawImage(x + 5, y, WIDTH, HEIGHT, cLobby[i][c].texture)
			dxDrawLinedRectangle(x + 5, y, WIDTH, HEIGHT, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS))
			dxDrawText(cLobby[i][c].name, x, y, x + WIDTH, y + HEIGHT, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), scaledSize(2.2), "roboto", "center", "center") -- Lobby name
			if cLobby[i][c].name ~= "Closed" and cLobby[i][c].name ~= "Tune your ride" then
				local players = gamemodePlayers[cLobby[i][c].name]
		--		dxDrawText(players .. (players == 1 and " player" or " players"), x + 5, y - 5, x + WIDTH, y + HEIGHT - 5, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), 1.4, "roboto", "center", cLobby[i][c].imgsrc and "bottom" or "center")
			end
		end
	end
	dxDrawText(currplayers .. (currplayers == 1 and " player" or " players") .. " on server", 0 + 1, START_Y + TOTAL_HEIGTH + 1, sx + 1, sy + 1, tocolor(0, 0, 0, 255 * LOBBY_PROGRESS), 1.6, "roboto", "center", "center")
	dxDrawText(currplayers .. (currplayers == 1 and " player" or " players") .. " on server", 0, START_Y + TOTAL_HEIGTH, sx, sy, tocolor(255, 255, 255, 255 * LOBBY_PROGRESS), 1.6, "roboto", "center", "center")
--	dxDrawText(inspect(cLobby[1]), 200, 50, 50, 50, tocolor(0, 0, 0, 255))
end

function handleMouseLobby(_, _, cx, cy)
	for i = 1, #cLobby do
		for c = 1, #cLobby[i] do
			local x = cLobby[i][c].x
			local y = cLobby[i][c].y
			if cx >= x and cx <= x + WIDTH and cy >= y and cy <= y + HEIGHT then
				cLobby[i][c].hovered = true
			else
				cLobby[i][c].hovered = false
			end
		end
	end
end

function handleClickLobby(button, state, cx, cy)
	if button == "left" and state == "up" then
		for i = 1, #cLobby do
			for c = 1, #cLobby[i] do
				local x = cLobby[i][c].x
				local y = cLobby[i][c].y
				if cx >= x and cx <= x + WIDTH and cy >= y and cy <= y + HEIGHT then
					if cLobby[i][c].closed then
						showNotificationToPlayer("Sorry, this gamemode is closed", "error")
					else
						-- Gamemode has children
						if cLobby[i][c].children then
							local cxx, cyy = 0, 0
							cxx, cyy = cx - x, cy - y
							local hh = scaledSize(30)
							for ii = 1, #cLobby[i][c].children do
								local ypos = HEIGHT - (ii * hh)
								if cxx >= 0 and cxx <= WIDTH and cyy >= ypos and cyy <= ypos + hh then
									if getGamemodePlayers(cLobby[i][c].children[ii].name) >= cLobby[i][c].maxplayers then
										showNotificationToPlayer("Gamemode is full", "error")
									else
										triggerServerEvent("lobby:onClientClickLobbyGamemode", localPlayer, cLobby[i][c].children[ii].name)
										showNotificationToPlayer("Joined gamemode " ..cLobby[i][c].children[ii].name, "info")
										stopLobby()
									end
								end
							end
						else
							if cLobby[i][c].name == "Tune your ride" then
								fadeCamera(false)
								setTimer(startTunning, 1000, 1)
								stopLobby()
							elseif cLobby[i][c].name == "Training" then
								triggerEvent("lobby:onPlayerClickTraining", localPlayer)
							else
								triggerServerEvent("lobby:onClientClickLobbyGamemode", localPlayer, cLobby[i][c].name)
								showNotificationToPlayer("Joined gamemode " ..cLobby[i][c].name, "info")
								stopLobby()
							end
						end
					end
					return
				end
			end
		end
	end
end

function createLobby(name, alpha, maxalpha, imgsrc, closed, children, maxplayers)
	if CARD_IDX > ROW_CARDS then
		CARD_IDX = 1
		GROUP_IDX = GROUP_IDX + 1
	end
	local tbl = children and {} or nil
	if children then
		for i = 1, #children do
			table.insert(tbl, { name = children[i], progress = 0 })
		end
	end
	cLobby[GROUP_IDX][CARD_IDX] = { x = 0, y = 0, name = name, alpha = alpha, maxalpha = maxalpha, imgsrc = imgsrc, closed = closed, progress = 0, hovered = false, texture = dxCreateRenderTarget(WIDTH, HEIGHT, true), children = tbl, maxplayers = maxplayers }
	CARD_IDX = CARD_IDX + 1
end

function doPositionCalculation()
	TOTAL_WIDTH = (GROUP_IDX == 1 and CARD_IDX or ROW_CARDS) * (WIDTH + OFFST)
	TOTAL_HEIGTH = GROUP_IDX * (HEIGHT + OFFST)
	local START_X = (sx / 2) - (TOTAL_WIDTH / 2)
	local START_Y = (sy / 2) - (TOTAL_HEIGTH / 2)
	for i = 1, #cLobby do
		for c = 1, #cLobby[i] do
			cLobby[i][c].x = START_X + ((WIDTH + OFFST) * (c - 1))
			cLobby[i][c].y = START_Y + ((HEIGHT + OFFST) * (i - 1))
		end
	end
end

function backToLobby(_, state)
	local tick = getTickCount()
	if tick - backtoLobby.tick <= 10000 and state == "down" then
		local seconds = math.floor((tick - backtoLobby.tick) / 1000)
		local wait = (10 - seconds)
		showNotificationToPlayer("Please wait " ..wait.. " " ..(wait == 1 and "second.." or "seconds.."), "error")
	else
		if getElementData(localPlayer, "room_id") ~= "Lobby" then
			if state == "down" then
				if not backtoLobby.handler then
					addEventHandler("onClientRender", root, drawBackToLobby)
					backtoLobby.handler = true
				end
				backtoLobby.show = true
				backtoLobby.progress2 = 0
				backtoLobby.progress3 = 0
				backtoLobby.progress3up = true
			elseif state == "up" then
				backtoLobby.show = false
			end
		end
	end
end

local w, h = 422, 12
local progress_time = 0.02
function drawBackToLobby()
	local x = (sx / 2) - (w / 2)
	local y = sy - 152
	if backtoLobby.show then
		backtoLobby.progress1 = backtoLobby.progress1 + 0.08 > 1 and 1 or backtoLobby.progress1 + 0.08
		backtoLobby.progress2 = backtoLobby.progress2 + progress_time > 1 and 1 or backtoLobby.progress2 + progress_time
		if backtoLobby.progress3up then
			backtoLobby.progress3 = backtoLobby.progress3 + 0.04 
		elseif not backtoLobby.progress3up then
			backtoLobby.progress3 = backtoLobby.progress3 - 0.04 
		end
		if backtoLobby.progress3 > 1 then
			backtoLobby.progress3 = 1
			backtoLobby.progress3up = false
		elseif backtoLobby.progress3 < 0 then
			backtoLobby.progress3 = 0
			backtoLobby.progress3up = true
		end
	else
		backtoLobby.progress1 = backtoLobby.progress1 - 0.08 < 0 and 0 or backtoLobby.progress1 - 0.08
		if backtoLobby.progress1 == 0  then
			removeEventHandler("onClientRender", root, drawBackToLobby)
			backtoLobby.handler = false
		end
	end
	local pw, center = interpolateBetween(w - 4, 0, 0, 5, (w / 2), 0, backtoLobby.progress2, "Linear")
	local alpha = interpolateBetween(50, 0, 0, 255, 0, 0, backtoLobby.progress3, "Linear")
	dxDrawText("Returning to lobby", x, y - 20, x + w, y, tocolor(255, 255, 255, backtoLobby.show and alpha or 255 * backtoLobby.progress1), 1.2, "roboto", "center", "top")
	dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 180 * backtoLobby.progress1), false, true)
	dxDrawRectangle(x + center, y + 2, pw, h - 4, tocolor(253, 106, 2, 200 * backtoLobby.progress1), false, true)
	if pw == 5 and not backtoLobby.sent then
		backtoLobby.show = false
		startLobby()
		backtoLobby.sent = true
	end
end

function updateLobbiePlayers()
	currplayers = #getElementsByType("player")
--	lobbieplayers = getGamemodePlayers("Lobby")
	for id in pairs(gamemodePlayers) do
		gamemodePlayers[id] = getGamemodePlayers(id)
	end
end

function getGamemodePlayers(tp)
	local players, c = getElementsByType("player"), 0
	for i = 1, #players do
		if getElementData(players[i], "room_id") == tp then
			c = c + 1
		end
	end
	return c
end

function getTrainingPlayers()
	local players, c = getElementsByType("player"), 0
	for i = 1, #players do
		local tp = getElementData(players[i], "room_id")
		if tp then
			if tp:find("Training") then
				c = c + 1
			end
		end
	end
	return c
end

function scaledSize(size)
	return (size / 1920) * sx
end