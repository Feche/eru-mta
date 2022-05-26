local MAX_SEC = 3

local queue = {}

addEvent("notification:showPlayerJoinLeaveGamemode", true)

addEventHandler("onClientRender", root,
	function()
		if queue[1] then
			if not queue[1].tickset then
				queue[1].tick = getTickCount()
				queue[1].tickset = true
				queue[1].goup = true
			else
				if getTickCount() - queue[1].tick >= MAX_SEC * 1000 then
					queue[1].goup = false
				end
			end
			if queue[1].goup then
				queue[1].progress = queue[1].progress + 0.06 > 1 and 1 or queue[1].progress + 0.06
			else 
				queue[1].progress = queue[1].progress - 0.06 < 0 and 0 or queue[1].progress - 0.06
				if queue[1].progress == 0 then
					table.remove(queue, 1)
					return
				end
			end
			local x = sx - queue[1].width - 10
			local y = sy / 2
			dxDrawText(queue[1].msgnocolor, sx - queue[1].width - 10 + 1, y + 1, sx + 1, y + 1, tocolor(0, 0, 0, 255 * queue[1].progress), 1, "roboto", "center", "center")
			dxDrawText(queue[1].msg, sx - queue[1].width - 10, y, sx, y, tocolor(255, 255, 255, 255 * queue[1].progress), 1, "roboto", "center", "center", false, false, false, true)
			if queue[1].join then	
				dxDrawImage(x - 14 + 1, y - 8 + 1, 16, 16, "files/img/joinquit/join.png", 0, 0, 0, tocolor(0, 0, 0, 255 * queue[1].progress))
				dxDrawImage(x - 14, y - 8, 16, 16, "files/img/joinquit/join.png", 0, 0, 0, tocolor(255, 255, 255, 255 * queue[1].progress))
			else
				dxDrawImage(x - 16 + 1, y - 8 + 1, 16, 16, "files/img/joinquit/quit.png", 0, 0, 0, tocolor(0, 0, 0, 255 * queue[1].progress))
				dxDrawImage(x - 16, y - 8, 16, 16, "files/img/joinquit/quit.png", 0, 0, 0, tocolor(255, 255, 255, 255 * queue[1].progress))
			end
		end
	end
)

addEventHandler("notification:showPlayerJoinLeaveGamemode", root,
	function(msg, join)
		showJoinMessage(msg, join)
	end
)

function showJoinMessage(msg, join)
	local nocolor = msg:gsub("#%x%x%x%x%x%x", "")
	queue[#queue + 1] = { msg = msg, msgnocolor = nocolor, progress = 0, tick = 0, tickset = false, goup = false, join = join, width = dxGetTextWidth(nocolor, 1, "roboto")}
end