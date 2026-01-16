--[[
    Serdiums ESP Module
    Gamesense-style ESP System
]]

-- Check if Drawing API exists
if not Drawing then
    return {
        Enabled = false,
        Start = function() warn("[Serdiums ESP] Drawing API not available") end,
        Stop = function() end,
        Toggle = function() end
    }
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local ESP = {
    Enabled = false,
    TeamCheck = false,
    
    -- Toggles
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = false,
    
    -- Settings
    MaxDistance = 2000,
    BoxThickness = 1,
    TracerOrigin = "Bottom", -- Top, Center, Bottom
    
    -- Colors
    BoxColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthHigh = Color3.fromRGB(0, 255, 0),
    HealthLow = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
    
    -- Font
    Font = 2, -- Drawing.Fonts.Plex
    FontSize = 13,
    
    -- Internal
    Objects = {},
    Connections = {}
}

local function NewDrawing(class, props)
    local drawing = Drawing.new(class)
    for k, v in pairs(props or {}) do
        drawing[k] = v
    end
    return drawing
end

local function WorldToScreen(position)
    local vector, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(vector.X, vector.Y), onScreen, vector.Z
end

local function GetCharacter(player)
    return player.Character
end

local function GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
end

local function GetHead(character)
    return character and character:FindFirstChild("Head")
end

local function IsAlive(player)
    local char = GetCharacter(player)
    local humanoid = GetHumanoid(char)
    return humanoid and humanoid.Health > 0
end

local function IsTeammate(player)
    if not ESP.TeamCheck then return false end
    if not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function GetDistance(position)
    local rootPart = GetRootPart(LocalPlayer.Character)
    if not rootPart then return math.huge end
    return (rootPart.Position - position).Magnitude
end

local function GetBoundingBox(character)
    local rootPart = GetRootPart(character)
    if not rootPart then return nil, nil end
    
    local position = rootPart.Position
    local top = (character:FindFirstChild("Head") or rootPart).Position + Vector3.new(0, 1.5, 0)
    local bottom = position - Vector3.new(0, 3, 0)
    
    local topScreen, topVisible = WorldToScreen(top)
    local bottomScreen, bottomVisible = WorldToScreen(bottom)
    
    if not topVisible and not bottomVisible then
        return nil, nil
    end
    
    local height = bottomScreen.Y - topScreen.Y
    local width = height / 2
    
    local boxPosition = Vector2.new(topScreen.X - width / 2, topScreen.Y)
    local boxSize = Vector2.new(width, height)
    
    return boxPosition, boxSize
end

function ESP:CreateObject(player)
    if player == LocalPlayer then return end
    
    local object = {
        Player = player,
        Box = NewDrawing("Square", {
            Thickness = self.BoxThickness,
            Filled = false,
            Visible = false
        }),
        BoxOutline = NewDrawing("Square", {
            Thickness = self.BoxThickness + 2,
            Color = Color3.new(0, 0, 0),
            Filled = false,
            Visible = false
        }),
        Name = NewDrawing("Text", {
            Size = self.FontSize,
            Font = self.Font,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Visible = false
        }),
        Health = NewDrawing("Square", {
            Filled = true,
            Visible = false
        }),
        HealthOutline = NewDrawing("Square", {
            Filled = false,
            Color = Color3.new(0, 0, 0),
            Thickness = 1,
            Visible = false
        }),
        Distance = NewDrawing("Text", {
            Size = self.FontSize - 1,
            Font = self.Font,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Visible = false
        }),
        Tracer = NewDrawing("Line", {
            Thickness = 1,
            Visible = false
        }),
        TracerOutline = NewDrawing("Line", {
            Thickness = 3,
            Color = Color3.new(0, 0, 0),
            Visible = false
        })
    }
    
    self.Objects[player] = object
end

function ESP:RemoveObject(player)
    local object = self.Objects[player]
    if not object then return end
    
    for _, drawing in pairs(object) do
        if typeof(drawing) == "table" and drawing.Remove then
            drawing:Remove()
        end
    end
    
    self.Objects[player] = nil
end

