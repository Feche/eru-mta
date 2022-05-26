local path_to_save = "files/data/login"
local MAX_CHARACTERS = 25

local rectanglew, rectangleh = 300, 300
local width, height = 150, 30
local x = sx / 2 - width / 2
local y = (sy / 2) - 220--120

local skybox_shader

local handler = false
local obj
local stars
local txd
local dff

local dts = {}
local saved = {}
local selected = 0
local yoffst = 0

addEvent("login:onPlayerLoginEx", true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setTimer(startLogin, 500, 1)
		setPlayerHudComponentVisible("all", false)
		guiSetInputMode("no_binds")
		--[[obj = createObject(691,1103.5000000,-2059.3000000,54.0000000 + 6,0.0000000,0.0000000,54.0000000 + 10) --object(sm_veg_tree4_big) (1)
		setObjectScale(obj, 2)
		obj = createObject(691,1099.9000000,-2000.0000000,54.0000000 + 6,0.0000000,0.0000000,53.9980000 + 10) --object(sm_veg_tree4_big) (2)
		setObjectScale(obj, 2)
		obj = createObject(691,1100.4000000,-2014.7000000,54.0000000 + 6,0.0000000,0.0000000,53.9980000 + 10) --object(sm_veg_tree4_big) (3)
		setObjectScale(obj, 2)
		obj = createObject(691,1105.4000000,-2076.1001000,54.0000000 + 6,0.0000000,0.0000000,53.9980000 + 10) --object(sm_veg_tree4_big) (4)
		setObjectScale(obj, 2)
		createObject(3877,1094.9000000,-2036.9000000,81.9000000,0.0000000,0.0000000,0.0000000) --object(sf_rooflite) (1)
		obj = createObject(3510,1153.3000000,-2048.2000000,68.0000000,0.0000000,0.0000000,82.0000000) --object(vgsn_nitree_r02) (1)
		setObjectScale(obj, 0.5)
		obj = createObject(3512,1152.2000000,-2025.5000000,68.0000000,0.0000000,0.0000000,0.0000000) --object(vgsn_nitree_b02) (1)
		setObjectScale(obj, 0.6)
		createObject(3276,1159.8000000,-2025.6000000,68.9000000,0.0000000,0.0000000,0.0000000) --object(cxreffencesld) (1)
		createObject(3276,1144.5000000,-2025.5000000,68.9000000,0.0000000,0.0000000,0.0000000) --object(cxreffencesld) (2)
		createObject(3276,1160.5000000,-2048.3000000,68.9000000,0.0000000,0.0000000,0.0000000) --object(cxreffencesld) (3)
		createObject(3276,1146.0000000,-2048.3000000,68.9000000,0.0000000,0.0000000,0.0000000) --object(cxreffencesld) (4)
		-- Skybox!
		skybox_shader = dxCreateShader("files/shaders/skybox/shader_skybox.fx")
		stars = dxCreateTexture("files/shaders/skybox/skybox.dds", "dxt1")
		
		dxSetShaderValue(skybox_shader, "sSkyBoxTexture1", stars)
		dxSetShaderValue(skybox_shader, "sResize", 1, 1, 1) 
		dxSetShaderValue(skybox_shader, "sStretch", 1, 1, 1)
		
		engineApplyShaderToWorldTexture(skybox_shader, "skybox_tex")
		
		txd = engineLoadTXD("files/shaders/skybox/skybox_model.txd")
		engineImportTXD(txd, 2070)
		dff = engineLoadDFF("files/shaders/skybox/skybox_model.dff")
		engineReplaceModel(dff, 2070)
		
		obj = createObject(2070, getElementPosition(localPlayer))
		setElementCollisionsEnabled(obj, false)
		setElementDimension(localPlayer, 0)
		setObjectScale(obj, 0.1)
		setElementAlpha(obj, 0)]]
		--
		dts.rectangle = { x = sx / 2 - rectanglew / 2, y = sy / 2 - rectangleh / 2 }
		dts.username = { x = x, y = y + 180 + yoffst, goup = false, progress = 0, alpha = 150, text = "" }
		dts.password = { x = x, y = dts.username.y + height + 15, goup = false, progress = 0, alpha = 150, text = "", mask = "" }
		dts.login = { x = x + 50, y = dts.password.y + 55, width = dxGetTextWidth("Login", 1.6, "roboto"), goup = false, progress = 0, alpha = 150 }
		dts.register = { x = x + 40, y = dts.login.y + 35, width = dxGetTextWidth("Register", 1.6, "roboto"), goup = false, progress = 0, alpha = 150 }
		-- Load saved data
		if fileExists(path_to_save) then
			saved.file = fileOpen(path_to_save)
			local data = fromJSON(fileRead(saved.file, fileGetSize(saved.file)))
			if data then
				dts.username.text = data.username
				dts.password.text = data.password
				for i = 1, #dts.password.text do
					dts.password.mask = dts.password.mask.. "*"
				end
			end
			fileClose(saved.file)
		end
	end
)

