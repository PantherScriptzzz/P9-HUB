-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "P9Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true  -- Ensure the GUI is enabled at the start

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
local isLockActive = false
local isESPActive = false
local isAutoShooting = false
local isCFrameActive = false

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
            highlight.Name = "ESP"
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
        end
    end
end

function RemoveESP()
    -- Remove all ESP highlights
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local character = player.Character
            local highlight = character:FindFirstChild("ESP")
            if highlight then
                highlight:Destroy()
            end
        end
    end
end

-- AutoShoot
function StartAutoShoot()
    -- Implement auto shoot logic
    RunService.Heartbeat:Connect(function()
        local targetPlayer = GetClosestPlayer()
        if targetPlayer then
            -- Shoot at the target player (implement shooting logic)
            ShootAtPlayer(targetPlayer)
        end
    end)
end

function StopAutoShoot()
    -- Stop auto shoot logic (disconnect the heartbeat event)
end

function ShootAtPlayer(targetPlayer)
    -- Replace with actual shooting logic
    print("Shooting at player: " .. targetPlayer.Name)
end

-- Teleport functionality
function TeleportToClosestPlayer()
    local closestPlayer = GetClosestPlayer()
    if closestPlayer then
        local humanoidRootPart = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            Camera.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, 5, 0))
        end
    end
end

-- CFrame Speed functionality
function ActivateCFrameSpeed()
    -- Implement CFrame speed logic here
end

function DeactivateCFrameSpeed()
    -- Deactivate CFrame speed logic here
end

-- Keybinds to control the features
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.C then
        isLockActive = not isLockActive
        if isLockActive then
            -- Lock logic here
            local closestPlayer = GetClosestPlayer()
            if closestPlayer then
                LockOntoPlayer(closestPlayer)
            end
        else
            -- Unlock logic here
        end
    end

    if input.KeyCode == Enum.KeyCode.T then
        isESPActive = not isESPActive
        if isESPActive then
            -- Activate ESP
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    HighlightPlayer(player)
                end
            end
        else
            -- Deactivate ESP
            RemoveESP()
        end
    end

    if input.KeyCode == Enum.KeyCode.V then
        isAutoShooting = not isAutoShooting
        if isAutoShooting then
            StartAutoShoot()
        else
            StopAutoShoot()
        end
    end

    if input.KeyCode == Enum.KeyCode.Z then
        -- Teleport logic
        TeleportToClosestPlayer()
    end

    if input.KeyCode == Enum.KeyCode.Q then
        isCFrameActive = not isCFrameActive
        if isCFrameActive then
            ActivateCFrameSpeed()
        else
            DeactivateCFrameSpeed()
        end
    end
end)
