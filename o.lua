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

local FlyEnabled = false
local FlySpeed = 10
local flyBodyGyro = nil
local flyBodyVelocity = nil
local flyConnection = nil

local ACCENT       = Color3.fromRGB(255, 255, 255)
local ACCENT_ON    = Color3.fromRGB(70, 200, 255)
local BG_MAIN      = Color3.fromRGB(13, 13, 16)
local BG_PANEL     = Color3.fromRGB(20, 20, 25)
local BG_CARD      = Color3.fromRGB(26, 26, 32)
local BG_CARD_HOV  = Color3.fromRGB(32, 32, 40)
local TXT_PRIMARY  = Color3.fromRGB(245, 245, 248)
local TXT_DIM      = Color3.fromRGB(130, 130, 142)
local STROKE_SOFT  = Color3.fromRGB(40, 40, 50)
local TOGGLE_OFF   = Color3.fromRGB(48, 48, 58)
local TOGGLE_KNOB  = Color3.fromRGB(245, 245, 248)
local COLOR_ESP_FILL    = Color3.fromRGB(70, 200, 255)
local COLOR_ESP_OUTLINE = Color3.fromRGB(190, 235, 255)

local UI_Target = (pcall(function() return CoreGui.Name end)) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zeta"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UI_Target

local connections = {}
local function addConn(conn)
	table.insert(connections, conn)
	return conn
end

local function tw(o, t, p)
	return TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p)
end

local function corner(parent, r)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r)
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	return s
end

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 34, 0, 34)
ToggleUIBtn.Position = UDim2.new(0, 14, 0.5, -17)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = ACCENT
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 15
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
corner(ToggleUIBtn, 10)
stroke(ToggleUIBtn, STROKE_SOFT, 1, 0.2)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 232, 0, 260)
Frame.Position = UDim2.new(0.5, -116, 0.5, -130)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = false
Frame.Active = true
corner(Frame, 14)
stroke(Frame, STROKE_SOFT, 1, 0.1)

local FrameGrad = Instance.new("UIGradient", Frame)
FrameGrad.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
FrameGrad.Rotation = 90

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundTransparency = 1

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 6, 0, 6)
LogoDot.Position = UDim2.new(0, 13, 0.5, -3)
LogoDot.BackgroundColor3 = ACCENT_ON
corner(LogoDot, 3)
local dotGlow = Instance.new("UIStroke", LogoDot)
dotGlow.Color = ACCENT_ON
dotGlow.Thickness = 2
dotGlow.Transparency = 0.6

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 26, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false
corner(CloseBtn, 6)

addConn(CloseBtn.MouseEnter:Connect(function()
	tw(CloseBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(200, 60, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end))
addConn(CloseBtn.MouseLeave:Connect(function()
	tw(CloseBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(38, 38, 46), TextColor3 = TXT_DIM}):Play()
end))
addConn(CloseBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end))

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -20, 0, 26)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = BG_PANEL
corner(TabBar, 8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 3)

local TabPadding = Instance.new("UIPadding", TabBar)
TabPadding.PaddingLeft = UDim.new(0, 3)
TabPadding.PaddingRight = UDim.new(0, 3)
TabPadding.PaddingTop = UDim.new(0, 3)
TabPadding.PaddingBottom = UDim.new(0, 3)

local isDragging = false
local dragStart, startPos

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

addConn(ToggleUIBtn.MouseEnter:Connect(function()
	tw(ToggleUIBtn, 0.15, {BackgroundColor3 = BG_CARD}):Play()
end))
addConn(ToggleUIBtn.MouseLeave:Connect(function()
	tw(ToggleUIBtn, 0.15, {BackgroundColor3 = BG_MAIN}):Play()
end))
addConn(ToggleUIBtn.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
end))

