local Players = game:GetService("Players")
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
local COLOR_CARD = Color3.fromRGB(46, 46, 46)
local COLOR_ITEM = Color3.fromRGB(26, 26, 26)
local COLOR_ITEM_ACTIVE = Color3.fromRGB(38, 38, 38)
local COLOR_STROKE = Color3.fromRGB(48, 48, 48)
local COLOR_TEXT = Color3.fromRGB(240, 240, 240)
local COLOR_TEXT_DIM = Color3.fromRGB(165, 165, 165)
local COLOR_TRACK = Color3.fromRGB(58, 58, 58)

local RING_SIZE = 226
local RING_RADIUS = 96
local RING_THICKNESS = 24
local RING_SEGMENTS = 120

local DEFAULTS = {
	colorR = 255,
	colorG = 255,
	colorB = 255,
	transparency = 0,
	scale = 1.1,
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
	config.colorR = math.clamp(config.colorR, 0, 255)
	config.colorG = math.clamp(config.colorG, 0, 255)
	config.colorB = math.clamp(config.colorB, 0, 255)
	config.transparency = math.clamp(config.transparency, 0, 0.7)
	config.scale = math.clamp(config.scale, 0.5, 1.6)
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

local function accentColor()
	return Color3.fromRGB(config.colorR, config.colorG, config.colorB)
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

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.fromScale(0.5, 0.5)
window.Size = UDim2.fromOffset(BASE_WIDTH, BASE_HEIGHT)
window.BackgroundColor3 = COLOR_WINDOW
window.BorderSizePixel = 0
window.Active = true
window.Parent = screenGui
corner(window, 14)
stroke(window, Color3.fromRGB(38, 38, 38), 1)
table.insert(panelParts, window)

local uiScale = Instance.new("UIScale")
uiScale.Parent = window

local function applyScale()
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local widthRatio = isMobile and 0.58 or 0.66
	local heightRatio = isMobile and 0.62 or 0.76
	local base = math.min(viewport.X * widthRatio / BASE_WIDTH, viewport.Y * heightRatio / BASE_HEIGHT)
	uiScale.Scale = math.clamp(base * config.scale, 0.15, 1.6)
end

applyScale()

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 62)
header.BackgroundColor3 = COLOR_HEADER
header.BorderSizePixel = 0
header.Parent = window
corner(header, 14)
table.insert(panelParts, header)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 24)
headerFix.Position = UDim2.new(0, 0, 1, -24)
headerFix.BackgroundColor3 = COLOR_HEADER
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 0
headerFix.Parent = header
table.insert(panelParts, headerFix)

makeIcon(header, ICON_BOLT, 28, UDim2.fromOffset(16, 17))

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(54, 11)
titleLabel.Size = UDim2.fromOffset(760, 24)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 19
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = COLOR_TEXT
titleLabel.RichText = true
titleLabel.Text = TITLE .. " <font color=\"rgb(140,140,140)\">\u{2022}</font> " .. AUTHOR
titleLabel.Parent = header

local versionLabel = Instance.new("TextLabel")
versionLabel.BackgroundTransparency = 1
versionLabel.Position = UDim2.fromOffset(54, 35)
versionLabel.Size = UDim2.fromOffset(220, 18)
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 14
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.TextColor3 = COLOR_TEXT_DIM
versionLabel.Text = VERSION
versionLabel.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.BackgroundTransparency = 1
closeButton.AutoButtonColor = false
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -14, 0.5, 0)
closeButton.Size = UDim2.fromOffset(38, 38)
closeButton.Text = ""
closeButton.Parent = header

makeIcon(closeButton, ICON_CLOSE, 19, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 62)
body.Size = UDim2.new(1, 0, 1, -62)
body.Parent = window

local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromOffset(12, 8)
sidebar.Size = UDim2.new(0, 212, 1, -20)
sidebar.Parent = body
corner(sidebar, 12)
stroke(sidebar, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, sidebar)

local navHolder = Instance.new("Frame")
navHolder.BackgroundTransparency = 1
navHolder.Position = UDim2.fromOffset(12, 12)
navHolder.Size = UDim2.new(1, -24, 0, 200)
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
	for _, part in ipairs(panelParts) do
		part.BackgroundTransparency = config.transparency
	end
