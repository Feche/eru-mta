local size = 32

addEventHandler("onClientRender", root, 
	function()
		local players = getElementsByType("player", root, true) -- Get only streamed players
		for i = 1, #players do
		--	if players[i] ~= localPlayer then
				local state = getElementData(players[i], "state")
				if getElementData(players[i], "chatting") then 
					if state == "alive" or state == "training" then
						local veh = getPedOccupiedVehicle(players[i])
						local target = veh and veh or localPlayer
						local x, y, z = getElementPosition(target)
						local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer))
						local alpha = 255 - (dist * 2)
						x, y = getScreenFromWorldPosition(x, y, z + 1.2)
						if x then
							dxDrawImage(x - (size / 2), y - (size / 2), size, size, "files/img/misc/chat.png", 0, 0, 0, tocolor(255, 255, 255, alpha < 0 and 0 or alpha))
						end
					end
				end
		--	end
		end
	end
)

function checkPlayerChatting()
	if isChatBoxInputActive() or isConsoleActive() then
		setElementData(localPlayer, "chatting", true)
	else
		setElementData(localPlayer, "chatting", false)
	end
end
setTimer(checkPlayerChatting, 500, 0)
bindKey("g", "down", "chatbox", "Global")