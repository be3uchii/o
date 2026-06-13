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
local Smoothing = 0.18
local MaxTargetDistance = 600
local PredictionStrength = 0.5
local AimAssist = true

local UI_Target
local ok = pcall(function() return CoreGui.Name end)
UI_Target = ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LZhin_V10"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = UI_Target

local FovCircle = Instance.new("Frame", ScreenGui)
FovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
FovCircle.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
FovCircle.BackgroundTransparency = 1
FovCircle.Visible = false
Instance.new("UICorner", FovCircle).CornerRadius = UDim.new(1, 0)
local FovStroke = Instance.new("UIStroke", FovCircle)
FovStroke.Color = Color3.fromRGB(0, 220, 150)
FovStroke.Thickness = 1
FovStroke.Transparency = 0.65

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
local TStroke = Instance.new("UIStroke", ToggleUIBtn)
TStroke.Color = Color3.fromRGB(0, 220, 150)
TStroke.Thickness = 1
TStroke.Transparency = 0.3

ToggleUIBtn.MouseEnter:Connect(function()
	TweenService:Create(ToggleUIBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 26)}):Play()
end)
ToggleUIBtn.MouseLeave:Connect(function()
	TweenService:Create(ToggleUIBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(14, 14, 18)}):Play()
end)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 210, 0, 330)
Frame.Position = UDim2.new(0.5, -105, 0.5, -165)
Frame.BackgroundColor3 = Color3.fromRGB(11, 11, 15)
Frame.Visible = false
Frame.Active = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)
local FStroke = Instance.new("UIStroke", Frame)
FStroke.Color = Color3.fromRGB(0, 220, 150)
FStroke.Thickness = 1
FStroke.Transparency = 0.4

local TopBar = Instance.new("Frame", Frame)
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopBar.ZIndex = 2
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)
local TopFix = Instance.new("Frame", TopBar)
TopFix.Size = UDim2.new(1, 0, 0, 10)
TopFix.Position = UDim2.new(0, 0, 1, -10)
TopFix.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
TopFix.BorderSizePixel = 0

local TopAccent = Instance.new("Frame", TopBar)
TopAccent.Size = UDim2.new(0, 28, 0, 2)
TopAccent.Position = UDim2.new(0, 10, 1, -2)
TopAccent.BackgroundColor3 = Color3.fromRGB(0, 220, 150)
TopAccent.BorderSizePixel = 0
Instance.new("UICorner", TopAccent).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "⚡ LZhin V10"
Title.TextColor3 = Color3.fromRGB(220, 220, 225)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

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

CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(230, 60, 60)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)

