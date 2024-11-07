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
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESPFolder"

-- Welcome UI Creation
local function createWelcomeUI()
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "WelcomeScreen"

    -- Welcome text label
    local textLabel = Instance.new("TextLabel", screenGui)
    textLabel.Size = UDim2.new(0.3, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.35, 0, 0.45, 0)
    textLabel.BackgroundTransparency = 1 -- No background color
    textLabel.Text = "Welcome to P9 HUB!"
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextTransparency = 1

    -- Fade in effect for welcome text
    local fadeInTween = game:GetService("TweenService"):Create(textLabel, TweenInfo.new(2), {TextTransparency = 0})
    fadeInTween:Play()

    -- Instructional text label after welcome message
    local instructionLabel = Instance.new("TextLabel", screenGui)
    instructionLabel.Size = UDim2.new(0.5, 0, 0.2, 0)
    instructionLabel.Position = UDim2.new(0.25, 0, 0.55, 0)
    instructionLabel.BackgroundTransparency = 1 -- No background color
    instructionLabel.Text = "HOTKEYS FOR P9 HUB\n\nCAM LOCK (C)\nESP (T)\nAUTO SHOOT (V)\nCFRAME (Q to start , P to increase, M to decrease)\nTeleport to nearest player (Z)"
    instructionLabel.TextColor3 = Color3.new(1, 0, 0)
    instructionLabel.TextScaled = true
    instructionLabel.Font = Enum.Font.SourceSansBold
    instructionLabel.TextTransparency = 1

    -- Fade in effect for instructions
    local instructionFadeInTween = game:GetService("TweenService"):Create(instructionLabel, TweenInfo.new(2), {TextTransparency = 0})
    instructionFadeInTween:Play()

    -- After 7 seconds, remove the instructional text and then delete the GUI
    delay(7, function()
        -- Fade out the instructional text
        local fadeOutTween = game:GetService("TweenService"):Create(instructionLabel, TweenInfo.new(2), {TextTransparency = 1})
        fadeOutTween:Play()

        -- Wait for the fade-out to complete before deleting the GUI
        fadeOutTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Return the screenGui to be used later
    return screenGui
end

-- Function to toggle ESP
local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        -- Enable ESP: Highlight players and add billboard GUI
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                -- Highlight creation
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.FillTransparency = 0.8
                highlight.Name = "ESPHighlight"

                -- Billboard GUI for name
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "NameTag"
                billboard.Parent = player.Character:WaitForChild("Head")
                billboard.Size = UDim2.new(2, 0, 0.5, 0)
                billboard.StudsOffset = Vector3.new(0, 2, 0)

                local nameLabel = Instance.new("TextLabel", billboard)
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 0, 0)
                nameLabel.TextScaled = true
            end
        end
    else
        -- Disable ESP: Remove highlights and billboard GUIs
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                local nameTag = player.Character:FindFirstChild("Head"):FindFirstChild("NameTag")
                if highlight then highlight:Destroy() end
                if nameTag then nameTag:Destroy() end
            end
        end
    end
end

-- Function for Auto Shoot toggle (you can expand this with proper logic)
local function toggleAutoShoot()
    autoShootEnabled = not autoShootEnabled
    if autoShootEnabled then
        print("Auto Shoot is ON")
    else
        print("Auto Shoot is OFF")
    end
end

-- Function to teleport to nearest player
local function teleportToPlayer()
    -- Finds the nearest player to teleport to
    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end

    -- Teleport to the nearest player if found
    if nearestPlayer then
        LocalPlayer.Character:SetPrimaryPartCFrame(nearestPlayer.Character.HumanoidRootPart.CFrame)
        print("Teleported to:", nearestPlayer.Name)
    end
end

-- Function for Lock-On target
local function lockOntoTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    if closestPlayer then
        -- Lock camera to closest player's position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
        print("Locked onto:", closestPlayer.Name)
    end
end

-- GUI Visibility Control (FN key to toggle)
local guiVisible = true
local screenGui = createWelcomeUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.F then
            guiVisible = not guiVisible
            if screenGui then
                screenGui.Enabled = guiVisible
            end
        end
    end
end)

-- Bind keys to features
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.C then
            lockOntoTarget()
        elseif input.KeyCode == Enum.KeyCode.T then
            toggleESP()
        elseif input.KeyCode == Enum.KeyCode.V then
            toggleAutoShoot()
        elseif input.KeyCode == Enum.KeyCode.Z then
            teleportToPlayer()
        end
    end
end)
