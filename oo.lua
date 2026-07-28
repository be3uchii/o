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

local DEFAULTS = {
	hue = 0,
	saturation = 0,
	transparency = 0,
	scale = 1.2,
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
	config.hue = math.clamp(config.hue, 0, 1)
	config.saturation = math.clamp(config.saturation, 0, 1)
	config.transparency = math.clamp(config.transparency, 0, 0.7)
	config.scale = math.clamp(config.scale, 0.5, 1.6)
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
	return Color3.fromHSV(config.hue, config.saturation, 1)
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
local accentImages = {}
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
header.Size = UDim2.new(1, 0, 0, 66)
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

makeIcon(header, ICON_BOLT, 30, UDim2.fromOffset(16, 18), nil, true)

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(56, 12)
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
versionLabel.Position = UDim2.fromOffset(56, 37)
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
closeButton.Size = UDim2.fromOffset(40, 40)
closeButton.Text = ""
closeButton.Parent = header

makeIcon(closeButton, ICON_CLOSE, 20, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5))

local body = Instance.new("Frame")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(0, 66)
body.Size = UDim2.new(1, 0, 1, -66)
body.Parent = window

local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = COLOR_SIDEBAR
sidebar.BorderSizePixel = 0
sidebar.Position = UDim2.fromOffset(12, 8)
sidebar.Size = UDim2.new(0, 220, 1, -20)
sidebar.Parent = body
corner(sidebar, 12)
stroke(sidebar, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, sidebar)

local navHolder = Instance.new("Frame")
navHolder.BackgroundTransparency = 1
navHolder.Position = UDim2.fromOffset(12, 12)
navHolder.Size = UDim2.new(1, -24, 0, 210)
navHolder.Parent = sidebar

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 10)
navList.SortOrder = Enum.SortOrder.LayoutOrder
navList.Parent = navHolder

local content = Instance.new("Frame")
content.BackgroundColor3 = COLOR_PANEL
content.BorderSizePixel = 0
content.Position = UDim2.fromOffset(244, 8)
content.Size = UDim2.new(1, -256, 1, -20)
content.ClipsDescendants = true
content.Parent = body
corner(content, 12)
stroke(content, Color3.fromRGB(34, 34, 34), 1)
table.insert(panelParts, content)

local pages = {}
local buttons = {}
local navIcons = {}
local currentPage = "Main"
local satGradient = nil

local function applySettings()
	local accent = accentColor()
	for _, image in ipairs(accentImages) do
		image.ImageColor3 = accent
	end
	for _, fill in ipairs(accentFills) do
		fill.BackgroundColor3 = accent
	end
	for _, item in ipairs(accentStrokes) do
		item.Color = accent
	end
	for name, icon in pairs(navIcons) do
		icon.ImageColor3 = name == currentPage and accent or COLOR_TEXT
	end
	for _, part in ipairs(panelParts) do
		part.BackgroundTransparency = config.transparency
	end
	if satGradient then
		satGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(config.hue, 1, 1)),
		})
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
		icon.ImageColor3 = iconName == name and accent or COLOR_TEXT
	end
end

local function makeNavButton(name, imageId, order)
	local button = Instance.new("TextButton")
	button.Name = name
	button.LayoutOrder = order
	button.AutoButtonColor = false
	button.BackgroundColor3 = COLOR_ITEM
	button.BorderSizePixel = 0
	button.Size = UDim2.new(1, 0, 0, 62)
	button.Text = ""
	button.Parent = navHolder
	corner(button, 10)
	stroke(button, Color3.fromRGB(42, 42, 42), 1)

	navIcons[name] = makeIcon(button, imageId, 24, UDim2.new(0, 18, 0.5, 0), Vector2.new(0, 0.5))

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromOffset(56, 0)
	label.Size = UDim2.new(1, -66, 1, 0)
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
settingsLayout.Padding = UDim.new(0, 14)
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

