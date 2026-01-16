--[[
    Serdiums UI Library - Core Module
    Exact Gamesense Style 1:1
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Theme = {
        Background = Color3.fromRGB(12, 12, 12),
        Sidebar = Color3.fromRGB(18, 18, 18),
        TabButton = Color3.fromRGB(25, 25, 25),
        TabButtonActive = Color3.fromRGB(35, 35, 35),
        Section = Color3.fromRGB(20, 20, 20),
        SectionHeader = Color3.fromRGB(25, 25, 25),
        Element = Color3.fromRGB(22, 22, 22),
        Text = Color3.fromRGB(180, 180, 180),
        TextDark = Color3.fromRGB(100, 100, 100),
        TextBright = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(160, 190, 60),
        AccentDark = Color3.fromRGB(120, 150, 40),
        SliderBg = Color3.fromRGB(35, 35, 35),
        SliderFill = Color3.fromRGB(160, 190, 60),
        Dropdown = Color3.fromRGB(30, 30, 30),
        DropdownBorder = Color3.fromRGB(45, 45, 45),
        Border = Color3.fromRGB(35, 35, 35),
        Checkbox = Color3.fromRGB(30, 30, 30),
        CheckboxCheck = Color3.fromRGB(160, 190, 60),
        Risky = Color3.fromRGB(255, 80, 80),
        Separator = Color3.fromRGB(40, 40, 40)
    },
    Toggles = {},
    Options = {},
    Registry = {},
    ScreenGui = nil,
    Open = true,
    ToggleKey = Enum.KeyCode.RightControl,
    Tabs = {}
}

-- Utility Functions
local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, props, time)
    local tween = TweenService:Create(obj, TweenInfo.new(time or 0.1, Enum.EasingStyle.Quad), props)
    tween:Play()
    return tween
end

local function Ripple(button)
    -- Simple hover effect
end

-- Gamesense Icons (matching screenshot exactly)
local Icons = {
    ["crosshair"] = "⊕",
    ["eye"] = "◉",
    ["settings"] = "⚙",
    ["player"] = "◈",
    ["world"] = "◎",
    ["misc"] = "☰",
    ["save"] = "💾",
    ["rage"] = "⚡",
    ["legit"] = "◇",
    ["visuals"] = "👁",
    ["skins"] = "🎨",
    ["configs"] = "📁"
}

Library.Create = Create
Library.Tween = Tween
Library.Icons = Icons

return Library
