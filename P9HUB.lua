-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variables for feature states
local isLockActive = false
local isESPActive = false
local isAutoShooting = false
local isCFrameActive = false
local cframeSpeed = 1000  -- Default CFrame speed

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "P9Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true

-- Title Setup
local Title = Instance.new("TextLabel")
Title.Parent = ScreenGui
Title.Size = UDim2.new(0, 300, 0, 50)
Title.Position = UDim2.new(0.5, -150, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "P9 HUB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 24
Title.TextStrokeTransparency = 0.5
Title.TextTransparency = 0
Title.TextStrokeTransparency = 0.3

-- Add drag functionality to the title
local dragging = false
local dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Title.Position
    end
end)

Title.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Title.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Welcome Text Fade-In
local welcomeText = Instance.new("TextLabel")
welcomeText.Parent = ScreenGui
welcomeText.Size = UDim2.new(0, 300, 0, 50)
welcomeText.Position = UDim2.new(0.5, -150, 0.5, -25)
welcomeText.BackgroundTransparency = 1
welcomeText.Text = "Welcome to P9 HUB!"
welcomeText.TextColor3 = Color3.fromRGB(255, 0, 0)
welcomeText.TextSize = 24
welcomeText.TextStrokeTransparency = 0.5
welcomeText.TextTransparency = 1

-- Fade in the text
for i = 1, 20 do
    welcomeText.TextTransparency = i / 20
    wait(0.1)
end

-- Delay and show the main UI after welcome fades in
wait(2)

-- Create main interface window
local mainWindow = Instance.new("Frame")
mainWindow.Parent = ScreenGui
mainWindow.Size = UDim2.new(0, 300, 0, 300)
mainWindow.Position = UDim2.new(0.5, -150, 0.5, -150)
mainWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainWindow.BorderSizePixel = 0
mainWindow.Visible = true

-- Add title to the main window
local mainTitle = Instance.new("TextLabel")
mainTitle.Parent = mainWindow
mainTitle.Size = UDim2.new(1, 0, 0, 30)
mainTitle.Text = "P9 HUB"
mainTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
mainTitle.TextSize = 18
mainTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainTitle.TextStrokeTransparency = 0.5

-- Function to create buttons
local function createFeatureButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Parent = mainWindow
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 0, 0)
    button.TextSize = 16
    button.TextStrokeTransparency = 0.5
    button.TextButton = true
    button.MouseButton1Click:Connect(callback)
end

-- Feature buttons
createFeatureButton("Lock (C)", UDim2.new(0, 10, 0, 40), function()
    isLockActive = not isLockActive
    if isLockActive then
        -- Lock onto the nearest player (Lock Script)
        local closestPlayer = GetClosestPlayer()
        if closestPlayer then
            -- Lock onto closest player and start following
            LockOntoPlayer(closestPlayer)
        end
    else
        -- Stop lock (Reset Camera and stop following)
        Player = nil
        isLocked = false
    end
end)

createFeatureButton("ESP (T)", UDim2.new(0, 10, 0, 90), function()
    isESPActive = not isESPActive
    if isESPActive then
        -- Activate ESP (Highlight players)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                HighlightPlayer(player)
            end
        end
    else
        -- Deactivate ESP (Remove highlights)
        RemoveESP()
    end
end)

createFeatureButton("Auto Shoot (V)", UDim2.new(0, 10, 0, 140), function()
    isAutoShooting = not isAutoShooting
    if isAutoShooting then
        -- Start auto-shooting when the cursor is on the target
        StartAutoShoot()
    else
        -- Stop auto-shooting
        StopAutoShoot()
    end
end)

createFeatureButton("Teleport (Z)", UDim2.new(0, 10, 0, 190), function()
    -- Teleport to the closest player
    TeleportToClosestPlayer()
end)

createFeatureButton("CFrame Speed (Q)", UDim2.new(0, 10, 0, 240), function()
    isCFrameActive = not isCFrameActive
    if isCFrameActive then
        -- Enable CFrame movement (add speed boost)
        ActivateCFrameSpeed()
    else
        -- Deactivate CFrame movement
        DeactivateCFrameSpeed()
    end
end)

-- Close Window Button
local closeButton = Instance.new("TextButton")
closeButton.Parent = mainWindow
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, -50, 1, -40)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(255, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
closeButton.TextSize = 18
closeButton.MouseButton1Click:Connect(function()
    mainWindow.Visible = false
end)

-- Keybinds to control the features
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        mainWindow.Visible = not mainWindow.Visible
    end
end)

-- Lock-on functionality
function LockOntoPlayer(targetPlayer)
    -- Implement locking logic to target player
    local character = targetPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, humanoidRootPart.Position)
    end
end

function GetClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- ESP Highlighting
function HighlightPlayer(player)
    -- Add highlight to player
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local highlight = Instance.new("Highlight")
            highlight.Parent = character
            highlight.Name = "Highlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0
        end
    end
end

function RemoveESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            if character:FindFirstChild("Highlight") then
                character:FindFirstChild("Highlight"):Destroy()
            end
        end
    end
end

-- AutoShoot Feature
function StartAutoShoot()
    -- Auto shoot logic (lock on to target and shoot when in range)
end

function StopAutoShoot()
    -- Stop auto shoot
end

-- CFrame Movement Logic
function ActivateCFrameSpeed()
    -- Add CFrame speed movement logic
end

function DeactivateCFrameSpeed()
    -- Remove speed boost and reset
end

function TeleportToClosestPlayer()
    -- Implement teleport functionality
end
