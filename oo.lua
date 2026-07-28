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
local COLOR_TEXT = Color3.fromRGB(235, 235, 235)
local COLOR_TEXT_DIM = Color3.fromRGB(140, 140, 140)

local ACCENTS = {
	Color3.fromRGB(235, 235, 235),
	Color3.fromRGB(88, 142, 255),
	Color3.fromRGB(163, 110, 255),
	Color3.fromRGB(78, 205, 148),
	Color3.fromRGB(255, 158, 64),
	Color3.fromRGB(240, 92, 92),
	Color3.fromRGB(255, 106, 193),
	Color3.fromRGB(96, 224, 232),
}

local DEFAULTS = {
	accent = 2,
	transparency = 0,
	scale = 1,
	rounding = 1,
	tintIcons = true,
	savePosition = true,
	posX = nil,
	posY = nil,
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
		if decoded[key] ~= nil then
			config[key] = decoded[key]
		end
	end
	config.accent = math.clamp(tonumber(config.accent) or DEFAULTS.accent, 1, #ACCENTS)
	config.transparency = math.clamp(tonumber(config.transparency) or 0, 0, 0.7)
	config.scale = math.clamp(tonumber(config.scale) or 1, 0.5, 1.5)
	config.rounding = math.clamp(tonumber(config.rounding) or 1, 0, 2)
end

local saveQueued = false

local function saveConfig()
	if not hasFiles or saveQueued then
		return
	end
	saveQueued = true
	task.delay(0.35, function()
		saveQueued = false
		ensureFolder()
		pcall(function()
			writefile(CONFIG_PATH, HttpService:JSONEncode(config))
		end)
	end)
end

loadConfig()

local function accentColor()
	return ACCENTS[config.accent] or ACCENTS[1]
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

local roundedParts = {}
local panelParts = {}
local accentImages = {}
local accentFills = {}
local accentStrokes = {}
local plainImages = {}

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	table.insert(roundedParts, { object = c, base = radius })
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

local function makeIcon(parent, imageId, size, position, anchor, accent)
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
	if accent then
		table.insert(accentImages, image)
	else
		table.insert(plainImages, image)
	end
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

if config.savePosition and config.posX and config.posY then
	window.Position = UDim2.fromOffset(config.posX, config.posY)
	window.AnchorPoint = Vector2.new(0, 0)
end

local uiScale = Instance.new("UIScale")
uiScale.Parent = window

local function applyScale()
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local widthRatio = isMobile and 0.62 or 0.7
	local heightRatio = isMobile and 0.66 or 0.8
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
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = COLOR_HEADER
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 0
headerFix.Parent = header
table.insert(panelParts, headerFix)

makeIcon(header, ICON_BOLT, 26, UDim2.fromOffset(16, 18), nil, true)

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(52, 12)
titleLabel.Size = UDim2.fromOffset(700, 22)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = COLOR_TEXT
titleLabel.RichText = true
titleLabel.Text = TITLE .. " <font color=\"rgb(120,120,120)\">\u{2022}</font> " .. AUTHOR
titleLabel.Parent = header

local versionLabel = Instance.new("TextLabel")
versionLabel.BackgroundTransparency = 1
versionLabel.Position = UDim2.fromOffset(52, 34)
versionLabel.Size = UDim2.fromOffset(200, 16)
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 12
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

makeIcon(closeButton, ICON_CLOSE, 18, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 62)
body.Size = UDim2.new(1, 0, 1, -62)
body.Parent = window

local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromOffset(12, 8)
sidebar.Size = UDim2.new(0, 208, 1, -20)
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
navList.Padding = UDim.new(0, 10)
navList.SortOrder = Enum.SortOrder.LayoutOrder
navList.Parent = navHolder

local content = Instance.new("Frame")
content.BackgroundColor3 = COLOR_PANEL
content.BorderSizePixel = 0
content.Position = UDim2.fromOffset(232, 8)
content.Size = UDim2.new(1, -244, 1, -20)
content.ClipsDescendants = true
content.Parent = body
corner(content, 12)
stroke(content, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, content)

local pages = {}
local buttons = {}
local navIcons = {}
local currentPage = "Main"

local function applySettings()
	local accent = accentColor()
	for _, image in ipairs(accentImages) do
		image.ImageColor3 = config.tintIcons and accent or COLOR_TEXT
	end
	for _, fill in ipairs(accentFills) do
		fill.BackgroundColor3 = accent
	end
	for _, item in ipairs(accentStrokes) do
		item.Color = accent
	end
	for name, icon in pairs(navIcons) do
		if name == currentPage and config.tintIcons then
			icon.ImageColor3 = accent
		else
			icon.ImageColor3 = COLOR_TEXT
		end
	end
	for _, part in ipairs(panelParts) do
		part.BackgroundTransparency = config.transparency
	end
	for _, entry in ipairs(roundedParts) do
		entry.object.CornerRadius = UDim.new(0, math.floor(entry.base * config.rounding))
	end
	applyScale()
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
	pad.PaddingTop = UDim.new(0, 20)
	pad.PaddingBottom = UDim.new(0, 20)
	pad.PaddingLeft = UDim.new(0, 20)
	pad.PaddingRight = UDim.new(0, 20)
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
	for buttonName, button in pairs(buttons) do
		local active = buttonName == name
		TweenService:Create(button, TweenInfo.new(0.18), {
			BackgroundColor3 = active and COLOR_ITEM_ACTIVE or COLOR_ITEM,
		}):Play()
	end
	local accent = accentColor()
	for iconName, icon in pairs(navIcons) do
		icon.ImageColor3 = (iconName == name and config.tintIcons) and accent or COLOR_TEXT
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
	stroke(button, Color3.fromRGB(42, 42, 42), 1)

	navIcons[name] = makeIcon(button, imageId, 22, UDim2.new(0, 16, 0.5, 0), Vector2.new(0, 0.5))

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(52, 0)
	label.Size = UDim2.new(1, -62, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = name
	label.TextSize = 16
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
settingsList.ScrollBarThickness = 3
settingsList.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)
settingsList.Parent = settingsPage

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding = UDim.new(0, 12)
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Parent = settingsList

local settingsPadding = Instance.new("UIPadding")
settingsPadding.PaddingRight = UDim.new(0, 10)
settingsPadding.PaddingBottom = UDim.new(0, 10)
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

local function makeRowTitle(row, text, subtext)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(16, 12)
	title.Size = UDim2.new(1, -120, 0, 18)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_TEXT
	title.Text = text
	title.Parent = row

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(16, 30)
		sub.Size = UDim2.new(1, -120, 0, 16)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 12
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.TextColor3 = COLOR_TEXT_DIM
		sub.Text = subtext
		sub.Parent = row
	end

	return title
end

local function makeSlider(name, minValue, maxValue, getValue, setValue, format)
	local row = makeRow(74)
	makeRowTitle(row, name)

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -16, 0, 12)
	valueLabel.Size = UDim2.fromOffset(90, 18)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 13
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = COLOR_TEXT_DIM
	valueLabel.Text = format(getValue())
	valueLabel.Parent = row

	local track = Instance.new("Frame")
	track.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
	track.BorderSizePixel = 0
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.new(0, 16, 0, 52)
	track.Size = UDim2.new(1, -32, 0, 6)
	track.Parent = row
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = accentColor()
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale((getValue() - minValue) / (maxValue - minValue), 1)
	fill.Parent = track
	corner(fill, 3)
	table.insert(accentFills, fill)

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = accentColor()
	knob.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Parent = track
	corner(knob, 7)
	table.insert(accentFills, knob)

	local dragging = false

	local function update(x)
		local absolutePosition = track.AbsolutePosition.X
		local absoluteSize = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - absolutePosition) / absoluteSize, 0, 1)
		local value = minValue + (maxValue - minValue) * alpha
		setValue(value)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = format(value)
	end

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			saveConfig()
		end
	end)

	return function()
		local alpha = (getValue() - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = format(getValue())
	end
end

local function makeSwitch(name, subtext, getValue, setValue)
	local row = makeRow(56)
	makeRowTitle(row, name, subtext)

	local switch = Instance.new("TextButton")
	switch.AutoButtonColor = false
	switch.Text = ""
	switch.BorderSizePixel = 0
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -16, 0.5, 0)
	switch.Size = UDim2.fromOffset(44, 24)
	switch.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
	switch.Parent = row
	corner(switch, 12)

	local dot = Instance.new("Frame")
	dot.BorderSizePixel = 0
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Size = UDim2.fromOffset(18, 18)
	dot.BackgroundColor3 = COLOR_TEXT
	dot.Parent = switch
	corner(dot, 9)

	local function render()
		local on = getValue()
		TweenService:Create(switch, TweenInfo.new(0.15), {
			BackgroundColor3 = on and accentColor() or Color3.fromRGB(52, 52, 52),
		}):Play()
		TweenService:Create(dot, TweenInfo.new(0.15), {
			Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		}):Play()
	end

	switch.MouseButton1Click:Connect(function()
		setValue(not getValue())
		render()
		saveConfig()
	end)

	render()
	return render
