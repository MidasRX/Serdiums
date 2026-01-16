--[[
    Serdiums Example Script
    Exact Gamesense Style UI Demo
]]

-- Single loadstring to load everything
local Serdiums = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/init.lua"))()

-- Extract modules
local Library = Serdiums.Library
local ESP = Serdiums.ESP
local Chams = Serdiums.Chams

-- Access globals
local Toggles = Library.Toggles
local Options = Library.Options

-- Create Window (Gamesense Style)
local Window = Library:CreateWindow({
    Title = "Serdiums",
    Size = UDim2.new(0, 520, 0, 380),
    ToggleKey = Enum.KeyCode.RightControl
})

--// RAGE TAB \\-- (Like gamesense)
local RageTab = Window:AddTab("Rage", "⊕")

-- Aimbot Section (Left column)
local AimbotSection = RageTab:AddSection("Aimbot", "Left")

-- Toggle with inline dropdown (like gamesense "Enabled" with "Head" dropdown)
AimbotSection:AddToggle("Aimbot", {
    Text = "Enabled",
    Default = false,
    Dropdown = {
        Values = {"Head", "Chest", "Pelvis", "Nearest"},
        Default = "Head",
        Flag = "AimbotHitbox",
        Callback = function(value)
            print("Hitbox:", value)
        end
    },
    Callback = function(value)
        print("Aimbot:", value)
    end
})

AimbotSection:AddToggle("MultiPoint", {
    Text = "Multi-point",
    Default = false,
    Dropdown = {
        Values = {"Low", "Medium", "High"},
        Default = "Medium",
        Flag = "MultiPointLevel"
    }
})

AimbotSection:AddSlider("MinHitChance", {
    Text = "Minimum hit chance",
    Min = 0,
    Max = 100,
    Default = 90,
    Suffix = "%"
})

AimbotSection:AddSlider("MinDamage", {
    Text = "Minimum damage",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%"
})

AimbotSection:AddDivider()

AimbotSection:AddToggle("HitChanceOverride", {
    Text = "Minimum hit chance override",
    Default = false
})

AimbotSection:AddToggle("DamageOverride", {
    Text = "Minimum damage override",
    Default = false
})

AimbotSection:AddToggle("ForceLethal", {
    Text = "Force lethal shot",
    Default = false
})

AimbotSection:AddToggle("PreferBody", {
    Text = "Prefer body aim",
    Default = false
})

AimbotSection:AddToggle("ForceBody", {
    Text = "Force body aim",
    Default = false
})

AimbotSection:AddToggle("DelayShot", {
    Text = "Delay shot",
    Default = false
})

AimbotSection:AddToggle("QuickStop", {
    Text = "Quick stop",
    Default = false
})

AimbotSection:AddToggle("AutoScope", {
    Text = "Auto scope",
    Default = false
})

-- Other Section (Right column)
local OtherSection = RageTab:AddSection("Other", "Right")

OtherSection:AddDropdown("AccuracyBoost", {
    Text = "Accuracy boost",
    Values = {"Off", "Low", "Medium", "High"},
    Default = "Low"
})

OtherSection:AddToggle("AutoFire", {
    Text = "Automatic fire",
    Default = false
})

OtherSection:AddToggle("AimWalls", {
    Text = "Aim through walls",
    Default = false,
    Risky = true
})

OtherSection:AddToggle("SilentAim", {
    Text = "Silent aim",
    Default = false,
    Risky = true
})

OtherSection:AddToggle("RemoveRecoil", {
    Text = "Remove recoil",
    Default = false
})

OtherSection:AddToggle("RemoveSpread", {
    Text = "Remove spread",
    Default = false
})

OtherSection:AddToggle("DoubleTap", {
    Text = "Double tap",
    Default = false,
    Risky = true
})

OtherSection:AddToggle("QuickPeekAssist", {
    Text = "Quick peek assist",
    Default = false
})

OtherSection:AddToggle("DuckPeekAssist", {
    Text = "Duck peek assist",
    Default = false
})

OtherSection:AddToggle("LimitAimStep", {
    Text = "Limit aim step",
    Default = false
})

OtherSection:AddSlider("MaxFOV", {
    Text = "Maximum FOV",
    Min = 1,
    Max = 180,
    Default = 180,
    Suffix = "°"
})

OtherSection:AddToggle("LogMissedShots", {
    Text = "Log missed shots",
    Default = false
})

-- Anti-Aim Section (Right column)
local AntiAimSection = RageTab:AddSection("Anti-aimbot angles", "Right")

AntiAimSection:AddToggle("AntiAim", {
    Text = "Enabled",
    Default = false,
    Risky = true
})

AntiAimSection:AddDropdown("PitchType", {
    Text = "Pitch",
    Values = {"Off", "Down", "Up", "Zero"},
    Default = "Down"
})

AntiAimSection:AddDropdown("YawType", {
    Text = "Yaw",
    Values = {"Off", "Local view", "Spin", "Random"},
    Default = "Local view"
})

AntiAimSection:AddSlider("YawOffset", {
    Text = "",
    Min = -180,
    Max = 180,
    Default = 0,
    Suffix = "°"
})

AntiAimSection:AddToggle("Jitter", {
    Text = "Jitter",
    Default = false
})