local pages = {}
local tabButtons = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame", Frame)
	page.Size = UDim2.new(1, -16, 1, -74)
	page.Position = UDim2.new(0, 8, 0, 70)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = STROKE_SOFT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 5)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local padding = Instance.new("UIPadding", page)
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 4)

	return page
end

local function ShowPage(name)
	for key, page in pairs(pages) do
		page.Visible = (key == name)
	end
	for key, data in pairs(tabButtons) do
		local on = (key == name)
		tw(data.btn, 0.18, {BackgroundColor3 = on and ACCENT or BG_PANEL}):Play()
		tw(data.lbl, 0.18, {TextColor3 = on and BG_MAIN or TXT_DIM}):Play()
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -3, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	corner(btn, 6)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10

	local page = CreatePage()
	pages[name] = page
	tabButtons[name] = {btn = btn, lbl = lbl}

	addConn(btn.MouseButton1Click:Connect(function()
		ShowPage(name)
	end))

	return page
end

local EspPage = CreateTab("ESP")
local CombatPage = CreateTab("Combat")
local MiscPage = CreateTab("Misc")

local function CreateToggle(parent, text, info, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 9)
	stroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -60, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -60, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 22)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 34, 0, 18)
	track.Position = UDim2.new(1, -44, 0.5, -9)
	track.BackgroundColor3 = TOGGLE_OFF
	corner(track, 9)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 3, 0.5, -6)
	knob.BackgroundColor3 = TOGGLE_KNOB
	corner(knob, 6)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

	local state = false
	local function render()
		if state then
			tw(track, 0.18, {BackgroundColor3 = ACCENT_ON}):Play()
			tw(knob, 0.18, {Position = UDim2.new(1, -15, 0.5, -6)}):Play()
		else
			tw(track, 0.18, {BackgroundColor3 = TOGGLE_OFF}):Play()
			tw(knob, 0.18, {Position = UDim2.new(0, 3, 0.5, -6)}):Play()
		end
	end

	addConn(btn.MouseEnter:Connect(function()
		tw(card, 0.15, {BackgroundColor3 = BG_CARD_HOV}):Play()
	end))
	addConn(btn.MouseLeave:Connect(function()
		tw(card, 0.15, {BackgroundColor3 = BG_CARD}):Play()
	end))
	addConn(btn.MouseButton1Click:Connect(function()
		state = not state
		render()
		if callback then callback(state, sub) end
	end))

	return card
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 9)
	stroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -110, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -110, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 22)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1

	local idx = 1
	local controlW = 92
	local controlH = 20

	local controlFrame = Instance.new("Frame", card)
	controlFrame.Size = UDim2.new(0, controlW, 0, controlH)
	controlFrame.Position = UDim2.new(1, -(controlW + 6), 0.5, -(controlH / 2))
	controlFrame.BackgroundTransparency = 1

	local arrowL = Instance.new("TextButton", controlFrame)
	arrowL.Size = UDim2.new(0, controlH, 1, 0)
	arrowL.Position = UDim2.new(0, 0, 0, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.Text = "<"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 11
	arrowL.AutoButtonColor = false
	corner(arrowL, 6)

	local valLabel = Instance.new("TextLabel", controlFrame)
	valLabel.Size = UDim2.new(1, -(controlH * 2 + 4), 1, 0)
	valLabel.Position = UDim2.new(0, controlH + 2, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Center

	local arrowR = Instance.new("TextButton", controlFrame)
	arrowR.Size = UDim2.new(0, controlH, 1, 0)
	arrowR.Position = UDim2.new(1, -controlH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.Text = ">"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 11
	arrowR.AutoButtonColor = false
	corner(arrowR, 6)

	addConn(arrowL.MouseEnter:Connect(function()
		tw(arrowL, 0.12, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}):Play()
	end))
	addConn(arrowL.MouseLeave:Connect(function()
		tw(arrowL, 0.12, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}):Play()
	end))
	addConn(arrowR.MouseEnter:Connect(function()
		tw(arrowR, 0.12, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}):Play()
	end))
	addConn(arrowR.MouseLeave:Connect(function()
		tw(arrowR, 0.12, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}):Play()
	end))

	local function apply()
		valLabel.Text = labels[idx]
		sub.Text = labels[idx]
		if callback then callback(values[idx], idx) end
	end

	addConn(arrowL.MouseButton1Click:Connect(function()
		idx = idx - 1
		if idx < 1 then idx = #values end
		apply()
	end))
	addConn(arrowR.MouseButton1Click:Connect(function()
		idx = idx + 1
		if idx > #values then idx = 1 end
		apply()
	end))

	apply()
	return card
