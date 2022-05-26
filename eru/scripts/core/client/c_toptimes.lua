local width, height = 360, 220
local xx, y = sx - width - 10, (sy / 2 - width / 2) - 60

local isvisible = false
local progress = 0
local goup = false
local handler = false
local mapname = "-"
local tts = {}
local showtttimer = nil

addEvent("race:onRaceMapStop")

addEvent("toptimes:onServerSendToptimes", true)
addEvent("race:onRaceMapStarting", true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		bindKey("F5", "down", setToptimeVisible)
	end
)

addEventHandler("toptimes:onServerSendToptimes", root,
	function(toptimes, name)
		tts = toptimes
		mapname = name
	end
)

addEventHandler("race:onRaceMapStop", root,
	function()
		tts = {}
		mapname = "-"
		if isToptimeVisible() then
			setToptimeVisible()
		end
	end
)

addEventHandler("race:onRaceMapStarting", root,
	function(tp)
		if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" then
			setToptimeVisible()
			showtttimer = setTimer(setToptimeVisible, 5000, 1)
		end
	end
)

function drawToptime()
	if goup then
		progress = progress + 0.08 > 1 and 1 or progress + 0.08
	else
		progress = progress - 0.08 < 0 and 0 or progress - 0.08
	end
	x = interpolateBetween(sx + width, 0, 0, xx, 0, 0, progress, "Linear")
	-- Ractangle
	dxDrawRoundedRectangle(x, y, width, height, tocolor(0, 0, 0, 220 * progress), 8)
	-- Map name
	dxDrawRoundedRectangle(x, y, width, 30, tocolor(0, 0, 0, 200 * progress), 8, "top")
	dxDrawText(mapname or "???", x, y, x + width, y + 30, -1, 1, "default-bold", "center", "center")
	local h = ((height - 30) / 10) - 2
	for i = 1, 10 do
		local posx, posy = x + 10, y + (h * i) + 22
		dxDrawRoundedRectangle(posx, posy, width - 20, h, ((i % 2 == 0) and tocolor(40, 40, 40, 120 * progress) or tocolor(50, 50, 50, 120 * progress)), 5)
		dxDrawText(i.. ":", posx + 5, posy, posx + 5, posy + h, -1, 1, "default", "left", "center")
		dxDrawText(tts[i] and tts[i].name or "-", posx + 30, posy, posx + 110, posy + h, -1, 1, "default", "center", "center", false, false, false, true)
		dxDrawText(tts[i] and tts[i].timestr or "-", posx + 110, posy, posx + 190, posy + h, -1, 1, "default", "center", "center")
		dxDrawText(tts[i] and tts[i].country or "-", posx + 190, posy, posx + 270, posy + h, -1, 1, "default", "center", "center")
		dxDrawText(tts[i] and tts[i].date or "-", posx + 270, posy, posx + 335, posy + h, -1, 1, "default", "center", "center")
	end
	-- Remove handler if progress is done
	if progress == 0 then
		removeEventHandler("onClientRender", root, drawToptime)
		handler = false
	end
end

function setToptimeVisible()
	local tp = getElementData(localPlayer, "room_id")
	if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" then
		if isTimer(showtttimer) then -- Kill timer if player hides toptimes on mapstart (so it doesnt showup again)
			killTimer(showtttimer) 
		end
		isvisible = not isvisible
		goup = isvisible
		if isvisible then
			progress = 0
		end
		if isvisible and not handler then
			addEventHandler("onClientRender", root, drawToptime)
			handler = true
		end
		if #tts == 0 and isvisible then
			triggerServerEvent("toptimes:onPlayerRequestMapToptimes", localPlayer)
		end
	end
end

function isToptimeVisible()
	return isvisible
end