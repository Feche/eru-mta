local sx, sy = guiGetScreenSize()

local ROW_HEIGHT = 18
local FONT_TYPE = "segoeui-medium"
local FONT_SIZE = 1.2

local SCOREBOARD_WIDTH = 1024
local SCOREBOARD_HEIGHT = 512

local _type = type
local type = {}
type.gamemode = 1
type.team = 2
type.player = 3

local iScoreboard = 
{
	disabled = false,
	visible = false,
	renderTarget = nil,
	rows = {},
	w = 0,
	h = 0,
	oldw = 0,
	oldh = 0,
	serverName = "",
	serverSlots = "",
	serverPlayers = 0,
	scrollY = 0,
	oldY = 0,
	progress = 0,
	timer,
	animprogress = 0,
	selectedProgress = {}
}

local iTabs = {}

local handler = false

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		addScoreboardTab("ID", "id")
		addScoreboardTab("Name", "playername", 150)
	--	addScoreboardTab("Gamemode", "room_id")
		addScoreboardTab("State", "state", 80)
		addScoreboardTab("Money", "money", 70)
		addScoreboardTab("Points", "points")
		addScoreboardTab("Country", "Country", 100)
		addScoreboardTab("Online", "onlinetime")
		addScoreboardTab("FPS", "fps")
		addScoreboardTab("Ping", "Ping")
		iScoreboard.serverName = getElementData(root, "servername")
		iScoreboard.serverSlots = getElementData(root, "maxplayers")
		bindKey("tab", "both", showScoreboard)
	end
)

function addScoreboardTab(name, elementname, width)
	width = width and width or dxGetTextWidth(name, 1, FONT_TYPE) + 15
	table.insert(iTabs, { x = iScoreboard.w, name = name, elementname = elementname, width = width })
	iScoreboard.w = iScoreboard.w + width
	recreateRenderTarget()
end

function drawScoreboard()
	if iScoreboard.visible then
		iScoreboard.animprogress = iScoreboard.animprogress + 0.08 > 1 and 1 or iScoreboard.animprogress + 0.08
	else
		iScoreboard.animprogress = iScoreboard.animprogress - 0.08 < 0 and 0 or iScoreboard.animprogress - 0.08
		if iScoreboard.animprogress == 0 then
			removeEventHandler("onClientRender", root, drawScoreboard)
			removeEventHandler("onClientKey", root, handleScoreboardKeys)
			handler = false
			killTimer(iScoreboard.timer)
		end
	end
	local w, h = getScoreboardSize()
	h = (h > SCOREBOARD_HEIGHT and SCOREBOARD_HEIGHT or h)
	local x, y = sx / 2 - 256, sy / 2 - h / 2
	-- Server name
	local ix, iy = x, y - (ROW_HEIGHT * 2)
	dxDrawRectangle(ix, iy, w, ROW_HEIGHT, tocolor(0, 0, 0, 100 * iScoreboard.animprogress))
	dxDrawLine(ix, iy, ix, iy + ROW_HEIGHT, tocolor(0, 0, 0, 255 * iScoreboard.animprogress), 1)
	dxDrawLine(ix, iy, ix + w - 1, iy, tocolor(0, 0, 0, 255 * iScoreboard.animprogress), 1)
	dxDrawLine(ix + w - 1, iy, ix + w - 1, iy + ROW_HEIGHT, tocolor(0, 0, 0, 255 * iScoreboard.animprogress), 1)
	dxDrawText(iScoreboard.serverName or "?", ix, iy, ix + w, iy + ROW_HEIGHT, tocolor(255, 255, 255, 255 * iScoreboard.animprogress), FONT_SIZE, FONT_TYPE, "left", "center")
	dxDrawText(iScoreboard.serverPlayers.. "/" ..iScoreboard.serverSlots, ix, iy, ix + w - 4, iy + ROW_HEIGHT, tocolor(255, 255, 255, 255 * iScoreboard.animprogress), FONT_SIZE, FONT_TYPE, "right", "center")
	-- Tabs name
	dxDrawRectangle(ix, iy + ROW_HEIGHT, w, ROW_HEIGHT, tocolor(0, 0, 0, 200 * iScoreboard.animprogress))
	for i = 1, #iTabs do
		local tabdata = iTabs[i]
		dxDrawText(tabdata.name, x + tabdata.x, y - ROW_HEIGHT, x + tabdata.x + tabdata.width, y, tocolor(255, 255, 255, 255 * iScoreboard.animprogress), FONT_SIZE, FONT_TYPE, "center", "center", false, false, false, true)
	end
	-- Check if cursor is inside render target
	local cx, cy = getCursorPosition()
	cx = cx and cx * sx or 0
	cy = cy and cy * sy or 0
	local tx, ty = -1, -1
	if cx >= x and cx <= x + w and cy >= y and cy <= y + h then
		tx = cx - x
		ty = cy - y
	end
	-- Prepare render target
	dxSetRenderTarget(iScoreboard.renderTarget, true)
	dxSetBlendMode("modulate_add")
	drawRenderTarget(tx, ty, iScoreboard.animprogress) -- Draw into the render
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	-- Draw render target
	if iScoreboard.renderTarget then
		dxSetBlendMode("add")
		dxDrawImage(x, y, SCOREBOARD_WIDTH, SCOREBOARD_HEIGHT, iScoreboard.renderTarget)
		dxSetBlendMode("blend")
	end