local Content = Instance.new("ScrollingFrame", Frame)
Content.Size = UDim2.new(1, 0, 1, -42)
Content.Position = UDim2.new(0, 0, 0, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = Color3.fromRGB(0, 220, 150)
Content.CanvasSize = UDim2.new(0, 0, 0, 280)

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.Padding = UDim.new(0, 7)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding", Content)
UIPadding.PaddingTop = UDim.new(0, 8)

local isDragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				isDragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and isDragging then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

ToggleUIBtn.MouseButton1Click:Connect(function()
	Frame.Visible = not Frame.Visible
	if Frame.Visible then
		Frame.BackgroundTransparency = 1
		TweenService:Create(Frame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	Frame.Visible = false
end)

local function CreateButton(text, info)
	local BtnFrame = Instance.new("Frame")
	BtnFrame.Size = UDim2.new(0.91, 0, 0, 46)
	BtnFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 10)
	local BStroke = Instance.new("UIStroke", BtnFrame)
	BStroke.Color = Color3.fromRGB(38, 38, 48)
	BStroke.Thickness = 1

	local Lbl = Instance.new("TextLabel", BtnFrame)
	Lbl.Size = UDim2.new(1, -58, 0.5, 0)
	Lbl.Position = UDim2.new(0, 12, 0, 5)
	Lbl.Text = text
	Lbl.TextColor3 = Color3.fromRGB(215, 215, 222)
	Lbl.Font = Enum.Font.GothamBold
	Lbl.TextSize = 11
	Lbl.BackgroundTransparency = 1
	Lbl.TextXAlignment = Enum.TextXAlignment.Left

	local Sub = Instance.new("TextLabel", BtnFrame)
	Sub.Size = UDim2.new(1, -58, 0.5, 0)
	Sub.Position = UDim2.new(0, 12, 0.5, -3)
	Sub.Text = info
	Sub.TextColor3 = Color3.fromRGB(100, 100, 112)
	Sub.Font = Enum.Font.Gotham
	Sub.TextSize = 9
	Sub.BackgroundTransparency = 1
	Sub.TextXAlignment = Enum.TextXAlignment.Left

	local ActionBtn = Instance.new("TextButton", BtnFrame)
	ActionBtn.Size = UDim2.new(1, 0, 1, 0)
	ActionBtn.BackgroundTransparency = 1
	ActionBtn.Text = ""
	ActionBtn.AutoButtonColor = false

	local Badge = Instance.new("Frame", BtnFrame)
	Badge.Size = UDim2.new(0, 40, 0, 20)
	Badge.Position = UDim2.new(1, -48, 0.5, -10)
	Badge.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
	Instance.new("UICorner", Badge).CornerRadius = UDim.new(0, 6)
	local BadgeStroke = Instance.new("UIStroke", Badge)
	BadgeStroke.Color = Color3.fromRGB(38, 38, 48)
	BadgeStroke.Thickness = 1

	local StatusText = Instance.new("TextLabel", Badge)
	StatusText.Size = UDim2.new(1, 0, 1, 0)
	StatusText.Text = "OFF"
	StatusText.TextColor3 = Color3.fromRGB(200, 70, 70)
	StatusText.Font = Enum.Font.GothamBold
	StatusText.TextSize = 10
	StatusText.BackgroundTransparency = 1

	ActionBtn.MouseEnter:Connect(function()
		TweenService:Create(BtnFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}):Play()
	end)
	ActionBtn.MouseLeave:Connect(function()
		TweenService:Create(BtnFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
	end)

	return BtnFrame, ActionBtn, StatusText, BStroke, Sub, Badge, BadgeStroke
end

local function CreateSlider(text, minVal, maxVal, defaultVal)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(0.91, 0, 0, 50)
	Container.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)
	local CStroke = Instance.new("UIStroke", Container)
	CStroke.Color = Color3.fromRGB(38, 38, 48)
	CStroke.Thickness = 1

	local Lbl = Instance.new("TextLabel", Container)
	Lbl.Size = UDim2.new(1, -40, 0, 18)
	Lbl.Position = UDim2.new(0, 12, 0, 8)
	Lbl.Text = text
	Lbl.TextColor3 = Color3.fromRGB(215, 215, 222)
	Lbl.Font = Enum.Font.GothamBold
	Lbl.TextSize = 10
	Lbl.BackgroundTransparency = 1
	Lbl.TextXAlignment = Enum.TextXAlignment.Left

	local ValueLbl = Instance.new("TextLabel", Container)
	ValueLbl.Size = UDim2.new(0, 30, 0, 18)
	ValueLbl.Position = UDim2.new(1, -42, 0, 8)
	ValueLbl.Text = tostring(math.floor(defaultVal * 100) / 100)
	ValueLbl.TextColor3 = Color3.fromRGB(0, 220, 150)
	ValueLbl.Font = Enum.Font.GothamBold
	ValueLbl.TextSize = 9
	ValueLbl.BackgroundTransparency = 1
	ValueLbl.TextXAlignment = Enum.TextXAlignment.Right

	local SliderBG = Instance.new("Frame", Container)
	SliderBG.Size = UDim2.new(1, -24, 0, 4)
	SliderBG.Position = UDim2.new(0, 12, 0, 32)
	SliderBG.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
	Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)

	local SliderFill = Instance.new("Frame", SliderBG)
	SliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(0, 220, 150)
	Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

	local SliderBtn = Instance.new("TextButton", Container)
	SliderBtn.Size = UDim2.new(0, 12, 0, 12)
	SliderBtn.Position = UDim2.new(0, 12 + ((defaultVal - minVal) / (maxVal - minVal)) * (Container.Size.X.Offset - 24) - 6, 0, 30)
	SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 150)
	SliderBtn.Text = ""
	SliderBtn.AutoButtonColor = false
	Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

	local isDragging = false
	local currentValue = defaultVal

	SliderBtn.MouseButton1Down:Connect(function()
		isDragging = true
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if not isDragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local mouseX = UserInputService:GetMouseLocation().X
			local sliderX = SliderBG.AbsolutePosition.X
			local sliderWidth = SliderBG.AbsoluteSize.X
			local relativePos = math.clamp(mouseX - sliderX, 0, sliderWidth)
			currentValue = minVal + (relativePos / sliderWidth) * (maxVal - minVal)
			currentValue = math.floor(currentValue * 100) / 100

			SliderFill.Size = UDim2.new(relativePos / sliderWidth, 0, 1, 0)
			SliderBtn.Position = UDim2.new(0, sliderX - Container.AbsolutePosition.X + relativePos - 6, 0, 30)
			ValueLbl.Text = tostring(currentValue)

			return currentValue
		end
	end)

	return Container, function() return currentValue end
end