addEventHandler("login:onPlayerLoginEx", root,
	function()
		stopLogin()
		saveLoginData(dts.username.text, dts.password.text)
	end
)

function startLogin()
	if not handler then
		setTime(22, 0)
		setWeather(10)
		setFogDistance(300)
		setCameraTarget(localPlayer)
		addEventHandler("onClientPreRender", root, drawLogin)
		handler = true
		--setCameraMatrix(1175.3883056641, -2036.9565429688, 70.440986633301, 1075.9057617188, -2036.9503173828, 80.600555419922)
		setCameraMatrix(1479.7557373047, -1587.1430664063, 15.239374160767, 1479.9645996094, -1684.1497802734, 39.522228240967)
		fadeCamera(true)
		showCursor(true)
		setElementData(localPlayer, "state", "login")
		--
		showChat(false)
		pVeh = getElementData(localPlayer, "veh")
	end
end

function stopLogin()
	if handler then
		removeEventHandler("onClientPreRender", root, drawLogin)
		handler = false
		--[[destroyElement(skybox_shader)
		destroyElement(stars)
		destroyElement(txd)
		destroyElement(dff)
		destroyElement(obj)
		engineRestoreModel(2070)]]
		startLobby()
	end
end

local rot = 0
function drawLogin()
--	animateCameraWithCursor(1479.7557373047, -1587.1430664063, 15.239374160767, 1479.9645996094, -1684.1497802734, 39.522228240967)
	local alpha
	dxDrawRectangle(dts.rectangle.x, dts.rectangle.y + yoffst, rectanglew, rectangleh, tocolor(0, 0, 0, 150))
	dxDrawLinedRectangle(dts.rectangle.x, dts.rectangle.y + yoffst, rectanglew, rectangleh, tocolor(0, 0, 0, 255))
	dxDrawText("Extreme Racers United", 0 + 1, y + 30 + yoffst + 1, sx + 1, sy + 1, tocolor(0, 0, 0, 255), 2.4, "roboto-bold", "center")
	dxDrawText("Extreme Racers United", 0, y + 30 + yoffst, sx, sy, tocolor(120, 120, 120, 255), 2.4, "roboto-bold", "center")
--	dxDrawLine(dts.rectangle.x + 30, dts.rectangle.y + 60 + yoffst, dts.rectangle.x + 270, dts.rectangle.y + 60 + yoffst, tocolor(255, 165, 0, 150))
	-- Login welcome text
	dxDrawText("Welcome back", 0, y + 80 + yoffst, sx, y, tocolor(255, 255, 255, 255), 1.8, "roboto-bold", "center", "top")
	dxDrawText(getPlayerName(localPlayer), 0, y + 115 + yoffst, sx, y, tocolor(255, 255, 255, 255), 1.6, "roboto-medium", "center", "top", false, false, false, true)
	dxDrawText("Login with your credentials:", 0, y + 150 + yoffst, sx, y, tocolor(255, 255, 255, 255), 1, "roboto", "center", "top")
	-- Username text
	dxDrawRoundedRectangle(dts.username.x, dts.username.y, width, height, tocolor(100, 100, 100, 150), 8)
	if #dts.username.text == 0 then
		alpha = interpolateBetween(dts.username.alpha, 0, 0, 0, 0, 0, dts.username.progress, "Linear")
		dxDrawText("username", dts.username.x + 10, dts.username.y, dts.username.x + width, dts.username.y + height, tocolor(255, 255, 255, alpha), 1, "roboto", "left", "center")
	end
	dxDrawText(dts.username.text, dts.username.x + 10, dts.username.y, dts.username.x + width, dts.username.y + height, tocolor(150, 150, 150, 255), 1, "roboto", "left", "center")
	-- Password text
	dxDrawRoundedRectangle(dts.password.x, dts.password.y, width, height, tocolor(100, 100, 100, 150), 8)
	if #dts.password.text == 0 then
		alpha = interpolateBetween(dts.password.alpha, 0, 0, 0, 0, 0, dts.password.progress, "Linear")
		dxDrawText("password", dts.password.x + 10, dts.password.y, dts.password.x + width, dts.password.y + height, tocolor(255, 255, 255, alpha), 1, "roboto", "left", "center")
	end
	dxDrawText(dts.password.mask, dts.password.x + 10, dts.password.y, dts.password.x + width, dts.password.y + height, tocolor(150, 150, 150, 255), 1, "roboto", "left", "center")
	-- Login button
	alpha, pg1, pg2 = interpolateBetween(dts.login.alpha, 0, 200, 255, 200, 0, dts.login.progress, "Linear")
	dxDrawRoundedRectangle(dts.login.x - 25, dts.login.y - 3, 100, 30, tocolor(0, 0, 0, pg1), 14)
	dxDrawRoundedRectangle(dts.login.x - 25, dts.login.y - 3, 100, 30, tocolor(0, 0, 0, pg2), 8)
