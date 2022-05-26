-----------------------------------------------------------------------------------------------
-- http://lite.ip2location.com/database-ip-country-region-city (November 2014 database date) --
-----------------------------------------------------------------------------------------------
-- UPDATE ip2location SET country_name = 'RUSSIA' where country_name = 'RUSSIAN FEDERATION'

local ip2locationdb = nil

addEventHandler("onResourceStart", getResourceRootElement(),
	function()
		ip2locationdb = dbConnect("mysql", "dbname=ip2location;host=127.0.0.1", "root", "Feche1234#")
		local players = getElementsByType("player")
		for i = 1, #players do
			setPlayerContryInfo(players[i])
		end
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		setPlayerContryInfo(source)
	end
)

function setPlayerContryInfo(source)
	local country = getCountry(getPlayerIP(source))
	setElementData(source, "Country", country)
end

function getCountry(ip)
	ip = split(ip, '.')
	local num = (16777216 * ip[1]) + (65536 * ip[2]) + (256 * ip[3]) + ip[4]
	local qr = dbQuery(ip2locationdb, "SELECT country_code, country_name FROM ip2location_db1 WHERE " ..num.. " BETWEEN ip_from AND ip_to LIMIT 1")
	local result = dbPoll(qr, -1)
	if result[1] then
		return result[1].country_name
	end
	return "?"
end

addCommandHandler("num",
	function(source)
		local ip = getPlayerIP(source)
		ip = split(ip, '.')
		local num = (16777216 * ip[1]) + (65536 * ip[2]) + (256 * ip[3]) + ip[4]
		outputChatBox("Your IP num is: " ..num, source)
	end
)

--[[
CREATE DATABASE eru_ip2location;
USE eru_ip2location;
CREATE TABLE `ip2location`(
	`ip_from` INT(10) UNSIGNED,
	`ip_to` INT(10) UNSIGNED,
	`country_code` CHAR(2),
	`country_name` VARCHAR(64),
	`region_name` VARCHAR(128),
	`city_name` VARCHAR(128),
	INDEX `idx_ip_from` (`ip_from`),
	INDEX `idx_ip_to` (`ip_to`),
	INDEX `idx_ip_from_to` (`ip_from`, `ip_to`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

LOAD DATA LOCAL
	INFILE '/IP2LOCATION-LITE-DB3.CSV'
INTO TABLE
	`ip2location`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 0 LINES;
]]--