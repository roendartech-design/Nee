-- Super Hack Kill - Roblox Studio LocalScript
-- Use in your OWN Roblox experience. Place in StarterPlayer > StarterPlayerScripts.
-- Includes draggable menu/icon, moderate camera aim assist, player highlights,
-- and a separate fly control panel with UP/DOWN and adjustable speed.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("SuperHackKill")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SuperHackKill"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(65, 65, 80)
    s.Thickness = thickness or 1
    s.Parent = obj
end

local function makeButton(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(38, 40, 52)
    b.TextColor3 = Color3.fromRGB(240, 240, 245)
    b.Text = text
    b.TextSize = 13
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 7)
    return b
end

local function makeLabel(parent, text, size, position)
    local l = Instance.new("TextLabel")
    l.Size = size
    l.Position = position
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(225, 225, 235)
    l.Text = text
    l.TextSize = 13
    l.Font = Enum.Font.Gotham
    l.Parent = parent
    return l
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Floating icon: drag it around; tap it to show/hide the main menu.
local icon = Instance.new("ImageButton")
icon.Name = "OpenIcon"
icon.Size = UDim2.fromOffset(52, 52)
icon.Position = UDim2.new(0, 18, 0.45, 0)
icon.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
icon.Image = "rbxassetid://7072718362"
icon.ScaleType = Enum.ScaleType.Fit
icon.Parent = gui
corner(icon, 26)
stroke(icon, Color3.fromRGB(115, 85, 255), 2)

-- Main menu
local main = Instance.new("Frame")
main.Name = "MainMenu"
main.Size = UDim2.fromOffset(250, 250)
main.Position = UDim2.new(0.5, -125, 0.5, -125)
main.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
main.Parent = gui
corner(main, 12)
stroke(main, Color3.fromRGB(100, 75, 220), 1.5)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 38)
header.BackgroundColor3 = Color3.fromRGB(34, 31, 52)
header.Parent = main
corner(header, 10)
makeLabel(header, "SUPER HACK KILL", UDim2.new(1, -45, 1, 0), UDim2.fromOffset(12, 0)).TextXAlignment = Enum.TextXAlignment.Left
local closeMain = makeButton(header, "X", UDim2.fromOffset(28, 26), UDim2.new(1, -34, 0, 6))
closeMain.BackgroundColor3 = Color3.fromRGB(120, 45, 55)

local status = makeLabel(main, "Studio / own-game tools", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 43))
status.TextColor3 = Color3.fromRGB(150, 150, 170)

local aimBtn = makeButton(main, "AIM ASSIST: OFF", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 69))
local espBtn = makeButton(main, "ESP: OFF", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 108))
local visibleBtn = makeButton(main, "VISIBLE ONLY: ON", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 147))
local flyOpenBtn = makeButton(main, "FLY CONTROLS", UDim2.new(1, -20, 0, 34), UDim2.fromOffset(10, 190))
flyOpenBtn.BackgroundColor3 = Color3.fromRGB(80, 55, 175)

makeDraggable(main, header)

-- Separate fly panel. UP/DOWN move the character vertically while flight is enabled.
local flyPanel = Instance.new("Frame")
flyPanel.Name = "FlyPanel"
flyPanel.Size = UDim2.fromOffset(230, 220)
flyPanel.Position = UDim2.new(0.5, 15, 0.5, -110)
flyPanel.BackgroundColor3 = Color3.fromRGB(22, 23, 31)
flyPanel.Visible = false
flyPanel.Parent = gui
corner(flyPanel, 12)
stroke(flyPanel, Color3.fromRGB(80, 150, 255), 1.5)

local flyHeader = Instance.new("Frame")
flyHeader.Size = UDim2.new(1, 0, 0, 36)
flyHeader.BackgroundColor3 = Color3.fromRGB(28, 48, 70)
flyHeader.Parent = flyPanel
corner(flyHeader, 10)
makeLabel(flyHeader, "FLY CONTROL", UDim2.new(1, -75, 1, 0), UDim2.fromOffset(10, 0)).TextXAlignment = Enum.TextXAlignment.Left
local minimizeFly = makeButton(flyHeader, "–", UDim2.fromOffset(26, 25), UDim2.new(1, -62, 0, 5))
local closeFly = makeButton(flyHeader, "X", UDim2.fromOffset(26, 25), UDim2.new(1, -31, 0, 5))
closeFly.BackgroundColor3 = Color3.fromRGB(120, 45, 55)
makeDraggable(flyPanel, flyHeader)

