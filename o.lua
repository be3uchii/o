local ok_main, err_main = pcall(function()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if _G.__ZetaUnload then
	pcall(_G.__ZetaUnload)
	_G.__ZetaUnload = nil
end

local AimbotEnabled = false
local EspEnabled = false
local NamesEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local HitboxMode = 0
local HitboxSizes = {0, 5, 10, 20}
local FOV_RADIUS = 110
local MaxTargetDistance = 600

local AIM_SMOOTHNESS = 0.18
local AIM_PREDICTION = 0.065
local AIM_MAX_MISS_FRAMES = 4
local AIM_SWITCH_ANGLE = 35

local FlySpeed = 50

local ACCENT_ON   = Color3.fromRGB(70, 200, 255)
local ACCENT_SOFT = Color3.fromRGB(150, 225, 255)
local BG_MAIN     = Color3.fromRGB(13, 13, 16)
local BG_PANEL    = Color3.fromRGB(22, 22, 27)
local BG_CARD     = Color3.fromRGB(27, 27, 33)
local BG_CARD_HOV = Color3.fromRGB(34, 34, 42)
local TXT_PRIMARY = Color3.fromRGB(248, 248, 250)
local TXT_DIM     = Color3.fromRGB(140, 140, 152)
local STROKE_SOFT = Color3.fromRGB(255, 255, 255)
local TOGGLE_OFF  = Color3.fromRGB(50, 50, 60)
local ESP_FILL    = Color3.fromRGB(0, 255, 100)
local ESP_OUTLINE = Color3.fromRGB(100, 255, 150)
local C_RED       = Color3.fromRGB(210, 65, 65)
local C_WHT       = Color3.fromRGB(255, 255, 255)
local C_BTN       = Color3.fromRGB(40, 40, 48)

local TI_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUICK = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local UI_Target
do
	local coreOk, coreGui = pcall(function() return game:GetService("CoreGui") end)
	if coreOk and coreGui then
		local nameOk = pcall(function() return coreGui.Name end)
		if nameOk then UI_Target = coreGui end
	end
	if not UI_Target then
		UI_Target = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
end

local existingGui = UI_Target:FindFirstChild("Zeta")
if existingGui then existingGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zeta"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = UI_Target

pcall(function()
	if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = Instance.new("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = ReplicatedStorage
	end
end)

pcall(function()
	settings().Physics.AllowSleep = false
	LocalPlayer.MaximumSimulationRadius = math.huge
	sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
end)

local connections = {}
local function track(conn)
	connections[#connections + 1] = conn
	return conn
end

local function tw(o, ti, p)
	if o and o.Parent then
		TweenService:Create(o, ti, p):Play()
	end
end

local function corner(parent, r)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r)
	return c
end

local function mkStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0
	return s
end

local Shadow = Instance.new("ImageLabel", ScreenGui)
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(0, 260, 0, 260)
Shadow.ZIndex = 4

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleUIBtn.Position = UDim2.new(0, 8, 0.5, -15)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.BackgroundTransparency = 0.1
ToggleUIBtn.TextColor3 = TXT_PRIMARY
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 12
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
ToggleUIBtn.ZIndex = 10
corner(ToggleUIBtn, 9)
mkStroke(ToggleUIBtn, STROKE_SOFT, 1, 0.75)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Name = "MainMenu"
Frame.Size = UDim2.new(0, 226, 0, 0)
Frame.AutomaticSize = Enum.AutomaticSize.Y
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.BackgroundColor3 = BG_MAIN
Frame.BackgroundTransparency = 0.08
Frame.Visible = true
Frame.Active = true
Frame.Draggable = false
Frame.ZIndex = 5
corner(Frame, 16)
mkStroke(Frame, STROKE_SOFT, 1, 0.82)

local fg = Instance.new("UIGradient", Frame)
fg.Color = ColorSequence.new(Color3.fromRGB(22, 22, 28), Color3.fromRGB(10, 10, 13))
fg.Rotation = 90

local function updateShadow()
	Shadow.Size = UDim2.new(0, Frame.AbsoluteSize.X + 40, 0, Frame.AbsoluteSize.Y + 40)
end
track(Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateShadow))
updateShadow()

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 6
TopBar.Active = false

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 6, 0, 6)
LogoDot.Position = UDim2.new(0, 10, 0.5, -3)
LogoDot.BackgroundColor3 = ACCENT_ON
LogoDot.ZIndex = 7
corner(LogoDot, 3)
local dg = Instance.new("UIStroke", LogoDot)
dg.Color = ACCENT_SOFT
dg.Thickness = 2
dg.Transparency = 0.5

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -58, 1, 0)
Title.Position = UDim2.new(0, 22, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.ZIndex = 7

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -10)
CloseBtn.BackgroundColor3 = C_BTN
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 9
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 7
corner(CloseBtn, 6)
mkStroke(CloseBtn, STROKE_SOFT, 1, 0.85)

