local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local espEnabled = true
local espObjects = {}

local GASOLINE_NAMES = {
    "Gasoline", "GasolineCan", "Gas", "GasCan", "FuelCan",
    "Fuel", "Petrol", "Gasoline_Can", "Canister", "GasCanister",
    "Jerry", "JerryCan", "jerrycan", "gasCan", "gasoline",
    "GasContainer", "FuelContainer", "RefinedFuel", "GasCan"
}

local function isGasolineItem(obj)
    if not obj or not obj:IsA("BasePart") and not obj:IsA("Model") and not obj:IsA("Tool") then
        return false
    end
    local name = obj.Name:lower()
    local keywords = {"gas", "fuel", "canister", "jerry", "petrol", "gasoline"}
    for _, kw in ipairs(keywords) do
        if name:find(kw) then return true end
    end
    return false
end

local function getItemPosition(obj)
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, v in ipairs(obj:GetDescendants()) do
            if v:IsA("BasePart") then return v.Position end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Tool") then
        if obj:FindFirstChild("Handle") then
            return obj.Handle.Position
        end
    end
    return nil
end

local function getAllGasolineItems()
    local items = {}
    local function searchIn(container)
        for _, obj in ipairs(container:GetChildren()) do
            if isGasolineItem(obj) then
                table.insert(items, obj)
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                searchIn(obj)
            end
        end
    end
    searchIn(workspace)
    return items
end

local function getNearestItem()
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(getAllGasolineItems()) do
        local pos = getItemPosition(obj)
        if pos then
            local dist = (hrp.Position - pos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = obj
            end
        end
    end
    return nearest, nearestDist
end

local function teleportNear(obj)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = getItemPosition(obj)
    if not pos then return end
    local offset = Vector3.new(math.random(-3,3), 2, math.random(-3,3))
    hrp.CFrame = CFrame.new(pos + offset)
end

local function clearESP()
    for _, v in ipairs(espObjects) do
        pcall(function() v:Destroy() end)
    end
    espObjects = {}
end

local function createBillboard(obj, pos, dist)
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 120, 0, 38)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = obj:IsA("BasePart") and obj or obj.PrimaryPart
    bb.Parent = obj
    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.45
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,5)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 160, 0)
    stroke.Thickness = 1.5
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0.55,0)
    label.Position = UDim2.new(0,0,0,0)
    label.BackgroundTransparency = 1
    label.Text = "⛽ " .. obj.Name
    label.TextColor3 = Color3.fromRGB(255, 200, 50)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    local distLabel = Instance.new("TextLabel", frame)
    distLabel.Size = UDim2.new(1,0,0.45,0)
    distLabel.Position = UDim2.new(0,0,0.55,0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = math.floor(dist) .. " studs"
    distLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    table.insert(espObjects, bb)
end

local function updateESP()
    clearESP()
    if not espEnabled then return end
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local items = getAllGasolineItems()
    for _, obj in ipairs(items) do
        local pos = getItemPosition(obj)
        if pos then
            local dist = (hrp.Position - pos).Magnitude
            if dist < 800 then
                pcall(function()
                    createBillboard(obj, pos, dist)
                end)
            end
        end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STA_MobileGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 175, 0, 210)
MainFrame.Position = UDim2.new(0, 16, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 12, 6)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 200, 60)
stroke.Thickness = 1.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 34)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 30, 10)
TitleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 10)
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ STA SCRIPT"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13

local function makeBtn(parent, yPos, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = true
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.75
    s.Thickness = 1
    return btn
end

local TPGasBtn = makeBtn(MainFrame, 44, "⛽  TP К БЕНЗИНУ", Color3.fromRGB(180, 80, 0))
local TPCanBtn = makeBtn(MainFrame, 90, "🪣  TP К КАНИСТРЕ", Color3.fromRGB(0, 120, 180))

local ESPToggle = makeBtn(MainFrame, 136, "👁  ESP: ВКЛ", Color3.fromRGB(0, 100, 40))

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 22)
StatusLabel.Position = UDim2.new(0, 10, 0, 180)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "готов"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

local function setStatus(msg, color)
    StatusLabel.Text = msg
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 200, 100)
end

local function flashBtn(btn)
    local orig = btn.BackgroundColor3
    btn.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    task.delay(0.18, function() btn.BackgroundColor3 = orig end)
end

TPGasBtn.MouseButton1Click:Connect(function()
    flashBtn(TPGasBtn)
    local nearest, dist = getNearestItem()
    if nearest then
        setStatus("⛽ TP → " .. math.floor(dist) .. "st", Color3.fromRGB(255, 180, 50))
        teleportNear(nearest)
        task.delay(0.7, function() setStatus("готов") end)
    else
        setStatus("⚠ бензин не найден", Color3.fromRGB(255, 80, 80))
        task.delay(1.5, function() setStatus("готов") end)
    end
end)

TPCanBtn.MouseButton1Click:Connect(function()
    flashBtn(TPCanBtn)
    local nearest, dist = getNearestItem()
    if nearest then
        setStatus("🪣 TP → " .. math.floor(dist) .. "st", Color3.fromRGB(100, 200, 255))
        teleportNear(nearest)
        task.delay(0.7, function() setStatus("готов") end)
    else
        setStatus("⚠ канистра не найдена", Color3.fromRGB(255, 80, 80))
        task.delay(1.5, function() setStatus("готов") end)
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.Text = "👁  ESP: ВКЛ"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 40)
        setStatus("ESP включён")
    else
        ESPToggle.Text = "👁  ESP: ВЫКЛ"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        clearESP()
        setStatus("ESP выключен", Color3.fromRGB(180, 80, 80))
    end
    task.delay(1, function() setStatus("готов") end)
end)

local espTick = 0
RunService.Heartbeat:Connect(function(dt)
    espTick = espTick + dt
    if espTick >= 2 then
        espTick = 0
        task.spawn(updateESP)
    end
end)

setStatus("✓ скрипт загружен", Color3.fromRGB(0, 255, 80))
task.delay(2, function() setStatus("готов") end)
task.spawn(updateESP)