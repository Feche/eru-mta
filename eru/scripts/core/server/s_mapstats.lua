local currentMapAccounts = {}

addEvent("panel:onPlayerRequestMapInfo", true)

addEvent("race:onRaceMapStarting")
addEvent("race:onRaceMapStop")

addEventHandler("onResourceStart", resourceRoot,
	function()
		dbExec(db, "CREATE TABLE IF NOT EXISTS mapstats (resname TINYTEXT, timesplayed INTEGER, likes INTEGER, dislikes INTEGER, accounts TEXT)")
		addCommandHandler("l", addMapLike)
		addCommandHandler("like", addMapLike)
		addCommandHandler("dl", addMapDislike)
		addCommandHandler("dislike", addMapDislike)
	end
)

addEventHandler("race:onRaceMapStarting", root,
	function(tp, resname)
		currentMapAccounts = {}
		local qr = dbQuery(db, "SELECT accounts FROM mapstats WHERE resname = ?", resname)
		local result = dbPoll(qr, -1)
		if result[1] then
			currentMapAccounts = fromJSON(result[1].accounts)
			-- Add play count
			dbExec(db, "UPDATE mapstats SET timesplayed = timesplayed + 1 WHERE resname = ?", resname)
		else
			dbExec(db, "INSERT INTO mapstats VALUES (?, 1, 0, 0, '[[]]')", resname)
		end
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp, resname)
		dbExec(db, "UPDATE mapstats SET accounts = ? WHERE resname = ?", toJSON(currentMapAccounts), resname)
	end
)

addEventHandler("panel:onPlayerRequestMapInfo", root,
	function(mapname)
		local resname = getResourceNameFromMapname(mapname)
		if resname then
			triggerClientEvent(source, "panel:onReceiveMapInfo", source, { mapinfo = getMapInfo(resname), maptoptimes = getMapToptimes(resname) })
		end
	end
)

function addMapLike(source)
	local tp = getPlayerGamemode(source)
	local resname = getGamemodeResourceName(tp)
	local didvote = playerAlreadyLikesDislikesMap(source)
	if didvote then 
		if didvote == "dislike" then
			dbExec(db, "UPDATE mapstats SET likes = likes + 1, dislikes = dislikes - 1 WHERE resname = ?", resname)
			currentMapAccounts[getPlayerAccount(source)] = "like"
			outputChatBox("Now you like this map!", source, 0, 255, 0)
		else
			outputChatBox("You already like this map", source, 255, 255, 0)
		end
	else
		dbExec(db, "UPDATE mapstats SET likes = likes + 1 WHERE resname = ?", resname)
		currentMapAccounts[getPlayerAccount(source)] = "like"
		outputChatBox("You gave this map a like!", source, 0, 255, 0)
	end
end

function addMapDislike(source)
	local tp = getPlayerGamemode(source)
	local resname = getGamemodeResourceName(tp)
	local didvote = playerAlreadyLikesDislikesMap(source)
	if didvote then 
		if didvote == "like" then
			dbExec(db, "UPDATE mapstats SET likes = likes - 1, dislikes = dislikes + 1 WHERE resname = ?", resname)
			currentMapAccounts[getPlayerAccount(source)] = "dislike"
			outputChatBox("Now you dislike this map", source, 255, 255, 0)
		else
			outputChatBox("You already dislike this map", source, 255, 255, 0)
		end
	else
		dbExec(db, "UPDATE mapstats SET dislikes = dislikes + 1 WHERE resname = ?", resname)
		currentMapAccounts[getPlayerAccount(source)] = "dislike"
		outputChatBox("You gave this map a dislike", source, 255, 255, 0)
	end
end

function playerAlreadyLikesDislikesMap(source)
	return currentMapAccounts[getPlayerAccount(source)] or false
end

function getMapInfo(resname)
	local qr = dbQuery(db, "SELECT likes, dislikes, timesplayed FROM mapstats WHERE resname = ?", resname)
	local result = dbPoll(qr, -1)
	if result[1] then
		return { likes = result[1].likes, dislikes = result[1].dislikes, timesplayed = result[1].timesplayed }
	else
		return { likes = 0, dislikes = 0, timesplayed = 0 }
	end
end