--	dxDrawLinedRectangle(dts.login.x - 25, dts.login.y - 3, 100, 30, tocolor(0, 0, 0, 255))
	dxDrawText("Login", dts.rectangle.x, dts.login.y, dts.rectangle.x + rectanglew, dts.login.y, tocolor(255, 255, 255, alpha), 1.6, "roboto", "center")
	-- Register button
	alpha, pg1, pg2 = interpolateBetween(dts.register.alpha, 0, 200, 255, 200, 0, dts.register.progress, "Linear")
--	dxDrawLinedRectangle(dts.login.x - 25, dts.login.y - 3, 100, 30, -1)
--	dxDrawRectangle(dts.login.x - 25, dts.register.y - 3, 100, 30, tocolor(0, 0, 0, 200))
	dxDrawRoundedRectangle(dts.login.x - 25, dts.register.y - 3, 100, 30, tocolor(0, 0, 0, pg1), 14)
	dxDrawRoundedRectangle(dts.login.x - 25, dts.register.y - 3, 100, 30, tocolor(0, 0, 0, pg2), 8)
	dxDrawText("Register", dts.rectangle.x, dts.register.y, dts.rectangle.x + rectanglew, dts.register.y, tocolor(255, 255, 255, alpha), 1.6, "roboto", "center")
	-- Login button animation rendering
	if dts.login.goup then
		dts.login.progress = dts.login.progress + 0.08 > 1 and 1 or dts.login.progress + 0.08
	elseif not dts.login.goup then
		dts.login.progress = dts.login.progress - 0.08 < 0 and 0 or dts.login.progress - 0.08
	end
	-- Register
	if dts.register.goup then
		dts.register.progress = dts.register.progress + 0.08 > 1 and 1 or dts.register.progress + 0.08
	elseif not dts.register.goup then
		dts.register.progress = dts.register.progress - 0.08 < 0 and 0 or dts.register.progress - 0.08
	end
	-- Username edit
	if dts.username.goup then
		dts.username.progress = dts.username.progress + 0.08 > 1 and 1 or dts.username.progress + 0.08
	else
		dts.username.progress = dts.username.progress - 0.08 < 0 and 0 or dts.username.progress - 0.08
	end
	-- Password edit
	if dts.password.goup then
		dts.password.progress = dts.password.progress + 0.08 > 1 and 1 or dts.password.progress + 0.08
	else
		dts.password.progress = dts.password.progress - 0.08 < 0 and 0 or dts.password.progress - 0.08
	end
	--
	if selected == 1 then
		if #dts.username.text > 0 then
			local x = dts.username.x + dxGetTextWidth(dts.username.text, 1, "roboto") + 10
			dxDrawText("|", x, dts.username.y, x, dts.username.y + height, tocolor(255, 255, 255, 200), 1, "roboto", "left", "center")
		end
	elseif selected == 2 then
		if #dts.password.text > 0 then
			local x = dts.password.x + dxGetTextWidth(dts.password.mask, 1, "roboto") + 10
			dxDrawText("|", x, dts.password.y, x, dts.password.y + height, tocolor(255, 255, 255, 200), 1, "roboto", "left", "center")
		end
	end
	--Skybox
	--[[rot = rot - 0.001
	rot = rot > 360 and 0 or rot
	local x, y, z = getCameraMatrix()
	setElementPosition(obj, x, y, z)
	dxSetShaderValue(skybox_shader, "rotateY", rot)]]
	---- Logo
--	local x, y = sx / 2 - 128, sy - 200
--	dxDrawImage(x + 2, y + 2, 256, 256, "files/img/logo.png", 0, 0, 0, tocolor(0, 0, 0, 255))
--	dxDrawImage(x, y, 256, 256, "files/img/logo.png")
end