local function makeRowTitle(row, text, subtext)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(18, 14)
	title.Size = UDim2.new(1, -160, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 17
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLOR_TEXT
	title.Text = text
	title.Parent = row

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.BackgroundTransparency = 1
		sub.Position = UDim2.fromOffset(18, 36)
		sub.Size = UDim2.new(1, -160, 0, 20)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 14
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.TextColor3 = COLOR_TEXT_DIM
		sub.Text = subtext
		sub.Parent = row
	end

	return title
end

local activeSlider = nil

local function makeSlider(options)
	local row = makeRow(options.subtext and 108 or 90)
	makeRowTitle(row, options.name, options.subtext)

	local valueLabel = Instance.new("TextLabel")
	valueLabel.BackgroundTransparency = 1
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -18, 0, 14)
	valueLabel.Size = UDim2.fromOffset(130, 22)
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 16
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.TextColor3 = COLOR_TEXT_DIM
	valueLabel.Text = options.format(options.get())
	valueLabel.Parent = row

	local track = Instance.new("Frame")
	track.BackgroundColor3 = COLOR_TRACK
	track.BorderSizePixel = 0
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.new(0, 18, 1, -26)
	track.Size = UDim2.new(1, -36, 0, 10)
	track.Parent = row
	circle(track, 5)

	local fill = Instance.new("Frame")
	fill.BorderSizePixel = 0
	fill.BackgroundColor3 = accentColor()
	fill.Size = UDim2.fromScale(0, 1)
	fill.Parent = track
	circle(fill, 5)

	if options.gradient == "hue" then
		fill.BackgroundTransparency = 1
		track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		})
		gradient.Parent = track
	elseif options.gradient == "saturation" then
		fill.BackgroundTransparency = 1
		track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		satGradient = Instance.new("UIGradient")
		satGradient.Parent = track
	else
		table.insert(accentFills, fill)
	end

	local knob = Instance.new("Frame")
	knob.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.fromOffset(20, 20)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = track
	circle(knob, 10)
	stroke(knob, Color3.fromRGB(24, 24, 24), 2)

	local function render()
		local alpha = (options.get() - options.min) / (options.max - options.min)
		alpha = math.clamp(alpha, 0, 1)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = options.format(options.get())
	end

	local function update(x)
		local absolutePosition = track.AbsolutePosition.X
		local absoluteSize = math.max(track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - absolutePosition) / absoluteSize, 0, 1)
		options.set(options.min + (options.max - options.min) * alpha)
		render()
	end

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if activeSlider == nil then
				activeSlider = { update = update, input = input }
				update(input.Position.X)
			end
		end
	end)

	render()
	return render
end

