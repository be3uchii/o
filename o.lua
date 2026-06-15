local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local EspEnabled = false
local HitboxMode = 0
local HitboxSizes = {0, 15, 30, 70}
local FOV_RADIUS = 110
local MaxTargetDistance = 600
local AIM_SMOOTHNESS = 0.12

local UI_Target = (pcall(function() return CoreGui.Name end)) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LZhin"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UI_Target

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 36, 0, 36)
ToggleUIBtn.Position = UDim2.new(0, 14, 0.5, -18)
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
ToggleUIBtn.TextColor3 = Color3.fromRGB(0, 220, 150)
ToggleUIBtn.Text = "⚡"
ToggleUIBtn.TextSize = 16
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
Instance.new("UICorner", ToggleUIBtn).CornerRadius = UDim.new(0, 10)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 210, 0, 270)
Frame.Position = UDim2.new(0.5, -105, 0.5, -135)
Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 15)
Frame.Visible = false
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopBar.ZIndex = 2
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "⚡ LZhin"
Title.TextColor3 = Color3.fromRGB(220, 220, 225)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("ScrollingFrame", Frame)
Content.Size = UDim2.new(1, 0, 1, -42)
Content.Position = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.CanvasSize = UDim2.new(0, 0, 0, 240)

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local UIPadding = Instance.new("UIPadding", Content)
UIPadding.PaddingTop = UDim.new(0, 8)

local isDragging = false
local dragStart, startPos
local connections = {}

local function addConn(conn)
	table.insert(connections, conn)
end

addConn(TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		dragStart = input.Position
		startPos = Frame.Position
	end
end))

addConn(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end))

addConn(UserInputService.InputChanged:Connect(function(input)
	if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end))

local tweenInfo015 = TweenInfo.new(0.15)
local tweenInfo012 = TweenInfo.new(0.12)

local COLOR_ON_TEXT    = Color3.fromRGB(0, 220, 150)
local COLOR_ON_BADGE   = Color3.fromRGB(0, 40, 28)
local COLOR_ON_BSTROKE = Color3.fromRGB(0, 180, 120)
local COLOR_OFF_TEXT   = Color3.fromRGB(200, 70, 70)
local COLOR_OFF_STROKE = Color3.fromRGB(38, 38, 48)
local COLOR_OFF_BADGE  = Color3.fromRGB(28, 28, 35)
local COLOR_BTN_BASE   = Color3.fromRGB(18, 18, 24)
local COLOR_BTN_HOVER  = Color3.fromRGB(22, 22, 30)
local COLOR_ESP_FILL    = Color3.fromRGB(0, 210, 140)
local COLOR_ESP_OUTLINE = Color3.fromRGB(80, 255, 180)
local COLOR_TP_NORMAL  = Color3.fromRGB(215, 215, 222)

addConn(ToggleUIBtn.MouseEnter:Connect(function()
	TweenService:Create(ToggleUIBtn, tweenInfo015, {BackgroundColor3 = Color3.fromRGB(20, 20, 26)}):Play()
end))
addConn(ToggleUIBtn.MouseLeave:Connect(function()
	TweenService:Create(ToggleUIBtn, tweenInfo015, {BackgroundColor3 = Color3.fromRGB(14, 14, 18)}):Play()
end))
addConn(ToggleUIBtn.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end))
addConn(CloseBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end))

local function CreateButton(text, info)
	local BtnFrame = Instance.new("Frame")
	BtnFrame.Size = UDim2.new(0.91, 0, 0, 46)
	BtnFrame.BackgroundColor3 = COLOR_BTN_BASE
	Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 10)

	local BStroke = Instance.new("UIStroke", BtnFrame)
	BStroke.Color = COLOR_OFF_STROKE

	local Lbl = Instance.new("TextLabel", BtnFrame)
	Lbl.Size = UDim2.new(1, -58, 0.5, 0)
	Lbl.Position = UDim2.new(0, 12, 0, 5)
	Lbl.Text = text
	Lbl.TextColor3 = Color3.fromRGB(215, 215, 222)
	Lbl.Font = Enum.Font.GothamBold
	Lbl.TextSize = 11
	Lbl.BackgroundTransparency = 1

	local Sub = Instance.new("TextLabel", BtnFrame)
	Sub.Size = UDim2.new(1, -58, 0.5, 0)
	Sub.Position = UDim2.new(0, 12, 0.5, -3)
	Sub.Text = info
	Sub.TextColor3 = Color3.fromRGB(100, 100, 112)
	Sub.Font = Enum.Font.Gotham
	Sub.TextSize = 9
	Sub.BackgroundTransparency = 1

	local ActionBtn = Instance.new("TextButton", BtnFrame)
	ActionBtn.Size = UDim2.new(1, 0, 1, 0)
	ActionBtn.BackgroundTransparency = 1
	ActionBtn.Text = ""
	ActionBtn.AutoButtonColor = false

	local Badge = Instance.new("Frame", BtnFrame)
	Badge.Size = UDim2.new(0, 40, 0, 20)
	Badge.Position = UDim2.new(1, -48, 0.5, -10)
	Badge.BackgroundColor3 = COLOR_OFF_BADGE
	Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)

	local BadgeStroke = Instance.new("UIStroke", Badge)
	BadgeStroke.Color = COLOR_OFF_STROKE

	local StatusText = Instance.new("TextLabel", Badge)
	StatusText.Size = UDim2.new(1, 0, 1, 0)
	StatusText.Text = "OFF"
	StatusText.TextColor3 = COLOR_OFF_TEXT
	StatusText.Font = Enum.Font.GothamBold
	StatusText.TextSize = 10
	StatusText.BackgroundTransparency = 1

	addConn(ActionBtn.MouseEnter:Connect(function()
		TweenService:Create(BtnFrame, tweenInfo012, {BackgroundColor3 = COLOR_BTN_HOVER}):Play()
	end))
	addConn(ActionBtn.MouseLeave:Connect(function()
		TweenService:Create(BtnFrame, tweenInfo012, {BackgroundColor3 = COLOR_BTN_BASE}):Play()
	end))

	return BtnFrame, ActionBtn, StatusText, BStroke, Sub, Badge, BadgeStroke