addEventHandler("onClientCursorMove", root,
	function(_, _, cx, cy)
		if not handler then return end
		-- Login button animation
		if cx >= dts.login.x and cx <= dts.login.x + dts.login.width and cy >= dts.login.y and cy <= dts.login.y + 30 then
			dts.login.goup = true
		else
			dts.login.goup = false
		end
		-- Register
		if cx >= dts.register.x and cx <= dts.register.x + dts.register.width and cy >= dts.register.y and cy <= dts.register.y + 30 then
			dts.register.goup = true
		else
			dts.register.goup = false
		end
	end
)

addEventHandler("onClientClick", root,
	function(button, state, cx, cy)
		if not handler then return end
		if state == "up" then
			-- Username edit
			if cx >= dts.username.x and cx <= dts.username.x + width and cy >= dts.username.y and cy <= dts.username.y + height then
				dts.username.goup = true
				dts.password.goup = false
				selected = 1
			-- Password edit
			elseif cx >= dts.password.x and cx <= dts.password.x + width and cy >= dts.password.y and cy <= dts.password.y + height then
				dts.username.goup = false
				dts.password.goup = true
				selected = 2
			else
				dts.username.goup = false
				dts.password.goup = false
				selected = 0
			end
			-- Login button
			if cx >= dts.login.x and cx <= dts.login.x + dts.login.width and cy >= dts.login.y and cy <= dts.login.y + height then
				if #dts.username.text < 4 then
					showNotificationToPlayer("Username must be at least 4 characters long", "error")
				elseif #dts.password.text < 4 then
					showNotificationToPlayer("Password must be at least 4 characters long", "error")
				else
					triggerServerEvent("login:onPlayerRequestLogin", localPlayer, dts.username.text, dts.password.text)
				end
			elseif cx >= dts.register.x and cx <= dts.register.x + dts.register.width and cy >= dts.register.y and cy <= dts.register.y + height then
				if #dts.username.text < 4 then
					showNotificationToPlayer("Username must be at least 4 characters long", "error")
				elseif #dts.password.text < 4 then
					showNotificationToPlayer("Password must be at least 4 characters long", "error")
				else
					triggerServerEvent("login:onPlayerRequestRegister", localPlayer, dts.username.text, dts.password.text)
				end
			end
		end
	end
)

addEventHandler("onClientCharacter", root,
	function(key)
		if not handler then return end
		if key == " " then return end
		if selected == 1 then
			if #dts.username.text < MAX_CHARACTERS then
				dts.username.text = dts.username.text.. "" ..key
			end
		elseif selected == 2 then
			if #dts.password.text < MAX_CHARACTERS then
				dts.password.text = dts.password.text.. "" ..key
				dts.password.mask = dts.password.mask.. "*"
			end
		end
	end
)

addEventHandler("onClientKey", root,
	function(key, state)
		if not handler or not state then return end
		if key == "backspace" then
			if selected == 1 then
				dts.username.text = dts.username.text:sub(0, #dts.username.text - 1)
			elseif selected == 2 then
				dts.password.text = dts.password.text:sub(0, #dts.password.text - 1)
				dts.password.mask = dts.password.mask:sub(0, #dts.password.mask - 1)
			end
		elseif key == "tab" and state then
			if selected == 1 then
				dts.username.goup = false
				dts.password.goup = true
				selected = 2
			elseif selected == 2 then
				dts.username.goup = true
				dts.password.goup = false
				selected = 1
			else
				dts.username.goup = true
				selected = 1
			end
		end
	end
)

function saveLoginData(username, password)
	local data = { username = username, password = password }
	if fileExists(path_to_save) then
		fileDelete(path_to_save)
	end
	saved.file = fileCreate(path_to_save)
	fileWrite(saved.file, toJSON(data))
	fileClose(saved.file)
end

function animateCameraWithCursor(x1, y1, z1, x2, y2, z2)
	local cx, cy = getCursorPosition()
	if cx then
		local offx = interpolateBetween(0, 0, 0, 2, 0, 0, cx, "Linear")
		local offy = interpolateBetween(0, 0, 0, 2, 2, 0, cy, "Linear")
		setCameraMatrix(x1, y1, z1, x2 - offx, y2 - offy, z2)
	end
end

function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	_width = _width or 1
	color = color or tocolor(0, 0, 0, 255)
	dxDrawLine ( x, y, x+width, y, color, _width, postGUI ) -- Top
	dxDrawLine ( x, y, x, y+height, color, _width, postGUI ) -- Left
	dxDrawLine ( x, y+height, x+width, y+height, color, _width, postGUI ) -- Bottom
	return dxDrawLine ( x+width, y, x+width, y+height, color, _width, postGUI ) -- Right
end