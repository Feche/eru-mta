local sx, sy = guiGetScreenSize()

CACHE_DIR = "" -- Shared with c_scriptloader_functions.lua
local CURR_RESNAME = ""
local CURR_SCRIPTS = {}
local _DEBUG = true

-- Download graph variables
local dPercent = 0
local handler = false
local lastUpdate = getTickCount()

addEvent("loadscript:onServerSendFiles", true)

addEventHandler("loadscript:onServerSendFiles", root,
	function(file, resname, currentfile, totalfiles)
		if CURR_RESNAME ~= resname then
			if _DEBUG then
				outputDebugString("[LOADSCRIPT] onServerSendFiles: aborting creation of file '" ..file.filesrc.. "' since map changed")
				downloadProgress(100)
				return
			end
		end
		local path = CACHE_DIR .. file.filesrc
		local f = fileCreate(path)
		fileWrite(f, file.data)
		fileClose(f)
		downloadProgress((100 / totalfiles) * currentfile)
		if _DEBUG then
			outputDebugString("[LOADSCRIPT] onServerSendFiles: created file '" ..file.filesrc.. "'")
		end
		-- All files downloaded, load scritps
		if currentfile == totalfiles then
			-- Load scripts after file creation
			setTimer(loadClientScripts, 1000, 1)
			downloadProgress(100)
		end
	end
)

function unloadClientScripts()
	triggerEvent("onClientResourceStop", resourceRoot)
	for id, event in ipairs(events) do
		if isElement(event[2]) and type(event[3]) == "function" then
			removeEventHandler(event[1], event[2], event[3])
		end
	end
	-- Remove commands
	for id, command in ipairs(commands) do
		removeCommandHandler(command[1], command[2])
	end
	-- Unbind keys
	for id, bind in ipairs(binds) do
		unbindKey(bind[1], bind[2], bind[3])
	end
	-- Kill timers
	for id, timer in ipairs(getTimers()) do
		killTimer(timer)
	end
	-- Shaders
	for i = 1, #sshaders do
		if isElement(sshaders[i]) then
			destroyElement(sshaders[i])
		end
	end
	-- Textures
	for i = 1, #textures do
		if isElement(textures[i]) then
			destroyElement(textures[i])
		end
	end
	-- Fonts
	for i = 1, #fonts do
		if isElement(fonts[i]) then
			destroyElement(fonts[i])
		end
	end
	-- DFF
	for i = 1, #ddff do
		if isElement(ddff[i]) then
			destroyElement(ddff[i])
		end
	end
	-- TXT
	for i = 1, #ttxd do
		if isElement(ttxd[i]) then
			destroyElement(ttxd[i])
		end
	end
	-- COL
	for i = 1, #ccol do
		if isElement(ccol[i]) then
			destroyElement(ccol[i])
		end
	end
	-- Close files
	for i = 1, #files do
		fileClose(files[i])
	end
	-- Unload XML
	for i = 1, #xml do
		if xml[i] then
			xmlUnloadFile(xml[i])
		end
	end
	-- Restore to default
	events = {}
	commands = {}
	binds = {}
	sshaders = {}
	textures = {}
	fonts = {}
	ddff = {}
	txd = {}
	col = {}
	files = {}
	xml = {}
	-- Resetting world back to default
	resetSkyGradient()
	resetSunSize()
	resetSunColor()
	resetHeatHaze()
	resetRainLevel()
	resetWindVelocity()
	resetFarClipDistance()
	resetFogDistance()
	resetWaterColor()
	resetWaterLevel()
	setGameSpeed(1)
	setGravity(0.008)
	setWorldSpecialPropertyEnabled("hovercars", false)
	setWorldSpecialPropertyEnabled("aircars", false)
	setWorldSpecialPropertyEnabled("extrabunny", false)
	setWorldSpecialPropertyEnabled("extrajump", false)
	restoreAllWorldModels()
	sandbox.Destroy()
	-- Restore sandbox
	if _DEBUG then
		outputDebugString("[LOADSCRIPT] destroyClientScript: destroyed client script")
	end
end

-- Export called from c_core.lua
function loadClientScripts()
	for i = 1, #CURR_SCRIPTS do
		sandbox.LoadScript(CURR_SCRIPTS[i].data, tostring(CURR_SCRIPTS[i].filesrc))
	end
	sandbox.StartScripts()
	if _DEBUG then
		outputDebugString("[LOADSCRIPT] loadClientScript: loaded " ..#CURR_SCRIPTS.. " clientside scripts")
	end
end

function checkClientFiles(files, resname, scripts)
	CACHE_DIR = "/cache/" ..resname.. "/"
	CURR_SCRIPTS = scripts -- Client scripts, ex: music.lua
	CURR_RESNAME = resname
	--
	local filestodownload = {}
	-- Client files, ex: infernus.dff, photo.png
	for i = 1, #files do
		if files[i] then
			local path = CACHE_DIR .. files[i].filesrc
			if not fileExists(path) then
				filestodownload[#filestodownload + 1] = files[i].filesrc
				if _DEBUG then
					outputDebugString("[LOADSCRIPT] loadClientFiles: requesting file '" ..files[i].filesrc.. "'")
				end
			else
				if getFileMD5(path) ~= files[i].md5 then
					filestodownload[#filestodownload + 1] = files[i].filesrc
					fileDelete(path)
					if _DEBUG then
						outputDebugString("[LOADSCRIPT] loadClientFiles: md5 hash for file '" ..files[i].filesrc.. "' doesn't match, requesting new file")
					end
				else
					if _DEBUG then
						outputDebugString("[LOADSCRIPT] loadClientFiles: md5 hash for file '" ..files[i].filesrc.. "' matchs, skipping file creation")
					end
				end
			end
		end
	end
	-- If some or all files don't exist, request download to server
	if #filestodownload > 0 then
		triggerServerEvent("loadscript:onClientRequestFiles", localPlayer, filestodownload)
		return false
	end
	return true
end

function getFileMD5(path)
	local file = fileOpen(path, true)
	if file then
		local data = fileRead(file, fileGetSize(file)) 
		fileClose(file)
		return hash("md5", data)
	end
	return "nil"
end

local size = 128
local x, y = sx / 2 - size / 2, sy / 2 + 200
function drawDownloadProgress()
	local r, g, b = 255, 127, 0 -- Orange color
	for i = 1, 360 do
		if i <= dPercent then
			dxDrawImage(x, y, size, size, "img/12px.png", i, 0, 0, tocolor(r, g, b))
		else
			dxDrawImage(x, y, size, size, "img/12px.png", i, 0, 0, tocolor(40, 40, 40))
		end
	end
	dxDrawImage(x, y, size, size, "img/12px.png", dPercent, 0, 0, tocolor(r, g, b))
	dxDrawText(math.floor(dPercent / 3.6).. "%", x, y, x + size, y + size, -1, 2, "default-bold", "center", "center")
	if getTickCount() - lastUpdate > 2200 then
		downloadProgress((dPercent / 3.6) + math.random(1, 2))
	end
end

function downloadProgress(percent)
	if percent >= 100 then
		removeEventHandler("onClientRender", root, drawDownloadProgress)
		handler = false
	else
		if not handler then
			addEventHandler("onClientRender", root, drawDownloadProgress)
			handler = true
		end
	end
	dPercent = percent * 3.6
	lastUpdate = getTickCount()
end
--downloadProgress(50)