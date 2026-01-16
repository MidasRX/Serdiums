--[[
    Serdiums ThemeManager
    Theme Customization System
]]

local HttpService = game:GetService("HttpService")

local ThemeManager = {}
ThemeManager.Folder = "Serdiums"
ThemeManager.Library = nil

ThemeManager.BuiltInThemes = {
    ["Default"] = {
        Background = "121212",
        Secondary = "181818",
        Tertiary = "202020",
        Accent = "8660ff",
        Text = "ffffff",
        SubText = "b4b4b4",
        Outline = "2d2d2d",
        DarkOutline = "191919",
        Toggle = "3c3c3c",
        ToggleEnabled = "8660ff",
        Slider = "8660ff",
        Dropdown = "1c1c1c",
        Risk = "ff5050"
    },
    ["Gamesense"] = {
        Background = "0c0c0c",
        Secondary = "141414",
        Tertiary = "1a1a1a",
        Accent = "a855f7",
        Text = "ffffff",
        SubText = "909090",
        Outline = "252525",
        DarkOutline = "0a0a0a",
        Toggle = "2a2a2a",
        ToggleEnabled = "a855f7",
        Slider = "a855f7",
        Dropdown = "161616",
        Risk = "ff4444"
    },
    ["Fatality"] = {
        Background = "191335",
        Secondary = "1e1842",
        Tertiary = "252050",
        Accent = "c50754",
        Text = "ffffff",
        SubText = "a0a0a0",
        Outline = "3c355d",
        DarkOutline = "0f0a1f",
        Toggle = "302555",
        ToggleEnabled = "c50754",
        Slider = "c50754",
        Dropdown = "1a1440",
        Risk = "ff3333"
    },
    ["Aqua"] = {
        Background = "0f1419",
        Secondary = "151c24",
        Tertiary = "1a232d",
        Accent = "00bcd4",
        Text = "e8f0f5",
        SubText = "8899a6",
        Outline = "253341",
        DarkOutline = "0a0f14",
        Toggle = "1e2a36",
        ToggleEnabled = "00bcd4",
        Slider = "00bcd4",
        Dropdown = "141b22",
        Risk = "ff5252"
    },
    ["Mint"] = {
        Background = "1a1a1a",
        Secondary = "222222",
        Tertiary = "2a2a2a",
        Accent = "3db488",
        Text = "ffffff",
        SubText = "a8a8a8",
        Outline = "383838",
        DarkOutline = "101010",
        Toggle = "333333",
        ToggleEnabled = "3db488",
        Slider = "3db488",
        Dropdown = "1e1e1e",
        Risk = "e74c3c"
    },
    ["Nord"] = {
        Background = "2e3440",
        Secondary = "3b4252",
        Tertiary = "434c5e",
        Accent = "88c0d0",
        Text = "eceff4",
        SubText = "d8dee9",
        Outline = "4c566a",
        DarkOutline = "242933",
        Toggle = "4c566a",
        ToggleEnabled = "88c0d0",
        Slider = "88c0d0",
        Dropdown = "353d4a",
        Risk = "bf616a"
    },
    ["Dracula"] = {
        Background = "282a36",
        Secondary = "343746",
        Tertiary = "3d4056",
        Accent = "ff79c6",
        Text = "f8f8f2",
        SubText = "bfbfbf",
        Outline = "6272a4",
        DarkOutline = "1d1e26",
        Toggle = "44475a",
        ToggleEnabled = "ff79c6",
        Slider = "ff79c6",
        Dropdown = "2d2f3c",
        Risk = "ff5555"
    },
    ["Catppuccin"] = {
        Background = "1e1e2e",
        Secondary = "262637",
        Tertiary = "302d41",
        Accent = "f5c2e7",
        Text = "d9e0ee",
        SubText = "988ba2",
        Outline = "575268",
        DarkOutline = "161622",
        Toggle = "3e3a50",
        ToggleEnabled = "f5c2e7",
        Slider = "f5c2e7",
        Dropdown = "222233",
        Risk = "f28fad"
    },
    ["Blood"] = {
        Background = "0d0d0d",
        Secondary = "141414",
        Tertiary = "1a1a1a",
        Accent = "8b0000",
        Text = "e0e0e0",
        SubText = "888888",
        Outline = "2a2a2a",
        DarkOutline = "080808",
        Toggle = "252525",
        ToggleEnabled = "8b0000",
        Slider = "8b0000",
        Dropdown = "111111",
        Risk = "ff0000"
    },
    ["Ocean"] = {
        Background = "0a1628",
        Secondary = "0f1f35",
        Tertiary = "142843",
        Accent = "0ea5e9",
        Text = "f0f4f8",
        SubText = "7a9bb8",
        Outline = "1e3a5f",
        DarkOutline = "06101e",
        Toggle = "183050",
        ToggleEnabled = "0ea5e9",
        Slider = "0ea5e9",
        Dropdown = "0c1a2e",
        Risk = "f43f5e"
    }
}

function ThemeManager:SetLibrary(lib)
    self.Library = lib
