local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local TITLE = "script for everyone"
local AUTHOR = "@plevokek"
local VERSION = "0.1"

local BASE_WIDTH = 1024
local BASE_HEIGHT = 647
local ROUNDING = 2

local FOLDER_NAME = "ScriptForEveryone"
local CONFIG_PATH = FOLDER_NAME .. "/config.json"

local ICON_CLOSE = "rbxassetid://6031094678"
local ICON_SETTINGS = "rbxassetid://7059346373"
local ICON_MORE = "rbxassetid://5107175347"
local ICON_BOLT = "rbxassetid://12100467982"
local ICON_BOLT_TOGGLE = "rbxassetid://13160015062"
local ICON_HOME = "rbxassetid://7539983773"

local COLOR_WINDOW = Color3.fromRGB(15, 15, 15)
local COLOR_HEADER = Color3.fromRGB(10, 10, 10)
local COLOR_SIDEBAR = Color3.fromRGB(13, 13, 13)
local COLOR_PANEL = Color3.fromRGB(24, 24, 24)
local COLOR_ITEM = Color3.fromRGB(26, 26, 26)
local COLOR_ITEM_ACTIVE = Color3.fromRGB(38, 38, 38)
local COLOR_STROKE = Color3.fromRGB(48, 48, 48)
local COLOR_TEXT = Color3.fromRGB(240, 240, 240)
local COLOR_TEXT_DIM = Color3.fromRGB(208, 208, 208)
local COLOR_TRACK = Color3.fromRGB(58, 58, 58)

local COLOR_INNOCENT = Color3.fromRGB(0, 255, 90)
local COLOR_MURDERER = Color3.fromRGB(255, 45, 45)
local COLOR_GUN = Color3.fromRGB(255, 140, 0)

local RING_SIZE = 186
local RING_RADIUS = 79
local RING_THICKNESS = 20
local RING_SEGMENTS = 100

local DEFAULTS = {
	colorR = 255,
	colorG = 255,
	colorB = 255,
	transparency = 0,
	scale = 1.1,
	espFillOn = 0,
	espBoxOn = 0,
	espNameOn = 0,
	espDistOn = 0,
	espFillR = 0,
	espFillG = 255,
	espFillB = 120,
	espBoxR = 255,
	espBoxG = 255,
	espBoxB = 255,
	espNameR = 255,
	espNameG = 255,
	espNameB = 255,
	espDistR = 255,
	espDistG = 255,
	espDistB = 255,
	mm2On = 0,
	gunOn = 0,
	speedOn = 0,
	speedValue = 16,
	hitboxOn = 0,
	hitboxSize = 5,
	hitboxR = 255,
	hitboxG = 60,
	hitboxB = 60,
}

local config = {}
for key, value in pairs(DEFAULTS) do
	config[key] = value
end

local hasFiles = typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"

local function ensureFolder()
	if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
		pcall(function()
			if not isfolder(FOLDER_NAME) then
				makefolder(FOLDER_NAME)
			end
		end)
	end
end

local function loadConfig()
	if not hasFiles then
		return
	end
	ensureFolder()
	local ok, raw = pcall(function()
		if isfile(CONFIG_PATH) then
			return readfile(CONFIG_PATH)
		end
		return nil
	end)
	if not ok or type(raw) ~= "string" then
		return
	end
	local decoded
	ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if not ok or type(decoded) ~= "table" then
		return
	end
	for key in pairs(DEFAULTS) do
		if tonumber(decoded[key]) then
			config[key] = tonumber(decoded[key])
		end
	end
	config.transparency = math.clamp(config.transparency, 0, 0.7)
	config.scale = math.clamp(config.scale, 0.5, 1.6)
	config.speedValue = math.clamp(config.speedValue, 16, 200)
	config.hitboxSize = math.clamp(config.hitboxSize, 1, 20)
end

local saveQueued = false

local function saveConfig()
	if not hasFiles or saveQueued then
		return
	end
	saveQueued = true
	task.delay(0.3, function()
		saveQueued = false
		ensureFolder()
		pcall(function()
			writefile(CONFIG_PATH, HttpService:JSONEncode(config))
		end)
	end)
end

loadConfig()

local function colorOf(prefix)
	return Color3.fromRGB(
		math.clamp(config[prefix .. "R"] or 255, 0, 255),
		math.clamp(config[prefix .. "G"] or 255, 0, 255),
		math.clamp(config[prefix .. "B"] or 255, 0, 255)
	)
end

local function setColorOf(prefix, color)
	config[prefix .. "R"] = math.floor(color.R * 255 + 0.5)
	config[prefix .. "G"] = math.floor(color.G * 255 + 0.5)
	config[prefix .. "B"] = math.floor(color.B * 255 + 0.5)
end

local function accentColor()
	return colorOf("color")
end

local function flag(key)
	return (config[key] or 0) >= 0.5
end

local function toHex(color)
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
	)
end

local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end
	if typeof(get_hidden_gui) == "function" then
		local ok, result = pcall(get_hidden_gui)
		if ok and result then
			return result
		end
	end
	local ok = pcall(function()
		return CoreGui.Name
	end)
	if ok then
		return CoreGui
	end
	return player:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()

for _, gui in ipairs(guiParent:GetChildren()) do
	if gui.Name == "ScriptForEveryoneUI" then
		gui:Destroy()
	end
end

local panelParts = {}
local accentFills = {}
local accentStrokes = {}
local switches = {}
local swatches = {}

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, math.floor(radius * ROUNDING))
	c.Parent = parent
	return c
end

local function circle(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or COLOR_STROKE
	s.Thickness = thickness or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function makeIcon(parent, imageId, size, position, anchor)
	local image = Instance.new("ImageLabel")
	image.Name = "Icon"
	image.BackgroundTransparency = 1
	image.Size = UDim2.fromOffset(size, size)
	image.Position = position
	image.AnchorPoint = anchor or Vector2.new(0, 0)
	image.ScaleType = Enum.ScaleType.Fit
	image.Image = imageId
	image.ImageColor3 = COLOR_TEXT
	image.Parent = parent
	return image
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptForEveryoneUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
if syn and syn.protect_gui then
	pcall(syn.protect_gui, screenGui)
end
if typeof(protectgui) == "function" then
	pcall(protectgui, screenGui)
end
screenGui.Parent = guiParent

local espHolder = Instance.new("Frame")
espHolder.Name = "Esp"
espHolder.BackgroundTransparency = 1
espHolder.Size = UDim2.fromScale(1, 1)
espHolder.ZIndex = 0
espHolder.Parent = screenGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT)
window.BackgroundColor3 = COLOR_WINDOW
window.BorderSizePixel = 0
window.Active = true
window.ZIndex = 5
window.Parent = screenGui
corner(window, 14)
stroke(window, Color3.fromRGB(38, 38, 38), 1)
table.insert(panelParts, window)

local uiScale = Instance.new("UIScale")
uiScale.Parent = window

local function applyScale()
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local widthRatio = isMobile and 0.52 or 0.60
	local heightRatio = isMobile and 0.56 or 0.70
	local base = math.min(viewport.X * widthRatio / BASE_WIDTH, viewport.Y * heightRatio / BASE_HEIGHT)
	uiScale.Scale = math.clamp(base * config.scale, 0.15, 1.6)
end

applyScale()