local Divider = Instance.new("Frame", Frame)
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 30)
Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Divider.BackgroundTransparency = 0.94
Divider.BorderSizePixel = 0
Divider.ZIndex = 6

local PlayerListPanel

local MenuOpen = true

local function SetMenuVisible(open)
	MenuOpen = open
	Frame.Visible = open
	Shadow.Visible = open
	if open then
		Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	else
		if PlayerListPanel then PlayerListPanel.Visible = false end
	end
	tw(ToggleUIBtn, TI_MED, {BackgroundColor3 = open and ACCENT_ON or BG_MAIN, TextColor3 = open and BG_MAIN or TXT_PRIMARY})
end

track(CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end))
track(CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end))
track(CloseBtn.MouseButton1Click:Connect(function() SetMenuVisible(false) end))

track(ToggleUIBtn.MouseEnter:Connect(function()
	if not MenuOpen then tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_CARD}) end
end))
track(ToggleUIBtn.MouseLeave:Connect(function()
	if not MenuOpen then tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_MAIN}) end
end))
track(ToggleUIBtn.MouseButton1Click:Connect(function() SetMenuVisible(not MenuOpen) end))

track(UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Z then
		SetMenuVisible(not MenuOpen)
	end
end))

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -16, 0, 26)
TabBar.Position = UDim2.new(0, 8, 0, 38)
TabBar.BackgroundColor3 = BG_PANEL
TabBar.BackgroundTransparency = 0.15
TabBar.ZIndex = 6
corner(TabBar, 9)

local tl = Instance.new("UIListLayout", TabBar)
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 3)

local tp = Instance.new("UIPadding", TabBar)
tp.PaddingLeft   = UDim.new(0, 3)
tp.PaddingRight  = UDim.new(0, 3)
tp.PaddingTop    = UDim.new(0, 3)
tp.PaddingBottom = UDim.new(0, 3)

local pages = {}
local tabButtons = {}
local tabOrder = {}