end

function ThemeManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function ThemeManager:BuildFolderTree()
    if not isfolder then return end
    
    local paths = {self.Folder, self.Folder .. "/themes"}
    
    for _, path in ipairs(paths) do
        if not isfolder(path) then
            makefolder(path)
        end
    end
end

function ThemeManager:ApplyTheme(name)
    if not self.Library then
        warn("[Serdiums ThemeManager] Library not set!")
        return false
    end
    
    local theme = self.BuiltInThemes[name]
    if not theme then
        theme = self:GetCustomTheme(name)
    end
    
    if not theme then
        warn("[Serdiums ThemeManager] Theme not found:", name)
        return false
    end
    
    for key, hex in pairs(theme) do
        if self.Library.Theme[key] ~= nil then
            self.Library.Theme[key] = Color3.fromHex(hex)
        end
    end
    
    -- Update all registered UI elements
    if self.Library.UpdateTheme then
        self.Library:UpdateTheme()
    end
    
    -- Also refresh the UI manually
    if self.Library.Main then
        self:RefreshUI()
    end
    
    return true
end

function ThemeManager:RefreshUI()
    -- Refresh main window colors
    local lib = self.Library
    if not lib or not lib.Main then return end
    
    lib.Main.BackgroundColor3 = lib.Theme.Background
    
    -- Recursively update colors
    local function updateDescendants(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Main" then
                if child.BackgroundTransparency < 1 then
                    -- Keep accent colors for sliders/toggles
                end
            end
            updateDescendants(child)
        end
    end
    
    updateDescendants(lib.Main)
end

function ThemeManager:GetCustomTheme(name)
    local path = self.Folder .. "/themes/" .. name .. ".json"
    if not isfile or not isfile(path) then return nil end
    
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
    return success and decoded or nil
end

function ThemeManager:SaveCustomTheme(name)
    if not name or name == "" then return false end
    
    self:BuildFolderTree()
    
    local theme = {}
    for key, color in pairs(self.Library.Theme) do
        theme[key] = color:ToHex()
    end
    
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, theme)
    if not success then return false end
    
    writefile(self.Folder .. "/themes/" .. name .. ".json", encoded)
    return true
end

function ThemeManager:GetThemes()
    local themes = {}
    
    for name in pairs(self.BuiltInThemes) do
        table.insert(themes, name)
    end
    
    table.sort(themes)
    
    if isfolder and isfolder(self.Folder .. "/themes") then
        for _, file in ipairs(listfiles(self.Folder .. "/themes")) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name and not self.BuiltInThemes[name] then
                    table.insert(themes, name .. " (Custom)")
                end
            end
        end
    end
    
    return themes
end

function ThemeManager:SaveDefault(name)
    self:BuildFolderTree()
    writefile(self.Folder .. "/themes/default.txt", name)
end

function ThemeManager:LoadDefault()
    local path = self.Folder .. "/themes/default.txt"
    if isfile and isfile(path) then
        local name = readfile(path)
        self:ApplyTheme(name:gsub(" %(Custom%)", ""))
        return name
    end
    return "Default"
end

function ThemeManager:BuildThemeSection(tab)
    local section = tab:AddSection("Theme")
    
    local themes = self:GetThemes()
    local defaultTheme = self:LoadDefault()
    
    section:AddDropdown("ThemeManager_List", {
        Text = "Theme",
        Values = themes,
        Default = defaultTheme,
        Callback = function(value)
            local name = value:gsub(" %(Custom%)", "")
            self:ApplyTheme(name)
        end
    })
    
    section:AddButton({
        Text = "Set as Default",
        Callback = function()
            local theme = self.Library.Options.ThemeManager_List.Value
            self:SaveDefault(theme)
            self.Library:Notify({Title = "Theme", Content = "Default theme set!", Type = "Success"})
        end
    })
    
    section:AddDivider()
    
    section:AddInput("ThemeManager_CustomName", {
        Text = "Custom Theme Name",
        Placeholder = "Enter name..."
    })
    
    section:AddButton({
        Text = "Save Current as Custom",
        Callback = function()
            local name = self.Library.Options.ThemeManager_CustomName.Value
            if self:SaveCustomTheme(name) then
                self.Library:Notify({Title = "Theme", Content = "Saved: " .. name, Type = "Success"})
                self.Library.Options.ThemeManager_List:SetValues(self:GetThemes())
            else
                self.Library:Notify({Title = "Error", Content = "Failed to save theme", Type = "Error"})
            end
        end
    })
    
    return section
end

function ThemeManager:BuildColorSection(tab)
    local section = tab:AddSection("Colors")
    
    local colorKeys = {"Accent", "Background", "Secondary", "Text", "SubText"}
    
    for _, key in ipairs(colorKeys) do
        section:AddColorPicker("Theme_" .. key, {
            Text = key,
            Default = self.Library.Theme[key],
            Callback = function(color)
                self.Library.Theme[key] = color
                self.Library:UpdateTheme()
            end
        })
    end
    
    return section
end

return ThemeManager