local headerClip = Instance.new("Frame")
headerClip.Name = "HeaderClip"
headerClip.BackgroundTransparency = 1
headerClip.Size = UDim2.new(1, 0, 0, 62)
headerClip.ClipsDescendants = true
headerClip.ZIndex = 5
headerClip.Parent = window

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 92)
header.BackgroundColor3 = COLOR_HEADER
header.BorderSizePixel = 0
header.ZIndex = 5
header.Parent = headerClip
corner(header, 14)
table.insert(panelParts, header)

makeIcon(header, ICON_BOLT, 28, UDim2.fromOffset(16, 17)).ZIndex = 6

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(54, 11)
titleLabel.Size = UDim2.fromOffset(760, 24)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 22
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = COLOR_TEXT
titleLabel.RichText = true
titleLabel.Text = TITLE .. " <font color=\"rgb(140,140,140)\">\u{2022}</font> " .. AUTHOR
titleLabel.ZIndex = 6
titleLabel.Parent = header

local versionLabel = Instance.new("TextLabel")
versionLabel.BackgroundTransparency = 1
versionLabel.Position = UDim2.fromOffset(54, 35)
versionLabel.Size = UDim2.fromOffset(220, 18)
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 16
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.TextColor3 = COLOR_TEXT_DIM
versionLabel.Text = VERSION
versionLabel.ZIndex = 6
versionLabel.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.BackgroundTransparency = 1
closeButton.AutoButtonColor = false
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -14, 0, 12)
closeButton.Size = UDim2.fromOffset(38, 38)
closeButton.Text = ""
closeButton.ZIndex = 6
closeButton.Parent = header

makeIcon(closeButton, ICON_CLOSE, 19, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)).ZIndex = 7

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 62)
body.Size = UDim2.new(1, 0, 1, -62)
body.ZIndex = 5
body.Parent = window

local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromOffset(12, 8)
sidebar.Size = UDim2.new(0, 212, 1, -20)
sidebar.ZIndex = 5
sidebar.Parent = body
corner(sidebar, 12)
stroke(sidebar, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, sidebar)

local navHolder = Instance.new("Frame")
navHolder.BackgroundTransparency = 1
navHolder.Position = UDim2.fromOffset(12, 12)
navHolder.Size = UDim2.new(1, -24, 0, 200)
navHolder.ZIndex = 5
navHolder.Parent = sidebar

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 9)
navList.SortOrder = Enum.SortOrder.LayoutOrder
navList.Parent = navHolder

local content = Instance.new("Frame")
content.BackgroundColor3 = COLOR_PANEL
content.BorderSizePixel = 0
content.Position = UDim2.fromOffset(236, 8)
content.Size = UDim2.new(1, -248, 1, -20)
content.ClipsDescendants = true
content.ZIndex = 5
content.Parent = body
corner(content, 12)
stroke(content, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, content)

local pages = {}
local buttons = {}
local navStrokes = {}
local currentPage = "Main"

local function applySettings()
	local accent = accentColor()
	for _, fill in ipairs(accentFills) do
		fill.BackgroundColor3 = accent
	end
	for _, item in ipairs(accentStrokes) do
		item.Color = accent
	end
	for name, item in pairs(navStrokes) do
		item.Color = name == currentPage and accent or Color3.fromRGB(42, 42, 42)
	end
	for _, render in ipairs(switches) do
		render()
	end
	for _, part in ipairs(panelParts) do
		part.BackgroundTransparency = config.transparency
	end
end

local function makePage(name)
	local page = Instance.new("Frame")
	page.Name = name
	page.BackgroundTransparency = 1
	page.Size = UDim2.fromScale(1, 1)
	page.Visible = false
	page.ZIndex = 6
	page.Parent = content

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 18)
	pad.PaddingBottom = UDim.new(0, 18)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = page

	pages[name] = page
	return page
end

local function makeList(page)
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Size = UDim2.fromScale(1, 1)
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 4
	list.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	list.ZIndex = 6
	list.Parent = page

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local padding = Instance.new("UIPadding")
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = list

	local order = 0

	local function row(height)
		order = order + 1
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = COLOR_ITEM
		frame.BorderSizePixel = 0
		frame.Size = UDim2.new(1, 0, 0, height)
		frame.LayoutOrder = order
		frame.ZIndex = 6
		frame.Parent = list
		corner(frame, 10)
		stroke(frame, Color3.fromRGB(42, 42, 42), 1)
		return frame
	end

	local function divider(text)
		order = order + 1
		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Size = UDim2.new(1, 0, 0, 40)
		holder.LayoutOrder = order
		holder.ZIndex = 6
		holder.Parent = list

		local line = Instance.new("Frame")
		line.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
		line.BorderSizePixel = 0
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.ZIndex = 6
		line.Parent = holder

		local label = Instance.new("TextLabel")
		label.BackgroundColor3 = COLOR_PANEL
		label.BorderSizePixel = 0
		label.AnchorPoint = Vector2.new(0, 0.5)
		label.Position = UDim2.new(0, 12, 0.5, 0)
		label.Size = UDim2.fromOffset(120, 22)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 17
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextColor3 = COLOR_TEXT_DIM
		label.Text = text
		label.ZIndex = 7
		label.Parent = holder

		return holder
	end

	return row, divider
end

