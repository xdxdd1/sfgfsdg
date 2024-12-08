local fakeRT = GetRenderTarget("fakeRT" .. os.time(), ScrW(), ScrH())
local Main, Health, Team, Weapon, Nick, Rank, Cham = false, false, false, false, false, false, false
local RenderDis, nextToggleTime, delay = 2900, 0, 1

hook.Add("RenderScene", "no_screenshot", function(vOrigin, vAngle, vFOV)
    if Main then
        render.SetRenderTarget(nil)
        return true
    end

    render.RenderView({
        x = 0, y = 0, w = ScrW(), h = ScrH(),
        dopostprocess = true, origin = vOrigin, angles = vAngle, fov = vFOV,
        drawhud = true, drawmonitors = true, drawviewmodel = true
    })
    render.CopyTexture(nil, fakeRT)
    cam.Start2D()
        hook.Run("CheatHUDPaint")
    cam.End2D()
    render.SetRenderTarget(fakeRT)
    return true
end)

hook.Add("ShutDown", "o", function()
    render.SetRenderTarget()
end)

local cmdlist = {
    cmdlist = function()
        print("- cmdlist: Список доступных команд")
        print("- nick 0/1: Никнейм игрока")
        print("- health 0/1: Здоровье игрока")
        print("- weapon 0/1: Показывает оружие которое держит игрок")
        print("- job 0/1: Показывает профессию игрока")
    end,
    nick = function(state)
        if state == "1" then
            Nick = true
        elseif state == "0" then
            Nick = false
        end
    end,
    health = function(state)
        if state == "1" then
            Health = true
        elseif state == "0" then
            Health = false
        end
    end,
    weapon = function(state)
        if state == "1" then
            Weapon = true
        elseif state == "0" then
            Weapon = false
        end
    end,
    job = function(state)
        if state == "1" then
            Team = true
        elseif state == "0" then
            Team = false
        end
    end
}

concommand.Add("cmdlist", function(ply, cmd, args)
    cmdlist.cmdlist()
end)

concommand.Add("nick", function(ply, cmd, args)
    cmdlist.nick(args[1])
end)

concommand.Add("health", function(ply, cmd, args)
    cmdlist.health(args[1])
end)

concommand.Add("weapon", function(ply, cmd, args)
    cmdlist.weapon(args[1])
end)

concommand.Add("job", function(ply, cmd, args)
    cmdlist.job(args[1])
end)

hook.Add("HUDPaint", "z", function()
    if not Main then return end

    for _, ply in ipairs(player.GetAll()) do
        if ply == LocalPlayer() or not ply:Alive() or LocalPlayer():GetPos():Distance(ply:GetPos()) > RenderDis then continue end
        local screenPos = ply:GetPos():ToScreen()
        if not screenPos.visible then continue end
        local yOffset, realNick, usergroup = 0, ply:Nick(), ply:GetUserGroup()

        local function DFText(text, color)
            draw.SimpleTextOutlined(text, "DermaDefault", screenPos.x, screenPos.y + yOffset, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 200))
            yOffset = yOffset + 15
        end

        if Nick then
            DFText(Rank and realNick .. " (" .. usergroup .. ")" or realNick, Color(255, 255, 255))
        end

        if Health then
            local health, healthColor = ply:Health(), Color(0, 255, 0)
            if health <= 40 then healthColor = Color(255, 0, 0) elseif health <= 60 then healthColor = Color(255, 255, 0) end
            DFText(tostring(health), healthColor)
        end

        if Weapon then
            local weapon, weaponName = ply:GetActiveWeapon(), "None"
            if IsValid(weapon) then weaponName = weapon:GetPrintName() end
            DFText(weaponName, Color(255, 255, 255))
        end

        if Team then
            DFText(team.GetName(ply:Team()), team.GetColor(ply:Team()))
        end

        if ply:Crouching() then
            DFText("CROUCH", Color(204, 204, 0))
        end

        if ply:GetMoveType() == MOVETYPE_NOCLIP then
            DFText("NOCLIP", Color(204, 204, 0))
        end
    end
end)

hook.Add("PostDrawTranslucentRenderables", "x", function()
    if Cham then
        for _, ply in ipairs(player.GetAll()) do
            if ply ~= LocalPlayer() and ply:Alive() and LocalPlayer():GetPos():Distance(ply:GetPos()) <= RenderDis then
                cam.IgnoreZ(true)
                ply:DrawModel()
                cam.IgnoreZ(false)
            end
        end
    end
end)

hook.Add("Think", "c", function()
    if input.IsKeyDown(KEY_9) and CurTime() > nextToggleTime then
        nextToggleTime = CurTime() + delay
        Main = not Main
        Health, Team, Weapon, Nick, Rank, Cham, RenderDis = Main, Main, Main, Main, Main, Main, Main and 2900 or 0
    end
end)
