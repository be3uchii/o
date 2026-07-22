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
local FlingEnabled = false
local FlingTarget = nil
local HitboxMode = 0
local HitboxSizes = {0, 15, 30, 70}
local FOV_RADIUS = 110
local MaxTargetDistance = 600

local AIM_SMOOTHNESS = 0.32
local AIM_SWITCH_THRESHOLD = 0.65
local AIM_PREDICTION = 0.08
local AIM_POS_SMOOTH = 0.45
local AIM_MAX_MISS_FRAMES = 8

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
local C_RED       = Color3.fromRGB(200, 60, 60)
local C_WHT       = Color3.fromRGB(255, 255, 255)
local C_BTN       = Color3.fromRGB(38, 38, 46)

local TI_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_QUICK = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local UI_Target
do
	local coreOk, coreGui = pcall(function() return game:GetService("CoreGui") end)
	if coreOk and coreGui then
		local nameOk = pcall(function() return coreGui.Name end)
		if nameOk then
			UI_Target = coreGui
		end
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

local ToggleUIBtn = Instance.new("TextButton", ScreenGui)
ToggleUIBtn.Size = UDim2.new(0, 34, 0, 34)
ToggleUIBtn.Position = UDim2.new(0, 10, 0.5, -17)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = TXT_PRIMARY
ToggleUIBtn.Text = "Z"
ToggleUIBtn.TextSize = 14
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
ToggleUIBtn.ZIndex = 10
corner(ToggleUIBtn, 9)
mkStroke(ToggleUIBtn, STROKE_SOFT, 1, 0.2)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 270, 0, 310)
Frame.Position = UDim2.new(0.5, -135, 0.5, -155)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = true
Frame.Active = true
Frame.ZIndex = 5
corner(Frame, 14)
mkStroke(Frame, STROKE_SOFT, 1, 0.1)

local fg = Instance.new("UIGradient", Frame)
fg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
fg.Rotation = 90

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 6

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 6, 0, 6)
LogoDot.Position = UDim2.new(0, 12, 0.5, -3)
LogoDot.BackgroundColor3 = ACCENT_ON
LogoDot.ZIndex = 7
corner(LogoDot, 3)
local dg = Instance.new("UIStroke", LogoDot)
dg.Color = ACCENT_ON
dg.Thickness = 2
dg.Transparency = 0.6

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 26, 0, 0)
Title.Text = "Zeta"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.BackgroundTransparency = 1
Title.ZIndex = 7

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = C_BTN
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 7
corner(CloseBtn, 6)

local PlayerListPanel
local FlingListPanel

local function HideAll()
	Frame.Visible = false
	if PlayerListPanel then PlayerListPanel.Visible = false end
	if FlingListPanel then FlingListPanel.Visible = false end
end

track(CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end))
track(CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end))
track(CloseBtn.MouseButton1Click:Connect(HideAll))

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -20, 0, 28)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = BG_PANEL
TabBar.ZIndex = 6
corner(TabBar, 8)

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

do
	local isDragging = false
	local dragStart = nil
	local startPos = nil

	local function onInputBegan(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			isDragging = true
			dragStart = input.Position
			startPos = Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					isDragging = false
				end
			end)
		end
	end

	local function onInputChanged(input)
		local t = input.UserInputType
		if isDragging and (t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch) then
			if dragStart and startPos then
				local d = input.Position - dragStart
				Frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + d.X,
					startPos.Y.Scale,
					startPos.Y.Offset + d.Y
				)
			end
		end
	end

	local function onInputEnded(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			isDragging = false
		end
	end

	track(TopBar.InputBegan:Connect(onInputBegan))
	track(UserInputService.InputChanged:Connect(onInputChanged))
	track(UserInputService.InputEnded:Connect(onInputEnded))
end

track(ToggleUIBtn.MouseEnter:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_CARD}) end))
track(ToggleUIBtn.MouseLeave:Connect(function() tw(ToggleUIBtn, TI_FAST, {BackgroundColor3 = BG_MAIN}) end))
track(ToggleUIBtn.MouseButton1Click:Connect(function()
	local v = not Frame.Visible
	Frame.Visible = v
	if not v then
		if PlayerListPanel then PlayerListPanel.Visible = false end
		if FlingListPanel then FlingListPanel.Visible = false end
	end
end))