end

function drawRenderTarget(cx, cy, progress)
	local x, y = 0, 0
	local rows = #iScoreboard.rows
	local yoffst = iScoreboard.oldY
	if iScoreboard.oldY ~= iScoreboard.scrollY then
		iScoreboard.progress = iScoreboard.progress + 0.08 > 1 and 1 or iScoreboard.progress + 0.08
		yoffst = interpolateBetween(iScoreboard.oldY, 0, 0, iScoreboard.scrollY, 0, 0, iScoreboard.progress, "Linear")
		if iScoreboard.progress == 1 then
			iScoreboard.oldY = yoffst
			iScoreboard.progress = 0
		end
	end
--	yoffst = iScoreboard.scrollY
	for i = 1, #iScoreboard.rows do
		local idx = i - 1
		local data = iScoreboard.rows[i]
		local w = iScoreboard.w
		-- Gamemode
		if data.tp == type.gamemode then
			dxDrawRectangle(x, y + yoffst, w, ROW_HEIGHT, tocolor(0, 0, 0, 240 * progress))
			dxDrawText(data.name.. " #ffffff(" ..data.players.. (data.players == 1 and " player)" or " players)"), x, y + yoffst, 0, y + yoffst + ROW_HEIGHT, tocolor(255, 165, 0, 255 * progress), FONT_SIZE, FONT_TYPE, "left", "center", false, false, false, true)
			yoffst = yoffst + ROW_HEIGHT
		-- Team
		elseif data.tp == type.team then
			dxDrawRectangle(x, y + yoffst, w, ROW_HEIGHT, tocolor(0, 0, 0, 240 * progress))
			local r, g, b = unpack(data.color)
			dxDrawText("| " ..data.name.. " | #ffffff(" ..data.players.. (data.players == 1 and " player)" or " players)"), x, y + yoffst, 0, 0, tocolor(r, g, b, 255 * progress), FONT_SIZE, FONT_TYPE, "left", "top", false, false, false, true)
			yoffst = yoffst + ROW_HEIGHT
		-- Player
		elseif data.tp == type.player then
			if not iScoreboard.selectedProgress[i] then iScoreboard.selectedProgress[i] = 0 end
			if cx >= x and cx <= x + w and cy >= y + yoffst and cy <= y + yoffst + ROW_HEIGHT then
				iScoreboard.selectedProgress[i] = iScoreboard.selectedProgress[i] + 0.08 > 1 and 1 or iScoreboard.selectedProgress[i] + 0.08
			else
				iScoreboard.selectedProgress[i] = iScoreboard.selectedProgress[i] - 0.08 < 0 and 0 or iScoreboard.selectedProgress[i] - 0.08
			end
			local r, g, a = interpolateBetween(0, 0, 150, 255, 165, 150, iScoreboard.selectedProgress[i], "Linear")
			--
			local source = data.source
			if isElement(source) then
				for i = 1, #iTabs do
					local tabdata = iTabs[i]
					dxDrawRectangle(tabdata.x, y + yoffst, tabdata.width, ROW_HEIGHT, tocolor(r, g, 0, a * progress))
					local value = getElementData(source, tabdata.elementname) or "?"
					local valuenohex = (_type(value) == "string" and value:gsub("#%x%x%x%x%x%x", "") or value)
					value = _type(value) == "number" and convertNumber(value) or value
					dxDrawText(valuenohex, tabdata.x + 1, y + yoffst + 1, tabdata.x + tabdata.width + 1, 0 + 1, tocolor(0, 0, 0, 255 * progress), FONT_SIZE, FONT_TYPE, "center", "top")
					dxDrawText(value, tabdata.x, y + yoffst, tabdata.x + tabdata.width, 0, tocolor(255, 255, 255, 255 * progress), FONT_SIZE, FONT_TYPE, "center", "top", false, false, false, true)
				end
				yoffst = yoffst + ROW_HEIGHT
			end
		end
	end
