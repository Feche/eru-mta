local OJvehicles =
{
	518, 419, 474, 600, 491, 604, 467, 550, 529, 459, 605, 478, 458, 475, 560, 568, 489
}

local policeVehicles =
{
	433, 427, 490, 528, 523, 596, 598, 599, 597, 601
}

local OJtarget = nil
local OJspawnidx = nil
local OJbarrels = {}

setElementData(root, "oj.ghostmode", true)

addEvent("race:onRaceMapStop")
addEvent("race:onRaceMapStart")

addEvent("lobby:onPlayerJoinLobby", true)
addEvent("oj:onOJDropBarrel", true)

addEventHandler("onPlayerQuit", root,
	function()
		if source == OJtarget then
			local state = getGamemodeState("OJ")
			if state ~= "map started" then
				OJtarget = getOJplayer()
				outputChatBoxToGamemode("- The OJ left, new OJ is " ..getPlayerName(OJtarget), "OJ")
				spawnRacePlayer(OJtarget, "OJ", OJspawnidx) -- get OJ spawn from valid OJ vehicles
				setVehicleColor(pVeh[OJtarget], 254, 127, 156)
				setElementData(root, "oj.target", OJtarget)
			end
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		if source == OJtarget then
			local state = getGamemodeState("OJ")
			if state ~= "map started" then
				OJtarget = getOJplayer()
				outputChatBoxToGamemode("- The OJ left, new OJ is " ..getPlayerName(OJtarget), "OJ")
				spawnRacePlayer(OJtarget, "OJ", OJspawnidx) -- get OJ spawn from valid OJ vehicles
				setVehicleColor(pVeh[OJtarget], 254, 127, 156)
				setElementData(root, "oj.target", OJtarget)
			end
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "OJ" then
			OJtarget = nil -- remove OJ target so next map is selected again
			OJspawnidx = nil
			setElementData(root, "oj.target", nil)
			setElementData(root, "oj.ghostmode", true)
			destroyBarrels()
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "OJ" then
			destroyBarrels()
			setElementData(root, "oj.ghostmode", true)
			showNotificationToGamemode("Disabling ghostmode in 15 seconds", "OJ", "warning")
			setTimer(
				function()
					setElementData(root, "oj.ghostmode", false)
					showNotificationToGamemode("Ghostmode disabled", "OJ", "warning")
				end
			, 15000, 1)
		end
	end
)

addEventHandler("oj:onOJDropBarrel", root,
	function(pos)
		local obj = createObject(1225, unpack(pos))
		setElementDimension(obj, getElementDimension(source))
		OJbarrels[#OJbarrels + 1] = obj
	end
)

function handleOJSpawn(source, spawns)
	if not OJtarget then
		OJtarget = getOJplayer()
		OJspawnidx = findOJspawn(spawns)
	end
	if source == OJtarget then
		spawnRacePlayer(source, "OJ", OJspawnidx) -- get OJ spawn from valid OJ vehicles
		setVehicleColor(pVeh[source], 254, 127, 156)
		setElementData(root, "oj.target", OJtarget)
	else
		spawnRacePlayer(source, "OJ", findPoliceSpawn(spawns))
		setVehicleColor(pVeh[source], 255, 255, 255)
	end
end

function handleOJKill(source, iswin)
	if source == OJtarget then
		if iswin then
			setTimer(changeLobbyMap, 2000, 1, "OJ")
			setTimer(addToDeathlist, 500, 1, getPlayerName(source), "OJ")
			triggerClientEventForGamemode(root, "OJ", "race:onPlayerWin", source, "#F987C5OJ")
			triggerEvent("race:onOJWin", source)
		else
			setTimer(changeLobbyMap, 2000, 1, "OJ")
			triggerClientEventForGamemode(root, "OJ", "race:onPlayerWin", source, "#0000FFPolice")
		end		
	end
end

function handleOJMapFinish()
	if getPlayerState(OJtarget) == "alive" then
		triggerClientEventForGamemode(root, "OJ", "race:onPlayerWin", source, "#F987C5OJ")
		setTimer(changeLobbyMap, 1500, 1, "OJ")
	end
end

function getOJplayer()
	local players = getGamemodePlayers("OJ")
	return players[math.random(#players)]
end

function getCurrentOJ()
	return OJtarget
end

function findOJspawn(spawns)
	for i = 1, #spawns do
		for x = 1, #OJvehicles do
			if tonumber(spawns[i].modelid) == OJvehicles[x] then
				return i
			end
		end
	end
end

function findPoliceSpawn(spawns)
	while true do
		local idx = math.random(#spawns)
		if idx ~= OJspawnidx then
			return idx
		end
	end
end

function destroyBarrels()
	for i = 1, #OJbarrels do
		destroyElement(OJbarrels[i])
	end
	OJbarrels = {}
end

function getPositionInfrontOfElement(element, meters)
	if (not element or not isElement(element)) then return false end
	local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end