local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local EspEnabled = false
local NamesEnabled = false
local NoclipEnabled = false
local HitboxMode = 0
local HitboxSizes = {0, 15, 30, 70}
local FOV_RADIUS = 110
local MaxTargetDistance = 600
local AIM_SMOOTHNESS = 0.22

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
ToggleUIBtn.Text = "\u{26A1}"
ToggleUIBtn.TextSize = 16
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
Instance.new("UICorner", ToggleUIBtn).CornerRadius = UDim.new(0, 10)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 230, 0, 320)
Frame.Position = UDim2.new(0.5, -115, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 15)
Frame.Visible = false
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

local FrameStroke = Instance.new("UIStroke", Frame)
FrameStroke.Color = Color3.fromRGB(30, 30, 40)
FrameStroke.Thickness = 1
FrameStroke.Transparency = 0.3

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopBar.ZIndex = 2
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Text = "\u{26A1} LZhin"
Title.TextColor3 = Color3.fromRGB(220, 220, 225)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.ZIndex = 2

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "\u{2715}"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 3
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -16, 0, 32)
TabBar.Position = UDim2.new(0, 8, 0, 44)
TabBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)

local TabPadding = Instance.new("UIPadding", TabBar)
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)

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

local COLOR_ON_TEXT     = Color3.fromRGB(0, 220, 150)
local COLOR_ON_BADGE    = Color3.fromRGB(0, 40, 28)
local COLOR_ON_BSTROKE  = Color3.fromRGB(0, 180, 120)
local COLOR_OFF_TEXT    = Color3.fromRGB(200, 70, 70)
local COLOR_OFF_STROKE  = Color3.fromRGB(38, 38, 48)
local COLOR_OFF_BADGE   = Color3.fromRGB(28, 28, 35)
local COLOR_BTN_BASE    = Color3.fromRGB(18, 18, 24)
local COLOR_BTN_HOVER   = Color3.fromRGB(22, 22, 30)
local COLOR_ESP_FILL    = Color3.fromRGB(0, 210, 140)
local COLOR_ESP_OUTLINE = Color3.fromRGB(100, 255, 190)
local COLOR_TP_NORMAL   = Color3.fromRGB(215, 215, 222)
local COLOR_TAB_ON      = Color3.fromRGB(0, 220, 150)
local COLOR_TAB_OFF     = Color3.fromRGB(120, 120, 132)
local COLOR_TAB_BG_ON   = Color3.fromRGB(22, 30, 28)
local COLOR_TAB_BG_OFF  = Color3.fromRGB(16, 16, 22)

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

local pages = {}
local tabButtons = {}
local activePage = nil

local function CreatePage()
	local page = Instance.new("ScrollingFrame", Frame)
	page.Size = UDim2.new(1, 0, 1, -84)
	page.Position = UDim2.new(0, 0, 0, 82)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 150)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local padding = Instance.new("UIPadding", page)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)

	return page
end

local function ShowPage(name)
	for key, page in pairs(pages) do
		page.Visible = (key == name)
	end
	for key, btn in pairs(tabButtons) do
		local on = (key == name)
		TweenService:Create(btn, tweenInfo012, {
			BackgroundColor3 = on and COLOR_TAB_BG_ON or COLOR_TAB_BG_OFF,
			TextColor3 = on and COLOR_TAB_ON or COLOR_TAB_OFF,
		}):Play()
	end
	activePage = name
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -4, 1, -6)
	btn.BackgroundColor3 = COLOR_TAB_BG_OFF
	btn.Text = name
	btn.TextColor3 = COLOR_TAB_OFF
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.AutoButtonColor = false
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local page = CreatePage()
	pages[name] = page
	tabButtons[name] = btn

	addConn(btn.MouseButton1Click:Connect(function()
		ShowPage(name)
	end))

	return page
end

local EspPage = CreateTab("ESP")
local CombatPage = CreateTab("Combat")
local MiscPage = CreateTab("Misc")