end

function updateScoreboardData()
	local players = getElementsByType("player")
	local idx = #players
	for i = 1, idx do
		setElementData(players[i], "Ping", getPlayerPing(players[i]), false)
	end
	iScoreboard.serverPlayers = idx
	iScoreboard.rows = {}
	local tp = getPlayerGamemode(localPlayer)
	for gamemode, teams in pairs(getTeamsInGamemodes()) do
		local gamemodepos = 0
		local teampos = 0
		-- Insert gamemodes
		if gamemodeHasTeams(teams) then
			table.insert(iScoreboard.rows, { tp = type.gamemode, name = gamemode, players = 0 })
			gamemodepos = #iScoreboard.rows
			if gamemode == "Login" then
				for _, player in pairs(teams) do
					table.insert(iScoreboard.rows, { tp = type.player, source = player })
					iScoreboard.rows[gamemodepos].players = iScoreboard.rows[gamemodepos].players + 1
				end
			else
				for team in pairs(teams) do
					-- Insert teams
					local players = getPlayersInTeam(team)
					table.insert(iScoreboard.rows, { tp = type.team, name = getTeamName(team), color = { getTeamColor(team) }, players = 0 })
					teampos = #iScoreboard.rows
					for i = 1, #players do
						if getPlayerGamemode(players[i]) == gamemode then
							-- Insert players
							table.insert(iScoreboard.rows, { tp = type.player, source = players[i] })
							iScoreboard.rows[gamemodepos].players = iScoreboard.rows[gamemodepos].players + 1
							iScoreboard.rows[teampos].players = iScoreboard.rows[teampos].players + 1
						end
					end
				end
			end
		end
	end
	-- Add player to first position
	idx = #iScoreboard.rows
	local gamemodepos = 0
	for i = 1, idx do
		if iScoreboard.rows[i].tp == type.gamemode then 
			if iScoreboard.rows[i].name == tp then
				gamemodepos = i
				local c = 1
				for x = gamemodepos + 1, idx do
					if iScoreboard.rows[x].tp ~= type.gamemode then
						c = c + 1
					else
						break
					end
				end
				local count = 0
				local tbl = {}
				while true do
					local data = iScoreboard.rows[gamemodepos]
					table.remove(iScoreboard.rows, gamemodepos)
					table.insert(tbl, 1, data)
					count = count + 1
					if count == c then
						local playerdata
						for i = 1, #tbl do
							if tbl[i].tp == type.player then
								if tbl[i].source == localPlayer then
									playerdata = tbl[i]
								else
									table.insert(iScoreboard.rows, 1, tbl[i])
								end
							elseif tbl[i].tp == type.gamemode then
								table.insert(iScoreboard.rows, 1, tbl[i])
								table.insert(iScoreboard.rows, 3, playerdata)
							else
								table.insert(iScoreboard.rows, 1, tbl[i])
							end
						end
						break
					end
				end
				break
			end
		end
	end
	recreateRenderTarget()