local function makeRowTitle(parent, text, subtext, zIndex)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(18, 14)
	title.Size = UDim2.new(1, -190, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_TEXT
	title.Text = text
	title.ZIndex = zIndex or 7
	title.Parent = parent

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(18, 36)
		sub.Size = UDim2.new(1, -190, 0, 20)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 17
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.TextTruncate = Enum.TextTruncate.AtEnd
		sub.TextColor3 = COLOR_TEXT_DIM
		sub.Text = subtext
		sub.ZIndex = zIndex or 7
		sub.Parent = parent
	end

	return title
end

local function selectPage(name)
	currentPage = name
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
	local accent = accentColor()
	for buttonName, button in pairs(buttons) do
		local active = buttonName == name
		TweenService:Create(button, TweenInfo.new(0.18), {
			BackgroundColor3 = active and COLOR_ITEM_ACTIVE or COLOR_ITEM,
		}):Play()
		navStrokes[buttonName].Color = active and accent or Color3.fromRGB(42, 42, 42)
	end
end

local function makeNavButton(name, imageId, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.LayoutOrder = order
	button.AutoButtonColor = false
	button.BackgroundColor3 = COLOR_ITEM
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 0, 58)
	button.Text = ""
	button.ZIndex = 6
	button.Parent = navHolder
	corner(button, 10)
	navStrokes[name] = stroke(button, Color3.fromRGB(42, 42, 42), 1)

	makeIcon(button, imageId, 23, UDim2.new(0, 17, 0.5, 0), Vector2.new(0, 0.5)).ZIndex = 7

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(54, 0)
	label.Size = UDim2.new(1, -64, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = name
	label.TextSize = 21
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COLOR_TEXT
	label.ZIndex = 7
	label.Parent = button

	button.MouseButton1Click:Connect(function()
		selectPage(name)
	end)

	buttons[name] = button
	return button
end

local mainPage = makePage("Main")
local morePage = makePage("More")
local settingsPage = makePage("Settings")

local mainRow, mainDivider = makeList(mainPage)
local moreRow = makeList(morePage)
local settingsRow = makeList(settingsPage)

local activeDrag = nil

UserInputService.InputChanged:Connect(function(input)
	if not activeDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		activeDrag.update(input.Position.X, input.Position.Y)
	elseif input.UserInputType == Enum.UserInputType.Touch and input == activeDrag.input then
		activeDrag.update(input.Position.X, input.Position.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not activeDrag then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == activeDrag.input then
		local finished = activeDrag.finished
		activeDrag = nil
		if finished then
			finished()
		end
	end
end)

local function buildSlider(options)
	local holder = options.parent
	local zIndex = options.zIndex or 7

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(options.x, options.y)
	label.Size = UDim2.fromOffset(math.max(options.width - 120, 60), 22)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 20
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COLOR_TEXT
	label.Text = options.name
	label.ZIndex = zIndex
	label.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.fromOffset(options.x + options.width - 120, options.y)
	valueLabel.Size = UDim2.fromOffset(120, 22)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 19
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = COLOR_TEXT_DIM
	valueLabel.ZIndex = zIndex
	valueLabel.Parent = holder

	local track = Instance.new("Frame")
	track.BackgroundColor3 = COLOR_TRACK
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(options.x, options.y + 32)
	track.Size = UDim2.fromOffset(options.width, 10)
	track.ZIndex = zIndex
	track.Parent = holder
	circle(track, 5)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = accentColor()
	fill.Size = UDim2.fromScale(0, 1)
	fill.ZIndex = zIndex + 1
	fill.Parent = track
	circle(fill, 5)

	local gradient = nil
	if options.gradient == "saturation" then
		fill.BackgroundTransparency = 1
		track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		gradient = Instance.new("UIGradient")
		gradient.Parent = track
	else
		table.insert(accentFills, fill)
	end

	local hitbox = Instance.new("TextButton")
	hitbox.AutoButtonColor = false
	hitbox.Text = ""
	hitbox.BackgroundTransparency = 1
	hitbox.Position = UDim2.fromOffset(options.x - 6, options.y + 18)
	hitbox.Size = UDim2.fromOffset(options.width + 12, 38)
	hitbox.ZIndex = zIndex + 3
	hitbox.Parent = holder

	local knob = Instance.new("Frame")
	knob.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(20, 20)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = zIndex + 2
	knob.Parent = track
	circle(knob, 10)
	stroke(knob, Color3.fromRGB(24, 24, 24), 2)

	if options.fullWidth then
		label.Size = UDim2.new(1, -(options.x * 2) - 120, 0, 22)
		valueLabel.AnchorPoint = Vector2.new(1, 0)
		valueLabel.Position = UDim2.new(1, -options.x, 0, options.y)
		track.Size = UDim2.new(1, -options.x * 2, 0, 10)
		hitbox.Size = UDim2.new(1, -options.x * 2 + 12, 0, 38)
	end

	local function render()
		local alpha = math.clamp((options.get() - options.min) / (options.max - options.min), 0, 1)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = options.format(options.get())
		if gradient and options.gradientColor then
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, options.gradientColor()),
			})
		end
	end

	local function update(x)
		local absolutePosition = track.AbsolutePosition.X
		local absoluteSize = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - absolutePosition) / absoluteSize, 0, 1)
		options.set(options.min + (options.max - options.min) * alpha)
		render()
	end

	hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if activeDrag == nil then
				activeDrag = { update = update, input = input, finished = options.finished }
				update(input.Position.X)
			end
		end
	end)

	render()
	return render
end

local openPicker

local function makeSwitch(row, key, offsetX, onChanged)
	local track = Instance.new("Frame")
	track.BorderSizePixel = 0
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -offsetX, 0.5, 0)
	track.Size = UDim2.fromOffset(66, 36)
	track.BackgroundColor3 = COLOR_TRACK
	track.ZIndex = 7
	track.Parent = row
	circle(track, 18)

	local knob = Instance.new("Frame")
	knob.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = UDim2.new(0, 3, 0.5, 0)
	knob.Size = UDim2.fromOffset(30, 30)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 8
	knob.Parent = track
	circle(knob, 15)

	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Text = ""
	button.BackgroundTransparency = 1
	button.Size = UDim2.fromScale(1, 1)
	button.ZIndex = 9
	button.Parent = track

	local function render()
		local on = flag(key)
		TweenService:Create(track, TweenInfo.new(0.16), {
			BackgroundColor3 = on and accentColor() or COLOR_TRACK,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.16), {
			Position = on and UDim2.new(1, -33, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		}):Play()
	end

	button.MouseButton1Click:Connect(function()
		config[key] = flag(key) and 0 or 1
		render()
		saveConfig()
		if onChanged then
			onChanged(flag(key))
		end
	end)

	table.insert(switches, render)
	render()
	return render
end

local function makeSwatch(row, prefix, title)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Text = ""
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -18, 0.5, 0)
	button.Size = UDim2.fromOffset(36, 36)
	button.BackgroundColor3 = colorOf(prefix)
	button.ZIndex = 7
	button.Parent = row
	corner(button, 4)
	stroke(button, Color3.fromRGB(70, 70, 70), 2)

	swatches[prefix] = button

	button.MouseButton1Click:Connect(function()
		openPicker(prefix, title, false)
	end)

	return button
end

local function makeActionButton(row, text)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -18, 0.5, 0)
	button.Size = UDim2.fromOffset(146, 44)
	button.BackgroundColor3 = COLOR_ITEM_ACTIVE
	button.Font = Enum.Font.GothamBold
	button.TextSize = 19
	button.TextColor3 = COLOR_TEXT
	button.Text = text
	button.ZIndex = 7
	button.Parent = row
	corner(button, 8)
	stroke(button, Color3.fromRGB(58, 58, 58), 1)
	return button
end

local fillRow = mainRow(84)
makeRowTitle(fillRow, "Подсветка", "Заливка игроков сквозь стены")
makeSwitch(fillRow, "espFillOn", 68)
makeSwatch(fillRow, "espFill", "Цвет подсветки")

local boxRow = mainRow(84)
makeRowTitle(boxRow, "Бокс 2D", "Прямоугольная обводка игрока")
makeSwitch(boxRow, "espBoxOn", 68)
makeSwatch(boxRow, "espBox", "Цвет бокса")

local nameRow = mainRow(84)
makeRowTitle(nameRow, "Никнейм", "Имя игрока над боксом")
makeSwitch(nameRow, "espNameOn", 68)
makeSwatch(nameRow, "espName", "Цвет никнейма")

local distRow = mainRow(84)
makeRowTitle(distRow, "Дистанция", "Расстояние в метрах под боксом")
makeSwitch(distRow, "espDistOn", 68)
makeSwatch(distRow, "espDist", "Цвет дистанции")

mainDivider("MM2")

local mm2Row = mainRow(84)
makeRowTitle(mm2Row, "MM2 ESP", "Только те, кто в раунде: убийца красный")
makeSwitch(mm2Row, "mm2On", 18)

local gunRow = mainRow(84)
makeRowTitle(gunRow, "Подсветка пистолета", "Оранжевая, когда ган на полу")
makeSwitch(gunRow, "gunOn", 18)

local gunTpRow = mainRow(84)
makeRowTitle(gunTpRow, "Телепорт к пистолету", "Переносит к упавшему гану")
local gunTpButton = makeActionButton(gunTpRow, "Телепорт")

local speedRow = moreRow(84)
makeRowTitle(speedRow, "Скорость", "Ускоряет ходьбу персонажа")
makeSwitch(speedRow, "speedOn", 18)

