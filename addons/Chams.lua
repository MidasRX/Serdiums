--[[
    Serdiums Chams Module
    Highlight-based Chams System
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Chams = {
    Enabled = false,
    TeamCheck = false,
    
    -- Colors
    FillColor = Color3.fromRGB(170, 0, 255),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    
    -- Settings
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    
    -- Internal
    Highlights = {},
    Connections = {},
    Container = nil
}

function Chams:CreateHighlight(player)
    if player == LocalPlayer then return end
    if self.Highlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "SerdiumsChams_" .. player.Name
    highlight.FillColor = self.FillColor
    highlight.OutlineColor = self.OutlineColor
    highlight.FillTransparency = self.FillTransparency
    highlight.OutlineTransparency = self.OutlineTransparency
    highlight.DepthMode = self.DepthMode
    highlight.Enabled = self.Enabled
    
    -- Parent to container
    if not self.Container or not self.Container.Parent then
        self.Container = Instance.new("Folder")
        self.Container.Name = "SerdiumsChams"
        self.Container.Parent = game:GetService("CoreGui")
    end
    highlight.Parent = self.Container
    
    self.Highlights[player] = highlight
    
    -- Update adornee when character changes
    local function updateAdornee()
        local char = player.Character
        if char then
            highlight.Adornee = char
        else
            highlight.Adornee = nil
        end
    end
    
    updateAdornee()
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        updateAdornee()
    end)
    
    player.CharacterRemoving:Connect(function()
        highlight.Adornee = nil
    end)
end

function Chams:RemoveHighlight(player)
    local highlight = self.Highlights[player]
    if highlight then
        highlight:Destroy()
        self.Highlights[player] = nil
    end
end

function Chams:UpdateHighlight(player)
    local highlight = self.Highlights[player]
    if not highlight then return end
    
    local char = player.Character
    local shouldShow = self.Enabled and char
    
    -- Team check
    if shouldShow and self.TeamCheck then
        if LocalPlayer.Team and player.Team == LocalPlayer.Team then
            shouldShow = false
        end
    end
    
    highlight.Enabled = shouldShow
    highlight.FillColor = self.FillColor
    highlight.OutlineColor = self.OutlineColor
    highlight.FillTransparency = self.FillTransparency
    highlight.OutlineTransparency = self.OutlineTransparency
    highlight.DepthMode = self.DepthMode
    
    if char then
        highlight.Adornee = char
    end
end

function Chams:UpdateAll()
    for player, _ in pairs(self.Highlights) do
        if player and player.Parent then
            self:UpdateHighlight(player)
        end
    end
end

function Chams:Start()
    self:Stop()
    
    -- Create container
    self.Container = Instance.new("Folder")
    self.Container.Name = "SerdiumsChams"
    pcall(function()
        self.Container.Parent = game:GetService("CoreGui")
    end)
    if not self.Container.Parent then
        self.Container.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Create for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateHighlight(player)
        end
    end
    
    -- Player added
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        task.wait(0.5)
        if player ~= LocalPlayer then
            self:CreateHighlight(player)
        end
    end))
    
    -- Player removed
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        self:RemoveHighlight(player)
    end))
    
    -- Update loop
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:UpdateAll()
    end))
    
    print("[Serdiums Chams] Started")
end

function Chams:Stop()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
    
    for player, _ in pairs(self.Highlights) do
        self:RemoveHighlight(player)
    end
    
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

function Chams:Toggle(state)
    self.Enabled = state
    self:UpdateAll()
end

function Chams:SetFillColor(color)
    self.FillColor = color
    self:UpdateAll()
end

function Chams:SetOutlineColor(color)
    self.OutlineColor = color
    self:UpdateAll()
end

function Chams:SetFillTransparency(value)
    self.FillTransparency = value
    self:UpdateAll()
end

function Chams:SetOutlineTransparency(value)
    self.OutlineTransparency = value
    self:UpdateAll()
end

return Chams
