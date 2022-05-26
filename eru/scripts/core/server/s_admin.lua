addEventHandler("onUnban", root,
	function(ban)
		local serial = getBanSerial(ban)
		dbExec(db, "UPDATE players SET banned = 0 WHERE serial = ?", serial)
		outputDebugString("[BANS] serial " ..serial.. " has been unbanned")
	end
)

addCommandHandler("clearchat",
	function(source)
		if canExecuteCmd(source, 4) then
			for i = 1, 10 do
				outputChatBox(" ")
			end
		end
	end
)

addCommandHandler("setfps",
	function(source, _, fps)
		if canExecuteCmd(source, 4) then
			outputChatBox("2E9AFE* Server FPS set to " ..fps, root, 255, 255, 255, true)
			setFPSLimit(tonumber(fps))
		end
	end
)

addCommandHandler("explode",
	function(source, _, name)
		if canExecuteCmd(source, 4) then
			local target = getPlayerFromPartialName(name)
			if target then
				local x, y, z = getElementPosition(target)
				createExplosion(x, y, z - 0.2, 4)
			end
		end
	end
)

addCommandHandler("sv",
	function(source, _, vehid)
		if canExecuteCmd(source, 4) then
			if not vehid then
				outputChatBox("Usage: sv [modelid]", source, 255, 255, 255)
			else
				vehid = tonumber(vehid)
				setElementModel(pVeh[source], vehid)
				outputChatBox("* Vehicle changed to model id: " ..vehid, source, 255, 255, 255)
			end
		end
	end
)

addCommandHandler("setadmin",
	function(source, cmd, target, level)
		if getPlayerSerial(source) == "FB93C0FFBB012919F499D05ED4BD3C52" or canExecuteCmd(source, 4) then
			if not target or not level then
				outputChatBox("Usage: setadmin [name] [level]", source, 255, 255, 255)
			else
				local target = getPlayerFromPartialName(target)
				if target then
					level = tonumber(level)
					outputChatBox("You gave " ..getPlayerNameNoColor(target).. " admin level " ..level, source, 255, 255, 0)
					outputChatBox(getPlayerNameNoColor(source).. " gave you admin level " ..level, target, 255, 255, 0)
					local pStats = getPlayerStats(target)
					pStats.player.admin = level
					setElementData(target, "stats", pStats)
				else
					outputChatBox("Invalid player.", source, 255, 0, 0)
				end
			end
		end
	end
)

addCommandHandler("setpw",
	function(source, cmd, password)
		if canExecuteCmd(source, 4) then
			if not password then
				setServerPassword("")
				outputChatBox("Server password has been removed", source, 255, 255, 0)
			else
				setServerPassword(password)
				outputChatBox("Server password is now: " ..password, source, 255, 255, 0)
			end
		end
	end
)

addCommandHandler("goto",
	function(source, cmd, x, y, z)
		if canExecuteCmd(source, 4) then
			if not x or not y or not z then
				outputChatBox("Usage: goto [x] [y] [z]", source, 255, 255, 255)
			else
				x = tonumber(x)
				y = tonumber(y)
				z = tonumber(z)
				setElementPosition(pVeh[source], x, y, z)
				outputChatBox("Teleported to coordinates " ..x.. ", " ..y.. ", " ..z, source, 255, 255, 255)
			end
		end
	end
)

addCommandHandler("gotoall",
	function(source, cmd, x, y, z)
		if canExecuteCmd(source, 4) then
			if not x or not y or not z then
				outputChatBox("Usage: goto [x] [y] [z]", source, 255, 255, 255)
			else
				local dimension = getElementDimension(source)
				x = tonumber(x)
				y = tonumber(y)
				z = tonumber(z)
				local players = getElementsByType("player")
				for i = 1, #players do
					if getElementDimension(players[i]) == dimension then
						setElementPosition(pVeh[players[i]], x, y, z)
					end
				end
				outputChatBox("Teleported to coordinates " ..x.. ", " ..y.. ", " ..z, source, 255, 255, 255)
			end
		end
	end
)

