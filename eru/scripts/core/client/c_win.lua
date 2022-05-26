local showwinner = false
local winnername = ""
local winnernamenocolor = ""
local progress = 0

addEvent("race:onPlayerWin", true)

addEventHandler("race:onPlayerWin", root,
	function(_, name)
		showWinner(name)
	end
)

addEventHandler("onClientRender", root,
	function()
		if showwinner then
			progress = progress + 0.08 > 1 and 1 or progress + 0.08
		else
			progress = progress - 0.08 < 0 and 0 or progress - 0.08
		end
		local size = interpolateBetween(0, 0, 0, 2, 0, 0, progress, "Linear")
		local width = dxGetTextWidth(winnernamenocolor, size, "bankgothic")
		local width2 = dxGetTextWidth("is the winner!", size, "default")
		local x = sx / 2 - (width + width2) / 2
		dxDrawText(winnernamenocolor, x + 2, 2, x + 2, 400 + 2, tocolor(0, 0, 0, 255), size, "bankgothic", "left", "center")
		dxDrawText(winnername, x, 0, x, 400, tocolor(255, 255, 255, 255), size, "bankgothic", "left", "center", false, false, false, true)
		dxDrawText("is the winner!", x + width + 5 + 2, 4 + 2, x + width + 5 + 2, 400 + 4 + 2, tocolor(0, 0, 0, 255), size, "default", "left", "center")
		dxDrawText("is the winner!", x + width + 5, 4, x + width + 5, 400 + 4, tocolor(255, 255, 255, 255), size, "default", "left", "center")
	end
)

function showWinner(name)
	showwinner = true
	winnername = name
	winnernamenocolor = name:gsub("#%x%x%x%x%x%x", "")
	setTimer(function() showwinner = false end, 5000, 1)
end