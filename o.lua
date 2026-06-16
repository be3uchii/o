local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimbotEnabled = false
local EspEnabled = false
local NamesEnabled = false
local NoclipEnabled = false
local FlingEnabled = false
local FlingTarget = nil
local HitboxMode = 0
local HitboxSizes = {0, 15, 30, 70}
local FOV_RADIUS = 110
local MaxTargetDistance = 600
local AIM_SMOOTHNESS = 0.22
local ESP_REFRESH_RATE = 0.1
local MaxTargetDistanceSq = MaxTargetDistance * MaxTargetDistance
local FOV_RADIUS_SQ = FOV_RADIUS * FOV_RADIUS

local ACCENT_ON   = Color3.fromRGB(88, 178, 255)
local ACCENT_GLOW = Color3.fromRGB(120, 200, 255)
local BG_MAIN     = Color3.fromRGB(14, 15, 19)
local BG_PANEL    = Color3.fromRGB(22, 23, 29)
local BG_CARD     = Color3.fromRGB(28, 29, 37)
local BG_CARD_HOV = Color3.fromRGB(36, 38, 48)
local TXT_PRIMARY = Color3.fromRGB(238, 240, 245)
local TXT_DIM     = Color3.fromRGB(124, 128, 140)
local STROKE_SOFT = Color3.fromRGB(44, 46, 58)
local TOGGLE_OFF  = Color3.fromRGB(52, 54, 66)
local ESP_FILL    = Color3.fromRGB(0, 255, 100)
local ESP_OUTLINE = Color3.fromRGB(100, 255, 150)

local TI_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_QUICK = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local UI_Target = (pcall(function() return CoreGui.Name end)) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zeta"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = UI_Target

if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
	local detection = Instance.new("Decal")
	detection.Name = "juisdfj0i32i0eidsuf0iok"
	detection.Parent = ReplicatedStorage
end

pcall(function()
	settings().Physics.AllowSleep = false
	LocalPlayer.MaximumSimulationRadius = math.huge
	sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
end)

local function tw(o, ti, p)
	TweenService:Create(o, ti, p):Play()
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = parent
	return c
end

local function mkStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function mkPadding(parent, all)
	local p = Instance.new("UIPadding")
	p.PaddingLeft   = UDim.new(0, all)
	p.PaddingRight  = UDim.new(0, all)
	p.PaddingTop    = UDim.new(0, all)
	p.PaddingBottom = UDim.new(0, all)
	p.Parent = parent
	return p
end

local C_RED = Color3.fromRGB(232, 78, 78)
local C_WHT = Color3.fromRGB(255, 255, 255)
local C_BTN = Color3.fromRGB(40, 42, 52)

local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0, 30, 0, 30)
ToggleUIBtn.Position = UDim2.new(0, 12, 0.5, -15)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = ACCENT_ON
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 14
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
ToggleUIBtn.Parent = ScreenGui
corner(ToggleUIBtn, 9)
mkStroke(ToggleUIBtn, STROKE_SOFT, 1, 0.1)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 214, 0, 248)
Frame.Position = UDim2.new(0.5, -107, 0.5, -124)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = false
Frame.Active = true
Frame.Parent = ScreenGui
corner(Frame, 14)
mkStroke(Frame, STROKE_SOFT, 1, 0.05)

local fg = Instance.new("UIGradient")
fg.Color = ColorSequence.new(Color3.fromRGB(24, 26, 34), Color3.fromRGB(12, 13, 17))
fg.Rotation = 90
fg.Parent = Frame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Frame

local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 6, 0, 6)
LogoDot.Position = UDim2.new(0, 12, 0.5, -3)
LogoDot.BackgroundColor3 = ACCENT_ON
LogoDot.Parent = TopBar
corner(LogoDot, 3)
local dg = Instance.new("UIStroke")
dg.Color = ACCENT_GLOW
dg.Thickness = 3
dg.Transparency = 0.55
dg.Parent = LogoDot

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -64, 1, 0)
Title.Position = UDim2.new(0, 24, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -10)
CloseBtn.BackgroundColor3 = C_BTN
CloseBtn.Text = "×"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
corner(CloseBtn, 6)

CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end)
CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end)

local PlayerListPanel
local FlingListPanel

local function HideAll()
	Frame.Visible = false
	if PlayerListPanel then PlayerListPanel.Visible = false end
	if FlingListPanel then FlingListPanel.Visible = false end
end

CloseBtn.MouseButton1Click:Connect(HideAll)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 26)
TabBar.Position = UDim2.new(0, 10, 0, 38)
TabBar.BackgroundColor3 = BG_PANEL
TabBar.Parent = Frame
corner(TabBar, 9)

local tl = Instance.new("UIListLayout")
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 3)
tl.Parent = TabBar
mkPadding(TabBar, 3)

do
	local isDragging, dragStart, startPos = false
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStart = input.Position
			startPos = Frame.Position
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

ToggleUIBtn.MouseEnter:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
ToggleUIBtn.MouseLeave:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_MAIN}) end)
ToggleUIBtn.MouseButton1Click:Connect(function()
	local v = not Frame.Visible
	Frame.Visible = v
	if not v then
		if PlayerListPanel then PlayerListPanel.Visible = false end
		if FlingListPanel then FlingListPanel.Visible = false end
	end
end)

local pages = {}
local tabButtons = {}
local tabOrder = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -14, 1, -72)
	page.Position = UDim2.new(0, 7, 0, 70)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = STROKE_SOFT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Frame
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 5)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.Parent = page
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, 3)
	p.PaddingBottom = UDim.new(0, 4)
	p.Parent = page
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		local on = k == name
		pages[k].Visible = on
		local d = tabButtons[k]
		tw(d.btn, TI_MED, {BackgroundColor3 = on and ACCENT_ON or BG_PANEL})
		tw(d.lbl, TI_MED, {TextColor3 = on and BG_MAIN or TXT_DIM})
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.333, -3, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = TabBar
	corner(btn, 6)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 10
	lbl.Parent = btn
	local page = CreatePage()
	pages[name] = page
	tabButtons[name] = {btn = btn, lbl = lbl}
	tabOrder[#tabOrder + 1] = name
	btn.MouseButton1Click:Connect(function() ShowPage(name) end)
	return page
end

local EspPage    = CreateTab("ESP")
local CombatPage = CreateTab("Combat")
local MiscPage   = CreateTab("Misc")

local function CreateToggle(parent, text, info, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 40)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -56, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -56, 0, 10)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0, 30, 0, 16)
	track.Position = UDim2.new(1, -40, 0.5, -8)
	track.BackgroundColor3 = TOGGLE_OFF
	track.Parent = card
	corner(track, 8)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 11, 0, 11)
	knob.Position = UDim2.new(0, 3, 0.5, -5)
	knob.BackgroundColor3 = TXT_PRIMARY
	knob.Parent = track
	corner(knob, 6)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = card

	local ON_POS  = UDim2.new(1, -14, 0.5, -5)
	local OFF_POS = UDim2.new(0, 3, 0.5, -5)
	local state = false
	btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			tw(track, TI_MED, {BackgroundColor3 = ACCENT_ON})
			tw(knob, TI_MED, {Position = ON_POS})
		else
			tw(track, TI_MED, {BackgroundColor3 = TOGGLE_OFF})
			tw(knob, TI_MED, {Position = OFF_POS})
		end
		callback(state)
	end)
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 40)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -100, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -100, 0, 10)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local cW, cH = 84, 18
	local cf = Instance.new("Frame")
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 6), 0.5, -(cH / 2))
	cf.BackgroundTransparency = 1
	cf.Parent = card

	local arrowL = Instance.new("TextButton")
	arrowL.Size = UDim2.new(0, cH, 1, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.Text = "‹"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 11
	arrowL.AutoButtonColor = false
	arrowL.Parent = cf
	corner(arrowL, 6)

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(1, -(cH * 2 + 4), 1, 0)
	valLabel.Position = UDim2.new(0, cH + 2, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Center
	valLabel.Parent = cf

	local arrowR = Instance.new("TextButton")
	arrowR.Size = UDim2.new(0, cH, 1, 0)
	arrowR.Position = UDim2.new(1, -cH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.Text = "›"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 11
	arrowR.AutoButtonColor = false
	arrowR.Parent = cf
	corner(arrowR, 6)

	arrowL.MouseEnter:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}) end)
	arrowL.MouseLeave:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}) end)
	arrowR.MouseEnter:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = ACCENT_ON, TextColor3 = BG_MAIN}) end)
	arrowR.MouseLeave:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = BG_PANEL, TextColor3 = TXT_PRIMARY}) end)

	local n = #values
	local idx = 1
	local function apply()
		valLabel.Text = labels[idx]
		sub.Text = labels[idx]
		callback(values[idx], idx)
	end
	arrowL.MouseButton1Click:Connect(function()
		idx = idx > 1 and idx - 1 or n
		apply()
	end)
	arrowR.MouseButton1Click:Connect(function()
		idx = idx < n and idx + 1 or 1
		apply()
	end)
	apply()
