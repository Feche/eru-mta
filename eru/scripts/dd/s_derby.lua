addEvent("race:onRaceMapStop")
addEvent("race:onRaceMapStart")

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "Destruction Derby A" or tp == "Destruction Derby B" then
			setElementData(root, tp == "Destruction Derby A" and "dda.ghostmode" or "ddb.ghostmode", true)
		end
	end
)

addEventHandler("race:onRaceMapStart", root,
	function(tp)
		if tp == "Destruction Derby A" or tp == "Destruction Derby B" then
			setElementData(root, tp == "Destruction Derby A" and "dda.ghostmode" or "ddb.ghostmode", true)
			showNotificationToGamemode("Disabling ghostmode in 5 seconds", tp, "warning")
			setTimer(
				function()
					setElementData(root, tp == "Destruction Derby A" and "dda.ghostmode" or "ddb.ghostmode", false)
					showNotificationToGamemode("Ghostmode disabled", tp, "warning")
				end
			, 5000, 1)
		end
	end
)