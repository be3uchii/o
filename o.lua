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

local TI_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUICK = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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

local function mkStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0
end

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 26, 0, 26)
ToggleUIBtn.Position = UDim2.new(0, 10, 0.5, -13)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = TXT_PRIMARY
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 12
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
corner(ToggleUIBtn, 7)
mkStroke(ToggleUIBtn, STROKE_SOFT, 1, 0.2)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 222)
Frame.Position = UDim2.new(0.5, -100, 0.5, -111)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = false
Frame.Active = true
corner(Frame, 12)
mkStroke(Frame, STROKE_SOFT, 1, 0.1)

local fg = Instance.new("UIGradient", Frame)
fg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
fg.Rotation = 90

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundTransparency = 1

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 5, 0, 5)
LogoDot.Position = UDim2.new(0, 10, 0.5, -2)
LogoDot.BackgroundColor3 = ACCENT_ON
corner(LogoDot, 3)
local dg = Instance.new("UIStroke", LogoDot)
dg.Color = ACCENT_ON
dg.Thickness = 2
dg.Transparency = 0.6

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 21, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 18, 0, 18)
CloseBtn.Position = UDim2.new(1, -24, 0.5, -9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 9
CloseBtn.AutoButtonColor = false
corner(CloseBtn, 5)

local C_RED = Color3.fromRGB(200, 60, 60)
local C_WHT = Color3.fromRGB(255, 255, 255)
local C_BTN = Color3.fromRGB(38, 38, 46)

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

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -16, 0, 22)
TabBar.Position = UDim2.new(0, 8, 0, 32)
TabBar.BackgroundColor3 = BG_PANEL
corner(TabBar, 7)

local tl = Instance.new("UIListLayout", TabBar)
tl.FillDirection = Enum.FillDirection.Horizontal
tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
tl.VerticalAlignment = Enum.VerticalAlignment.Center
tl.Padding = UDim.new(0, 2)

local tp = Instance.new("UIPadding", TabBar)
tp.PaddingLeft   = UDim.new(0, 2)
tp.PaddingRight  = UDim.new(0, 2)
tp.PaddingTop    = UDim.new(0, 2)
tp.PaddingBottom = UDim.new(0, 2)

do
	local isDragging, dragStart, startPos = false
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			dragStart = input.Position
			startPos = Frame.Position
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
	local page = Instance.new("ScrollingFrame", Frame)
	page.Size = UDim2.new(1, -12, 1, -60)
	page.Position = UDim2.new(0, 6, 0, 58)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = STROKE_SOFT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	local l = Instance.new("UIListLayout", page)
	l.Padding = UDim.new(0, 4)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", page)
	p.PaddingTop    = UDim.new(0, 2)
	p.PaddingBottom = UDim.new(0, 3)
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		pages[k].Visible = (k == name)
		local on = k == name
		local d = tabButtons[k]
		tw(d.btn, TI_MED, {BackgroundColor3 = on and TXT_PRIMARY or BG_PANEL})
		tw(d.lbl, TI_MED, {TextColor3 = on and BG_MAIN or TXT_DIM})
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -2, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	corner(btn, 5)
	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 9
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
	card.Size = UDim2.new(1, 0, 0, 36)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 7)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -52, 0, 12)
	lbl.Position = UDim2.new(0, 8, 0, 6)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 9
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -52, 0, 10)
	sub.Position = UDim2.new(0, 8, 0, 19)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 7
	sub.BackgroundTransparency = 1

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 28, 0, 15)
	track.Position = UDim2.new(1, -36, 0.5, -7)
	track.BackgroundColor3 = TOGGLE_OFF
	corner(track, 8)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 10, 0, 10)
	knob.Position = UDim2.new(0, 2, 0.5, -5)
	knob.BackgroundColor3 = TXT_PRIMARY
	corner(knob, 5)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

	local ON_POS  = UDim2.new(1, -12, 0.5, -5)
	local OFF_POS = UDim2.new(0, 2, 0.5, -5)
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
	card.Size = UDim2.new(1, 0, 0, 36)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 7)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -96, 0, 12)
	lbl.Position = UDim2.new(0, 8, 0, 6)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 9
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -96, 0, 10)
	sub.Position = UDim2.new(0, 8, 0, 19)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 7
	sub.BackgroundTransparency = 1

	local cW, cH = 80, 17
	local cf = Instance.new("Frame", card)
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 5), 0.5, -(cH / 2))
	cf.BackgroundTransparency = 1

	local arrowL = Instance.new("TextButton", cf)
	arrowL.Size = UDim2.new(0, cH, 1, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.Text = "<"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 9
	arrowL.AutoButtonColor = false
	corner(arrowL, 5)

	local valLabel = Instance.new("TextLabel", cf)
	valLabel.Size = UDim2.new(1, -(cH * 2 + 4), 1, 0)
	valLabel.Position = UDim2.new(0, cH + 2, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 9
	valLabel.TextXAlignment = Enum.TextXAlignment.Center

	local arrowR = Instance.new("TextButton", cf)
	arrowR.Size = UDim2.new(0, cH, 1, 0)
	arrowR.Position = UDim2.new(1, -cH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.Text = ">"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 9
	arrowR.AutoButtonColor = false
	corner(arrowR, 5)

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
	card.Size = UDim2.new(1, 0, 0, 36)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 7)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -60, 0, 12)
	lbl.Position = UDim2.new(0, 8, 0, 6)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 9
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -60, 0, 10)
	sub.Position = UDim2.new(0, 8, 0, 19)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 7
	sub.BackgroundTransparency = 1

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 40, 0, 17)
	pill.Position = UDim2.new(1, -46, 0.5, -8)
	pill.BackgroundColor3 = TXT_PRIMARY
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 8
	corner(pill, 8)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

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

