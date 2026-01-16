--[[
    Serdiums Example Script
    Demonstrates all features of the Serdiums UI Library
]]

-- Single loadstring to load everything
local Serdiums = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/init.lua"))()

-- Extract modules
local Library = Serdiums.Library
local SaveManager = Serdiums.SaveManager
local ThemeManager = Serdiums.ThemeManager
local ESP = Serdiums.ESP

-- Access globals
local Toggles = Library.Toggles
local Options = Library.Options

-- Create Window
local Window = Library:CreateWindow({
    Title = "Serdiums",
    Subtitle = "v1.0.0 | Gamesense Style",
    Size = UDim2.new(0, 550, 0, 400),
    ToggleKey = Enum.KeyCode.RightControl
})

-- Setup Managers (folders for configs/themes)
SaveManager:SetFolder("Serdiums/MyScript")
ThemeManager:SetFolder("Serdiums/MyScript")

--// MAIN TAB \\--
local MainTab = Window:AddTab("Main")

-- Combat Section
local CombatSection = MainTab:AddSection("Combat")

CombatSection:AddToggle("Aimbot", {
    Text = "Aimbot",
    Default = false,
    Callback = function(value)
        print("Aimbot:", value)
    end
})

CombatSection:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = false,
    Risky = true,
    Callback = function(value)
        print("Silent Aim:", value)
    end
})

CombatSection:AddSlider("AimFOV", {
    Text = "FOV",
    Min = 10,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Suffix = "°",
    Callback = function(value)
        print("FOV:", value)
    end
})

CombatSection:AddSlider("Smoothness", {
    Text = "Smoothness",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Callback = function(value)
        print("Smoothness:", value)
    end
})

CombatSection:AddDropdown("TargetPart", {
    Text = "Target Part",
    Values = {"Head", "Torso", "Random"},
    Default = "Head",
    Callback = function(value)
        print("Target Part:", value)
    end
})

-- Movement Section
local MovementSection = MainTab:AddSection("Movement")

MovementSection:AddToggle("Speed", {
    Text = "Speed Hack",
    Default = false,
    Callback = function(value)
        local player = game.Players.LocalPlayer
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value and Options.SpeedValue.Value or 16
        end
    end
})

MovementSection:AddSlider("SpeedValue", {
    Text = "Walk Speed",
    Min = 16,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Callback = function(value)
        if Toggles.Speed.Value then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
            end
        end
    end
})

MovementSection:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false
})

MovementSection:AddKeybind("FlyKey", {
    Text = "Fly Toggle",
    Default = "F",
    Callback = function()
        print("Fly toggled!")
    end,
    ChangedCallback = function(key)
        print("Fly keybind changed to:", key)
    end
})

--// VISUALS TAB \\--
local VisualsTab = Window:AddTab("Visuals")

-- ESP Section
local ESPSection = VisualsTab:AddSection("ESP")

-- Start ESP system
ESP:Start()

ESPSection:AddToggle("PlayerESP", {
    Text = "Player ESP",
    Default = false,
    Callback = function(value)
        ESP:Toggle(value)
    end
})

ESPSection:AddToggle("BoxESP", {
    Text = "Boxes",
    Default = true,
    Callback = function(value)
        ESP.Boxes = value
    end
})

ESPSection:AddToggle("NameESP", {
    Text = "Names",
    Default = true,
    Callback = function(value)
        ESP.Names = value
    end
})

ESPSection:AddToggle("HealthESP", {
    Text = "Health Bars",
    Default = true,
    Callback = function(value)
        ESP.Health = value
    end
})

ESPSection:AddToggle("DistanceESP", {
    Text = "Distance",
    Default = true,
    Callback = function(value)
        ESP.Distance = value
    end
})

ESPSection:AddToggle("TracerESP", {
    Text = "Tracers",
    Default = false,
    Callback = function(value)
        ESP.Tracers = value
    end
})

ESPSection:AddColorPicker("ESPColor", {
    Text = "Box Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP.BoxColor = color
        ESP.NameColor = color
        ESP.TracerColor = color
    end
})

ESPSection:AddSlider("ESPDistance", {
    Text = "Max Distance",
    Min = 100,
    Max = 5000,
    Default = 2000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(value)
        ESP.MaxDistance = value
    end
})

-- Chams Section
local ChamsSection = VisualsTab:AddSection("Chams")

ChamsSection:AddToggle("PlayerChams", {
    Text = "Player Chams",
    Default = false
})

ChamsSection:AddColorPicker("ChamsVisibleColor", {
    Text = "Visible Color",
    Default = Color3.fromRGB(0, 255, 0)
})

ChamsSection:AddColorPicker("ChamsHiddenColor", {
    Text = "Hidden Color",
    Default = Color3.fromRGB(255, 0, 0)
})

ChamsSection:AddSlider("ChamsTransparency", {
    Text = "Transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2
})

--// MISC TAB \\--
local MiscTab = Window:AddTab("Misc")

-- Utility Section
local UtilitySection = MiscTab:AddSection("Utility")

UtilitySection:AddButton({
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

UtilitySection:AddButton({
    Text = "Server Hop",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

UtilitySection:AddButton({
    Text = "Copy Game Link",
    Callback = function()
        if setclipboard then
            setclipboard("roblox://placeId=" .. game.PlaceId)
            Library:Notify({
                Title = "Copied!",
                Content = "Game link copied to clipboard",
                Type = "Success",
                Duration = 3
            })
        end
    end
})

UtilitySection:AddDivider()

UtilitySection:AddInput("ChatMessage", {
    Text = "Chat Message",
    Placeholder = "Enter message...",
    Callback = function(text)
        print("Input:", text)
    end
})

UtilitySection:AddDropdown("Team", {
    Text = "Team Filter",
    Values = {"All", "Enemy", "Friendly"},
    Default = "Enemy",
    Callback = function(value)
        print("Team Filter:", value)
    end
})

UtilitySection:AddDropdown("MultiSelect", {
    Text = "Features",
    Values = {"Feature A", "Feature B", "Feature C", "Feature D"},
    Multi = true,
    Callback = function(value)
        print("Selected features:", value)
    end
})

-- Fun Section
local FunSection = MiscTab:AddSection("Fun")

FunSection:AddToggle("AntiAFK", {
    Text = "Anti AFK",
    Default = true,
    Callback = function(value)
        if value then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

FunSection:AddLabel("These features are just for fun!")

--// SETTINGS TAB \\--
local SettingsTab = Window:AddTab("Settings")

-- Theme Section
ThemeManager:BuildThemeSection(SettingsTab)
ThemeManager:BuildColorSection(SettingsTab)

-- Config Section
SaveManager:BuildConfigSection(SettingsTab)

-- UI Section
local UISection = SettingsTab:AddSection("UI Settings")

UISection:AddKeybind("MenuToggle", {
    Text = "Menu Toggle",
    Default = "RightControl",
    ChangedCallback = function(key)
        Library.ToggleKey = Enum.KeyCode[key]
    end
})

UISection:AddButton({
    Text = "Unload Script",
    Callback = function()
        Library:Unload()
    end
})

--// NOTIFICATIONS EXAMPLE \\--
Library:Notify({
    Title = "Welcome!",
    Content = "Serdiums loaded successfully",
    Type = "Success",
    Duration = 5
})

-- OnChanged Examples
Toggles.Aimbot:OnChanged(function(value)
    print("Aimbot OnChanged:", value)
end)

Options.AimFOV:OnChanged(function(value)
    print("FOV OnChanged:", value)
end)
