---
--- Replaced client side functions go in this file (for the sake of neatness)
---

events = {}
commands = {}
binds = {}
sshaders = {}
textures = {}
fonts = {}
ddff = {}
ttxd = {}
ccol = {}
files = {}
xml = {}

--- 
--- GENERAL FUNCTIONS
---

function setElementData_internal(source, key, value)
	return setElementData(source, key, value, false)
end

function setElementModel_internal(source, modelid)
	triggerServerEvent("loadscript:syncClientToServer", source, "setElementModel", modelid)
end

---
--- DIMENSION-SYNCED FUNCTIONS
---

function createWater_internal(...)
	local water = createWater(...)
	setElementDimension(water, getElementDimension(localPlayer))
	return water
end

function createObject_internal(...)
	local object = createObject(...)
	setElementDimension(object, getElementDimension(localPlayer))
	return object
end

function createPed_internal(...)
	local ped = createPed(...)
	setElementDimension(ped, getElementDimension(localPlayer))
	return ped
end

function createVehicle_internal(...)
	local veh = createVehicle(...)
	setElementDimension(veh, getElementDimension(localPlayer))
	return veh
end

function createMarker_internal(...)
	local marker = createMarker(...)
	setElementDimension(marker, getElementDimension(localPlayer))
	return marker
end

function createColCircle_internal(...)
	local col = createColCircle(...)
	setElementDimension(col, getElementDimension(localPlayer))
	return col
end

function createColCuboid_internal(...)
	local col = createColCuboid(...)
	setElementDimension(col, getElementDimension(localPlayer))
	return col
end

function createColSphere_internal(...)
	local col = createColSphere(...)
	setElementDimension(col, getElementDimension(localPlayer))
	return col
end

function createColTube_internal(...)
	local col = createColTube(...)
	setElementDimension(col, getElementDimension(localPlayer))
	return col
end

function createColPolygon_internal(...)
	local col = createColPolygon(...)
	setElementDimension(col, getElementDimension(localPlayer))
	return col
end

function createProjectile_internal(...)
	if getElementDimension(localPlayer) ~= 5 then
		return createProjectile(...)
	end
end

---
--- PATH-DEPENDANT FUNCTIONS
---

-- File functions

function fileOpen_internal(path, readonly)
	if not fileExists(CACHE_DIR .. path) then return end
	local f = fileOpen(CACHE_DIR .. path, readonly)
	table.insert(files, f)
	return f
end

function fileCreate_internal(path)
	local f = fileCreate(CACHE_DIR .. path)
	table.insert(files, f)
	return f
end

-- Engine functions

function engineLoadTXD_internal(path, filtering)
--	if not fileExists(CACHE_DIR .. path) then return end
	local t = engineLoadTXD(CACHE_DIR .. path, filtering)
	if isElement(t) then
		table.insert(ttxd, t)
	end
	return t
end

function engineLoadDFF_internal(path, modelid)
--	if not fileExists(CACHE_DIR .. path) then return end
	local d = engineLoadDFF(CACHE_DIR .. path, modelid)
	if isElement(d) then
		table.insert(ddff, d)
	end
	return d
end

function engineLoadCOL_internal(path)
	if not fileExists(CACHE_DIR .. path) then return end
	local c = engineLoadCOL(CACHE_DIR .. path)
	table.insert(ccol, c)
	return c
end

-- XML

function xmlLoadFile_internal(path)
	if not fileExists(CACHE_DIR .. path) then return end
	local x = xmlLoadFile(CACHE_DIR .. path)
	table.insert(xml, x)
	return x
end

-- DX

function dxDrawImage_internal(x, y, w, h, path, ...)
	if type(path) == "string" then
		if not fileExists(CACHE_DIR .. path) then return end
		return dxDrawImage(x, y, w, h, CACHE_DIR .. path, ...)
	end
	return dxDrawImage(x, y, w, h, path, ...)
end

function dxDrawImageSection_internal(x, y, w, h, u, v, usize, vsize, path, ...)
	if type(path) == "string" then
		if not fileExists(CACHE_DIR .. path) then return end
		dxDrawImageSection(x, y, w, h, u, v, usize, vsize, CACHE_DIR .. path, ...)
	end
	return dxDrawImageSection(x, y, w, h, u, v, usize, vsize, path, ...)
end

function dxCreateFont_internal(path, ...)
	if not fileExists(CACHE_DIR .. path) then return end
	local font = dxCreateFont(CACHE_DIR .. path, ...)
	if isElement(font) then
		table.insert(fonts, font)
	end
	return font
end

function dxCreateTexture_internal(arg1, arg2, arg3, arg4, arg5, arg6)
	if not tonumber(arg1) then
		if #arg1 < 50 then
			arg1 = CACHE_DIR .. arg1
			if not fileExists(arg1) then return end
		end
	end
	local texture = dxCreateTexture(arg1, arg2, arg3, arg4, arg5, arg6)
	if isElement(texture) then
		table.insert(textures, texture)
	end
	return texture
end

function dxCreateShader_internal(path)
	if not fileExists(CACHE_DIR .. path) then return end
	local shader = dxCreateShader(CACHE_DIR .. path)
	if isElement(shader) then
		table.insert(sshaders, shader)
	end
	return shader
end 

---
--- HANDLERS
---

function addEventHandler_internal(name, attachedto, handlerfunc)
	if type(name) == "string" and isElement(attachedto) and type(handlerfunc) == "function" then
		-- Don't add these handlers on trials maps
		if name == "onClientRender" or name == "onClientPreRender" and getElementDimension(localPlayer) == 11 then 
			return 
		end 
		table.insert(events, { name, attachedto, handlerfunc })
		return addEventHandler(name, attachedto, handlerfunc)
	end
end

function addCommandHandler_internal(name, handlerfunc)
	if type(name) == "string" and type(handlerfunc) == "function" then
		table.insert(commands, { name, handlerfunc })
		return addCommandHandler(name, handlerfunc)
	end
end

function bindKey_internal(key, state, handlerfunc, ...)
	if getElementDimension(localPlayer) ~= 5 then -- Don't bind on Shooter
		table.insert(binds, { key, state, handlerfunc })
		return bindKey(key, state, handlerfunc, ...)
	end
end

function unbindKey_internal(key, state, handlerfunc)
	if getElementDimension(localPlayer) ~= 5 then
		unbindKey(key, state, handlerfunc)
	end
end