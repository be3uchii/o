local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local espEnabled = true
local espObjects = {}

local BLACKLIST = {
    "fuelzone", "fuelarea", "fuelregion", "fueltank",
    "fuelstation", "fueldepot", "fuelspot", "generator",
    "zone", "area", "region", "depot", "station",
    "trigger", "hitbox", "invisible", "part0", "part1"
}

local function isFuelItem(obj)
    if not obj then return false end
    if not (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then return false end
    local name = obj.Name:lower()
    if not name:find("fuel") then return false end
    for _, bad in ipairs(BLACKLIST) do
        if name:find(bad) then return false end
    end
    if obj:IsA("BasePart") then
        local size = obj.Size
        if size.X > 30 or size.Y > 30 or size.Z > 30 then return false end
        if obj.Transparency >= 0.9 then return false end
        if not obj.CanCollide and obj.Size.Magnitude > 10 then return false end
    end
    return true
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
        local h = obj:FindFirstChild("Handle")
        if h then return h.Position end
    end
    return nil
end

local function getAllFuelItems()
    local items = {}
    local function scan(container)
        for _, obj in ipairs(container:GetChildren()) do
            if isFuelItem(obj) then
                table.insert(items, obj)
            end
            if obj:IsA("Folder") or obj:IsA("Model") then
                scan(obj)
            end
        end
    end
    scan(workspace)
    return items
end

local function getNearestFuel()
    local char = lp.Character
    if not char then return nil, 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, 0 end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(getAllFuelItems()) do
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

local function teleportToFuel(obj)
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local pos = getItemPosition(obj)
    if not pos then return end

    local offset = Vector3.new(
        math.random(-2, 2),
        3,
        math.random(-2, 2)
    )
    local targetCF = CFrame.new(pos + offset)

    local oldState = hum:GetState()
    hum.PlatformStand = true

    for i = 1, 5 do
        hrp.CFrame = targetCF
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
    end

    task.delay(0.15, function()
        if hum and hum.Parent then
            hum.PlatformStand = false
        end
    end)
end

local function clearESP()
    for _, v in ipairs(espObjects) do
        pcall(function() v:Destroy() end)
    end
    espObjects = {}
end

local function createESPLabel(obj, pos, dist)
    local adornee = nil
    if obj:IsA("BasePart") then
        adornee = obj
    elseif obj:IsA("Model") then
        adornee = obj.PrimaryPart
        if not adornee then
            for _, v in ipairs(obj:GetDescendants()) do
                if v:IsA("BasePart") then adornee = v break end
            end
        end
    elseif obj:IsA("Tool") then
        adornee = obj:FindFirstChild("Handle")
    end
    if not adornee then return end

    local bb = Instance.new("BillboardGui")
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0, 130, 0, 42)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.Adornee = adornee
    bb.Parent = adornee

    local frame = Instance.new("Frame", bb)
    frame.Size = UDim2.new(1,0,1,0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.BorderSizePixel = 0
    local c = Instance.new("UICorner", frame)
    c.CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 165, 0)
    stroke.Thickness = 1.8

    local nameL = Instance.new("TextLabel", frame)
    nameL.Size = UDim2.new(1, -4, 0.55, 0)
    nameL.Position = UDim2.new(0, 2, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = "⛽ " .. obj.Name
    nameL.TextColor3 = Color3.fromRGB(255, 210, 60)
    nameL.TextScaled = true
    nameL.Font = Enum.Font.GothamBold

    local distL = Instance.new("TextLabel", frame)
    distL.Size = UDim2.new(1, -4, 0.45, 0)
    distL.Position = UDim2.new(0, 2, 0.55, 0)
    distL.BackgroundTransparency = 1
    distL.Text = math.floor(dist) .. " st"
    distL.TextColor3 = Color3.fromRGB(140, 255, 140)
    distL.TextScaled = true
    distL.Font = Enum.Font.Gotham

    table.insert(espObjects, bb)
end

local function updateESP()
    clearESP()
    if not espEnabled then return end
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(getAllFuelItems()) do
        local pos = getItemPosition(obj)
        if pos then
            local dist = (hrp.Position - pos).Magnitude
            if dist < 900 then
                pcall(createESPLabel, obj, pos, dist)
            end
        end
    end
end

local gui = Instance.new("ScreenGui")
gui.Name = "STA_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 195)
frame.Position = UDim2.new(0, 14, 0.5, -97)
frame.BackgroundColor3 = Color3.fromRGB(5, 10, 5)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
local fc = Instance.new("UICorner", frame)
fc.CornerRadius = UDim.new(0, 11)
local fs = Instance.new("UIStroke", frame)
fs.Color = Color3.fromRGB(0, 210, 65)
fs.Thickness = 1.6

local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 28, 10)
titleBar.BorderSizePixel = 0
local tbc = Instance.new("UICorner", titleBar)
tbc.CornerRadius = UDim.new(0, 11)
local titleTxt = Instance.new("TextLabel", titleBar)
titleTxt.Size = UDim2.new(1, -8, 1, 0)
titleTxt.Position = UDim2.new(0, 8, 0, 0)
titleTxt.BackgroundTransparency = 1
titleTxt.Text = "⚡ STA  FUEL"
titleTxt.TextColor3 = Color3.fromRGB(0, 255, 80)
titleTxt.Font = Enum.Font.GothamBold
titleTxt.TextSize = 13