end

local colorRow = makeRow(78)
makeRowTitle(colorRow, "Цвет акцента", "Иконки, ползунки и активная вкладка")

local swatchHolder = Instance.new("Frame")
swatchHolder.BackgroundTransparency = 1
swatchHolder.Position = UDim2.fromOffset(16, 48)
swatchHolder.Size = UDim2.new(1, -32, 0, 24)
swatchHolder.Parent = colorRow

local swatchLayout = Instance.new("UIListLayout")
swatchLayout.FillDirection = Enum.FillDirection.Horizontal
swatchLayout.Padding = UDim.new(0, 8)
swatchLayout.SortOrder = Enum.SortOrder.LayoutOrder
swatchLayout.Parent = swatchHolder

local swatchStrokes = {}

local function renderSwatches()
	for index, item in ipairs(swatchStrokes) do
		local selected = index == config.accent
		item.Color = selected and COLOR_TEXT or Color3.fromRGB(52, 52, 52)
		item.Thickness = selected and 2 or 1
	end
end

for index, color in ipairs(ACCENTS) do
	local swatch = Instance.new("TextButton")
	swatch.AutoButtonColor = false
	swatch.Text = ""
	swatch.BorderSizePixel = 0
	swatch.LayoutOrder = index
	swatch.Size = UDim2.fromOffset(24, 24)
	swatch.BackgroundColor3 = color
	swatch.Parent = swatchHolder
	corner(swatch, 7)
	swatchStrokes[index] = stroke(swatch, Color3.fromRGB(52, 52, 52), 1)

	swatch.MouseButton1Click:Connect(function()
		config.accent = index
		renderSwatches()
		applySettings()
		saveConfig()
	end)
