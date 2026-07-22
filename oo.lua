local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

lp.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
end)

local FUEL_NAMES = {
    "Gasoline", "GasCan", "Gas_Can", "FuelCan", "Fuel_Can",
    "GasCanister", "Canister", "GasolineCan", "FuelCanister",
    "Gasoline Can", "Gas Can", "Fuel Can", "Gas Canister",
    "RefinedFuel", "Refined_Fuel", "Refined Fuel"
}

local FOOD_NAMES = {
    "Food", "CannedFood", "Canned_Food", "Canned Food",
    "MRE", "Gatorade", "GatoradeBottle", "Carrot",
    "Bread", "Apple", "Berries", "Berry", "Mushroom",
    "CookedMeat", "Cooked_Meat", "Meat", "Fish", "CookedFish",
    "Cooked Fish", "RawMeat", "Raw_Meat", "Soup",
    "EnergyDrink", "Energy_Drink", "Energy Drink",
    "ProteinBar", "Protein_Bar", "Protein Bar",
    "WaterBottle", "Water_Bottle", "Water Bottle",
    "Juice", "Ration", "Snack", "Chips"
}

local function nameMatch(name, list)
    local low = name:lower()
    for _, v in ipairs(list) do
        if low == v:lower() or low:find(v:lower(), 1, true) then
            return true
        end
    end
    return false
end

local function findClosest(nameList)
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model")) then
            if nameMatch(obj.Name, nameList) then
                local pos
                if obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
                    pos = obj.Position
                end
                if pos and hrp then
                    local d = (hrp.Position - pos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = pos
                    end
                end
            end
        end
    end
    return best
end

local function teleportTo(pos)
    if not hrp or not pos then return end
    local target = CFrame.new(pos + Vector3.new(0, 3, 0))
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 0 end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.CFrame = target
    local conn
    local ticks = 0
    conn = RunService.Heartbeat:Connect(function()
        ticks = ticks + 1
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = target
        if ticks >= 10 then
            conn:Disconnect()
            if hum then hum.WalkSpeed = 16 end
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STA_MobileGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 200, 0, 130)
Frame.Position = UDim2.new(0, 20, 0.5, -65)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = Frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 100, 0)
stroke.Thickness = 1.5
stroke.Parent = Frame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "🧟 STA Teleport"
TitleLabel.Size = UDim2.new(1, -36, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = CloseBtn

local isVisible = true
CloseBtn.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    for _, v in ipairs(Frame:GetChildren()) do
        if v.Name ~= "MainFrame" and v ~= TitleBar then
            v.Visible = isVisible
        end
    end
    CloseBtn.Text = isVisible and "✕" or "▼"
    Frame.Size = isVisible and UDim2.new(0, 200, 0, 130) or UDim2.new(0, 200, 0, 34)
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "Status"
StatusLabel.Text = "Выбери действие"
StatusLabel.Size = UDim2.new(1, -16, 0, 20)
StatusLabel.Position = UDim2.new(0, 8, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = Frame

local function makeButton(text, color, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, posY)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = Frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local orig = btn.BackgroundColor3
        btn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
        callback()
        task.delay(0.3, function() btn.BackgroundColor3 = orig end)
    end)

    return btn
end

makeButton("⛽  Канистра (бензин)", Color3.fromRGB(200, 80, 20), 62, function()
    StatusLabel.Text = "⏳ Ищу канистру..."
    task.wait(0.1)
    local pos = findClosest(FUEL_NAMES)
    if pos then
        teleportTo(pos)
        StatusLabel.Text = "✅ Телепорт к бензину!"
    else
        StatusLabel.Text = "❌ Канистра не найдена"
    end
    task.delay(2, function() StatusLabel.Text = "Выбери действие" end)
end)

makeButton("🍖  Еда", Color3.fromRGB(40, 130, 60), 100, function()
    StatusLabel.Text = "⏳ Ищу еду..."
    task.wait(0.1)
    local pos = findClosest(FOOD_NAMES)
    if pos then
        teleportTo(pos)
        StatusLabel.Text = "✅ Телепорт к еде!"
    else
        StatusLabel.Text = "❌ Еда не найдена"
    end
    task.delay(2, function() StatusLabel.Text = "Выбери действие" end)
end)