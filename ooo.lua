local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera

local espEnabled = true
local espObjects = {}
local cachedItems = {}
local lastCacheUpdate = 0

local function isGasolineItem(obj)
    if not obj then return false end
    local name = obj.Name:lower()
    if name:find("fuelzone") then return false end
    return name:find("fuel") or name:find("fuelcan")
end

local function getItemPosition(obj)
    if obj:IsA("Model") then
        return obj.PrimaryPart and obj.PrimaryPart.Position or obj:FindFirstChildWhichIsA("BasePart") and obj:FindFirstChildWhichIsA("BasePart").Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle")
        return handle and handle.Position
    end
    return nil
end

local function updateItemCache()
    cachedItems = {}
    local function searchIn(container)
        for _, obj in ipairs(container:GetChildren()) do
            if isGasolineItem(obj) then
                table.insert(cachedItems, obj)
            elseif obj:IsA("Folder") or obj:IsA("Model") then
                searchIn(obj)
            end
        end
    end
    searchIn(workspace)
end

local function getNearestItem()
    local char = lp.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(cachedItems) do
        if obj and obj.Parent then
            local pos = getItemPosition(obj)
            if pos then
                local dist = (hrp.Position - pos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
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
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
end

local function clearESP()
    for _, v in ipairs(espObjects) do
        pcall(function() v:Destroy() end)
    end
    espObjects = {}
end

local function createBillboard(obj, dist)
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
    label.Text = "⛽ FUEL"
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
    
    for _, obj in ipairs(cachedItems) do
        if obj and obj.Parent then
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
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STA_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 140, 0, 160)
MainFrame.Position = UDim2.new(0, 10, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 14, 8)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 200, 60)
stroke.Thickness = 1.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 30, 10)
TitleBar.BorderSizePixel = 0
local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 8)
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -8, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "STA"
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
    return btn
end

local TPBtn = makeBtn(MainFrame, 36, "⛽ TP FUEL", Color3.fromRGB(180, 80, 0))
local ESPToggle = makeBtn(MainFrame, 76, "👁 ESP: ON", Color3.fromRGB(0, 100, 40))

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -16, 0, 20)
StatusLabel.Position = UDim2.new(0, 8, 0, 116)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "READY"
StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

local function setStatus(msg, color)
    StatusLabel.Text = msg
    StatusLabel.TextColor3 = color or Color3.fromRGB(100, 200, 100)
end

TPBtn.MouseButton1Click:Connect(function()
    local nearest, dist = getNearestItem()
    if nearest then
        setStatus("TP " .. math.floor(dist) .. "m", Color3.fromRGB(255, 180, 50))
        teleportNear(nearest)
        task.delay(0.5, function() setStatus("READY") end)
    else
        setStatus("NOT FOUND", Color3.fromRGB(255, 80, 80))
        task.delay(1, function() setStatus("READY") end)
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.Text = "👁 ESP: ON"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 40)
        setStatus("ESP ON")
    else
        ESPToggle.Text = "👁 ESP: OFF"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
        clearESP()
        setStatus("ESP OFF", Color3.fromRGB(180, 80, 80))
    end
    task.delay(0.8, function() setStatus("READY") end)
end)

local espTick = 0
local cacheTick = 0
RunService.Heartbeat:Connect(function(dt)
    cacheTick = cacheTick + dt
    if cacheTick >= 5 then
        cacheTick = 0
        task.spawn(updateItemCache)
    end
    
    if espEnabled then
        espTick = espTick + dt
        if espTick >= 2 then
            espTick = 0
            task.spawn(updateESP)
        end
    end
end)

updateItemCache()
setStatus("LOADED", Color3.fromRGB(0, 255, 80))
task.delay(1.5, function() setStatus("READY") end)
task.spawn(updateESP)