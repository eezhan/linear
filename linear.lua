local Linear = getgenv().Linear

local Players, Client, Mouse, RS, Camera =
    game:GetService("Players"),
    game:GetService("Players").LocalPlayer,
    game:GetService("Players").LocalPlayer:GetMouse(),
    game:GetService("RunService"),
    game.Workspace.CurrentCamera

local Circle = Drawing.new("Circle")
Circle.Color = Color3.new(0.26666666666666666, 0, 0.43137254901960786)
Circle.Thickness = 1

local UpdateFOV = function ()
    if (not Circle) then
        return Circle
    end
    Circle.Visible = Linear.FOV["Visible"]
    Circle.Radius = Linear.FOV["Radius"] * 3
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
    return Circle
end

RS.Heartbeat:Connect(UpdateFOV)

Mouse.KeyDown:Connect(function(SilentAimEnable)
	if SilentAimEnable.KeyCode ~= Linear.Silent.Keybind then
		return
	elseif SilentAimEnable.KeyCode == Linear.Silent.Keybind then
		Linear.Silent.Enabled = not Linear.Silent.Enabled
	end
end)

ClosestPlrFromMouse = function()
    local Target, Closest = nil, 1/0
 
    for _ ,v in pairs(Players:GetPlayers()) do
        if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
            local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            if (Circle.Radius > Distance and Distance < Closest and OnScreen) then
                Closest = Distance
                Target = v
            end
        end
    end
    return Target
end

local WTS = function (Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local IsOnScreen = function (Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end

local FilterObjs = function (Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
        return true
    end
end

local GetClosestBodyPart = function (character)
    local ClosestDistance = 1/0
    local BodyPart = nil
    if (character and character:GetChildren()) then
        for _,  x in next, character:GetChildren() do
            if FilterObjs(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if (Circle.Radius > Distance and Distance < ClosestDistance) then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end
    return BodyPart
end

local Prey

task.spawn(function ()
    while task.wait() do
        if Prey then
            if Linear.Silent.Enabled and Linear.Silent.ClosestPart == true then
                Linear.Silent["Part"] = tostring(GetClosestBodyPart(Prey.Character))
            end
        end
    end
end)

local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index = newcclosure(function(self, v)
    if (Linear.Silent.Enabled and Mouse and tostring(v) == "Hit") then

        Prey = ClosestPlrFromMouse()

        if Prey then
            local endpoint = game.Players[tostring(Prey)].Character[Linear.Silent["Part"]].CFrame + (
                game.Players[tostring(Prey)].Character[Linear.Silent["Part"]].Velocity * Linear.Silent.Prediction
            )
            return (tostring(v) == "Hit" and endpoint)
        end
    end
    return backupindex(self, v)
end)

if Linear.Misc.CrewCheck == true then
    while true do
        local newPlayer = game.Players.PlayerAdded:wait()
        if player:IsInGroup(newPlayer.Group) then
            table.insert(Ignored.Players, newPlayer)
        end
    end
end

local ClosestPlrFromMouse = function()
    local Target, Closest = nil, 1/0
    
    for _ ,v in pairs(Players:GetPlayers()) do
    	if Linear.Misc.WallCheck then
    		if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
    			local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
    			local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    
    			if (Circle.Radius > Distance and Distance < Closest and OnScreen) and WallCheck(v.Character.HumanoidRootPart.Position, {Client, v.Character}) then
    				Closest = Distance
    				Target = v
    			end
    		end
    	else
    		if (v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart")) then
    			local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
    			local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
    
    			if (Circle.Radius > Distance and Distance < Closest and OnScreen) then
    				Closest = Distance
    				Target = v
    			end
    		end
    	end
    end
    return Target
end

local Prey
local PartToUse = Linear.Silent.Part

task.spawn(function ()
    while task.wait() do
        if Prey then
            if Linear.Silent.Enabled and Linear.Silent.ClosestPart == true then
                PartToUse = tostring(GetClosestBodyPart(Prey.Character))
            end
            if Linear.Silent.Extra.UnlockOnDeath == true then
                if Prey.Character.Humanoid.Health < 2 then
                    Prey = nil
                end
            end
            if Linear.Silent.Extra.UnlockOnUsersDeath == true then
                if Client.Character.Humanoid.Health < 2 then
                    Prey = nil
                end
            end
			if Linear.Silent.Extra.AntiGroundShots then
				pcall(function()
                    local TargetVelv5 = Prey.Character[Linear.Silent.Part]
                    TargetVelv5.Velocity = Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 0.5), TargetVelv5.Velocity.Z)
                    TargetVelv5.AssemblyLinearVelocity = Vector3.new(TargetVelv5.Velocity.X, (TargetVelv5.Velocity.Y * 0.5), TargetVelv5.Velocity.Z)
                end)
			end
        end
    end
end)

local vel
while true do
    local Targ = ClosestPlrFromMouse()
    if Targ then
        vel = game.Players[tostring(Targ)].Character[Linear.Silent.Part].MoveDirection * Linear.Silent.Prediction * 19.64285
        task.wait(0.0225)
        if Targ.Character.Humanoid.FloorMaterial == Enum.Material.Air then
            vel = vel / 2.75
        end
        return vel
    end
    task.wait()
end

local Script = {Functions = {}}
    Script.Functions.getToolName = function(name)
        local split = string.split(string.split(name, "[")[2], "]")[1]
        return split
    end
    Script.Functions.getEquippedWeaponName = function()
        if (Client.Character) and Client.Character:FindFirstChildWhichIsA("Tool") then
           local Tool =  Client.Character:FindFirstChildWhichIsA("Tool")
           if string.find(Tool.Name, "%[") and string.find(Tool.Name, "%]") and not string.find(Tool.Name, "Wallet") and not string.find(Tool.Name, "Phone") then
              return Script.Functions.getToolName(Tool.Name)
           end
        end
        return nil
    end
    RS.RenderStepped:Connect(function()
    if Script.Functions.getEquippedWeaponName() ~= nil then
        local WeaponLinear = Linear.FOV.GunFOV[Script.Functions.getEquippedWeaponName()]
        if WeaponLinear ~= nil and Linear.FOV.GunFOV.Enabled == true then
            Linear.FOV.Radius = WeaponLinear.FOV 
        else
            Linear.FOV.Radius = Linear.FOV.Radius
        end
    end
end)
