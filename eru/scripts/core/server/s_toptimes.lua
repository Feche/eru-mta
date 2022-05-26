local mapTTs = {}

addEvent("race:onRaceMapStarting")
addEvent("race:onRaceMapStop")
addEvent("race:onPlayerReachHunter")

addEvent("toptimes:onPlayerRequestMapToptimes", true)

addEventHandler("onResourceStart", resourceRoot,
	function()
		dbExec(db, "CREATE TABLE IF NOT EXISTS maptoptimes (resname TINYTEXT, toptimes LONGTEXT)")
	end
)

addEventHandler("race:onRaceMapStarting", root,
	function(tp, resname)
		if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" then
			loadMapTTs(resname)
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" then
			local resname = getGamemodeResourceName(tp)
			saveMapTopTimes(resname)
			mapTTs[resname] = nil
		end
	end
)

addEventHandler("race:onPlayerReachHunter", root,
	function(tp)
		if tp:find("Deathmatch") or tp:find("Oldschool") or tp == "Race" then
			local state = getPlayerState(source)
			if state == "alive" then
				local pStats = getPlayerStats(source)
				local resname = getGamemodeResourceName(tp)
				local timepassed = getRaceTimePassed(tp)
				local pos = getTimePosition(resname, timepassed)
				local name = getPlayerName(source)--pStats.name
				updatePlayerToptime(source, tp, resname, pos, timepassed, pStats.account, name, FormatDate("d/m/Y"))
			end
		end
	end
, true, "high")

addEventHandler("toptimes:onPlayerRequestMapToptimes", root,
	function()
		local tp = getPlayerGamemode(source)
		local resname = getGamemodeResourceName(tp)
		local mapname = gServerGamemodes[tp].mapname
		triggerClientEvent(source, "toptimes:onServerSendToptimes", source, mapTTs[resname], mapname)
	end
)

function updatePlayerToptime(source, tp, resname, pos, timepassed, account, name, date, isracett)
	if mapTTs[resname] then
		for i = 1, #mapTTs[resname] do -- Find if player has a toptime already made
			if mapTTs[resname][i].account == account then -- If he has, check if he improved or not his toptime
				if mapTTs[resname][i].timepassed > timepassed then -- Toptime improved
					local timestr = msToTimeStr(timepassed)
					outputChatBoxToGamemode("#FFFF00" ..getPlayerNameNoColor(source).. " has improved his toptime [#" ..pos.. "] time: " ..timestr.. ", difference: -" ..msToTimeStr(mapTTs[resname][i].timepassed - timepassed), tp)
					table.remove(mapTTs[resname], i) -- Remove old player toptime
					table.insert(mapTTs[resname], pos, { timepassed = timepassed, timestr = timestr, account = account, name = name, date = date }) -- Insert new toptime
					triggerClientEventForGamemode(root, tp, "toptimes:onServerSendToptimes", mapTTs[resname], gServerGamemodes[tp].mapname)
					return
				else -- He didn't improve his old tt
					return
				end
			end
		end 
	end -- Checking is done, no tt found
	-- Player does not have a toptime, insert new toptime
	local timestr = msToTimeStr(timepassed)
	table.insert(mapTTs[resname], pos, { timepassed = timepassed, timestr = timestr, account = account, name = name, date = date }) -- Insert new toptime
	triggerClientEventForGamemode(root, tp, "toptimes:onServerSendToptimes", mapTTs[resname], gServerGamemodes[tp].mapname) -- Update tts to client
	if 10 >= pos then -- Show notification if it is on top10
		outputChatBoxToGamemode("#FFFF00" ..getPlayerNameNoColor(source).. " got a new toptime [#" ..pos.. "] time: " ..timestr, tp)
		if pos == 1 then -- First time getting toptime #1
			addPlayerTopOne(source)
		end
	else -- Player toptime not in top10
		outputChatBox("You've got a new toptime [#" ..pos.. "] time: " ..timestr, source, 255, 255, 0)
	end
end

