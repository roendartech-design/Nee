-- Super Hack Kill - Studio Aim Assist + ESP
-- Install as a LocalScript in StarterPlayer > StarterPlayerScripts.
-- Designed for your own Roblox experience; no executor or external UI library required.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local AIM_SMOOTHNESS = 0.16 -- Lower = slower, higher = faster. Keep below 1.
local MAX_FOV_PIXELS = 180
local MAX_DISTANCE = 500

local aimEnabled = false
local espEnabled = false
local visibleOnly = true

local highlights = {}
local billboards = {}
local currentTarget = nil

local function characterOf(player)
    return player.Character
end

local function isAlive(player)
    local character = characterOf(player)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function hasLineOfSight(player, targetPart)
    local character = localPlayer.Character
    if not character then return false end

    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { character }

    local result = Workspace:Raycast(origin, direction, params)
    return result ~= nil and result.Instance:IsDescendantOf(player.Character)
end

local function getTarget()
    local bestPlayer = nil
    local bestDistance = MAX_FOV_PIXELS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and isAlive(player) then
            local character = characterOf(player)
            local head = character and character:FindFirstChild("Head")

            if head then
                local distance = (head.Position - camera.CFrame.Position).Magnitude
                local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)

                if onScreen and screenPoint.Z > 0 and distance <= MAX_DISTANCE then
                    local center = camera.ViewportSize / 2
                    local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude

                    if screenDistance < bestDistance and (not visibleOnly or hasLineOfSight(player, head)) then
                        bestDistance = screenDistance
                        bestPlayer = player
                    end
                end
            end
        end
    end

    return bestPlayer
end

local function clearEsp(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if billboards[player] then
        billboards[player]:Destroy()
        billboards[player] = nil
    end
end

local function createEsp(player)
    if player == localPlayer then return end
    local character = characterOf(player)
    local head = character and character:FindFirstChild("Head")
    if not character or not head then return end

    if not highlights[player] or highlights[player].Parent ~= character then
        clearEsp(player)

        local highlight = Instance.new("Highlight")
        highlight.Name = "SHK_PlayerESP"
        highlight.FillTransparency = 0.78
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
        highlights[player] = highlight

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "SHK_PlayerLabel"
        billboard.Adornee = head
        billboard.Size = UDim2.fromOffset(150, 30)
        billboard.StudsOffset = Vector3.new(0, 2.2, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.35
        label.Text = player.DisplayName
        label.Parent = billboard

        billboards[player] = billboard
    end
end

local function updateEsp()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if espEnabled then
                createEsp(player)
            else
                clearEsp(player)
            end
        end
    end
end

-- Lightweight in-game control panel (Studio-compatible).
local gui = Instance.new("ScreenGui")
gui.Name = "SuperHackKillPanel"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(220, 174)
panel.Position = UDim2.new(0, 18, 0.5, -87)
panel.BackgroundColor3 = Color3.fromRGB(22, 24, 31)
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 34)
title.Position = UDim2.fromOffset(8, 4)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "SUPER HACK KILL"
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = panel

local function makeToggle(text, y, initial, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 34)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 52, 65)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = panel

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 7)
    buttonCorner.Parent = button

    local state = initial
    local function refresh()
        button.Text = text .. ": " .. (state and "ON" or "OFF")
        button.BackgroundColor3 = state and Color3.fromRGB(45, 125, 88) or Color3.fromRGB(48, 52, 65)
    end

    button.Activated:Connect(function()
        state = not state
        refresh()
        callback(state)
    end)

    refresh()
    return button
end

makeToggle("AIMBOT", 43, false, function(value)
    aimEnabled = value
    currentTarget = nil
end)

makeToggle("ESP", 83, false, function(value)
    espEnabled = value
    updateEsp()
end)

makeToggle("VISIBLE ONLY", 123, true, function(value)
    visibleOnly = value
    currentTarget = nil
end)

Players.PlayerRemoving:Connect(function(player)
    clearEsp(player)
    if currentTarget == player then currentTarget = nil end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then createEsp(player) end
    end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espEnabled then createEsp(player) end
        end)
    end
end

RunService.RenderStepped:Connect(function()
    camera = Workspace.CurrentCamera
    if espEnabled then
        updateEsp()
    end

    if not aimEnabled then
        currentTarget = nil
        return
    end

    if not currentTarget or not isAlive(currentTarget) then
        currentTarget = getTarget()
    end

    if currentTarget then
        local character = characterOf(currentTarget)
        local head = character and character:FindFirstChild("Head")

        if not head or (visibleOnly and not hasLineOfSight(currentTarget, head)) then
            currentTarget = getTarget()
            character = currentTarget and characterOf(currentTarget)
            head = character and character:FindFirstChild("Head")
        end

        if head then
            local desired = CFrame.lookAt(camera.CFrame.Position, head.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, AIM_SMOOTHNESS)
        end
    end
end)