local speedSliderRow = moreRow(92)
local refreshSpeed = buildSlider({
	parent = speedSliderRow,
	name = "Значение скорости",
	x = 18,
	y = 16,
	width = 0,
	fullWidth = true,
	zIndex = 7,
	min = 16,
	max = 200,
	get = function()
		return config.speedValue
	end,
	set = function(value)
		config.speedValue = math.floor(value + 0.5)
	end,
	format = function(value)
		return tostring(math.floor(value + 0.5))
	end,
	finished = saveConfig,
})

local hitboxRow = moreRow(84)
makeRowTitle(hitboxRow, "Хитбокс", "Увеличивает хитбокс игроков")
makeSwitch(hitboxRow, "hitboxOn", 68)
makeSwatch(hitboxRow, "hitbox", "Цвет хитбокса")

local hitboxSliderRow = moreRow(92)
local refreshHitbox = buildSlider({
	parent = hitboxSliderRow,
	name = "Размер хитбокса",
	x = 18,
	y = 16,
	width = 0,
	fullWidth = true,
	zIndex = 7,
	min = 1,
	max = 20,
	get = function()
		return config.hitboxSize
	end,
	set = function(value)
		config.hitboxSize = value
	end,
	format = function(value)
		return string.format("%.1f", value)
	end,
	finished = saveConfig,
})

local colorRow = settingsRow(84)
makeRowTitle(colorRow, "Цвет акцента", "Нажми на кружок и крути палитру")

local hexLabel = Instance.new("TextLabel")
hexLabel.BackgroundTransparency = 1
hexLabel.AnchorPoint = Vector2.new(1, 0.5)
hexLabel.Position = UDim2.new(1, -74, 0.5, 0)
hexLabel.Size = UDim2.fromOffset(130, 24)
hexLabel.Font = Enum.Font.GothamBold
hexLabel.TextSize = 18
hexLabel.TextXAlignment = Enum.TextXAlignment.Right
hexLabel.TextColor3 = COLOR_TEXT_DIM
hexLabel.Text = toHex(accentColor())
hexLabel.ZIndex = 7
hexLabel.Parent = colorRow

local colorButton = Instance.new("TextButton")
colorButton.AutoButtonColor = false
colorButton.Text = ""
colorButton.BorderSizePixel = 0
colorButton.AnchorPoint = Vector2.new(1, 0.5)
colorButton.Position = UDim2.new(1, -18, 0.5, 0)
colorButton.Size = UDim2.fromOffset(44, 44)
colorButton.BackgroundColor3 = accentColor()
colorButton.ZIndex = 7
colorButton.Parent = colorRow
circle(colorButton, 22)
stroke(colorButton, Color3.fromRGB(70, 70, 70), 2)
table.insert(accentFills, colorButton)
swatches["color"] = colorButton

local scaleRow = settingsRow(92)
local refreshScale = buildSlider({
	parent = scaleRow,
	name = "Размер меню",
	x = 18,
	y = 16,
	width = 0,
	fullWidth = true,
	zIndex = 7,
	min = 0.5,
	max = 1.6,
	get = function()
		return config.scale
	end,
	set = function(value)
		config.scale = value
		applyScale()
	end,
	format = function(value)
		return tostring(math.floor(value * 100 + 0.5)) .. "%"
	end,
	finished = saveConfig,
})

local pathRow = settingsRow(74)
makeRowTitle(
	pathRow,
	hasFiles and "Настройки сохраняются" or "Сохранение недоступно",
	hasFiles and ("/storage/emulated/0/Delta/Workspace/" .. CONFIG_PATH) or "Исполнитель не поддерживает работу с файлами"
)

local resetRow = settingsRow(74)
makeRowTitle(resetRow, "Сбросить настройки", "Вернуть все значения по умолчанию")

local resetButton = Instance.new("TextButton")
resetButton.AutoButtonColor = false
resetButton.BorderSizePixel = 0
resetButton.AnchorPoint = Vector2.new(1, 0.5)
resetButton.Position = UDim2.new(1, -18, 0.5, 0)
resetButton.Size = UDim2.fromOffset(118, 38)
resetButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 19
resetButton.TextColor3 = COLOR_TEXT
resetButton.Text = "Сбросить"
resetButton.ZIndex = 7
resetButton.Parent = resetRow
corner(resetButton, 8)
stroke(resetButton, Color3.fromRGB(58, 58, 58), 1)

local overlay = Instance.new("TextButton")
overlay.Name = "PickerOverlay"
overlay.AutoButtonColor = false
overlay.Text = ""
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.5
overlay.BorderSizePixel = 0
overlay.Size = UDim2.fromScale(1, 1)
overlay.Visible = false
overlay.ZIndex = 40
overlay.Parent = window

local picker = Instance.new("Frame")
picker.BackgroundColor3 = COLOR_PANEL
picker.BorderSizePixel = 0
picker.AnchorPoint = Vector2.new(0.5, 0.5)
picker.Position = UDim2.fromScale(0.5, 0.5)
picker.Size = UDim2.fromOffset(264, 412)
picker.ZIndex = 41
picker.Parent = overlay
corner(picker, 12)
stroke(picker, Color3.fromRGB(52, 52, 52), 1)

local pickerTitle = Instance.new("TextLabel")
pickerTitle.BackgroundTransparency = 1
pickerTitle.Position = UDim2.fromOffset(18, 14)
pickerTitle.Size = UDim2.new(1, -120, 0, 22)
pickerTitle.Font = Enum.Font.GothamBold
pickerTitle.TextSize = 20
pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
pickerTitle.TextTruncate = Enum.TextTruncate.AtEnd
pickerTitle.TextColor3 = COLOR_TEXT
pickerTitle.Text = "Палитра"
pickerTitle.ZIndex = 42
pickerTitle.Parent = picker

local pickerHex = Instance.new("TextLabel")
pickerHex.BackgroundTransparency = 1
pickerHex.AnchorPoint = Vector2.new(1, 0)
pickerHex.Position = UDim2.new(1, -18, 0, 14)
pickerHex.Size = UDim2.fromOffset(96, 22)
pickerHex.Font = Enum.Font.GothamBold
pickerHex.TextSize = 17
pickerHex.TextXAlignment = Enum.TextXAlignment.Right
pickerHex.TextColor3 = COLOR_TEXT_DIM
pickerHex.Text = toHex(accentColor())
pickerHex.ZIndex = 42
pickerHex.Parent = picker

local ring = Instance.new("Frame")
ring.BackgroundTransparency = 1
ring.AnchorPoint = Vector2.new(0.5, 0)
ring.Position = UDim2.new(0.5, 0, 0, 46)
ring.Size = UDim2.fromOffset(RING_SIZE, RING_SIZE)
ring.ZIndex = 42
ring.Parent = picker

local ringCenter = RING_SIZE / 2

for index = 1, RING_SEGMENTS do
	local angle = (index - 1) * (2 * math.pi / RING_SEGMENTS)
	local segment = Instance.new("Frame")
	segment.BorderSizePixel = 0
	segment.AnchorPoint = Vector2.new(0.5, 0.5)
	segment.Size = UDim2.fromOffset(math.ceil(2 * math.pi * RING_RADIUS / RING_SEGMENTS) + 2, RING_THICKNESS)
	segment.Position = UDim2.fromOffset(
		math.floor(ringCenter + RING_RADIUS * math.cos(angle) + 0.5),
		math.floor(ringCenter + RING_RADIUS * math.sin(angle) + 0.5)
	)
	segment.Rotation = math.deg(angle) + 90
	segment.BackgroundColor3 = Color3.fromHSV((index - 1) / RING_SEGMENTS, 1, 1)
	segment.ZIndex = 42
	segment.Parent = ring
