local TIME_TO_SAVE = 30 -- save player stats every 30 minutes
local REGISTER_MONEY = 2500000
local MAX_RANKING = 25

local HUNTER_MONEY = 250
local WIN_MONEY = 500
local WIN_POINTS = 2
local HUNTER_POINTS = 1

local pGotHunter = {}
local gTimeOnline = {}
local gTimeOnline2 = {} -- Used for rankings
local gRankings = {}

db = nil

addEvent("login:onPlayerRequestLogin", true)
addEvent("login:onPlayerRequestRegister", true)

addEvent("panel:onPlayerRequestRankings", true)

addEvent("race:onRaceMapStart")
addEvent("race:onPlayerWin")
addEvent("race:onPlayerDead")
addEvent("race:onPlayerReachHunter")
addEvent("race:onOJWin")
addEvent("race:onPlayerSpawning")

addEventHandler("onResourceStart", resourceRoot,
	function()
		db = dbConnect("mysql", "dbname=eru;host=127.0.0.1", "root", "Feche1234#")
		if db then
			outputDebugString("[MYSQL] Connected to MYSQL database")
		else
			outputDebugString("[MYSQL] FAILED to connect to MYSQL database")
		end
		dbExec(db, "CREATE TABLE IF NOT EXISTS players (account TINYTEXT, password TINYTEXT, serial TINYTEXT, logged INT, date TINYTEXT, name TINYTEXT, namenocolor TINYTEXT, logins INTEGER, timeplayed INTEGER, mosttimeplayed INTEGER, winsdm INTEGER, deathsdm INTEGER, mapsplayeddm INTEGER, winsodm INTEGER, deathsodm INTEGER, mapsplayedodm INTEGER, winsdd INTEGER, deathsdd INTEGER, mapsplayeddd INTEGER, winsrace INTEGER, deathsrace INTEGER, mapsplayedrace INTEGER, winshunter INTEGER, deathshunter INTEGER, mapsplayedhunter INTEGER, totalkillshunter INTEGER, winsshooter INTEGER, deathsshooter INTEGER, mapsplayedshooter INTEGER, totalkillsshooter INTEGER, winsoj INTEGER, deathsoj INTEGER, mapsplayedoj INTEGER, winstrials INTEGER, deathstrials INTEGER, mapsplayedtrials INTEGER, money INTEGER, points INTEGER, hunters INTEGER, topone INTEGER, vip INTEGER, admin INTEGER, mapstrained INTEGER, timespenttraining INTEGER, huntersontraining INTEGER, lotteriesplayed INTEGER, lotterieswon INTEGER, lotteriesprofit INTEGER, flipswon INTEGER, spinswon INTEGER, clan TINYTEXT, banned INTEGER, vehicle TEXT)")
		dbExec(db, "UPDATE players SET logged = 0")
		--
		local players = getElementsByType("player")
		for i = 1, #players do
			gTimeOnline[players[i]] = getTickCount()
			gTimeOnline2[players[i]] = getTickCount()
		end
		--
		setTimer(updateRankings, 2000, 1)
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		local players = getElementsByType("player")
		for i = 1, #players do
			savePlayerStats(players[i], true)
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		gTimeOnline[source] = getTickCount()
		gTimeOnline2[source] = getTickCount()
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		savePlayerStats(source, true)
	end
, true, "low")

addEventHandler("login:onPlayerRequestLogin", root,
	function(username, password)
		local qr = dbQuery(db, "SELECT * FROM players WHERE account = '" ..username.. "'")
		local result = dbPoll(qr, -1)
		if result[1] then
			local stats = result[1]
			if stats.password == password then
				if stats.logged == 1 then
					showNotificationToPlayer(source, "The account is already logged in", "error")
				else
					loadPlayerStats(source, stats)
				end
			else
				showNotificationToPlayer(source, "Incorrect password, try again", "error")
			end
		else
			showNotificationToPlayer(source, "That account doesn't exist on this server", "error")
		end
	end
)

