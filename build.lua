local config = {
    colors = {
        esp_player_box = "255 255 255 255",
        esp_player_name = "255 255 255 255",
        esp_player_hp = "0 255 0 255",
        esp_player_weapon = "255 255 255 255",
        esp_player_rank = "255 255 255 255",
        esp_entity_name = "255 255 255 255"
    },
    keybinds = {
        aim_onkey_key = 0,
        menu_key = 10,
        logger_key = 0,
        panic_key = 0
    },
    aim_master_toggle = false,
    aim_onkey = true,
    aim_hitbox = 1,
    aim_fov = 15,
    aim_norecoil = false,
    aim_smoothing = true,
    aim_smoothing_value = 0.20,
    aim_ignoreinvis = true,
    esp_player_box = false,
    esp_player_name = false,
    esp_player_hp = false,
    esp_player_weapon = false,
    esp_player_rank = false,
    esp_player_team = false,
    esp_player_render_distance = 3700,
    esp_player_dormant = true,
    esp_entity_name = false,
    esp_render_mode = false,
    config_name = nil,
    name_font_size = 13,
    name_font = 1,
    flags_font_size = 13,
    flag_font = 1,
    friends = {},
    entities = {}
}
local hooks = {}
local verifyconfig = config
local frame, frameX, frameY, sheet, entityFrame, entityFrameX, entityFrameY, entityFrameWasOpen
local activeTab
local ss = false
local frametime, deviation = engine.ServerFrameTime()
local intp, toggledelay3, toggledelayN = false, false, false
local Fonts = {"Tahoma"}

local function UpdateNameFont()
	surface.CreateFont("KeypadBold",{font = Fonts[config["name_font"]], size = config["name_font_size"]})
end

local function UpdateFlagFont()
	surface.CreateFont("KeypadFont",{font = Fonts[config["flag_font"]], size = config["flags_font_size"]})
end
UpdateNameFont()
UpdateFlagFont()

local function GetRenderMode()
	return config["esp_render_mode"] and "unsafe" or "protected"
end

local function GetENTPos ( Ent )
	if Ent:IsValid() then 
		local Points = {
			Vector( Ent:OBBMaxs().x, Ent:OBBMaxs().y, Ent:OBBMaxs().z ),
			Vector( Ent:OBBMaxs().x, Ent:OBBMaxs().y, Ent:OBBMins().z ),
			Vector( Ent:OBBMaxs().x, Ent:OBBMins().y, Ent:OBBMins().z ),
			Vector( Ent:OBBMaxs().x, Ent:OBBMins().y, Ent:OBBMaxs().z ),
			Vector( Ent:OBBMins().x, Ent:OBBMins().y, Ent:OBBMins().z ),
			Vector( Ent:OBBMins().x, Ent:OBBMins().y, Ent:OBBMaxs().z ),
			Vector( Ent:OBBMins().x, Ent:OBBMaxs().y, Ent:OBBMins().z ),
			Vector( Ent:OBBMins().x, Ent:OBBMaxs().y, Ent:OBBMaxs().z )
		}
		local MaxX, MaxY, MinX, MinY
		local V1, V2, V3, V4, V5, V6, V7, V8
		local isVis
		for k, v in pairs( Points ) do
			local ScreenPos = Ent:LocalToWorld( v ):ToScreen()
			isVis = ScreenPos.visible
			if MaxX != nil then
				MaxX, MaxY, MinX, MinY = math.max( MaxX, ScreenPos.x ), math.max( MaxY, ScreenPos.y), math.min( MinX, ScreenPos.x ), math.min( MinY, ScreenPos.y)
			else
				MaxX, MaxY, MinX, MinY = ScreenPos.x, ScreenPos.y, ScreenPos.x, ScreenPos.y
			end

			if V1 == nil then
				V1 = ScreenPos
			elseif V2 == nil then
				V2 = ScreenPos
			elseif V3 == nil then
				V3 = ScreenPos
			elseif V4 == nil then
				V4 = ScreenPos
			elseif V5 == nil then
				V5 = ScreenPos
			elseif V6 == nil then
				V6 = ScreenPos
			elseif V7 == nil then
				V7 = ScreenPos
			elseif V8 == nil then
				V8 = ScreenPos
			end
		end
		return MaxX, MaxY, MinX, MinY, V1, V2, V3, V4, V5, V6, V7, V8, isVis
	end
