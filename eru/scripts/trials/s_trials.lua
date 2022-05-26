local tRank = {}

addEvent("trials:managePlayerRank", true)
addEvent("lobby:onPlayerJoinLobby", true)

addEvent("race:onRaceMapStart")
addEvent("lobby:onPlayerJoinGamemode")

local function getPlayerRank(source, checkpoints)
	if #tRank == 0 then
		table.insert(tRank, { source, checkpoints })
		return 1
	else
		-- Remove old player rank
		for i = 1, #tRank do
			if tRank[i][1] == source then
				table.remove(tRank, i)
				break
			end
		end
		--
		for i = 1, #tRank do
			if tRank[i][2] < checkpoints then
				table.insert(tRank, i, { source, checkpoints })
				return i
			end
		end
		-- Insert on last position if no rank found
		table.insert(tRank, { source, checkpoints })
		return #tRank
	end
end

local function updatePlayersRank()
	-- Remove disconnected players or not in trials
	for i in pairs(tRank) do
		if not isElement(tRank[i][1]) or getElementDimension(tRank[i][1]) ~= 11 then
			table.remove(tRank, i)
		end
	end
	-- Update players position
	for i = 1, #tRank do
		triggerClientEvent(tRank[i][1], "trials:updatePlayerRank", tRank[i][1], i)
	end
end

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Trials" then
			tRank = {}
			local players = getGamemodePlayers(tp)
			for i = 1, #players do
				table.insert(tRank, { players[i], 0 })
			end
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		local tp = getPlayerGamemode(source)
		if tp == "Trials" then
			setTimer(updatePlayersRank, 100, 1) -- Allow dimension to be changed when joining lobby
		end		
	end
, true, "high")

addEventHandler("lobby:onPlayerJoinGamemode", root,
	function()
	
	end
)

addEventHandler("trials:managePlayerRank", root,
	function(checkpoints)
		getPlayerRank(source, checkpoints)
		updatePlayersRank()
	end
)