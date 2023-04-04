local Linear = getgenv().Linear
local DetectedUnderGround = false
local DetectedDesync = false

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
    local Target, Closest = nil, math.huge
 
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
    local ClosestDistance = math.huge
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

Script.Functions.GetClosestPlayer = LPH_NO_VIRTUALIZE(function()
    local HitChance = Script.Functions.CalculateChance(Linear.Silent.HitChance)

    if not HitChance then
        return nil
    end
    for _, v in pairs(Players:GetPlayers()) do
        if Linear.Silent.Extra.WallCheck and not Script.Functions.RayCastCheck(v.Character.HumanoidRootPart, v.Character) then 
            continue 
        end
        if Linear.Misc.CrewCheck and Script.Functions.FindCrew(v) and v.DataFolder.Information:FindFirstChild("Crew").Value == Client.DataFolder.Information:FindFirstChild("Crew").Value then
            continue
        end
        if Linear.Misc.FriendCheck then
            if not table.find(Script.Friends, v.UserId) then
                continue
            end
        end
    end
end)

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

if Linear.Resolver.DetectDesync then
    local Magnitude = TargetVel.magnitude
    local Magnitude2 = TargetMov.magnitude
    if Magnitude > Linear.Resolver.DesyncDetection then
        DetectedDesync = true
    elseif Magnitude < 1 and Magnitude2 > 0.01 then
        DetectedDesync = true
    elseif Magnitude > 5 and Magnitude2 < 0.01 then
        DetectedDesync = true
    else
        DetectedDesync = false
    end
else
    DetectedDesync = false
end
if Linear.Resolver.DetectUnderGround then 
    if TargetVel.Y < Linear.Resolver.UnderGroundDetection then            
        DetectedUnderGround = true
    else
        DetectedUnderGround = false
    end
else
    DetectedUnderGround = false
end

if TargetCF ~= nil then
    if DetectedDesync then
        local MoveDirection = TargetMov * 16
        EndPoint = TargetCF + (MoveDirection * Linear.Silent.Prediction)
    elseif DetectedUnderGround then
        EndPoint = TargetCF + (Vector3.new(TargetVel.X, 0, TargetVel.Z) * Linear.Silent.Prediction)
    elseif DetectedFreeFall then
        EndPoint = TargetCF + (Vector3.new(TargetVel.X, (TargetVel.Y * Linear.Silent.Extra.AntiGroundValue), TargetVel.Z) * Linear.Silent.Prediction)
    elseif Linear.Silent.Prediction then
        EndPoint = TargetCF + (Vector3.new(TargetVel.X, (TargetVel.Y * 0.5), TargetVel.Z) * Linear.Silent.Prediction)
    else
        EndPoint = TargetCF
    end
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