end

local fakeRT = GetRenderTarget( "fakeRT" .. os.time(), ScrW(), ScrH() )
 
hook.Add("RenderScene", "x", function( vOrigin, vAngle, vFOV )
	if ( !gui.IsConsoleVisible() && !gui.IsGameUIVisible() ) || ss then
	    local view = {
	        x = 0,
	        y = 0,
	        w = ScrW(),
	        h = ScrH(),
	        dopostprocess = true,
	        origin = vOrigin,
	        angles = vAngle,
	        fov = vFOV,
	        drawhud = true,
	        drawmonitors = true,
	        drawviewmodel = true
	    }
	 
	    render.RenderView( view )
	    render.CopyTexture( nil, fakeRT )
	 
	    cam.Start2D()
	        hook.Run( "CheatHUDPaint" )
	    cam.End2D()

	    render.SetRenderTarget( fakeRT )
	 
	    return true
	end
end )
 
hook.Add("ShutDown", "c", function()
    render.SetRenderTarget()
end )

local renderv = render.RenderView
local renderc = render.Clear
local rendercap = render.Capture
local rendercappix = render.CapturePixels
local vguiworldpanel = vgui.GetWorldPanel
render.CapturePixels = function() return end
 
local function screengrab()
	if ss then return end
	ss = true
 
	renderc( 0, 0, 0, 255, true, true )
	renderv( {
		origin = LocalPlayer():EyePos(),
		angles = LocalPlayer():EyeAngles(),
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH(),
		dopostprocess = true,
		drawhud = true,
		drawmonitors = true,
		drawviewmodel = true
	} )
 
	local vguishits = vguiworldpanel()
 
	if IsValid( vguishits ) then
		vguishits:SetPaintedManually( true )
	end
 
	timer.Simple( 0.1, function()
		vguiworldpanel():SetPaintedManually( false )
		ss = false
	end)
end
 
render.Capture = function(data)
	screengrab()
	local cap = rendercap( data )
	return cap
end

local function GetIgnorePlayers(ply)
    if config["aim_ignorefriends"] then
        if table.HasValue(config["friends"], ply:SteamID()) then
            return false
        end
    end

    return true
end

local function ValidateESP(ply)
    if not IsValid(ply) then return false end
    if ply == LocalPlayer() then return false end
    if not ply:IsPlayer() and not ply:IsBot() then return false end
    if not ply:Alive() then return false end
    if config["esp_player_dormant"] then
        if ply:IsDormant() then return false end
    end
    if ply:GetPos():Distance(LocalPlayer():GetPos()) > config["esp_player_render_distance"] then return false end
    return true
end

local function ValidateAimbot(ply)
    if not IsValid(ply) then return false end
    if not ply:IsPlayer() and not ply:IsBot() then return false end
    if ply == LocalPlayer() then return false end
    if not ply:Alive() then return false end
    if ply:Team() == TEAM_SPECTATOR then return false end
    if ply:IsDormant() then return false end
    if not GetIgnorePlayers(ply) then return false end
    if ply:GetPos():Distance(LocalPlayer():GetPos()) > config["esp_player_render_distance"] then return false end
    return true
end

local playerTable = {}

hook.Add("Think", "b", function()
	for k, v in pairs(player.GetAll()) do
		if ValidateESP(v) && !table.HasValue(playerTable, v) then
			table.insert(playerTable, v)
		elseif !ValidateESP(v) && table.HasValue(playerTable, v) then
			table.RemoveByValue(playerTable, v)
		end
	end
end)

hook.Add("CalcView", "n", function(ply, pos, ang, fov)
    if !intp && !NoclipOn then
        local Camera = {}

        if config["aim_norecoil"] then
            Camera.angles = LocalPlayer():EyeAngles()
        end
        
        return Camera
    end
end)

local OEyeAngles = OEyeAngles or FindMetaTable( "Player" ).SetEyeAngles

FindMetaTable( "Player" ).SetEyeAngles = function( self, angle )

    if ( string.find( string.lower( debug.getinfo( 2 ).short_src ), "/weapons/" ) ) and config["aim_norecoil"] then return end

    OEyeAngles( self, angle )

