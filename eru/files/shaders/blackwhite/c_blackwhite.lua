local screenSource = dxCreateScreenSource(sx, sy)
local START, END = 15, 0.8
local blackWhiteShader
local handler = false
local prs = END
local godown = nil

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		blackWhiteShader = dxCreateShader("files/shaders/blackwhite/blackwhite.fx")
	end
)

function drawShader()
	dxUpdateScreenSource(screenSource)     
    dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
	dxDrawImage(0, 0, sx, sy, blackWhiteShader)
	--
	if godown then
		prs = prs - 0.8 < END and END or prs - 0.8
	else
		prs = prs + 0.01 > START and START or prs + 0.01
	end
	dxSetShaderValue(blackWhiteShader, "strong", prs)
	--
	if prs == START and not godown then
		removeEventHandler("onClientPreRender", root, drawShader)
		handler = false
	end
end

function showBlackWhite()
	if screenSource and blackWhiteShader then
		if not handler then
			addEventHandler("onClientPreRender", root, drawShader)
			handler = true
		end
		prs = START
		godown = true
	end
end

function removeBlackWhite()
	if screenSource and blackWhiteShader and handler then
		godown = false
	end
end

function stopBlackWhite()
	if handler then
		removeEventHandler("onClientPreRender", root, drawShader)
		handler = false
	end
end