end

function handleScoreboardKeys(key, press)
--	if iScoreboard.progress ~= 0 then return end
	local step = 20
	if key == "mouse_wheel_up" then 
		iScoreboard.scrollY = iScoreboard.scrollY + step > 0 and 0 or iScoreboard.scrollY + step
	elseif key == "mouse_wheel_down" then
		local h = SCOREBOARD_HEIGHT
		local _, th = getScoreboardSize()
		iScoreboard.scrollY = iScoreboard.scrollY - step
		if th + iScoreboard.scrollY < SCOREBOARD_HEIGHT then
			iScoreboard.scrollY = -th + (th > SCOREBOARD_HEIGHT and SCOREBOARD_HEIGHT or th)
			return
		end
 	elseif key == "mouse2" then
		showCursor(press)
	end
end

function getScoreboardSize()
	return iScoreboard.w, #iScoreboard.rows * ROW_HEIGHT
end

function showScoreboard()
	if iScoreboard.disabled then return end
	iScoreboard.visible = not iScoreboard.visible
	if iScoreboard.visible then
		if not handler then
			updateScoreboardData()
			addEventHandler("onClientRender", root, drawScoreboard)
			addEventHandler("onClientKey", root, handleScoreboardKeys)
			handler = true
			iScoreboard.timer = setTimer(updateScoreboardData, 1000, 0)
			setCursorPosition(sx / 2, sy / 2)
		end
	end
end

local viewrender = false
function recreateRenderTarget()
	local w, h = getScoreboardSize()
	w = SCOREBOARD_WIDTH
	h = SCOREBOARD_HEIGHT
	if iScoreboard.oldw == w and iScoreboard.oldh == h then
		return
	end
	if not iScoreboard.renderTarget then
		iScoreboard.renderTarget = dxCreateRenderTarget(w, h, not viewrender)
		if iScoreboard.renderTarget then
		--	outputDebugString("[TAB] Created render target, size " ..w.. "x" ..h)
		end
	else
		destroyElement(iScoreboard.renderTarget)
		iScoreboard.renderTarget = nil
		iScoreboard.renderTarget = dxCreateRenderTarget(w, h, not viewrender)
		if iScoreboard.renderTarget then
		--	outputDebugString("[TAB] Re-created render target, size " ..w.. "x" ..h)
		end
	end
	iScoreboard.oldw, iScoreboard.oldh = w, h
end

function getTeamsInGamemodes()
	local gamemodes =
	{
		["Login"] = {},
		["Lobby"] = {},
		["Deathmatch A"] = {},
		["Deathmatch B"] = {},
		["Oldschool A"] = {},
		["Oldschool B"] = {},
		["Destruction Derby A"] = {},
		["Destruction Derby B"] = {},
		["Training"] = {},
		["Race"] = {},
		["Shooter"] = {},
		["Hunter"] = {},
		["Trials"] = {},
		["OJ"] = {},
		["Freeroam"] = {}
	}
	local players = getElementsByType("player")
	for i = 1, #players do
		local tp = getPlayerGamemode(players[i])
		if tp == "Login" then
			table.insert(gamemodes[tp], players[i])
		else
			local team = getPlayerTeam(players[i])
			if team then
				if not gamemodes[tp][team] then
					gamemodes[tp][team] = team
				end
			end
		end
	end
	return gamemodes
end

function getPlayerGamemode(source)
	local tp = getElementData(source, "room_id")
	if tp:find("Training_S") then
		tp = "Training"
	end
	tp = tp:gsub("Joined", "Login")
	return tp
end

function gamemodeHasTeams(tbl)
	for _, _ in pairs(tbl) do
		return true
	end
	return false
end

function convertNumber ( number )  
	if not number then return "?" end
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end