end

local AimFrame, AimBtn, AimStatus, AimStroke, _,      AimBadge, AimBadgeStroke = CreateButton("Aimbot", "Lock")
local HitFrame, HitBtn, HitStatus, HitStroke, HitSub, HitBadge, HitBadgeStroke = CreateButton("Hitbox", "Default")
local EspFrame, EspBtn, EspStatus, EspStroke, _,      EspBadge, EspBadgeStroke = CreateButton("ESP", "Name + Highlight")
local TpFrame,  TpBtn,  TpStatus,  TpStroke,  _,      TpBadge,  TpBadgeStroke  = CreateButton("Teleport", "To Syringe")

AimFrame.Parent = Content
HitFrame.Parent = Content
EspFrame.Parent = Content
TpFrame.Parent  = Content

TpStatus.Text = "GO"
TpStatus.TextColor3 = COLOR_TP_NORMAL

local function SetActive(status, stroke, badge, badgeStroke, on)
	if on then
		status.TextColor3      = COLOR_ON_TEXT
		stroke.Color           = COLOR_ON_TEXT
		stroke.Transparency    = 0.2
		badge.BackgroundColor3 = COLOR_ON_BADGE
		badgeStroke.Color      = COLOR_ON_BSTROKE
	else
		status.TextColor3      = COLOR_OFF_TEXT
		stroke.Color           = COLOR_OFF_STROKE
		stroke.Transparency    = 0
		badge.BackgroundColor3 = COLOR_OFF_BADGE
		badgeStroke.Color      = COLOR_OFF_STROKE
	end
end

addConn(AimBtn.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	AimStatus.Text = AimbotEnabled and "ON" or "OFF"
	SetActive(AimStatus, AimStroke, AimBadge, AimBadgeStroke, AimbotEnabled)
end))

addConn(HitBtn.MouseButton1Click:Connect(function()
	HitboxMode = (HitboxMode + 1) % #HitboxSizes
	if HitboxMode == 0 then
		HitStatus.Text = "OFF"
		HitSub.Text    = "Default"
		SetActive(HitStatus, HitStroke, HitBadge, HitBadgeStroke, false)
	else
		HitStatus.Text = "V" .. HitboxMode
		HitSub.Text    = "Size: " .. HitboxSizes[HitboxMode + 1] .. "x"
		SetActive(HitStatus, HitStroke, HitBadge, HitBadgeStroke, true)
	end
end))

addConn(EspBtn.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	EspStatus.Text = EspEnabled and "ON" or "OFF"
	SetActive(EspStatus, EspStroke, EspBadge, EspBadgeStroke, EspEnabled)
end))

addConn(TpBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	if not hrp then return end
	local syringe = workspace:FindFirstChild("TempVSyringe", true)
	if not syringe then return end
	local part = syringe:FindFirstChildWhichIsA("BasePart")
	if not part then return end
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	TpStatus.TextColor3 = COLOR_ON_TEXT
	task.delay(0.3, function()
		TpStatus.TextColor3 = COLOR_TP_NORMAL
	end)
end))

local playerData = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function GetData(player)
	local data = playerData[player]
	if not data then
		data = {
			origSize     = nil,
			origTrans    = nil,
			origCollide  = nil,
			hitboxActive = false,
			espBillboard = nil,
			highlight    = nil,
		}
		playerData[player] = data
	end
	return data
end

local function SaveHRP(data, hrp)
	if not data.origSize then
		data.origSize    = hrp.Size
		data.origTrans   = hrp.Transparency
		data.origCollide = hrp.CanCollide
	end
end

local function RestoreHRP(data, hrp)
	if data.origSize then
		hrp.Size          = data.origSize
		hrp.Transparency  = data.origTrans
		hrp.CanCollide    = data.origCollide
		data.origSize     = nil
		data.hitboxActive = false
	end