end

local function CreateAction(parent, text, info, btnText, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 9)
	stroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -70, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -70, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 22)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 46, 0, 20)
	pill.Position = UDim2.new(1, -54, 0.5, -10)
	pill.BackgroundColor3 = ACCENT
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9
	corner(pill, 10)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

	addConn(btn.MouseEnter:Connect(function()
		tw(card, 0.15, {BackgroundColor3 = BG_CARD_HOV}):Play()
	end))
	addConn(btn.MouseLeave:Connect(function()
		tw(card, 0.15, {BackgroundColor3 = BG_CARD}):Play()
	end))
	addConn(btn.MouseButton1Click:Connect(function()
		if callback then callback(pill) end
	end))

	return card, pill
end

local function StopFly()
	FlyEnabled = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if flyBodyGyro and flyBodyGyro.Parent then
		flyBodyGyro:Destroy()
	end
	flyBodyGyro = nil
	if flyBodyVelocity and flyBodyVelocity.Parent then
		flyBodyVelocity:Destroy()
	end
	flyBodyVelocity = nil
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function StartFly()
	if FlyEnabled then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	FlyEnabled = true

	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
	hum.PlatformStand = true

	local bg = Instance.new("BodyGyro")
	bg.P = 9e4
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.CFrame = rootPart.CFrame
	bg.Parent = rootPart
	flyBodyGyro = bg

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Parent = rootPart
	flyBodyVelocity = bv

	flyConnection = RunService.Heartbeat:Connect(function()
		if not FlyEnabled then return end
		if not rootPart or not rootPart.Parent then
			StopFly()
			return
		end

		local camCF = Camera.CFrame
		local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
		local right   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

		if forward.Magnitude > 0 then forward = forward.Unit end
		if right.Magnitude > 0 then right = right.Unit end

		local moveDir = Vector3.new(0, 0, 0)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDir = moveDir + forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDir = moveDir - forward
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDir = moveDir + right
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDir = moveDir - right
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDir = moveDir + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDir = moveDir - Vector3.new(0, 1, 0)
		end

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit
		end

		bv.Velocity = moveDir * FlySpeed
		bg.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z))
	end)
end

CreateToggle(EspPage, "ESP", "Highlight boxes", function(on) EspEnabled = on end)
CreateToggle(EspPage, "Names", "Show nicknames", function(on) NamesEnabled = on end)

CreateToggle(CombatPage, "Aimbot", "Lock on target", function(on) AimbotEnabled = on end)

local HitboxStepValues = {0, 15, 30, 70}
local HitboxStepLabels = {"OFF", "15x", "30x", "70x"}
CreateStepper(CombatPage, "Hitbox", HitboxStepValues, HitboxStepLabels, function(value, idx)
	HitboxMode = idx - 1
end)

local PlayerListPanel
local RefreshPlayerList

local tpCard, tpPill = CreateAction(MiscPage, "Teleport to Player", "Pick from list", "OPEN", function()
	if PlayerListPanel then
		PlayerListPanel.Visible = not PlayerListPanel.Visible
		if PlayerListPanel.Visible then RefreshPlayerList() end
	end
end)

