local _DEBUG = true

local weHaveWinner = false
local pPos = {}
local totalchecks = 0
local ranks = {}

addEvent("race:checkForWinner", true)
addEvent("race:onPlayerHitCheckpoint", true)

addEvent("race:onRaceMapStart")
addEvent("lobby:onPlayerJoinLobby", true)

local function getPlayerRank(source)
	local rank = {}
	local players = getGamemodePlayers("Race")
	for i = 1, #players do
		rank[players[i]] = pPos[players[i]]
	end
	--
	local tbl = {}
	for player, pos in spairs(rank, function(t,a,b) return t[b] > t[a] end) do
		tbl[#tbl + 1] = player
	end
	--
	local rank = "?"
	for i = 1, #tbl do
		if tbl[i] == source then
			rank = i
			break
		end
	end
	if ranks[rank] then
		rank = rank + 1
	end
	return rank
end

addEventHandler("onPlayerQuit", root,
	function()
		local tp = getPlayerGamemode(source)
		if tp == "Race" then
			pPos[source] = nil
			updatePlayersRankingPosition()
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		local tp = getPlayerGamemode(source)
		if tp == "Race" then
			pPos[source] = nil
			updatePlayersRankingPosition()
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Race" then
			weHaveWinner = false
			pPos = {}
			ranks = {}
			totalchecks = getRaceCheckpoints()
			--
			local players = getGamemodePlayers("Race")
			for i = 1, #players do
				pPos[players[i]] = totalchecks
			end
			updatePlayersRankingPosition()
		end
	end
)

addEventHandler("lobby:onClientClickLobbyGamemode", root,
	function(tp)
		if tp == "Race" then
			pPos[source] = totalchecks
		end
	end
)

addEventHandler("race:onPlayerHitCheckpoint", root,
	function()
		if getPlayerState(source) == "alive" then
			pPos[source] = pPos[source] - 1
			updatePlayersRankingPosition()
		end
	end
)

addEventHandler("race:checkForWinner", root,
	function()
		if getPlayerState(source) == "alive" then
			if not weHaveWinner then
				weHaveWinner = true
				triggerEvent("race:onPlayerWin", source, "Race")
				triggerClientEventForGamemode(root, "Race", "race:onPlayerWin", source, getPlayerName(source))
				setGamemodeTimeLeft(0.5, "Race")
				showNotificationToGamemode("30 seconds left", "Race", "warning")
			end
			local rank = getPlayerRank(source)
			if not ranks[rank] then
				ranks[rank] = true
			else
				rank = rank + 1
				ranks[rank] = true
			end
			triggerEvent("race:onPlayerReachHunter", source, "Race")
		end
	end
)

function updatePlayersRankingPosition()
	local tick = getTickCount()
	local players = getGamemodePlayers("Race")
	for i = 1, #players do
		local rank = getPlayerRank(players[i])
		setElementData(players[i], "rank", rank)
	end
	if _DEBUG then
		outputDebugString("[RACE] updatePlayersRankingPosition took " ..(getTickCount() - tick).. " ms")
	end
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end