local function CreateButton(parent, text, info)
	local BtnFrame = Instance.new("Frame")
	BtnFrame.Size = UDim2.new(0.92, 0, 0, 46)
	BtnFrame.BackgroundColor3 = COLOR_BTN_BASE
	BtnFrame.Parent = parent
	Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 10)

	local BStroke = Instance.new("UIStroke", BtnFrame)
	BStroke.Color = COLOR_OFF_STROKE

	local Lbl = Instance.new("TextLabel", BtnFrame)
	Lbl.Size = UDim2.new(1, -58, 0.5, 0)
	Lbl.Position = UDim2.new(0, 12, 0, 5)
	Lbl.Text = text
	Lbl.TextColor3 = Color3.fromRGB(215, 215, 222)
	Lbl.TextXAlignment = Enum.TextXAlignment.Left
	Lbl.Font = Enum.Font.GothamBold
	Lbl.TextSize = 11
	Lbl.BackgroundTransparency = 1

	local Sub = Instance.new("TextLabel", BtnFrame)
	Sub.Size = UDim2.new(1, -58, 0.5, 0)
	Sub.Position = UDim2.new(0, 12, 0.5, -3)
	Sub.Text = info
	Sub.TextColor3 = Color3.fromRGB(100, 100, 112)
	Sub.TextXAlignment = Enum.TextXAlignment.Left
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

local _, EspBtn,   EspStatus,   EspStroke,   _,      EspBadge,   EspBadgeStroke   = CreateButton(EspPage, "ESP", "Highlight")
local _, NamesBtn, NamesStatus, NamesStroke, _,      NamesBadge, NamesBadgeStroke = CreateButton(EspPage, "Names", "Nicknames")

local _, AimBtn,   AimStatus,   AimStroke,   _,      AimBadge,   AimBadgeStroke   = CreateButton(CombatPage, "Aimbot", "Lock")
local _, HitBtn,   HitStatus,   HitStroke,   HitSub, HitBadge,   HitBadgeStroke   = CreateButton(CombatPage, "Hitbox", "Default")

local _, TpBtn,    TpStatus,    TpStroke,    _,      TpBadge,    TpBadgeStroke    = CreateButton(MiscPage, "Teleport", "To Syringe")
local _, NoclipBtn,NoclipStatus,NoclipStroke,_,      NoclipBadge,NoclipBadgeStroke= CreateButton(MiscPage, "NoClip", "Walk through objects")

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

addConn(NamesBtn.MouseButton1Click:Connect(function()
	NamesEnabled = not NamesEnabled
	NamesStatus.Text = NamesEnabled and "ON" or "OFF"
	SetActive(NamesStatus, NamesStroke, NamesBadge, NamesBadgeStroke, NamesEnabled)
end))