end

local function CreateAction(parent, text, info, btnText, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 40)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -64, 0, 13)
	lbl.Position = UDim2.new(0, 10, 0, 7)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -64, 0, 10)
	sub.Position = UDim2.new(0, 10, 0, 21)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 8
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local pill = Instance.new("TextLabel")
	pill.Size = UDim2.new(0, 44, 0, 18)
	pill.Position = UDim2.new(1, -50, 0.5, -9)
	pill.BackgroundColor3 = ACCENT_ON
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9
	pill.Parent = card
	corner(pill, 9)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = card

	btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function() callback(pill) end)

	return card, pill
end

CreateToggle(EspPage, "ESP", "Highlight boxes", function(on) EspEnabled = on end)
CreateToggle(EspPage, "Names", "Show nicknames", function(on) NamesEnabled = on end)
CreateToggle(CombatPage, "Aimbot", "Lock on target", function(on) AimbotEnabled = on end)
CreateStepper(CombatPage, "Hitbox", {0,15,30,70}, {"OFF","15x","30x","70x"}, function(value, idx)
	HitboxMode = idx - 1
end)

local RefreshPlayerList
local RefreshFlingList
local FlingPill

CreateAction(MiscPage, "Teleport to Player", "Pick from list", "OPEN", function()
	if PlayerListPanel then
		local v = not PlayerListPanel.Visible
		PlayerListPanel.Visible = v
		if FlingListPanel then FlingListPanel.Visible = false end
		if v then RefreshPlayerList() end
	end
end)