end

local function CloseFrame()
	frameX, frameY = frame:GetPos()
	RememberCursorPosition()
	frame:Remove()
	frame = false
end

local function Unload()
	if frame then
		frame:Remove()
	end
	if entityFrame then
		entityFrame:Remove()
	end
	for k, v in pairs(hooks) do
		hook.Remove(v, k)
	end
	for k, v in pairs(player.GetAll()) do
		v:SetRenderMode(0)
	end
end

local function CheckBox(lbl, x, y, cfg, col, par)

    local checkBox = vgui.Create("DCheckBoxLabel", par)
    checkBox:SetText(lbl)
    checkBox:SetPos(x, y)
    checkBox:SetValue(config[cfg])

    function checkBox:OnChange(bVal)
        config[cfg] = bVal
    end
    
    if col then
        local cx, cy = checkBox:GetPos()
        local colorPicker = vgui.Create("DImageButton", par)
        colorPicker:SetSize(16, 16)
        colorPicker:SetPos(cx + checkBox:GetWide() + 5, y - 1)

        function colorPicker:DoClick()
            if IsValid(colorWindow) then
                colorWindow:Remove()
            end
            colorWindow = vgui.Create("DFrame")
            colorWindow:SetSize(300, 225)
            local frameX, frameY = frame:GetPos()
            if frameX + 350 > ScrW() then
                colorWindow:Center()
            else
                colorWindow:SetPos(frameX + 350, frameY)
            end
            colorWindow:MakePopup()

            local colorSelector = vgui.Create("DColorMixer", colorWindow)
            colorSelector:SetColor(string.ToColor(config.colors[cfg]))

            function colorSelector:ValueChanged(val)
                local r = tostring(val.r)
                local g = tostring(val.g)
                local b = tostring(val.b)
                local a = tostring(val.a)
                local col = r.." "..g.." "..b.." "..a
                config.colors[cfg] = col
            end
        end
    end
end

local function Label(lbl, x, y, par)

	local label = vgui.Create("DLabel", par)
	label:SetText(lbl)
	local w, h = label:GetTextSize()
	label:SetSize(w, h)
	label:SetPos(x, y)

end

local function Slider(lbl, x, y, cfg, min, max, dec, par)

	local sliderLabel = vgui.Create("DLabel", par)
	sliderLabel:SetText(lbl)
	local w, h = sliderLabel:GetTextSize()
	sliderLabel:SetWide(w)
	sliderLabel:SetPos(x, y - h / 8)

	local slider = vgui.Create("DNumSlider", par)
	slider:SetWide(490)
	slider:SetPos(x - 210, y + 10)
	slider:SetMin(min)
	slider:SetMax(max)
	slider:SetTooltip(lbl)
	slider:SetDefaultValue(config[cfg])
	slider:ResetToDefaultValue()
	slider:SetDecimals(dec)
	function slider:OnValueChanged()
		config[cfg] = slider:GetValue()
	end

end

local function Dropdown(lbl, x, y, choices, cfg, par)

	local dropdownLabel = vgui.Create("DLabel", par)
	dropdownLabel:SetText(lbl)
	local w, h = dropdownLabel:GetTextSize()
	dropdownLabel:SetWide(w)
	dropdownLabel:SetPos(x, y - h / 8)

	local dropdown = vgui.Create("DComboBox", par)
	dropdown:SetSize(150, 20)
	dropdown:SetPos(x, y + 20)
	for k, v in ipairs(choices) do
		dropdown:AddChoice(v)
	end
	dropdown:SetSortItems(false)
	dropdown:ChooseOptionID(config[cfg])
	function dropdown:OnSelect(index, value, data)
		config[cfg] = index
	end
end

local function Bind(x, y, cfg, par)

	local keyBind = vgui.Create("DBinder", par)
	keyBind:SetValue(config.keybinds[cfg])
 	keyBind:SetSize(80, 16)
 	keyBind:SetPos(x, y)
 	keyBind.OnChange = function()
 		config.keybinds[cfg] = keyBind:GetValue()
 	end
end