addConn(NoclipBtn.MouseButton1Click:Connect(function()
	NoclipEnabled = not NoclipEnabled
	NoclipStatus.Text = NoclipEnabled and "ON" or "OFF"
	SetActive(NoclipStatus, NoclipStroke, NoclipBadge, NoclipBadgeStroke, NoclipEnabled)
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

ShowPage("ESP")

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
			charConn     = nil,
			lastChar     = nil,
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

local function DestroyBillboard(data)
	if data.espBillboard and data.espBillboard.Parent then
		data.espBillboard:Destroy()
	end
	data.espBillboard = nil
end

local function DestroyHighlight(data)
	if data.highlight and data.highlight.Parent then
		data.highlight:Destroy()
	end
	data.highlight = nil
end

local function HardRemoveESP(player)
	local data = playerData[player]
	if not data then return end
	DestroyBillboard(data)
	DestroyHighlight(data)
end

local function CleanupPlayer(player)
	local data = playerData[player]
	if not data then return end
	if data.charConn then
		data.charConn:Disconnect()
		data.charConn = nil
	end
	local char = player.Character
	if char and data.hitboxActive then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then RestoreHRP(data, hrp) end
	end
	HardRemoveESP(player)
	playerData[player] = nil
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

local function UpdateHighlight(player, char)
	local data = GetData(player)
	if not EspEnabled then
		DestroyHighlight(data)
		return
	end
	if not data.highlight or not data.highlight.Parent or data.highlight.Adornee ~= char then
		DestroyHighlight(data)
		local hl = Instance.new("Highlight")
		hl.Adornee             = char
		hl.FillColor           = COLOR_ESP_FILL
		hl.FillTransparency    = 0.82
		hl.OutlineColor        = COLOR_ESP_OUTLINE
		hl.OutlineTransparency = 0
		hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent              = ScreenGui
		data.highlight         = hl
	end
end

local function UpdateNames(player, hrp)
	local data = GetData(player)
	if not NamesEnabled then
		DestroyBillboard(data)
		return
	end
	if not data.espBillboard or not data.espBillboard.Parent or data.espBillboard.Adornee ~= hrp then
		DestroyBillboard(data)
		local bb = Instance.new("BillboardGui")
		bb.Adornee        = hrp
		bb.Size           = UDim2.new(0, 100, 0, 28)
		bb.StudsOffset    = Vector3.new(0, 3.4, 0)
		bb.AlwaysOnTop    = true
		bb.LightInfluence = 0
		bb.Parent         = ScreenGui

		local txt = Instance.new("TextLabel", bb)
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 11

		data.espBillboard = bb
	end
end

local function SetupPlayer(player)
	if player == LocalPlayer then return end
	local data = GetData(player)

	if data.charConn then
		data.charConn:Disconnect()
		data.charConn = nil
	end

	data.charConn = player.CharacterAdded:Connect(function()
		HardRemoveESP(player)
		local d = GetData(player)
		d.origSize     = nil
		d.hitboxActive = false
		d.lastChar     = nil
	end)
end

local filterInstances = {Camera}
local function IsVisible(targetPos, char)
	filterInstances[2] = LocalPlayer.Character
	filterInstances[3] = char
	rayParams.FilterDescendantsInstances = filterInstances
	return workspace:Raycast(Camera.CFrame.Position, targetPos - Camera.CFrame.Position, rayParams) == nil
end

local noclipParts = {}
local function ApplyNoclip()
	local char = LocalPlayer.Character
	if not char then return end
	if NoclipEnabled then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
				noclipParts[part] = true
			end
		end
	else
		for part in pairs(noclipParts) do
			if part and part.Parent then
				part.CanCollide = true
			end
			noclipParts[part] = nil
		end
	end
end

local cachedPlayers = {}
local lastPlayerRefresh = 0
local PLAYER_CACHE_INTERVAL = 0.5

for _, player in ipairs(Players:GetPlayers()) do
	SetupPlayer(player)
end

addConn(RunService.RenderStepped:Connect(function(dt)
	local now = tick()
	if now - lastPlayerRefresh > PLAYER_CACHE_INTERVAL then
		cachedPlayers = Players:GetPlayers()
		lastPlayerRefresh = now
	end

	ApplyNoclip()

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
			HardRemoveESP(player)
			continue
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			HardRemoveESP(player)
			continue
		end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		local isAlive  = humanoid and humanoid.Health > 0

		if isAlive and HitboxMode > 0 then
			ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
		elseif HitboxMode == 0 then
			DeactivateHitbox(player, hrp)
		end

		if isAlive then
			UpdateHighlight(player, char)
			UpdateNames(player, hrp)
		else
			HardRemoveESP(player)
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
	SetupPlayer(player)
end))

addConn(LocalPlayer.CharacterAdded:Connect(function()
	table.clear(noclipParts)
	for player in pairs(playerData) do
		local data = playerData[player]
		if data then
			HardRemoveESP(player)
			data.origSize     = nil
			data.hitboxActive = false
			data.lastChar     = nil
		end
	end
end))
