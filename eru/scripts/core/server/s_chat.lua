local antiSpam = {}

randomNames = 
{
	"RandomDude",
	"RandomGuy",
	"RandomName",
	"ChangeMe"
}

local rePlayer = {}

addEventHandler("onPlayerChat", root,
	function(msg, msgtp)
		cancelEvent()
		if not getPlayerStats(source) then return end
		if not checkAntispam(source, msg) then return end
		msg = msg:gsub("vv", "w")
		if msgtp == 0 then
			local tp = getPlayerGamemode(source)
			outputChatBoxToGamemode(getPlayerName(source).. "#ffffff: " ..msg, tp)
		elseif msgtp == 2 then
			local pteam = getPlayerTeam(source)
			if pteam ~= team then
				local players = getPlayersInTeam(pteam)
				for i = 1, #players do
					outputChatBox("[TEAM] " ..getPlayerName(source).. "#ffffff: " ..msg, players[i], 255, 255, 255, true)
				end
			end
		end
	end
)

addEventHandler("onConsole", root,
	function(msg)
		if msg:find("Global", 1, true) then
			msg = msg:gsub("Global", "")
			outputChatBox("[GLOBAL] " ..getPlayerName(source).. "#e7d9b0:" ..msg, root, 255, 255, 255, true)
		end
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		rePlayer[source] = nil
		antiSpam[source] = nil
	end
)

addCommandHandler("setnick",
	function(source, cmd, nick)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if not nick then
			outputChatBox("Usage: setnick [nick]", source, 255, 255, 255)
		else
			if canUseCmd(source, cmd) then
				local newnicknocolor = nick:gsub("#%x%x%x%x%x%x", "")
				for i = 1, #randomNames do
					if newnicknocolor:lower():find(randomNames[i]:lower()) then
						outputChatBox("The nickname is invalid", source, 255, 0, 0)
						return
					end
				end
				local newnick = nick
				local inuse, account = isNickInUse(newnick)
				if inuse then
					if account ~= pStats.account then
						outputChatBox("A player with that nick already exists.", source, 255, 0, 0)
					else
						setPlayerNick(source, newnick)
					end
				else
					setPlayerNick(source, newnick)
				end
			end
		end
	end
)

addCommandHandler("pm",
	function(source, _, to, ...)
		if not to or not ... then
			outputChatBox("Usage: pm [to] [msg]", source, 255, 255, 255)
		else
			local target = getPlayerFromPartialName(to)
			if target then
				local msg = table.concat({ ... }, " ")
				if target == source then
					outputChatBox("You can't PM to yourself", source, 255, 0, 0)
					return
				end
				outputChatBox("PM from " ..getPlayerName(source).. "#ffffff: " ..msg, target, 102, 255, 0, true)
				if not isElement(rePlayer[target]) then
					outputChatBox("You can reply back using /re", target, 102, 255, 0)
				end
				outputChatBox("PM to " ..getPlayerName(target).. "#ffffff: " ..msg, source, 102, 255, 0, true)
				rePlayer[target] = source
			else
				outputChatBox("Invalid player", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("re", 
	function(source, _, ...)
		if not ... then
			outputChatBox("Usage: re [msg]", source, 255, 255, 255)
		else
			if not isElement(rePlayer[source]) then
				outputChatBox("Invalid player", source, 255, 0, 0)
			else
				local msg = table.concat({ ... }, " ")
				local target = rePlayer[source]
				outputChatBox("PM from " ..getPlayerName(source).. "#ffffff: " ..msg, target, 102, 255, 0, true)
				if not isElement(rePlayer[target]) then
					outputChatBox("You can reply back using /re", target, 102, 255, 0)
				end
				outputChatBox("PM to " ..getPlayerName(target).. "#ffffff: " ..msg, source, 102, 255, 0, true)
				rePlayer[target] = source
			end
		end
	end
)

function checkAntispam(source, msg)
	local tick = getTickCount()
	if (antiSpam[source] and antiSpam[source].lastmsg or "") == msg then
		if tick - (antiSpam[source] and antiSpam[source].tick or 0) >= 5000 then
			antiSpam[source] = { tick = getTickCount(), lastmsg = msg }
			return true
		else
			outputChatBox("Don't flood the chat!", source, 255, 0, 0)
			return false
		end
	end
	antiSpam[source] = { tick = getTickCount(), lastmsg = msg }
	return true
end

function setPlayerNick(source, newnick, output)
	local pStats = getPlayerStats(source)
	local newnicknocolor = newnick:gsub("#%x%x%x%x%x%x", "")
	if output == nil then
		outputChatBoxToGamemode("#ff6464* " ..getPlayerName(source).. " #ff6464is now known as " ..RGBToHex(getTeamColor(getPlayerTeam(source))).. "" ..newnick, getPlayerGamemode(source))
	end
	dbExec(db, "UPDATE players SET name = ?, namenocolor = ? WHERE account = ?", newnick, newnicknocolor, pStats.account)
	pStats.player.name = newnick
	setElementData(source, "stats", pStats)
	setElementData(source, "playername", newnick)
end

function isNickInUse(name)
	local newnicknocolor = name:gsub("#%x%x%x%x%x%x", "")
	local qr = dbQuery(db, "SELECT namenocolor, account FROM players WHERE namenocolor = ?", newnicknocolor)
	local result = dbPoll(qr, -1)
	if result[1] then
		if result[1].namenocolor == newnicknocolor then
			return true, result[1].account
		else
			return false
		end
	end
	return false
end