UserInputService.InputChanged:Connect(function(input)
	if not activeSlider then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		activeSlider.update(input.Position.X)
	elseif input.UserInputType == Enum.UserInputType.Touch and input == activeSlider.input then
		activeSlider.update(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not activeSlider then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input == activeSlider.input then
		activeSlider = nil
		saveConfig()
	end
end)

local colorPreviewRow = makeRow(78)
makeRowTitle(colorPreviewRow, "Цвет акцента", "Иконки, активная вкладка и ползунки")

local hexLabel = Instance.new("TextLabel")
hexLabel.BackgroundTransparency = 1
hexLabel.AnchorPoint = Vector2.new(1, 0.5)
hexLabel.Position = UDim2.new(1, -76, 0.5, 0)
hexLabel.Size = UDim2.fromOffset(120, 22)
hexLabel.Font = Enum.Font.GothamBold
hexLabel.TextSize = 16
hexLabel.TextXAlignment = Enum.TextXAlignment.Right
hexLabel.TextColor3 = COLOR_TEXT_DIM
hexLabel.Text = toHex(accentColor())
hexLabel.Parent = colorPreviewRow

local preview = Instance.new("Frame")
preview.BorderSizePixel = 0
preview.AnchorPoint = Vector2.new(1, 0.5)
preview.Position = UDim2.new(1, -18, 0.5, 0)
preview.Size = UDim2.fromOffset(46, 46)
preview.BackgroundColor3 = accentColor()
preview.Parent = colorPreviewRow
circle(preview, 23)
stroke(preview, Color3.fromRGB(58, 58, 58), 1)
table.insert(accentFills, preview)

local refreshHue
local refreshSaturation

refreshHue = makeSlider({
	name = "Оттенок",
	min = 0,
	max = 1,
	gradient = "hue",
	get = function()
		return config.hue
	end,
	set = function(value)
		config.hue = value
		applySettings()
		hexLabel.Text = toHex(accentColor())
	end,
	format = function(value)
		return tostring(math.floor(value * 360 + 0.5)) .. "\u{00B0}"
	end,
})

refreshSaturation = makeSlider({
	name = "Насыщенность",
	min = 0,
	max = 1,
	gradient = "saturation",
	get = function()
		return config.saturation
	end,
	set = function(value)
		config.saturation = value
		applySettings()
		hexLabel.Text = toHex(accentColor())
	end,
	format = function(value)
		return tostring(math.floor(value * 100 + 0.5)) .. "%"
	end,
})

local refreshTransparency = makeSlider({
	name = "Прозрачность",
	min = 0,
	max = 0.7,
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

local refreshScale = makeSlider({
	name = "Размер меню",
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
})

local pathRow = makeRow(76)
makeRowTitle(
	pathRow,
	hasFiles and "Настройки сохраняются" or "Сохранение недоступно",
	hasFiles and ("/storage/emulated/0/Delta/Workspace/" .. CONFIG_PATH) or "Исполнитель не поддерживает работу с файлами"
)

local resetRow = makeRow(76)
makeRowTitle(resetRow, "Сбросить настройки", "Вернуть значения по умолчанию")

local resetButton = Instance.new("TextButton")
resetButton.AutoButtonColor = false
resetButton.BorderSizePixel = 0
resetButton.AnchorPoint = Vector2.new(1, 0.5)
resetButton.Position = UDim2.new(1, -18, 0.5, 0)
resetButton.Size = UDim2.fromOffset(120, 40)
resetButton.BackgroundColor3 = COLOR_ITEM_ACTIVE
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 16
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
profile.Size = UDim2.new(1, -28, 0, 56)
profile.Parent = sidebar

local avatarHolder = Instance.new("Frame")
avatarHolder.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
avatarHolder.BorderSizePixel = 0
avatarHolder.AnchorPoint = Vector2.new(0, 0.5)
avatarHolder.Position = UDim2.new(0, 0, 0.5, 0)
avatarHolder.Size = UDim2.fromOffset(52, 52)
avatarHolder.ClipsDescendants = true
avatarHolder.Parent = profile
circle(avatarHolder, 26)

local avatar = Instance.new("ImageLabel")
avatar.BackgroundTransparency = 1
avatar.Size = UDim2.fromScale(1, 1)
avatar.ScaleType = Enum.ScaleType.Crop
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
avatar.Parent = avatarHolder
circle(avatar, 26)

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
nameLabel.Position = UDim2.fromOffset(64, 6)
nameLabel.Size = UDim2.new(1, -70, 0, 22)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 17
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.TextColor3 = COLOR_TEXT
nameLabel.Text = player.Name
nameLabel.Parent = profile

local displayLabel = Instance.new("TextLabel")
displayLabel.BackgroundTransparency = 1
displayLabel.Position = UDim2.fromOffset(64, 30)
displayLabel.Size = UDim2.new(1, -70, 0, 20)
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
toggle.Size = UDim2.fromOffset(50, 50)
toggle.Position = UDim2.new(0, 14, 0, 90)
toggle.Text = ""
toggle.Active = true
toggle.Draggable = true
toggle.Parent = screenGui
circle(toggle, 25)

local toggleStroke = stroke(toggle, accentColor(), 1)
table.insert(accentStrokes, toggleStroke)

makeIcon(toggle, ICON_BOLT_TOGGLE, 26, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5), true)

toggle.MouseButton1Click:Connect(function()
	window.Visible = not window.Visible
end)

closeButton.MouseButton1Click:Connect(function()
	window.Visible = false
end)

local function refreshAll()
	refreshHue()
	refreshSaturation()
	refreshTransparency()
	refreshScale()
	hexLabel.Text = toHex(accentColor())
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