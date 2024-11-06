-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- Variables
local hubVisible = true
local espEnabled = false
local LockEvent = Instance.new("BindableEvent")
local ESPEvent = Instance.new("BindableEvent")
local AutoShootEvent = Instance.new("BindableEvent")
local TeleportEvent = Instance.new("BindableEvent")
local CFrameMovementEvent = Instance.new("BindableEvent")

-- Function to toggle the hub GUI visibility
local function toggleHubGUI()
    hubVisible = not hubVisible
    if playerGui:FindFirstChild("P9_HUB_GUI") then
        playerGui.P9_HUB_GUI.Enabled = hubVisible
    end
end

-- Create the main hub UI
local function createHubUI()
    -- Main ScreenGui for P9 HUB
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

    -- Feature Buttons with Events
    local features = {
        {name = "Lock On Target", event = LockEvent},
        {name = "ESP Toggle", event = ESPEvent},
        {name = "Auto Shoot", event = AutoShootEvent},
        {name = "Teleport to Player", event = TeleportEvent},
        {name = "CFrame Movement", event = CFrameMovementEvent}
    }

    for i, feature in ipairs(features) do
        local button = Instance.new("TextButton", mainFrame)
        button.Size = UDim2.new(0.9, 0, 0.12, 0)
        button.Position = UDim2.new(0.05, 0, 0.1 + (0.15 * (i - 1)), 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = feature.name
        button.TextColor3 = Color3.new(1, 0, 0)
        button.TextScaled = true
        button.Font = Enum.Font.SourceSansBold

        button.MouseButton1Click:Connect(function()
            feature.event:Fire()  -- Fire the event when button is clicked
        end)

        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0.05, 0)
    end
end

-- Toggle GUI visibility with CTRL key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            toggleHubGUI()
        end
    end
end)

-- Run the UI Creation
createHubUI()

-- Expose the events so other scripts can use them
_G.LockEvent = LockEvent
_G.ESPEvent = ESPEvent
_G.AutoShootEvent = AutoShootEvent
_G.TeleportEvent = TeleportEvent
_G.CFrameMovementEvent = CFrameMovementEvent

--[[
-----------------------------------------
Lock Script: Lock onto the nearest target
-----------------------------------------
]]
_G.LockEvent.Event:Connect(function()
    local function lockOntoNearest()
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
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
            print("Locked onto:", closestPlayer.Name)
        end
    end

    lockOntoNearest()
end)

--[[
-----------------------------------------
ESP Script: Toggle ESP to highlight players and show names
-----------------------------------------
]]
_G.ESPEvent.Event:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        -- Enable ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = player.Character
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(0, 0, 0)
                highlight.FillTransparency = 0.8
                highlight.Name = "ESPHighlight"

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
        -- Disable ESP
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                local nameTag = player.Character:FindFirstChild("Head"):FindFirstChild("NameTag")
                if highlight then highlight:Destroy() end
                if nameTag then nameTag:Destroy() end
            end
        end
    end
end)

--[[
-----------------------------------------
Auto Shoot Script: Automatically shoot when target is in crosshairs
-----------------------------------------
]]
_G.AutoShootEvent.Event:Connect(function()
    local function autoShoot()
        -- Add logic for auto-shooting
        print("Auto shoot activated")
    end

    autoShoot()
end)

--[[
-----------------------------------------
Teleport Script: Teleport to nearest player
-----------------------------------------
]]
_G.TeleportEvent.Event:Connect(function()
    local function teleportToNearestPlayer()
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
            LocalPlayer.Character:MoveTo(closestPlayer.Character.HumanoidRootPart.Position)
            print("Teleported to:", closestPlayer.Name)
        end
    end

    teleportToNearestPlayer()
end)

--[[
-----------------------------------------
CFrame Movement Script: Smooth movement of player when enabled
-----------------------------------------
]]
_G.CFrameMovementEvent.Event:Connect(function()
    local function cFrameMovement()
        -- Code for cFrame movement
        print("CFrame Movement enabled")
    end

    cFrameMovement()
end)
