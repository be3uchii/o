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

local ACCENT_ON   = Color3.fromRGB(70, 200, 255)
local ACCENT_2    = Color3.fromRGB(70, 200, 255)
local ACCENT_GLOW = Color3.fromRGB(120, 220, 255)
local BG_MAIN     = Color3.fromRGB(13, 13, 16)
local BG_PANEL    = Color3.fromRGB(20, 20, 25)
local BG_CARD     = Color3.fromRGB(26, 26, 32)
local BG_CARD_HOV = Color3.fromRGB(32, 32, 40)
local TXT_PRIMARY = Color3.fromRGB(245, 245, 248)
local TXT_DIM     = Color3.fromRGB(130, 130, 142)
local STROKE_SOFT = Color3.fromRGB(40, 40, 50)
local TOGGLE_OFF  = Color3.fromRGB(48, 48, 58)
local ESP_FILL    = Color3.fromRGB(0, 255, 100)
local ESP_OUTLINE = Color3.fromRGB(100, 255, 150)

local TI_FAST  = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TI_SMOOTH= TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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

local function mkGradient(parent, c1, c2, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rot or 90
	g.Parent = parent
	return g
end

local C_RED = Color3.fromRGB(235, 82, 82)
local C_WHT = Color3.fromRGB(255, 255, 255)
local C_BTN = Color3.fromRGB(42, 44, 56)

local ToggleUIBtn = Instance.new("TextButton")
ToggleUIBtn.Size = UDim2.new(0, 34, 0, 34)
ToggleUIBtn.Position = UDim2.new(0, 14, 0.5, -17)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = ACCENT_ON
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 16
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
ToggleUIBtn.Parent = ScreenGui
corner(ToggleUIBtn, 11)
local tubStroke = mkStroke(ToggleUIBtn, ACCENT_ON, 1.4, 0.3)

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 230, 0, 280)
Frame.Position = UDim2.new(0.5, -115, 0.5, -140)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = false
Frame.Active = true
Frame.Parent = ScreenGui
corner(Frame, 16)
mkStroke(Frame, STROKE_SOFT, 1.2, 0.1)
mkGradient(Frame, Color3.fromRGB(26, 28, 38), Color3.fromRGB(13, 14, 19), 90)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Frame

local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 14, 0.5, -4)
LogoDot.BackgroundColor3 = ACCENT_ON
LogoDot.Parent = TopBar
corner(LogoDot, 4)
mkGradient(LogoDot, ACCENT_ON, ACCENT_2, 45)
local dg = mkStroke(LogoDot, ACCENT_GLOW, 4, 0.6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 28, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -11)
CloseBtn.BackgroundColor3 = C_BTN
CloseBtn.Text = "×"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
corner(CloseBtn, 7)

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
TabBar.Size = UDim2.new(1, -24, 0, 30)
TabBar.Position = UDim2.new(0, 12, 0, 46)
TabBar.BackgroundColor3 = BG_PANEL
TabBar.Parent = Frame
corner(TabBar, 10)

local tl = Instance.new("UIListLayout")
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 4)
tl.Parent = TabBar
local tp = Instance.new("UIPadding")
tp.PaddingLeft = UDim.new(0, 4)
tp.PaddingRight = UDim.new(0, 4)
tp.PaddingTop = UDim.new(0, 4)
tp.PaddingBottom = UDim.new(0, 4)
tp.Parent = TabBar

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

ToggleUIBtn.MouseEnter:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_CARD}) tw(tubStroke, TI_FAST, {Transparency = 0}) end)
ToggleUIBtn.MouseLeave:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_MAIN}) tw(tubStroke, TI_FAST, {Transparency = 0.3}) end)
ToggleUIBtn.MouseButton1Click:Connect(function()
	local v = not Frame.Visible
	Frame.Visible = v
	if v then
		Frame.Size = UDim2.new(0, 230, 0, 0)
		tw(Frame, TI_SMOOTH, {Size = UDim2.new(0, 230, 0, 280)})
	else
		if PlayerListPanel then PlayerListPanel.Visible = false end
		if FlingListPanel then FlingListPanel.Visible = false end
	end
end)