end

local function makeCard(parent, size, position)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = COLOR_CARD
	card.BorderSizePixel = 0
	card.Size = size
	card.Position = position
	card.Parent = parent
	corner(card, 10)
	return card
end

local function makePage(name, blank)
	local page = Instance.new("Frame")
	page.Name = name
	page.BackgroundTransparency = 1
	page.Size = UDim2.fromScale(1, 1)
	page.Visible = false
	page.Parent = content

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 18)
	pad.PaddingBottom = UDim.new(0, 18)
	pad.PaddingLeft = UDim.new(0, 18)
	pad.PaddingRight = UDim.new(0, 18)
	pad.Parent = page

	if not blank then
		makeCard(page, UDim2.new(1, 0, 0.32, 0), UDim2.fromScale(0, 0))
		makeCard(page, UDim2.new(0.49, 0, 0.24, 0), UDim2.new(0, 0, 0.36, 0))
		makeCard(page, UDim2.new(0.49, 0, 0.24, 0), UDim2.new(0.51, 0, 0.36, 0))
		makeCard(page, UDim2.new(1, 0, 0.36, 0), UDim2.new(0, 0, 0.64, 0))
	end

	pages[name] = page
	return page
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
	button.Parent = navHolder
	corner(button, 10)
	navStrokes[name] = stroke(button, Color3.fromRGB(42, 42, 42), 1)

	makeIcon(button, imageId, 23, UDim2.new(0, 17, 0.5, 0), Vector2.new(0, 0.5))

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(54, 0)
	label.Size = UDim2.new(1, -64, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = name
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COLOR_TEXT
	label.Parent = button

	button.MouseButton1Click:Connect(function()
		selectPage(name)
	end)

	buttons[name] = button
	return button
end

makePage("Main")
makePage("More")
local settingsPage = makePage("Settings", true)

local settingsList = Instance.new("ScrollingFrame")
settingsList.BackgroundTransparency = 1
settingsList.BorderSizePixel = 0
settingsList.Size = UDim2.fromScale(1, 1)
settingsList.CanvasSize = UDim2.new()
settingsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsList.ScrollBarThickness = 4
settingsList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
settingsList.Parent = settingsPage

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding = UDim.new(0, 12)
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Parent = settingsList

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingRight = UDim.new(0, 12)
settingsPadding.PaddingBottom = UDim.new(0, 12)
settingsPadding.Parent = settingsList

local settingsOrder = 0

local function nextOrder()
	settingsOrder = settingsOrder + 1
	return settingsOrder
end

local function makeRow(height)
	local row = Instance.new("Frame")
	row.BackgroundColor3 = COLOR_ITEM
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, height)
	row.LayoutOrder = nextOrder()
	row.Parent = settingsList
	corner(row, 10)
	stroke(row, Color3.fromRGB(42, 42, 42), 1)
	return row
end