function loadMapTTs(resname)
	local qr = dbQuery(db, "SELECT toptimes FROM maptoptimes WHERE resname = '" ..resname.. "'")
	local result = dbPoll(qr, -1)
	if result[1] then
		local maptt = result[1]
		mapTTs[resname] = fromJSON(maptt.toptimes)
		outputDebugString("[TOPTIMES] Loaded map toptimes for resource " ..resname)
	else
		mapTTs[resname] = {}
		dbExec(db, "INSERT INTO maptoptimes VALUES (?, ?)", resname, "[[]]")
		outputDebugString("[TOPTIMES] Resource " ..resname.. " doesn't have any toptimes")
	end
end

function getMapToptimes(resname)
	local qr = dbQuery(db, "SELECT toptimes FROM maptoptimes WHERE resname = '" ..resname.. "'")
	local result = dbPoll(qr, -1)
	if result[1] then
		return fromJSON(result[1].toptimes)
	end
end

addCommandHandler("deletett",
	function(source, _, pos)
		if canExecuteCmd(source, 4) then
			if not pos then
				return outputChatBox("Usage: deletett [pos]", source, 255, 255, 255)
			end
			local tp = getPlayerGamemode(source)
			local resname = getGamemodeResourceName(tp)
			pos = tonumber(pos)
			if not mapTTs[resname] or not mapTTs[resname][pos] then
				outputChatBox("Toptime position #" ..pos.. " doesn't exist.", source, 255, 0, 0)
			else
				outputChatBoxToGamemode("#FFFF00* Toptime [#" ..pos.. "] from " ..mapTTs[resname][pos].name:gsub("#%x%x%x%x%x%x", "").. " has been deleted by " ..getPlayerNameNoColor(source), tp)
				table.remove(mapTTs[resname], pos)
				triggerClientEventForGamemode(root, tp, "toptimes:onServerSendToptimes", mapTTs[resname], gServerGamemodes[tp].mapname)
				saveMapTopTimes(resname)
			end
		end
	end
)

addCommandHandler("renamett",
	function(source, _, pos, newname)
		if canExecuteCmd(source, 4) then
			if not pos or not newname then
				return outputChatBox("Usage: renamett [pos] [newname]", source, 255, 255, 255)
			end
			local tp = getPlayerGamemode(source)
			local resname = getGamemodeResourceName(tp)
			pos = tonumber(pos)
			if not mapTTs[resname] or not mapTTs[resname][pos] then
				outputChatBox("Toptime position #" ..pos.. " doesn't exist.", source, 255, 0, 0)
			else
				outputChatBoxToGamemode("#FFFF00* " ..getPlayerNameNoColor(source).. " renamed toptime [#" ..pos.. "] from " ..mapTTs[resname][pos].name:gsub("#%x%x%x%x%x%x", "").. " to " ..newname, tp)
				mapTTs[resname][pos].name = newname
				triggerClientEventForGamemode(root, tp, "toptimes:onServerSendToptimes", mapTTs[resname], gServerGamemodes[tp].mapname)
				saveMapTopTimes(resname)
			end
		end
	end
)

function saveMapTopTimes(resname)
	if not mapTTs[resname] then return end
	dbExec(db, "UPDATE maptoptimes SET toptimes = ? WHERE resname = ?", toJSON(mapTTs[resname]), resname)
	outputDebugString("[TOPTIMES] Saved toptimes for resource " ..resname)
end

function getTimePosition(resname, timepassed)
	if not mapTTs[resname] then return end
	for i = 1, #mapTTs[resname] do
		if mapTTs[resname][i].timepassed >= timepassed then
			return i
		end
	end
	return #mapTTs[resname] + 1
end

function msToTimeStr(timeMs)
	local minutes = math.floor(timeMs / 60000)
	timeMs = timeMs - minutes * 60000
	local seconds = math.floor(timeMs / 1000)
	timeMs = timeMs - seconds * 1000
	local miliseconds = math.floor(timeMs / 10)
	if seconds < 10 then
		seconds = "0" ..seconds
	end
	if miliseconds < 10 then
		miliseconds = "0" ..miliseconds
	end
	return minutes.. ":" ..seconds.. ":" ..miliseconds
end