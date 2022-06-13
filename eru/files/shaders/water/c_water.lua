local myShader = nil
local shaderTimer = nil

function setWaterShaderStatus(status)
	if status then
		myShader = dxCreateShader("files/shaders/water/water.fx")
		if not myShader then
			outputChatBox("Water shader could not be initialized.", 255, 255, 0)
			return
		end
		local textureVol = dxCreateTexture("files/shaders/water/images/smallnoise3d.dds");
		local textureCube = dxCreateTexture("files/shaders/water/images/cube_env256.dds");
		dxSetShaderValue(myShader, "sRandomTexture", textureVol);
		dxSetShaderValue(myShader, "sReflectionTexture", textureCube);
		engineApplyShaderToWorldTexture(myShader, "waterclear256")
		refreshWaterColor()
		shaderTimer = setTimer(refreshWaterColor, 2500, 0)
	else
		if myShader then
			killTimer(shaderTimer)
			engineRemoveShaderFromWorldTexture(myShader, "waterclear256")
			destroyElement(myShader)
			myShader = nil
		end
	end
end

function refreshWaterColor()
	if myShader then
		local r, g, b, a = getWaterColor()
		dxSetShaderValue(myShader, "sWaterColor", r/255, g/255, b/255, a/255)
	end
end