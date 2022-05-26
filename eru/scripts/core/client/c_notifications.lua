--[[ NOTIFICATION TYPES
		1 - Success/OK
		2 - Warning
		3 - Error
		4 - Info	--]]
local sX, sY = guiGetScreenSize()

local height = 41
local screenOffset = 5
local margin = 5

local image = "files/img/misc/notifications.png"

local iconWidth = 35
local tileWidth = 22
local tileOffset = 36
local closerWidth = 6
local closerOffset = 58

local notifications = {}

local color = {
	[1] = {255, 255, 255},
	[2] = {80, 80, 80},
	[3] = {255, 255, 255},
	[4] = {255, 255, 255},
}

addEvent("notification:showNotificationToPlayer", true)

addEventHandler("notification:showNotificationToPlayer", root,
	function(text, tp)
		showNotificationToPlayer(text, tp)
	end
)

function showNotificationToPlayer(nText, nType, nDuration)
	if nType == "error" then nType = 3 end
	if nType == "warning" then nType = 2 end
	if nType == "info" then nType = 1 end
	if not nText or not nType then return end

	if not tonumber(nDuration) and nDuration ~= false then
		nDuration = 5000 --set to default duration of 5 seconds if not specified
	end
	
	local nWidth = dxGetTextWidth(nText, 1, "default-bold") + 10 + closerWidth + iconWidth
	local index = table.maxn(notifications) + 1
	
	table.insert(notifications, index, {text=nText, type=tonumber(nType), duration=tonumber(nDuration), added=getTickCount(), alpha=0, state="fadeIn", multiplier=1, width=nWidth})
	
	setSoundVolume(playSound("files/sounds/notif.ogg"), 0.5)
	
	return index
	
end

function removeNotification(index)
	if not index then return end
	
	notifications[tonumber(index)] = nil
end

addEventHandler("onClientRender", root,
	function ()
		local yOffset = margin

		for k, v in pairs(notifications) do
			
			if v.duration and v.state ~= "fadeOut" and v.state ~= "shrink" and getTickCount() - v.added >= v.duration then
				v.state = "fadeOut"
				v.multiplier = 1
			end
			
			if v.state == "fadeIn" then
				v.multiplier = v.multiplier * 1.1
				v.alpha = math.min(v.alpha + 3 * v.multiplier, 255)
				
				if v.alpha == 255 then
					v.state = nil
				end
			elseif v.state == "fadeOut" then
				v.multiplier = v.multiplier * 1.1
				v.alpha = math.max(v.alpha - 3 * v.multiplier, 0)
				
				if v.alpha == 0 then
					v.heightMultiplier = 1
					v.state = "shrink"
				end
			elseif v.state == "shrink" then
				v.heightMultiplier = math.max( 0, v.heightMultiplier - 0.07 )

				if v.heightMultiplier == 0 then
					notifications[k] = nil
				end
			end
			
		
			local tiledWidth = v.width - iconWidth - closerWidth
			local r, g, b = unpack(color[v.type])
			
			dxDrawImageSection(sX - v.width - screenOffset, yOffset, iconWidth, height, 0, (v.type - 1) * height, iconWidth, height, image, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)
			
			dxDrawImageSection(sX - v.width - screenOffset + iconWidth, yOffset, tiledWidth, height, tileOffset, (v.type - 1) * height, tileWidth, height, image, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)
			
			dxDrawImageSection(sX - v.width - screenOffset + iconWidth + tiledWidth, yOffset, closerWidth, height, closerOffset, (v.type - 1) * height, closerWidth, height, image, 0, 0, 0, tocolor(255, 255, 255, v.alpha), true)
			
			if v.type ~= 2 and v.type ~= 4 then
				dxDrawText(removeColorCoding(v.text), sX - v.width + iconWidth + 1, yOffset + 1, sX - screenOffset - closerWidth + 1, yOffset + height + 1, tocolor(0, 0, 0, 125 * v.alpha / 255), 1, "default-bold", "center", "center", true, false, true)
			end
			
			dxDrawText(v.text, sX - v.width + iconWidth, yOffset, sX - screenOffset - closerWidth, yOffset+height, tocolor(r, g, b, v.alpha), 1, "default-bold", "center", "center", true, false, true, true)
		
			yOffset = yOffset + ( v.heightMultiplier or 1 ) * ( height + margin )
		end
	end
)

function removeColorCoding(text)
	return text
end