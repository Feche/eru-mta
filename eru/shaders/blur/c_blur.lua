local sx, sy = guiGetScreenSize()
blurShader = nil
local isScreenBlurred = false

addEventHandler("onClientResourceStart", resourceRoot,	
	function()
		blurShader, tech = dxCreateShader("files/shaders/blur/blur.fx")
		if blurShader then
			screenTXD = dxCreateScreenSource(sx, sy)
			dxSetShaderValue(blurShader, "ScreenSource", screenTXD)
		--	outputDebugString("Blur shader loaded, using technique " ..tech)
		else
			outputDebugString("[SHADER] Failed to create shader 'files/shaders/blur/blur.fx'")
		end
	end
)

function setScreenBlurLevel(blur)
	dxSetShaderValue(blurShader, "BlurStrength", 1000 - ((800 / 255) * blur))
end

function setScreenBlurVisible(state)
	if not state and isScreenBlurred then
		removeEventHandler("onClientPreRender", root, drawBlurredScreen)
		isScreenBlurred = false
	elseif not isScreenBlurred then
		addEventHandler("onClientPreRender", root, drawBlurredScreen)
		isScreenBlurred = true
	end
end

function drawBlurredScreen()
	if screenTXD then
		dxUpdateScreenSource(screenTXD)
		dxDrawImage(-5, -5, sx + 5, sy + 5, blurShader)
	end
end