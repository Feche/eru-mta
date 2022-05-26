--
-- c_bloom.lua
--
local orderPriority = "-1.0"	-- The lower this number, the later the effect is applied

local Settings = {}
Settings.var = {}

----------------------------------------------------------------
-- enableBloom
----------------------------------------------------------------

function enableBloom()
	if bEffectEnabled2 then return end
	-- Create things
	myScreenSource2 = dxCreateScreenSource( scx/2, scy/2 )

	blurHShader2,tecName = dxCreateShader( "files/shaders/bloom/fx/blurH.fx" )
--	outputDebugString( "blurHShader2 is using technique " .. tostring(tecName) )

	blurVShader2,tecName = dxCreateShader( "files/shaders/bloom/fx/blurV.fx" )
--	outputDebugString( "blurVShader2 is using technique " .. tostring(tecName) )

	brightPassShader,tecName = dxCreateShader( "files/shaders/bloom/fx/brightPass.fx" )
--	outputDebugString( "brightPassShader is using technique " .. tostring(tecName) )

    addBlendShader,tecName = dxCreateShader( "files/shaders/bloom/fx/addBlend.fx" )
--	outputDebugString( "addBlendShader is using technique " .. tostring(tecName) )

	-- Get list of all elements used
	effectParts2 = {
						myScreenSource2,
						blurVShader2,
						blurHShader2,
						brightPassShader,
						addBlendShader,
					}

	-- Check list of all elements used
	bAllValid2 = true
	for _,part in ipairs(effectParts2) do
		bAllValid2 = part and bAllValid2
	end
	
	setEffectVariables2 ()
	bEffectEnabled2 = true
	
	if not bAllValid2 then
		outputChatBox( "Bloom: Could not create some things. Please use debugscript 3" )
		disableBloom()
	end	
end

-----------------------------------------------------------------------------------
-- disableBloom
-----------------------------------------------------------------------------------
function disableBloom()
	if not bEffectEnabled2 then return end
	-- Destroy all shaders
	for _,part in ipairs(effectParts2) do
		if part then
			destroyElement( part )
		end
	end
	effectParts2 = {}
	bAllValid2 = false
	RTPool2.clear()
	
	-- Flag effect as stopped
	bEffectEnabled2 = false
end

---------------------------------
-- Settings for effect
---------------------------------
function setEffectVariables2()
    local v = Settings.var
    -- Bloom
    v.cutoff = 0.08
    v.power = 1.88
	v.blur = 1
    v.bloom = 4
    v.blendR = 204
    v.blendG = 153
    v.blendB = 130
    v.blendA = 100

	-- Debugging
    v.PreviewEnable=0
    v.PreviewPosY=0
    v.PreviewPosX=100
    v.PreviewSize=70
end

-----------------------------------------------------------------------------------
-- onClientHUDRender
-----------------------------------------------------------------------------------
addEventHandler( "onClientHUDRender", root,
    function()
		if not bAllValid2 or not Settings.var then return end
		local v = Settings.var	
			
		-- Reset render target pool
		RTPool2.frameStart()
		DebugResults2.frameStart()
		-- Update screen
		dxUpdateScreenSource( myScreenSource2, true )
			
		-- Start with screen
		local current2 = myScreenSource2

		-- Apply all the effects, bouncing from one render target to another
		current2 = applyBrightPass( current2, v.cutoff, v.power )
		current2 = applyDownsample2( current2 )
		current2 = applyDownsample2( current2 )
		current2 = applyGBlurH2( current2, v.bloom, v.blur )
		current2 = applyGBlurV2( current2, v.bloom, v.blur )

		-- When we're done, turn the render target back to default
		dxSetRenderTarget()

		-- Mix result onto the screen using 'add' rather than 'alpha blend'
		if current2 then
			dxSetShaderValue( addBlendShader, "TEX0", current2 )
			local col = tocolor(v.blendR, v.blendG, v.blendB, v.blendA)
			dxDrawImage( 0, 0, scx, scy, addBlendShader, 0,0,0, col )
		end
		-- Debug stuff
		if v.PreviewEnable > 0.5 then
			DebugResults2.drawItems ( v.PreviewSize, v.PreviewPosX, v.PreviewPosY )
		end
	end
,true ,"low" .. orderPriority )


-----------------------------------------------------------------------------------
-- Apply the different stages
-----------------------------------------------------------------------------------
function applyDownsample2( Src, amount )
	if not Src then return nil end
	amount = amount or 2
	local mx,my = dxGetMaterialSize( Src )
	mx = mx / amount
	my = my / amount
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT )
	dxDrawImage( 0, 0, mx, my, Src )
	DebugResults2.addItem( newRT, "applyDownsample2" )
	return newRT
end

function applyGBlurH2( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurHShader2, "TEX0", Src )
	dxSetShaderValue( blurHShader2, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurHShader2, "BLOOM", bloom )
	dxSetShaderValue( blurHShader2, "BLUR", blur )
	dxDrawImage( 0, 0, mx, my, blurHShader2 )
	DebugResults2.addItem( newRT, "applyGBlurH2" )
	return newRT
end

function applyGBlurV2( Src, bloom, blur )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( blurVShader2, "TEX0", Src )
	dxSetShaderValue( blurVShader2, "TEX0SIZE", mx,my )
	dxSetShaderValue( blurVShader2, "BLOOM", bloom )
	dxSetShaderValue( blurVShader2, "BLUR", blur )
	dxDrawImage( 0, 0, mx,my, blurVShader2 )
	DebugResults2.addItem( newRT, "applyGBlurV2" )
	return newRT
end

function applyBrightPass( Src, cutoff, power )
	if not Src then return nil end
	local mx,my = dxGetMaterialSize( Src )
	local newRT = RTPool2.GetUnused(mx,my)
	if not newRT then return nil end
	dxSetRenderTarget( newRT, true ) 
	dxSetShaderValue( brightPassShader, "TEX0", Src )
	dxSetShaderValue( brightPassShader, "CUTOFF", cutoff )
	dxSetShaderValue( brightPassShader, "POWER", power )
	dxDrawImage( 0, 0, mx,my, brightPassShader )
	DebugResults2.addItem( newRT, "applyBrightPass" )
	return newRT
end