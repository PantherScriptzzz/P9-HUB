-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = Players.LocalPlayer:GetMouse()

-- Local player setup
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables for features
local cframeMovementEnabled = false
local speedMultiplier = 0
local maxSpeedMultiplier = 2000
local espEnabled = false
local autoShootEnabled = false
local lockTarget = nil
local teleportTarget = nil
local hubVisible = true
local dragToggle = false
local dragInput, dragStart, startPos

-- Welcome UI Creation
local function createWelcomeUI()
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "WelcomeScreen"

    local textLabel = Instance.new("TextLabel", screenGui)
    textLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.35, 0, 0.45, 0)
    textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    textLabel.Text = "Welcome to P9 HUB!"
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold

    local uiCorner = Instance.new("UICorner", textLabel)
    uiCorner.CornerRadius = UDim.new(0.1, 0)

    textLabel.BackgroundTransparency = 1
    textLabel.TextTransparency = 1

    for i = 1, 0, -0.1 do
        textLabel.BackgroundTransparency = i
        textLabel.TextTransparency = i
        wait(0.05)
    end

    wait(5)

    for i = 0, 1, 0.1 do
        textLabel.BackgroundTransparency = i
        textLabel.TextTransparency = i
        wait(0.05)
    end

    screenGui:Destroy()
end

-- P9 HUB Interface Creation with Draggable Functionality
local function createHubUI()
    local hubGui = Instance.new("ScreenGui", playerGui)
    hubGui.Name = "P9_HUB_GUI"

    local mainFrame = Instance.new("Frame", hubGui)
    mainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.Visible = hubVisible

    local uiCorner = Instance.new("UICorner", mainFrame)
    uiCorner.CornerRadius = UDim.new(0.05, 0)

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.Text = "P9 HUB"
    titleLabel.TextColor3 = Color3.new(1, 0, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold

    local features = {
        {name = "CFrame Movement (Q/P/M)", hotkey = "Q, P, M", toggleFunc = function() cframeMovementEnabled = not cframeMovementEnabled end},
        {name = "ESP Toggle (T)", hotkey = "T", toggleFunc = function() espEnabled = not espEnabled end},
        {name = "Auto Shoot (V)", hotkey = "V", toggleFunc = function() autoShootEnabled = not autoShootEnabled end},
        {name = "Teleport to Player (Z)", hotkey = "Z", toggleFunc = function() teleportTarget = Mouse.Target end},
        {name = "Lock On Target (C)", hotkey = "C", toggleFunc = function() lockTarget = lockTarget and nil or Mouse.Target end}
    }

    -- Creating buttons with functionality
    for i, feature in ipairs(features) do
        local button = Instance.new("TextButton", mainFrame)
        button.Size = UDim2.new(0.9, 0, 0.12, 0)
        button.Position = UDim2.new(0.05, 0, 0.1 + (0.15 * (i - 1)), 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = feature.name .. " (" .. feature.hotkey .. ")"
        button.TextColor3 = Color3.new(1, 0, 0) -- Red text color
        button.TextScaled = true
        button.Font = Enum.Font.SourceSansBold
        button.MouseButton1Click:Connect(feature.toggleFunc) -- Connect each button to its toggle function

        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0.05, 0)
    end

    -- Draggable Functionality
    local function updateInput(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.Heartbeat:Connect(function()
        if dragToggle then
            updateInput(dragInput)
        end
    end)

    -- Toggle GUI visibility with CTRL key
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.LeftControl then
                hubVisible = not hubVisible
                mainFrame.Visible = hubVisible
            end
        end
    end)
end

-- No-Clip Prevention for CFrame Movement
local function checkCollision(newPosition)
    local ray = Ray.new(LocalPlayer.Character.HumanoidRootPart.Position, (newPosition - LocalPlayer.Character.HumanoidRootPart.Position).unit * speedMultiplier)
    local part, _ = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    return not part -- Returns true if there’s no obstacle
end

-- Other Features (Teleport, Lock-on, etc.)
-- Your existing implementations for teleport, lock-on, auto shoot, ESP toggle, and CFrame Movement will go here.

-- Run the UI Creation and Show Welcome Message
createWelcomeUI()
createHubUI()
