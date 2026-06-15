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

local GLASS_WHITE = Color3.fromRGB(255, 255, 255)
local GLASS_TINT  = Color3.fromRGB(180, 200, 230)
local GLASS_DARK  = Color3.fromRGB(40, 50, 70)
local TEXT_DARK   = Color3.fromRGB(30, 30, 40)
local TEXT_LIGHT  = Color3.fromRGB(255, 255, 255)
local TEXT_GRAY   = Color3.fromRGB(150, 155, 170)
local ACCENT_BLUE = Color3.fromRGB(90, 160, 255)
local ACCENT_GLOW = Color3.fromRGB(120, 180, 255)
local BTN_OFF     = Color3.fromRGB(220, 225, 235)
local ESP_FILL    = Color3.fromRGB(0, 255, 100)
local ESP_OUTLINE = Color3.fromRGB(100, 255, 150)

local TI_FAST  = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_QUICK = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TI_SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local UI_Target = (pcall(function() return CoreGui.Name end)) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Zeta"
ScreenGui.ResetOnSpawn = false
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
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, r)
end

local function addGlow(parent, color, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color = color
	s.Thickness = 1.5
	s.Transparency = transparency or 0.4
end

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleUIBtn.Position = UDim2.new(0, 14, 0.5, -22)
ToggleUIBtn.BackgroundColor3 = GLASS_WHITE
ToggleUIBtn.BackgroundTransparency = 0.2
ToggleUIBtn.TextColor3 = TEXT_DARK
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 20
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
corner(ToggleUIBtn, 14)
addGlow(ToggleUIBtn, GLASS_TINT, 0.3)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 440)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
MainFrame.BackgroundColor3 = GLASS_WHITE
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.ClipsDescendants = true
corner(MainFrame, 28)
addGlow(MainFrame, GLASS_TINT, 0.2)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(255, 255, 255)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3

local mainGradient = Instance.new("UIGradient", MainFrame)
mainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 245))
})
mainGradient.Rotation = 135
mainGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.1),
	NumberSequenceKeypoint.new(0.5, 0.05),
	NumberSequenceKeypoint.new(1, 0.2)
})

local shineOverlay = Instance.new("Frame", MainFrame)
shineOverlay.Size = UDim2.new(1, 0, 0.5, 0)
shineOverlay.Position = UDim2.new(0, 0, 0, 0)
shineOverlay.BackgroundColor3 = GLASS_WHITE
shineOverlay.BackgroundTransparency = 0.7
shineOverlay.BorderSizePixel = 0
shineOverlay.ZIndex = 1

local shineGradient = Instance.new("UIGradient", shineOverlay)
shineGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
shineGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.6),
	NumberSequenceKeypoint.new(0.5, 0.85),
	NumberSequenceKeypoint.new(1, 1)
})
shineGradient.Rotation = 90

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, -40, 0, 50)
TitleBar.Position = UDim2.new(0, 20, 0, 15)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 2

local LogoCircle = Instance.new("Frame", TitleBar)
LogoCircle.Size = UDim2.new(0, 32, 0, 32)
LogoCircle.Position = UDim2.new(0, 0, 0.5, -16)
LogoCircle.BackgroundColor3 = ACCENT_BLUE
LogoCircle.ZIndex = 2
corner(LogoCircle, 10)
addGlow(LogoCircle, ACCENT_GLOW, 0)

local LogoG = Instance.new("UIGradient", LogoCircle)
LogoG.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 180, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 130, 230))
})
LogoG.Rotation = 45

local LogoText = Instance.new("TextLabel", LogoCircle)
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "Z"
LogoText.TextColor3 = TEXT_LIGHT
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 16
LogoText.ZIndex = 3

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(0, 150, 0, 32)
TitleText.Position = UDim2.new(0, 44, 0.5, -16)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Zeta Hub"
TitleText.TextColor3 = TEXT_DARK
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.ZIndex = 2

local SubText = Instance.new("TextLabel", TitleBar)
SubText.Size = UDim2.new(0, 150, 0, 12)
SubText.Position = UDim2.new(0, 44, 0.5, 4)
SubText.BackgroundTransparency = 1
SubText.Text = "Premium Edition"
SubText.TextColor3 = TEXT_GRAY
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 10
SubText.ZIndex = 2

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -16)
CloseBtn.BackgroundColor3 = BTN_OFF
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = TEXT_DARK
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 2
corner(CloseBtn, 10)

