local gTeams = {}

local gInvite = {}

addEvent("panel:onPlayerRequestCreateClan", true)
addEvent("panel:onPlayerRequestClanInfo", true)
addEvent("panel:onPlayerRequestClanLeave", true)
addEvent("panel:onPlayerRequestServerClans", true)
addEvent("panel:onPlayerRequestRemoveMember", true)
addEvent("panel:onPlayerRequestClanInfoManage", true)
addEvent("panel:onPlayerRequestClanModify", true)

addEventHandler("onResourceStart", resourceRoot,
	function()
		dbExec(db, "CREATE TABLE IF NOT EXISTS clans (name TINYTEXT, tag TINYTEXT, color TINYTEXT, date TINYTEXT, description TINYTEXT, points INTEGER, cwpoints INTEGER, cash INTEGER, members TEXT)")
		local qr = dbQuery(db, "SELECT name, color, members FROM clans")
		local result = dbPoll(qr, -1)
		if result then
			local c = 0
			for i = 1, #result do
				local name = result[i].name
				gTeams[name] = createTeam(name, hex2rgb(result[i].color))
				c = c + 1
			end
			outputDebugString("[CLANS] Loaded " ..c.. " clans")
		end
		team = createTeam("Players", 255, 255, 255)
		eru = createTeam("-|ERU|*", 128, 128, 128)
		--
		local players = getElementsByType("player")
		for i = 1, #players do
			setPlayerTeam(players[i], team)
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		setPlayerTeam(source, team)
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		gInvite[source] = nil
	end
)

addEventHandler("panel:onPlayerRequestCreateClan", root,
	function(name, tag, color, description)
		-- Check if name already exists
		local qr = dbQuery(db, "SELECT name FROM clans WHERE name = ?", name)
		local result = dbPoll(qr, -1)
		if result[1] then
			showNotificationToPlayer(source, "A clan with that name already exists", "error")
			return
		end
		-- Check if tag already exists
		qr = dbQuery(db, "SELECT tag FROM clans WHERE tag = ?", tag)
		result = dbPoll(qr, -1)
		if result[1] then
			showNotificationToPlayer(source, "A clan with that tag already exists", "error")
			return
		end
		-- All good
		local account = getPlayerAccount(source)
		local team = createTeam(name, hex2rgb(color))
		dbExec(db, "INSERT INTO clans VALUES (?, ?, ?, ?, ?, 0, 0, 0, ?)", name, tag, color, FormatDate("d/m/Y"), description, "[[]]")
		gTeams[name] = team
		addMemberToClan(source, name, "owner")
		givePlayerMoney(source, -1500000)
		showNotificationToPlayer(source, "Clan succesfully created", "info")
	end
)

addEventHandler("panel:onPlayerRequestClanInfo", root,
	function(clanname)
		local qr = dbQuery(db, "SELECT * FROM clans WHERE name = ?", clanname)
		local result = dbPoll(qr, -1)
		if result[1] then
			local members = fromJSON(result[1].members)
			local accountowner, owner = findClanOwner(members)
			triggerClientEvent(source, "panel:onReceiveClanInfo", source, result[1], accountowner, owner, getClanMembersForPanel(members, result[1].color))
		else
			showNotificationToPlayer(source, "There was an error while trying to get clan info (" ..clanname.. "#ffffff)", "error")
		end
	end
)

addEventHandler("panel:onPlayerRequestClanLeave", root,
	function()
		local pStats = getPlayerStats(source)
		local clanname = pStats.player.clan
		pStats.player.clan = "none"
		setElementData(source, "stats", pStats)
		-- Remove member
		local qr = dbQuery(db, "SELECT members FROM clans WHERE name = ?", clanname)
		local result = dbPoll(qr, -1)
		if result[1] then
			local members = fromJSON(result[1].members)
			for i = 1, #members do
				if members[i].account == pStats.account then
					table.remove(members, i)
					break
				end
			end
			dbExec(db, "UPDATE clans SET members = ? WHERE name = ?", toJSON(members), clanname)
		end
		setPlayerTeam(source, team)
		showNotificationToPlayer(source, "You left the clan", "warning")
	end
)

addEventHandler("panel:onPlayerRequestServerClans", root,
	function()
		triggerClientEvent(source, "panel:onReceiveServerClans", source, gTeams)
	end
)

addEventHandler("panel:onPlayerRequestRemoveMember", root,
	function(name)
		local account = getAccountFromName(name)
		if account == getPlayerAccount(source) then
			return showNotificationToPlayer(source, "Clan owner can't be removed", "error")
		end
		if account then
			dbExec(db, "UPDATE players SET clan = 'none' WHERE account = ?", account)
			local target = getPlayerFromAccount(account)
			if target then
				local pStats = getPlayerStats(target)
				pStats.player.clan = "none"
				setElementData(target, "stats", pStats)
				setPlayerTeam(target, team)
				outputChatBox("You had been removed from your clan", target, 255, 255, 0)
			end
			--
			local clanname = getPlayerStats(source).player.clan
			local qr = dbQuery(db, "SELECT members FROM clans WHERE name = ?", clanname)
			local result = dbPoll(qr, -1)
			if result[1] then
				local members = fromJSON(result[1].members)
				for i = 1, #members do
					if members[i].account == account then
						table.remove(members, i)
						break
					end
				end	
				dbExec(db, "UPDATE clans SET members = ? WHERE name = ?", toJSON(members), clanname)
			end
			showNotificationToPlayer(source, "Player " ..name.. " removed from clan", "warning")
		end
	end
)