local pages = {}
local tabButtons = {}
local tabOrder = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, -16, 1, -84)
	page.Position = UDim2.new(0, 8, 0, 82)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = ACCENT_ON
	page.ScrollBarImageTransparency = 0.4
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = Frame
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.Parent = page
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, 4)
	p.PaddingBottom = UDim.new(0, 5)
	p.Parent = page
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		local on = k == name
		pages[k].Visible = on
		local d = tabButtons[k]
		tw(d.btn, TI_FAST, {BackgroundColor3 = on and ACCENT_ON or BG_PANEL})
		tw(d.lbl, TI_FAST, {TextColor3 = on and BG_MAIN or TXT_DIM})
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.333, -4, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = TabBar
	corner(btn, 7)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
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
	card.Size = UDim2.new(1, 0, 0, 44)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 10)
	mkStroke(card, STROKE_SOFT, 1, 0.4)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 0, 22)
	accent.Position = UDim2.new(0, 0, 0.5, -11)
	accent.BackgroundColor3 = ACCENT_ON
	accent.BackgroundTransparency = 1
	accent.BorderSizePixel = 0
	accent.Parent = card
	corner(accent, 2)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -60, 0, 14)
	lbl.Position = UDim2.new(0, 12, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -60, 0, 11)
	sub.Position = UDim2.new(0, 12, 0, 24)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0, 34, 0, 18)
	track.Position = UDim2.new(1, -44, 0.5, -9)
	track.BackgroundColor3 = TOGGLE_OFF
	track.Parent = card
	corner(track, 9)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 3, 0.5, -6)
	knob.BackgroundColor3 = TXT_PRIMARY
	knob.Parent = track
	corner(knob, 6)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = card

	local ON_POS  = UDim2.new(1, -15, 0.5, -6)
	local OFF_POS = UDim2.new(0, 3, 0.5, -6)
	local state = false
	btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			tw(track, TI_MED, {BackgroundColor3 = ACCENT_ON})
			tw(knob, TI_MED, {Position = ON_POS})
			tw(accent, TI_FAST, {BackgroundTransparency = 0})
		else
			tw(track, TI_MED, {BackgroundColor3 = TOGGLE_OFF})
			tw(knob, TI_MED, {Position = OFF_POS})
			tw(accent, TI_FAST, {BackgroundTransparency = 1})
		end
		callback(state)
	end)
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 44)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 10)
	mkStroke(card, STROKE_SOFT, 1, 0.4)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -104, 0, 14)
	lbl.Position = UDim2.new(0, 12, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -104, 0, 11)
	sub.Position = UDim2.new(0, 12, 0, 24)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local cW, cH = 88, 20
	local cf = Instance.new("Frame")
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 8), 0.5, -(cH / 2))
	cf.BackgroundTransparency = 1
	cf.Parent = card

	local arrowL = Instance.new("TextButton")
	arrowL.Size = UDim2.new(0, cH, 1, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.Text = "‹"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 13
	arrowL.AutoButtonColor = false
	arrowL.Parent = cf
	corner(arrowL, 7)

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(1, -(cH * 2 + 4), 1, 0)
	valLabel.Position = UDim2.new(0, cH + 2, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 11
	valLabel.TextXAlignment = Enum.TextXAlignment.Center
	valLabel.Parent = cf

	local arrowR = Instance.new("TextButton")
	arrowR.Size = UDim2.new(0, cH, 1, 0)
	arrowR.Position = UDim2.new(1, -cH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.Text = "›"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 13
	arrowR.AutoButtonColor = false
	arrowR.Parent = cf
	corner(arrowR, 7)

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
	card.Size = UDim2.new(1, 0, 0, 44)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 10)
	mkStroke(card, STROKE_SOFT, 1, 0.4)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -70, 0, 14)
	lbl.Position = UDim2.new(0, 12, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.Parent = card

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -70, 0, 11)
	sub.Position = UDim2.new(0, 12, 0, 24)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.Parent = card

	local pill = Instance.new("TextLabel")
	pill.Size = UDim2.new(0, 50, 0, 20)
	pill.Position = UDim2.new(1, -58, 0.5, -10)
	pill.BackgroundColor3 = ACCENT_ON
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9
	pill.Parent = card
	corner(pill, 10)
	mkGradient(pill, ACCENT_ON, ACCENT_2, 0)

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
	panel.Size = UDim2.new(0, 210, 0, 250)
	panel.Position = UDim2.new(1, 10, 0, 0)
	panel.BackgroundColor3 = BG_MAIN
	panel.Visible = false
	panel.Parent = Frame
	corner(panel, 16)
	mkStroke(panel, STROKE_SOFT, 1.2, 0.1)
	mkGradient(panel, Color3.fromRGB(26, 28, 38), Color3.fromRGB(13, 14, 19), 90)

	local pTitle = Instance.new("TextLabel")
	pTitle.Size = UDim2.new(1, -44, 0, 36)
	pTitle.Position = UDim2.new(0, 14, 0, 0)
	pTitle.Text = titleText
	pTitle.TextColor3 = TXT_PRIMARY
	pTitle.TextXAlignment = Enum.TextXAlignment.Left
	pTitle.Font = Enum.Font.GothamBold
	pTitle.TextSize = 12
	pTitle.BackgroundTransparency = 1
	pTitle.Parent = panel

	local pClose = Instance.new("TextButton")
	pClose.Size = UDim2.new(0, 20, 0, 20)
	pClose.Position = UDim2.new(1, -30, 0, 8)
	pClose.BackgroundColor3 = C_BTN
	pClose.Text = "×"
	pClose.TextColor3 = TXT_DIM
	pClose.Font = Enum.Font.GothamBold
	pClose.TextSize = 14
	pClose.AutoButtonColor = false
	pClose.Parent = panel
	corner(pClose, 6)
	pClose.MouseEnter:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end)
	pClose.MouseLeave:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end)
	pClose.MouseButton1Click:Connect(function() panel.Visible = false end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -12, 1, -40)
	scroll.Position = UDim2.new(0, 6, 0, 38)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = ACCENT_ON
	scroll.ScrollBarImageTransparency = 0.4
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
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
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundColor3 = BG_CARD
	row.Parent = scroll
	corner(row, 8)

	local av = Instance.new("ImageLabel")
	av.Size = UDim2.new(0, 24, 0, 24)
	av.Position = UDim2.new(0, 6, 0.5, -12)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	av.Parent = row
	corner(av, 12)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -38, 1, 0)
	nameLbl.Position = UDim2.new(0, 36, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(240,242,248)'><b>%s</b></font>\n<font color='rgb(110,114,128)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 10
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
		d = {origSize=nil, origTrans=nil, origCollide=nil, hitboxActive=false, billboard=nil, highlight=nil, charConn=nil}
		playerData[player] = d
	end
	return d
end

local function SafeDestroy(inst)
	if inst and inst.Parent then inst:Destroy() end
end

local function RestoreHRP(data, hrp)
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
	if not d.origSize then
		d.origSize    = hrp.Size
		d.origTrans   = hrp.Transparency
		d.origCollide = hrp.CanCollide
	end
	hrp.Size         = Vector3.new(size, size, size)
	hrp.Transparency = 0.75
	hrp.CanCollide   = false
	d.hitboxActive   = true
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
		d.billboard = bb
	elseif bb.Adornee ~= hrp then
		bb.Adornee = hrp
	end
end

local function SetupPlayer(player)
	if player == LocalPlayer then return end
	local d = GetData(player)
	if d.charConn then d.charConn:Disconnect() end
	d.charConn = player.CharacterAdded:Connect(function()
		HardRemoveESP(player)
		local nd = GetData(player)
		nd.origSize = nil
		nd.hitboxActive = false
	end)
	FetchAvatar(player)
end

local rayParams = RaycastParams.new()
rayParams.FilterType  = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local rayFilter = {}

local function IsVisible(targetPos, localChar, enemyChar)
	rayFilter[1] = Camera
	rayFilter[2] = localChar
	rayFilter[3] = enemyChar
	rayParams.FilterDescendantsInstances = rayFilter
	local origin = Camera.CFrame.Position
	return workspace:Raycast(origin, targetPos - origin, rayParams) == nil
end

local noclipParts = {}
local lastNoclipUpdate = 0

local function UpdateNoclipCache()
	local char = LocalPlayer.Character
	if not char then
		noclipParts = {}
		return
	end
	local newParts = {}
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			newParts[#newParts + 1] = part
		end
	end
	noclipParts = newParts
end

local function ApplyNoclip()
	if not NoclipEnabled then return end
	for i = 1, #noclipParts do
		local part = noclipParts[i]
		if part and part.Parent then
			part.CanCollide = false
		end
	end
end

local cachedPlayers = Players:GetPlayers()

for _, p in ipairs(cachedPlayers) do SetupPlayer(p) end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	UpdateNoclipCache()
	for player, data in pairs(playerData) do
		if data then
			HardRemoveESP(player)
			data.origSize = nil
			data.hitboxActive = false
		end
	end
end)

if LocalPlayer.Character then
	UpdateNoclipCache()
end

RunService.Stepped:Connect(function()
	local now = tick()
	if now - lastNoclipUpdate > 2 then
		UpdateNoclipCache()
		lastNoclipUpdate = now
	end
	ApplyNoclip()
end)

local movel = 0.3

RunService.Heartbeat:Connect(function()
	if FlingEnabled and FlingTarget then
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local tchar = FlingTarget.Character
		if not tchar then return end
		local thrp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso")
		if not thrp then return end

		local vel = hrp.Velocity
		if vel.Magnitude < 1 then
			vel = Vector3.new(1, 0, 1)
		end
		local impulse = vel * 9000 + Vector3.new(0, 9000, 0)
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				part.Velocity = impulse
			end
		end
		hrp.CFrame = thrp.CFrame * CFrame.new(0, movel, 0)
		movel = movel * -1
		RunService.RenderStepped:Wait()
		if char and char.Parent then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.Velocity = vel
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local vp     = Camera.ViewportSize
	local cx     = vp.X * 0.5
	local cy     = vp.Y * 0.5
	local camCF  = Camera.CFrame
	local camPos = camCF.Position
	local localChar = LocalPlayer.Character
	local closestTarget, shortestDist = nil, math.huge
	local espActive = EspEnabled or NamesEnabled or HitboxMode > 0

	for i = 1, #cachedPlayers do
		local player = cachedPlayers[i]
		if player == LocalPlayer then continue end

		local char = player.Character
		if not char then HardRemoveESP(player) continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then HardRemoveESP(player) continue end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			local d = playerData[player]
			if d and d.hitboxActive then RestoreHRP(d, hrp) end
			HardRemoveESP(player)
			continue
		end

		if HitboxMode > 0 then
			ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
		else
			local d = playerData[player]
			if d and d.hitboxActive then RestoreHRP(d, hrp) end
		end

		UpdateHighlight(player, char)
		UpdateNames(player, hrp)

		if AimbotEnabled then
			local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
			local aimPos = torso and torso.Position or hrp.Position
			local sp, onScreen = Camera:WorldToViewportPoint(aimPos)
			if onScreen then
				local dx = sp.X - cx
				local dy = sp.Y - cy
				local dist = dx*dx + dy*dy
				if dist < FOV_RADIUS * FOV_RADIUS and dist < shortestDist then
					if (camPos - hrp.Position).Magnitude <= MaxTargetDistance then
						if IsVisible(aimPos, localChar, char) then
							shortestDist = dist
							closestTarget = aimPos
						end
					end
				end
			end
		end
	end

	if AimbotEnabled and closestTarget then
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
		if FlingPill then
			FlingPill.Text = "OPEN"
		end
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
