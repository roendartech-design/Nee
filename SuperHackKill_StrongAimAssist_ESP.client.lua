-- Super Hack Kill - Strong Aim Assist + ESP
-- For your own Roblox experience. Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- This is a Studio/game-development implementation, not an executor script.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AIM_ENABLED = false
local ESP_ENABLED = false
local ESP_FOLDER_NAME = "SuperHackKill_ESP"
local aimConnection
local espConnections = {}
local tracked = {}

-- Simple Rayfield-inspired panel with only the two requested toggles.
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("SuperHackKillPanel")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SuperHackKillPanel"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Main"
panel.Size = UDim2.fromOffset(260, 142)
panel.Position = UDim2.new(0, 24, 0.45, -71)
panel.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(91, 97, 115)
stroke.Thickness = 1
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 34)
header.Position = UDim2.fromOffset(12, 4)
header.BackgroundTransparency = 1
header.Font = Enum.Font.GothamBold
header.Text = "SUPER HACK KILL"
header.TextColor3 = Color3.fromRGB(245, 245, 250)
header.TextSize = 15
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local function makeToggle(labelText, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 39)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(39, 42, 53)
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(235, 237, 243)
    button.Parent = panel
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)

    local enabled = false
    local function refresh()
        button.Text = labelText .. (enabled and "     ON" or "     OFF")
        button.BackgroundColor3 = enabled and Color3.fromRGB(36, 112, 83) or Color3.fromRGB(39, 42, 53)
    end
    button.Activated:Connect(function()
        enabled = not enabled
        refresh()
        callback(enabled)
    end)
    refresh()
end

local function isAlive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    return humanoid ~= nil and humanoid.Health > 0 and head ~= nil
end

local function getBestTarget()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local bestCharacter = nil
    local bestScreenDistance = math.huge
    local viewport = Camera.ViewportSize
    local screenCenter = Vector2.new(viewport.X / 2, viewport.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player.Character) then
            local head = player.Character:FindFirstChild("Head")
            local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and screenPoint.Z > 0 then
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude
                if distance < bestScreenDistance then
                    bestScreenDistance = distance
                    bestCharacter = player.Character
                end
            end
        end
    end
    return bestCharacter
end

local function setAim(enabled)
    AIM_ENABLED = enabled
    if aimConnection then
        aimConnection:Disconnect()
        aimConnection = nil
    end
    if enabled then
        -- Strong lock: reacquires the closest visible player's head every rendered frame.
        aimConnection = RunService.RenderStepped:Connect(function()
            if not AIM_ENABLED then return end
            local character = getBestTarget()
            local head = character and character:FindFirstChild("Head")
            Camera = workspace.CurrentCamera
            if head and Camera then
                local cameraPosition = Camera.CFrame.Position
                Camera.CFrame = CFrame.lookAt(cameraPosition, head.Position)
            end
        end)
    end
end

local function removeESP(player)
    local data = tracked[player]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    tracked[player] = nil
end

local function addESP(player)
    if player == LocalPlayer or tracked[player] then return end
    local character = player.Character
    if not character then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = ESP_FOLDER_NAME .. "_Highlight"
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 65, 80)
    highlight.OutlineColor = Color3.fromRGB(255, 225, 225)
    highlight.FillTransparency = 0.65
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    local head = character:FindFirstChild("Head")
    local billboard
    if head then
        billboard = Instance.new("BillboardGui")
        billboard.Name = ESP_FOLDER_NAME .. "_Name"
        billboard.Adornee = head
        billboard.Size = UDim2.fromOffset(150, 26)
        billboard.StudsOffset = Vector3.new(0, 2.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = player:WaitForChild("PlayerGui", 0.1) or playerGui

        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = player.DisplayName
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.25
        label.TextSize = 13
        label.Parent = billboard
    end

    tracked[player] = { highlight = highlight, billboard = billboard }
end

local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            removeESP(player)
            if ESP_ENABLED then addESP(player) end
        end
    end
end

local function setESP(enabled)
    ESP_ENABLED = enabled
    if enabled then
        refreshESP()
    else
        for player in pairs(tracked) do removeESP(player) end
    end
end

makeToggle("AIMBOT", 43, setAim)
makeToggle("ESP", 89, setESP)

local function hookPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if ESP_ENABLED then
            removeESP(player)
            addESP(player)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do hookPlayer(player) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

-- Keep ESP in sync when players respawn or join while enabled.
RunService.Heartbeat:Connect(function()
    if not ESP_ENABLED then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local current = tracked[player]
            if not current or not current.highlight or current.highlight.Adornee ~= player.Character then
                removeESP(player)
                addESP(player)
            end
        end
    end
end)
