--
-- c_RTPool2.lua
--

scx, scy = guiGetScreenSize ()

-----------------------------------------------------------------------------------
-- Pool of render targets
-----------------------------------------------------------------------------------
RTPool2 = {}
RTPool2.list = {}

function RTPool2.frameStart()
	for rt,info in pairs(RTPool2.list) do
		info.bInUse = false
	end
end

function RTPool2.GetUnused( sx, sy )
	-- Find unused existing
	for rt,info in pairs(RTPool2.list) do
		if not info.bInUse and info.sx == sx and info.sy == sy then
			info.bInUse = true
			return rt
		end
	end
	-- Add new
--	outputDebugString( "creating new RT " .. tostring(sx) .. " x " .. tostring(sx) )
	local rt = dxCreateRenderTarget( sx, sy )
	if rt then
		RTPool2.list[rt] = { bInUse = true, sx = sx, sy = sy }
	end
	return rt
end

function RTPool2.clear()
	for rt,info in pairs(RTPool2.list) do
		destroyElement(rt)
	end
	RTPool2.list = {}
end


-----------------------------------------------------------------------------------
-- DebugResults2
-- Store all the rendertarget results for debugging
-----------------------------------------------------------------------------------
DebugResults2 = {}
DebugResults2.items = {}

function DebugResults2.frameStart()
	DebugResults2.items = {}
end

function DebugResults2.addItem( rt, label )
	table.insert( DebugResults2.items, { rt=rt, label=label } )
end

function DebugResults2.drawItems( sizeX, sliderX, sliderY )
	local posX = 5
	local gapX = 4
	local sizeY = sizeX * 90 / 140
	local textSizeY = 15 + 10
	local posY = 5
	local textColor = tocolor(0,255,0,255)
	local textShad = tocolor(0,0,0,255)

	local numImages = #DebugResults2.items
	local totalWidth = numImages * sizeX + (numImages-1) * gapX
	local totalHeight = sizeY + textSizeY

	posX = posX - (totalWidth - (scx-10)) * sliderX / 100
	posY = posY - (totalHeight - scy) * sliderY / 100

	local textY = posY+sizeY+1
	for index,item in ipairs(DebugResults2.items) do
		dxDrawImage( posX, posY, sizeX, sizeY, item.rt )
		local sizeLabel = string.format( "%d) %s %dx%d", index, item.label, dxGetMaterialSize( item.rt ) )
		dxDrawText( sizeLabel, posX+1.0, textY+1, posX+sizeX+1.0, textY+16, textShad,  1, "arial", "center", "top", true )
		dxDrawText( sizeLabel, posX,	 textY,   posX+sizeX,     textY+15, textColor, 1, "arial", "center", "top", true )
		posX = posX + sizeX + gapX
	end
end