end

local ringKnob = Instance.new("Frame")
ringKnob.BorderSizePixel = 0
ringKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ringKnob.Size = UDim2.fromOffset(22, 22)
ringKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ringKnob.ZIndex = 44
ringKnob.Parent = ring
circle(ringKnob, 11)
stroke(ringKnob, Color3.fromRGB(20, 20, 20), 3)

local preview = Instance.new("Frame")
preview.BorderSizePixel = 0
preview.AnchorPoint = Vector2.new(0.5, 0.5)
preview.Position = UDim2.fromScale(0.5, 0.5)
preview.Size = UDim2.fromOffset(92, 92)
preview.BackgroundColor3 = accentColor()
preview.ZIndex = 43
preview.Parent = ring
circle(preview, 46)
stroke(preview, Color3.fromRGB(20, 20, 20), 4)

local transparencyHolder = Instance.new("Frame")
transparencyHolder.BackgroundTransparency = 1
transparencyHolder.Position = UDim2.fromOffset(18, 300)
transparencyHolder.Size = UDim2.fromOffset(228, 50)
transparencyHolder.ZIndex = 42
transparencyHolder.Parent = picker

local pickerHue = 0
local pickerSat = 0
local pickerPrefix = "color"
local snapshot = { r = 255, g = 255, b = 255, transparency = 0 }

local renderSaturation
local renderTransparency

local function pickerColor()
	return Color3.fromHSV(pickerHue, pickerSat, 1)
end

local function pushPickerColor()
	local color = pickerColor()
	setColorOf(pickerPrefix, color)
	preview.BackgroundColor3 = color
	pickerHex.Text = toHex(color)
	if swatches[pickerPrefix] then
		swatches[pickerPrefix].BackgroundColor3 = color
	end
	if pickerPrefix == "color" then
		hexLabel.Text = toHex(color)
		applySettings()
	end
	ringKnob.Position = UDim2.fromOffset(
		math.floor(ringCenter + RING_RADIUS * math.cos(pickerHue * 2 * math.pi) + 0.5),
		math.floor(ringCenter + RING_RADIUS * math.sin(pickerHue * 2 * math.pi) + 0.5)
	)
	if renderSaturation then
		renderSaturation()
	end
end

local function ringUpdate(x, y)
	local absoluteCenterX = ring.AbsolutePosition.X + ring.AbsoluteSize.X / 2
	local absoluteCenterY = ring.AbsolutePosition.Y + ring.AbsoluteSize.Y / 2
	local dx = x - absoluteCenterX
	local dy = y - absoluteCenterY
	if dx == 0 and dy == 0 then
		return
	end
	local angle = math.atan2(dy, dx)
	if angle < 0 then
		angle = angle + 2 * math.pi
	end
	pickerHue = angle / (2 * math.pi)
	if pickerSat <= 0.001 then
		pickerSat = 1
	end
	pushPickerColor()
end

local ringHitbox = Instance.new("TextButton")
ringHitbox.AutoButtonColor = false
ringHitbox.Text = ""
ringHitbox.BackgroundTransparency = 1
ringHitbox.Size = UDim2.fromScale(1, 1)
ringHitbox.ZIndex = 45
ringHitbox.Parent = ring

ringHitbox.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local absoluteCenterX = ring.AbsolutePosition.X + ring.AbsoluteSize.X / 2
	local absoluteCenterY = ring.AbsolutePosition.Y + ring.AbsoluteSize.Y / 2
	local dx = input.Position.X - absoluteCenterX
	local dy = input.Position.Y - absoluteCenterY
	local distance = math.sqrt(dx * dx + dy * dy)
	local innerLimit = (RING_RADIUS - RING_THICKNESS) * (ring.AbsoluteSize.X / RING_SIZE)
	if distance < innerLimit then
		return
	end
	if activeDrag == nil then
		activeDrag = { update = ringUpdate, input = input }
		ringUpdate(input.Position.X, input.Position.Y)
	end
end)

renderSaturation = buildSlider({
	parent = picker,
	name = "Насыщенность",
	x = 18,
	y = 244,
	width = 228,
	min = 0,
	max = 1,
	zIndex = 42,
	gradient = "saturation",
	gradientColor = function()
		return Color3.fromHSV(pickerHue, 1, 1)
	end,
	get = function()
		return pickerSat
	end,
	set = function(value)
		pickerSat = value
		pushPickerColor()
	end,
	format = function(value)
		return tostring(math.floor(value * 100 + 0.5)) .. "%"
	end,
})

renderTransparency = buildSlider({
	parent = transparencyHolder,
	name = "Прозрачность",
	x = 0,
	y = 0,
	width = 228,
	min = 0,
	max = 0.7,
	zIndex = 42,
	get = function()
		return config.transparency
	end,
	set = function(value)
		config.transparency = value
		applySettings()
	end,
	format = function(value)
		return tostring(math.floor(value * 100 + 0.5)) .. "%"
	end,
	finished = saveConfig,
})

local applyButton = Instance.new("TextButton")
applyButton.AutoButtonColor = false
applyButton.BorderSizePixel = 0
applyButton.Position = UDim2.fromOffset(18, 356)
applyButton.Size = UDim2.fromOffset(110, 38)
applyButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 19
applyButton.TextColor3 = COLOR_TEXT
applyButton.Text = "Применить"
applyButton.ZIndex = 42
applyButton.Parent = picker
corner(applyButton, 8)
local applyStroke = stroke(applyButton, accentColor(), 2)
table.insert(accentStrokes, applyStroke)

local cancelButton = Instance.new("TextButton")
cancelButton.AutoButtonColor = false
cancelButton.BorderSizePixel = 0
cancelButton.Position = UDim2.fromOffset(136, 356)
cancelButton.Size = UDim2.fromOffset(110, 38)
cancelButton.BackgroundColor3 = COLOR_ITEM
cancelButton.Font = Enum.Font.GothamBold
cancelButton.TextSize = 19
cancelButton.TextColor3 = COLOR_TEXT_DIM
cancelButton.Text = "Сбросить"
cancelButton.ZIndex = 42
cancelButton.Parent = picker
corner(cancelButton, 8)
stroke(cancelButton, Color3.fromRGB(58, 58, 58), 1)

local function syncPickerFromConfig()
	local hue, saturation = colorOf(pickerPrefix):ToHSV()
	pickerHue = hue
	pickerSat = saturation
	pushPickerColor()
	renderSaturation()
	renderTransparency()
end

function openPicker(prefix, title, showTransparency)
	pickerPrefix = prefix
	pickerTitle.Text = title
	transparencyHolder.Visible = showTransparency and true or false
	if showTransparency then
		picker.Size = UDim2.fromOffset(264, 412)
		applyButton.Position = UDim2.fromOffset(18, 356)
		cancelButton.Position = UDim2.fromOffset(136, 356)
	else
		picker.Size = UDim2.fromOffset(264, 356)
		applyButton.Position = UDim2.fromOffset(18, 300)
		cancelButton.Position = UDim2.fromOffset(136, 300)
	end
	snapshot.r = config[prefix .. "R"]
	snapshot.g = config[prefix .. "G"]
	snapshot.b = config[prefix .. "B"]
	snapshot.transparency = config.transparency
	syncPickerFromConfig()
	overlay.Visible = true
end

