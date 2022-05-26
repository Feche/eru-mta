--
-- c_switch.lua
--

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
	--	triggerEvent( "switchContrast", resourceRoot, true )
	end
)

--------------------------------
-- Command handler
--		Toggle via command
--------------------------------
addCommandHandler( "contrast",
	function()
	--	triggerEvent( "switchContrast", resourceRoot, not bEffectEnabled2 )
	end
)


--------------------------------
-- Switch effect on or off
--------------------------------
function switchContrast( bOn )
--	outputChatBox("contrast = " ..tostring(bOn))
	if bOn then
		enableContrast()
	else
		disableContrast()
	end
end
addEvent( "switchContrast", true )
addEventHandler( "switchContrast", resourceRoot, switchContrast )