local AimFrame, AimBtn, AimStatus, AimStroke, _, AimBadge, AimBadgeStroke = CreateButton("Aimbot", "Prediction + Lock")
AimFrame.Parent = Content
local HitFrame, HitBtn, HitStatus, HitStroke, HitSub, HitBadge, HitBadgeStroke = CreateButton("Hitbox", "Default size")
HitFrame.Parent = Content
local EspFrame, EspBtn, EspStatus, EspStroke, _, EspBadge, EspBadgeStroke = CreateButton("ESP", "Name + Highlight")
EspFrame.Parent = Content

local SmoothingSlider, GetSmoothing = CreateSlider("Smoothing", 0.01, 0.5, 0.18)
SmoothingSlider.Parent = Content

local PredictionSlider, GetPrediction = CreateSlider("Prediction", 0, 1, 0.5)
PredictionSlider.Parent = Content

local function SetActive(status, stroke, badge, badgeStroke, on)
	if on then
		status.TextColor3 = Color3.fromRGB(0, 220, 150)
		stroke.Color = Color3.fromRGB(0, 220, 150)
		stroke.Transparency = 0.2
		badge.BackgroundColor3 = Color3.fromRGB(0, 40, 28)
		badgeStroke.Color = Color3.fromRGB(0, 180, 120)
	else
		status.TextColor3 = Color3.fromRGB(200, 70, 70)
		stroke.Color = Color3.fromRGB(38, 38, 48)
		stroke.Transparency = 0
		badge.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
		badgeStroke.Color = Color3.fromRGB(38, 38, 48)
	end
end

AimBtn.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	AimStatus.Text = AimbotEnabled and "ON" or "OFF"
	SetActive(AimStatus, AimStroke, AimBadge, AimBadgeStroke, AimbotEnabled)
	FovCircle.Visible = AimbotEnabled
end)

HitBtn.MouseButton1Click:Connect(function()
	HitboxMode = (HitboxMode + 1) % #HitboxSizes
	if HitboxMode == 0 then
		HitStatus.Text = "OFF"
		HitSub.Text = "Default size"
		SetActive(HitStatus, HitStroke, HitBadge, HitBadgeStroke, false)
	else
		HitStatus.Text = "V" .. HitboxMode
		HitSub.Text = "Size: " .. HitboxSizes[HitboxMode + 1] .. "x"
		SetActive(HitStatus, HitStroke, HitBadge, HitBadgeStroke, true)
	end
end)

EspBtn.MouseButton1Click:Connect(function()
	EspEnabled = not EspEnabled
	EspStatus.Text = EspEnabled and "ON" or "OFF"
	SetActive(EspStatus, EspStroke, EspBadge, EspBadgeStroke, EspEnabled)
end)

local playerData = {}
local playerVelocity = {}

local function GetData(player)
	if not playerData[player] then
		playerData[player] = {
			origSize = nil,
			origTrans = nil,
			origCollide = nil,
			hitboxActive = false,
			espBillboard = nil,
			highlight = nil,
		}
	end
	return playerData[player]
end

local function SaveHRP(data, hrp)
	if not data.origSize then
		data.origSize = hrp.Size
		data.origTrans = hrp.Transparency
		data.origCollide = hrp.CanCollide
	end
end

local function RestoreHRP(data, hrp)
	if data.origSize then
		hrp.Size = data.origSize
		hrp.Transparency = data.origTrans
		hrp.CanCollide = data.origCollide
		data.origSize = nil
		data.origTrans = nil
		data.origCollide = nil
		data.hitboxActive = false
	end
end

local function RemoveESP(player)
	local data = playerData[player]
	if not data then return end
	if data.espBillboard and data.espBillboard.Parent then
		data.espBillboard:Destroy()
	end
	data.espBillboard = nil
	if data.highlight and data.highlight.Parent then
		data.highlight:Destroy()
	end
	data.highlight = nil
end

local function CleanupPlayer(player)
	local data = playerData[player]
	if data then
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp and data.hitboxActive then
				RestoreHRP(data, hrp)
			end
		end
		RemoveESP(player)
	end
	playerData[player] = nil
	playerVelocity[player] = nil
end

Players.PlayerRemoving:Connect(CleanupPlayer)

local function ApplyHitbox(player, hrp, size)
	local data = GetData(player)
	SaveHRP(data, hrp)
	hrp.Size = Vector3.new(size, size, size)
	hrp.Transparency = 0.75
	hrp.CanCollide = false
	data.hitboxActive = true
end

local function DeactivateHitbox(player, hrp)
	local data = playerData[player]
	if not data then return end
	if data.hitboxActive then
		RestoreHRP(data, hrp)
	end
end