local function makeRowTitle(parent, text, subtext, zIndex)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(18, 14)
	title.Size = UDim2.new(1, -180, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 17
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_TEXT
	title.Text = text
	title.ZIndex = zIndex or 1
	title.Parent = parent

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(18, 36)
		sub.Size = UDim2.new(1, -180, 0, 20)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 14
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.TextColor3 = COLOR_TEXT_DIM
		sub.Text = subtext
		sub.ZIndex = zIndex or 1
		sub.Parent = parent
	end

	return title
end

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

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(options.x, options.y)
	label.Size = UDim2.fromOffset(options.width - 130, 22)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 17
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = COLOR_TEXT
	label.Text = options.name
	label.ZIndex = options.zIndex or 1
	label.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.Position = UDim2.fromOffset(options.x + options.width - 130, options.y)
	valueLabel.Size = UDim2.fromOffset(130, 22)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 16
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = COLOR_TEXT_DIM
	valueLabel.ZIndex = options.zIndex or 1
	valueLabel.Parent = holder

	local track = Instance.new("Frame")
	track.BackgroundColor3 = COLOR_TRACK
	track.BorderSizePixel = 0
	track.Position = UDim2.fromOffset(options.x, options.y + 32)
	track.Size = UDim2.fromOffset(options.width, 10)
	track.ZIndex = options.zIndex or 1
	track.Parent = holder
	circle(track, 5)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = accentColor()
	fill.Size = UDim2.fromScale(0, 1)
	fill.ZIndex = (options.zIndex or 1) + 1
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
	hitbox.ZIndex = (options.zIndex or 1) + 3
	hitbox.Parent = holder

	local knob = Instance.new("Frame")
	knob.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(20, 20)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = (options.zIndex or 1) + 2
	knob.Parent = track
	circle(knob, 10)
	stroke(knob, Color3.fromRGB(24, 24, 24), 2)

	if options.fullWidth then
		label.Size = UDim2.new(1, -(options.x * 2) - 130, 0, 22)
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

local colorRow = makeRow(84)
makeRowTitle(colorRow, "Цвет акцента", "Нажми на кружок и крути палитру")

local hexLabel = Instance.new("TextLabel")
hexLabel.BackgroundTransparency = 1
hexLabel.AnchorPoint = Vector2.new(1, 0.5)
hexLabel.Position = UDim2.new(1, -82, 0.5, 0)
hexLabel.Size = UDim2.fromOffset(130, 24)
hexLabel.Font = Enum.Font.GothamBold
hexLabel.TextSize = 16
hexLabel.TextXAlignment = Enum.TextXAlignment.Right
hexLabel.TextColor3 = COLOR_TEXT_DIM
hexLabel.Text = toHex(accentColor())
hexLabel.Parent = colorRow

local colorButton = Instance.new("TextButton")
colorButton.AutoButtonColor = false
colorButton.Text = ""
colorButton.BorderSizePixel = 0
colorButton.AnchorPoint = Vector2.new(1, 0.5)
colorButton.Position = UDim2.new(1, -18, 0.5, 0)
colorButton.Size = UDim2.fromOffset(50, 50)
colorButton.BackgroundColor3 = accentColor()
colorButton.Parent = colorRow
circle(colorButton, 25)
stroke(colorButton, Color3.fromRGB(70, 70, 70), 2)
table.insert(accentFills, colorButton)

local scaleRow = makeRow(92)
local refreshScale = buildSlider({
	parent = scaleRow,
	name = "Размер меню",
	x = 18,
	y = 16,
	width = 0,
	fullWidth = true,
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

local pathRow = makeRow(74)
makeRowTitle(
	pathRow,
	hasFiles and "Настройки сохраняются" or "Сохранение недоступно",
	hasFiles and ("/storage/emulated/0/Delta/Workspace/" .. CONFIG_PATH) or "Исполнитель не поддерживает работу с файлами"
)

local resetRow = makeRow(74)
makeRowTitle(resetRow, "Сбросить настройки", "Вернуть значения по умолчанию")

local resetButton = Instance.new("TextButton")
resetButton.AutoButtonColor = false
resetButton.BorderSizePixel = 0
resetButton.AnchorPoint = Vector2.new(1, 0.5)
resetButton.Position = UDim2.new(1, -18, 0.5, 0)
resetButton.Size = UDim2.fromOffset(118, 38)
resetButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 16
resetButton.TextColor3 = COLOR_TEXT
resetButton.Text = "Сбросить"
resetButton.Parent = resetRow
corner(resetButton, 8)
stroke(resetButton, Color3.fromRGB(58, 58, 58), 1)

scaleRow:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	refreshScale()
end)

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
picker.Size = UDim2.fromOffset(300, 470)
picker.ZIndex = 41
picker.Parent = overlay
corner(picker, 12)
stroke(picker, Color3.fromRGB(52, 52, 52), 1)

local pickerTitle = Instance.new("TextLabel")
pickerTitle.BackgroundTransparency = 1
pickerTitle.Position = UDim2.fromOffset(20, 16)
pickerTitle.Size = UDim2.new(1, -120, 0, 24)
pickerTitle.Font = Enum.Font.GothamBold
pickerTitle.TextSize = 18
pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
pickerTitle.TextColor3 = COLOR_TEXT
pickerTitle.Text = "Палитра"
pickerTitle.ZIndex = 42
pickerTitle.Parent = picker

local pickerHex = Instance.new("TextLabel")
pickerHex.BackgroundTransparency = 1
pickerHex.AnchorPoint = Vector2.new(1, 0)
pickerHex.Position = UDim2.new(1, -20, 0, 16)
pickerHex.Size = UDim2.fromOffset(120, 24)
pickerHex.Font = Enum.Font.GothamBold
pickerHex.TextSize = 16
pickerHex.TextXAlignment = Enum.TextXAlignment.Right
pickerHex.TextColor3 = COLOR_TEXT_DIM
pickerHex.Text = toHex(accentColor())
pickerHex.ZIndex = 42
pickerHex.Parent = picker

local ring = Instance.new("Frame")
ring.BackgroundTransparency = 1
ring.AnchorPoint = Vector2.new(0.5, 0)
ring.Position = UDim2.new(0.5, 0, 0, 52)
ring.Size = UDim2.fromOffset(RING_SIZE, RING_SIZE)
ring.ZIndex = 42
ring.Parent = picker

local center = RING_SIZE / 2

for index = 1, RING_SEGMENTS do
	local angle = (index - 1) * (2 * math.pi / RING_SEGMENTS)
	local segment = Instance.new("Frame")
	segment.BorderSizePixel = 0
	segment.AnchorPoint = Vector2.new(0.5, 0.5)
	segment.Size = UDim2.fromOffset(math.ceil(2 * math.pi * RING_RADIUS / RING_SEGMENTS) + 2, RING_THICKNESS)
	segment.Position = UDim2.fromOffset(
		math.floor(center + RING_RADIUS * math.cos(angle) + 0.5),
		math.floor(center + RING_RADIUS * math.sin(angle) + 0.5)
	)
	segment.Rotation = math.deg(angle) + 90
	segment.BackgroundColor3 = Color3.fromHSV((index - 1) / RING_SEGMENTS, 1, 1)
	segment.ZIndex = 42
	segment.Parent = ring
end

local ringKnob = Instance.new("Frame")
ringKnob.BorderSizePixel = 0
ringKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ringKnob.Size = UDim2.fromOffset(26, 26)
ringKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ringKnob.ZIndex = 44
ringKnob.Parent = ring
circle(ringKnob, 13)
stroke(ringKnob, Color3.fromRGB(20, 20, 20), 3)

local preview = Instance.new("Frame")
preview.BorderSizePixel = 0
preview.AnchorPoint = Vector2.new(0.5, 0.5)
preview.Position = UDim2.fromScale(0.5, 0.5)
preview.Size = UDim2.fromOffset(112, 112)
preview.BackgroundColor3 = accentColor()
preview.ZIndex = 43
preview.Parent = ring
circle(preview, 56)
stroke(preview, Color3.fromRGB(20, 20, 20), 4)

local pickerHue = 0
local pickerSat = 0
local snapshot = { colorR = 255, colorG = 255, colorB = 255, transparency = 0 }

local function pickerColor()
	return Color3.fromHSV(pickerHue, pickerSat, 1)
end

local renderSaturation
local renderTransparency

local function pushPickerColor()
	local color = pickerColor()
	config.colorR = math.floor(color.R * 255 + 0.5)
	config.colorG = math.floor(color.G * 255 + 0.5)
	config.colorB = math.floor(color.B * 255 + 0.5)
	preview.BackgroundColor3 = color
	pickerHex.Text = toHex(color)
	hexLabel.Text = toHex(color)
	colorButton.BackgroundColor3 = color
	ringKnob.Position = UDim2.fromOffset(
		math.floor(center + RING_RADIUS * math.cos(pickerHue * 2 * math.pi) + 0.5),
		math.floor(center + RING_RADIUS * math.sin(pickerHue * 2 * math.pi) + 0.5)
	)
	applySettings()
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
	x = 20,
	y = 294,
	width = 260,
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
	parent = picker,
	name = "Прозрачность",
	x = 20,
	y = 356,
	width = 260,
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
})

