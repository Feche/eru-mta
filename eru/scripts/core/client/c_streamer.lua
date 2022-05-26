local DRAW_DISTANCE = 1000

local moreDrawDistanceModels = 
{
	8558, 3458, 18450, 8838
}

local gStreamer = {}
local iStreamed = {}

local streamTimer = nil

function createStreamedObjects(objects)
	if isTimer(streamTimer) then
		killTimer(streamTimer)
	end
	gStreamer = {}
	iStreamed = {}
	for i = 1, #objects do
		local obj = createObject(objects[i].modelid, objects[i].posx, objects[i].posy, objects[i].posz, objects[i].rotx, objects[i].roty, objects[i].rotz, objects[i].islowlod)
		if obj then
			setElementInterior(obj, objects[i].interior or 0)
			setElementDimension(obj, getElementDimension(localPlayer))
			setObjectScale(obj, objects[i].scale or 1)
			if objects[i].doublesided then
				setElementDoubleSided(obj, objects[i].doublesided)
			end
			-- extended draw distance
			for x = 1, #moreDrawDistanceModels do
				if moreDrawDistanceModels[x] == objects[i].modelid then
					extendedDrawDistance(obj)
				end
			end
		end
	end
	setFarClipDistance(DRAW_DISTANCE)
	setFogDistance(300)
	streamTimer = setTimer(streamObjects, DRAW_DISTANCE, 0)
	streamObjects()
--	outputDebugString("[STREAMER] " ..#gStreamer.. " objects streamed")
end

function extendedDrawDistance(parent)
	local lowlodobj = createObject(getElementModel(parent), 0, 0, 0, 0, 0, 0, true)
	setElementPosition(lowlodobj, getElementPosition(parent))
	setElementRotation(lowlodobj, getElementRotation(parent))
	setObjectScale(lowlodobj, getObjectScale(parent))
	setElementDoubleSided(lowlodobj, isElementDoubleSided(parent))
	setElementDimension(lowlodobj, getElementDimension(localPlayer))
	setElementInterior(parent, 100)
	setElementDimension(parent, 100)
	setElementDimension(lowlodobj, 100)
	table.insert(gStreamer, { parent, lowlodobj })
end

function streamObjects()
	local dimension = getElementDimension(localPlayer)
	for i = 1, #gStreamer do
		local obj = gStreamer[i][1]
		if isElement(obj) then
			local x, y, z = getElementPosition(obj)
			local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(getCameraTarget() or localPlayer))
			if dist <= DRAW_DISTANCE then
				if getElementDimension(obj) ~= dimension then
					for x = 1, 2 do
						setElementDimension(gStreamer[i][x], dimension)
					end
				end
			else
				if getElementDimension(obj) ~= 100 then
					for x = 1, 2 do
						setElementDimension(gStreamer[i][x], 100)
					end
				end
			end
		end
	end
end