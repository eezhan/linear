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