AntiAimSection:AddToggle("Spin", {
    Text = "Spin",
    Default = false
})

AntiAimSection:AddToggle("Freestanding", {
    Text = "Freestanding",
    Default = false
})

--// VISUALS TAB \\--
local VisualsTab = Window:AddTab("Visuals", "◉")

-- ESP Section (Left)
local ESPSection = VisualsTab:AddSection("ESP", "Left")

-- Start ESP
ESP:Start()

ESPSection:AddToggle("ESP", {
    Text = "Enabled",
    Default = false,
    Callback = function(value)
        ESP:Toggle(value)
    end
})

ESPSection:AddToggle("ESPBoxes", {
    Text = "Boxes",
    Default = true,
    Callback = function(value)
        ESP.Boxes = value
    end
})

ESPSection:AddToggle("ESPNames", {
    Text = "Names",
    Default = true,
    Callback = function(value)
        ESP.Names = value
    end
})

ESPSection:AddToggle("ESPHealth", {
    Text = "Health bars",
    Default = true,
    Callback = function(value)
        ESP.Health = value
    end
})

ESPSection:AddToggle("ESPDistance", {
    Text = "Distance",
    Default = true,
    Callback = function(value)
        ESP.Distance = value
    end
})

ESPSection:AddToggle("ESPTracers", {
    Text = "Tracers",
    Default = false,
    Callback = function(value)
        ESP.Tracers = value
    end
})

ESPSection:AddColorPicker("ESPColor", {
    Text = "Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color)
        ESP.BoxColor = color
        ESP.NameColor = color
    end
})

ESPSection:AddSlider("ESPMaxDist", {
    Text = "Max distance",
    Min = 100,
    Max = 5000,
    Default = 2000,
    Suffix = "m",
    Callback = function(value)
        ESP.MaxDistance = value
    end
})

-- Chams Section (Left)
local ChamsSection = VisualsTab:AddSection("Chams", "Left")

Chams:Start()

ChamsSection:AddToggle("Chams", {
    Text = "Enabled",
    Default = false,
    Callback = function(value)
        Chams:Toggle(value)
    end
})

ChamsSection:AddToggle("ChamsTeamCheck", {
    Text = "Team check",
    Default = false,
    Callback = function(value)
        Chams.TeamCheck = value
    end
})

ChamsSection:AddColorPicker("ChamsVisible", {
    Text = "Visible color",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(color)
        Chams.VisibleColor = color
    end
})

ChamsSection:AddColorPicker("ChamsHidden", {
    Text = "Hidden color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        Chams.HiddenColor = color
    end
})

ChamsSection:AddSlider("ChamsFill", {
    Text = "Fill transparency",
    Min = 0,
    Max = 1,
    Default = 0.5,
    Rounding = 2,
    Callback = function(value)
        Chams.FillTransparency = value
    end
})

-- World Section (Right)
local WorldSection = VisualsTab:AddSection("World", "Right")

WorldSection:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Callback = function(value)
        local lighting = game:GetService("Lighting")
        if value then
            lighting.Ambient = Color3.new(1, 1, 1)
            lighting.Brightness = 2
            lighting.FogEnd = 100000
        else
            lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            lighting.Brightness = 1
        end
    end
})

WorldSection:AddToggle("NoFog", {
    Text = "No fog",
    Default = false,
    Callback = function(value)
        game:GetService("Lighting").FogEnd = value and 100000 or 1000
    end
})

WorldSection:AddToggle("NoParticles", {
    Text = "No particles",
    Default = false
})

--// MISC TAB \\--
local MiscTab = Window:AddTab("Misc", "⚙")

-- Movement Section
local MovementSection = MiscTab:AddSection("Movement", "Left")

MovementSection:AddToggle("Speed", {
    Text = "Speed hack",
    Default = false,
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = value and Options.SpeedValue.Value or 16
        end
    end
})

MovementSection:AddSlider("SpeedValue", {
    Text = "Walk speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        if Toggles.Speed and Toggles.Speed.Value then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = value
            end
        end
    end
})

MovementSection:AddToggle("InfJump", {
    Text = "Infinite jump",
    Default = false
})

MovementSection:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Risky = true
})

MovementSection:AddSlider("FlySpeed", {
    Text = "Fly speed",
    Min = 10,
    Max = 200,
    Default = 50
})

-- Utility Section
local UtilitySection = MiscTab:AddSection("Utility", "Right")

UtilitySection:AddButton({
    Text = "Rejoin server",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

UtilitySection:AddButton({
    Text = "Server hop",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

UtilitySection:AddButton({
    Text = "Copy game link",
    Callback = function()
        if setclipboard then
            setclipboard("roblox://placeId=" .. game.PlaceId)
        end
    end
})

UtilitySection:AddDivider()

UtilitySection:AddToggle("AntiAFK", {
    Text = "Anti AFK",
    Default = true,
    Callback = function(value)
        if value then
            local vu = game:GetService("VirtualUser")
            game.Players.LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

UtilitySection:AddKeybind("MenuKey", {
    Text = "Menu toggle",
    Default = "RightControl",
    ChangedCallback = function(key)
        if key then
            Library.ToggleKey = key
        end
    end
})

print("[Serdiums] Loaded - Press RightControl to toggle")