end

local function RemoveESP(player)
	local data = playerData[player]
	if not data then return end
	if data.espBillboard then
		data.espBillboard:Destroy()
		data.espBillboard = nil
	end
	if data.highlight then
		data.highlight:Destroy()
		data.highlight = nil
	end
end

local function CleanupPlayer(player)
	local data = playerData[player]
	if not data then return end
	local char = player.Character
	if char and data.hitboxActive then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then RestoreHRP(data, hrp) end
	end
	RemoveESP(player)
	playerData[player] = nil
end

local function ResetPlayerData(player)
	local data = playerData[player]
	if not data then return end
	RemoveESP(player)
	data.origSize     = nil
	data.hitboxActive = false
end

local function ApplyHitbox(player, hrp, size)
	local data = GetData(player)
	SaveHRP(data, hrp)
	hrp.Size          = Vector3.new(size, size, size)
	hrp.Transparency  = 0.75
	hrp.CanCollide    = false
	data.hitboxActive = true
end

local function DeactivateHitbox(player, hrp)
	local data = playerData[player]
	if data and data.hitboxActive then
		RestoreHRP(data, hrp)
	end
end

local function GetOrCreateESP(player, hrp, char)
	local data = GetData(player)

	if not data.espBillboard or not data.espBillboard.Parent then
		local bb = Instance.new("BillboardGui")
		bb.Adornee     = hrp
		bb.Size        = UDim2.new(0, 100, 0, 24)
		bb.StudsOffset = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop = true
		bb.Parent      = ScreenGui

		local txt = Instance.new("TextLabel", bb)
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextTransparency       = 0
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 10

		data.espBillboard = bb
	end

	if not data.highlight or not data.highlight.Parent then
		local hl = Instance.new("Highlight")
		hl.Adornee             = char
		hl.FillColor           = COLOR_ESP_FILL
		hl.FillTransparency    = 0.85
		hl.OutlineColor        = COLOR_ESP_OUTLINE
		hl.OutlineTransparency = 0
		hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent              = ScreenGui
		data.highlight         = hl
	end
end

local filterInstances = {Camera}
local function IsVisible(targetPos, char)
	filterInstances[2] = LocalPlayer.Character
	filterInstances[3] = char
	rayParams.FilterDescendantsInstances = filterInstances
	return workspace:Raycast(Camera.CFrame.Position, targetPos - Camera.CFrame.Position, rayParams) == nil
end

local cachedPlayers = {}
local lastPlayerRefresh = 0
local PLAYER_CACHE_INTERVAL = 1

local currentCamCFrame = Camera.CFrame

addConn(RunService.RenderStepped:Connect(function(dt)
	local now = tick()
	if now - lastPlayerRefresh > PLAYER_CACHE_INTERVAL then
		cachedPlayers = Players:GetPlayers()
		lastPlayerRefresh = now
	end

	local vpSize       = Camera.ViewportSize
	local ScreenCenter = Vector2.new(vpSize.X * 0.5, vpSize.Y * 0.5)
	local camCF        = Camera.CFrame
	local camPos       = camCF.Position

	local closestTarget = nil
	local shortestDist  = math.huge

	for i = 1, #cachedPlayers do
		local player = cachedPlayers[i]
		if player == LocalPlayer then continue end

		local char = player.Character
		if not char then
			CleanupPlayer(player)
			continue
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			RemoveESP(player)
			continue
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local isAlive  = humanoid and humanoid.Health > 0

		if isAlive and HitboxMode > 0 then
			ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
		elseif HitboxMode == 0 then
			DeactivateHitbox(player, hrp)
		end

		if EspEnabled and isAlive then
			GetOrCreateESP(player, hrp, char)
		else
			RemoveESP(player)
		end

		if AimbotEnabled and isAlive then
			local worldDist = (camPos - hrp.Position).Magnitude
			if worldDist <= MaxTargetDistance then
				local torso  = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
				local aimPos = torso and torso.Position or hrp.Position
				local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
					if dist < FOV_RADIUS and dist < shortestDist and IsVisible(aimPos, char) then
						shortestDist  = dist
						closestTarget = aimPos
					end
				end
			end
		end
	end

	if AimbotEnabled and closestTarget then
		local targetCF = CFrame.new(camPos, closestTarget)
		local alpha = 1 - (1 - AIM_SMOOTHNESS) ^ (dt * 60)
		Camera.CFrame = camCF:Lerp(targetCF, alpha)
	end
end))

addConn(Players.PlayerRemoving:Connect(function(player)
	CleanupPlayer(player)
	for i = 1, #cachedPlayers do
		if cachedPlayers[i] == player then
			table.remove(cachedPlayers, i)
			break
		end
	end
end))

addConn(Players.PlayerAdded:Connect(function(player)
	addConn(player.CharacterAdded:Connect(function()
		ResetPlayerData(player)
	end))
end))

addConn(LocalPlayer.CharacterAdded:Connect(function()
	for player in pairs(playerData) do
		ResetPlayerData(player)
	end
end))