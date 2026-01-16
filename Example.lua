--[[
    Serdiums Example Script
    Gamesense Style 1:1
]]

-- Load Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/addons/ThemeManager.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/addons/ESP.lua"))()
local Chams = loadstring(game:HttpGet("https://raw.githubusercontent.com/MidasRX/Serdiums/main/addons/Chams.lua"))()

-- Create Window (matches gamesense size)
local Window = Library:CreateWindow({
    Title = "Serdiums",
    Size = UDim2.new(0, 580, 0, 420)
})

--[[ TAB 1: RAGE ]]--
local RageTab = Window:AddTab("Rage", "crosshair")

-- Left Column: Aimbot
local AimbotSection = RageTab:AddLeftSection("Aimbot")

AimbotSection:AddToggle("AimbotEnabled", {
    Text = "Enabled",
    Default = false,
    Dropdown = {
        Values = {"Head", "Chest", "Pelvis", "Nearest"},
        Default = "Head",
        Flag = "AimbotTarget",
        Callback = function(val) end
    },
    Callback = function(val) end
})

AimbotSection:AddToggle("MultiPoint", {
    Text = "Multi-point",
    Default = false,
    Dropdown = {
        Values = {"Low", "Medium", "High"},
        Default = "Medium",
        Flag = "MultiPointMode"
    }
})

AimbotSection:AddSlider("HitChance", {
    Text = "Minimum hit chance",
    Min = 0,
    Max = 100,
    Default = 90,
    Suffix = "%",
    Callback = function(val) end
})

AimbotSection:AddSlider("MinDamage", {
    Text = "Minimum damage",
    Min = 0,
    Max = 100,
    Default = 50,
    Suffix = "%"
})

AimbotSection:AddToggle("HitChanceOverride", {
    Text = "Minimum hit chance override"
})

AimbotSection:AddToggle("DamageOverride", {
    Text = "Minimum damage override"
})

AimbotSection:AddToggle("ForceLethal", {
    Text = "Force lethal shot"
})

AimbotSection:AddToggle("PreferBody", {
    Text = "Prefer body aim"
})

AimbotSection:AddToggle("ForceBody", {
    Text = "Force body aim"
})

AimbotSection:AddToggle("DelayShot", {
    Text = "Delay shot"
})

AimbotSection:AddToggle("QuickStop", {
    Text = "Quick stop"
})

AimbotSection:AddToggle("AutoScope", {
    Text = "Auto scope"
})

-- Right Column: Other
local OtherSection = RageTab:AddRightSection("Other")

OtherSection:AddDropdown("AccuracyBoost", {
    Text = "Accuracy boost",
    Values = {"Off", "Low", "Medium", "High"},
    Default = "Low"
})

OtherSection:AddToggle("AutoFire", {
    Text = "Automatic fire"
})

OtherSection:AddToggle("WallAim", {
    Text = "Aim through walls",
    Risky = true
})

OtherSection:AddToggle("SilentAim", {
    Text = "Silent aim",
    Risky = true
})

OtherSection:AddToggle("RemoveRecoil", {
    Text = "Remove recoil"
})

OtherSection:AddToggle("RemoveSpread", {
    Text = "Remove spread"
})

OtherSection:AddToggle("DoubleTap", {
    Text = "Double tap",
    Risky = true
})

OtherSection:AddToggle("QuickPeek", {
    Text = "Quick peek assist"
})

OtherSection:AddToggle("DuckPeek", {
    Text = "Duck peek assist"
})

OtherSection:AddToggle("LimitStep", {
    Text = "Limit aim step"
})

OtherSection:AddSlider("MaxFOV", {
    Text = "Maximum FOV",
    Min = 0,
    Max = 180,
    Default = 180,
    Suffix = "°"
})

OtherSection:AddToggle("LogMissed", {
    Text = "Log missed shots"
})

-- Anti-Aimbot Angles Section
local AntiAimSection = RageTab:AddRightSection("Anti-aimbot angles")

AntiAimSection:AddToggle("AntiAimEnabled", {
    Text = "Enabled"
})

AntiAimSection:AddDropdown("PitchMode", {
    Text = "Pitch",
    Values = {"Off", "Down", "Up", "Zero"},
    Default = "Down"
})

AntiAimSection:AddDropdown("YawMode", {
    Text = "Yaw",
    Values = {"Off", "Local view", "180", "Spin", "Random"},
    Default = "Local view"
})

AntiAimSection:AddToggle("Jitter", {
    Text = "Jitter"
})

AntiAimSection:AddToggle("Spin", {
    Text = "Spin"
})

AntiAimSection:AddToggle("Freestanding", {
    Text = "Freestanding"
})

--[[ TAB 2: VISUALS ]]--
local VisualsTab = Window:AddTab("Visuals", "eye")

-- Left: ESP
local ESPSection = VisualsTab:AddLeftSection("ESP")

ESPSection:AddToggle("ESPEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(val)
        if val then
            ESP:Start()
        else
            ESP:Stop()
        end
    end
})

ESPSection:AddToggle("ESPBox", {
    Text = "Box",
    Default = true,
    Callback = function(val)
        ESP.Settings.ShowBox = val
    end
})

ESPSection:AddToggle("ESPName", {
    Text = "Name",
    Default = true,
    Callback = function(val)
        ESP.Settings.ShowName = val
    end
})