local flyBody = Instance.new("Frame")
flyBody.Size = UDim2.new(1, 0, 1, -38)
flyBody.Position = UDim2.fromOffset(0, 38)
flyBody.BackgroundTransparency = 1
flyBody.Parent = flyPanel

local flyToggle = makeButton(flyBody, "FLY: OFF", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 8))
flyToggle.BackgroundColor3 = Color3.fromRGB(45, 105, 75)
local upBtn = makeButton(flyBody, "UP ▲", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 48))
local downBtn = makeButton(flyBody, "DOWN ▼", UDim2.new(1, -20, 0, 32), UDim2.fromOffset(10, 88))
local speedLabel = makeLabel(flyBody, "SPEED: 50", UDim2.new(1, -100, 0, 30), UDim2.fromOffset(10, 137))
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
local minusBtn = makeButton(flyBody, "−", UDim2.fromOffset(42, 30), UDim2.new(1, -100, 0, 137))
local plusBtn = makeButton(flyBody, "+", UDim2.fromOffset(42, 30), UDim2.new(1, -52, 0, 137))

-- Drag/tap behavior for the floating icon.
local iconDragging, iconStart, iconPos, iconMoved = false, nil, nil, false
icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconMoved = false
        iconStart = input.Position
        iconPos = icon.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                iconDragging = false
                if not iconMoved then main.Visible = not main.Visible end
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - iconStart
        if delta.Magnitude > 5 then iconMoved = true end
        icon.Position = UDim2.new(iconPos.X.Scale, iconPos.X.Offset + delta.X,
            iconPos.Y.Scale, iconPos.Y.Offset + delta.Y)
    end
end)

closeMain.Activated:Connect(function() main.Visible = false end)
flyOpenBtn.Activated:Connect(function() flyPanel.Visible = true end)
closeFly.Activated:Connect(function() flyPanel.Visible = false end)
local minimized = false
minimizeFly.Activated:Connect(function()
    minimized = not minimized
    flyBody.Visible = not minimized
    flyPanel.Size = minimized and UDim2.fromOffset(230, 36) or UDim2.fromOffset(230, 220)
    minimizeFly.Text = minimized and "+" or "–"
end)

-- Aim assist (camera smoothing, intended for NPC/player testing in your own experience).
local aimEnabled = false
local visibleOnly = true
local aimConnection
local function hasLineOfSight(character, targetPart)
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local origin = camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    local result = Workspace:Raycast(origin, targetPart.Position - origin, params)
    return result == nil or result.Instance:IsDescendantOf(character)
end

local function getAimTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil end
    local center = camera.ViewportSize / 2
    local best, bestDistance = nil, 150
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character then
            local hum = other.Character:FindFirstChildOfClass("Humanoid")
            local head = other.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and head then
                local point, onScreen = camera:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(point.X, point.Y) - center).Magnitude
                if onScreen and distance < bestDistance and (not visibleOnly or hasLineOfSight(other.Character, head)) then
                    best, bestDistance = head, distance
                end
            end
        end
    end
    return best
end

aimBtn.Activated:Connect(function()
    aimEnabled = not aimEnabled
    aimBtn.Text = aimEnabled and "AIM ASSIST: ON" or "AIM ASSIST: OFF"
end)
visibleBtn.Activated:Connect(function()
    visibleOnly = not visibleOnly
    visibleBtn.Text = visibleOnly and "VISIBLE ONLY: ON" or "VISIBLE ONLY: OFF"
end)

-- ESP highlights
local espEnabled = false
local highlights = {}
local function clearHighlights()
    for _, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    table.clear(highlights)
end
local function addHighlight(other)
    if other == player or not other.Character or highlights[other] then return end
    local h = Instance.new("Highlight")
    h.Name = "SHK_ESP"
    h.FillColor = Color3.fromRGB(120, 75, 255)
    h.OutlineColor = Color3.fromRGB(235, 235, 255)
    h.FillTransparency = 0.65
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = other.Character
    h.Parent = gui
    highlights[other] = h
end
local function refreshHighlights()
    if not espEnabled then return end
    for _, other in ipairs(Players:GetPlayers()) do addHighlight(other) end