CloseBtn.MouseEnter:Connect(function()
	tw(CloseBtn, TI_FAST, {BackgroundColor3 = Color3.fromRGB(255, 100, 100), BackgroundTransparency = 0.2, TextColor3 = TEXT_LIGHT})
end)
CloseBtn.MouseLeave:Connect(function()
	tw(CloseBtn, TI_FAST, {BackgroundColor3 = BTN_OFF, BackgroundTransparency = 0.3, TextColor3 = TEXT_DARK})
end)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -40, 0, 42)
TabBar.Position = UDim2.new(0, 20, 0, 80)
TabBar.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
TabBar.BackgroundTransparency = 0.4
TabBar.ZIndex = 2
corner(TabBar, 14)

local TabStroke = Instance.new("UIStroke", TabBar)
TabStroke.Color = Color3.fromRGB(200, 215, 240)
TabStroke.Thickness = 1
TabStroke.Transparency = 0.5

local tl = Instance.new("UIListLayout", TabBar)
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 4)

local tp = Instance.new("UIPadding", TabBar)
tp.PaddingLeft   = UDim.new(0, 4)
tp.PaddingRight  = UDim.new(0, 4)
tp.PaddingTop    = UDim.new(0, 4)
tp.PaddingBottom = UDim.new(0, 4)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -40, 1, -140)
ContentArea.Position = UDim2.new(0, 20, 0, 135)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true
ContentArea.ZIndex = 2

local StatusBar = Instance.new("Frame", MainFrame)
StatusBar.Size = UDim2.new(1, -40, 0, 30)
StatusBar.Position = UDim2.new(0, 20, 1, -45)
StatusBar.BackgroundTransparency = 0.4
StatusBar.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
StatusBar.ZIndex = 2
corner(StatusBar, 10)

local StatusDot = Instance.new("Frame", StatusBar)
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
StatusDot.ZIndex = 3
corner(StatusDot, 4)

local StatusText = Instance.new("TextLabel", StatusBar)
StatusText.Size = UDim2.new(1, -30, 1, 0)
StatusText.Position = UDim2.new(0, 25, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Online • v2.0"
StatusText.TextColor3 = TEXT_GRAY
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 10
StatusText.ZIndex = 3

local PlayerListPanel
local FlingListPanel

local function HideAll()
	MainFrame.Visible = false
	if PlayerListPanel then PlayerListPanel.Visible = false end
	if FlingListPanel then FlingListPanel.Visible = false end
end

CloseBtn.MouseButton1Click:Connect(HideAll)

do
	local isDragging, dragStart, startPos = false
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

ToggleUIBtn.MouseEnter:Connect(function()
	tw(ToggleUIBtn, TI_FAST, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 48, 0, 48)})
end)
ToggleUIBtn.MouseLeave:Connect(function()
	tw(ToggleUIBtn, TI_FAST, {BackgroundTransparency = 0.2, Size = UDim2.new(0, 44, 0, 44)})
end)
ToggleUIBtn.MouseButton1Click:Connect(function()
	local v = not MainFrame.Visible
	MainFrame.Visible = v
	if not v then
		if PlayerListPanel then PlayerListPanel.Visible = false end
		if FlingListPanel then FlingListPanel.Visible = false end
	end
end)