local flingCard, flingPillRef = CreateAction(MiscPage, "Fling Player", "Select target", "OPEN", function(pill)
	if FlingEnabled then
		FlingEnabled = false
		FlingTarget = nil
		pill.Text = "OPEN"
		if FlingListPanel then FlingListPanel.Visible = false end
	else
		if FlingListPanel then
			local v = not FlingListPanel.Visible
			FlingListPanel.Visible = v
			if PlayerListPanel then PlayerListPanel.Visible = false end
			if v then RefreshFlingList() end
		end
	end
end)
FlingPill = flingPillRef

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
	tw(pill, TI_QUICK, {BackgroundColor3 = ACCENT_GLOW})
	task.delay(0.3, function() tw(pill, TI_FAST, {BackgroundColor3 = ACCENT_ON}) end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

local function MakeListPanel(titleText)
	local panel = Instance.new("Frame")
	panel.Size = UDim2.new(0, 196, 0, 220)
	panel.Position = UDim2.new(1, 8, 0, 0)
	panel.BackgroundColor3 = BG_MAIN
	panel.Visible = false
	panel.Parent = Frame
	corner(panel, 14)
	mkStroke(panel, STROKE_SOFT, 1, 0.05)

	local pfg = Instance.new("UIGradient")
	pfg.Color = ColorSequence.new(Color3.fromRGB(24, 26, 34), Color3.fromRGB(12, 13, 17))
	pfg.Rotation = 90
	pfg.Parent = panel

	local pTitle = Instance.new("TextLabel")
	pTitle.Size = UDim2.new(1, -40, 0, 30)
	pTitle.Position = UDim2.new(0, 12, 0, 0)
	pTitle.Text = titleText
	pTitle.TextColor3 = TXT_PRIMARY
	pTitle.TextXAlignment = Enum.TextXAlignment.Left
	pTitle.Font = Enum.Font.GothamBold
	pTitle.TextSize = 11
	pTitle.BackgroundTransparency = 1
	pTitle.Parent = panel

	local pClose = Instance.new("TextButton")
	pClose.Size = UDim2.new(0, 18, 0, 18)
	pClose.Position = UDim2.new(1, -26, 0, 6)
	pClose.BackgroundColor3 = C_BTN
	pClose.Text = "×"
	pClose.TextColor3 = TXT_DIM
	pClose.Font = Enum.Font.GothamBold
	pClose.TextSize = 12
	pClose.AutoButtonColor = false
	pClose.Parent = panel
	corner(pClose, 5)
	pClose.MouseEnter:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end)
	pClose.MouseLeave:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end)
	pClose.MouseButton1Click:Connect(function() panel.Visible = false end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -34)
	scroll.Position = UDim2.new(0, 5, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 2
	scroll.ScrollBarImageColor3 = STROKE_SOFT
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = scroll

	return panel, scroll
end

local plScroll, flScroll
PlayerListPanel, plScroll = MakeListPanel("Players")
FlingListPanel, flScroll = MakeListPanel("Fling Target")

local avatarCache   = {}
local avatarPending = {}

local function FetchAvatar(player, onDone)
	local uid = player.UserId
	local cached = avatarCache[uid]
	if cached then
		if onDone then onDone(cached) end
		return
	end
	local queue = avatarPending[uid]
	if queue then
		if onDone then queue[#queue + 1] = onDone end
		return
	end
	queue = {}
	if onDone then queue[1] = onDone end
	avatarPending[uid] = queue
	task.spawn(function()
		local ok, url = pcall(Players.GetUserThumbnailAsync, Players, uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		local cbs = avatarPending[uid]
		avatarPending[uid] = nil
		if ok and url and url ~= "" then
			avatarCache[uid] = url
			if cbs then
				for i = 1, #cbs do cbs[i](url) end
			end
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

local function MakeRow(scroll, player, onClick)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = BG_CARD
	row.Parent = scroll
	corner(row, 7)

	local av = Instance.new("ImageLabel")
	av.Size = UDim2.new(0, 22, 0, 22)
	av.Position = UDim2.new(0, 6, 0.5, -11)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	av.Parent = row
	corner(av, 11)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -36, 1, 0)
	nameLbl.Position = UDim2.new(0, 33, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(238,240,245)'><b>%s</b></font>\n<font color='rgb(108,112,124)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 9
	nameLbl.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row
	btn.MouseEnter:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function()
		onClick(player)
		tw(row, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
		task.delay(0.25, function() if row.Parent then tw(row, TI_FAST, {BackgroundColor3 = BG_CARD}) end end)
	end)
end

local function RefreshList(scroll, onClick)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local list = Players:GetPlayers()
	for i = 1, #list do
		if list[i] ~= LocalPlayer then MakeRow(scroll, list[i], onClick) end
	end
end

RefreshPlayerList = function()
	RefreshList(plScroll, TeleportToPlayer)
end

RefreshFlingList = function()
	RefreshList(flScroll, function(player)
		FlingTarget = player
		FlingEnabled = true
		if FlingPill then FlingPill.Text = "STOP" end
		if FlingListPanel then FlingListPanel.Visible = false end
	end)
end

ShowPage("ESP")

local playerData = {}

local function GetData(player)
	local d = playerData[player]
	if not d then
		d = {}
		playerData[player] = d
	end
	return d
end

local function SafeDestroy(inst)
	if inst and inst.Parent then inst:Destroy() end
end

local function RestoreHRP(data)
	local hrp = data.hrp
	if data.origSize and hrp and hrp.Parent then
		hrp.Size = data.origSize
		hrp.Transparency = data.origTrans
		hrp.CanCollide = data.origCollide
		data.origSize = nil
		data.hitboxActive = false
	end
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
	if d.charConn then d.charConn:Disconnect() d.charConn = nil end
	if d.hitboxActive then RestoreHRP(d) end
	HardRemoveESP(player)
	playerData[player] = nil
	avatarCache[player.UserId] = nil
	avatarPending[player.UserId] = nil
end

local function CacheCharacter(player, char)
	local d = GetData(player)
	HardRemoveESP(player)
	d.origSize = nil
	d.hitboxActive = false
	d.char = char
	d.hrp = char:WaitForChild("HumanoidRootPart", 5)
	d.humanoid = char:FindFirstChildOfClass("Humanoid")
	d.torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function ApplyHitbox(data, size)
	local hrp = data.hrp
	if not hrp then return end
	if not data.origSize then
		data.origSize    = hrp.Size
		data.origTrans   = hrp.Transparency
		data.origCollide = hrp.CanCollide
	end
	hrp.Size         = Vector3.new(size, size, size)
	hrp.Transparency = 0.75
	hrp.CanCollide   = false
	data.hitboxActive = true
end

local function UpdateHighlight(data, char)
	if not EspEnabled then
		if data.highlight then SafeDestroy(data.highlight) data.highlight = nil end
		return
	end
	local hl = data.highlight
	if not hl or not hl.Parent then
		hl = Instance.new("Highlight")
		hl.FillColor           = ESP_FILL
		hl.FillTransparency    = 0.82
		hl.OutlineColor        = ESP_OUTLINE
		hl.OutlineTransparency = 0
		hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee             = char
		hl.Parent              = ScreenGui
		data.highlight         = hl
	elseif hl.Adornee ~= char then
		hl.Adornee = char
	end
end

local function UpdateNames(data, player, hrp)
	if not NamesEnabled then
		if data.billboard then SafeDestroy(data.billboard) data.billboard = nil end
		return
	end
	local bb = data.billboard
	if not bb or not bb.Parent then
		bb = Instance.new("BillboardGui")
		bb.Size         = UDim2.new(0, 100, 0, 20)
		bb.StudsOffset  = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop  = true
		bb.LightInfluence = 0
		bb.Adornee      = hrp
		bb.Parent       = ScreenGui
		local txt = Instance.new("TextLabel")
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 10
		txt.Parent = bb
		data.billboard = bb
	elseif bb.Adornee ~= hrp then
		bb.Adornee = hrp
	end
end

local function SetupPlayer(player)
	if player == LocalPlayer then return end
	local d = GetData(player)
	if d.charConn then d.charConn:Disconnect() end
	d.charConn = player.CharacterAdded:Connect(function(char)
		CacheCharacter(player, char)
	end)
	if player.Character then CacheCharacter(player, player.Character) end
	FetchAvatar(player)
end

local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local rayFilter = {Camera, nil, nil}

local function IsVisible(targetPos, localChar, enemyChar)
	rayFilter[2] = localChar
	rayFilter[3] = enemyChar
	rayParams.FilterDescendantsInstances = rayFilter
	local origin = Camera.CFrame.Position
	return workspace:Raycast(origin, targetPos - origin, rayParams) == nil
end

local noclipParts = {}

local function UpdateNoclipCache()
	local char = LocalPlayer.Character
	if not char then noclipParts = {} return end
	local newParts = {}
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			newParts[#newParts + 1] = part
		end
	end
	noclipParts = newParts
end

local cachedPlayers = Players:GetPlayers()
for _, p in ipairs(cachedPlayers) do SetupPlayer(p) end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	UpdateNoclipCache()
	for player in pairs(playerData) do
		HardRemoveESP(player)
	end
end)

if LocalPlayer.Character then UpdateNoclipCache() end

RunService.Stepped:Connect(function()
	if not NoclipEnabled then return end
	for i = 1, #noclipParts do
		local part = noclipParts[i]
		if part and part.Parent then
			part.CanCollide = false
		end
	end
end)

local movel = 0.3

RunService.Heartbeat:Connect(function()
	if not (FlingEnabled and FlingTarget) then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local tchar = FlingTarget.Character
	if not tchar then return end
	local thrp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso")
	if not thrp then return end

	local vel = hrp.AssemblyLinearVelocity
	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = vel * 9000 + Vector3.new(0, 9000, 0)
		end
	end
	movel = movel * -1
	hrp.CFrame = thrp.CFrame * CFrame.new(0, movel, 0)
end)

local espAccum = 0

RunService.Heartbeat:Connect(function(dt)
	espAccum = espAccum + dt
	if espAccum < ESP_REFRESH_RATE then return end
	espAccum = 0

	local hitboxSize = HitboxMode > 0 and HitboxSizes[HitboxMode + 1] or 0

	for i = 1, #cachedPlayers do
		local player = cachedPlayers[i]
		if player ~= LocalPlayer then
			local d = playerData[player]
			if d then
				local char = d.char
				local hrp = d.hrp
				local hum = d.humanoid
				if not char or not char.Parent or not hrp or not hrp.Parent or not hum or hum.Health <= 0 then
					if d.hitboxActive then RestoreHRP(d) end
					HardRemoveESP(player)
				else
					if hitboxSize > 0 then
						ApplyHitbox(d, hitboxSize)
					elseif d.hitboxActive then
						RestoreHRP(d)
					end
					UpdateHighlight(d, char)
					UpdateNames(d, player, hrp)
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if not AimbotEnabled then return end
	local vp     = Camera.ViewportSize
	local cx     = vp.X * 0.5
	local cy     = vp.Y * 0.5
	local camCF  = Camera.CFrame
	local camPos = camCF.Position
	local localChar = LocalPlayer.Character
	local closestTarget, shortestDist = nil, FOV_RADIUS_SQ

	for i = 1, #cachedPlayers do
		local player = cachedPlayers[i]
		if player ~= LocalPlayer then
			local d = playerData[player]
			if d then
				local char = d.char
				local hrp = d.hrp
				local hum = d.humanoid
				if char and char.Parent and hrp and hrp.Parent and hum and hum.Health > 0 then
					local aimPart = d.torso
					local aimPos = (aimPart and aimPart.Parent) and aimPart.Position or hrp.Position
					if (camPos - hrp.Position).Magnitude <= MaxTargetDistance then
						local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
						if onScreen then
							local dx = sp.X - cx
							local dy = sp.Y - cy
							local dist = dx*dx + dy*dy
							if dist < shortestDist and IsVisible(aimPos, localChar, char) then
								shortestDist = dist
								closestTarget = aimPos
							end
						end
					end
				end
			end
		end
	end

	if closestTarget then
		local alpha = 1 - (1 - AIM_SMOOTHNESS) ^ (dt * 60)
		Camera.CFrame = camCF:Lerp(CFrame.new(camPos, closestTarget), alpha)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	CleanupPlayer(player)
	for i = 1, #cachedPlayers do
		if cachedPlayers[i] == player then
			table.remove(cachedPlayers, i)
			break
		end
	end
	if FlingTarget == player then
		FlingTarget = nil
		FlingEnabled = false
		if FlingPill then FlingPill.Text = "OPEN" end
	end
	if PlayerListPanel and PlayerListPanel.Visible then RefreshPlayerList() end
	if FlingListPanel and FlingListPanel.Visible then RefreshFlingList() end
end)

Players.PlayerAdded:Connect(function(player)
	cachedPlayers[#cachedPlayers + 1] = player
	SetupPlayer(player)
	if PlayerListPanel and PlayerListPanel.Visible then RefreshPlayerList() end
	if FlingListPanel and FlingListPanel.Visible then RefreshFlingList() end
end)