local applyButton = Instance.new("TextButton")
applyButton.AutoButtonColor = false
applyButton.BorderSizePixel = 0
applyButton.Position = UDim2.fromOffset(20, 414)
applyButton.Size = UDim2.fromOffset(126, 40)
applyButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 16
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
cancelButton.Position = UDim2.fromOffset(154, 414)
cancelButton.Size = UDim2.fromOffset(126, 40)
cancelButton.BackgroundColor3 = COLOR_ITEM
cancelButton.Font = Enum.Font.GothamBold
cancelButton.TextSize = 16
cancelButton.TextColor3 = COLOR_TEXT_DIM
cancelButton.Text = "Сбросить"
cancelButton.ZIndex = 42
cancelButton.Parent = picker
corner(cancelButton, 8)
stroke(cancelButton, Color3.fromRGB(58, 58, 58), 1)

local function syncPickerFromConfig()
	local hue, saturation = accentColor():ToHSV()
	pickerHue = hue
	pickerSat = saturation
	pushPickerColor()
	renderSaturation()
	renderTransparency()
end

local function openPicker()
	snapshot.colorR = config.colorR
	snapshot.colorG = config.colorG
	snapshot.colorB = config.colorB
	snapshot.transparency = config.transparency
	syncPickerFromConfig()
	overlay.Visible = true