local function Button(lbl, tooltip, fnc, x, y, par)

	local button = vgui.Create("DButton", par)
	button:SetSize(130, 20)
	button:SetPos(x, y)
	button:SetText(lbl)
	button:SetTooltip(tooltip)
	function button:DoClick()
		fnc()
	end
end

local function EntList()

	if not entityFrame then

		entityFrame = vgui.Create("DFrame")
		entityFrame:SetSize(400, 200)
		entityFrame:SetTitle("")
		if entityFrameX == nil or entityFrameY == nil then
			entityFrame:Center()
		else
			entityFrame:SetPos(entityFrameX, entityFrameY)
		end
		entityFrame:MakePopup()
		entityFrame.Paint = function(self, w, h)
			draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 255))
		end

		function entityFrame:OnClose()
			entityFrameX, entityFrameY = entityFrame:GetPos()
			entityFrame = false
		end

		local entList = vgui.Create("DListView", entityFrame)
		entList:DockMargin(0, 0, 100, 0)
		entList:Dock(FILL)
		entList:SetMultiSelect(false)
		entList:AddColumn("entities")

		entList.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
		end

		for _, col in ipairs(entList.Columns) do
			col.Header:SetTextColor(Color(255, 255, 255))
		end

		for k, v in ipairs(ents.GetAll()) do
			local good = true
			for k, line in ipairs(entList:GetLines()) do
    			if line:GetValue(1) == v:GetClass() then good = false break end
			end
			if v:GetClass() ~= "worldspawn" and v:GetClass() ~= "player" and v:GetOwner() ~= LocalPlayer() and good then
				entList:AddLine(v:GetClass())
			end
		end

		for _, line in ipairs(entList:GetLines()) do
			for _, column in ipairs(line.Columns) do
				column:SetTextColor(Color(255, 255, 255))
			end
		end

		local enable = vgui.Create("DCheckBoxLabel", entityFrame)
		enable:SetText("enabled")
		enable:SetPos(305, 30)
		enable:SetTextColor(Color(255, 255, 255))
		enable:SetValue(false)

		function enable:OnChange(bVal)
			if entList:GetSelectedLine() ~= nil then
				local _, line = entList:GetSelectedLine()
				if bVal then
					if table.HasValue(config["entities"], line:GetColumnText(1)) then return
					else table.insert(config["entities"], line:GetColumnText(1)) end
				else
					if table.HasValue(config["entities"], line:GetColumnText(1)) then
						table.RemoveByValue(config["entities"], line:GetColumnText(1))
					end
				end
			end
		end

		CheckBox("name", 305, 50, "esp_entity_name", false, entityFrame)

		function entList:OnRowSelected(ind, line)
			if table.HasValue(config["entities"], line:GetColumnText(1)) then
				enable:SetValue(true)
			else
				enable:SetValue(false)
			end
		end
	end
end

function GUI()

	frame = vgui.Create("DFrame")
	frame:SetSize(350, 240)
	if frameX == nil or frameY == nil then
		frame:Center()
	else
		frame:SetPos(frameX, frameY)
	end
	frame:MakePopup()
	frame:SetTitle("hook")
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 255))
	end

	sheet = vgui.Create("DPropertySheet", frame)
	sheet:Dock(FILL)
	sheet.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 255))
	end

	local aim = vgui.Create("DScrollPanel", sheet)
	local aimsbar = aim:GetVBar()
	function aimsbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function aimsbar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function aimsbar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function aimsbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	sheet:AddSheet("aim", aim)

	local visplayer = vgui.Create("DScrollPanel", sheet)
	local playerbar = visplayer:GetVBar()
	function playerbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function playerbar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function playerbar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	function playerbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 255))
	end
	sheet:AddSheet("esp", visplayer)
	sheet:SwitchToName(activeTab)
	for k, v in pairs(sheet:GetItems()) do
		function v.Tab:OnDepressed()
			activeTab = v.Name
		end
		v.Tab.Paint = function(self, w, h)
			if self:IsActive() then
				draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 255))
			else
				draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50, 255))
			end
		end
	end

	CheckBox("enabled", 10, 5, "aim_master_toggle", false, aim)
	Bind(110, 5, "aim_onkey_key", aim)
	Dropdown("hitbox selection", 10, 25, {"body", "head"}, "aim_hitbox", aim)
	Slider("fov", 10, 65, "aim_fov", 0, 180, 0, aim)
	Slider("smooth", 10, 105, "aim_smoothing_value", 0, 2, 2, aim)
	CheckBox("no recoil", 10, 145, "aim_norecoil", false, aim)
	CheckBox("box", 10, 5, "esp_player_box", false, visplayer)
	CheckBox("name", 10, 25, "esp_player_name", false, visplayer)
	CheckBox("health", 10, 45, "esp_player_hp", false, visplayer)
	CheckBox("weapon", 10, 65, "esp_player_weapon", false, visplayer)
	CheckBox("rank", 10, 85, "esp_player_rank", false, visplayer)
	CheckBox("job", 10, 105, "esp_player_team", false, visplayer)
	Button("render: " .. GetRenderMode(), "", SwapRender, 180, 5, visplayer)
	Button("entity list", "", EntList, 180, 25, visplayer)
	Button("panic", "", Unload, 180, 45, visplayer)