local pages = {}
local tabButtons = {}
local tabOrder = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame", Frame)
	page.Size = UDim2.new(1, -16, 1, -76)
	page.Position = UDim2.new(0, 8, 0, 74)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = STROKE_SOFT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.ZIndex = 6
	local l = Instance.new("UIListLayout", page)
	l.Padding = UDim.new(0, 5)
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local p = Instance.new("UIPadding", page)
	p.PaddingTop    = UDim.new(0, 3)
	p.PaddingBottom = UDim.new(0, 4)
	return page
end

local function ShowPage(name)
	for i = 1, #tabOrder do
		local k = tabOrder[i]
		pages[k].Visible = (k == name)
		local on = (k == name)
		local d = tabButtons[k]
		tw(d.btn, TI_MED, {BackgroundColor3 = on and TXT_PRIMARY or BG_PANEL})
		tw(d.lbl, TI_MED, {TextColor3 = on and BG_MAIN or TXT_DIM})
	end
end

local function CreateTab(name)
	local btn = Instance.new("TextButton", TabBar)
	btn.Size = UDim2.new(0.333, -3, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 7
	corner(btn, 6)
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
	card.Size = UDim2.new(1, 0, 0, 46)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -60, 0, 14)
	lbl.Position = UDim2.new(0, 10, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -60, 0, 12)
	sub.Position = UDim2.new(0, 10, 0, 24)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local track_frame = Instance.new("Frame", card)
	track_frame.Size = UDim2.new(0, 34, 0, 18)
	track_frame.Position = UDim2.new(1, -44, 0.5, -9)
	track_frame.BackgroundColor3 = TOGGLE_OFF
	track_frame.ZIndex = 8
	corner(track_frame, 9)

	local knob = Instance.new("Frame", track_frame)
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.Position = UDim2.new(0, 3, 0.5, -6)
	knob.BackgroundColor3 = TXT_PRIMARY
	knob.ZIndex = 9
	corner(knob, 6)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 10

	local ON_POS  = UDim2.new(1, -15, 0.5, -6)
	local OFF_POS = UDim2.new(0, 3, 0.5, -6)
	local state = false

	track(btn.MouseEnter:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD_HOV}) end))
	track(btn.MouseLeave:Connect(function() tw(card, TI_FAST, {BackgroundColor3 = BG_CARD}) end))
	track(btn.MouseButton1Click:Connect(function()
		state = not state
		if state then
			tw(track_frame, TI_MED, {BackgroundColor3 = ACCENT_ON})
			tw(knob, TI_MED, {Position = ON_POS})
		else
			tw(track_frame, TI_MED, {BackgroundColor3 = TOGGLE_OFF})
			tw(knob, TI_MED, {Position = OFF_POS})
		end
		pcall(callback, state)
	end))
end