local function makeBtn(yPos, text, col)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -18, 0, 38)
    b.Position = UDim2.new(0, 9, 0, yPos)
    b.BackgroundColor3 = col
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = true
    local bc = Instance.new("UICorner", b)
    bc.CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", b)
    bs.Color = Color3.fromRGB(255,255,255)
    bs.Transparency = 0.78
    bs.Thickness = 1
    return b
end

local tpBtn  = makeBtn(40,  "⛽  TP К FUEL",    Color3.fromRGB(170, 75, 0))
local espBtn = makeBtn(86,  "👁  ESP: ВКЛ",     Color3.fromRGB(0, 95, 38))

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -18, 0, 20)
status.Position = UDim2.new(0, 9, 0, 132)
status.BackgroundTransparency = 1
status.Text = "готов"
status.TextColor3 = Color3.fromRGB(100, 200, 100)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Center

local countL = Instance.new("TextLabel", frame)
countL.Size = UDim2.new(1, -18, 0, 18)
countL.Position = UDim2.new(0, 9, 0, 155)
countL.BackgroundTransparency = 1
countL.Text = "найдено: 0"
countL.TextColor3 = Color3.fromRGB(80, 160, 80)
countL.Font = Enum.Font.Gotham
countL.TextSize = 10
countL.TextXAlignment = Enum.TextXAlignment.Center

local function setStatus(msg, col)
    status.Text = msg
    status.TextColor3 = col or Color3.fromRGB(100, 200, 100)
end

local function flash(btn)
    local orig = btn.BackgroundColor3
    btn.BackgroundColor3 = Color3.fromRGB(0, 210, 75)
    task.delay(0.15, function() btn.BackgroundColor3 = orig end)
end

tpBtn.MouseButton1Click:Connect(function()
    flash(tpBtn)
    local nearest, dist = getNearestFuel()
    if nearest then
        setStatus("⛽ TP → " .. math.floor(dist) .. " st", Color3.fromRGB(255, 175, 45))
        teleportToFuel(nearest)
        task.delay(0.8, function() setStatus("готов") end)
    else
        setStatus("⚠ fuel не найден", Color3.fromRGB(255, 70, 70))
        task.delay(2, function() setStatus("готов") end)
    end
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "👁  ESP: ВКЛ"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 95, 38)
        task.spawn(updateESP)
        setStatus("ESP включён")
    else
        espBtn.Text = "👁  ESP: ВЫКЛ"
        espBtn.BackgroundColor3 = Color3.fromRGB(75, 18, 18)
        clearESP()
        setStatus("ESP выключен", Color3.fromRGB(180, 75, 75))
    end
    task.delay(1.2, function() setStatus("готов") end)
end)

local espTick = 0
local countTick = 0
RunService.Heartbeat:Connect(function(dt)
    espTick = espTick + dt
    countTick = countTick + dt
    if espTick >= 2 then
        espTick = 0
        task.spawn(updateESP)
    end
    if countTick >= 3 then
        countTick = 0
        local n = #getAllFuelItems()
        countL.Text = "найдено fuel: " .. n
    end
end)

setStatus("✓ загружен", Color3.fromRGB(0, 255, 80))
task.delay(2, function() setStatus("готов") end)
task.spawn(updateESP)