end

hook.Add("Think", "p", function()
    if config.keybinds["menu_key"] != 0 && input.IsKeyDown(config.keybinds["menu_key"]) && !insertdown && !config["menu_key"] then
		if entityFrame then
			entityFrameX, entityFrameY = entityFrame:GetPos()
			entityFrame:Remove()
			entityFrameWasOpen = true
			entityFrame = false
		end
		if frame then
			CloseFrame()
		else
			GUI()
			RestoreCursorPosition()
		end
    end
    if config.keybinds["logger_key"] != 0 && input.IsKeyDown(config.keybinds["logger_key"]) && !homedown && !config["logger_key"] then
		if !exploit_menu:IsVisible() then
			gui.EnableScreenClicker(true)
			RestoreCursorPosition()
			exploit_menu:MakePopup()
			exploit_menu:SetVisible(true)
		else
			RememberCursorPosition()
			gui.EnableScreenClicker(false)
			exploit_menu:Hide()
			exploit_menu:SetVisible(false)
		end
	end
	insertdown = input.IsKeyDown(config.keybinds["menu_key"])
	homedown = input.IsKeyDown(config.keybinds["logger_key"])
	panicdown = input.IsKeyDown(config.keybinds["panic_key"])
	if !panicdown && input.IsKeyDown(config.keybinds["panic_key"]) && config.keybinds["panic_key"] != 0 then
		Unload()
	end
end)

