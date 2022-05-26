addEvent("race:onRaceMapStop")
addEvent("race:onRaceMapStart")

addEvent("shooter:addPlayerShooterKill", true)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "Shooter" then
			setElementData(root, "shooter.ghostmode", true)
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Shooter" then
			setElementData(root, "shooter.ghostmode", true)
			showNotificationToGamemode("Disabling ghostmode in 15 seconds", "Shooter", "warning")
			setTimer(
				function()
					setElementData(root, "shooter.ghostmode", false)
					showNotificationToGamemode("Ghostmode disabled", "Shooter", "warning")
				end
			, 15000, 1)
		end
	end
)

addEventHandler("shooter:addPlayerShooterKill", root,
	function()
		addPlayerShooterKill(source)
	end
)