end

renderSwatches()

local refreshTransparency = makeSlider("Прозрачность", 0, 0.7, function()
	return config.transparency
end, function(value)
	config.transparency = value
	applySettings()
end, function(value)
	return tostring(math.floor(value * 100 + 0.5)) .. "%"
end)

local refreshScale = makeSlider("Размер меню", 0.5, 1.5, function()
	return config.scale
end, function(value)
	config.scale = value
	applyScale()
end, function(value)
	return tostring(math.floor(value * 100 + 0.5)) .. "%"
end)

local refreshRounding = makeSlider("Скругление углов", 0, 2, function()
	return config.rounding
end, function(value)
	config.rounding = value
	applySettings()
end, function(value)
	return tostring(math.floor(value * 100 + 0.5)) .. "%"
end)

local refreshTint = makeSwitch("Красить иконки", "Иконки в цвете акцента", function()
	return config.tintIcons
end, function(value)
	config.tintIcons = value
	applySettings()
end)

local refreshSavePosition = makeSwitch("Запоминать положение", "Меню откроется там же, где закрыл", function()
	return config.savePosition
end, function(value)
	config.savePosition = value
end)

local pathRow = makeRow(56)
makeRowTitle(
	pathRow,
	hasFiles and "Настройки сохраняются" or "Сохранение недоступно",
	hasFiles and ("/storage/emulated/0/Delta/Workspace/" .. CONFIG_PATH) or "Исполнитель не поддерживает работу с файлами"
)