addEventHandler("login:onPlayerRequestRegister", root,
	function(username, password)
		local qr = dbQuery(db, "SELECT * FROM players WHERE account = '" ..username.. "'")
		local result = dbPoll(qr, -1)
		if result[1] then
			showNotificationToPlayer(source, "That username is already taken", "error")
		else
			local name = getPlayerName(source)
			local date = FormatDate("d/m/Y")
			dbExec(db, "INSERT INTO players VALUES (?, ?, ?, 1, ?, ?, ?, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'none', 0, '[[]]')", username, password, getPlayerSerial(source), date, name, getPlayerNameNoColor(source))
			showNotificationToPlayer(source, "Successfully registered account '" ..username.. "'", "info")
			triggerClientEvent(source, "login:onPlayerLoginEx", source)
			local pStats = {}
			pStats.account = username
			pStats.logged = true
			pStats.date = date
			pStats.player = {}
			pStats.player.name = name
			pStats.player.logins = 1
			pStats.player.timeplayed = 0
			pStats.player.mosttimeplayed = 0
			--
			pStats.player.winsdm = 0
			pStats.player.deathsdm = 0
			pStats.player.mapsplayeddm = 0
			
			pStats.player.winsodm = 0
			pStats.player.deathsodm = 0
			pStats.player.mapsplayedodm = 0
			
			pStats.player.winsdd = 0
			pStats.player.deathsdd = 0
			pStats.player.mapsplayeddd = 0
			
			pStats.player.winsrace = 0
			pStats.player.deathsrace = 0
			pStats.player.mapsplayedrace = 0
			
			pStats.player.winshunter = 0
			pStats.player.deathshunter = 0
			pStats.player.mapsplayedhunter = 0
			pStats.player.totalkillshunter = 0
			
			pStats.player.winsshooter = 0
			pStats.player.deathsshooter = 0
			pStats.player.mapsplayedshooter = 0
			pStats.player.totalkillsshooter = 0
			
			pStats.player.winsoj = 0
			pStats.player.deathsoj = 0
			pStats.player.mapsplayedoj = 0
			
			pStats.player.winstrials = 0
			pStats.player.deathstrials = 0
			pStats.player.mapsplayedtrials = 0
			--
			pStats.player.money = REGISTER_MONEY
			pStats.player.points = 0
			pStats.player.hunters = 0
			pStats.player.topone = 0
			--
			pStats.player.vip = 0
			pStats.player.admin = 0
			--
			pStats.player.mapstrained = 0
			pStats.player.timespenttraining = 0
			pStats.player.huntersontraining = 0
			--
			pStats.player.lotteriesplayed = 0
			pStats.player.lotterieswon = 0
			pStats.player.lotteriesprofit = 0
			--
			pStats.player.flipswon = 0
			pStats.player.spinswon = 0
			--
			pStats.player.clan = "none"
			--
			pStats.vehicle = {}
			pStats.vehicle.wheel = -1
			pStats.vehicle.rearlight = -1
			pStats.vehicle.noscolor = false
			pStats.vehicle.plate = false
			pStats.vehicle.paint = false
			pStats.vehicle.frontlight = false
			setElementData(source, "stats", pStats)
			setElementData(source, "money", REGISTER_MONEY) -- scoreboard
			setElementData(source, "points", 0) -- scoreboard
			-- Change nick if it's already in use
			local inuse, account = isNickInUse(name)
			if inuse then
				if account ~= pStats.account then
					setPlayerNick(source, randomNames[math.random(#randomNames)].. "" ..math.random(100, 999), false)
					showNotificationToPlayer(source, "Your nickname is already in use, changing to a random one", "warning")
				end
			end
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if not tp:find("Training_S_", 1, true) then
			local players = getGamemodePlayers(tp)
			for i = 1, #players do
				addPlayerMapsPlayed(players[i], tp)
				pGotHunter[players[i]] = false
			end
		end
	end
)

addEventHandler("race:onPlayerSpawning", root,
	function()
		-- Wheel
		local pStats = getPlayerStats(source)
		if pStats.vehicle.wheel > 0 then
			addVehicleUpgrade(pVeh[source], pStats.vehicle.wheel)
		end
		-- Paint
		if type(pStats.vehicle.paint) == "table" then
			local r, g, b = unpack(pStats.vehicle.paint)
			setVehicleColor(pVeh[source], r, g, b, r, g, b, r, g, b, r, g, b)
		end
		-- Headlight color
		if type(pStats.vehicle.frontlight) == "table" then
			setVehicleHeadLightColor(pVeh[source], unpack(pStats.vehicle.frontlight))
		end
	end
)

addEventHandler("race:onPlayerWin", root,
	function(tp)
		addPlayerWin(source, tp)
		outputChatBox("You've won $" ..WIN_MONEY.. " and " ..WIN_POINTS.. " points for winning the race", source, 255, 255, 255)
		givePlayerMoney(source, WIN_MONEY)
		givePlayerPoints(source, WIN_POINTS)
	end
)

addEventHandler("race:onOJWin", root,
	function()
		local pStats = getPlayerStats(source)
		pStats.player.winsoj = pStats.player.winsoj + 1
		setElementData(source, "stats", pStats)
	end
)

addEventHandler("race:onPlayerDead", root,
	function(tp, rank)
		if not tp:find("Training_S_", 1, true) then
			if getGamemodeState(tp) == "map started" or getGamemodeState(tp) == "map finished" then
				addPlayerDeath(source, tp)
				local money = math.floor(WIN_MONEY / rank)
				local points = math.floor(WIN_POINTS / rank)
			--	showNotificationToPlayer(source, "You've won $" ..money.. " and " ..points.. " point(s) for finishing " ..rank.. "" ..((rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th'), "info")
				outputChatBox("You've won $" ..money.. " and " ..points.. " point(s) for finishing " ..rank.. "" ..((rank < 10 or rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[rank % 10] or 'th'), source, 255, 255, 255)
				givePlayerMoney(source, money)
				givePlayerPoints(source, points)
			end
		end
	end
)

addEventHandler("race:onPlayerReachHunter", root,
	function(tp)
		if tp == "Deathmatch" or tp == "Old Deathmatch" or tp:find("Training_S_", 1, true) then
			if tp == "Deathmatch" or tp == "Old Deathmatch" then
				local state = getPlayerState(source)
				if not pGotHunter[source] then
					if state == "alive" then
						addPlayerHunters(source)
						showNotificationToPlayer(source, "You've won $" ..HUNTER_MONEY.. " for reaching hunter", "info")
						givePlayerMoney(source, HUNTER_MONEY)
						showNotificationToGamemode(getPlayerNameNoColor(source).. " reached hunter", tp, "info")
						pGotHunter[source] = true
					elseif state == "training" then 
						local trainingmoney = math.floor(HUNTER_MONEY / 2)
						showNotificationToPlayer(source, "You've won $" ..trainingmoney.. " for reaching hunter in training", "info")
						givePlayerMoney(source, trainingmoney)
						showNotificationToGamemode(getPlayerNameNoColor(source).. " reached hunter in training", tp, "info")
						pGotHunter[source] = true
					end
				end
			else -- Training_S_ type
				showNotificationToGamemode(getPlayerNameNoColor(source).. " reached hunter", tp, "info")
				if not pGotHunter[source] then
					addPlayerHuntersTraining(source)
					pGotHunter[source] = true
				end
			end
		end
	end
)

addEventHandler("panel:onPlayerRequestRankings", root,
	function()
		triggerClientEvent(source, "panel:onReceiveRankings", source, gRankings)
	end
)

function loadPlayerStats(source, stats)
	if stats.banned == 1 then
		kickPlayer(source, "Your account is banned")
		return
	end
	local pStats = {}
	pStats.account = stats.account
	pStats.logged = true
	pStats.date = stats.date
	pStats.player = {}
	pStats.player.name = stats.name
	pStats.player.logins = stats.logins + 1
	pStats.player.timeplayed = stats.timeplayed
	pStats.player.mosttimeplayed = stats.mosttimeplayed
	--
	pStats.player.winsdm = stats.winsdm
	pStats.player.deathsdm = stats.deathsdm
	pStats.player.mapsplayeddm = stats.mapsplayeddm
	
	pStats.player.winsodm = stats.winsodm
	pStats.player.deathsodm = stats.deathsodm
	pStats.player.mapsplayedodm = stats.mapsplayedodm
	
	pStats.player.winsdd = stats.winsdd
	pStats.player.deathsdd = stats.deathsdd
	pStats.player.mapsplayeddd = stats.mapsplayeddd
	
	pStats.player.winsrace = stats.winsrace
	pStats.player.deathsrace = stats.deathsrace
	pStats.player.mapsplayedrace = stats.mapsplayedrace
	
	pStats.player.winshunter = stats.winshunter
	pStats.player.deathshunter = stats.deathshunter
	pStats.player.mapsplayedhunter = stats.mapsplayedhunter
	pStats.player.totalkillshunter = stats.totalkillshunter
	
	pStats.player.winsshooter = stats.winsshooter
	pStats.player.deathsshooter = stats.deathsshooter
	pStats.player.mapsplayedshooter = stats.mapsplayedshooter
	pStats.player.totalkillsshooter = stats.totalkillsshooter
	
	pStats.player.winsoj = stats.winsoj
	pStats.player.deathsoj = stats.deathsoj
	pStats.player.mapsplayedoj = stats.mapsplayedoj
	
	pStats.player.winstrials = stats.winstrials
	pStats.player.deathstrials = stats.deathstrials
	pStats.player.mapsplayedtrials = stats.mapsplayedtrials
	--
	pStats.player.money = stats.money
	pStats.player.points = stats.points
	pStats.player.hunters = stats.hunters
	pStats.player.topone = stats.topone
	--
	pStats.player.vip = stats.vip
	pStats.player.admin = stats.admin
	--
	pStats.player.mapstrained = stats.mapstrained
	pStats.player.timespenttraining = stats.timespenttraining
	pStats.player.huntersontraining = stats.huntersontraining
	--
	pStats.player.lotteriesplayed = stats.lotteriesplayed
	pStats.player.lotterieswon = stats.lotterieswon
	pStats.player.lotteriesprofit = stats.lotteriesprofit
	--
	pStats.player.flipswon = stats.flipswon
	pStats.player.spinswon = stats.spinswon
	--
	pStats.player.clan = stats.clan
	--
	pStats.vehicle = fromJSON(stats.vehicle)
	setElementData(source, "stats", pStats)
	setElementData(source, "money", pStats.player.money) -- scoreboard
	setElementData(source, "points", pStats.player.points) -- scoreboard
	showNotificationToPlayer(source, "Successfully logged in", "info")
	triggerEvent("login:onPlayerLoginEx", source, pStats)
	triggerClientEvent(source, "login:onPlayerLoginEx", source)
	dbExec(db, "UPDATE players SET logged = 1, serial = ? WHERE account = ?", getPlayerSerial(source), pStats.account)
	setPlayerClan(source) -- Set the player clan
end

function addPlayerWin(source, tp)
	local pStats = getPlayerStats(source)
	if tp:find("Deathmatch") then
		pStats.player.winsdm = pStats.player.winsdm + 1
	elseif tp:find("Oldschool") then
		pStats.player.winsodm = pStats.player.winsodm + 1
	elseif tp:find("Destruction Derby") then
		pStats.player.winsdd = pStats.player.winsdd + 1
	elseif tp == "Race" then
		pStats.player.winsrace = pStats.player.winsrace + 1
	elseif tp == "Hunter" then
		pStats.player.winshunter = pStats.player.winshunter + 1
	elseif tp == "Shooter" then
		pStats.player.winsshooter = pStats.player.winsshooter + 1
	elseif tp == "Trials" then
		pStats.player.winstrials = pStats.player.winstrials + 1
	end
	setElementData(source, "stats", pStats)
end

function addPlayerDeath(source, tp)
	local pStats = getPlayerStats(source)
	if tp:find("Deathmatch") then
		pStats.player.deathsdm = pStats.player.deathsdm + 1
	elseif tp:find("Oldschool") then
		pStats.player.deathsodm = pStats.player.deathsodm + 1
	elseif tp:find("Destruction Derby") then
		pStats.player.deathsdd = pStats.player.deathsdd + 1
	elseif tp == "Race" then
		pStats.player.deathsrace = pStats.player.deathsrace + 1
	elseif tp == "Hunter" then
		pStats.player.deathshunter = pStats.player.deathshunter + 1
	elseif tp == "Shooter" then
		pStats.player.deathsshooter = pStats.player.deathsshooter + 1
	elseif tp == "OJ" then
		if source == getCurrentOJ() then
			pStats.player.deathsoj = pStats.player.deathsoj + 1
		end
	elseif tp == "Trials" then
		pStats.player.deathstrials = pStats.player.deathstrials + 1
	end
	setElementData(source, "stats", pStats)
end

function addPlayerMapsPlayed(source, tp)
	local pStats = getPlayerStats(source)
	if tp:find("Deathmatch") then
		pStats.player.mapsplayeddm = pStats.player.mapsplayeddm + 1
	elseif tp:find("Oldschool") then
		pStats.player.mapsplayedodm = pStats.player.mapsplayedodm + 1
	elseif tp:find("Destruction Derby") then
		pStats.player.mapsplayeddd = pStats.player.mapsplayeddd + 1
	elseif tp == "Race" then
		pStats.player.mapsplayedrace = pStats.player.mapsplayedrace + 1
	elseif tp == "Hunter" then
		pStats.player.mapsplayedhunter = pStats.player.mapsplayedhunter + 1
	elseif tp == "Shooter" then
		pStats.player.mapsplayedshooter = pStats.player.mapsplayedshooter + 1
	elseif tp == "OJ" then
		pStats.player.mapsplayedoj = pStats.player.mapsplayedoj + 1
	elseif tp == "Trials" then
		pStats.player.mapsplayedtrials = pStats.player.mapsplayedtrials + 1
	end
	setElementData(source, "stats", pStats)
end

function addPlayerHunters(source)
	local pStats = getPlayerStats(source)
	pStats.player.hunters = pStats.player.hunters + 1
	setElementData(source, "stats", pStats)
end

function addPlayerTopOne(source)
	local pStats = getPlayerStats(source)
	pStats.player.topone = pStats.player.topone + 1
	setElementData(source, "stats", pStats)
end

function addPlayerShooterKill(source)
	local pStats = getPlayerStats(source)
	pStats.player.totalkillsshooter = pStats.player.totalkillsshooter + 1
	setElementData(source, "stats", pStats)
end

function addPlayerMapsTrained(source)
	local pStats = getPlayerStats(source)
	pStats.player.mapstrained = pStats.player.mapstrained + 1
	setElementData(source, "stats", pStats)
end

function addPlayerTrainingTime(source, ms)
	local pStats = getPlayerStats(source)
	pStats.player.timespenttraining = pStats.player.timespenttraining + ms
	setElementData(source, "stats", pStats)
end

function addPlayerHuntersTraining(source)
	local pStats = getPlayerStats(source)
	pStats.player.huntersontraining = pStats.player.huntersontraining + 1
	setElementData(source, "stats", pStats)
end

function addPlayerLotteryPlayed(source)
	local pStats = getPlayerStats(source)
	pStats.player.lotteriesplayed = pStats.player.lotteriesplayed + 1
	setElementData(source, "stats", pStats)
end

function addPlayerLotteryWon(source)
	local pStats = getPlayerStats(source)
	pStats.player.lotterieswon = pStats.player.lotterieswon + 1
	setElementData(source, "stats", pStats)
end

function addPlayerLotteryProfit(source, profit)
	local pStats = getPlayerStats(source)
	pStats.player.lotteriesprofit = pStats.player.lotteriesprofit + profit
	setElementData(source, "stats", pStats)
end

_givePlayerMoney = givePlayerMoney
function givePlayerMoney(source, money)
	local pStats = getPlayerStats(source)
	pStats.player.money = pStats.player.money + money
	setElementData(source, "stats", pStats)
	setElementData(source, "money", pStats.player.money) -- scoreboard
	if pStats.player.clan ~= "none" and money > 0 then
		dbExec(db, "UPDATE clans SET cash = cash + " ..money.. " WHERE name = ?", pStats.player.clan)
	end
end

function givePlayerPoints(source, points)
	local pStats = getPlayerStats(source)
	pStats.player.points = pStats.player.points + points
	setElementData(source, "stats", pStats)
	setElementData(source, "points", pStats.player.points) -- scoreboard
	if pStats.player.clan ~= "none" then
		dbExec(db, "UPDATE clans SET points = points + " ..points.. " WHERE name = ?", pStats.player.clan)
	end
end

function getPlayerStats(source)
	return getElementData(source, "stats")
end

_getPlayerAccount = getPlayerAccount
function getPlayerAccount(source)
	return getPlayerStats(source) and getPlayerStats(source).account or false
end

function getPlayerMoney(source)
	return getElementData(source, "stats").player.money
end

function getPlayerFromAccount(account)
	local players = getElementsByType("player")
	for i = 1, #players do
		if getPlayerAccount(players[i]) == account then
			return players[i]
		end
	end
	return false
end

function getNameFromAccount(account)
	local qr = dbQuery(db, "SELECT name FROM players WHERE account = ?", account)
	local result = dbPoll(qr, -1)
	if result[1] then
		return result[1].name
	end
	return false
end

function getAccountFromName(name)
	name = name:gsub("#%x%x%x%x%x%x", "")
	local qr = dbQuery(db, "SELECT account FROM players WHERE namenocolor = ?", name)
	local result = dbPoll(qr, -1)
	if result[1] then
		return result[1].account
	end
	return "?"
end

function savePlayerStats(source, logout)
	local pStats = getPlayerStats(source)
	if not pStats then return end -- Player connected but not logged in
	pStats.player.mosttimeplayed = pStats.player.mosttimeplayed < getPlayerOnlineTime(source) and getPlayerOnlineTime(source) or pStats.player.mosttimeplayed
	pStats.player.timeplayed = pStats.player.timeplayed + math.floor((getTickCount() - gTimeOnline2[source]) / 60000)
	gTimeOnline2[source] = getTickCount()
	dbExec(db, "UPDATE players SET logged = ?, logins = ?, timeplayed = ?, mosttimeplayed = ?, winsdm = ?, deathsdm = ?, mapsplayeddm = ?, winsodm = ?, deathsodm = ?, mapsplayedodm = ?, winsdd = ?, deathsdd = ?, mapsplayeddd = ?, winsrace = ?, deathsrace = ?, mapsplayedrace = ?, winshunter = ?, deathshunter = ?, mapsplayedhunter = ?, totalkillshunter = ?, winsshooter = ?, deathsshooter = ?, mapsplayedshooter = ?, totalkillsshooter = ?, winsoj = ?, deathsoj = ?, mapsplayedoj = ?, winstrials = ?, deathstrials = ?, mapsplayedtrials = ?, money = ?, points = ?, hunters = ?, topone = ?, vip = ?, admin = ?, mapstrained = ?, timespenttraining = ?, huntersontraining = ?, lotteriesplayed = ?, lotterieswon = ?, lotteriesprofit = ?, flipswon = ?, spinswon = ?, clan = ?, vehicle = ? WHERE account = ?", logout and 0 or 1, pStats.player.logins, pStats.player.timeplayed, pStats.player.mosttimeplayed, pStats.player.winsdm, pStats.player.deathsdm, pStats.player.mapsplayeddm, pStats.player.winsodm, pStats.player.deathsodm, pStats.player.mapsplayedodm, pStats.player.winsdd, pStats.player.deathsdd, pStats.player.mapsplayeddd, pStats.player.winsrace, pStats.player.deathsrace, pStats.player.mapsplayedrace, pStats.player.winshunter, pStats.player.deathshunter, pStats.player.mapsplayedhunter, pStats.player.totalkillshunter, pStats.player.winsshooter, pStats.player.deathsshooter, pStats.player.mapsplayedshooter, pStats.player.totalkillsshooter, pStats.player.winsoj, pStats.player.deathsoj, pStats.player.mapsplayedoj, pStats.player.winstrials, pStats.player.deathstrials, pStats.player.mapsplayedtrials, pStats.player.money, pStats.player.points, pStats.player.hunters, pStats.player.topone, pStats.player.vip, pStats.player.admin, pStats.player.mapstrained, pStats.player.timespenttraining, pStats.player.huntersontraining, pStats.player.lotteriesplayed, pStats.player.lotterieswon, pStats.player.lotteriesprofit, pStats.player.flipswon, pStats.player.spinswon, pStats.player.clan, toJSON(pStats.vehicle), pStats.account)
end

function updateTotalOnline()
	local tick = getTickCount()
	local players = getElementsByType("player")
	for i = 1, #players do
		local minutes = (tick - gTimeOnline[players[i]]) / 60000
		local hour, minute = math.floor(minutes / 60 % 24), math.floor(minutes % 60)
		if minute < 10 then 
			minute = "0" ..minute
		end
		setElementData(players[i], "onlinetime", hour.. ":" ..minute)
	end
end
setTimer(updateTotalOnline, 60000, 0)

function updateRankings()
	local tick = getTickCount()
	gRankings = { [1] = { money = {}, points = {} }, [2] = { mosttimeplayed = {}, timeplayed = {} }, [3] = { spins = {}, flips = {} }, [4] = { hunters = {}, topone = {} }, [5] = { wins = {}, winratio = {} }, [6] = { mapsplayed = {}, deaths = {} }, [7] = { lotterieswon = {}, lotteriesprofit = {} }, [8] = { maplikes = {}, mapdislikes = {} }, [9] = { topmapsplayed = {}, topshooterkills = {} } }
	-- Money
	local result = dbPoll(dbQuery(db, "SELECT money, name FROM players ORDER BY money DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[1].money, { name = result[i].name, money = result[i].money })
		end
	end
	-- Points
	local result = dbPoll(dbQuery(db, "SELECT points, name FROM players ORDER BY points DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[1].points, { name = result[i].name, points = result[i].points })
		end
	end
	-- Most online
	local result = dbPoll(dbQuery(db, "SELECT mosttimeplayed, name FROM players ORDER BY mosttimeplayed DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[2].mosttimeplayed, { name = result[i].name, mosttimeplayed = result[i].mosttimeplayed })
		end
	end
	-- Time played
	local result = dbPoll(dbQuery(db, "SELECT timeplayed, name FROM players ORDER BY timeplayed DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[2].timeplayed, { name = result[i].name, timeplayed = result[i].timeplayed })
		end
	end
	-- Spins
	local result = dbPoll(dbQuery(db, "SELECT spinswon, name FROM players ORDER BY spinswon DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[3].spins, { name = result[i].name, spinswon = result[i].spinswon })
		end
	end
	-- Flips
	local result = dbPoll(dbQuery(db, "SELECT flipswon, name FROM players ORDER BY flipswon DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[3].flips, { name = result[i].name, flipswon = result[i].flipswon })
		end
	end
	-- Hunters
	local result = dbPoll(dbQuery(db, "SELECT hunters, name FROM players ORDER BY hunters DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[4].hunters, { name = result[i].name, hunters = result[i].hunters })
		end
	end
	-- Toptimes
	local result = dbPoll(dbQuery(db, "SELECT topone, name FROM players ORDER BY topone DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[4].topone, { name = result[i].name, topone = result[i].topone })
		end
	end
	-- Wins
	local result = dbPoll(dbQuery(db, "SELECT name, winsdm + winsodm + winsrace + winsshooter AS totalwins FROM players ORDER BY totalwins DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[5].wins, { name = result[i].name, wins = result[i].totalwins })
		end
	end
	-- Win ratio
	local result = dbPoll(dbQuery(db, "SELECT name, (winsdm + winsodm + winsrace + winsshooter) / (mapsplayeddm + mapsplayedodm + mapsplayedrace + mapsplayedshooter) AS winratio FROM players ORDER BY winratio DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[5].winratio, { name = result[i].name, winratio = math.round((result[i].winratio or 0) * 100, 2) })
		end
	end
	-- Maps played
	local result = dbPoll(dbQuery(db, "SELECT name, mapsplayeddm + mapsplayedodm + mapsplayedrace + mapsplayedshooter AS totalplays FROM players ORDER BY totalplays DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[6].mapsplayed, { name = result[i].name, mapsplayed = result[i].totalplays })
		end
	end
	-- Deaths
	local result = dbPoll(dbQuery(db, "SELECT name, deathsdm + deathsodm + deathsrace + deathsshooter AS deaths FROM players ORDER BY deaths DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[6].deaths, { name = result[i].name, deaths = result[i].deaths })
		end
	end
	-- Lottery wins
	local result = dbPoll(dbQuery(db, "SELECT lotterieswon, name FROM players ORDER BY lotterieswon DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[7].lotterieswon, { name = result[i].name, lotterieswon = result[i].lotterieswon })
		end
	end
	-- Lottery profit
	local result = dbPoll(dbQuery(db, "SELECT lotteriesprofit, name FROM players ORDER BY lotteriesprofit DESC LIMIT " ..MAX_RANKING), -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[7].lotteriesprofit, { name = result[i].name, lotteriesprofit = result[i].lotteriesprofit })
		end
	end
	-- Map likes
	local qr = dbQuery(db, "SELECT likes, resname FROM mapstats ORDER BY likes DESC LIMIT " ..MAX_RANKING)
	local result = dbPoll(qr, -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[8].maplikes, { mapname = getMapNameFromResourceName(result[i].resname), likes = result[i].likes })
		end
	end
	-- Map dislikes
	local qr = dbQuery(db, "SELECT dislikes, resname FROM mapstats ORDER BY dislikes DESC LIMIT " ..MAX_RANKING)
	local result = dbPoll(qr, -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[8].mapdislikes, { mapname = getMapNameFromResourceName(result[i].resname), dislikes = result[i].dislikes })
			if i == 5 then
		--		outputChatBox("Mapname is " ..getResourceMapName(result[i].resname))
			end
		end
	end
	-- Top maps played
	local qr = dbQuery(db, "SELECT timesplayed, resname FROM mapstats ORDER BY timesplayed DESC LIMIT " ..MAX_RANKING)
	local result = dbPoll(qr, -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[9].topmapsplayed, { mapname = getMapNameFromResourceName(result[i].resname), timesplayed = result[i].timesplayed })
		end
	end
	-- Top shooter kills
	local qr = dbQuery(db, "SELECT totalkillsshooter, name FROM players ORDER BY totalkillsshooter DESC LIMIT " ..MAX_RANKING)
	local result = dbPoll(qr, -1)
	if result then
		for i = 1, #result do
			table.insert(gRankings[9].topshooterkills, { name = result[i].name, totalkillsshooter = result[i].totalkillsshooter })
		end
	end
	outputDebugString("[STATS] updateRankings took " ..getTickCount() - tick.. " ms.")
end
setTimer(updateRankings, 14400000, 0) -- 4 hours

function getPlayerOnlineTime(source)
	return math.floor((getTickCount() - gTimeOnline[source]) / 60000) -- Returns minutes
end

function canExecuteCmd(source, level)
	local pStats = getPlayerStats(source)
	if pStats then
		if pStats.player.admin >= level then
			return true
		else
			outputChatBox("You can't do that.", source, 255, 0, 0)
			return false
		end
	end
end

setTimer(
	function()
		local players = getElementsByType("player")
		for i = 1, #players do
			savePlayerStats(players[i])
		end
	end
, TIME_TO_SAVE * 60000, 0)

function Check(funcname, ...)
    local arg = {...}

    if (type(funcname) ~= "string") then
        error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '"..type(funcname).."'.", 2)
    end
    if (#arg % 3 > 0) then
        error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is "..(#arg % 3)..".", 2)
    end

    for i=1, #arg-2, 3 do
        if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
            error("Argument type mismatch at 'Check' (arg #"..i.."). Expected 'string' or 'table', got '"..type(arg[i]).."'.", 2)
        elseif (type(arg[i+2]) ~= "string") then
            error("Argument type mismatch at 'Check' (arg #"..(i+2).."). Expected 'string', got '"..type(arg[i+2]).."'.", 2)
        end

        if (type(arg[i]) == "table") then
            local aType = type(arg[i+1])
            for _, pType in next, arg[i] do
                if (aType == pType) then
                    aType = nil
                    break
                end
            end
            if (aType) then
                error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..table.concat(arg[i], "' or '").."', got '"..aType.."'.", 3)
            end
        elseif (type(arg[i+1]) ~= arg[i]) then
            error("Argument type mismatch at '"..funcname.."' ('"..arg[i+2].."'). Expected '"..arg[i].."', got '"..type(arg[i+1]).."'.", 3)
        end
    end
end

local gWeekDays = { "Sunday", "Monday", "Tuesday", "Thursday", "Wednesday", "Friday", "Saturday" }
function FormatDate(format, escaper, timestamp)
	Check("FormatDate", "string", format, "format", {"nil","string"}, escaper, "escaper", {"nil","string"}, timestamp, "timestamp")
	escaper = (escaper or "'"):sub(1, 1)
	local time = getRealTime(timestamp)
	local formattedDate = ""
	local escaped = false
 
	time.year = time.year + 1900
	time.month = time.month + 1
 
	local datetime = { d = ("%02d"):format(time.monthday), h = ("%02d"):format(time.hour), i = ("%02d"):format(time.minute), m = ("%02d"):format(time.month), s = ("%02d"):format(time.second), w = gWeekDays[time.weekday+1]:sub(1, 2), W = gWeekDays[time.weekday+1], y = tostring(time.year):sub(-2), Y = time.year }
 
	for char in format:gmatch(".") do
		if (char == escaper) then escaped = not escaped
		else formattedDate = formattedDate..(not escaped and datetime[char] or char) end
	end
	return formattedDate
end

function sortTable(tbl, index)
	local tmp = {}
	for _, v in pairs(tbl) do
		table.insert(tmp, v)
	end
	table.sort(tmp, 
		function(a, b) 
			if a[index] then
				return a[index] > b[index] 
			else
				print(index.. " is nil")
			end
		end
	)
	local idx = #tmp
	if idx > MAX_RANKING then
		for i = MAX_RANKING + 1, idx do
			table.remove(tmp, i)
		end
	end
	return tmp
end

function math.round(num, idp)
	if idp and idp > 0 then
		local mult = 10^idp
		local value = math.floor(num * mult + 0.5) / mult
		return tostring(value):find("nan") and 0 or value
	end
	return math.floor(num + 0.5)
end