local function closePicker(revert)
	if not overlay.Visible then
		return
	end
	if revert then
		config[pickerPrefix .. "R"] = snapshot.r
		config[pickerPrefix .. "G"] = snapshot.g
		config[pickerPrefix .. "B"] = snapshot.b
		config.transparency = snapshot.transparency
		if swatches[pickerPrefix] then
			swatches[pickerPrefix].BackgroundColor3 = colorOf(pickerPrefix)
		end
		hexLabel.Text = toHex(accentColor())
		applySettings()
	end
	overlay.Visible = false
end

colorButton.MouseButton1Click:Connect(function()
	openPicker("color", "Цвет акцента", true)
end)

applyButton.MouseButton1Click:Connect(function()
	saveConfig()
	closePicker(false)
end)

cancelButton.MouseButton1Click:Connect(function()
	config[pickerPrefix .. "R"] = DEFAULTS[pickerPrefix .. "R"]
	config[pickerPrefix .. "G"] = DEFAULTS[pickerPrefix .. "G"]
	config[pickerPrefix .. "B"] = DEFAULTS[pickerPrefix .. "B"]
	if transparencyHolder.Visible then
		config.transparency = DEFAULTS.transparency
	end
	if swatches[pickerPrefix] then
		swatches[pickerPrefix].BackgroundColor3 = colorOf(pickerPrefix)
	end
	hexLabel.Text = toHex(accentColor())
	applySettings()
	syncPickerFromConfig()
end)

overlay.MouseButton1Click:Connect(function()
	closePicker(true)
end)

makeNavButton("Main", ICON_HOME, 1)
makeNavButton("More", ICON_MORE, 2)
makeNavButton("Settings", ICON_SETTINGS, 3)

selectPage("Main")

local profile = Instance.new("Frame")
profile.BackgroundTransparency = 1
profile.AnchorPoint = Vector2.new(0, 1)
profile.Position = UDim2.new(0, 14, 1, -16)
profile.Size = UDim2.new(1, -28, 0, 54)
profile.ZIndex = 6
profile.Parent = sidebar

local avatarHolder = Instance.new("Frame")
avatarHolder.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
avatarHolder.BorderSizePixel = 0
avatarHolder.AnchorPoint = Vector2.new(0, 0.5)
avatarHolder.Position = UDim2.new(0, 0, 0.5, 0)
avatarHolder.Size = UDim2.fromOffset(50, 50)
avatarHolder.ClipsDescendants = true
avatarHolder.ZIndex = 6
avatarHolder.Parent = profile
circle(avatarHolder, 25)

local avatar = Instance.new("ImageLabel")
avatar.BackgroundTransparency = 1
avatar.Size = UDim2.fromScale(1, 1)
avatar.ScaleType = Enum.ScaleType.Crop
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.ZIndex = 6
avatar.Parent = avatarHolder
circle(avatar, 25)

task.spawn(function()
	local ok, thumbnail = pcall(function()
		local image, isReady = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		if isReady then
			return image
		end
		return nil
	end)
	if ok and thumbnail then
		avatar.Image = thumbnail
	end
end)

local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Position = UDim2.fromOffset(62, 6)
nameLabel.Size = UDim2.new(1, -68, 0, 22)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 20
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.TextColor3 = COLOR_TEXT
nameLabel.Text = player.Name
nameLabel.ZIndex = 6
nameLabel.Parent = profile

local displayLabel = Instance.new("TextLabel")
displayLabel.BackgroundTransparency = 1
displayLabel.Position = UDim2.fromOffset(62, 29)
displayLabel.Size = UDim2.new(1, -68, 0, 20)
displayLabel.Font = Enum.Font.Gotham
displayLabel.TextSize = 18
displayLabel.TextXAlignment = Enum.TextXAlignment.Left
displayLabel.TextTruncate = Enum.TextTruncate.AtEnd
displayLabel.TextColor3 = COLOR_TEXT_DIM
displayLabel.Text = player.DisplayName
displayLabel.ZIndex = 6
displayLabel.Parent = profile

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.AutoButtonColor = false
toggle.BackgroundColor3 = COLOR_HEADER
toggle.BorderSizePixel = 0
toggle.Size = UDim2.fromOffset(40, 40)
toggle.Position = UDim2.new(0, 14, 0, 90)
toggle.Text = ""
toggle.Active = true
toggle.Draggable = true
toggle.ZIndex = 10
toggle.Parent = screenGui
circle(toggle, 20)

local toggleStroke = stroke(toggle, accentColor(), 1)
table.insert(accentStrokes, toggleStroke)

makeIcon(toggle, ICON_BOLT_TOGGLE, 21, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)).ZIndex = 11

local function setWindowVisible(visible)
	if not visible then
		closePicker(true)
	end
	window.Visible = visible
end

toggle.MouseButton1Click:Connect(function()
	setWindowVisible(not window.Visible)
end)

closeButton.MouseButton1Click:Connect(function()
	setWindowVisible(false)
end)

local function refreshAll()
	refreshScale()
	refreshSpeed()
	refreshHitbox()
	hexLabel.Text = toHex(accentColor())
	for prefix, button in pairs(swatches) do
		button.BackgroundColor3 = colorOf(prefix)
	end
	syncPickerFromConfig()
	applySettings()
	applyScale()
end

resetButton.MouseButton1Click:Connect(function()
	for key, value in pairs(DEFAULTS) do
		config[key] = value
	end
	pickerPrefix = "color"
	refreshAll()
	saveConfig()
end)

refreshAll()

local camera = workspace.CurrentCamera
if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
		applyScale()
	end
end)

local espObjects = {}
local hitboxTargets = {}

local function createEspObject(target)
	local box = Instance.new("Frame")
	box.Name = "Box"
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Visible = false
	box.ZIndex = 1
	box.Parent = espHolder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 1.5
	boxStroke.Color = Color3.fromRGB(255, 255, 255)
	boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	boxStroke.Parent = box

	local nickLabel = Instance.new("TextLabel")
	nickLabel.BackgroundTransparency = 1
	nickLabel.Font = Enum.Font.GothamBold
	nickLabel.TextSize = 17
	nickLabel.TextStrokeTransparency = 0.25
	nickLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nickLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nickLabel.Text = target.DisplayName
	nickLabel.Visible = false
	nickLabel.ZIndex = 2
	nickLabel.Parent = espHolder

	local distLabel = Instance.new("TextLabel")
	distLabel.BackgroundTransparency = 1
	distLabel.Font = Enum.Font.GothamBold
	distLabel.TextSize = 17
	distLabel.TextStrokeTransparency = 0.25
	distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	distLabel.Text = ""
	distLabel.Visible = false
	distLabel.ZIndex = 2
	distLabel.Parent = espHolder

	local entry = {
		box = box,
		boxStroke = boxStroke,
		nick = nickLabel,
		distance = distLabel,
		highlight = nil,
	}

	espObjects[target] = entry
	return entry
end

local function clearHighlight(entry)
	if entry.highlight then
		entry.highlight:Destroy()
		entry.highlight = nil
	end
end

local function hideEntry(entry)
	entry.box.Visible = false
	entry.nick.Visible = false
	entry.distance.Visible = false
end

local function removeEspObject(target)
	local entry = espObjects[target]
	if not entry then
		return
	end
	clearHighlight(entry)
	entry.box:Destroy()
	entry.nick:Destroy()
	entry.distance:Destroy()
	espObjects[target] = nil
end

Players.PlayerRemoving:Connect(removeEspObject)

local function nameHas(lowered, word)
	return string.find(lowered, word, 1, true) ~= nil