local function DoESP()
	if !ss then
		for k, v in ipairs(player.GetAll()) do
			if ValidateESP(v) then
				local MaxX, MaxY, MinX, MinY, V1, V2, V3, V4, V5, V6, V7, V8, isVis = GetENTPos(v)
				if isVis then
					if config["esp_player_box"] then
						surface.SetDrawColor(string.ToColor(config.colors["esp_player_box"]))
						surface.DrawLine(MaxX, MaxY, MinX, MaxY)
						surface.DrawLine(MaxX, MaxY, MaxX, MinY)
						surface.DrawLine(MinX, MinY, MaxX, MinY)
						surface.DrawLine(MinX, MinY, MinX, MaxY)
					end

					if config["esp_player_name"] then
						surface.SetFont("KeypadBold")
						local w, h = surface.GetTextSize(v:Nick())
						local col = string.ToColor(config.colors["esp_player_name"])
						draw.SimpleTextOutlined(v:Nick(), "KeypadBold", MaxX-(MaxX-MinX)/2-w/2, MinY-1, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))
					end

					if config["esp_player_hp"] then
						local hpMultiplier = v:Health() / v:GetMaxHealth()
						hpMultiplier = math.Clamp(hpMultiplier, 0, 1)
						local barLen = MinY - MaxY
						local barlen = barLen * hpMultiplier
						surface.SetFont("KeypadFont")
						local w, h = surface.GetTextSize(v:Health())
						draw.SimpleTextOutlined(v:Health(), "KeypadFont", MinX-w-6, MinY+10, string.ToColor(config.colors["esp_player_hp"]), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))
					end

					if config["esp_player_weapon"] then
						surface.SetFont("KeypadFont")
						if IsValid(v:GetActiveWeapon()) then
							local w, h = surface.GetTextSize(v:GetActiveWeapon():GetPrintName())
							draw.SimpleTextOutlined(v:GetActiveWeapon():GetPrintName(), "KeypadFont", MaxX-(MaxX-MinX)/2-w/2, MaxY+12, string.ToColor(config.colors["esp_player_weapon"]), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
						end
					end

					if config["esp_player_rank"] then
						local yOffset = config["esp_player_weapon"] and 24 or 12
						surface.SetFont("KeypadFont")
						local w, h = surface.GetTextSize(v:GetUserGroup())
						draw.SimpleTextOutlined(v:GetUserGroup(), "KeypadFont", MaxX-(MaxX-MinX)/2-w/2, MaxY+yOffset, string.ToColor(config.colors["esp_player_rank"]), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))
					end

					if config["esp_player_team"] then
						local yOffset
						if config["esp_player_weapon"] and config["esp_player_rank"] then
							yOffset = 36
						elseif config["esp_player_weapon"] or config["esp_player_rank"] then
							yOffset = 24
						else
							yOffset = 12
						end
						local teamColor = team.GetColor(v:Team())
						surface.SetFont("KeypadFont")
						local w, h = surface.GetTextSize(team.GetName(v:Team()))
						draw.SimpleTextOutlined(team.GetName(v:Team()), "KeypadFont", MaxX-(MaxX-MinX)/2-w/2, MaxY+yOffset, teamColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))
					end
				end
			end
		end

		for k, v in ipairs(ents.GetAll()) do
			if table.HasValue(config["entities"], v:GetClass()) then
				if v and v:GetOwner() != LocalPlayer() and IsValid(v) and v:GetPos():Distance(LocalPlayer():GetPos()) <= config["esp_player_render_distance"] then
					local MaxX, MaxY, MinX, MinY, V1, V2, V3, V4, V5, V6, V7, V8, isVis = GetENTPos(v)
					if config["esp_entity_name"] then
						surface.SetFont("KeypadFont")
						local w, h = surface.GetTextSize(v:GetClass())
						draw.SimpleTextOutlined(v:GetClass(), "KeypadFont", MaxX-(MaxX-MinX)/2-w/2, MinY-1, string.ToColor(config.colors["esp_entity_name"]), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0,0,0))
					end
				end
			end
		end
	end
end

function SwapRender(init)
	
	init = init or false

	if !init then
		config["esp_render_mode"] = !config["esp_render_mode"]
	end

	if !config["esp_render_mode"] then
		if table.HasValue(hooks, "HUDPaint") then
			hook.Remove("HUDPaint", table.KeyFromValue(hooks, "HUDPaint"))
			table.RemoveByValue(hooks, "HUDPaint")
		end
		hook.Add("CheatHUDPaint", "r", DoESP)
	else
		if table.HasValue(hooks, "CheatHUDPaint") then
			hook.Remove("CheatHUDPaint", table.KeyFromValue(hooks, "CheatHUDPaint"))
			table.RemoveByValue(hooks, "CheatHUDPaint")
		end
		hook.Add("HUDPaint", "l", DoESP)
	end

	if !init then
		if frame then
			CloseFrame()
			GUI()
		end
	end

end

SwapRender(true)

local predictedWeapons = {
	["weapon_crossbow"] = 3110
}

local pred, realAng

local function FixMovement(cmd, fa)
	
	local vec = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
	local vel = math.sqrt(vec.x * vec.x + vec.y * vec.y)
	local mang = vec:Angle()
	local yaw = cmd:GetViewAngles().y - fa.y + mang.y

	if ( ( cmd:GetViewAngles().p + 90 ) % 360 ) > 180 then
		yaw = 180 - yaw
	end

	yaw = ( ( yaw + 180 ) % 360 ) - 180

	cmd:SetForwardMove( math.cos( math.rad( yaw ) ) * vel )
	cmd:SetSideMove( math.sin( math.rad( yaw ) ) * vel )

end

local function GetAngleDiffrence(from, to)

	local ang, aim

	ang = from:Forward()
	aim = to:Forward()

	return math.deg( math.acos( aim:Dot(ang) / aim:LengthSqr() ) )

end

