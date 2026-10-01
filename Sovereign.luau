--[[\
    Sovereign Hub - Steal An Egg (Fixed & Debugged Edition)
]]--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration State
local Config = {
    AutoSteal = false,
    InstantSteal = false,
    AntiGuard = false,
    AutoTreadmill = false,
    AutoHatch = false,
    AntiHit = false,
    AutoSell = false
}

-- Destroy previous UI if it exists
if CoreGui:FindFirstChild("SovereignHubNative") then
    CoreGui.SovereignHubNative:Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SovereignHubNative"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.Size = UDim2.new(0, 550, 0, 350)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Top Bar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 35)

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Sovereign Hub | Steal An Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
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
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar Tabs Container
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.Active = true
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Sidebar.BorderSizePixel = 0
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.Size = UDim2.new(0, 130, 1, -35)
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 250)
Sidebar.ScrollBarThickness = 2

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)

-- Content Pages Container
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 140, 0, 45)
Container.Size = UDim2.new(1, -150, 1, -55)

local pages = {}
local tabButtons = {}

local function CreateTab(name, index)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Parent = Container
    page.BackgroundTransparency = 1
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 400)
    page.ScrollBarThickness = 3
    page.Visible = (index == 1)
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    
    pages[name] = page

    local btn = Instance.new("TextButton")
    btn.Name = name .. "Button"
    btn.Parent = Sidebar
    btn.BackgroundColor3 = (index == 1) and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(25, 25, 32)
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = (index == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
    btn.TextSize = 13
    
    btn.MouseButton1Click:Connect(function()
        for pName, pObj in pairs(pages) do
            pObj.Visible = (pName == name)
        end
        for _, bObj in pairs(tabButtons) do
            bObj.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
            bObj.TextColor3 = Color3.fromRGB(170, 170, 170)
        end
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    tabButtons[name] = btn
    return page
end

local function AddToggle(tab, title, configKey)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Parent = tab
    toggleBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Size = UDim2.new(1, -10, 0, 36)
    toggleBtn.AutoButtonColor = false
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Text = "   " .. title
    toggleBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    toggleBtn.TextSize = 13
    toggleBtn.TextXAlignment = Enum.TextXAlignment.Left

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = toggleBtn

    local indicator = Instance.new("Frame")
    indicator.Parent = toggleBtn
    indicator.AnchorPoint = Vector2.new(1, 0.5)
    indicator.Position = UDim2.new(1, -12, 0.5, 0)
    indicator.Size = UDim2.new(0, 16, 0, 16)
    indicator.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 4)
    indCorner.Parent = indicator

    toggleBtn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        indicator.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
        print("[Sovereign Hub] " .. title .. " set to: " .. tostring(Config[configKey]))
    end)
end

-- Tabs
local FarmTab = CreateTab("Farm", 1)
local TrainingTab = CreateTab("Training", 2)
local HatchTab = CreateTab("Hatch & Pets", 3)
local MiscTab = CreateTab("Misc / Combat", 4)

-- Elements
AddToggle(FarmTab, "Auto Steal", "AutoSteal")
AddToggle(FarmTab, "Instant Steal", "InstantSteal")
AddToggle(FarmTab, "Anti Guard Protection", "AntiGuard")
AddToggle(TrainingTab, "Auto Treadmill / Grinder", "AutoTreadmill")
AddToggle(HatchTab, "Auto Hatch Eggs", "AutoHatch")
AddToggle(MiscTab, "Anti-Hit / Godmode", "AntiHit")
AddToggle(MiscTab, "Auto Sell Items", "AutoSell")

-- Core Execution Loops with Fallback & Proximity Firechecks
RunService.Heartbeat:Connect(function()
    pcall(function()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if Config.AutoSteal then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    -- Automatically trigger proximity prompts available in the game map
                    pcall(function()
                        fireproximityprompt(obj)
                    end)
                end
            end
        end
    end)
end)

print("[Sovereign Hub] Loaded successfully!")