end

local function isKnifeName(name)
	local lowered = string.lower(name)
	return nameHas(lowered, "knife")
		or nameHas(lowered, "blade")
		or nameHas(lowered, "sword")
		or nameHas(lowered, "scythe")
		or nameHas(lowered, "axe")
end

local function isGunName(name)
	local lowered = string.lower(name)
	if nameHas(lowered, "drop") then
		return false
	end
	return nameHas(lowered, "gun")
		or nameHas(lowered, "revolver")
		or nameHas(lowered, "pistol")
		or nameHas(lowered, "shot")
		or nameHas(lowered, "blaster")
end

local KNIFE_NAMES = isKnifeName
local GUN_NAMES = isGunName
local ROUND_RADIUS = 1200
local SCAN_INTERVAL = 0.2
local GUN_INTERVAL = 1
local LOBBY_INTERVAL = 5
local BOX_TOP = Vector3.new(0, 3.2, 0)
local BOX_BOTTOM = Vector3.new(0, 3.4, 0)
local DEFAULT_ROOT_SIZE = Vector3.new(2, 2, 1)

local function setVisible(object, value)
	if object.Visible ~= value then
		object.Visible = value
	end
end

local function containerHasTool(container, matches)
	if not container then
		return false
	end
	local children = container:GetChildren()
	for i = 1, #children do
		local child = children[i]
		if child:IsA("Tool") or child:IsA("Model") then
			if matches(child.Name) then
				return true
			end
		end
	end
	return false
end

local function findTool(target, character, matches)
	if containerHasTool(character, matches) then
		return true
	end
	local ok, backpack = pcall(function()
		return target:FindFirstChildOfClass("Backpack")
	end)
	if ok and containerHasTool(backpack, matches) then
		return true
	end
	local gear = target:FindFirstChild("StarterGear")
	if containerHasTool(gear, matches) then
		return true
	end
	return false
end

local lobbyCFrame = nil
local lobbySize = nil
local lobbyClock = 0
local gunClock = 0
local scanClock = 0
local murdererPosition = nil

local function refreshLobby()
	lobbyCFrame = nil
	lobbySize = nil
	local candidate = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("lobby")
	if candidate and candidate:IsA("Model") then
		local ok, boundsCFrame, boundsSize = pcall(function()
			return candidate:GetBoundingBox()
		end)
		if ok and boundsCFrame and boundsSize then
			lobbyCFrame = boundsCFrame
			lobbySize = boundsSize
		end
	end
end

local function inLobby(position)
	if not lobbyCFrame or not lobbySize then
		return false
	end
	local relative = lobbyCFrame:PointToObjectSpace(position)
	return math.abs(relative.X) <= lobbySize.X * 0.5 + 15
		and math.abs(relative.Y) <= lobbySize.Y * 0.5 + 40
		and math.abs(relative.Z) <= lobbySize.Z * 0.5 + 15
end

local function getRole(target, character, root)
	if not murdererPosition then
		return nil
	end
	if findTool(target, character, KNIFE_NAMES) then
		return "murderer"
	end
	local position = root.Position
	if inLobby(position) then
		return nil
	end
	if (position - murdererPosition).Magnitude > ROUND_RADIUS then
		return nil
	end
	if findTool(target, character, GUN_NAMES) then
		return "sheriff"
	end
	return "innocent"
end

local function roleColor(role)
	if role == "murderer" then
		return COLOR_MURDERER
	end
	if role == "sheriff" then
		return COLOR_SHERIFF
	end
	return COLOR_INNOCENT
end

local gunHandle = nil
local gunHighlight = nil

local function clearGunHighlight()
	if gunHighlight then
		gunHighlight:Destroy()
		gunHighlight = nil
	end
end

local function gunValid()
	local handle = gunHandle
	if not handle or not handle.Parent then
		return false
	end
	local owner = handle.Parent
	if owner:IsA("Tool") then
		return owner.Parent == workspace
	end
	return owner == workspace
end

local function gunPartOf(instance)
	if instance:IsA("BasePart") then
		return instance
	end
	if instance:IsA("Tool") or instance:IsA("Model") then
		local handle = instance:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			return handle
		end
		if instance:IsA("Model") and instance.PrimaryPart then
			return instance.PrimaryPart
		end
		return instance:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function looksLikeDroppedGun(name)
	local lowered = string.lower(name)
	return nameHas(lowered, "gun")
		or nameHas(lowered, "revolver")
		or nameHas(lowered, "pistol")
end

local deepGunClock = 0

local function scanGun()
	local children = workspace:GetChildren()
	for i = 1, #children do
		local instance = children[i]
		if looksLikeDroppedGun(instance.Name) then
			local part = gunPartOf(instance)
			if part then
				return part
			end
		end
	end

	local now = os.clock()
	if now - deepGunClock < 4 then
		return nil
	end
	deepGunClock = now

	local names = { "GunDrop", "GunDropPart", "Gun" }
	for i = 1, #names do
		local found = workspace:FindFirstChild(names[i], true)
		if found and not Players:GetPlayerFromCharacter(found.Parent) then
			local part = gunPartOf(found)
			if part then
				return part
			end
		end
	end
	return nil
end

local function updateGun()
	if not flag("gunOn") then
		clearGunHighlight()
		return
	end
	if not gunValid() then
		gunHandle = scanGun()
	end
	if not gunHandle then
		clearGunHighlight()
		return
	end
	if not gunHighlight or gunHighlight.Adornee ~= gunHandle then
		clearGunHighlight()
		local highlight = Instance.new("Highlight")
		highlight.Name = "SfeGunHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.35
		highlight.OutlineTransparency = 0
		highlight.FillColor = COLOR_GUN
		highlight.OutlineColor = COLOR_GUN
		highlight.Adornee = gunHandle
		highlight.Parent = espHolder
		gunHighlight = highlight
	end
end

gunTpButton.MouseButton1Click:Connect(function()
	if not gunValid() then
		gunHandle = scanGun()
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if gunHandle and gunHandle.Parent and root then
		root.CFrame = CFrame.new(gunHandle.Position + Vector3.new(0, 3, 0))
	end
end)

local hitboxData = setmetatable({}, { __mode = "k" })

local function destroyHitbox(character)
	local data = hitboxData[character]
	if data then
		hitboxData[character] = nil
		if data.part then
			data.part:Destroy()
		end
	end
end

local function applyHitbox(character, root, on, key, size, color)
	local data = hitboxData[character]

	if not on then
		if data then
			destroyHitbox(character)
		end
		return nil
	end

	if data and (not data.part or data.part.Parent ~= character) then
		destroyHitbox(character)
		data = nil
	end

	if not data then
		local part = Instance.new("Part")
		part.Name = "SfeHitbox"
		part.Shape = Enum.PartType.Block
		part.Size = size
		part.Color = color
		part.Material = Enum.Material.ForceField
		part.Transparency = 0.7
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = true
		part.CanQuery = true
		part.Massless = true
		part.CastShadow = false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.CFrame = root.CFrame
		part.Parent = character
		data = { part = part, key = key, root = root }
		hitboxData[character] = data
		return data
	end

	if data.key ~= key then
		data.key = key
		data.part.Size = size
		data.part.Color = color
	end
	data.root = root
	return data
end

local function updateSpeed()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if flag("speedOn") then
		if humanoid.WalkSpeed ~= config.speedValue then
			humanoid.WalkSpeed = config.speedValue
		end
	elseif humanoid.WalkSpeed ~= 16 and humanoid.WalkSpeed == config.speedValue then
		humanoid.WalkSpeed = 16
	end
