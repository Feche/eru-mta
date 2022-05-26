local SECONDS_CHECK = 10
local AFK_ENABLED = true

local oldX, oldY, oldZ = 0, 0, 0
local isAFK = false
local afkTick = getTickCount()
local progress = 0
local goup = true
local afkTimer = nil
local killedTimes = 0

addEvent("race:onRaceMapStart", true)
addEvent("race:onRaceMapStop", true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		-- Disable AFK on local server
		if getElementData(root, "maxplayers") == 32 then
			AFK_ENABLED = false
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function()
		if isTimer(afkTimer) then
			killTimer(afkTimer)
		end
		afkTimer = setTimer(checkAFK, SECONDS_CHECK * 1000, 0)
	end
)

addEventHandler("race:onRaceMapStop", root,
	function()
		if isTimer(afkTimer) then
			killTimer(afkTimer)
		end
		isAFK = false
	end
)

function checkAFK()
	if not AFK_ENABLED then return end
	local state = getElementData(localPlayer, "state")
	if state == "alive" then
		local x, y, z = getElementPosition(localPlayer)
		if math.floor(x) == oldX and math.floor(y) == oldY and math.floor(z) == oldZ then
			if not isAFK then
				afkTick = getTickCount()
			end
			isAFK = true
		else
			oldX, oldY, oldZ = math.floor(x), math.floor(y), math.floor(z)
			isAFK = false
		end
	end
end

addEventHandler("onClientRender", root,
	function()
		if isAFK then
			if goup then
				progress = progress + 0.04 > 1 and 1 or progress + 0.04
				if progress == 1 then
					goup = false
				end
			else
				progress = progress - 0.04 < 0 and 0 or progress - 0.04
				if progress == 0 then
					goup = true
				end
			end
			local seconds = math.floor((15000 - (getTickCount() - afkTick)) / 1000)
			local txt = { [0] = "KILLED", [1] = "KILLED", [2] = "KICKED TO LOBBY" }
			dxDrawText("move or you will get " ..txt[killedTimes].. "\n" ..seconds.. " seconds", 0 + 2, 0 + 2, sx + 2, sy + 2, tocolor(0, 0, 0, 255 * progress), 1, "bankgothic", "center", "center", false, false, false, true)
			dxDrawText("move or you will get #FF0000" ..txt[killedTimes].. "\n" ..seconds.. " #ffffffseconds", 0, 0, sx, sy, tocolor(255, 255, 255, 255 * progress), 1, "bankgothic", "center", "center", false, false, false, true)
			if seconds == 0 then
				isAFK = false
				killedTimes = killedTimes + 1
				if killedTimes == 3 then
					startLobby() -- Kick to lobby
					killedTimes = 0
				else
					handleRaceKill()
				end
			end
		end
	end
)

addEventHandler("onClientCharacter", root,
	function()
		killedTimes = 0
		isAFK = false
		oldX, oldY, oldZ = 0, 0, 0
	end
)