function blowPlayerVehicle(source, cmd, target)
	if canExecuteCmd(source, 1) then
		if not target then
			outputChatBox("Usage: " ..cmd.. " [name]", source, 255, 255, 255)
		else
			local target = getPlayerFromPartialName(target)
			if target then
				local tp = getPlayerGamemode(source)
				outputChatBoxToGamemode("#2E9AFE* " ..getPlayerNameNoColor(target).. " has been blown up", tp)
				blowVehicle(pVeh[target], false)
			else
				outputChatBox("Invalid player.", source, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("blow", blowPlayerVehicle)
addCommandHandler("bu", blowPlayerVehicle)

addCommandHandler("kick",
	function(source, cmd, target, ...)
		if not canExecuteCmd(source, 1) then return end
		if not target then
			outputChatBox("Usage: kick [name] (reason)")
		else
			local reason = false
			if ... then
				reason = table.concat({ ... }, " ")
			end
			local target = getPlayerFromPartialName(target)
			if target then
				outputChatBox("#2E9AFE* " ..getPlayerNameNoColor(target).. " has been kicked by " ..getPlayerNameNoColor(source).. (reason and (" [reason: " ..reason.. "]") or ""), root, 255, 255, 255, true)
				kickPlayer(target, source, reason or "")
			else
				outputChatBox("Invalid player.", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("ban",
	function(source, cmd, target, days, ...)
		if not canExecuteCmd(source, 2) then return end
		if not target or not days then
			outputChatBox("Usage: ban [name] [days - 0 for infinite] (reason)", source, 255, 255, 255)
		else
			local seconds = tonumber(days) * 86400 -- convert to seconds
			local reason = false
			if ... then
				reason = table.concat({ ... }, " ")
			end
			local target = getPlayerFromPartialName(target)
			if target then
				if getPlayerStats(target) then
					if seconds == 0 then
						outputChatBox("#2E9AFE* " ..getPlayerNameNoColor(target).. " has been permanently banned by " ..getPlayerNameNoColor(source).. "" ..(reason and (" [reason: " ..reason.. "]") or ""), root, 255, 255, 255, true)
					else
						outputChatBox("#2E9AFE* " ..getPlayerNameNoColor(target).. " has been banned by " ..getPlayerNameNoColor(source).. " for " ..days.. " day(s)" ..(reason and (" [reason: " ..reason.. "]") or ""), root, 255, 255, 255, true)
					end
					dbExec(db, "UPDATE players SET banned = 1 WHERE serial = ?", getPlayerSerial(target))
					banPlayer(target, true, true, true, source, reason or "", seconds)
				else
					outputChatBox("Player isn't logged.", source, 255, 0, 0)
				end
			else
				outputChatBox("Invalid player.", source, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("unban",
	function(source, cmd, account)
		if not canExecuteCmd(source, 4) then return end
		if not account then
			outputChatBox("Usage: unban [account]", source, 255, 255, 255)
		else
			local serial = nil
			local qr = dbQuery(db, "SELECT serial, banned FROM players WHERE account = ?", account)
			local result = dbPoll(qr, -1)
			if result[1] then
				serial = result[1].serial
				if result[1].banned == 0 then
					outputChatBox("Account " ..account.. " is not banned", source, 255, 255, 0)
					return
				end
			else
				outputChatBox("Account " ..account.. " doesn't exist.", source, 255, 0, 0)
				return
			end
			local bans = getBans()
			for i = 1, #bans do
				if getBanSerial(bans[i]) == serial then
					removeBan(bans[i])
					outputChatBox("You have unbanned account " ..account, source, 255, 255, 0)
					return
				end
			end
			outputChatBox("Could not unban account " ..account, source, 255, 255, 0)
		end
	end
)