local function GetOrCreateESP(player, hrp, char)
	local data = GetData(player)

	if not data.espBillboard or not data.espBillboard.Parent then
		local bb = Instance.new("BillboardGui")
		bb.Name = "LZhinESPName_" .. player.Name
		bb.Adornee = hrp
		bb.Size = UDim2.new(0, 100, 0, 24)
		bb.StudsOffset = Vector3.new(0, 3.2, 0)
		bb.AlwaysOnTop = true
		bb.Parent = ScreenGui

		local txt = Instance.new("TextLabel", bb)
		txt.Size = UDim2.new(1, 0, 1, 0)
		txt.BackgroundTransparency = 1
		txt.Text = player.Name
		txt.TextColor3 = Color3.fromRGB(200, 255, 220)
		txt.TextTransparency = 0.25
		txt.TextStrokeTransparency = 0.4
		txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		txt.Font = Enum.Font.GothamBold
		txt.TextSize = 10
		txt.TextXAlignment = Enum.TextXAlignment.Center

		data.espBillboard = bb
	end

	if not data.highlight or not data.highlight.Parent then
		local hl = Instance.new("Highlight")
		hl.Name = "LZhinHL_" .. player.Name
		hl.Adornee = char
		hl.FillColor = Color3.fromRGB(0, 180, 120)
		hl.FillTransparency = 0.72
		hl.OutlineColor = Color3.fromRGB(0, 220, 150)
		hl.OutlineTransparency = 0.15
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = ScreenGui
		data.highlight = hl
	end
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function IsVisible(targetPos, char)
	local origin = Camera.CFrame.Position
	local dir = targetPos - origin
	local filterList = {Camera}
	local localChar = LocalPlayer.Character
	if localChar then table.insert(filterList, localChar) end
	table.insert(filterList, char)
	rayParams.FilterDescendantsInstances = filterList
	local result = workspace:Raycast(origin, dir, rayParams)
	return result == nil
end

local lastCFUpdate = 0
local cameraVelocity = Vector3.new(0, 0, 0)
local lastCameraPos = Camera.CFrame.Position

local function PredictPosition(pos, player, hrp)
	if not playerVelocity[player] then
		playerVelocity[player] = Vector3.new(0, 0, 0)
	end

	local prediction = GetPrediction()
	local velocity = playerVelocity[player]
	local predictedPos = pos + velocity * prediction

	return predictedPos
end

RunService.RenderStepped:Connect(function()
	Smoothing = GetSmoothing()
	PredictionStrength = GetPrediction()

	local vpSize = Camera.ViewportSize
	local ScreenCenter = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
	local camCFrame = Camera.CFrame
	local camPos = camCFrame.Position
	local players = Players:GetPlayers()

	local closestTarget = nil
	local shortestDist = math.huge
	local targetVelocity = Vector3.new(0, 0, 0)

	for i = 1, #players do
		local player = players[i]
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
		local isAlive = humanoid and humanoid.Health > 0

		if isAlive and HitboxMode > 0 then
			ApplyHitbox(player, hrp, HitboxSizes[HitboxMode + 1])
		else
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
				local head = char:FindFirstChild("Head")
				local aimPos = head and head.Position or hrp.Position

				if playerVelocity[player] then
					local newPos = PredictPosition(aimPos, player, hrp)
					local screenPos, onScreen = Camera:WorldToViewportPoint(newPos)
					if onScreen then
						local pos2D = Vector2.new(screenPos.X, screenPos.Y)
						local dist = (pos2D - ScreenCenter).Magnitude
						if dist < FOV_RADIUS and dist < shortestDist then
							if IsVisible(newPos, char) then
								shortestDist = dist
								closestTarget = newPos
								targetVelocity = playerVelocity[player]
							end
						end
					end
				else
					local screenPos, onScreen = Camera:WorldToViewportPoint(aimPos)
					if onScreen then
						local pos2D = Vector2.new(screenPos.X, screenPos.Y)
						local dist = (pos2D - ScreenCenter).Magnitude
						if dist < FOV_RADIUS and dist < shortestDist then
							if IsVisible(aimPos, char) then
								shortestDist = dist
								closestTarget = aimPos
							end
						end
					end
				end
			end
		end

		if playerVelocity[player] == nil then
			playerVelocity[player] = Vector3.new(0, 0, 0)
		end
		local oldPos = playerVelocity[player]
		playerVelocity[player] = hrp.Velocity
	end

	if AimbotEnabled and closestTarget then
		local newCF = CFrame.new(camPos, closestTarget)
		Camera.CFrame = camCFrame:Lerp(newCF, math.clamp(Smoothing, 0.01, 0.5))
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		CleanupPlayer(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			CleanupPlayer(player)
		end)
	end
end