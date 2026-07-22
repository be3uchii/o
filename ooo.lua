local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SurviveApocalypseGUI"
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(128, 0, 255)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "STA Mobile v1.0"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

local GasBtn = Instance.new("TextButton")
GasBtn.Size = UDim2.new(0, 210, 0, 40)
GasBtn.Position = UDim2.new(0.5, -105, 0, 50)
GasBtn.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
GasBtn.Text = "Teleport to Gas / Canister"
GasBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GasBtn.TextSize = 14
GasBtn.Font = Enum.Font.GothamBold
GasBtn.Parent = MainFrame

local GasCorner = Instance.new("UICorner")
GasCorner.CornerRadius = UDim.new(0, 8)
GasCorner.Parent = GasBtn

local FoodBtn = Instance.new("TextButton")
FoodBtn.Size = UDim2.new(0, 210, 0, 40)
FoodBtn.Position = UDim2.new(0.5, -105, 0, 100)
FoodBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
FoodBtn.Text = "Teleport to Food"
FoodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FoodBtn.TextSize = 14
FoodBtn.Font = Enum.Font.GothamBold
FoodBtn.Parent = MainFrame

local FoodCorner = Instance.new("UICorner")
FoodCorner.CornerRadius = UDim.new(0, 8)
FoodCorner.Parent = FoodBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 1, -25)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function teleportTo(position)
    local char = getCharacter()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
end

local function scanAndTeleport(keywords)
    local found = nil
    local function search(object)
        for _, child in ipairs(object:GetChildren()) do
            for _, kw in ipairs(keywords) do
                if string.find(string.lower(child.Name), string.lower(kw)) then
                    if child:IsA("BasePart") then
                        found = child
                        break
                    elseif child:IsA("Model") then
                        local primary = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            found = primary
                            break
                        end
                    end
                end
            end
            if found then break end
            search(child)
        end
    end
    search(Workspace)
    if found then
        teleportTo(found.Position)
        StatusLabel.Text = "Status: Teleported to " .. found.Name
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        StatusLabel.Text = "Status: Item not found!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

GasBtn.MouseButton1Click:Connect(function()
    scanAndTeleport({"gas", "canister", "fuel", "jerrycan", "gascan"})
end)

FoodBtn.MouseButton1Click:Connect(function()
    scanAndTeleport({"food", "beans", "can", "apple", "bread", "water", "cola", "mre", "soda"})
end)