function ESP:UpdateObject(player)
    local object = self.Objects[player]
    if not object then return end
    
    local character = GetCharacter(player)
    local humanoid = GetHumanoid(character)
    local rootPart = GetRootPart(character)
    
    -- Check visibility conditions
    local visible = self.Enabled
        and character
        and rootPart
        and humanoid
        and humanoid.Health > 0
        and not IsTeammate(player)
    
    if visible then
        local distance = GetDistance(rootPart.Position)
        visible = distance <= self.MaxDistance
    end
    
    if not visible then
        for name, drawing in pairs(object) do
            if name ~= "Player" and drawing.Visible ~= nil then
                drawing.Visible = false
            end
        end
        return
    end
    
    local boxPos, boxSize = GetBoundingBox(character)
    
    if not boxPos or not boxSize then
        for name, drawing in pairs(object) do
            if name ~= "Player" and drawing.Visible ~= nil then
                drawing.Visible = false
            end
        end
        return
    end
    
    local distance = GetDistance(rootPart.Position)
    
    -- Box
    if self.Boxes then
        object.BoxOutline.Position = boxPos - Vector2.new(1, 1)
        object.BoxOutline.Size = boxSize + Vector2.new(2, 2)
        object.BoxOutline.Visible = true
        
        object.Box.Position = boxPos
        object.Box.Size = boxSize
        object.Box.Color = self.BoxColor
        object.Box.Visible = true
    else
        object.Box.Visible = false
        object.BoxOutline.Visible = false
    end
    
    -- Name
    if self.Names then
        object.Name.Text = player.DisplayName
        object.Name.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y - self.FontSize - 2)
        object.Name.Color = self.NameColor
        object.Name.Visible = true
    else
        object.Name.Visible = false
    end
    
    -- Health
    if self.Health and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthHeight = boxSize.Y * healthPercent
        local healthColor = self.HealthLow:Lerp(self.HealthHigh, healthPercent)
        
        object.HealthOutline.Position = Vector2.new(boxPos.X - 5, boxPos.Y)
        object.HealthOutline.Size = Vector2.new(3, boxSize.Y)
        object.HealthOutline.Visible = true
        
        object.Health.Position = Vector2.new(boxPos.X - 4, boxPos.Y + boxSize.Y - healthHeight)
        object.Health.Size = Vector2.new(2, healthHeight)
        object.Health.Color = healthColor
        object.Health.Visible = true
    else
        object.Health.Visible = false
        object.HealthOutline.Visible = false
    end
    
    -- Distance
    if self.Distance then
        object.Distance.Text = string.format("[%dm]", math.floor(distance))
        object.Distance.Position = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y + 2)
        object.Distance.Color = self.NameColor
        object.Distance.Visible = true
    else
        object.Distance.Visible = false
    end
    
    -- Tracer
    if self.Tracers then
        local screenSize = Camera.ViewportSize
        local startPos
        
        if self.TracerOrigin == "Top" then
            startPos = Vector2.new(screenSize.X / 2, 0)
        elseif self.TracerOrigin == "Center" then
            startPos = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        else
            startPos = Vector2.new(screenSize.X / 2, screenSize.Y)
        end
        
        local endPos = Vector2.new(boxPos.X + boxSize.X / 2, boxPos.Y + boxSize.Y)
        
        object.TracerOutline.From = startPos
        object.TracerOutline.To = endPos
        object.TracerOutline.Visible = true
        
        object.Tracer.From = startPos
        object.Tracer.To = endPos
        object.Tracer.Color = self.TracerColor
        object.Tracer.Visible = true
    else
        object.Tracer.Visible = false
        object.TracerOutline.Visible = false
    end
end

function ESP:Start()
    -- Stop if already running
    self:Stop()
    
    -- Create for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateObject(player)
        end
    end
    
    -- Player added
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        task.wait(1) -- Wait for character
        if player ~= LocalPlayer then
            self:CreateObject(player)
        end
    end))
    
    -- Player removed
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        self:RemoveObject(player)
    end))
    
    -- Update loop
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        Camera = workspace.CurrentCamera
        for player, _ in pairs(self.Objects) do
            if player and player.Parent then
                self:UpdateObject(player)
            end
        end
    end))
    
    print("[Serdiums ESP] Started - Tracking", #Players:GetPlayers() - 1, "players")
end

function ESP:Stop()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
    
    for player in pairs(self.Objects) do
        self:RemoveObject(player)
    end
end

function ESP:Toggle(state)
    self.Enabled = state
    if not state then
        for _, object in pairs(self.Objects) do
            for name, drawing in pairs(object) do
                if name ~= "Player" and drawing.Visible ~= nil then
                    drawing.Visible = false
                end
            end
        end
    end
end

return ESP
