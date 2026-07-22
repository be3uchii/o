local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local espEnabled = true
local espObjects = {}
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 2

local KEYWORDS = {"gas", "fuel", "canister", "jerry", "petrol", "gasoline"}

local function isGasolineItem(obj)
    if not obj then return false end
    local objType = obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")
    if not objType then return false end
    
    local name = obj.Name:lower()
    for _, kw in ipairs(KEYWORDS) do
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
    elseif obj:IsA("Tool") and obj:FindFirstChild("Handle") then
        return obj.Handle.Position
    end
    return nil
end

local gasCache = {}
local lastCacheTime = 0
local CACHE_DURATION = 1.5

local function getAllGasolineItems()
    local currentTime = tick()
    if currentTime - lastCacheTime < CACHE_DURATION and #gasCache > 0 then
        return gasCache
    end
    
    local items = {}
    local visited = {}
    
    local function searchIn(container, depth)
        if depth > 5 or visited[container] then return end
        visited[container] = true
        
        for _, obj in ipairs(container:GetChildren()) do
            if isGasolineItem(obj) then
                table.insert(items, obj)
            elseif (obj:IsA("Folder") or obj:IsA("Model")) and depth < 4 then
                searchIn(obj, depth + 1)
            end
        end
    end
    
    searchIn(workspace, 0)
    gasCache = items
    lastCacheTime = currentTime
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

local function createBillboard(obj, dist)
    local adornee = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
    if not adornee then return end
    
    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 100, 0, 32)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = adornee
    bb.Parent = obj
    
    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 5)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 160, 0)
    stroke.Thickness = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = math.floor(dist) .. "m"
    label.TextColor3 = Color3.fromRGB(255, 200, 50)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    
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
                    createBillboard(obj, dist)
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
MainFrame.Size = UDim2.new(0, 160, 0, 165)
MainFrame.Position = UDim2.new(0, 16, 0.5, -82)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 12, 6)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 200, 60)
stroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 30, 10)
TitleBar.BorderSizePixel = 0

local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ STA"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 80)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12

local function makeBtn(parent, yPos, text, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, yPos)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = true
    
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(255, 255, 255)
    s.Transparency = 0.75
    s.Thickness = 0.8
    
    return btn
end

local TPGasBtn = makeBtn(MainFrame, 38, "⛽ TP", Color3.fromRGB(180, 80, 0))
local ESPToggle = makeBtn(MainFrame, 76, "👁 ESP: ВКЛ", Color3.fromRGB(0, 100, 40))
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -16, 0, 18)
StatusLabel.Position = UDim2.new(0, 8, 0, 118)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "готов"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

local function setStatus(msg, color)
    StatusLabel.Text = msg
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 200, 100)
end

local function flashBtn(btn)
    local orig = btn.BackgroundColor3
    btn.BackgroundColor3 = Color3.fromRGB(0, 220, 80)
    task.delay(0.15, function() btn.BackgroundColor3 = orig end)
end

TPGasBtn.MouseButton1Click:Connect(function()
    flashBtn(TPGasBtn)
    local nearest, dist = getNearestItem()
    if nearest then
        setStatus("TP → " .. math.floor(dist) .. "st", Color3.fromRGB(255, 180, 50))
        teleportNear(nearest)
        task.delay(0.6, function() setStatus("готов") end)
    else
        setStatus("⚠ не найдено", Color3.fromRGB(255, 80, 80))
        task.delay(1.2, function() setStatus("готов") end)
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.Text = "👁 ESP: ВКЛ"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 40)
        setStatus("ESP ВКЛ")
    else
        ESPToggle.Text = "👁 ESP: ВЫКЛ"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        clearESP()
        setStatus("ESP ВЫКЛ", Color3.fromRGB(180, 80, 80))
    end
    task.delay(0.8, function() setStatus("готов") end)
end)

RunService.Heartbeat:Connect(function()
    lastESPUpdate = lastESPUpdate + 1
    if lastESPUpdate >= ESP_UPDATE_INTERVAL * 60 then
        lastESPUpdate = 0
        task.spawn(updateESP)
    end
end)

setStatus("✓ загружен", Color3.fromRGB(0, 255, 80))
task.delay(1.5, function() setStatus("готов") end)
task.spawn(updateESP)