end
espBtn.Activated:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    if espEnabled then refreshHighlights() else clearHighlights() end
end)
Players.PlayerAdded:Connect(function(other)
    other.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then
            if highlights[other] then highlights[other]:Destroy(); highlights[other] = nil end
            addHighlight(other)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(other)
    if highlights[other] then highlights[other]:Destroy(); highlights[other] = nil end
end)
for _, other in ipairs(Players:GetPlayers()) do
    if other ~= player then
        other.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espEnabled then
                if highlights[other] then highlights[other]:Destroy(); highlights[other] = nil end
                addHighlight(other)
            end
        end)
    end
end

-- Modern constraint-based flight. UP/DOWN buttons also work on touch screens.
local flying = false
local flySpeed = 50
local vertical = 0
local flyAttachment, flyVelocity, flyOrientation
local keyState = {W=false, A=false, S=false, D=false, Space=false, Ctrl=false}

local function destroyFlightObjects()
    if flyVelocity then flyVelocity:Destroy(); flyVelocity = nil end
    if flyOrientation then flyOrientation:Destroy(); flyOrientation = nil end
    if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
end

local function stopFlying()
    flying = false
    vertical = 0
    destroyFlightObjects()
    flyToggle.Text = "FLY: OFF"
    flyToggle.BackgroundColor3 = Color3.fromRGB(45, 105, 75)
end

local function startFlying()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end
    destroyFlightObjects()
    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "SHK_FlyAttachment"
    flyAttachment.Parent = root

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "SHK_FlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.MaxForce = 100000
    flyVelocity.Parent = root

    flyOrientation = Instance.new("AlignOrientation")
    flyOrientation.Name = "SHK_FlyOrientation"
    flyOrientation.Attachment0 = flyAttachment
    flyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    flyOrientation.MaxTorque = 100000
    flyOrientation.Responsiveness = 15
    flyOrientation.Parent = root

    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    flying = true
    flyToggle.Text = "FLY: ON"
    flyToggle.BackgroundColor3 = Color3.fromRGB(35, 145, 85)
end

flyToggle.Activated:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

local function setHoldButton(button, value)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            vertical = value
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if vertical == value then vertical = 0 end
        end
    end)
end
setHoldButton(upBtn, 1)
setHoldButton(downBtn, -1)

plusBtn.Activated:Connect(function()
    flySpeed = math.clamp(flySpeed + 10, 10, 200)
    speedLabel.Text = "SPEED: " .. flySpeed
end)
minusBtn.Activated:Connect(function()
    flySpeed = math.clamp(flySpeed - 10, 10, 200)
    speedLabel.Text = "SPEED: " .. flySpeed
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.W then keyState.W = true end
    if input.KeyCode == Enum.KeyCode.A then keyState.A = true end
    if input.KeyCode == Enum.KeyCode.S then keyState.S = true end
    if input.KeyCode == Enum.KeyCode.D then keyState.D = true end
    if input.KeyCode == Enum.KeyCode.Space then keyState.Space = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then keyState.Ctrl = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then keyState.W = false end
    if input.KeyCode == Enum.KeyCode.A then keyState.A = false end
    if input.KeyCode == Enum.KeyCode.S then keyState.S = false end
    if input.KeyCode == Enum.KeyCode.D then keyState.D = false end
    if input.KeyCode == Enum.KeyCode.Space then keyState.Space = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then keyState.Ctrl = false end
end)

local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local camera = Workspace.CurrentCamera
        local target = getAimTarget()
        if camera and target then
            local desired = CFrame.lookAt(camera.CFrame.Position, target.Position)
            camera.CFrame = camera.CFrame:Lerp(desired, 0.12)
        end
    end

    if flying and flyVelocity and flyOrientation then
        local camera = Workspace.CurrentCamera
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not camera or not root or not flyVelocity.Parent then
            stopFlying()
            return
        end
        local move = Vector3.zero
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        if keyState.W then move += forward end
        if keyState.S then move -= forward end
        if keyState.D then move += right end
        if keyState.A then move -= right end
        local y = vertical
        if keyState.Space then y = 1 end
        if keyState.Ctrl then y = -1 end
        if move.Magnitude > 0 then move = move.Unit end
        flyVelocity.VectorVelocity = move * flySpeed + Vector3.new(0, y * flySpeed, 0)
        flyOrientation.CFrame = CFrame.lookAt(root.Position, root.Position + Vector3.new(forward.X, 0, forward.Z))
    end
end)

player.CharacterAdded:Connect(function()
    if flying then
        task.wait(0.4)
        startFlying()
    end
end)

script.Destroying:Connect(function()
    stopFlying()
    clearHighlights()
    if renderConnection then renderConnection:Disconnect() end
end)
