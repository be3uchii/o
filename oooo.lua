local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

_G.AutoGas = true
_G.AutoFire = true
_G.AutoFood = true
_G.KillAura = true
_G.KillAuraRadius = 25
_G.ZombieEsp = true
_G.ItemEsp = true
_G.WalkSpeed = 65
_G.JumpPower = 50
_G.InfStamina = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ApocalypseDeltaMobile"
ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = "SURVIVE THE APOCALYPSE HUB"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 100, 1, -35)
TabContainer.Position = UDim2.new(0, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -100, 1, -35)
ContentContainer.Position = UDim2.new(0, 100, 0, 35)
ContentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local function MoveTo(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local speed = 45
        local duration = distance / speed
        local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

task.spawn(function()
    while _G.AutoGas do
        task.wait(0.5)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "gas") or string.find(name, "canister") or string.find(name, "fuel") or string.find(name, "jerry") then
                        if obj:FindFirstChild("TouchTransmitter") or (obj.Parent and obj.Parent:IsA("Tool")) then
                            local itemPos = obj.CFrame
                            MoveTo(itemPos)
                            firetouchinterest(hrp, obj, 0)
                            task.wait(0.1)
                            firetouchinterest(hrp, obj, 1)
                            if _G.AutoFire then
                                local fireplace = nil
                                for _, f in ipairs(Workspace:GetDescendants()) do
                                    if f:IsA("Part") or f:IsA("Model") then
                                        local fn = string.lower(f.Name)
                                        if string.find(fn, "fire") or string.find(fn, "burner") or string.find(fn, "stove") or string.find(fn, "generator") then
                                            fireplace = f
                                            break
                                        end
                                    end
                                end
                                if fireplace then
                                    local fPos = fireplace.CFrame or fireplace:GetPivot()
                                    MoveTo(fPos)
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while _G.AutoFood do
        task.wait(1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("Tool") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "food") or string.find(name, "apple") or string.find(name, "water") or string.find(name, "drink") or string.find(name, "meat") or string.find(name, "bread") then
                        MoveTo(obj.CFrame)
                        firetouchinterest(hrp, obj, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, obj, 1)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while _G.KillAura do
        task.wait(0.1)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, zombie in ipairs(Workspace:GetChildren()) do
                if zombie:FindFirstChild("Humanoid") and zombie ~= char then
                    local zh = zombie:FindFirstChild("Humanoid")
                    local zhrp = zombie:FindFirstChild("HumanoidRootPart")
                    if zh and zhrp and zh.Health > 0 then
                        local dist = (hrp.Position - zhrp.Position).Magnitude
                        if dist <= _G.KillAuraRadius then
                            local weapon = char:FindFirstChildOfClass("Tool")
                            if weapon then
                                weapon:Activate()
                                local damageEvent = weapon:FindFirstChild("OnHit") or weapon:FindFirstChild("Hit") or ReplicatedStorage:FindFirstChild("Damage")
                                if damageEvent and damageEvent:IsA("RemoteEvent") then
                                    damageEvent:FireServer(zombie, zhrp.Position)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function CreateEsp(part, color, text)
    if not part:FindFirstChild("ApocEsp") then
        local bg = Instance.new("BillboardGui")
        bg.Name = "ApocEsp"
        bg.AlwaysOnTop = true
        bg.Size = UDim2.new(0, 100, 0, 30)
        bg.Adornee = part
        bg.Parent = part
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextSize = 11
        label.Font = Enum.Font.GothamBold
        label.Parent = bg
    end
end
task.spawn(function()
    while task.wait(2) do
        if _G.ZombieEsp then
            for _, zombie in ipairs(Workspace:GetChildren()) do
                if zombie:FindFirstChild("Humanoid") and zombie.Name ~= LocalPlayer.Name then
                    local hrp = zombie:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        CreateEsp(hrp, Color3.fromRGB(255, 50, 50), "Zombie [" .. math.floor(zombie.Humanoid.Health) .. "]")
                    end
                end
            end
        end
        if _G.ItemEsp then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    local name = string.lower(obj.Name)
                    if string.find(name, "gas") or string.find(name, "canister") or string.find(name, "fuel") then
                        CreateEsp(obj, Color3.fromRGB(255, 200, 50), "Fuel Canister")
                    elseif string.find(name, "food") or string.find(name, "apple") or string.find(name, "water") then
                        CreateEsp(obj, Color3.fromRGB(50, 255, 50), "Food / Drink")
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = _G.WalkSpeed
            hum.JumpPower = _G.JumpPower
        end
        if _G.InfStamina then
            local stats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:FindFirstChild("PlayerGui")
            local stamina = stats and stats:FindFirstChild("Stamina", true)
            if stamina and stamina:IsA("NumberValue") or stamina:IsA("IntValue") then
                stamina.Value = 100
            end
        end
    end
end)