local function CreateStepper(parent, text, values, labels, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 46)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -110, 0, 14)
	lbl.Position = UDim2.new(0, 10, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -110, 0, 12)
	sub.Position = UDim2.new(0, 10, 0, 24)
	sub.Text = labels[1]
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local cW, cH = 96, 22
	local cf = Instance.new("Frame", card)
	cf.Size = UDim2.new(0, cW, 0, cH)
	cf.Position = UDim2.new(1, -(cW + 6), 0.5, -(cH / 2))
	cf.BackgroundTransparency = 1
	cf.ZIndex = 8

	local arrowL = Instance.new("TextButton", cf)
	arrowL.Size = UDim2.new(0, cH, 1, 0)
	arrowL.BackgroundColor3 = BG_PANEL
	arrowL.Text = "<"
	arrowL.TextColor3 = TXT_PRIMARY
	arrowL.Font = Enum.Font.GothamBold
	arrowL.TextSize = 11
	arrowL.AutoButtonColor = false
	arrowL.ZIndex = 9
	corner(arrowL, 6)

	local valLabel = Instance.new("TextLabel", cf)
	valLabel.Size = UDim2.new(1, -(cH * 2 + 6), 1, 0)
	valLabel.Position = UDim2.new(0, cH + 3, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = labels[1]
	valLabel.TextColor3 = ACCENT_ON
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 11
	valLabel.TextXAlignment = Enum.TextXAlignment.Center
	valLabel.ZIndex = 9

	local arrowR = Instance.new("TextButton", cf)
	arrowR.Size = UDim2.new(0, cH, 1, 0)
	arrowR.Position = UDim2.new(1, -cH, 0, 0)
	arrowR.BackgroundColor3 = BG_PANEL
	arrowR.Text = ">"
	arrowR.TextColor3 = TXT_PRIMARY
	arrowR.Font = Enum.Font.GothamBold
	arrowR.TextSize = 11
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
	card.Size = UDim2.new(1, 0, 0, 46)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	card.ZIndex = 7
	corner(card, 8)
	mkStroke(card, STROKE_SOFT, 1, 0.5)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -70, 0, 14)
	lbl.Position = UDim2.new(0, 10, 0, 8)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.BackgroundTransparency = 1
	lbl.ZIndex = 8

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -70, 0, 12)
	sub.Position = UDim2.new(0, 10, 0, 24)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.BackgroundTransparency = 1
	sub.ZIndex = 8

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 52, 0, 22)
	pill.Position = UDim2.new(1, -58, 0.5, -11)
	pill.BackgroundColor3 = TXT_PRIMARY
	pill.Text = btnText or "OPEN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9
	pill.ZIndex = 8
	corner(pill, 9)

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

local _, flingPillRef = CreateAction(MiscPage, "Fling Player", "Select target", "OPEN", function(pill)
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
	tw(pill, TI_QUICK, {BackgroundColor3 = ACCENT_ON})
	task.delay(0.3, function() tw(pill, TI_FAST, {BackgroundColor3 = TXT_PRIMARY}) end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on) NoclipEnabled = on end)

PlayerListPanel = Instance.new("Frame", Frame)
PlayerListPanel.Size = UDim2.new(0, 220, 0, 240)
PlayerListPanel.Position = UDim2.new(1, 8, 0, 0)
PlayerListPanel.BackgroundColor3 = BG_MAIN
PlayerListPanel.Visible = false
PlayerListPanel.ZIndex = 6
corner(PlayerListPanel, 14)
mkStroke(PlayerListPanel, STROKE_SOFT, 1, 0.1)

local plpfg = Instance.new("UIGradient", PlayerListPanel)
plpfg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
plpfg.Rotation = 90