local pages = {}
local tabButtons = {}
local tabOrder = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame", ContentArea)
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = ACCENT_BLUE
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 3
	local l = Instance.new("UIListLayout", page)
	l.Padding = UDim.new(0, 6)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", page)
	p.PaddingTop    = UDim.new(0, 4)
	p.PaddingBottom = UDim.new(0, 4)
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		pages[k].Visible = (k == name)
		local on = k == name
		local d = tabButtons[k]
		if on then
			tw(d.btn, TI_MED, {BackgroundColor3 = ACCENT_BLUE, BackgroundTransparency = 0.05})
			tw(d.lbl, TI_MED, {TextColor3 = TEXT_LIGHT})
		else
			tw(d.btn, TI_MED, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.7})
			tw(d.lbl, TI_MED, {TextColor3 = TEXT_DARK})
		end
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -4, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 0.7
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 3
	corner(btn, 10)
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TEXT_DARK
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.ZIndex = 4
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
	card.Size = UDim2.new(1, 0, 0, 58)
	card.BackgroundColor3 = GLASS_WHITE
	card.BackgroundTransparency = 0.25
	card.Parent = parent
	card.ZIndex = 4
	corner(card, 14)
	addGlow(card, GLASS_TINT, 0.5)

	local cardG = Instance.new("UIGradient", card)
	cardG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 245, 255))
	})
	cardG.Rotation = 90
	cardG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.35)
	})

	local iconBg = Instance.new("Frame", card)
	iconBg.Size = UDim2.new(0, 38, 0, 38)
	iconBg.Position = UDim2.new(0, 10, 0.5, -19)
	iconBg.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
	iconBg.BackgroundTransparency = 0.3
	iconBg.ZIndex = 5
	corner(iconBg, 10)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -130, 0, 16)
	lbl.Position = UDim2.new(0, 58, 0, 12)
	lbl.Text = text
	lbl.TextColor3 = TEXT_DARK
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 5

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -130, 0, 12)
	sub.Position = UDim2.new(0, 58, 0, 30)
	sub.Text = info
	sub.TextColor3 = TEXT_GRAY
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.BackgroundTransparency = 1
	sub.ZIndex = 5

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 44, 0, 24)
	track.Position = UDim2.new(1, -54, 0.5, -12)
	track.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
	track.BackgroundTransparency = 0.2
	track.ZIndex = 5
	corner(track, 12)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = GLASS_WHITE
	knob.ZIndex = 6
	corner(knob, 9)
	addGlow(knob, Color3.fromRGB(200, 210, 230), 0.3)

	local knobG = Instance.new("UIGradient", knob)
	knobG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 235, 245))
	})
	knobG.Rotation = 90

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 7

	local ON_POS  = UDim2.new(1, -21, 0.5, -9)
	local OFF_POS = UDim2.new(0, 3, 0.5, -9)
	local state = false

	btn.MouseEnter:Connect(function()
		tw(card, TI_FAST, {BackgroundTransparency = 0.1})
	end)
	btn.MouseLeave:Connect(function()
		tw(card, TI_FAST, {BackgroundTransparency = 0.25})
	end)

	btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			tw(track, TI_SPRING, {BackgroundColor3 = ACCENT_BLUE, BackgroundTransparency = 0})
			tw(knob, TI_SPRING, {Position = ON_POS})
		else
			tw(track, TI_SPRING, {BackgroundColor3 = Color3.fromRGB(220, 225, 240), BackgroundTransparency = 0.2})
			tw(knob, TI_SPRING, {Position = OFF_POS})
		end
		callback(state)
	end)
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 58)
	card.BackgroundColor3 = GLASS_WHITE
	card.BackgroundTransparency = 0.25
	card.Parent = parent
	card.ZIndex = 4
	corner(card, 14)
	addGlow(card, GLASS_TINT, 0.5)

	local cardG = Instance.new("UIGradient", card)
	cardG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 245, 255))
	})
	cardG.Rotation = 90
	cardG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.35)
	})

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -130, 0, 16)
	lbl.Position = UDim2.new(0, 18, 0, 12)
	lbl.Text = text
	lbl.TextColor3 = TEXT_DARK
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 5

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -130, 0, 12)
	sub.Position = UDim2.new(0, 18, 0, 30)
	sub.Text = labels[1]
	sub.TextColor3 = TEXT_GRAY
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.BackgroundTransparency = 1
	sub.ZIndex = 5

	local cW, cH = 90, 28
	local cf = Instance.new("Frame", card)
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 14), 0.5, -cH/2)
	cf.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
	cf.BackgroundTransparency = 0.3
	cf.ZIndex = 5
	corner(cf, 10)
	addGlow(cf, GLASS_TINT, 0.5)

	local arrowL = Instance.new("TextButton", cf)
	arrowL.Size = UDim2.new(0, 24, 0, 22)
	arrowL.Position = UDim2.new(0, 3, 0.5, -11)
	arrowL.BackgroundColor3 = GLASS_WHITE
	arrowL.BackgroundTransparency = 0.2
	arrowL.Text = "‹"
	arrowL.TextColor3 = TEXT_DARK
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 16
	arrowL.AutoButtonColor = false
	arrowL.ZIndex = 6
	corner(arrowL, 7)

	local valLabel = Instance.new("TextLabel", cf)
	valLabel.Size = UDim2.new(0, 36, 0, 22)
	valLabel.Position = UDim2.new(0.5, -18, 0.5, -11)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_BLUE
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 12
	valLabel.TextXAlignment = Enum.TextXAlignment.Center
	valLabel.ZIndex = 6

	local arrowR = Instance.new("TextButton", cf)
	arrowR.Size = UDim2.new(0, 24, 0, 22)
	arrowR.Position = UDim2.new(1, -27, 0.5, -11)
	arrowR.BackgroundColor3 = GLASS_WHITE
	arrowR.BackgroundTransparency = 0.2
	arrowR.Text = "›"
	arrowR.TextColor3 = TEXT_DARK
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 16
	arrowR.AutoButtonColor = false
	arrowR.ZIndex = 6
	corner(arrowR, 7)

	arrowL.MouseEnter:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = ACCENT_BLUE, BackgroundTransparency = 0, TextColor3 = TEXT_LIGHT}) end)
	arrowL.MouseLeave:Connect(function() tw(arrowL, TI_QUICK, {BackgroundColor3 = GLASS_WHITE, BackgroundTransparency = 0.2, TextColor3 = TEXT_DARK}) end)
	arrowR.MouseEnter:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = ACCENT_BLUE, BackgroundTransparency = 0, TextColor3 = TEXT_LIGHT}) end)
	arrowR.MouseLeave:Connect(function() tw(arrowR, TI_QUICK, {BackgroundColor3 = GLASS_WHITE, BackgroundTransparency = 0.2, TextColor3 = TEXT_DARK}) end)

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
	card.Size = UDim2.new(1, 0, 0, 58)
	card.BackgroundColor3 = GLASS_WHITE
	card.BackgroundTransparency = 0.25
	card.Parent = parent
	card.ZIndex = 4
	corner(card, 14)
	addGlow(card, GLASS_TINT, 0.5)

	local cardG = Instance.new("UIGradient", card)
	cardG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 245, 255))
	})
	cardG.Rotation = 90
	cardG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.35)
	})

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -110, 0, 16)
	lbl.Position = UDim2.new(0, 18, 0, 12)
	lbl.Text = text
	lbl.TextColor3 = TEXT_DARK
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 5

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -110, 0, 12)
	sub.Position = UDim2.new(0, 18, 0, 30)
	sub.Text = info
	sub.TextColor3 = TEXT_GRAY
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.BackgroundTransparency = 1
	sub.ZIndex = 5

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 70, 0, 28)
	pill.Position = UDim2.new(1, -84, 0.5, -14)
	pill.BackgroundColor3 = ACCENT_BLUE
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = TEXT_LIGHT
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 11
	pill.ZIndex = 6
	corner(pill, 10)

	local pillG = Instance.new("UIGradient", pill)
	pillG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 130, 230))
	})
	pillG.Rotation = 90

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 7

	btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundTransparency = 0.1}) end)
	btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundTransparency = 0.25}) end)
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

