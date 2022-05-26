local gIDs = {}

addEventHandler("onResourceStart", resourceRoot,
	function()
	local players = getElementsByType("player")
		for i = 1, #players do
			setPlayerID(players[i])
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		setPlayerID(source)
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		removePlayerID(source)
	end
)

function setPlayerID(source)
	local ididx = 1
	while true do
		if not gIDs[ididx] then
			gIDs[ididx] = source
			setElementData(source, "id", ididx)
			return
		end
		ididx = ididx + 1
	end
end

function getPlayerID(source)
	for id, player in pairs(gIDs) do
		if player == source then
			return id
		end
	end
	return -1
end

function removePlayerID(source)
	for id, player in pairs(gIDs) do
		if player == source then
			gIDs[id] = nil
			return
		end
	end
end