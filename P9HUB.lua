--[[
    P9 HUB Script
    This script includes all features: ESP, Lock, Auto Shoot, Teleport, and CFrame Movement
    with proper keybinds, GUI, and noclip prevention.
--]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "P9Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true  -- Make sure the GUI is enabled at the start

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

-- Fade in the welcome text
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

-- CFrame Movement
local movementSpeed = 50
local increaseSpeed = 10
local decreaseSpeed = 5
local currentSpeed = movementSpeed

local isCFrameActive = false

-- Activate CFrame movement with Q
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Q then
            isCFrameActive = true
        elseif input.KeyCode == Enum.KeyCode.P then
            currentSpeed = currentSpeed + increaseSpeed
        elseif input.KeyCode == Enum.KeyCode.M then
            currentSpeed = math.max(currentSpeed - decreaseSpeed, movementSpeed)
        end
    end
end)

-- Deactivate CFrame movement
RunService.RenderStepped:Connect(function()
    if isCFrameActive then
        local moveDirection = Camera.CFrame.LookVector
        Camera.CFrame = Camera.CFrame * CFrame.new(moveDirection * currentSpeed)
    end
end)

-- Lock onto player
local isLockActive = false
local targetPlayer = nil

local function GetClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPosition = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.C then
        if isLockActive then
            targetPlayer = nil
            isLockActive = false
        else
            targetPlayer = GetClosestPlayer()
            isLockActive = true
        end
    end
end)

-- Teleport to nearest player (Z key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Z and not gameProcessed then
        local closestPlayer = GetClosestPlayer()
        if closestPlayer and closestPlayer.Character then
            LocalPlayer.Character:SetPrimaryPartCFrame(closestPlayer.Character.HumanoidRootPart.CFrame)
        end
    end
end)

-- Auto Shoot (toggle V key)
local isAutoShooting = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.V then
        isAutoShooting = not isAutoShooting
    end
end)

-- Highlighting and ESP
local function highlightPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.Name = "ESP"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.8
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.OutlineTransparency = 0
    end
end

local function removeHighlight(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local highlight = player.Character:FindFirstChild("ESP")
        if highlight then
            highlight:Destroy()
        end
    end
end

-- Toggle ESP with T key
local isESPActive = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        isESPActive = not isESPActive
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if isESPActive then
                    highlightPlayer(player)
                else
                    removeHighlight(player)
                end
            end
        end
    end
end)

-- Add the feature buttons for GUI
local function createFeatureButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Parent = ScreenGui
    button.Size = UDim2.new(0, 200, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 0, 0)
    button.TextSize = 18
    button.TextStrokeTransparency = 0.5
    button.TextButton = true
    button.MouseButton1Click:Connect(callback)
end

createFeatureButton("Lock (C)", UDim2.new(0.5, -100, 0.3, 0), function()
    if isLockActive then
        targetPlayer = nil
        isLockActive = false
    else
        targetPlayer = GetClosestPlayer()
        isLockActive = true
    end
end)

createFeatureButton("ESP (T)", UDim2.new(0.5, -100, 0.35, 0), function()
    isESPActive = not isESPActive
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if isESPActive then
                highlightPlayer(player)
            else
                removeHighlight(player)
            end
        end
    end
end)

createFeatureButton("Auto Shoot (V)", UDim2.new(0.5, -100, 0.4, 0), function()
    isAutoShooting = not isAutoShooting
end)

createFeatureButton("Teleport (Z)", UDim2.new(0.5, -100, 0.45, 0), function()
    local closestPlayer = GetClosestPlayer()
    if closestPlayer and closestPlayer.Character then
        LocalPlayer.Character:SetPrimaryPartCFrame(closestPlayer.Character.HumanoidRootPart.CFrame)
    end
end)

createFeatureButton("CFrame Speed (Q)", UDim2.new(0.5, -100, 0.5, 0), function()
    isCFrameActive = not isCFrameActive
end)
