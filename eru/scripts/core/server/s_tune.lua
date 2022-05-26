addEvent("tune:onPlayerRequestBuy", true)

addEvent("login:onPlayerLoginEx")

addEventHandler("tune:onPlayerRequestBuy", root,
	function(tp, id, r, g, b)
		local pStats = getPlayerStats(source)
		if tp == "wheel" then
			if getPlayerMoney(source) < 20000 then
				showNotificationToPlayer(source, "You don't have enough money", "error")
			else
				pStats.vehicle.wheel = id
				setElementData(source, "stats", pStats)
				--
				if id == -1 then
					local upgrades = getVehicleUpgrades(pVeh[source])
					for i = 1, #upgrades do
						removeVehicleUpgrade(pVeh[source], upgrades[i])
					end
					showNotificationToPlayer(source, "Wheels removed", "warning")
				else
					showNotificationToPlayer(source, "Wheels bought", "info")
					givePlayerMoney(source, -20000)
				end
			end
		elseif tp == "rear light" then
			if getPlayerMoney(source) < 50000 then
				showNotificationToPlayer(source, "You don't have enough money", "error")
			else
				pStats.vehicle.rearlight = id
				setElementData(source, "stats", pStats)
				triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "rear lights", id)
				showNotificationToPlayer(source, "Lights bought", "info")
				givePlayerMoney(source, -50000)
			end
		elseif tp == "nos" then
			if getPlayerMoney(source) < 45000 then
				showNotificationToPlayer(source, "You don't have enough money", "error")
			else
				pStats.vehicle.noscolor = { r, g, b }
				setElementData(source, "stats", pStats)
				triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "nos", _, r, g, b)
				showNotificationToPlayer(source, "NOS color bought", "info")
				givePlayerMoney(source, -45000)
			end
		elseif tp == "plate" then
			if getPlayerMoney(source) < 10000 then
				showNotificationToPlayer(source, "You don't have enough money", "error")
			elseif #id == 0 then
				showNotificationToPlayer(source, "Please insert a text", "error")
			else
				pStats.vehicle.plate = id
				setElementData(source, "stats", pStats)
				setVehiclePlateText(pVeh[source], id)
				showNotificationToPlayer(source, "Plate text set", "info")
				givePlayerMoney(source, -10000)
			end
		elseif tp == "paint" then
			if id == -1 then
				pStats.vehicle.paint = false
				setElementData(source, "stats", pStats)
				showNotificationToPlayer(source, "Paint removed", "warning")
			elseif id == 100 then
				if getPlayerMoney(source) < 25000 then
					showNotificationToPlayer(source, "You don't have enough money", "error")
				else
					pStats.vehicle.paint = { r, g, b }
					setElementData(source, "stats", pStats)
					setVehicleColor(pVeh[source], r, g, b, r, g, b, r, g, b, r, g, b)
					givePlayerMoney(source, -25000)
					showNotificationToPlayer(source, "Paint bought", "info")
				end
			else
				if getPlayerMoney(source) < 150000 then
					showNotificationToPlayer(source, "You don't have enough money", "error")
				else
					pStats.vehicle.paint = id
					setElementData(source, "stats", pStats)
					triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "paint", id)
					givePlayerMoney(source, -150000)
					showNotificationToPlayer(source, "Paint bought", "info")
				end
			end
		elseif tp == "front lights" then
			if id == -1 then
				pStats.vehicle.frontlight = false
				setElementData(source, "stats", pStats)
				triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "front lights", 100)
				showNotificationToPlayer(source, "Light effect/color removed", "warning")
			elseif id == 100 then
				if getPlayerMoney(source) < 20000 then
					showNotificationToPlayer(source, "You don't have enough money", "error")
				else
					pStats.vehicle.frontlight = { r, g, b }
					setElementData(source, "stats", pStats)
					setVehicleHeadLightColor(pVeh[source], r, g, b)
					givePlayerMoney(source, -20000)
					showNotificationToPlayer(source, "Headlight color bought", "info")
				end
			else
				if getPlayerMoney(source) < 60000 then
					showNotificationToPlayer(source, "You don't have enough money", "error")
				else
					pStats.vehicle.frontlight = id
					setElementData(source, "stats", pStats)
					triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "front lights", id)
					givePlayerMoney(source, -60000)
					showNotificationToPlayer(source, "Headlight animation bought", "info")
				end
			end
		end
	end
)

addEventHandler("login:onPlayerLoginEx", root,
	function(stats)
		-- Rear light DVO
		if stats.vehicle.rearlight > 0 then
			triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "rear lights", stats.vehicle.rearlight)
		end
		-- NOS Color
		if stats.vehicle.noscolor then
			triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "nos", _, unpack(stats.vehicle.noscolor))
		end
		-- NOS Color
		if stats.vehicle.plate then
			setVehiclePlateText(pVeh[source], stats.vehicle.plate)
		end
		-- Paint DVO
		if type(stats.vehicle.paint) == "number" then
			triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "paint", stats.vehicle.paint)
		end
		-- Headlight animation
		if type(stats.vehicle.frontlight) == "number" then
			triggerClientEvent(source, "tunning:setVehicleDVO", pVeh[source], "front lights", stats.vehicle.frontlight)
		end
	end
)