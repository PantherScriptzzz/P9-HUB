-- Function to initialize individual features
local function toggleCFrameMovement()
    cframeMovementEnabled = not cframeMovementEnabled
    debugStatus("CFrame Movement", cframeMovementEnabled)
end

local function toggleESP()
    espEnabled = not espEnabled
    debugStatus("ESP", espEnabled)

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

local function toggleAutoShoot()
    autoShootEnabled = not autoShootEnabled
    debugStatus("Auto Shoot", autoShootEnabled)
end

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

local function lockOntoTarget()
    -- Lock onto the closest player
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

-- Main Hub GUI Creation
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

    -- Creating buttons for each feature
    local features = {
        {name = "CFrame Movement", toggleFunc = toggleCFrameMovement},
        {name = "ESP Toggle", toggleFunc = toggleESP},
        {name = "Auto Shoot", toggleFunc = toggleAutoShoot},
        {name = "Teleport to Player", toggleFunc = teleportToPlayer},
        {name = "Lock On Target", toggleFunc = lockOntoTarget}
    }

    for i, feature in ipairs(features) do
        local button = Instance.new("TextButton", mainFrame)
        button.Size = UDim2.new(0.9, 0, 0.12, 0)
        button.Position = UDim2.new(0.05, 0, 0.1 + (0.15 * (i - 1)), 0)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.Text = feature.name
        button.TextColor3 = Color3.new(1, 0, 0) -- Red text color
        button.TextScaled = true
        button.Font = Enum.Font.SourceSansBold

        button.MouseButton1Click:Connect(function()
            feature.toggleFunc() -- Call the feature's toggle function
        end)

        local buttonCorner = Instance.new("UICorner", button)
        buttonCorner.CornerRadius = UDim.new(0.05, 0)
    end
end

-- Toggle GUI visibility with CTRL key
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.LeftControl then
            hubVisible = not hubVisible
            hubGui.Visible = hubVisible
        end
    end
end)

-- Run the UI Creation
createWelcomeUI()
createHubUI()
