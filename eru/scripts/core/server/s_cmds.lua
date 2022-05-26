local TIME_BETWEEN_CMDS = 8 -- 30 seconds

local cmdTick = {}

addEventHandler("onPlayerQuit", root,
	function()
		cmdTick[source] = nil
	end
)

addEventHandler("onPlayerChangeNick", root,
	function()
		outputChatBox("Please use /setnick [name] to change your name", source, 255, 255, 0)
	end
)

addCommandHandler("spin",
	function(source, cmd, amount)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		amount = tonumber(amount)
		if not amount then
			outputChatBox("Usage: spin [amount]", source, 255, 255, 255)
		else
			if amount > 1000 then
				outputChatBox("Maximum amount allowed for spin is $1000.", source, 255, 0, 0)
			elseif amount < 500 then
				outputChatBox("Minimum amount allowed for spin is $500.", source, 255, 0, 0)
			else
				if canUseCmd(source, cmd) then
					local tp = getPlayerGamemode(source)
					if math.random(1, 12) == math.random(13, 36) then
						local won = amount * 36
						outputChatBoxToGamemode("#2E9AFE* " ..getPlayerNameNoColor(source).. " spins $" ..amount.. " and wins $" ..won, tp)
						givePlayerMoney(source, won)
						pStats.player.spinswon = pStats.player.spinswon + 1
						setElementData(source, "stats", pStats)
					else
						outputChatBoxToGamemode("#2E9AFE* " ..getPlayerNameNoColor(source).. " spins $" ..amount.. " and loses", tp)
						givePlayerMoney(source, -amount)
					end
				end
			end
		end
	end
)

addCommandHandler("flip",
	function(source, cmd, amount)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if not amount then
			outputChatBox("Usage: flip [amount]", source, 255, 255, 255)
		else
			amount = tonumber(amount)
			if amount > 1500 then
				outputChatBox("Maximum amount allowed for flip is $1500.", source, 255, 0, 0)
			elseif amount < 250 then
				outputChatBox("Minimum amount allowed for flip is $250.", source, 255, 0, 0)
			else
				if canUseCmd(source, cmd) then
					local tp = getPlayerGamemode(source)
					if math.random(1, 2) == 2 then
						local won = amount * 2
						outputChatBoxToGamemode("##2E9AFE* " ..getPlayerNameNoColor(source).. " flips $" ..amount.. " and wins $" ..won, tp)
						givePlayerMoney(source, won)
						pStats.player.flipswon = pStats.player.flipswon + 1
						setElementData(source, "stats", pStats)
					else
						outputChatBoxToGamemode("##2E9AFE* " ..getPlayerNameNoColor(source).. " flips $" ..amount.. " and loses", tp)
						givePlayerMoney(source, -amount)
					end
				end
			end
		end
	end
)

-----------

addCommandHandler("hi",
	function(source, cmd, target)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			if not target then
				local tp = getPlayerGamemode(source)
				outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'Hi!'", tp)
			else
				local target = getPlayerFromPartialName(target)
				if target then
					outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'Hi!' to " ..getPlayerNameNoColor(target), tp)
				else
					outputChatBox("Invalid player.", source, 255, 0, 0)
				end
			end
		end
	end
)

addCommandHandler("wb",
	function(source, cmd, target)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if not target then
			outputChatBox("Usage: wb [name]", source, 255, 255, 255)
		else
			if canUseCmd(source, cmd) then
				local target = getPlayerFromPartialName(target)
				if target then
					local tp = getPlayerGamemode(source)
					outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'Welcome back!' to " ..getPlayerNameNoColor(target), tp)
				else
					outputChatBox("Invalid player.", source, 255, 0, 0)
				end
			end
		end
	end
)

addCommandHandler("bb",
	function(source, cmd, target)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			if not target then
				local tp = getPlayerGamemode(source)
				outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'Bye bye!'", tp)
			else
				local target = getPlayerFromPartialName(target)
				if target then
					outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'Bye bye!' to " ..getPlayerNameNoColor(target), tp)
				else
					outputChatBox("Invalid player.", source, 255, 0, 0)
				end
			end
		end
	end
)

addCommandHandler("afk",
	function(source, cmd)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			local tp = getPlayerGamemode(source)
			outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " is now away from keyboard", tp)
		end
	end
)

addCommandHandler("nos",
	function(source, cmd)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			local tp = getPlayerGamemode(source)
			outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " is waiting for nitro!", tp)
		end
	end
)

addCommandHandler("brb",
	function(source, cmd)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			local tp = getPlayerGamemode(source)
			outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " will be right back!", tp)
		end
	end
)

addCommandHandler("back",
	function(source, cmd)
		local pStats = getPlayerStats(source)
		if not pStats then return end
		if canUseCmd(source, cmd) then
			local tp = getPlayerGamemode(source)
			outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " says 'I'm back!'", tp)
		end
	end
)

addCommandHandler("cookie",
	function(source, cmd, target)
		if not target then
			outputChatBox("Usage: cookie [name]", source, 255, 255, 255)
		else
			local pStats = getPlayerStats(source)
			if not pStats then return end
			if canUseCmd(source, cmd) then
				local tp = getPlayerGamemode(source)
				local target = getPlayerFromPartialName(target)
				if target then
					outputChatBoxToGamemode("#ff00ff* " ..getPlayerNameNoColor(source).. " gives " ..getPlayerNameNoColor(target).. " a cookie!", tp)
				else
					outputChatBox("Invalid player.", source, 255, 0, 0)
				end
			end
		end
	end
)

function canUseCmd(source, cmd)
	local tick = getTickCount()
	local timeleft = tick - (cmdTick[source] or 0)
	if timeleft >= TIME_BETWEEN_CMDS * 1000 then
		cmdTick[source] = getTickCount()
		return true
	else
		outputChatBox("Please wait " ..(TIME_BETWEEN_CMDS - math.floor(timeleft / 1000)).. " second(s) before using /" ..cmd, source, 255, 0, 0)
		return false
	end
end 