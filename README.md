# Serdiums UI Library

A sleek, gamesense-style UI library for Roblox exploits with a modern dark theme aesthetic.

## Features

- 🎨 **10+ Built-in Themes** (Gamesense, Fatality, Dracula, Nord, etc.)
- 💾 **Config Save/Load System**
- 🔔 **Notification System**
- 🖱️ **Draggable Window**
- ⌨️ **Keybind Support**
- 🎨 **Color Pickers**
- 📊 **Sliders, Toggles, Dropdowns, Inputs**
- 📁 **Theme & Config Management**

## Installation

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL/Library.lua"))()
local SaveManager = loadstring(game:HttpGet("YOUR_RAW_URL/addons/SaveManager.lua"))()
local ThemeManager = loadstring(game:HttpGet("YOUR_RAW_URL/addons/ThemeManager.lua"))()
```

## Quick Start

```lua
-- Create Window
local Window = Library:CreateWindow({
    Title = "My Script",
    Subtitle = "v1.0.0",
    Size = UDim2.new(0, 550, 0, 400),
    ToggleKey = Enum.KeyCode.RightControl
})

-- Create Tab
local MainTab = Window:AddTab("Main")

-- Create Section
local Section = MainTab:AddSection("Features")

-- Add Toggle
Section:AddToggle("MyToggle", {
    Text = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Toggled:", value)
    end
})

-- Add Slider
Section:AddSlider("MySlider", {
    Text = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Value:", value)
    end
})
```

## Elements

### Toggle
```lua
Section:AddToggle("Index", {
    Text = "Toggle Name",
    Default = false,
    Risky = false, -- Makes text red
    Callback = function(value) end
})

-- Access: Toggles.Index.Value
-- Methods: :SetValue(bool), :OnChanged(fn)
```

### Slider
```lua
Section:AddSlider("Index", {
    Text = "Slider Name",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
    Suffix = "%",
    Callback = function(value) end
})

-- Access: Options.Index.Value
-- Methods: :SetValue(number), :OnChanged(fn)
```

### Dropdown
```lua
Section:AddDropdown("Index", {
    Text = "Dropdown Name",
    Values = {"Option1", "Option2", "Option3"},
    Default = "Option1",
    Multi = false, -- Multi-select
    Callback = function(value) end
})

-- Access: Options.Index.Value
-- Methods: :SetValue(value), :SetValues(table), :OnChanged(fn)
```

### Button
```lua
Section:AddButton({
    Text = "Button Name",
    Callback = function()
        print("Clicked!")
    end
})
```

### Input
```lua
Section:AddInput("Index", {
    Text = "Input Name",
    Default = "",
    Placeholder = "Enter text...",
    Callback = function(text) end
})

-- Access: Options.Index.Value
-- Methods: :SetValue(string), :OnChanged(fn)
```

### Keybind
```lua
Section:AddKeybind("Index", {
    Text = "Keybind Name",
    Default = "E",
    Callback = function() end, -- Called when key pressed
    ChangedCallback = function(key) end -- Called when keybind changed
})

-- Access: Options.Index.Value
-- Methods: :SetValue(keyname)
```

### ColorPicker
```lua
Section:AddColorPicker("Index", {
    Text = "Color Name",
    Default = Color3.new(1, 0, 0),
    Callback = function(color) end
})

-- Access: Options.Index.Value
-- Methods: :SetValue(Color3), :SetValueRGB(Color3)
```

### Label
```lua
Section:AddLabel("Some text here")
-- Methods: :SetText(string)
```

### Divider
```lua
Section:AddDivider()
```

## Notifications

```lua
Library:Notify({
    Title = "Title",
    Content = "Message content",
    Type = "Success", -- Info, Success, Warning, Error
    Duration = 5
})
```

## SaveManager

```lua
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("YourFolder")
SaveManager:SetSubFolder("SubFolder") -- Optional

-- Save
SaveManager:Save("ConfigName")

-- Load
SaveManager:Load("ConfigName")

-- Delete
SaveManager:Delete("ConfigName")

-- Get all configs
local configs = SaveManager:GetConfigs()

-- Build UI section
SaveManager:BuildConfigSection(SettingsTab)

-- Ignore certain indexes
SaveManager:SetIgnoreIndexes({"Theme_Accent"})
```

## ThemeManager

```lua
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("YourFolder")

-- Apply theme
ThemeManager:ApplyTheme("Gamesense")

-- Save custom theme
ThemeManager:SaveCustomTheme("MyTheme")

-- Build UI sections
ThemeManager:BuildThemeSection(SettingsTab)
ThemeManager:BuildColorSection(SettingsTab)

-- Save/Load default theme
ThemeManager:SaveDefault("Gamesense")
ThemeManager:LoadDefault()
```

## Available Themes

- Default
- Gamesense
- Fatality
- Aqua
- Mint
- Nord
- Dracula
- Catppuccin
- Blood
- Ocean

## Unloading

```lua
Library:Unload()
```

## Credits

- Inspired by Obsidian, Linoria, and Sirius libraries
- Gamesense ESP styling

---

**Serdiums © 2026**
