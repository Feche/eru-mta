local _DEBUG = true

sandbox = {}
sandbox.created = false
sandbox.env = {}
sandbox.scripts = {}
sandbox.trials = {}

local check = {}
check.block = 
{ 
	"loadstring", "load", "call",
	"fetchRemote", 
	"addEvent", "triggerEvent", "triggerServerEvent", 
	"fileDelete", 
	"outputChatBox", 
	"playSound", "playSound3D", "setSoundVolume",
	"setFPSLimit",
	"engineSetModelLODDistance", "setCloudsEnabled", "getResourceName",
	"guiCreateWindow", "guiCreateMemo", "guiSetInputEnabled", "guiCreateButton"
}

check.badspell =
{
	"setCloudEnabled"
}

check.replace =
{
	"unbindKey", "bindKey",
	"addCommandHandler", "addEventHandler",
	"dxCreateShader", "dxCreateTexture", "dxCreateFont", "dxDrawImageSection", "dxDrawImage",
	"xmlLoadFile",
	"engineLoadCOL", "engineLoadDFF", "engineLoadTXD",
	"fileCreate", "fileOpen",
	"createProjectile",
	"createColPolygon", "createColTube", "createColSphere", "createColCuboid", "createColCircle",
	"createMarker", "createVehicle", "createPed", "createObject", "createWater",
	"setElementData", "setElementModel"
}

local function shouldReplace(func)
	for i = 1, #check.replace do
		if check.replace[i] == func then
			return true
		end
	end
	return false
end

local function shouldBlock(func)
	for i = 1, #check.block do
		if check.block[i] == func then
			return true
		end
	end
	return false
end

local _outputDebugString = outputDebugString
local function outputDebugString(...)
	if _DEBUG then
		_outputDebugString(...)
	end
end

function sandbox.Create()
	sandbox.env = {}
	sandbox.scripts = {}
	sandbox.trials = {}
	for name, func in pairs(_G) do
		if not shouldBlock(name) then
			local replaced = shouldReplace(name) and name .. "_internal" or name
			sandbox.env[name] = _G[replaced]
		else
			sandbox.env[name] = function() end
		end
	end
	-- Add 'bad spelled' functions (bad map script)
	for i = 1, #check.badspell do
		sandbox.env[check.badspell[i]] = function() end
	end
	setmetatable(sandbox.env, 
	{
        __index = function(_, index)
            if index == "source" then
                return _G.source
            else
                return rawget(sandbox.env, index)
            end
        end
    })
	sandbox.created = true
	outputDebugString("[SANDBOX] Created sandbox")
end

function sandbox.Destroy()
	sandbox.created = false
	sandbox.env = nil
	sandbox.scripts = nil
	sandbox.trials = nil
	setElementData(localPlayer, "trials.pos", sandbox.trials, false)
	outputDebugString("[SANDBOX] Destroyed sandbox")
end

function sandbox.LoadScript(script, scriptname)
	if not sandbox.created then
		sandbox.Create()
	end
	local func = loadstring(script)
	table.insert(sandbox.scripts, { func, scriptname })
	-- Get posX or posY for Trials
	if not sandbox.trials.posX and not sandbox.trials.posY and not sandbox.trials.rotZ then
		if getElementDimension(localPlayer) == 11 then
			if script:find("cameraOffsets") or script:find("onClientPreRender") then
				for varname, value in string.gmatch(script, "(%S+) = (%S+)") do
					if varname == "posX" then
						sandbox.trials.posX = value
					elseif varname == "posY" then
						sandbox.trials.posY = value
					elseif varname == "rotZ" then
						sandbox.trials.rotZ = value
					end
					--
					if sandbox.trials.posX and sandbox.trials.posY and sandbox.trials.rotZ then
						break
					end
				end
			end
			if sandbox.trials.posX or sandbox.trials.posY or sandbox.trials.rotZ then
				sandbox.trials.posX = tonumber(sandbox.trials.posX)
				sandbox.trials.posY = tonumber(sandbox.trials.posY)
				sandbox.trials.rotZ = tonumber(sandbox.trials.rotZ)
				setElementData(localPlayer, "trials.pos", sandbox.trials, false)
			end
		end
	end
end

function sandbox.StartScripts()
	if not sandbox.scripts then return end
	for i = 1, #sandbox.scripts do
		local func, scriptname = sandbox.scripts[i][1], sandbox.scripts[i][2]
		setfenv(func, sandbox.env)
		local localPlayer = _G[localPlayer]
		func()
	end
	setTimer(triggerEvent, 500, 1, "onClientResourceStart", resourceRoot)
end

_outputDebugString("[SANDBOX] Sandbox script started")