local resetRow = makeRow(56)
makeRowTitle(resetRow, "Сбросить настройки", "Вернуть значения по умолчанию")

local resetButton = Instance.new("TextButton")
resetButton.AutoButtonColor = false
resetButton.BorderSizePixel = 0
resetButton.AnchorPoint = Vector2.new(1, 0.5)
resetButton.Position = UDim2.new(1, -16, 0.5, 0)
resetButton.Size = UDim2.fromOffset(96, 30)
resetButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 13
resetButton.TextColor3 = COLOR_TEXT
resetButton.Text = "Сбросить"
resetButton.Parent = resetRow
corner(resetButton, 8)
stroke(resetButton, Color3.fromRGB(58, 58, 58), 1)

makeNavButton("Main", ICON_HOME, 1)
makeNavButton("More", ICON_MORE, 2)
makeNavButton("Settings", ICON_SETTINGS, 3)

selectPage("Main")

local profile = Instance.new("Frame")
profile.BackgroundTransparency = 1
profile.AnchorPoint = Vector2.new(0, 1)
profile.Position = UDim2.new(0, 14, 1, -16)
profile.Size = UDim2.new(1, -28, 0, 52)
profile.Parent = sidebar

local avatarHolder = Instance.new("Frame")
avatarHolder.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
avatarHolder.BorderSizePixel = 0
avatarHolder.AnchorPoint = Vector2.new(0, 0.5)
avatarHolder.Position = UDim2.new(0, 0, 0.5, 0)
avatarHolder.Size = UDim2.fromOffset(48, 48)
avatarHolder.ClipsDescendants = true
avatarHolder.Parent = profile

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 24)
avatarCorner.Parent = avatarHolder

local avatar = Instance.new("ImageLabel")
avatar.BackgroundTransparency = 1
avatar.Size = UDim2.fromScale(1, 1)
avatar.ScaleType = Enum.ScaleType.Crop
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.Parent = avatarHolder

local avatarImageCorner = Instance.new("UICorner")
avatarImageCorner.CornerRadius = UDim.new(0, 24)
avatarImageCorner.Parent = avatar

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
nameLabel.Position = UDim2.fromOffset(60, 6)
nameLabel.Size = UDim2.new(1, -66, 0, 20)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 15
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.TextColor3 = COLOR_TEXT
nameLabel.Text = player.Name
nameLabel.Parent = profile

local displayLabel = Instance.new("TextLabel")
displayLabel.BackgroundTransparency = 1
displayLabel.Position = UDim2.fromOffset(60, 27)
displayLabel.Size = UDim2.new(1, -66, 0, 18)
displayLabel.Font = Enum.Font.Gotham
displayLabel.TextSize = 13
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
toggle.Size = UDim2.fromOffset(46, 46)
toggle.Position = UDim2.new(0, 14, 0, 90)
toggle.Text = ""
toggle.Active = true
toggle.Draggable = true
toggle.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 23)
toggleCorner.Parent = toggle

local toggleStroke = stroke(toggle, accentColor(), 1)
table.insert(accentStrokes, toggleStroke)

makeIcon(toggle, ICON_BOLT_TOGGLE, 24, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), true)

toggle.MouseButton1Click:Connect(function()
	window.Visible = not window.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	window.Visible = false
end)

local function refreshAll()
	renderSwatches()
	refreshTransparency()
	refreshScale()
	refreshRounding()
	refreshTint()
	refreshSavePosition()
	applySettings()
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
		if dragging and config.savePosition then
			config.posX = math.floor(window.AbsolutePosition.X)
			config.posY = math.floor(window.AbsolutePosition.Y)
			saveConfig()
		end
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