local function CreatePage()
	local page = Instance.new("Frame", Frame)
	page.Size = UDim2.new(1, -12, 0, 0)
	page.Position = UDim2.new(0, 6, 0, 68)
	page.BackgroundTransparency = 1
	page.AutomaticSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 6
	local l = Instance.new("UIListLayout", page)
	l.Padding = UDim.new(0, 4)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.SortOrder = Enum.SortOrder.LayoutOrder
	local p = Instance.new("UIPadding", page)
	p.PaddingTop    = UDim.new(0, 4)
	p.PaddingBottom = UDim.new(0, 8)
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		pages[k].Visible = (k == name)
		local on = (k == name)
		local d = tabButtons[k]
		tw(d.btn, TI_MED, {BackgroundColor3 = on and TXT_PRIMARY or BG_PANEL, BackgroundTransparency = on and 0 or 0.15})
		tw(d.lbl, TI_MED, {TextColor3 = on and BG_MAIN or TXT_DIM})
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -3, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.BackgroundTransparency = 0.15
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 7
	corner(btn, 7)
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.ZIndex = 8
	local page = CreatePage()
	pages[name] = page
	tabButtons[name] = {btn = btn, lbl = lbl}
	tabOrder[#tabOrder + 1] = name
	track(btn.MouseButton1Click:Connect(function() ShowPage(name) end))
	return page
end

local EspPage    = CreateTab("ESP")
local CombatPage = CreateTab("Combat")
local MiscPage   = CreateTab("Misc")

local function CreateToggle(parent, text, info, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 38)
	card.BackgroundColor3 = BG_CARD
	card.BackgroundTransparency = 0.12
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 9)
	mkStroke(card, STROKE_SOFT, 1, 0.9)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -54, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -54, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local track_frame = Instance.new("Frame", card)
	track_frame.Size = UDim2.new(0, 30, 0, 16)
	track_frame.Position = UDim2.new(1, -38, 0.5, -8)
	track_frame.BackgroundColor3 = TOGGLE_OFF
	track_frame.ZIndex = 8
	corner(track_frame, 8)
	mkStroke(track_frame, STROKE_SOFT, 1, 0.88)

	local knob = Instance.new("Frame", track_frame)
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 2, 0.5, -6)
	knob.BackgroundColor3 = TXT_PRIMARY
	knob.ZIndex = 9
	corner(knob, 6)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 10

	local ON_POS  = UDim2.new(1, -14, 0.5, -6)
	local OFF_POS = UDim2.new(0, 2, 0.5, -6)
	local state = false

	track(btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end))
	track(btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end))
	track(btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			tw(track_frame, TI_MED, {BackgroundColor3 = ACCENT_ON})
			tw(knob, TI_MED, {Position = ON_POS, BackgroundColor3 = C_WHT})
		else
			tw(track_frame, TI_MED, {BackgroundColor3 = TOGGLE_OFF})
			tw(knob, TI_MED, {Position = OFF_POS, BackgroundColor3 = TXT_PRIMARY})
		end
		pcall(callback, state)
	end))
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 38)
	card.BackgroundColor3 = BG_CARD
	card.BackgroundTransparency = 0.12
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 9)
	mkStroke(card, STROKE_SOFT, 1, 0.9)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -92, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -92, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local cW, cH = 82, 19
	local cf = Instance.new("Frame", card)
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 6), 0.5, -(cH / 2))
	cf.BackgroundTransparency = 1
	cf.ZIndex = 8

	local arrowL = Instance.new("TextButton", cf)
	arrowL.Size = UDim2.new(0, cH, 1, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.BackgroundTransparency = 0.1
	arrowL.Text = "<"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 10
	arrowL.AutoButtonColor = false
	arrowL.ZIndex = 9
	corner(arrowL, 6)

	local valLabel = Instance.new("TextLabel", cf)
	valLabel.Size = UDim2.new(1, -(cH * 2 + 4), 1, 0)
	valLabel.Position = UDim2.new(0, cH + 2, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Center
	valLabel.ZIndex = 9

	local arrowR = Instance.new("TextButton", cf)
	arrowR.Size = UDim2.new(0, cH, 1, 0)
	arrowR.Position = UDim2.new(1, -cH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.BackgroundTransparency = 0.1
	arrowR.Text = ">"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 10
	arrowR.AutoButtonColor = false
	arrowR.ZIndex = 9
	corner(arrowR, 6)

	track(arrowL.MouseEnter:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}) end))
	track(arrowL.MouseLeave:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}) end))
	track(arrowR.MouseEnter:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}) end))
	track(arrowR.MouseLeave:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}) end))

	local n = #values
	local idx = 1
	local function apply()
		valLabel.Text = labels[idx]
		sub.Text = labels[idx]
		pcall(callback, values[idx], idx)
	end
	track(arrowL.MouseButton1Click:Connect(function()
		idx = idx > 1 and idx - 1 or n
		apply()
	end))
	track(arrowR.MouseButton1Click:Connect(function()
		idx = idx < n and idx + 1 or 1
		apply()
	end))
	apply()
end

local function CreateAction(parent, text, info, btnText, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 38)
	card.BackgroundColor3 = BG_CARD
	card.BackgroundTransparency = 0.12
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 9)
	mkStroke(card, STROKE_SOFT, 1, 0.9)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -62, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -62, 0, 11)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 46, 0, 19)
	pill.Position = UDim2.new(1, -52, 0.5, -9)
	pill.BackgroundColor3 = TXT_PRIMARY
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 8
	pill.ZIndex = 8
	corner(pill, 8)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 10

	track(btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end))
	track(btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end))
	track(btn.MouseButton1Click:Connect(function() pcall(callback, pill) end))

	return card, pill
end

local FlyBodyVelocity = Instance.new("BodyVelocity")
FlyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)

local FlyBodyGyro = Instance.new("BodyGyro")
FlyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
FlyBodyGyro.P = 1e4
FlyBodyGyro.D = 500

local FlyConnection = nil

