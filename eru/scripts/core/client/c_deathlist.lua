local POSX = 18
local POSY = 200
local MAX_LIST = 11
--
local scale = 1
local font = "roboto-bold"
local seconds = 1

local showdeathlist = true
local showprogress = 0

local gDeathlist =
{
	name,
	posx,
	posy,
	width
}

local reso =
{	-- posx, posy, maxonlist
	[600] = { 18, 200, 11 },
	[768] = { 18, 200, 19 },
	[1080] = { 24, 400, 26 }
}

-- Set resolution
if reso[sy] then -- If reso doesn't exist, fallback to predefined above
	POSX, POSY, MAX_LIST = unpack(reso[sy])
end

local queue = {}
local names = {}
local lastaddedtick = getTickCount()
local idx = 0
local timer

addEvent("deathlist:addNameToDeathlist", true)

addEventHandler("onClientRender", root,
	function()
		local offstx = interpolateBetween(-200, 0, 0, POSX - 20, 0, 0, gRace.progress, "Linear")
		for i = 1, #gDeathlist do
			-- Move left
			if gDeathlist[i].goleft then
				gDeathlist[i].progress = gDeathlist[i].progress + 0.06 > 1 and 1 or gDeathlist[i].progress + 0.06
				gDeathlist[i].posx = interpolateBetween(-gDeathlist[i].width, 0, 0, POSX, 0, 0, gDeathlist[i].progress, "Linear")
				if gDeathlist[i].progress == 1 then
					gDeathlist[i].goleft = false
				end
			end
			-- Move down
			if gDeathlist[i].godown then
				gDeathlist[i].progress = gDeathlist[i].progress + 0.08 > 1 and 1 or gDeathlist[i].progress + 0.08
				gDeathlist[i].posy = interpolateBetween(gDeathlist[i].posy, 0, 0, gDeathlist[i].posy + 2, 0, 0, gDeathlist[i].progress, "Linear")
				if gDeathlist[i].progress == 1 then
					gDeathlist[i].godown = false
				end
			end
			-- Fade out
			if gDeathlist[i].fadeout then
				gDeathlist[i].fadeprogress = gDeathlist[i].fadeprogress - 0.06 < 0 and 0 or gDeathlist[i].fadeprogress - 0.06
				dxDrawText(gDeathlist[i].name, gDeathlist[i].posx + offstx, gDeathlist[i].posy, gDeathlist[i].posx + gDeathlist[i].width + offstx, gDeathlist[i].posy, tocolor(255, 255, 255, 255 * gDeathlist[i].fadeprogress), scale, font, "left", "top", false, false, false, true)
				if gDeathlist[i].fadeprogress == 0 then
					table.remove(gDeathlist, i)
				end
			else
				dxDrawText(gDeathlist[i].namenocolor, gDeathlist[i].posx + offstx + 1, gDeathlist[i].posy + 1, gDeathlist[i].posx + gDeathlist[i].width + offstx + 1, gDeathlist[i].posy + 1, tocolor(0, 0, 0, 255), scale, font, "left", "top", false, false, false, false)
				dxDrawText(gDeathlist[i].name, gDeathlist[i].posx + offstx, gDeathlist[i].posy, gDeathlist[i].posx + gDeathlist[i].width + offstx, gDeathlist[i].posy, -1, scale, font, "left", "top", false, false, false, true)
			end
		end
	end
)

addEventHandler("deathlist:addNameToDeathlist", root,
	function(name)
		addNameToDeathlist(name)
	end
)

function addNameToDeathlist(name)
	if names[name] then return end
	local idx = #queue + 1
	local width = dxGetTextWidth(name, scale, font) + 15
	queue[idx] = { name = name, namenocolor = name:gsub("#%x%x%x%x%x%x", ""), posx = -width, posy = POSY, width = width + 10, progress = 0, fadeprogress = 0, goleft = true, godown = false, fadeout = false }
	names[name] = true -- prevent doubles on deathlist
end

function clearDeathList()
	if isTimer(timer) then
		killTimer(timer)
	end
	queue = {}
	gDeathlist = {}
	names = {}
	timer = setTimer(moveFromQueue, seconds * 1000, 0)
--	outputDebugString("[DEATHLIST] Deathlist cleared")
end

function showDeathlist(bool)
	showdeathlist = bool
end	

function moveFromQueue()
	for i in pairs(queue) do
		local tick = getTickCount()
		if tick - lastaddedtick >= seconds * 1000 then
			local idx = #gDeathlist
			-- Move the rest down
			for x = 1, idx do	
				gDeathlist[x].progress = 0
				gDeathlist[x].godown = true
			end
			table.insert(gDeathlist, 1, queue[i])
			idx = idx + 1
			if idx > MAX_LIST then
				gDeathlist[idx].godown = true
				gDeathlist[idx].fadeout = true
				gDeathlist[idx].progress = 0
				gDeathlist[idx].fadeprogress = 1
			end
			table.remove(queue, i)
			lastaddedtick = tick
			return
		end
	end
end
timer = setTimer(moveFromQueue, seconds * 1000, 0)