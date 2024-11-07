-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Feature States
local espEnabled = false
local autoShootEnabled = false
local lockOnEnabled = false
local hubVisible = true

-- Debug Status Function
local function debugStatus(feature, state)
    print(feature .. (state and " enabled" or " disabled"))
end

-- Toggle Functions for Each Feature
local function toggleESP()
    espEnabled = not espEnabled
    debugStatus("ESP", espEnabled)

    if espEnabled then
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
                nameLabel.BackgroundTransparency = 0.3
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(1, 0, 0)
                nameLabel.TextScaled = true
            end
        end
    else
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

local function toggleAutoShoot()
    autoShootEnabled = not autoShootEnabled
    debugStatus("Auto Shoot", autoShootEnabled)
end

local function teleportToPlayer()
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

    if nearestPlayer then
        LocalPlayer.Character:SetPrimaryPartCFrame(nearestPlayer.Character.HumanoidRootPart.CFrame)
        print("Teleported to:", nearestPlayer.Name)
    end
end

local function toggleLockOnTarget()
    lockOnEnabled = not lockOnEnabled
    debugStatus("Lock On", lockOnEnabled)

    if lockOnEnabled then
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
            RunService:BindToRenderStep("LockOn", Enum.RenderPriority.Camera.Value + 1, function()
                if closestPlayer and closestPlayer.Character then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
                else
                    lockOnEnabled = false
                    RunService:UnbindFromRenderStep("LockOn")
                    debugStatus("Lock On", lockOnEnabled)
                end
            end)
        end
    else
        RunService:UnbindFromRenderStep("LockOn")
    end
end

-- Main Hub GUI Creation
local function createHubUI()
    local hubGui = Instance.new("ScreenGui", PlayerGui)
    hubGui.Name = "P9_HUB_GUI"

    local mainFrame = Instance.new("Frame", hubGui)
    mainFrame.Size = UDim2.new(0.3, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.Visible = hubVisible

    local uiCorner = Instance.new("UICorner", mainFrame)
    uiCorner.CornerRadius = UDim.new(0.05, 0)

    mainFrame.Active = true
    mainFrame.Draggable = true

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleLabel.BackgroundTransparency = 0.3
    titleLabel.Text = "P9 HUB"
    titleLabel.TextColor3 = Color3.new(1, 0, 0)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold

    local features = {
        {name = "ESP Toggle (T)", toggleFunc = toggleESP, key = Enum.KeyCode.T},
        {name = "Auto Shoot (V)", toggleFunc = toggleAutoShoot, key = Enum.KeyCode.V},
        {name = "Teleport to Player (Z)", toggleFunc = teleportToPlayer, key = Enum.KeyCode.Z},
        {name = "Lock On Target (C)", toggleFunc = toggleLockOnTarget, key = Enum.KeyCode.C}
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
            feature.toggleFunc()
        end)

        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0.05, 0)

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == feature.key then
                feature.toggleFunc()
            end
        end)
    end
end

-- Toggle GUI visibility with FN key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Function then
        hubVisible = not hubVisible
        local hubGui = PlayerGui:FindFirstChild("P9_HUB_GUI")
        if hubGui then
            hubGui.Visible = hubVisible
        end
    end
end)

-- Run the UI Creation
createHubUI()
