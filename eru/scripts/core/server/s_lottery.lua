local gLotto =
{
	open = false,
	jackpot = 0,
	tick = 0,
	timer = nil,
	msgsent = false
}

local jackpots =
{
	3000,
	6000,
	9000
}

local gTicket = {}

addCommandHandler("lotto",
	function(source, cmd, number)
		if not gLotto.open then 
			outputChatBox("Lottery is closed.", source, 255, 0, 0)
			return 
		end
		local lottoid = isPlayerOnLotto(source)
		if lottoid then
			outputChatBox("You are already on the lottery, your number is " ..lottoid, source, 255, 255, 0)
			return
		end
		if not number then
			outputChatBox("Usage: lotto [1 - 100]", source, 255, 255, 255)
		else
			if getPlayerMoney(source) >= 2000 then
				number = tonumber(number)
				if not gTicket[number] then
					gTicket[number] = source
					outputChatBox("You bought a lottery ticket, number is " ..number, source, 255, 255, 0)
					gLotto.jackpot = gLotto.jackpot + 2000
					addPlayerLotteryPlayed(source)
					if math.random(1, 2) == math.random(1, 2) then
						outputChatBox("* Lottery jackpot is now $" ..gLotto.jackpot.. ", use /lotto [1 - 100] to buy your number!", root, 255, 255, 0)
					end	
				else
					outputChatBox("That ticket number is already bought.", source, 255, 0, 0)
				end
			else
				outputChatBox("You don't have enough money.", source, 255, 0, 0)
			end	
		end
	end
)

addCommandHandler("openlotto",
	function(source)
		if canExecuteCmd(source, 4) then
			openLottery()
		end
	end
)

function openLottery()
	if gLotto.open then return end
	gLotto.open = true
	gLotto.jackpot = gLotto.jackpot == 0 and jackpots[math.random(#jackpots)] or gLotto.jackpot
	gLotto.tick = getTickCount()
	outputChatBox("* Lottery is now open, use /lotto [1 - 100] to enter the lottery, ticket price is $2000 - jackpot is $" ..gLotto.jackpot, root, 255, 255, 0)
	gLotto.timer = setTimer(
		function()
			local tick = getTickCount()
			if tick - gLotto.tick >= 30000 and not gLotto.msgsent then
				outputChatBox("Lottery winner will be announced in 1 minute..", root, 255, 255, 0)
				gLotto.msgsent = true
			end
			if tick - gLotto.tick >= 90000 then
				local rand = math.random(1, 100)
				if gTicket[rand] then
					if isElement(gTicket[rand]) then
						outputChatBox("* Lucky number is " ..rand.. " - " ..getPlayerName(gTicket[rand]).. " won $" ..gLotto.jackpot, root, 255, 255, 255)
						givePlayerMoney(gTicket[rand], gLotto.jackpot)
						addPlayerLotteryProfit(gTicket[rand], gLotto.jackpot)
						addPlayerLotteryWon(gTicket[rand])
					else
						outputChatBox("* Lucky number is " ..rand.. " - we have no winners! - lottery jackpot is now $" ..gLotto.jackpot, root, 255, 255, 255)
					end
				else
					outputChatBox("* Lucky number is " ..rand.. " - we have no winners! - lottery jackpot is now $" ..gLotto.jackpot, root, 255, 255, 255)
				end
				closeLottery()
			end
		end
	, 1000, 0)
end
setTimer(openLottery, math.random(1800000, 3600000), 1) -- Open in between 30 minutes and 60 minutes

function closeLottery()
	gTicket = {}
	gLotto.msgsent = false
	gLotto.open = false
	killTimer(gLotto.timer)
	setTimer(openLottery, math.random(1800000, 3600000), 1) -- Open in between 30 minutes and 60 minutes
end

function isPlayerOnLotto(source)
	for id, player in pairs(gTicket) do
		if player == source then
			return id
		end
	end
	return false
end