local function StartFly()
	local Character = LocalPlayer.Character
	if not Character then return end
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not Root or not Humanoid then return end
	FlyBodyVelocity.Parent = Root
	FlyBodyGyro.Parent = Root
	FlyBodyGyro.CFrame = Root.CFrame
	Humanoid.PlatformStand = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	FlyConnection = RunService.Heartbeat:Connect(function()
		if not FlyEnabled or not Root or not Root.Parent or not Humanoid or not Humanoid.Parent then return end
		FlyBodyGyro.CFrame = Camera.CFrame
		local MoveDir = Humanoid.MoveDirection
		if MoveDir.Magnitude > 0 then
			local LookVec = Camera.CFrame.LookVector
			FlyBodyVelocity.Velocity = Vector3.new(MoveDir.X, LookVec.Y * MoveDir.Magnitude, MoveDir.Z) * FlySpeed
		else
			FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function StopFly()
	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end
	FlyBodyVelocity.Parent = nil
	FlyBodyGyro.Parent = nil
	local Character = LocalPlayer.Character
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.PlatformStand = false
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end
end

local RefreshPlayerList

CreateToggle(EspPage, "ESP", "Highlight boxes", function(on) EspEnabled = on end)
CreateToggle(EspPage, "Names", "Show nicknames", function(on) NamesEnabled = on end)
CreateToggle(CombatPage, "Aimbot", "Lock on target", function(on) AimbotEnabled = on end)
CreateStepper(CombatPage, "Hitbox", {0,5,10,20}, {"OFF","5x","10x","20x"}, function(value, idx)
	HitboxMode = idx - 1
end)

CreateAction(MiscPage, "Teleport to Player", "Pick from list", "OPEN", function()
	if PlayerListPanel then
		local v = not PlayerListPanel.Visible
		PlayerListPanel.Visible = v
		if v then
			local fx = Frame.AbsolutePosition.X
			local fy = Frame.AbsolutePosition.Y
			PlayerListPanel.Position = UDim2.new(0, fx + Frame.AbsoluteSize.X + 8, 0, fy)
			RefreshPlayerList()
		end
	end
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

CreateToggle(MiscPage, "Fly", "Fly through the air", function(on)
	FlyEnabled = on
	if on then
		StartFly()
	else
		StopFly()
	end
end)

track(LocalPlayer.CharacterAdded:Connect(function()
	if FlyEnabled then
		FlyEnabled = false
		StopFly()
	end
end))

PlayerListPanel = Instance.new("Frame", ScreenGui)
PlayerListPanel.Size = UDim2.new(0, 190, 0, 180)
PlayerListPanel.Position = UDim2.new(0, 0, 0, 0)
PlayerListPanel.BackgroundColor3 = BG_MAIN
PlayerListPanel.BackgroundTransparency = 0.08
PlayerListPanel.Visible = false
PlayerListPanel.Active = true
PlayerListPanel.Draggable = false
PlayerListPanel.ZIndex = 6
corner(PlayerListPanel, 16)
mkStroke(PlayerListPanel, STROKE_SOFT, 1, 0.82)

local plpfg = Instance.new("UIGradient", PlayerListPanel)
plpfg.Color = ColorSequence.new(Color3.fromRGB(22, 22, 28), Color3.fromRGB(10, 10, 13))
plpfg.Rotation = 90

local plTitle = Instance.new("TextLabel", PlayerListPanel)
plTitle.Size = UDim2.new(1, -34, 0, 28)
plTitle.Position = UDim2.new(0, 10, 0, 0)
plTitle.Text = "Players"
plTitle.TextColor3 = TXT_PRIMARY
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 12
plTitle.BackgroundTransparency = 1
plTitle.ZIndex = 7

local plClose = Instance.new("TextButton", PlayerListPanel)
plClose.Size = UDim2.new(0, 20, 0, 20)
plClose.Position = UDim2.new(1, -26, 0, 5)
plClose.BackgroundColor3 = C_BTN
plClose.Text = "X"
plClose.TextColor3 = TXT_DIM
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 9
plClose.AutoButtonColor = false
plClose.ZIndex = 7
corner(plClose, 6)
mkStroke(plClose, STROKE_SOFT, 1, 0.85)
track(plClose.MouseEnter:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end))
track(plClose.MouseLeave:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end))
track(plClose.MouseButton1Click:Connect(function() PlayerListPanel.Visible = false end))

local plScroll = Instance.new("ScrollingFrame", PlayerListPanel)
plScroll.Size = UDim2.new(1, -8, 1, -32)
plScroll.Position = UDim2.new(0, 4, 0, 30)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 3
plScroll.ScrollBarImageColor3 = STROKE_SOFT
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
plScroll.ZIndex = 7
local pll = Instance.new("UIListLayout", plScroll)
pll.Padding = UDim.new(0, 3)
pll.HorizontalAlignment = Enum.HorizontalAlignment.Center

local avatarCache   = {}
local avatarPending = {}