CreateAction(MiscPage, "Teleport to Player", "Pick from list", "OPEN", function()
	if PlayerListPanel then
		local v = not PlayerListPanel.Visible
		PlayerListPanel.Visible = v
		if FlingListPanel then FlingListPanel.Visible = false end
		if v then RefreshPlayerList() end
	end
end)

CreateAction(MiscPage, "Fling Player", "Select target", "OPEN", function()
	if FlingListPanel then
		local v = not FlingListPanel.Visible
		FlingListPanel.Visible = v
		if PlayerListPanel then PlayerListPanel.Visible = false end
		if v then RefreshFlingList() end
	end
end)

CreateAction(MiscPage, "Stop Fling", "Disable fling", "OFF", function(pill)
	FlingEnabled = false
	FlingTarget = nil
	tw(pill, TI_QUICK, {BackgroundColor3 = C_RED})
	task.delay(0.3, function() tw(pill, TI_FAST, {BackgroundColor3 = TXT_PRIMARY}) end)
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
	tw(pill, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
	task.delay(0.3, function() tw(pill, TI_FAST, {BackgroundColor3 = TXT_PRIMARY}) end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

PlayerListPanel = Instance.new("Frame", Frame)
PlayerListPanel.Size = UDim2.new(0, 185, 0, 195)
PlayerListPanel.Position = UDim2.new(1, 6, 0, 0)
PlayerListPanel.BackgroundColor3 = BG_MAIN
PlayerListPanel.Visible = false
corner(PlayerListPanel, 12)
mkStroke(PlayerListPanel, STROKE_SOFT, 1, 0.1)

local plpfg = Instance.new("UIGradient", PlayerListPanel)
plpfg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
plpfg.Rotation = 90

local plTitle = Instance.new("TextLabel", PlayerListPanel)
plTitle.Size = UDim2.new(1, -36, 0, 26)
plTitle.Position = UDim2.new(0, 8, 0, 0)
plTitle.Text = "Players"
plTitle.TextColor3 = TXT_PRIMARY
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.Font = Enum.Font.GothamBold
plTitle.TextSize = 10
plTitle.BackgroundTransparency = 1

local plClose = Instance.new("TextButton", PlayerListPanel)
plClose.Size = UDim2.new(0, 16, 0, 16)
plClose.Position = UDim2.new(1, -22, 0, 5)
plClose.BackgroundColor3 = C_BTN
plClose.Text = "X"
plClose.TextColor3 = TXT_DIM
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 8
plClose.AutoButtonColor = false
corner(plClose, 4)
plClose.MouseEnter:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end)
plClose.MouseLeave:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end)
plClose.MouseButton1Click:Connect(function() PlayerListPanel.Visible = false end)

local plScroll = Instance.new("ScrollingFrame", PlayerListPanel)
plScroll.Size = UDim2.new(1, -8, 1, -30)
plScroll.Position = UDim2.new(0, 4, 0, 28)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 2
plScroll.ScrollBarImageColor3 = STROKE_SOFT
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local pll = Instance.new("UIListLayout", plScroll)
pll.Padding = UDim.new(0, 3)
pll.HorizontalAlignment = Enum.HorizontalAlignment.Center

FlingListPanel = Instance.new("Frame", Frame)
FlingListPanel.Size = UDim2.new(0, 185, 0, 195)
FlingListPanel.Position = UDim2.new(1, 6, 0, 0)
FlingListPanel.BackgroundColor3 = BG_MAIN
FlingListPanel.Visible = false
corner(FlingListPanel, 12)
mkStroke(FlingListPanel, STROKE_SOFT, 1, 0.1)

local flpfg = Instance.new("UIGradient", FlingListPanel)
flpfg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
flpfg.Rotation = 90

local flTitle = Instance.new("TextLabel", FlingListPanel)
flTitle.Size = UDim2.new(1, -36, 0, 26)
flTitle.Position = UDim2.new(0, 8, 0, 0)
flTitle.Text = "Fling Target"
flTitle.TextColor3 = TXT_PRIMARY
flTitle.TextXAlignment = Enum.TextXAlignment.Left
flTitle.Font = Enum.Font.GothamBold
flTitle.TextSize = 10
flTitle.BackgroundTransparency = 1

local flClose = Instance.new("TextButton", FlingListPanel)
flClose.Size = UDim2.new(0, 16, 0, 16)
flClose.Position = UDim2.new(1, -22, 0, 5)
flClose.BackgroundColor3 = C_BTN
flClose.Text = "X"
flClose.TextColor3 = TXT_DIM
flClose.Font = Enum.Font.GothamBold
flClose.TextSize = 8
flClose.AutoButtonColor = false
corner(flClose, 4)
flClose.MouseEnter:Connect(function() tw(flClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end)
flClose.MouseLeave:Connect(function() tw(flClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end)
flClose.MouseButton1Click:Connect(function() FlingListPanel.Visible = false end)

local flScroll = Instance.new("ScrollingFrame", FlingListPanel)
flScroll.Size = UDim2.new(1, -8, 1, -30)
flScroll.Position = UDim2.new(0, 4, 0, 28)
flScroll.BackgroundTransparency = 1
flScroll.BorderSizePixel = 0
flScroll.ScrollBarThickness = 2
flScroll.ScrollBarImageColor3 = STROKE_SOFT
flScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
flScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local fll = Instance.new("UIListLayout", flScroll)
fll.Padding = UDim.new(0, 3)
fll.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

local function MakePlayerRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_CARD
	row.Parent = plScroll
	corner(row, 6)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 20, 0, 20)
	av.Position = UDim2.new(0, 5, 0.5, -10)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	corner(av, 10)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -32, 1, 0)
	nameLbl.Position = UDim2.new(0, 30, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(245,245,248)'><b>%s</b></font>\n<font color='rgb(100,100,112)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 9

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.MouseEnter:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function()
		TeleportToPlayer(player)
		tw(row, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
		task.delay(0.25, function() tw(row, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	end)
end

local function MakeFlingRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = BG_CARD
	row.Parent = flScroll
	corner(row, 6)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 20, 0, 20)
	av.Position = UDim2.new(0, 5, 0.5, -10)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	corner(av, 10)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -32, 1, 0)
	nameLbl.Position = UDim2.new(0, 30, 0, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.RichText = true
	nameLbl.Text = string.format(
		"<font color='rgb(245,245,248)'><b>%s</b></font>\n<font color='rgb(100,100,112)'>%s</font>",
		player.DisplayName, player.Name
	)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Font = Enum.Font.GothamSemibold
	nameLbl.TextSize = 9

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.MouseEnter:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD_HOV}) end)
	btn.MouseLeave:Connect(function() tw(row, TI_QUICK, {BackgroundColor3 = BG_CARD}) end)
	btn.MouseButton1Click:Connect(function()
		FlingTarget = player
		FlingEnabled = true
		tw(row, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
		task.delay(0.25, function() tw(row, TI_FAST, {BackgroundColor3 = BG_CARD}) end)
	end)
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

RefreshFlingList = function()
	for _, child in ipairs(flScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local list = Players:GetPlayers()
	for i = 1, #list do
		if list[i] ~= LocalPlayer then MakeFlingRow(list[i]) end
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