CreateAction(MiscPage, "Teleport", "To syringe", "GO", function(pill)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	if not hrp then return end
	local syringe = workspace:FindFirstChild("TempVSyringe", true)
	if not syringe then return end
	local part = syringe:FindFirstChildWhichIsA("BasePart")
	if not part then return end
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	tw(pill, TI_QUICK, {BackgroundColor3 = Color3.fromRGB(80, 220, 120)})
	task.delay(0.3, function() tw(pill, TI_FAST, {BackgroundColor3 = ACCENT_BLUE}) end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

local function MakeListPanel(name, title)
	local panel = Instance.new("Frame", MainFrame)
	panel.Size = UDim2.new(0, 220, 0, 320)
	panel.Position = UDim2.new(1, 20, 0, 60)
	panel.BackgroundColor3 = GLASS_WHITE
	panel.BackgroundTransparency = 0.15
	panel.Visible = false
	panel.ZIndex = 10
	corner(panel, 20)
	addGlow(panel, GLASS_TINT, 0.3)

	local panelG = Instance.new("UIGradient", panel)
	panelG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 240, 250))
	})
	panelG.Rotation = 135
	panelG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0.25)
	})

	local pTitle = Instance.new("TextLabel", panel)
	pTitle.Size = UDim2.new(1, -50, 0, 36)
	pTitle.Position = UDim2.new(0, 16, 0, 8)
	pTitle.Text = title
	pTitle.TextColor3 = TEXT_DARK
	pTitle.TextXAlignment = Enum.TextXAlignment.Left
	pTitle.Font = Enum.Font.GothamBold
	pTitle.TextSize = 14
	pTitle.BackgroundTransparency = 1
	pTitle.ZIndex = 11

	local pClose = Instance.new("TextButton", panel)
	pClose.Size = UDim2.new(0, 28, 0, 28)
	pClose.Position = UDim2.new(1, -36, 0, 12)
	pClose.BackgroundColor3 = Color3.fromRGB(245, 248, 255)
	pClose.BackgroundTransparency = 0.3
	pClose.Text = "✕"
	pClose.TextColor3 = TEXT_DARK
	pClose.Font = Enum.Font.GothamBold
	pClose.TextSize = 12
	pClose.AutoButtonColor = false
	pClose.ZIndex = 11
	corner(pClose, 8)

	pClose.MouseEnter:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = Color3.fromRGB(255, 100, 100), BackgroundTransparency = 0.1, TextColor3 = TEXT_LIGHT}) end)
	pClose.MouseLeave:Connect(function() tw(pClose, TI_FAST, {BackgroundColor3 = Color3.fromRGB(245, 248, 255), BackgroundTransparency = 0.3, TextColor3 = TEXT_DARK}) end)
	pClose.MouseButton1Click:Connect(function() panel.Visible = false end)

	return panel, pClose