end

local tracked = {}
local trackedCount = 0
local localRoot = nil
local fillOn = false
local boxOn = false
local nickOn = false
local distOn = false
local mm2On = false
local anyOn = false

local function hideFast(entry)
	setVisible(entry.box, false)
	setVisible(entry.nick, false)
	setVisible(entry.distance, false)
end

local function ensureHighlight(entry, character, color)
	local highlight = entry.highlight
	if not highlight or highlight.Adornee ~= character then
		clearHighlight(entry)
		highlight = Instance.new("Highlight")
		highlight.Name = "SfeHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.55
		highlight.OutlineTransparency = 0
		highlight.Adornee = character
		highlight.Parent = espHolder
		entry.highlight = highlight
		entry.fillColor = nil
	end
	if entry.fillColor ~= color then
		entry.fillColor = color
		highlight.FillColor = color
		highlight.OutlineColor = color
	end
end

local hitboxList = {}
local hitboxCount = 0

local function refreshState()
	fillOn = flag("espFillOn")
	boxOn = flag("espBoxOn")
	nickOn = flag("espNameOn")
	distOn = flag("espDistOn")
	mm2On = flag("mm2On")
	anyOn = fillOn or boxOn or nickOn or distOn or mm2On

	local localCharacter = player.Character
	localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") or nil

	local hitboxOn = flag("hitboxOn")
	local hitboxKey = nil
	local hitboxSize = nil
	local hitboxColor = nil
	if hitboxOn then
		local value = math.floor(config.hitboxSize + 0.5)
		hitboxKey = value
			.. "|"
			.. math.floor(config.hitboxR)
			.. "|"
			.. math.floor(config.hitboxG)
			.. "|"
			.. math.floor(config.hitboxB)
		hitboxSize = Vector3.new(value, value, value)
		hitboxColor = colorOf("hitbox")
	end

	local players = Players:GetPlayers()

	murdererPosition = nil
	if mm2On then
		for i = 1, #players do
			local target = players[i]
			local character = target.Character
			if character and findTool(target, character, KNIFE_NAMES) then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root then
					murdererPosition = root.Position
					break
				end
			end
		end
	end

	local defaultFill = colorOf("espFill")
	local defaultBox = colorOf("espBox")
	local defaultName = colorOf("espName")
	local defaultDist = colorOf("espDist")

	trackedCount = 0
	hitboxCount = 0

	for i = 1, #players do
		local target = players[i]
		if target ~= player then
			local character = target.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if character and root then
				local ok, data = pcall(applyHitbox, character, root, hitboxOn, hitboxKey, hitboxSize, hitboxColor)
				if ok and data then
					hitboxCount = hitboxCount + 1
					hitboxList[hitboxCount] = data
				end
			end

			local entry = espObjects[target]
			local role = nil
			local show = false

			if anyOn and root and humanoid and humanoid.Health > 0 then
				if mm2On then
					role = getRole(target, character, root)
					show = role ~= nil
				else
					show = true
				end
			end

			if show then
				entry = entry or createEspObject(target)
				local base = role and roleColor(role) or nil
				entry.root = root
				entry.boxColor = base or defaultBox
				entry.nameColor = base or defaultName
				entry.distColor = base or defaultDist

				if fillOn or mm2On then
					ensureHighlight(entry, character, base or defaultFill)
				elseif entry.highlight then
					clearHighlight(entry)
					entry.fillColor = nil
				end

				if nickOn then
					local nickText = target.DisplayName
					if entry.nickText ~= nickText then
						entry.nickText = nickText
						entry.nick.Text = nickText
					end
				end

				trackedCount = trackedCount + 1
				tracked[trackedCount] = entry
			elseif entry then
				entry.root = nil
				hideFast(entry)
				if entry.highlight then
					clearHighlight(entry)
					entry.fillColor = nil
				end
			end
		end
	end

	for i = trackedCount + 1, #tracked do
		tracked[i] = nil
	end

	for i = hitboxCount + 1, #hitboxList do
		hitboxList[i] = nil
	end

	setVisible(espHolder, anyOn or flag("gunOn"))
end

RunService.RenderStepped:Connect(function(delta)
	for i = 1, hitboxCount do
		local data = hitboxList[i]
		local part = data.part
		local root = data.root
		if part.Parent and root.Parent then
			part.CFrame = root.CFrame
		end
	end

	local currentCamera = workspace.CurrentCamera
	if not currentCamera then
		return
	end

	scanClock = scanClock + delta
	if scanClock >= SCAN_INTERVAL then
		scanClock = 0
		refreshState()
		updateSpeed()
	end

	if mm2On then
		lobbyClock = lobbyClock + delta
		if lobbyCFrame == nil or lobbyClock >= LOBBY_INTERVAL then
			lobbyClock = 0
			refreshLobby()
		end
	end

	gunClock = gunClock + delta
	if gunClock >= GUN_INTERVAL then
		gunClock = 0
		updateGun()
	end

	if trackedCount == 0 then
		return
	end

	local origin = currentCamera.CFrame.Position
	if localRoot and localRoot.Parent then
		origin = localRoot.Position
	end

	for i = 1, trackedCount do
		local entry = tracked[i]
		local root = entry.root
		if root and root.Parent then
			local position = root.Position
			local top, onScreen = currentCamera:WorldToViewportPoint(position + BOX_TOP)
			if onScreen then
				local bottom = currentCamera:WorldToViewportPoint(position - BOX_BOTTOM)
				local height = math.abs(top.Y - bottom.Y)
				local width = height * 0.55
				local left = math.floor((top.X + bottom.X) * 0.5 - width * 0.5)
				local topY = math.floor(top.Y < bottom.Y and top.Y or bottom.Y)
				local boxWidth = math.floor(width)
				local boxHeight = math.floor(height)

				setVisible(entry.box, boxOn)
				if boxOn then
					entry.box.Position = UDim2.fromOffset(left, topY)
					entry.box.Size = UDim2.fromOffset(boxWidth, boxHeight)
					if entry.boxApplied ~= entry.boxColor then
						entry.boxApplied = entry.boxColor
						entry.boxStroke.Color = entry.boxColor
					end
				end

				setVisible(entry.nick, nickOn)
				if nickOn then
					entry.nick.Position = UDim2.fromOffset(left, topY - 20)
					entry.nick.Size = UDim2.fromOffset(boxWidth, 18)
					if entry.nameApplied ~= entry.nameColor then
						entry.nameApplied = entry.nameColor
						entry.nick.TextColor3 = entry.nameColor
					end
				end

				setVisible(entry.distance, distOn)
				if distOn then
					entry.distance.Position = UDim2.fromOffset(left, topY + boxHeight + 2)
					entry.distance.Size = UDim2.fromOffset(boxWidth, 18)
					if entry.distApplied ~= entry.distColor then
						entry.distApplied = entry.distColor
						entry.distance.TextColor3 = entry.distColor
					end
					local studs = math.floor((position - origin).Magnitude + 0.5)
					if entry.studs ~= studs then
						entry.studs = studs
						entry.distance.Text = studs .. " м"
					end
				end
			else
				hideFast(entry)
			end
		else
			hideFast(entry)
		end
	end
end)

local dragging = false
local dragInput
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragInput = input
		dragStart = input.Position
		startPosition = window.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		window.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		setWindowVisible(not window.Visible)
	end
end)
