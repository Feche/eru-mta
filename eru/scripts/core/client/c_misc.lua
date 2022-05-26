local fps = 0
local tick = getTickCount()

local images = {}

local randomMessages =
{
	"#ff6464[INFO] #FFFFFFHold L or F1 to return to lobby",
	"#ff6464[INFO] #FFFFFFPress F4 to enable car hide, and F3 to enable car fade",
	"#ff6464[INFO] #FFFFFFMake sure to check the settings on your userpanel [F7]",
	"#ff6464[INFO] #FFFFFFOpen your userpanel by pressing F7",
	"#ff6464[INFO] #FFFFFFView current map toptimes by pressing F5",
	"#ff6464[INFO] #FFFFFFYou can buy maps using /bm [map name]",
	"#ff6464[INFO] #FFFFFFCreate your clan by pressing F7 -> Clans",
	"#ff6464[INFO] #FFFFFFCheck server rankings by pressing F7 -> Rankings",
	"#ff6464[INFO] #FFFFFFYou can train with your friends by making a room on training mode!",
	"#ff6464[INFO] #FFFFFFYou can /like or /dislike maps",
	"#ff6464[INFO] #FFFFFFIf you are enjoying the server, make sure to add us to your favorites!",
	"#ff6464[INFO] #FFFFFFYou can change your nick using /setnick [name]",
	"#ff6464[INFO] #FFFFFFOur forum is www.eru-crew.com",
	"#ff6464[INFO] #FFFFFFSuggestions for the server are welcome!",
	"#ff6464[INFO] #FFFFFFOur Discord server link is https://discord.gg/2waFXsP",
	"#ff6464[INFO] #FFFFFFYou can set radio songs by pressing F7 -> Radio",
	"#ff6464[INFO] #FFFFFFChange between radio or map songs on your userpanel settings [F7]",
	"#ff6464[INFO] #FFFFFFMute current music by pressing M",
	"#ff6464[INFO] #FFFFFFFor more information, you can go to the help tab on your userpanel",
	"#ff6464[INFO] #FFFFFFMake your vehicle unique, head to Tune your ride on lobby screen!",
	"#ff6464[INFO] #FFFFFFYou can send private messages using /pm [name] [message]",
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		outputChatBox(randomMessages[math.random(#randomMessages)], 255, 255, 255, true)
		setTimer(
			function()
				outputChatBox(randomMessages[math.random(#randomMessages)], 255, 255, 255, true)
			end
		, 120000, 0)
		setTimer(function() setElementData(localPlayer, "fps", fps) end, 5000, 0) -- Update FPS on scoreboard
	end
)

local fpscount = 0
addEventHandler("onClientRender", root,
	function()
		fpscount = fpscount + 1
		if getTickCount() - tick >= 1000 then
			fps = fpscount
			tick = getTickCount()
			fpscount = 0
		end
		local spectators = getElementData(localPlayer, "spectators") or 0
		local text = spectators > 0 and (spectators.. " spectator(s) - ") or ""
		dxDrawText(text.. "" ..fps.. " fps", 0 + 1, 0 + 1, sx + 1, sy + 1 - 12, tocolor(0, 0, 0, 255), 1, "roboto", "right", "bottom")
		dxDrawText(text.. "" ..fps.. " fps", 0, 0, sx, sy - 12, -1, 1, "roboto", "right", "bottom")
	end
)

_dxDrawImage = dxDrawImage
function dxDrawImage(x, y, w, h, image, ...)
	if not isElement(image) then
		if not images[image] then
			images[image] = dxCreateTexture(image)
		--	outputDebugString("[IMAGE] Created image texture for " ..image)
		end
		return _dxDrawImage(x, y, w, h, images[image], ...)
	else
		return _dxDrawImage(x, y, w, h, image, ...)
	end
end