local plTitle = Instance.new("TextLabel", PlayerListPanel)
plTitle.Size = UDim2.new(1, -40, 0, 32)
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
plClose.Position = UDim2.new(1, -26, 0, 6)
plClose.BackgroundColor3 = C_BTN
plClose.Text = "X"
plClose.TextColor3 = TXT_DIM
plClose.Font = Enum.Font.GothamBold
plClose.TextSize = 9
plClose.AutoButtonColor = false
plClose.ZIndex = 7
corner(plClose, 5)
track(plClose.MouseEnter:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end))
track(plClose.MouseLeave:Connect(function() tw(plClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end))
track(plClose.MouseButton1Click:Connect(function() PlayerListPanel.Visible = false end))

local plScroll = Instance.new("ScrollingFrame", PlayerListPanel)
plScroll.Size = UDim2.new(1, -10, 1, -36)
plScroll.Position = UDim2.new(0, 5, 0, 34)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 3
plScroll.ScrollBarImageColor3 = STROKE_SOFT
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
plScroll.ZIndex = 7
local pll = Instance.new("UIListLayout", plScroll)
pll.Padding = UDim.new(0, 4)
pll.HorizontalAlignment = Enum.HorizontalAlignment.Center

FlingListPanel = Instance.new("Frame", Frame)
FlingListPanel.Size = UDim2.new(0, 220, 0, 240)
FlingListPanel.Position = UDim2.new(1, 8, 0, 0)
FlingListPanel.BackgroundColor3 = BG_MAIN
FlingListPanel.Visible = false
FlingListPanel.ZIndex = 6
corner(FlingListPanel, 14)
mkStroke(FlingListPanel, STROKE_SOFT, 1, 0.1)

local flpfg = Instance.new("UIGradient", FlingListPanel)
flpfg.Color = ColorSequence.new(Color3.fromRGB(20, 20, 26), Color3.fromRGB(11, 11, 14))
flpfg.Rotation = 90

local flTitle = Instance.new("TextLabel", FlingListPanel)
flTitle.Size = UDim2.new(1, -40, 0, 32)
flTitle.Position = UDim2.new(0, 10, 0, 0)
flTitle.Text = "Fling Target"
flTitle.TextColor3 = TXT_PRIMARY
flTitle.TextXAlignment = Enum.TextXAlignment.Left
flTitle.Font = Enum.Font.GothamBold
flTitle.TextSize = 12
flTitle.BackgroundTransparency = 1
flTitle.ZIndex = 7

local flClose = Instance.new("TextButton", FlingListPanel)
flClose.Size = UDim2.new(0, 20, 0, 20)
flClose.Position = UDim2.new(1, -26, 0, 6)
flClose.BackgroundColor3 = C_BTN
flClose.Text = "X"
flClose.TextColor3 = TXT_DIM
flClose.Font = Enum.Font.GothamBold
flClose.TextSize = 9
flClose.AutoButtonColor = false
flClose.ZIndex = 7
corner(flClose, 5)
track(flClose.MouseEnter:Connect(function() tw(flClose, TI_FAST, {BackgroundColor3 = C_RED, TextColor3 = C_WHT}) end))
track(flClose.MouseLeave:Connect(function() tw(flClose, TI_FAST, {BackgroundColor3 = C_BTN, TextColor3 = TXT_DIM}) end))
track(flClose.MouseButton1Click:Connect(function() FlingListPanel.Visible = false end))

local flScroll = Instance.new("ScrollingFrame", FlingListPanel)
flScroll.Size = UDim2.new(1, -10, 1, -36)
flScroll.Position = UDim2.new(0, 5, 0, 34)
flScroll.BackgroundTransparency = 1
flScroll.BorderSizePixel = 0
flScroll.ScrollBarThickness = 3
flScroll.ScrollBarImageColor3 = STROKE_SOFT
flScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
flScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
flScroll.ZIndex = 7
local fll = Instance.new("UIListLayout", flScroll)
fll.Padding = UDim.new(0, 4)
fll.HorizontalAlignment = Enum.HorizontalAlignment.Center

local avatarCache   = {}
local avatarPending = {}

local function FetchAvatar(player, onDone)
	local uid = player.UserId
	if avatarCache[uid] then
		if onDone then
			task.spawn(onDone, avatarCache[uid])
		end
		return
	end
	if onDone then
		if not avatarPending[uid] then
			avatarPending[uid] = {}
		end
		avatarPending[uid][#avatarPending[uid] + 1] = onDone
	end
	if avatarPending[uid] and #avatarPending[uid] > 1 then return end
	if not onDone then
		avatarPending[uid] = avatarPending[uid] or {}
	end
	task.spawn(function()
		local ok, url = pcall(Players.GetUserThumbnailAsync, Players, uid,
			Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		if ok and url and url ~= "" then
			avatarCache[uid] = url
			local cbs = avatarPending[uid]
			avatarPending[uid] = nil
			if cbs then
				for i = 1, #cbs do
					task.spawn(cbs[i], url)
				end
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
	row.Size = UDim2.new(1, 0, 0, 38)
	row.BackgroundColor3 = BG_CARD
	row.Parent = plScroll
	row.ZIndex = 8
	corner(row, 7)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 26, 0, 26)
	av.Position = UDim2.new(0, 6, 0.5, -13)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	av.ZIndex = 9
	corner(av, 13)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av and av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -40, 1, 0)
	nameLbl.Position = UDim2.new(0, 38, 0, 0)
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

local function MakeFlingRow(player)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 38)
	row.BackgroundColor3 = BG_CARD
	row.Parent = flScroll
	row.ZIndex = 8
	corner(row, 7)

	local av = Instance.new("ImageLabel", row)
	av.Size = UDim2.new(0, 26, 0, 26)
	av.Position = UDim2.new(0, 6, 0.5, -13)
	av.BackgroundColor3 = BG_PANEL
	av.Image = avatarCache[player.UserId] or ""
	av.ZIndex = 9
	corner(av, 13)

	if av.Image == "" then
		FetchAvatar(player, function(url)
			if av and av.Parent then av.Image = url end
		end)
	end

	local nameLbl = Instance.new("TextLabel", row)
	nameLbl.Size = UDim2.new(1, -40, 1, 0)
	nameLbl.Position = UDim2.new(0, 38, 0, 0)
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
		FlingTarget = player
		FlingEnabled = true
		if FlingPill then FlingPill.Text = "STOP" end
		if FlingListPanel then FlingListPanel.Visible = false end
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
		d = {
			origSize = nil,
			origTrans = nil,
			origCollide = nil,
			hitboxActive = false,
			billboard = nil,
			highlight = nil,
			charConn = nil,
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
	if data.origSize and hrp and hrp.Parent then
		pcall(function()
			hrp.Size        = data.origSize
			hrp.Transparency = data.origTrans
			hrp.CanCollide  = data.origCollide
		end)
		data.origSize    = nil
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
	if not d.origSize then
		d.origSize    = hrp.Size
		d.origTrans   = hrp.Transparency
		d.origCollide = hrp.CanCollide
	end
	pcall(function()
		hrp.Size         = Vector3.new(size, size, size)
		hrp.Transparency = 0.75
		hrp.CanCollide   = false
	end)
	d.hitboxActive = true
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
		nd.origSize = nil
		nd.hitboxActive = false
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
	for i = #rayFilterCache, n + 1, -1 do
		rayFilterCache[i] = nil
	end
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
			pcall(function() part.CanCollide = false end)
		end
	end
end

local cachedPlayers = Players:GetPlayers()

for _, p in ipairs(cachedPlayers) do
	SetupPlayer(p)
end

track(LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	UpdateNoclipCache()
	for player, data in pairs(playerData) do
		if data then
			HardRemoveESP(player)
			data.origSize = nil
			data.hitboxActive = false
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

local movel = 0.3

track(RunService.Heartbeat:Connect(function()
	if not (FlingEnabled and FlingTarget) then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local tchar = FlingTarget.Character
	if not tchar then return end
	local thrp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Torso")
	if not thrp then return end
	pcall(function()
		local vel = hrp.AssemblyLinearVelocity
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				part.AssemblyLinearVelocity = vel * 180000 + Vector3.new(0, 180000, 0)
			end
		end
	end)
	RunService.RenderStepped:Wait()
	pcall(function()
		if char and char.Parent then
			local vel = hrp.AssemblyLinearVelocity
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.AssemblyLinearVelocity = vel
				end
			end
		end
	end)
	RunService.Stepped:Wait()
	pcall(function()
		if char and char.Parent and hrp and hrp.Parent then
			hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(0, movel, 0)
			movel = movel * -1
			hrp.CFrame = thrp.CFrame
		end
	end)
end))

local CurrentAimTarget = nil
local CurrentAimMiss = 0
local SmoothedAimPos = nil

track(RunService.RenderStepped:Connect(function(dt)
	local vp     = Camera.ViewportSize
	local cx     = vp.X * 0.5
	local cy     = vp.Y * 0.5
	local camCF  = Camera.CFrame
	local camPos = camCF.Position
	local localChar = LocalPlayer.Character

	local candidates = nil
	local bestPlayer, bestDist2 = nil, math.huge

	if AimbotEnabled then
		candidates = {}
	end

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
			local aimPart = char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or hrp
			local rawPos = aimPart.Position
			local vel = hrp.AssemblyLinearVelocity
			local predictedPos = rawPos + vel * AIM_PREDICTION

			local sp, onScreen = Camera:WorldToViewportPoint(predictedPos)
			if onScreen and sp.Z > 0 then
				local dx = sp.X - cx
				local dy = sp.Y - cy
				local dist2 = dx * dx + dy * dy
				if dist2 <= FOV_RADIUS * FOV_RADIUS then
					if (camPos - hrp.Position).Magnitude <= MaxTargetDistance then
						if IsVisible(rawPos, localChar, char) then
							candidates[player] = {pos = predictedPos, dist2 = dist2}
							if dist2 < bestDist2 then
								bestDist2 = dist2
								bestPlayer = player
							end
						end
					end
				end
			end
		end
	end

	if AimbotEnabled then
		local chosenPlayer = nil
		local currentData = CurrentAimTarget and candidates[CurrentAimTarget]

		if currentData then
			CurrentAimMiss = 0
			if bestPlayer == CurrentAimTarget or bestDist2 >= currentData.dist2 * AIM_SWITCH_THRESHOLD then
				chosenPlayer = CurrentAimTarget
			else
				chosenPlayer = bestPlayer
			end
		elseif CurrentAimTarget and CurrentAimMiss < AIM_MAX_MISS_FRAMES and IsPlayerStillValid(CurrentAimTarget) then
			CurrentAimMiss = CurrentAimMiss + 1
			chosenPlayer = CurrentAimTarget
		else
			CurrentAimMiss = 0
			chosenPlayer = bestPlayer
		end

		CurrentAimTarget = chosenPlayer

		if chosenPlayer then
			local data = candidates[chosenPlayer]
			local rawTargetPos = data and data.pos or SmoothedAimPos

			if rawTargetPos then
				if SmoothedAimPos then
					SmoothedAimPos = SmoothedAimPos:Lerp(rawTargetPos, AIM_POS_SMOOTH)
				else
					SmoothedAimPos = rawTargetPos
				end

				if (camPos - SmoothedAimPos).Magnitude > 0.05 then
					local alpha = 1 - (1 - AIM_SMOOTHNESS) ^ (dt * 60)
					local desiredCFrame = CFrame.new(camPos, SmoothedAimPos)
					Camera.CFrame = camCF:Lerp(desiredCFrame, alpha)
				end
			end
		else
			SmoothedAimPos = nil
		end
	else
		CurrentAimTarget = nil
		CurrentAimMiss = 0
		SmoothedAimPos = nil
	end
end))

track(Players.PlayerRemoving:Connect(function(player)
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
end))

track(Players.PlayerAdded:Connect(function(player)
	cachedPlayers[#cachedPlayers + 1] = player
	SetupPlayer(player)
	if PlayerListPanel and PlayerListPanel.Visible then RefreshPlayerList() end
	if FlingListPanel and FlingListPanel.Visible then RefreshFlingList() end
end))

_G.__ZetaUnload = function()
	for i = 1, #connections do
		local c = connections[i]
		if c then
			pcall(function() c:Disconnect() end)
		end
	end
	connections = {}

	for player, _ in pairs(playerData) do
		pcall(CleanupPlayer, player)
	end

	AimbotEnabled = false
	EspEnabled = false
	NamesEnabled = false
	NoclipEnabled = false
	FlingEnabled = false
	FlingTarget = nil
	CurrentAimTarget = nil
	SmoothedAimPos = nil

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