local function Prediction(v, pos)
	local ply = LocalPlayer()
	if ( type( v:GetVelocity() ) == "Vector" ) then
		local dis, wep = v:GetPos():Distance( ply:GetPos() ), ( ply.GetActiveWeapon && IsValid( ply:GetActiveWeapon() ) && ply:GetActiveWeapon():GetClass() )
		if ( wep && predictedWeapons[ wep ]  ) then
			local t = dis / predictedWeapons[ wep ]
			return ( pos + v:GetVelocity() * t )
		end
		return pos
	end
	return pos
end

local function isVisible(v)
    local ply = LocalPlayer()

    local pos = v:LocalToWorld(v:OBBCenter())

    local trace = { 
        start = ply:GetShootPos(), 
        endpos = pos, 
        filter = { ply, v }, 
        mask = MASK_SHOT
    }
    local tr = util.TraceLine(trace)

    if not tr.Hit then
        return true
    end
    return false
end

local function Smoothing( ang )
	if ( config["aim_smoothing_value"] == 0 ) then return ang end
	local speed, ply = RealFrameTime() / ( config["aim_smoothing_value"] / 10 ), LocalPlayer()
	local angl = LerpAngle( speed, ply:EyeAngles(), ang )
	return Angle( angl.p, angl.y, 0 )
end

hook.Add("CreateMove", "bn", function(ucmd)
    if config["aim_master_toggle"] then
        if not config["aim_onkey"] or (
            config.keybinds["aim_onkey_key"] ~= 0 and 
            (
                (config.keybinds["aim_onkey_key"] >= 107 and config.keybinds["aim_onkey_key"] <= 113 and input.IsMouseDown(config.keybinds["aim_onkey_key"])) or 
                input.IsKeyDown(config.keybinds["aim_onkey_key"])
            )
        ) and not frame then
            if not LocalPlayer():Alive() then return end
            if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():Clip1() ~= 0 then
                local centerx, centery = ScrW() / 2, ScrH() / 2
                local playerCenter, newPlayerCenter = math.huge, math.huge

                for k, v in pairs(player.GetAll()) do
                    if ValidateAimbot(v) and GetIgnorePlayers(v) then
                        if isVisible(v) then
                            local tarFrames = RealFrameTime() / (1 / frametime)
                            local plyFrames = RealFrameTime() / (1 / frametime)
                            local pred = v:GetVelocity() * tarFrames - LocalPlayer():GetVelocity() * plyFrames
                            local CurAngle = ucmd:GetViewAngles()
                            local CurPos = LocalPlayer():GetShootPos()
                            local AimSpot

                            if config["aim_hitbox"] ~= 1 and v:LookupBone("ValveBiped.Bip01_Head1") ~= nil then
                                AimSpot = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0, 0, 1) + pred
                            elseif config["aim_hitbox"] == 2 and v:LookupBone("ValveBiped.Bip01_Pelvis") ~= nil then
                                AimSpot = v:GetBonePosition(v:LookupBone("ValveBiped.Bip01_Pelvis")) + pred
                            else
                                AimSpot = v:LocalToWorld(v:OBBCenter()) + pred
                            end

                            if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crossbow" then
                                AimSpot = Prediction(v, AimSpot)
                            end

                            local FinAngle = (AimSpot - CurPos):Angle()
                            FinAngle:Normalize()

                            local distanceToScreen = math.sqrt(
                                (AimSpot:ToScreen().x - centerx)^2 +
                                (AimSpot:ToScreen().y - centery)^2
                            )
                            if distanceToScreen < playerCenter then
                                newPlayerCenter = distanceToScreen
                            end

                            local angDiff = GetAngleDiffrence(CurAngle, FinAngle)
                            angDiff = math.abs(math.NormalizeAngle(angDiff))
                            if angDiff < config["aim_fov"] then
                                if config["aim_smoothing"] and 
                                    (IsValid(LocalPlayer():GetActiveWeapon()) and 
                                    LocalPlayer():GetActiveWeapon():GetClass() ~= "weapon_crossbow") then
                                    playerCenter = newPlayerCenter
                                    ucmd:SetViewAngles(Smoothing(FinAngle))
                                else
                                    playerCenter = newPlayerCenter
                                    ucmd:SetViewAngles(FinAngle)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)