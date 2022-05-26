local customFonts = { "roboto", "roboto-bold", "roboto-medium", "segoeui-medium" }

local fonts = {}

_dxDrawText = dxDrawText
function dxDrawText(text, x, y, w, h, color, size, font, ...)
	if font and isCustomFont(font) then
		return _dxDrawText(text, x, y, w, h, color, 1, getFontBySize(font, size), ...)
	else
		if not w then
			_dxDrawText(text, x, y)
		else
			return _dxDrawText(text, x, y, w, h, color, size, font or "default", ...)
		end
	end
end

_dxGetTextWidth = dxGetTextWidth
function dxGetTextWidth(text, size, font)
	if font and isCustomFont(font) then 
		return _dxGetTextWidth(text, 1, getFontBySize(font, size))
	else
		return _dxGetTextWidth(text, size, font)
	end
end

function isCustomFont(font)
	for i = 1, #customFonts do
		if font == customFonts[i] then
			return true
		end
	end
	return false
end

function getFontBySize(font, size)
	size = tostring(size)
	if not fonts[font] then
		fonts[font] = {}
	end
	if not fonts[font][size] then
		fonts[font][size] = dxCreateFont("files/fonts/" ..font.. ".ttf", 9 * size, false, "cleartype")
	--	outputDebugString("[FONTS] Created font " ..font.. ", size " ..(9 * size))
	end
	return fonts[font][size]
end