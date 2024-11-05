-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local espHighlights = {}
local espEnabled = true -- Track if ESP is enabled

-- Variables for locking onto players
local targetPlayer = nil -- Currently locked-on player
local isLocked = false -- Track if we are locked onto a player
local autoShootActive = false -- Track auto-shoot status
local cframeMovementEnabled = false -- Track CFrame movement toggle
local speedMultiplier = 1 -- Initial speed multiplier for the player's movement
local minSpeedMultiplier = 1 -- Minimum speed multiplier
local maxSpeedMultiplier = 5 -- Maximum speed multiplier

-- Function to create GUI to show "Welcome to P9 HUB!" message
local function CreateScriptLoadedGUI()
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    local label = Instance.new("TextLabel", screenGui)

    label.Size = UDim2.new(0.3, 0, 0.1, 0)
    label.Position = UDim2.new(0.35, 0, 0.45, 0)
    label.Text = "Welcome to P9 HUB!" -- Updated text
    label.TextSize = 30
    label.Font = Enum.Font.SourceSansBold
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.TextTransparency = 1
    label.BackgroundTransparency = 1

    -- Add glow effect
    local glowEffect = TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 0})
    glowEffect:Play()

    -- Dark effect for the game background
    local darkOverlay = Instance.new("Frame", screenGui)
    darkOverlay.Size = UDim2.new(1, 0, 1, 0)
    darkOverlay.BackgroundColor3 = Color3.new(0, 0, 0) -- Black color
    darkOverlay.BackgroundTransparency = 0 -- Start fully opaque
    TweenService:Create(darkOverlay, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()

    -- Remove GUI after 5 seconds
    wait(5)
    screenGui:Destroy()
end

-- Call GUI creation function
CreateScriptLoadedGUI()

-- Function to get the closest player to the mouse cursor
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

-- Function to lock onto the selected player instantly
local function LockOntoPlayer()
    if isLocked and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1, 0) -- Slight upward offset
        -- Instantly change the camera's CFrame to look at the target
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition) -- Directly point to the target
    end
end

-- Function to add ESP and name label for all players except the local player
local function UpdateESP()
    -- Clear existing ESP highlights and name tags
    for _, highlight in pairs(espHighlights) do
        highlight:Destroy()
    end
    espHighlights = {}

    -- Apply ESP and name label to all other players
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                -- Create highlight for ESP effect
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP"
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.FillTransparency = 0.8
                highlight.OutlineTransparency = 0
                highlight.Adornee = player.Character
                highlight.Parent = player.Character
                table.insert(espHighlights, highlight)

                -- Create a BillboardGui to display the player’s name above their character
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Name = "NameTag"
                billboardGui.Adornee = player.Character:FindFirstChild("Head") -- Attach to head
                billboardGui.Size = UDim2.new(2, 0, 0.5, 0) -- Initial size
                billboardGui.StudsOffset = Vector3.new(0, 2, 0) -- Position above head
                billboardGui.AlwaysOnTop = true

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Parent = billboardGui
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 0, 0) -- Red text color
                nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.TextSize = 14

                billboardGui.Parent = player.Character
            end
        end
    else
        -- If ESP is disabled, hide name tags
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local billboardGui = player.Character:FindFirstChild("NameTag")
                if billboardGui then
                    billboardGui:Destroy() -- Completely remove the BillboardGui
                end
            end
        end
    end
end

-- Function to adjust size of each player's BillboardGui based on distance from local player
local function AdjustESPSize()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local billboardGui = player.Character:FindFirstChild("NameTag")
            if billboardGui then
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                -- Scale size based on distance, clamping to a minimum and maximum size
                local scale = math.clamp(10 / distance, 0.5, 2) -- Adjust "10" for sensitivity, 0.5 min size, 2 max size
                billboardGui.Size = UDim2.new(scale, 0, scale / 2, 0) -- Adjust height proportionally
            end
        end
    end
end

-- Teleport Function
local function TeleportToTarget()
    local teleportTarget = targetPlayer or GetClosestPlayer()
    if teleportTarget and teleportTarget.Character and teleportTarget.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character:SetPrimaryPartCFrame(teleportTarget.Character.HumanoidRootPart.CFrame)
    end
end

-- Auto-Shoot Function with rapid clicks
local function AutoShoot()
    autoShootActive = not autoShootActive

    if autoShootActive then
        -- Start shooting rapidly while the cursor is on the target player
        RunService.RenderStepped:Connect(function()
            if autoShootActive and targetPlayer and Mouse.Target and Mouse.Target:IsDescendantOf(targetPlayer.Character) then
                mouse1click() -- Simulate a left-click
            end
        end)
    end
end

-- Function to adjust the player's speed
local function AdjustSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Check if the player is moving and CFrame-based movement is enabled
        local moveDirection = Vector3.new(0, 0, 0)

        if cframeMovementEnabled then
            -- Calculate movement direction based on player input
            local forwardDirection = Camera.CFrame.LookVector * speedMultiplier
            local backwardDirection = -Camera.CFrame.LookVector * speedMultiplier
            local rightDirection = Camera.CFrame.RightVector * speedMultiplier
            local leftDirection = -Camera.CFrame.RightVector * speedMultiplier

            -- Detect input for movement
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + forwardDirection
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection + backwardDirection
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + rightDirection
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection + leftDirection
            end

            -- Move the player using CFrame
            if moveDirection.Magnitude > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + (moveDirection.Unit * speedMultiplier)
                LocalPlayer.Character.Humanoid.WalkSpeed = 16 * speedMultiplier -- Adjust walk speed based on multiplier
                LocalPlayer.Character.Humanoid.WalkSpeed = 16 * speedMultiplier -- Adjust walk speed based on multiplier
            else
                -- Reset speed to normal when CFrame movement is not enabled
                LocalPlayer.Character.Humanoid.WalkSpeed = 16 -- Reset to default walk speed
            end
        end
    end
end

-- User Input for Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.C then
            -- Lock onto the closest player
            if isLocked then
                targetPlayer = nil -- Unlock
                isLocked = false
            else
                targetPlayer = GetClosestPlayer() -- Lock onto closest player
                isLocked = true
            end
        elseif input.KeyCode == Enum.KeyCode.Q then
            -- Toggle CFrame movement on/off
            cframeMovementEnabled = not cframeMovementEnabled

        elseif input.KeyCode == Enum.KeyCode.P then
            -- Increase speed multiplier
            if speedMultiplier < maxSpeedMultiplier then
                speedMultiplier = speedMultiplier + 1
            end
        elseif input.KeyCode == Enum.KeyCode.M then
            -- Decrease speed multiplier
            if speedMultiplier > minSpeedMultiplier then
                speedMultiplier = speedMultiplier - 1
            end

        elseif input.KeyCode == Enum.KeyCode.Z then
            -- Teleport to nearest player or the currently locked target
            TeleportToTarget()

        elseif input.KeyCode == Enum.KeyCode.V then
            -- Toggle auto-shooting
            AutoShoot()
        elseif input.KeyCode == Enum.KeyCode.T then
            -- Toggle ESP and Billboard GUI visibility
            espEnabled = not espEnabled
            UpdateESP() -- Refresh ESP highlights and name tags
        end
    end
end)

-- Run the lock function on RenderStepped
RunService.RenderStepped:Connect(function()
    LockOntoPlayer() -- Keep the camera locked onto the target
    AdjustSpeed() -- Adjust the player's movement speed
    AdjustESPSize() -- Continuously adjust ESP sizes
end)

-- Update ESP every 5 seconds to check for new players
while true do
    wait(5)
    UpdateESP()
end