end

PlayerListPanel = MakeListPanel("Players", "Players")
FlingListPanel = MakeListPanel("Fling", "Fling Target")

local function MakeScroll(parent)
	local scroll = Instance.new("ScrollingFrame", parent)
	scroll.Size = UDim2.new(1, -16, 1, -56)
	scroll.Position = UDim2.new(0, 8, 0, 50)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = ACCENT_BLUE
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 11
	local l = Instance.new("UIListLayout", scroll)
	l.Padding = UDim.new(0, 4)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	return scroll
end

local plScroll = MakeScroll(PlayerListPanel)
local flScroll = MakeScroll(FlingListPanel)

local avatarCache   = {}
local avatarPending = {}

local function FetchAvatar(player, onDone)
	local uid = player.UserId
	if avatarCache[uid] then
		if onDone then onDone(avatarCache[uid]) end
		return
	end
	if onDone then
		avatarPending[uid] = avatarPending[uid] or {}
		avatarPending[uid][#avatarPending[uid] + 1] = onDone
	end
	if avatarPending[uid] and #avatarPending[uid] > (onDone and 1 or 0) then return end
	task.spawn(function()
		local ok, url = pcall(Players.GetUserThumbnailAsync, Players, uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		if ok and url and url ~= "" then
			avatarCache[uid] = url
			local cbs = avatarPending[uid]
			avatarPending[uid] = nil
			if cbs then
				for i = 1, #cbs do cbs[i](url) end
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

local function MakeRow(player, scroll, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 44)
	row.BackgroundColor3 = GLASS_WHITE
	row.BackgroundTransparency = 0.3
	row.Parent = scroll
	row.ZIndex = 12
	corner(row, 10)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 32, 0, 32)
	av.Position = UDim2.new(0, 6, 0.5, -16)
	av.BackgroundColor3 = Color3.fromRGB(240, 245, 255)
	av.Image = avatarCache[player.UserId] or ""
	av.ZIndex = 13
	corner(av, 16)
	addGlow(av, GLASS_TINT, 0.4)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -48, 1, 0)
	nameLbl.Position = UDim2.new(0, 44, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(30,30,40)'><b>%s</b></font>\n<font color='rgb(150,155,170)' size='9'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 11
	nameLbl.ZIndex = 13

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 14

	btn.MouseEnter:Connect(function() tw(row, TI_QUICK, {BackgroundTransparency = 0.1}) end)
	btn.MouseLeave:Connect(function() tw(row, TI_QUICK, {BackgroundTransparency = 0.3}) end)
	btn.MouseButton1Click:Connect(function()
		callback(player)
		tw(row, TI_QUICK, {BackgroundColor3 = ACCENT_BLUE, BackgroundTransparency = 0.3})
		task.delay(0.3, function() tw(row, TI_FAST, {BackgroundColor3 = GLASS_WHITE, BackgroundTransparency = 0.3}) end)
	end)
end

RefreshPlayerList = function()
	for _, child in ipairs(plScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local list = Players:GetPlayers()
	for i = 1, #list do
		if list[i] ~= LocalPlayer then
			MakeRow(list[i], plScroll, function(player)
				TeleportToPlayer(player)
			end)
		end
	end
end

RefreshFlingList = function()
	for _, child in ipairs(flScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local list = Players:GetPlayers()
	for i = 1, #list do
		if list[i] ~= LocalPlayer then
			MakeRow(list[i], flScroll, function(player)
				FlingTarget = player
				FlingEnabled = true
				if FlingPill then
					FlingPill.Text = "STOP"
				end
				if FlingListPanel then
					FlingListPanel.Visible = false
				end
			end)
		end
	end
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
		local txt = Instance.new("TextLabel", bb)
		txt.Size                   = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text                   = player.Name
		txt.TextColor3             = Color3.fromRGB(255, 255, 255)
		txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 10
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
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				part.Velocity = vel * 180000 + Vector3.new(0, 180000, 0)
			end
		end
		RunService.RenderStepped:Wait()
		if char and char.Parent then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.Velocity = vel
				end
			end
		end
		RunService.Stepped:Wait()
		if char and char.Parent and hrp and hrp.Parent then
			hrp.Velocity = vel + Vector3.new(0, movel, 0)
			movel = movel * -1
			hrp.CFrame = thrp.CFrame
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