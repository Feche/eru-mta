local Trials = {}
Trials.handler = nil
Trials.colspheres = {}
--
Trials.rank = 1
Trials.checkpoint = 0
Trials.progress = 0
Trials.totalcheckpoints = 0
Trials.currentw = 0
--
Trials.camera =
{
	14,
	-2,
	6,
	progress = 0,
	oldvalue = 0
}

addEvent("lobby:onPlayerJoinGamemode", true)
addEvent("race:onRaceMapStop", true)
addEvent("trials:updatePlayerRank", true)

addEvent("lobby:onPlayerJoinLobby")
addEvent("trials:manageCheckpoints")

addEventHandler("lobby:onPlayerJoinGamemode", root,
	function(tp)
		if tp == "Trials" then
			Trials.addHandlers()
		end
	end
)

addEventHandler("lobby:onPlayerJoinLobby", root,
	function()
		Trials.removeHandlers()
		Trials.checkpoint = 0
		Trials.rank = 1
		Trials.totalcheckpoints = 0
		Trials.colspheres = {}
	end
)

addEventHandler("race:onRaceMapStop", root,
	function(tp)
		if tp == "Trials" then
			Trials.checkpoint = 0
			Trials.rank = 1
			Trials.totalcheckpoints = 0
			Trials.colspheres = {}
		end
	end
)

addEventHandler("trials:updatePlayerRank", root,
	function(rank)
		Trials.rank = rank
	end
)

addEventHandler("trials:manageCheckpoints", root, -- Called from c_core.lua
	function(markers)
		local dimension = getElementDimension(localPlayer)
		for i = 1, #markers do
			setElementDimension(markers[i], i == 1 and dimension or 100)
			setMarkerType(markers[i], "corona")
			setMarkerColor(markers[i], 0, 0, 255, 100)
			setMarkerSize(markers[i], 1)
			local x, y, z = getElementPosition(markers[i])
			local offstz = -2.2
			setElementPosition(markers[i], x, y, z + offstz)
			--
			local col = createColSphere(x, y, z, 3.5)
			setElementDimension(col, i == 1 and dimension or 100)
			table.insert(Trials.colspheres, { col, markers[i] })
		end
		Trials.totalcheckpoints = #Trials.colspheres
--		outputChatBox('created ' ..#Trials.coronas.. " coronas")
		setDevelopmentMode(true)
	end
)

function Trials.colHit(element, matchingdimension)
	if pVeh == element and matchingdimension then
		for i = 1, #Trials.colspheres do
			if Trials.colspheres[i][1] == source then
				setElementDimension(Trials.colspheres[i][1], 100)
				setElementDimension(Trials.colspheres[i][2], 100)
				Trials.checkpoint = Trials.checkpoint + 1
				Trials.progress = 0
				triggerServerEvent("trials:managePlayerRank", localPlayer, Trials.checkpoint)
				if Trials.colspheres[i + 1] then
					local dimension = getElementDimension(localPlayer)
					setElementDimension(Trials.colspheres[i + 1][1], dimension)
					setElementDimension(Trials.colspheres[i + 1][2], dimension)
				elseif #Trials.colspheres == Trials.checkpoint then
					-- Player finish race
				end
				break
			end
		end
	end
end

function Trials.draw()
	local data = getElementData(localPlayer, "trials.pos")
	if not data then return end
	local vehicle = pVeh
	if vehicle then
		local x, y, z = getElementPosition(vehicle)
		local rx, ry, rz = getElementRotation(vehicle)
		local posX, posY = data.posX, data.posY
		setElementPosition(vehicle, data.posX or x, data.posY or y, z)
		setElementRotation(vehicle, rx, 0, data.rotZ)
		Trials.camera.progress = getVehicleSpeed(pVeh) / 150
		local speedOffset = interpolateBetween(Trials.camera[2], 0, 0, Trials.camera[2] + 15, 0, 0, Trials.camera.progress, "Linear")
		local cx, cy, cz = getPositionFromElementOffset(vehicle, Trials.camera[1], Trials.camera[2] + -speedOffset, 0)
		setCameraMatrix(cx, cy, z + Trials.camera[3], data.posX or x, data.posY or y, z)
	--	dxDrawText("cx = " ..cx, 500, 500)
		--
		--
		--
		local pwidth, pheight = 400, 30
		Trials.progress = Trials.progress + 0.08 > 1 and 1 or Trials.progress + 0.08
		local scale = pwidth / (Trials.totalcheckpoints == 0 and 1 or Trials.totalcheckpoints)
		local y = interpolateBetween(sy + 36, 0, 0, sy - 41, 0, 0, gRace.progress, "Linear")
		local w = interpolateBetween(Trials.currentw, 0, 0, (scale * Trials.checkpoint) == 0 and 1 or (scale * Trials.checkpoint), 0, 0, Trials.progress, "Linear")
		if Trials.progress == 1 then
			Trials.currentw = w 
		end
		local x
		x = sx / 2 - pwidth / 2
		y = y + 10
		dxDrawRoundedRectangle(x, y, pwidth, pheight, tocolor(0, 0, 0, 150), 10)
		dxDrawRoundedRectangle(x + 5, y + 5, w - 10, pheight - 10, tocolor(253, 106, 2, 255), 10)
		local rank = type(Trials.rank) == "number" and ((Trials.rank < 10 or Trials.rank > 20) and ({ [1] = 'st', [2] = 'nd', [3] = 'rd' })[Trials.rank % 10] or 'th') or Trials.rank
		dxDrawText("Position: " ..Trials.rank.. "" ..rank.. "\nCheckpoint: " ..Trials.checkpoint.. "/" ..Trials.totalcheckpoints, 0, 0, sx, sy - 38, tocolor(255, 255, 255, 255 * gRace.progress), 1.4, "roboto-bold", "center", "bottom")
	end
end

function Trials.damage()
	local vehicle = pVeh
	if vehicle then
		local evx, evy, evz = getElementVelocity(vehicle)
		setElementVelocity(vehicle, evx, evy, evz + 0.5)
		setTimer(
			function()
				setGravity(0.002)
				setTimer(setGravity, 1000, 1, 0.008)
			end
		, 100, 1)
	end
end

function Trials.addHandlers()
	if not Trials.handler then
		addEventHandler("onClientPreRender", root, Trials.draw)
		addEventHandler("onClientPlayerDamage", localPlayer, Trials.damage)
		addEventHandler("onClientColShapeHit", root, Trials.colHit)
		Trials.handler = true
		outputDebugString("[TRIALS] Adding trials handlers")
	end
end

function Trials.removeHandlers()
	if Trials.handler then
		removeEventHandler("onClientPreRender", root, Trials.draw)
		removeEventHandler("onClientPlayerDamage", localPlayer, Trials.damage)
		removeEventHandler("onClientColShapeHit", root, Trials.colHit)
		Trials.handler = false
		outputDebugString("[TRIALS] Removing trials handlers")
	end
end