local function FetchAvatar(player, onDone)
	local uid = player.UserId
	if avatarCache[uid] then
		if onDone then task.spawn(onDone, avatarCache[uid]) end
		return
	end
	if onDone then
		if not avatarPending[uid] then avatarPending[uid] = {} end
		avatarPending[uid][#avatarPending[uid] + 1] = onDone
	end
	if avatarPending[uid] and #avatarPending[uid] > 1 then return end
	if not onDone then avatarPending[uid] = avatarPending[uid] or {} end
	task.spawn(function()
		local ok, url = pcall(Players.GetUserThumbnailAsync, Players, uid,
			Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		if ok and url and url ~= "" then
			avatarCache[uid] = url
			local cbs = avatarPending[uid]
			avatarPending[uid] = nil
			if cbs then
				for i = 1, #cbs do task.spawn(cbs[i], url) end
			end
		else
			avatarPending[uid] = nil
		end
	end)
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
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_CARD
	row.BackgroundTransparency = 0.12
	row.Parent = plScroll
	row.ZIndex = 8
	corner(row, 8)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 20, 0, 20)
	av.Position = UDim2.new(0, 5, 0.5, -10)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	av.ZIndex = 9
	corner(av, 10)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av and av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -32, 1, 0)
	nameLbl.Position = UDim2.new(0, 30, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(248,248,250)'><b>%s</b></font>\n<font color='rgb(140,140,152)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 9
	nameLbl.ZIndex = 9

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 10
	track(btn.MouseEnter:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD_HOV}) end))
	track(btn.MouseLeave:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD}) end))
	track(btn.MouseButton1Click:Connect(function()
		TeleportToPlayer(player)
		tw(row, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
		task.delay(0.25, function() tw(row, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	end))
end

RefreshPlayerList = function()
	for _, child in ipairs(plScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local list = Players:GetPlayers()
	for i = 1, #list do
		if list[i] ~= LocalPlayer then MakePlayerRow(list[i]) end
	end
end

ShowPage("ESP")

local playerData = {}

local function GetData(player)
	local d = playerData[player]
	if not d then
		d = {
			origSize     = nil,
			origTrans    = nil,
			origCollide  = nil,
			hitboxActive = false,
			billboard    = nil,
			highlight    = nil,
			charConn     = nil,
			lastCharacter = nil,
		}
		playerData[player] = d
	end
	return d
end

local function SafeDestroy(inst)
	if inst and inst.Parent then
		pcall(function() inst:Destroy() end)
	end
end

local function RestoreHRP(data, hrp)
	if not data.hitboxActive then return end
	if hrp and hrp.Parent then
		pcall(function()
			hrp.Size         = data.origSize or Vector3.new(2, 2, 1)
			hrp.Transparency = data.origTrans or 1
			hrp.CanCollide   = data.origCollide ~= nil and data.origCollide or false
		end)
	end
	data.origSize     = nil
	data.origTrans    = nil
	data.origCollide  = nil
	data.hitboxActive = false
end

local function HardRemoveESP(player)
	local d = playerData[player]
	if not d then return end
	SafeDestroy(d.billboard)
	SafeDestroy(d.highlight)
	d.billboard = nil
	d.highlight = nil
end

local function CleanupPlayer(player)
	local d = playerData[player]
	if not d then return end
	if d.charConn then
		pcall(function() d.charConn:Disconnect() end)
		d.charConn = nil
	end
	local char = player.Character
	if char and d.hitboxActive then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then RestoreHRP(d, hrp) end
	end
	HardRemoveESP(player)
	playerData[player] = nil
	avatarCache[player.UserId] = nil
	avatarPending[player.UserId] = nil
end

local function ApplyHitbox(player, hrp, size)
	local d = GetData(player)
	if not d.hitboxActive then
		d.origSize    = hrp.Size
		d.origTrans   = hrp.Transparency
		d.origCollide = hrp.CanCollide
		d.hitboxActive = true
	end
	pcall(function()
		hrp.Size         = Vector3.new(size, size, size)
		hrp.Transparency = 0.80
		hrp.CanCollide   = false
	end)
end

local function UpdateHighlight(player, char)
	local d = GetData(player)
	if not EspEnabled then
		if d.highlight then
			SafeDestroy(d.highlight)
			d.highlight = nil
		end
		return
	end
	local hl = d.highlight
	if not hl or not hl.Parent then
		hl = Instance.new("Highlight")
		hl.FillColor           = ESP_FILL
		hl.FillTransparency    = 0.82
		hl.OutlineColor        = ESP_OUTLINE
		hl.OutlineTransparency = 0
		hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee             = char
		hl.Parent              = ScreenGui
		d.highlight            = hl
	elseif hl.Adornee ~= char then
		hl.Adornee = char
	end
end

local function UpdateNames(player, hrp)
	local d = GetData(player)
	if not NamesEnabled then
		if d.billboard then
			SafeDestroy(d.billboard)
			d.billboard = nil
		end
		return
	end
	local bb = d.billboard
	if not bb or not bb.Parent then
		bb = Instance.new("BillboardGui")
		bb.Size           = UDim2.new(0, 120, 0, 24)
		bb.StudsOffset    = Vector3.new(0, 3.5, 0)
		bb.AlwaysOnTop    = true
		bb.LightInfluence = 0
		bb.Adornee        = hrp
		bb.Parent         = ScreenGui
		local txt = Instance.new("TextLabel", bb)
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 11
		d.billboard = bb
	elseif bb.Adornee ~= hrp then
		bb.Adornee = hrp
	end
end

local function SetupPlayer(player)
	if player == LocalPlayer then return end
	local d = GetData(player)
	if d.charConn then
		pcall(function() d.charConn:Disconnect() end)
	end
	d.charConn = player.CharacterAdded:Connect(function()
		HardRemoveESP(player)
		local nd = GetData(player)
		nd.origSize     = nil
		nd.origTrans    = nil
		nd.origCollide  = nil
		nd.hitboxActive = false
		nd.lastCharacter = nil
	end)
	FetchAvatar(player)
end

local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local rayFilterCache = {}

local function IsVisible(targetPos, localChar, enemyChar)
	local n = 0
	if Camera then n = n + 1; rayFilterCache[n] = Camera end
	if localChar then n = n + 1; rayFilterCache[n] = localChar end
	if enemyChar then n = n + 1; rayFilterCache[n] = enemyChar end
	for i = #rayFilterCache, n + 1, -1 do rayFilterCache[i] = nil end
	rayParams.FilterDescendantsInstances = rayFilterCache
	local origin = Camera.CFrame.Position
	local dir = targetPos - origin
	local result = workspace:Raycast(origin, dir, rayParams)
	return result == nil
end

local function IsPlayerStillValid(player)
	if not player or not player.Parent then return false end
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	return hum ~= nil and hum.Health > 0
end

local noclipParts = {}
local lastNoclipUpdate = 0

local noclipFallStartTime = nil
local noclipLastY = nil
local noclipLastYTime = nil
local noclipJustTeleported = false
local NOCLIP_EMERGENCY_Y = -80
local NOCLIP_NO_GROUND_DIST = 30
local NOCLIP_FALLING_VEL = -8
local NOCLIP_FALL_DURATION = 1.2

local function UpdateNoclipCache()
	local char = LocalPlayer.Character
	if not char then noclipParts = {}; return end
	local newParts = {}
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			newParts[#newParts + 1] = part
		end
	end
	noclipParts = newParts
end

local function GetNearestPlayer()
	local bestDist = math.huge
	local bestHRP = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		local pc = player.Character
		if not pc then continue end
		local phrp = pc:FindFirstChild("HumanoidRootPart") or pc:FindFirstChild("Torso")
		if not phrp then continue end
		local myChar = LocalPlayer.Character
		local myHRP = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
		local dist = myHRP and (myHRP.Position - phrp.Position).Magnitude or 0
		if dist < bestDist then
			bestDist = dist
			bestHRP = phrp
		end
	end
	return bestHRP
end

local noclipGroundParams = RaycastParams.new()
noclipGroundParams.FilterType = Enum.RaycastFilterType.Exclude
noclipGroundParams.IgnoreWater = true

local function HasGroundNear(hrp)
	local char = LocalPlayer.Character
	noclipGroundParams.FilterDescendantsInstances = char and {char} or {}
	local result = workspace:Raycast(
		hrp.Position + Vector3.new(0, 2, 0),
		Vector3.new(0, -(NOCLIP_NO_GROUND_DIST + 2), 0),
		noclipGroundParams
	)
	return result ~= nil
end

local function DoNoclipTeleport(hrp)
	if noclipJustTeleported then return end
	if not hrp or not hrp.Parent then return end
	local nearestHRP = GetNearestPlayer()
	if not nearestHRP or not nearestHRP.Parent then return end
	noclipJustTeleported = true
	noclipFallStartTime = nil
	noclipLastY = nil
	noclipLastYTime = nil
	local ok = pcall(function()
		hrp.CFrame = nearestHRP.CFrame + Vector3.new(0, 3, 2)
		hrp.AssemblyLinearVelocity = Vector3.zero
	end)
	if not ok then
		noclipJustTeleported = false
		return
	end
	task.delay(1, function()
		noclipJustTeleported = false
	end)
end

local function ApplyNoclip()
	if not NoclipEnabled then
		noclipFallStartTime = nil
		noclipLastY = nil
		noclipLastYTime = nil
		return
	end

	local char = LocalPlayer.Character
	local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))

	if hrp and hrp.Parent and not noclipJustTeleported then
		local currentY = hrp.Position.Y
		local now = tick()

		if currentY <= NOCLIP_EMERGENCY_Y then
			DoNoclipTeleport(hrp)
		else
			local velY = hrp.AssemblyLinearVelocity.Y
			local isFallingFast = velY <= NOCLIP_FALLING_VEL
			local noGround = isFallingFast and not HasGroundNear(hrp)

			if noGround then
				if not noclipFallStartTime then
					noclipFallStartTime = now
				else
					local fallDuration = now - noclipFallStartTime
					if fallDuration >= NOCLIP_FALL_DURATION then
						DoNoclipTeleport(hrp)
					end
				end
			else
				noclipFallStartTime = nil
			end
		end

		noclipLastY = currentY
		noclipLastYTime = now
	end

	for i = 1, #noclipParts do
		local part = noclipParts[i]
		if part and part.Parent then
			pcall(function() part.CanCollide = false end)
		end
	end
end

local cachedPlayers = Players:GetPlayers()

for _, p in ipairs(cachedPlayers) do
	SetupPlayer(p)
end

track(LocalPlayer.CharacterAdded:Connect(function()
	noclipFallStartTime = nil
	noclipLastY = nil
	noclipLastYTime = nil
	noclipJustTeleported = false
	task.wait(0.5)
	UpdateNoclipCache()
	for player, data in pairs(playerData) do
		if data then
			HardRemoveESP(player)
			data.origSize     = nil
			data.origTrans    = nil
			data.origCollide  = nil
			data.hitboxActive = false
			data.lastCharacter = nil
		end
	end
end))

if LocalPlayer.Character then
	UpdateNoclipCache()
end

track(RunService.Stepped:Connect(function()
	local now = tick()
	if now - lastNoclipUpdate > 2 then
		UpdateNoclipCache()
		lastNoclipUpdate = now
	end
	ApplyNoclip()
end))

local CurrentAimTarget = nil
local CurrentAimMiss   = 0
local prevVelocities   = {}

local function GetAngleToTarget(camCF, worldPos)
	local dir = (worldPos - camCF.Position).Unit
	local dot = math.clamp(dir:Dot(camCF.LookVector), -1, 1)
	return math.deg(math.acos(dot))
end

local function GetAimPosition(char)
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	if torso then return torso.Position end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then return hrp.Position end
	return nil
end

track(RunService.RenderStepped:Connect(function(dt)
	local vp     = Camera.ViewportSize
	local cx     = vp.X * 0.5
	local cy     = vp.Y * 0.5
	local camCF  = Camera.CFrame
	local camPos = camCF.Position
	local localChar = LocalPlayer.Character

	local candidates = {}
	local bestPlayer, bestScreenDist2 = nil, math.huge

	for i = 1, #cachedPlayers do
		local player = cachedPlayers[i]
		if player ~= LocalPlayer then
			pcall(function()
				local char = player.Character
				if not char then HardRemoveESP(player) return end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then HardRemoveESP(player) return end

				local d = GetData(player)
				if d.lastCharacter ~= char then
					if d.lastCharacter then
						HardRemoveESP(player)
					end
					d.lastCharacter  = char
					d.hitboxActive   = false
					d.origSize       = nil
					d.origTrans      = nil
					d.origCollide    = nil
				end

				local hum = char:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then
					if d.hitboxActive then RestoreHRP(d, hrp) end
					HardRemoveESP(player)
					return
				end

				if HitboxMode > 0 then
					ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
				elseif d.hitboxActive then
					RestoreHRP(d, hrp)
				end

				UpdateHighlight(player, char)
				UpdateNames(player, hrp)

				if AimbotEnabled then
					local rawPos = GetAimPosition(char)
					if not rawPos then return end

					local vel = hrp.AssemblyLinearVelocity
					local pid = player.UserId
					local prevVel = prevVelocities[pid]
					local accel = Vector3.zero
					if prevVel then
						accel = (vel - prevVel) / math.max(dt, 0.001)
					end
					prevVelocities[pid] = vel

					local predictionTime = AIM_PREDICTION
					local predictedPos = rawPos + vel * predictionTime + accel * (predictionTime * predictionTime * 0.5)

					local sp, onScreen = Camera:WorldToViewportPoint(predictedPos)
					if onScreen and sp.Z > 0 then
						local dx = sp.X - cx
						local dy = sp.Y - cy
						local dist2 = dx * dx + dy * dy
						if dist2 <= FOV_RADIUS * FOV_RADIUS then
							local worldDist = (camPos - hrp.Position).Magnitude
							if worldDist <= MaxTargetDistance then
								if IsVisible(rawPos, localChar, char) then
									candidates[player] = {
										pos         = predictedPos,
										rawPos      = rawPos,
										screenDist2 = dist2,
										worldDist   = worldDist,
									}
									if dist2 < bestScreenDist2 then
										bestScreenDist2 = dist2
										bestPlayer = player
									end
								end
							end
						end
					end
				end
			end)
		end
	end

	if AimbotEnabled then
		local chosenPlayer = nil

		if CurrentAimTarget then
			local currentData = candidates[CurrentAimTarget]
			if currentData then
				CurrentAimMiss = 0
				if bestPlayer and bestPlayer ~= CurrentAimTarget then
					local currentAngle = GetAngleToTarget(camCF, currentData.pos)
					local bestAngle = GetAngleToTarget(camCF, candidates[bestPlayer].pos)
					chosenPlayer = bestAngle < currentAngle - AIM_SWITCH_ANGLE and bestPlayer or CurrentAimTarget
				else
					chosenPlayer = CurrentAimTarget
				end
			else
				if CurrentAimMiss < AIM_MAX_MISS_FRAMES and IsPlayerStillValid(CurrentAimTarget) then
					CurrentAimMiss = CurrentAimMiss + 1
					chosenPlayer = CurrentAimTarget
				else
					CurrentAimMiss = 0
					chosenPlayer = bestPlayer
				end
			end
		else
			CurrentAimMiss = 0
			chosenPlayer = bestPlayer
		end

		CurrentAimTarget = chosenPlayer

		if chosenPlayer then
			local data = candidates[chosenPlayer]
			if data then
				local alpha = 1 - (1 - AIM_SMOOTHNESS) ^ (dt * 60)
				local desiredCFrame = CFrame.new(camPos, data.pos)
				Camera.CFrame = camCF:Lerp(desiredCFrame, alpha)
			end
		end
	else
		CurrentAimTarget = nil
		CurrentAimMiss   = 0
		prevVelocities   = {}
	end
end))

task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		task.wait(1)
		pcall(function()
			for i = 1, #cachedPlayers do
				local player = cachedPlayers[i]
				if player ~= LocalPlayer then
					local char = player.Character
					if char then
						local hrp = char:FindFirstChild("HumanoidRootPart")
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hrp and hum and hum.Health > 0 then
							local d = GetData(player)
							if EspEnabled and (not d.highlight or not d.highlight.Parent or d.highlight.Adornee ~= char) then
								UpdateHighlight(player, char)
							end
							if NamesEnabled and (not d.billboard or not d.billboard.Parent or d.billboard.Adornee ~= hrp) then
								UpdateNames(player, hrp)
							end
						end
					end
				end
			end
		end)
	end
end)

track(Players.PlayerRemoving:Connect(function(player)
	CleanupPlayer(player)
	prevVelocities[player.UserId] = nil
	for i = 1, #cachedPlayers do
		if cachedPlayers[i] == player then
			table.remove(cachedPlayers, i)
			break
		end
	end
	if PlayerListPanel and PlayerListPanel.Visible then RefreshPlayerList() end
end))

track(Players.PlayerAdded:Connect(function(player)
	cachedPlayers[#cachedPlayers + 1] = player
	SetupPlayer(player)
	if PlayerListPanel and PlayerListPanel.Visible then RefreshPlayerList() end
end))

_G.__ZetaUnload = function()
	for i = 1, #connections do
		local c = connections[i]
		if c then pcall(function() c:Disconnect() end) end
	end
	connections = {}

	if FlyEnabled then
		FlyEnabled = false
		StopFly()
	end

	for player, _ in pairs(playerData) do
		pcall(CleanupPlayer, player)
	end

	AimbotEnabled    = false
	EspEnabled       = false
	NamesEnabled     = false
	NoclipEnabled    = false
	FlyEnabled       = false
	CurrentAimTarget = nil
	prevVelocities   = {}
	noclipParts      = {}
	noclipFallStartTime  = nil
	noclipLastY          = nil
	noclipLastYTime      = nil
	noclipJustTeleported = false

	pcall(function() ScreenGui:Destroy() end)
end

end)

if not ok_main then
	local Players2 = game:GetService("Players")
	local lp2 = Players2.LocalPlayer
	local pg2 = lp2:WaitForChild("PlayerGui", 15)
	if pg2 then
		local sg = Instance.new("ScreenGui", pg2)
		sg.Name = "ZetaError"
		sg.ResetOnSpawn = false
		local lbl = Instance.new("TextLabel", sg)
		lbl.Size = UDim2.new(1, 0, 0, 40)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.Text = "Zeta Error: " .. tostring(err_main)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 11
		lbl.TextWrapped = true
	end
end