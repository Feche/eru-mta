local MAP_COST = 2000

local ignoredScripts =
{
	"mapEditorScriptingExtension_c.lua", -- Map editor files
	"mapEditorScriptingExtension_s.lua"
}

local fileExtensionsToLoad = 
{
	".dff",
	".txd",
	".png",
	".dds",
	".fx",
	".col",
	".ogg",
	".mp3"
}

local gResources = {}
local gRecentMaps = {}

sResources =
{
	["Deathmatch"] = {},
	["Oldschool"] = {},
	["Destruction Derby"] = {},
	["Race"] = {},
	["Shooter"] = {},
	["Hunter"] = {},
	["Trials"] = {},
	["OJ"] = {}
}

local gGamemode =
{
	["Deathmatch A"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Deathmatch B"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Oldschool A"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Oldschool B"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Destruction Derby A"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Destruction Derby B"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Training"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Race"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Shooter"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Hunter"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Trials"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["OJ"] = { currentMap = "", mapQueue = {}, lastBought = nil },
	["Freeroam"] = { currentMap = "", mapQueue = {}, lastBought = nil }
}

local DM_ODM_MAPS = {}
local DM_MAPS = {}
local ODM_MAPS = {}
local DD_MAPS = {}
local TRIALS_MAPS = {}
local HUNTER_MAPS = {}
local RACE_MAPS = {}
local SHOOTER_MAPS = {}
local OJ_MAPS = {}

addEvent("panel:onPlayerRequestBuyMap", true)

addEventHandler("onResourceStart", resourceRoot,
	function()
		loadServerMaps()
		setElementData(root, "map.cost", MAP_COST)
	end
)

addEventHandler("panel:onPlayerRequestBuyMap", root,
	function(name)
		local tp = getPlayerGamemode(source)
		local resname, mapname = getMapFromName(name, tp)
		if resname then
			if #gGamemode[tp].mapQueue == 0 then
				if not isRecentMap(resname) then
					setNextMap(resname, mapname, tp)
					outputChatBoxToGamemode("#2E9AFE* '" ..mapname.. "' has been bought by " ..getPlayerNameNoColor(source), tp)
					givePlayerMoney(source, -getMapCost())
					showNotificationToPlayer(source, "Map bought", "info")
					gGamemode[tp].lastBought = { source = source, tick = getTickCount(), mapname = mapname, resname = resname }
					outputChatBox("You have 10 seconds to unbuy the current map (/ubm)", source, 255, 255, 0)
				else
					showNotificationToPlayer(source, "Map has been recently played, it will be available again in " ..(math.floor((1800000 - (getTickCount() - gRecentMaps[resname])) / 60000) + 1).. " minute(s)", "error")
				end
			else
				showNotificationToPlayer(source, "Next map is already set", "error")
			end
		else
			showNotificationToPlayer(source, "No map found with " ..name, "error")
		end
	end
)

addCommandHandler("qm",
	function(source, cmd, ...)
		if not canExecuteCmd(source, 2) then return end
		if not ... then
			outputChatBox("Usage: qm [mapname]", source, 255, 255, 255)
		else
			local tp = getPlayerGamemode(source)
			local mn = table.concat({ ... }, " ")
			local resname, mapname = getMapFromPartialName(mn, tp)
			if mapname then
				local text = { "set as next map", "added to the map queue" }
				setNextMap(resname, mapname, tp, true)
				outputChatBoxToGamemode("#2E9AFE* '" ..mapname.. "' has been " ..text[#gGamemode[tp].mapQueue == 1 and 1 or 2].. " by " ..getPlayerNameNoColor(source), tp)
			else
				outputChatBox("No map found with '" ..mn.. "'", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("redo",
	function(source)
		if not canExecuteCmd(source, 2) then return end
		local tp = getPlayerGamemode(source)
		local resname, mapname = getMapFromName(getCurrentMap(tp), tp)
		if resname then
			setNextMap(resname, mapname, tp, true, 1)
			outputChatBoxToGamemode("#2E9AFE* " ..getPlayerNameNoColor(source).. " has set this map to be replayed", tp)
		end
	end
)

addCommandHandler("cmq",
	function(source, cmd)
		if not canExecuteCmd(source, 2) then return end
		local tp = getPlayerGamemode(source)
		gGamemode[tp].mapQueue = {}
		outputChatBoxToGamemode("#2E9AFE* Map queue has been cleared by " ..getPlayerNameNoColor(source), tp)
		updateNextMapClient(tp)
	end
)

addCommandHandler("bm",
	function(source, cmd, ...)
		if not canUseCmd(source, cmd) then return end
		if not ... then
			outputChatBox("Usage: bm [mapname]", source, 255, 255, 255)
		else
			if getPlayerMoney(source) < getMapCost() then
				outputChatBox("You don't have enough money.", source, 255, 0, 0)
			else
				local tp = getPlayerGamemode(source)
				if #gGamemode[tp].mapQueue == 0 then
					local mn = table.concat({ ... }, " ")
					local resname, mapname = getMapFromPartialName(mn, tp)
					if not isRecentMap(resname) then
						if mapname then
							setNextMap(resname, mapname, tp)
							outputChatBoxToGamemode("#2E9AFE* '" ..mapname.. "' has been bought by " ..getPlayerNameNoColor(source), tp)
							givePlayerMoney(source, -getMapCost())
							gGamemode[tp].lastBought = { source = source, tick = getTickCount(), mapname = mapname, resname = resname }
							outputChatBox("You have 10 seconds to unbuy the current map (/ubm)", source, 255, 255, 0)
						else
							outputChatBox("No map found with '" ..mn.. "'", source, 255, 0, 0)
						end
					else
						outputChatBox("Map has been recently played, it will be available again in " ..(math.floor((1800000 - (getTickCount() - gRecentMaps[resname])) / 60000) + 1).. " minute(s)", source, 255, 0, 0)
					end
				else
					outputChatBox("Next map is already set.", source, 255, 0, 0)
				end
			end
		end
	end
)

addCommandHandler("ubm", 
	function(source)
		local tp = getPlayerGamemode(source)
		if gGamemode[tp].lastBought then
			if gGamemode[tp].lastBought.source == source then
				if getTickCount() - gGamemode[tp].lastBought.tick <= 10000 then
					for i = 1, #gGamemode[tp].mapQueue do
						if gGamemode[tp].mapQueue[i][2] == gGamemode[tp].lastBought.mapname then
							table.remove(gGamemode[tp].mapQueue, i)
							gRecentMaps[gGamemode[tp].lastBought.resname] = 0
							break
						end
					end
					outputChatBoxToGamemode("#2E9AFE* '" ..gGamemode[tp].lastBought.mapname.. "' has been unbought by " ..getPlayerNameNoColor(source), tp)
					gGamemode[tp].lastBought = nil
					updateNextMapClient(tp)
					givePlayerMoney(source, getMapCost())
					showNotificationToPlayer(source, "You have been refunded", "warning")
				else
					outputChatBox("You ran out of time :(", source, 255, 0, 0)
				end
			else
				outputChatBox("You did not buy the map!", source, 255, 0, 0)
			end
		else
			outputChatBox("There is no map to be unbought", source, 255, 0, 0)
		end
	end
)

addCommandHandler("resname",
	function(source)
		if not canExecuteCmd(source, 1) then return end
		local tp = getPlayerGamemode(source)
		local resname = getResourceNameFromMapname(getCurrentMap(tp))
		outputChatBox("Resource name is: " ..resname, source, 255, 255, 255)
	end
)

addCommandHandler("reloadmaps",
	function(source)
		if not canExecuteCmd(source, 4) then return end
		loadServerMaps()
		outputChatBox("Server maps were reloaded succesfully", source, 255, 255, 255)
	end
)

function getNextMap(tp)
	local sResTP = getCleanType(tp)
	gGamemode[tp].lastBought = nil
	--
	if #gGamemode[tp].mapQueue == 0 then
		local idx = math.random(#sResources[sResTP])
		gGamemode[tp].currentMap = sResources[sResTP][idx].mapname
		return sResources[sResTP][idx].resname, sResources[sResTP][idx].mapname
	else
		local resname, mapname = gGamemode[tp].mapQueue[1][1], gGamemode[tp].mapQueue[1][2]
		table.remove(gGamemode[tp].mapQueue, 1)
		gGamemode[tp].currentMap = mapname
		return resname, mapname
	end
end

function setNextMap(resname, mapname, tp, adminqueue, pos)
	table.insert(gGamemode[tp].mapQueue, pos or (#gGamemode[tp].mapQueue + 1), { resname, mapname })
	if not adminqueue then
		gRecentMaps[resname] = getTickCount()
	end
	updateNextMapClient(tp)
end

function isRecentMap(resname)
	if not gRecentMaps[resname] then
		return false
	elseif getTickCount() - (gRecentMaps[resname] or 0) >= 1800000 then
		gRecentMaps[resname] = nil
		return false
	end
	return true
end

function updateNextMapClient(tp, to)
	if to then
		triggerClientEvent(to, "race:updateNextMap", to, gGamemode[tp].mapQueue[1] and gGamemode[tp].mapQueue[1][2] or nil)
	else
		triggerClientEventForGamemode(root, tp, "race:updateNextMap", gGamemode[tp].mapQueue[1] and gGamemode[tp].mapQueue[1][2] or nil)
	end
end

function getResourceNameFromMapname(mapname)
	for tp in pairs(sResources) do
		for i = 1, #sResources[tp] do
			if sResources[tp][i].mapname == mapname then
				return sResources[tp][i].resname
			end
		end
	end
	return false
end

function getMapNameFromResourceName(resname)
	for tp in pairs(sResources) do
		for i = 1, #sResources[tp] do
			if sResources[tp][i].resname == resname then
				return sResources[tp][i].mapname
			end
		end
	end
end

function getMapFromPartialName(partial, tp)
	tp = getCleanType(tp)
	for i = 1, #sResources[tp] do
		if sResources[tp][i].mapname:lower():find(partial:lower()) then
			return sResources[tp][i].resname, sResources[tp][i].mapname
		end
	end
	return false
end

function getMapFromName(name, tp)
	tp = getCleanType(tp)
	for i = 1, #sResources[tp] do
		if sResources[tp][i].mapname == name then
			return sResources[tp][i].resname, sResources[tp][i].mapname
		end
	end
	return false
end

function getCurrentMap(tp)
	return gGamemode[tp].currentMap
end

function getResourceCategory(resname)
	if resname:find("race-dm-", 1, true) then
		return "[deathmatch]"
	elseif resname:find("race-odm-", 1, true) then
		return "[old deathmatch]"
	elseif resname:find("race-dd-", 1, true) then
		return "[destruction derby]"
	elseif resname:find("race-trials-", 1, true) then
		return "[trials]"
	elseif resname:find("race-hunter-", 1, true) then
		return "[hunter]"
	elseif resname:find("race-shooter-", 1, true) then
		return "[shooter]"
	elseif resname:find("race-oj-", 1, true) then
		return "[oj]"
	end
	-- Race
	local _, count = resname:gsub("%-", "")
	if count == 1 then
		return "[race]"
	end
	return "?"
end

function getResourceMapName(resname)
	local meta = xmlLoadFile("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/meta.xml", true)
	if meta then
		local info = xmlFindChild(meta, "info", 0)
		if info then
			local info = xmlNodeGetAttributes(info)
			xmlUnloadFile(meta)
			return info.name
		end
		xmlUnloadFile(meta)
	else
		outputDebugString("[MAP] Could not get mapname from meta.xml for resource '" ..resname.. "'", 1)
	end
	return false
end

function getResourceAuthor(resname)
	local meta = xmlLoadFile("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/meta.xml", true)
	if meta then
		local info = xmlFindChild(meta, "info", 0)
		if info then
			local info = xmlNodeGetAttributes(info)
			xmlUnloadFile(meta)
			return info.author or "??"
		end
		xmlUnloadFile(meta)
	end
	return false
end

function getResourceTimeWeather(resname)
	local weather, hour, minute = false, false, false
	local meta = xmlLoadFile("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/meta.xml", true)
	if meta then
		local settings = xmlFindChild(meta, "settings", 0)
		if settings then
			for i = 1, 20 do
				local settingsNode = xmlFindChild(settings, "setting", i)
				if settingsNode then
					local settingData = xmlNodeGetAttributes(settingsNode)
					-- Time
					if settingData.name == "#time" then
						hour, minute = settingData.value:match("(%d+):(%d+)")
					-- Weather
					elseif settingData.name == "#weather" then
						weather = settingData.value:gsub("%[", ""):gsub("%]", ""):gsub(" ", "")
					end
					-- If we got all what we needed, break the loop to save CPU
					if settingData.name and settingData.weather then
						break
					end
				end
			end
		end
		xmlUnloadFile(meta)
	end
	return { tonumber(weather), tonumber(hour), tonumber(minute) }
end

function loadServerMaps()
	DM_ODM_MAPS = {}
	DM_MAPS = {}
	ODM_MAPS = {}
	RACE_MAPS = {}
	SHOOTER_MAPS = {}
	OJ_MAPS = {}
	--
	if fileExists("server_maps") then
		local file = fileOpen("server_maps")
		gResources = fromJSON(fileRead(file, fileGetSize(file)))
		fileClose(file)
		outputDebugString("[MAPS] Loaded " ..#gResources.. " maps from server_maps file")
	else
		outputDebugString("[MAPS] server_maps file not found, stopping resource..")
		stopResource(getThisResource())
	end
	-- Set map names
	for i = 1, #gResources do
		local resname = gResources[i]
		local mapname = getResourceMapName(resname)
		if mapname then
			if resname:find("race-dm-", 1, true) then	
				mapname = not mapname:find("[DM]") and "[DM] " ..mapname or mapname
				sResources["Deathmatch"][#sResources["Deathmatch"] + 1] = { resname = resname, mapname = mapname }
				table.insert(DM_ODM_MAPS, mapname) -- For training
				table.insert(DM_MAPS, mapname)
			-- Old deathmatch maps
			elseif resname:find("race-odm-", 1, true) then	
				mapname = mapname:gsub("DM", "ODM")
				sResources["Oldschool"][#sResources["Oldschool"] + 1] = { resname = resname, mapname = mapname }
				table.insert(DM_ODM_MAPS, mapname) -- For training
				table.insert(ODM_MAPS, mapname)
			-- Destruction derby
			elseif resname:find("race-dd-", 1, true) then
				sResources["Destruction Derby"][#sResources["Destruction Derby"] + 1] = { resname = resname, mapname = mapname }
				table.insert(DD_MAPS, mapname)
			-- Shooter maps
			elseif resname:find("race-shooter-", 1, true) then
				sResources["Shooter"][#sResources["Shooter"] + 1] = { resname = resname, mapname = mapname }
				table.insert(SHOOTER_MAPS, mapname)
			-- Hunter maps
			elseif resname:find("race-hunter-", 1, true) then
				sResources["Hunter"][#sResources["Hunter"] + 1] = { resname = resname, mapname = mapname }
				table.insert(HUNTER_MAPS, mapname)
			-- Trials maps
			elseif resname:find("race-trials-", 1, true) then
				sResources["Trials"][#sResources["Trials"] + 1] = { resname = resname, mapname = mapname }
				table.insert(TRIALS_MAPS, mapname)
			-- OJ maps
			elseif resname:find("race-oj-", 1, true) then
				sResources["OJ"][#sResources["OJ"] + 1] = { resname = resname, mapname = mapname }
				table.insert(OJ_MAPS, mapname)
			end
			-- Race maps
			local _, count = resname:gsub("%-", "")
			if count == 1 then
				mapname = "[RACE] " ..mapname
				sResources["Race"][#sResources["Race"] + 1] = { resname = resname, mapname = mapname }
				table.insert(RACE_MAPS, mapname)
			end		
		end
	end
	setElementData(root, "dm.odm.maps", DM_ODM_MAPS) -- For training
	--
	setElementData(root, "Deathmatch.maps", DM_MAPS)
	setElementData(root, "Oldschool.maps", ODM_MAPS)
	setElementData(root, "Destruction Derby.maps", DD_MAPS)
	setElementData(root, "Race.maps", RACE_MAPS)
	setElementData(root, "Trials.maps", TRIALS_MAPS)
	setElementData(root, "Hunter.maps", HUNTER_MAPS)
	setElementData(root, "Shooter.maps", SHOOTER_MAPS)
	setElementData(root, "OJ.maps", OJ_MAPS)
	--
	local str = "[MAP] - "
	for id in pairs(sResources) do
		str = str .. #sResources[id].. " " ..id.. " maps - "
	end
	outputDebugString(str)
end

function loadMapFile(resname)
	local meta = xmlLoadFile("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/meta.xml", true)
	if meta then
		local map = xmlFindChild(meta, "map", 0)
		local tbl = {}
		if map then
			local map = xmlNodeGetAttributes(map)
			if map then
				local mapfile = xmlLoadFile("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/" ..map.src)
				if mapfile then
					-- Load objects
					local idx = 0
					local whattofind = "object"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.objects = {}
					if obj then
						while obj do
							idx = idx + 1
							local modelid = xmlNodeGetAttribute(obj, "model")
							local interior = xmlNodeGetAttribute(obj, "interior")
						--	local dimension = xmlNodeGetAttribute(obj, "dimension")
							local scale = xmlNodeGetAttribute(obj, "scale")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							local doublesided = xmlNodeGetAttribute(obj, "doublesided") == "true" and true or false
							local islowlod = xmlNodeGetAttribute(obj, "collisions") == "false" and true or false
							tbl.objects[#tbl.objects + 1] = { doublesided = doublesided, modelid = tonumber(modelid), interior = tonumber(interior), dimension = nil, islowlod = islowlod, scale = scale, posx = tonumber(posx), posy = tonumber(posy), posz = tonumber(posz), rotx = tonumber(rotx), roty = tonumber(roty), rotz = tonumber(rotz) }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					else
			--			outputDebugString("[MAP] loadMapFile: failed to find '" ..whattofind.. "' child from file '" ..resname.. "/" ..map.src.. "'") 
					end
					-- Remove world objects
					local idx = 0
					local whattofind = "removeWorldObject"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.removeobjects = {}
					if obj then
						while obj do
							idx = idx + 1
							local modelid = xmlNodeGetAttribute(obj, "model")
							local radius = xmlNodeGetAttribute(obj, "radius")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							if collisions == "false" then collisions = true else collisions = false end
							tbl.removeobjects[#tbl.removeobjects + 1] = { modelid = tonumber(modelid), radius = tonumber(radius), posx = tonumber(posx), posy = tonumber(posy), posz = tonumber(posz) }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					else
			--			outputDebugString("[MAP] loadMapFile: failed to find '" ..whattofind.. "' child from file '" ..resname.. "/" ..map.src.. "'") 
					end
					-- Load spawnpoint
					idx = 0
					whattofind = "spawnpoint"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.spawnpoints = {}
					if obj then
						while obj do
							idx = idx + 1
							local modelid = xmlNodeGetAttribute(obj, "vehicle")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							tbl.spawnpoints[#tbl.spawnpoints + 1] = { modelid = modelid, posx = posx, posy = posy, posz = posz, rotx = rotx, roty = roty, rotz = rotz }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					else
						outputDebugString("[MAP] loadMapFile: failed to find '" ..whattofind.. "' child from file '" ..resname.. "/" ..map.src.. "'") 
					end
					-- Load racepickup
					idx = 0
					whattofind = "racepickup"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.pickups = {}
					if obj then
						while obj do
							idx = idx + 1
							local type = xmlNodeGetAttribute(obj, "type")
							local modelid = xmlNodeGetAttribute(obj, "vehicle")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							tbl.pickups[#tbl.pickups + 1] = { type = type, modelid = tonumber(modelid), posx = tonumber(posx), posy = tonumber(posy), posz = tonumber(posz), rotx = tonumber(rotx), roty = tonumber(roty), rotz = tonumber(rotz) }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					else
				--		outputDebugString("[MAP] loadMapFile: failed to find '" ..whattofind.. "' child from file '" ..resname.. "/" ..map.src.. "'") 
					end
					-- Load checkpoints
					idx = 0
					whattofind = "checkpoint"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.checkpoints = {}
					if obj then
						while obj do
							idx = idx + 1
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							tbl.checkpoints[#tbl.checkpoints + 1] = { posx = tonumber(posx), posy = tonumber(posy), posz = tonumber(posz), rotx = tonumber(rotx), roty = tonumber(roty), rotz = tonumber(rotz) }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					end
					-- Load markers
					idx = 0
					whattofind = "marker"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.markers = {}
					if obj then
						while obj do
							idx = idx + 1
							local id = xmlNodeGetAttribute(obj, "id")
							local type = xmlNodeGetAttribute(obj, "type")
							local color = xmlNodeGetAttribute(obj, "color")
							local alpha = xmlNodeGetAttribute(obj, "alpha")
							local size = xmlNodeGetAttribute(obj, "size")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							tbl.markers[#tbl.markers + 1] = { id = id, type = type, color = color, size = tonumber(size), alpha = tonumber(alpha), posx = tonumber(posx), posy = tonumber(posy), posz = tonumber(posz), rotx = tonumber(rotx), roty = tonumber(roty), rotz = tonumber(rotz) }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					end
					-- Load vehicles
					idx = 0
					whattofind = "vehicle"
					local obj = xmlFindChild(mapfile, whattofind, idx)
					tbl.vehicles = {}
					if obj then
						while obj do
							idx = idx + 1
							local modelid = xmlNodeGetAttribute(obj, "model")
							local color = xmlNodeGetAttribute(obj, "paintjob")
							local posx = xmlNodeGetAttribute(obj, "posX")
							local posy = xmlNodeGetAttribute(obj, "posY")
							local posz = xmlNodeGetAttribute(obj, "posZ")
							local rotx = xmlNodeGetAttribute(obj, "rotX")
							local roty = xmlNodeGetAttribute(obj, "rotY")
							local rotz = xmlNodeGetAttribute(obj, "rotZ")
							tbl.vehicles[#tbl.vehicles + 1] = { modelid = modelid, color = color, posx = posx, posy = posy, posz = posz, rotx = rotx, roty = roty, rotz = rotz }
							obj = xmlFindChild(mapfile, whattofind, idx)
						end
					end
					-- Load map scripts
					local scriptssrc = {}
					idx = 0
					local scripts = xmlFindChild(meta, "script", idx)
					tbl.sscripts = {}
					tbl.cscripts = {}
					if scripts then
						while scripts do
							idx = idx + 1
							local scriptsrc = xmlNodeGetAttribute(scripts, "src")
							local tp = xmlNodeGetAttribute(scripts, "type")
							scriptssrc[#scriptssrc + 1] = { src = scriptsrc, tp = tp }
							scripts = xmlFindChild(meta, "script", idx)
						end
						tbl.sscripts, tbl.cscripts = getMapScriptsRAWData(resname, tp, scriptssrc)
					end
					-- Load map file extensions
					local filessrc = {}
					idx = 0
					local files = xmlFindChild(meta, "file", idx)
					tbl.files = {}
					if files then
						while files do
							idx = idx + 1
							local filesrc = xmlNodeGetAttribute(files, "src")
							for i = 1, #fileExtensionsToLoad do
								if filesrc:find(fileExtensionsToLoad[i], 1, true) then
									filessrc[#filessrc + 1] = filesrc
									break
								end
							end
							files = xmlFindChild(meta, "file", idx)
						end
						tbl.files = getMapFilesRAWData(resname, filessrc)
					end
					xmlUnloadFile(mapfile)
				else
					outputDebugString("[MAP] loadMapFile: failed to open xml file '" ..resname.. "/" ..map.src.. "'", 1) 
				end
			else	
				outputDebugString("[MAP] loadMapFile: failed to find 'src' child from '" ..resname.. "'", 1)  
			end
		else
			outputDebugString("[MAP] loadMapFile: failed to find 'map' child from '" ..resname.. "'", 1)  
		end
		xmlUnloadFile(meta) -- Unload the file
		return tbl
	else
		outputDebugString("[MAP] loadMapFile: failed to open xml file '" ..resname.. "'", 1) 
	end
end

function getMapFilesRAWData(resname, files)
	local filedata = {}
	for i = 1, #files do
		local file = fileOpen("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/" ..files[i])
		if file then
			local ismusic = (files[i]:find(".mp3") or files[i]:find(".ogg")) and true or false
			local count = fileGetSize(file)
			local data = fileRead(file, count)
			filedata[i] = { data = data, filesrc = files[i], md5 = not ismusic and hash("md5", data) }
			fileClose(file)
		else
			outputDebugString("[MAP] getMapFilesRAWData: couldn't load file '" ..files[i].. "' for resource '" ..resname.. "'")
		end
	end
	return filedata
end

function getMapScriptsRAWData(resname, tp, scripts)
	sScripts = {}
	cScripts = {}
	for i = 1, #scripts do
		if scripts[i].tp == "client" then
			local src = scripts[i].src
			if not ignoreFile(src) then
				local file = fileOpen("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/" ..src)
				if file then
					local count = fileGetSize(file) 
					local data = fileRead(file, count)
					cScripts[#cScripts + 1] = { data = data, src = src }
					fileClose(file)
				else 
					outputDebugString("[MAP] getMapScriptsRAWData: failed to open '" ..resname.. "/" ..src.. "'")
				end
			end
		elseif scripts[i].tp == "server" then
			local src = scripts[i].src
			if not ignoreFile(src) then
				local file = fileOpen("maps/" ..getResourceCategory(resname).. "/" ..resname.. "/" ..src)
				if file then
					local count = fileGetSize(file) 
					local data = fileRead(file, count)
					sScripts[#sScripts + 1] = { data = data, src = src }
					fileClose(file)
				else 
					outputDebugString("[MAP] getMapScriptsRAWData: failed to open '" ..resname.. "/" ..src.. "'")
				end
			end
		end
	end
--	outputDebugString("[LOADSCRIPT] getMapScriptsRAWData: loaded " ..#cScripts.. " client scripts for resource '" ..resname.. "'")
--	outputDebugString("[LOADSCRIPT] getMapScriptsRAWData: loaded " ..#sScripts.. " server scripts for resource '" ..resname.. "'")
	return sScripts, cScripts
end

function ignoreFile(src)
	for i = 1, #ignoredScripts do
		if src == ignoredScripts[i] then
			return true
		end
	end
	return false
end

function getCleanType(tp)
	return tp:gsub(" A", ""):gsub(" B", "")
end

function getMapCost()
	return getElementData(root, "map.cost")
end