addEventHandler("panel:onPlayerRequestClanInfoManage", root,
	function()
		local clanname = getPlayerStats(source).player.clan
		local qr = dbQuery(db, "SELECT tag, description, color FROM clans WHERE name = ?", clanname)
		local result = dbPoll(qr, -1)
		if result[1] then
			triggerClientEvent(source, "panel:onReceiveClanInfoManage", source, result[1], clanname)
		end
	end
)

addEventHandler("panel:onPlayerRequestClanModify", root,
	function(name, tag, color, clandescription)
		local oldclanname = getPlayerStats(source).player.clan
		dbExec(db, "UPDATE clans SET name = ?, tag = ?, color = ?, description = ? WHERE name = ?", name, tag, color, clandescription, oldclanname)
		for clanname in pairs(gTeams) do
			if clanname == oldclanname and clanname ~= name then
				gTeams[name] = createTeam(name, hex2rgb(color))
				local players = getPlayersInTeam(gTeams[clanname])
				for i = 1, #players do
					local pStats = getPlayerStats(players[i])
					pStats.player.clan = name
					setElementData(players[i], "stats", pStats)
					setPlayerTeam(players[i], gTeams[name])
				end
				destroyElement(gTeams[clanname]) -- Destroy team
				gTeams[clanname] = nil
				break
			end
		end
		givePlayerMoney(source, -250000)
		showNotificationToPlayer(source, "Changes were succesfully saved", "info")
	end
)

addCommandHandler("invite",
	function(source, cmd, name)
		if not name then
			outputChatBox("Usage: invite [name]", source, 255, 255, 255)
		else
			local target = getPlayerFromPartialName(name)
			if target then
				if target == source then 
					outputChatBox("You cannot invite yourself.", source, 255, 0, 0)
					return 
				end
				if canUseCmd(source, cmd) and isClanOwner(source) then
					if getPlayerStats(target).player.clan == "none" then
						gInvite[target] = { getPlayerStats(source).player.clan, source }
						outputChatBox("* " ..getPlayerNameNoColor(source).. " is inviting you to join his clan " ..gInvite[target][1].. ", use /join to accept the invitation", target, 255, 255, 0)
						outputChatBox("Invitation sent to " ..getPlayerNameNoColor(target), source, 255, 255, 0)
					else
						outputChatBox("The player is already on another clan.", source, 255, 0, 0)
					end
				end
			else
				outputChatBox("Invalid player.", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("join",
	function(source, cmd)
		if canUseCmd(source, cmd) then
			if gInvite[source] then
				addMemberToClan(source, gInvite[source][1], "member")
				outputChatBox("* " ..getPlayerNameNoColor(source).. " has accepted your clan invitation", gInvite[source][2], 0, 255, 0)
				outputChatBox("You have succesfully joined clan " ..gInvite[source][1], source, 0, 255, 0)
				gInvite[source] = nil
			else
				outputChatBox("You don't have any clan invitation.", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("deleteclan",
	function(source, cmd)
		if canUseCmd(source, cmd) then
			if isClanOwner(source) then
				local pStats = getPlayerStats(source)
				local clanname = pStats.player.clan
				local players = getPlayersInTeam(gTeams[clanname])
				for i = 1, #players do
					local stats = getPlayerStats(players[i])
					stats.player.clan = "none"
					setElementData(players[i], "stats", stats)
					setPlayerTeam(players[i], team)
					outputChatBox("Your clan has been deleted", players[i], 255, 255, 0)
				end
				destroyElement(gTeams[clanname])
				gTeams[clanname] = nil
				dbExec(db, "DELETE FROM clans WHERE name = ?", clanname)
			end
		end
	end
)

function addMemberToClan(source, clan, rank)
	local pStats = getPlayerStats(source)
	local members = getTeamMembers(clan)
	members[#members + 1] = { account = pStats.account, rank = rank }
	pStats.player.clan = clan
	setElementData(source, "stats", pStats)
	setPlayerTeam(source, gTeams[clan])
	dbExec(db, "UPDATE clans SET members = ? WHERE name = ?", toJSON(members), clan)
end

function setPlayerClan(source)
	local pStats = getPlayerStats(source)
	if pStats.player.clan ~= "none" then
		local team = getTeamFromClanName(pStats.player.clan)
		if not team then
			pStats.player.clan = "none"
			setElementData(source, "stats", pStats)
			outputChatBox("Your clan has been deleted", source, 255, 255, 0)
		else
			setPlayerTeam(source, team)
		end
	end
end

function getTeamFromClanName(name)
	if gTeams[name] then
		return gTeams[name]
	end
	return false
end

function getTeamMembers(name)
	local qr = dbQuery(db, "SELECT members FROM clans WHERE name = ?", name)
	local result = dbPoll(qr, -1)
	if result[1] then
		return fromJSON(result[1].members)
	end
	return false
end

function findClanOwner(members)
	for i = 1, #members do
		if members[i].rank == "owner" then
			return members[i].account, getNameFromAccount(members[i].account)
		end
	end
	return "?"
end

function isClanOwner(source)
	local pStats = getPlayerStats(source)
	local clanname = pStats.player.clan
	if clanname ~= "none" then
		local qr = dbQuery(db, "SELECT members FROM clans WHERE name = ?", clanname)
		local result = dbPoll(qr, -1)
		if result[1] then
			local members = fromJSON(result[1].members)
			for i = 1, #members do
				if members[i].account == pStats.account and members[i].rank == "owner" then
					return true
				end
			end
		end
	end
	return false
end

function getClanMembersForPanel(members, color)
	local tbl = {}
	for i = 1, #members do
		tbl[i] = color.. "" ..getNameFromAccount(members[i].account)
	end
	return tbl
end

function hex2rgb(hex) 
  hex = hex:gsub("#","") 
  return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)) 
end 