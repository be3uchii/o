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
ScreenGui.Name = "LZhin"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = UI_Target

local connections = {}
local function addConn(conn)
	table.insert(connections, conn)
end

local tw = function(o, t, p) return TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p) end

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
ToggleUIBtn.Size = UDim2.new(0, 40, 0, 40)
ToggleUIBtn.Position = UDim2.new(0, 16, 0.5, -20)
ToggleUIBtn.BackgroundColor3 = BG_MAIN
ToggleUIBtn.TextColor3 = ACCENT
ToggleUIBtn.Text = "\u{26A1}"
ToggleUIBtn.TextSize = 18
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.AutoButtonColor = false
corner(ToggleUIBtn, 12)
stroke(ToggleUIBtn, STROKE_SOFT, 1, 0.2)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 360)
Frame.Position = UDim2.new(0.5, -140, 0.5, -180)
Frame.BackgroundColor3 = BG_MAIN
Frame.Visible = false
Frame.Active = true
corner(Frame, 20)
stroke(Frame, STROKE_SOFT, 1, 0.15)

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local LogoDot = Instance.new("Frame", TopBar)
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 20, 0.5, -4)
LogoDot.BackgroundColor3 = ACCENT_ON
corner(LogoDot, 4)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 36, 0, 0)
Title.Text = "LZhin"
Title.TextColor3 = TXT_PRIMARY
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
CloseBtn.BackgroundColor3 = BG_CARD
CloseBtn.Text = "\u{2715}"
CloseBtn.TextColor3 = TXT_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false
corner(CloseBtn, 14)

addConn(CloseBtn.MouseEnter:Connect(function()
	tw(CloseBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(220, 60, 60), TextColor3 = TXT_PRIMARY}):Play()
end))
addConn(CloseBtn.MouseLeave:Connect(function()
	tw(CloseBtn, 0.15, {BackgroundColor3 = BG_CARD, TextColor3 = TXT_DIM}):Play()
end))

local TabBar = Instance.new("Frame", Frame)
TabBar.Size = UDim2.new(1, -32, 0, 36)
TabBar.Position = UDim2.new(0, 16, 0, 54)
TabBar.BackgroundColor3 = BG_PANEL
corner(TabBar, 12)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)

local TabPadding = Instance.new("UIPadding", TabBar)
TabPadding.PaddingLeft = UDim.new(0, 4)
TabPadding.PaddingRight = UDim.new(0, 4)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.PaddingBottom = UDim.new(0, 4)

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
addConn(CloseBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end))

local pages = {}
local tabButtons = {}

local function CreatePage()
	local page = Instance.new("ScrollingFrame", Frame)
	page.Size = UDim2.new(1, -24, 1, -106)
	page.Position = UDim2.new(0, 12, 0, 98)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = STROKE_SOFT
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false

	local layout = Instance.new("UIListLayout", page)
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local padding = Instance.new("UIPadding", page)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 8)

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
	btn.Size = UDim2.new(0.333, -4, 1, 0)
	btn.BackgroundColor3 = BG_PANEL
	btn.Text = ""
	btn.AutoButtonColor = false
	corner(btn, 9)

	local lbl = Instance.new("TextLabel", btn)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = TXT_DIM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12

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
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 14)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -80, 0, 18)
	lbl.Position = UDim2.new(0, 16, 0, 11)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -80, 0, 14)
	sub.Position = UDim2.new(0, 16, 0, 30)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.BackgroundTransparency = 1

	local track = Instance.new("Frame", card)
	track.Size = UDim2.new(0, 44, 0, 24)
	track.Position = UDim2.new(1, -60, 0.5, -12)
	track.BackgroundColor3 = TOGGLE_OFF
	corner(track, 12)

	local knob = Instance.new("Frame", track)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = TOGGLE_KNOB
	corner(knob, 9)

	local btn = Instance.new("TextButton", card)
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false

	local state = false

	local function render()
		if state then
			tw(track, 0.18, {BackgroundColor3 = ACCENT_ON}):Play()
			tw(knob, 0.18, {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
		else
			tw(track, 0.18, {BackgroundColor3 = TOGGLE_OFF}):Play()
			tw(knob, 0.18, {Position = UDim2.new(0, 3, 0.5, -9)}):Play()
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

local function CreateAction(parent, text, info, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundColor3 = BG_CARD
	card.Parent = parent
	corner(card, 14)

	local lbl = Instance.new("TextLabel", card)
	lbl.Size = UDim2.new(1, -90, 0, 18)
	lbl.Position = UDim2.new(0, 16, 0, 11)
	lbl.Text = text
	lbl.TextColor3 = TXT_PRIMARY
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 13
	lbl.BackgroundTransparency = 1

	local sub = Instance.new("TextLabel", card)
	sub.Size = UDim2.new(1, -90, 0, 14)
	sub.Position = UDim2.new(0, 16, 0, 30)
	sub.Text = info
	sub.TextColor3 = TXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 10
	sub.BackgroundTransparency = 1

	local pill = Instance.new("TextLabel", card)
	pill.Size = UDim2.new(0, 56, 0, 26)
	pill.Position = UDim2.new(1, -72, 0.5, -13)
	pill.BackgroundColor3 = ACCENT
	pill.Text = "RUN"
	pill.TextColor3 = BG_MAIN
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 11
	corner(pill, 13)

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

	return card
end

CreateToggle(EspPage, "ESP", "Highlight boxes", function(on)
	EspEnabled = on
end)

CreateToggle(EspPage, "Names", "Show nicknames", function(on)
	NamesEnabled = on
end)

CreateToggle(CombatPage, "Aimbot", "Lock on target", function(on)
	AimbotEnabled = on
end)

CreateToggle(CombatPage, "Hitbox", "Expand hitboxes", function(on, sub)
	if on then
		HitboxMode = 1
	else
		HitboxMode = 0
	end
	if HitboxMode == 0 then
		sub.Text = "Expand hitboxes"
	else
		sub.Text = "Size: " .. HitboxSizes[HitboxMode + 1] .. "x"
	end
end)

CreateAction(MiscPage, "Teleport", "To syringe", function(pill)
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
	task.delay(0.3, function()
		tw(pill, 0.2, {BackgroundColor3 = ACCENT}):Play()
	end)
end)

CreateToggle(MiscPage, "NoClip", "Walk through objects", function(on)
	NoclipEnabled = on
end)

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
	if data.espBillboard then
		if data.espBillboard.Parent then data.espBillboard:Destroy() end
		data.espBillboard = nil
	end
end

local function DestroyHighlight(data)
	if data.highlight then
		if data.highlight.Parent then data.highlight:Destroy() end
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
		hl.FillTransparency    = 0.8
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
		bb.Size           = UDim2.new(0, 110, 0, 26)
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
		txt.TextStrokeTransparency = 0.2
		txt.Font                   = Enum.Font.GothamBold
		txt.TextSize               = 12

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
		end
	end
end))