CreateAction(MiscPage, "Teleport", "To syringe", "CLICK", function(pill)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	if not hrp then return end
	local syringe = workspace:FindFirstChild("TempVSyringe", true)
	if not syringe then return end
	local part = syringe:FindFirstChildWhichIsA("BasePart")
	if not part then return end
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	tw(pill, 0.12, {BackgroundColor3 = ACCENT_ON}):Play()
	task.delay(0.3, function() tw(pill, 0.2, {BackgroundColor3 = ACCENT}):Play() end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

local FlySpeedValues = {}
local FlySpeedLabels = {}
for i = 1, 30 do
	FlySpeedValues[i] = i * 5
	FlySpeedLabels[i] = tostring(i * 5)
end

local flyStepperIdx = 1
FlySpeed = FlySpeedValues[1]

CreateStepper(MiscPage, "Fly Speed", FlySpeedValues, FlySpeedLabels, function(value, idx)
	FlySpeed = value
	flyStepperIdx = idx
end)

CreateToggle(MiscPage, "Fly", "WASD + Space/Ctrl", function(on)
	if on then
		StartFly()
	else
		StopFly()
	end
end)

PlayerListPanel = Instance.new("Frame", Frame)
PlayerListPanel.Size = UDim2.new(0, 210, 0, 220)
PlayerListPanel.Position = UDim2.new(1, 8, 0, 0)
PlayerListPanel.BackgroundColor3 = BG_MAIN
PlayerListPanel.Visible = false
corner(PlayerListPanel, 14)
stroke(PlayerListPanel, STROKE_SOFT, 1, 0.1)

local plTitle = Instance.new("TextLabel", PlayerListPanel)
plTitle.Size = UDim2.new(1, -40, 0, 32)
plTitle.Position = UDim2.new(0, 10, 0, 0)
plTitle.Text = "Players"
plTitle.TextColor3 = TXT_PRIMARY
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 12
plTitle.BackgroundTransparency = 1

local plClose = Instance.new("TextButton", PlayerListPanel)
plClose.Size = UDim2.new(0, 20, 0, 20)
plClose.Position = UDim2.new(1, -28, 0, 6)
plClose.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
plClose.Text = "X"
plClose.TextColor3 = TXT_DIM
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 10
plClose.AutoButtonColor = false
corner(plClose, 5)
addConn(plClose.MouseEnter:Connect(function()
	tw(plClose, 0.15, {BackgroundColor3 = Color3.fromRGB(200, 60, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end))
addConn(plClose.MouseLeave:Connect(function()
	tw(plClose, 0.15, {BackgroundColor3 = Color3.fromRGB(38, 38, 46), TextColor3 = TXT_DIM}):Play()
end))
addConn(plClose.MouseButton1Click:Connect(function() PlayerListPanel.Visible = false end))

local plScroll = Instance.new("ScrollingFrame", PlayerListPanel)
plScroll.Size = UDim2.new(1, -10, 1, -36)
plScroll.Position = UDim2.new(0, 5, 0, 34)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 2
plScroll.ScrollBarImageColor3 = STROKE_SOFT
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local plLayout = Instance.new("UIListLayout", plScroll)
plLayout.Padding = UDim.new(0, 4)
plLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local avatarCache = {}

local function PreloadAvatars()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not avatarCache[player.UserId] then
			task.spawn(function()
				local ok, content = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if ok and content and content ~= "" then
					avatarCache[player.UserId] = content
				end
			end)
		end
	end
end

PreloadAvatars()

addConn(Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		task.wait(2)
		if not avatarCache[player.UserId] then
			local ok, content = pcall(function()
				return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok and content and content ~= "" then
				avatarCache[player.UserId] = content
			end
		end
	end)
end))

local function GetCachedAvatar(userId)
	return avatarCache[userId] or ""
end

local function TeleportToPlayer(target)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	if not hrp then return end
	local tchar = target.Character
	if not tchar then return end
	local thrp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso")
	if not thrp then return end
	hrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 2)
end

local function MakePlayerRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = BG_CARD
	row.Parent = plScroll
	corner(row, 8)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 24, 0, 24)
	av.Position = UDim2.new(0, 6, 0.5, -12)
	av.BackgroundColor3 = BG_PANEL
	av.Image = GetCachedAvatar(player.UserId)
	corner(av, 12)

	if av.Image == "" then
		task.spawn(function()
			local img = GetCachedAvatar(player.UserId)
			if img == "" then
				local ok, content = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
				end)
				if ok and content then
					avatarCache[player.UserId] = content
					img = content
				end
			end
			if img ~= "" and av and av.Parent then
				av.Image = img
			end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -38, 1, 0)
	nameLbl.Position = UDim2.new(0, 36, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(245,245,248)'><b>%s</b></font>\n<font color='rgb(100,100,112)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 10

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

	addConn(btn.MouseEnter:Connect(function() tw(row, 0.12, {BackgroundColor3 = BG_CARD_HOV}):Play() end))
	addConn(btn.MouseLeave:Connect(function() tw(row, 0.12, {BackgroundColor3 = BG_CARD}):Play() end))
	addConn(btn.MouseButton1Click:Connect(function()
		TeleportToPlayer(player)
		tw(row, 0.1, {BackgroundColor3 = ACCENT_ON}):Play()
		task.delay(0.25, function() tw(row, 0.2, {BackgroundColor3 = BG_CARD}):Play() end)
	end))
end

RefreshPlayerList = function()
	for _, child in ipairs(plScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			MakePlayerRow(player)
		end
	end
end

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
		}
		playerData[player] = data
	end
	return data
end

local function SafeDestroy(inst)
	if inst and inst.Parent then
		inst:Destroy()
	end
end

local function SaveHRP(data, hrp)
	if not data.origSize then
		data.origSize    = hrp.Size
		data.origTrans   = hrp.Transparency
		data.origCollide = hrp.CanCollide
	end
end

local function RestoreHRP(data, hrp)
	if data.origSize and hrp and hrp.Parent then
		hrp.Size          = data.origSize
		hrp.Transparency  = data.origTrans
		hrp.CanCollide    = data.origCollide
		data.origSize     = nil
		data.hitboxActive = false
	end
end

local function DestroyBillboard(data)
	if data.espBillboard then
		SafeDestroy(data.espBillboard)
		data.espBillboard = nil
	end
end

local function DestroyHighlight(data)
	if data.highlight then
		SafeDestroy(data.highlight)
		data.highlight = nil
	end
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
		hl.FillTransparency    = 0.7
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
		bb.Size           = UDim2.new(0, 100, 0, 20)
		bb.StudsOffset    = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop    = true
		bb.LightInfluence = 0
		bb.Parent         = ScreenGui

		local txt = Instance.new("TextLabel", bb)
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 10

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

		if not isAlive then
			if playerData[player] then
				local d = playerData[player]
				if d.hitboxActive then RestoreHRP(d, hrp) end
			end
			HardRemoveESP(player)
			continue
		end

		if HitboxMode > 0 then
			ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
		else
			DeactivateHitbox(player, hrp)
		end

		UpdateHighlight(player, char)
		UpdateNames(player, hrp)

		if AimbotEnabled then
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
	if PlayerListPanel and PlayerListPanel.Visible then
		RefreshPlayerList()
	end
end))

addConn(Players.PlayerAdded:Connect(function(player)
	SetupPlayer(player)
	if PlayerListPanel and PlayerListPanel.Visible then
		RefreshPlayerList()
	end
end))

addConn(LocalPlayer.CharacterAdded:Connect(function()
	table.clear(noclipParts)
	StopFly()
	for player, data in pairs(playerData) do
		if data then
			HardRemoveESP(player)
			data.origSize     = nil
			data.hitboxActive = false
		end
	end
end))