end

local function closePicker(revert)
	if revert then
		config.colorR = snapshot.colorR
		config.colorG = snapshot.colorG
		config.colorB = snapshot.colorB
		config.transparency = snapshot.transparency
		hexLabel.Text = toHex(accentColor())
		colorButton.BackgroundColor3 = accentColor()
		applySettings()
	end
	overlay.Visible = false
end

colorButton.MouseButton1Click:Connect(openPicker)

applyButton.MouseButton1Click:Connect(function()
	saveConfig()
	closePicker(false)
end)

cancelButton.MouseButton1Click:Connect(function()
	config.colorR = DEFAULTS.colorR
	config.colorG = DEFAULTS.colorG
	config.colorB = DEFAULTS.colorB
	config.transparency = DEFAULTS.transparency
	hexLabel.Text = toHex(accentColor())
	colorButton.BackgroundColor3 = accentColor()
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
profile.Parent = sidebar

local avatarHolder = Instance.new("Frame")
avatarHolder.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
avatarHolder.BorderSizePixel = 0
avatarHolder.AnchorPoint = Vector2.new(0, 0.5)
avatarHolder.Position = UDim2.new(0, 0, 0.5, 0)
avatarHolder.Size = UDim2.fromOffset(50, 50)
avatarHolder.ClipsDescendants = true
avatarHolder.Parent = profile
circle(avatarHolder, 25)

local avatar = Instance.new("ImageLabel")
avatar.BackgroundTransparency = 1
avatar.Size = UDim2.fromScale(1, 1)
avatar.ScaleType = Enum.ScaleType.Crop
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
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
nameLabel.TextSize = 17
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.TextColor3 = COLOR_TEXT
nameLabel.Text = player.Name
nameLabel.Parent = profile

local displayLabel = Instance.new("TextLabel")
displayLabel.BackgroundTransparency = 1
displayLabel.Position = UDim2.fromOffset(62, 29)
displayLabel.Size = UDim2.new(1, -68, 0, 20)
displayLabel.Font = Enum.Font.Gotham
displayLabel.TextSize = 15
displayLabel.TextXAlignment = Enum.TextXAlignment.Left
displayLabel.TextTruncate = Enum.TextTruncate.AtEnd
displayLabel.TextColor3 = COLOR_TEXT_DIM
displayLabel.Text = player.DisplayName
displayLabel.Parent = profile

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.AutoButtonColor = false
toggle.BackgroundColor3 = COLOR_HEADER
toggle.BorderSizePixel = 0
toggle.Size = UDim2.fromOffset(48, 48)
toggle.Position = UDim2.new(0, 14, 0, 90)
toggle.Text = ""
toggle.Active = true
toggle.Draggable = true
toggle.Parent = screenGui
circle(toggle, 24)

local toggleStroke = stroke(toggle, accentColor(), 1)
table.insert(accentStrokes, toggleStroke)

makeIcon(toggle, ICON_BOLT_TOGGLE, 25, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

toggle.MouseButton1Click:Connect(function()
	window.Visible = not window.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	window.Visible = false
end)

local function refreshAll()
	refreshScale()
	hexLabel.Text = toHex(accentColor())
	colorButton.BackgroundColor3 = accentColor()
	syncPickerFromConfig()
	applySettings()
	applyScale()
end

resetButton.MouseButton1Click:Connect(function()
	for key, value in pairs(DEFAULTS) do
		config[key] = value
	end
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
		window.Visible = not window.Visible
	end
end)