ESPSection:AddToggle("ESPHealth", {
    Text = "Health bar",
    Default = true,
    Callback = function(val)
        ESP.Settings.ShowHealth = val
    end
})

ESPSection:AddToggle("ESPDistance", {
    Text = "Distance",
    Default = false,
    Callback = function(val)
        ESP.Settings.ShowDistance = val
    end
})

ESPSection:AddToggle("ESPTracers", {
    Text = "Tracers",
    Default = false,
    Callback = function(val)
        ESP.Settings.ShowTracers = val
    end
})

ESPSection:AddSlider("ESPMaxDist", {
    Text = "Max distance",
    Min = 100,
    Max = 2000,
    Default = 1000,
    Suffix = " studs",
    Callback = function(val)
        ESP.Settings.MaxDistance = val
    end
})

ESPSection:AddColorPicker("ESPColor", {
    Text = "ESP color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(col)
        ESP.Settings.BoxColor = col
        ESP.Settings.NameColor = col
    end
})

-- Left: Chams
local ChamsSection = VisualsTab:AddLeftSection("Chams")

ChamsSection:AddToggle("ChamsEnabled", {
    Text = "Enabled",
    Default = false,
    Callback = function(val)
        if val then
            Chams:Start()
        else
            Chams:Stop()
        end
    end
})

ChamsSection:AddColorPicker("ChamsVisible", {
    Text = "Visible color",
    Default = Color3.fromRGB(172, 208, 66),
    Callback = function(col)
        Chams.Settings.VisibleColor = col
        Chams:Refresh()
    end
})

ChamsSection:AddColorPicker("ChamsHidden", {
    Text = "Hidden color",
    Default = Color3.fromRGB(232, 93, 93),
    Callback = function(col)
        Chams.Settings.HiddenColor = col
        Chams:Refresh()
    end
})

ChamsSection:AddToggle("ChamsTeamCheck", {
    Text = "Team check",
    Default = true,
    Callback = function(val)
        Chams.Settings.TeamCheck = val
        Chams:Refresh()
    end
})

-- Right: World
local WorldSection = VisualsTab:AddRightSection("World")

WorldSection:AddToggle("Fullbright", {
    Text = "Fullbright",
    Callback = function(val)
        local lighting = game:GetService("Lighting")
        if val then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.FogEnd = 100000
        else
            lighting.Brightness = 1
            lighting.ClockTime = 14
            lighting.FogEnd = 10000
        end
    end
})

WorldSection:AddToggle("NoFog", {
    Text = "Remove fog",
    Callback = function(val)
        game:GetService("Lighting").FogEnd = val and 1000000 or 10000
    end
})

WorldSection:AddSlider("FOV", {
    Text = "Field of view",
    Min = 70,
    Max = 120,
    Default = 70,
    Suffix = "°",
    Callback = function(val)
        game:GetService("Workspace").CurrentCamera.FieldOfView = val
    end
})

--[[ TAB 3: MISC ]]--
local MiscTab = Window:AddTab("Misc", "misc")

local MiscSection = MiscTab:AddLeftSection("Movement")

MiscSection:AddToggle("Speed", {
    Text = "Speed hack",
    Risky = true,
    Callback = function(val)
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = val and 32 or 16
        end
    end
})

MiscSection:AddSlider("SpeedValue", {
    Text = "Speed multiplier",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(val)
        local player = game:GetService("Players").LocalPlayer
        if Library.Toggles["Speed"] and Library.Toggles["Speed"].Value then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = val
            end
        end
    end
})

MiscSection:AddToggle("InfJump", {
    Text = "Infinite jump",
    Callback = function(val)
        -- Will be implemented via InputBegan
    end
})

MiscSection:AddToggle("NoClip", {
    Text = "Noclip",
    Risky = true,
    Callback = function(val)
        -- Noclip logic here
    end
})

MiscSection:AddToggle("Fly", {
    Text = "Fly",
    Risky = true
})

local UtilSection = MiscTab:AddRightSection("Utility")

UtilSection:AddButton("Respawn", function()
    local player = game:GetService("Players").LocalPlayer
    if player.Character then
        player.Character:BreakJoints()
    end
end)

UtilSection:AddButton("Reset camera", function()
    local cam = game:GetService("Workspace").CurrentCamera
    cam.CameraType = Enum.CameraType.Custom
end)

UtilSection:AddKeybind("MenuKey", {
    Text = "Menu keybind",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key)
        Library.ToggleKey = key
    end
})

--[[ TAB 4: SETTINGS ]]--
local SettingsTab = Window:AddTab("Settings", "settings")

local ConfigSection = SettingsTab:AddLeftSection("Configuration")

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
SaveManager:SetFolder("Serdiums/configs")
ThemeManager:SetFolder("Serdiums/themes")

SaveManager:BuildConfigSection(ConfigSection)

local ThemesSection = SettingsTab:AddRightSection("Themes")

ThemeManager:BuildThemeSection(ThemesSection)

-- Notify
Library:Notify("Serdiums", "UI loaded successfully!", 3)

-- Infinite Jump Handler
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Library.Toggles["InfJump"] and Library.Toggles["InfJump"].Value then
        local player = game:GetService("Players").LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
