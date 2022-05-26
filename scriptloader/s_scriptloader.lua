local LATENT_SPEED = 1024 -- 1024kb/sec

addEvent("loadscript:syncClientToServer", true)
addEvent("loadscript:onClientRequestFiles", true)

addEventHandler("loadscript:onClientRequestFiles", root,
	function(files)
		local tp = getPlayerGamemode(source)
		local gServerGamemodes = getElementData(root, "gServerGamemodes")
		for i = 1, #files do
			for x = 1, #gServerGamemodes[tp].files do
				if files[i] == gServerGamemodes[tp].files[x].filesrc then -- gServerGamemodes - s_race.lua
					triggerLatentClientEvent(source, "loadscript:onServerSendFiles", LATENT_SPEED * 1024, false, source, gServerGamemodes[tp].files[x], gServerGamemodes[tp].resname, i, #files)
				end
			end
		end
	end
)

addEventHandler("loadscript:syncClientToServer", root,
	function(tp, ...)
		if tp == "setElementModel" then
			setElementModel(source, ...)
		elseif tp == "addVehicleUpgrade" then
			addVehicleUpgrade(source, ...)
		elseif tp == "setVehicleColor" then
			setVehicleColor(source, ...)
		elseif tp == "setElementFrozen" then
			setElementFrozen(source, ...)
		elseif tp == "setElementInterior" then
			setElementInterior(source, ...)
		end
	end
)

function getPlayerGamemode(source)
	return getElementData(source, "room_id") or "Joined"
end