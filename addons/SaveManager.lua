--[[
    Serdiums SaveManager
    Config Save/Load System
]]

local HttpService = game:GetService("HttpService")

local SaveManager = {}
SaveManager.Folder = "Serdiums"
SaveManager.SubFolder = ""
SaveManager.Ignore = {}
SaveManager.Library = nil

SaveManager.Parser = {
    Toggle = {
        Save = function(idx, object)
            return { type = "Toggle", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Toggles[idx] then
                SaveManager.Library.Toggles[idx]:SetValue(data.value)
            end
        end,
    },
    Slider = {
        Save = function(idx, object)
            return { type = "Slider", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end,
    },
    Dropdown = {
        Save = function(idx, object)
            return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end,
    },
    ColorPicker = {
        Save = function(idx, object)
            return { type = "ColorPicker", idx = idx, value = object.Value:ToHex() }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value))
            end
        end,
    },
    Input = {
        Save = function(idx, object)
            return { type = "Input", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end,
    },
    Keybind = {
        Save = function(idx, object)
            return { type = "Keybind", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if SaveManager.Library.Options[idx] then
                SaveManager.Library.Options[idx]:SetValue(data.value)
            end
        end,
    },
}

function SaveManager:SetLibrary(lib)
    self.Library = lib
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
    self:BuildFolderTree()
end

function SaveManager:SetSubFolder(folder)
    self.SubFolder = folder
    self:BuildFolderTree()
end

function SaveManager:SetIgnoreIndexes(list)
    for _, key in pairs(list) do
        self.Ignore[key] = true
    end
end

function SaveManager:GetPath()
    local path = self.Folder .. "/configs"
    if self.SubFolder ~= "" then
        path = path .. "/" .. self.SubFolder
    end
    return path
end

function SaveManager:BuildFolderTree()
    if not isfolder then return end
    
    local paths = {self.Folder, self.Folder .. "/configs"}
    if self.SubFolder ~= "" then
        table.insert(paths, self.Folder .. "/configs/" .. self.SubFolder)
    end
    
    for _, path in ipairs(paths) do
        if not isfolder(path) then
            makefolder(path)
        end
    end
end

function SaveManager:Save(name)
    if not name or name == "" then
        return false, "Invalid config name"
    end
    
    self:BuildFolderTree()
    
    local data = { objects = {} }
    
    for idx, toggle in pairs(self.Library.Toggles) do
        if not self.Ignore[idx] and toggle.Type then
            local parser = self.Parser[toggle.Type]
            if parser then
                table.insert(data.objects, parser.Save(idx, toggle))
            end
        end
    end
    
    for idx, option in pairs(self.Library.Options) do
        if not self.Ignore[idx] and option.Type then
            local parser = self.Parser[option.Type]
            if parser then
                table.insert(data.objects, parser.Save(idx, option))
            end
        end
    end
    
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then
        return false, "Failed to encode"
    end
    
    local path = self:GetPath() .. "/" .. name .. ".json"
    writefile(path, encoded)
    
    return true
end

function SaveManager:Load(name)
    if not name or name == "" then
        return false, "Invalid config name"
    end
    
    local path = self:GetPath() .. "/" .. name .. ".json"
    if not isfile(path) then
        return false, "Config not found"
    end
    
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
    if not success then
        return false, "Failed to decode"
    end
    
    for _, item in pairs(decoded.objects) do
        if item.type and self.Parser[item.type] and not self.Ignore[item.idx] then
            task.spawn(self.Parser[item.type].Load, item.idx, item)
        end
    end
    
    return true
end

function SaveManager:Delete(name)
    if not name or name == "" then
        return false, "Invalid config name"
    end
    
    local path = self:GetPath() .. "/" .. name .. ".json"
    if not isfile(path) then
        return false, "Config not found"
    end
    
    delfile(path)
    return true
end

function SaveManager:GetConfigs()
    self:BuildFolderTree()
    
    local configs = {}
    local path = self:GetPath()
    
    if isfolder and isfolder(path) then
        for _, file in ipairs(listfiles(path)) do
            if file:sub(-5) == ".json" then
                local name = file:match("([^/\\]+)%.json$")
                if name then
                    table.insert(configs, name)
                end
            end
        end
    end
    
    return configs
end

function SaveManager:BuildConfigSection(tab)
    local section = tab:AddSection("Configuration")
    
    section:AddInput("SaveManager_ConfigName", {
        Text = "Config Name",
        Placeholder = "Enter config name..."
    })
    
    section:AddDropdown("SaveManager_ConfigList", {
        Text = "Configs",
        Values = self:GetConfigs(),
        Default = nil
    })
    
    section:AddButton({
        Text = "Create Config",
        Callback = function()
            local name = self.Library.Options.SaveManager_ConfigName.Value
            local success, err = self:Save(name)
            if success then
                self.Library:Notify({Title = "Config", Content = "Saved: " .. name, Type = "Success"})
                self.Library.Options.SaveManager_ConfigList:SetValues(self:GetConfigs())
            else
                self.Library:Notify({Title = "Error", Content = err, Type = "Error"})
            end
        end
    })
    
    section:AddButton({
        Text = "Load Config",
        Callback = function()
            local name = self.Library.Options.SaveManager_ConfigList.Value
            local success, err = self:Load(name)
            if success then
                self.Library:Notify({Title = "Config", Content = "Loaded: " .. name, Type = "Success"})
            else
                self.Library:Notify({Title = "Error", Content = err, Type = "Error"})
            end
        end
    })
    
    section:AddButton({
        Text = "Delete Config",
        Callback = function()
            local name = self.Library.Options.SaveManager_ConfigList.Value
            local success, err = self:Delete(name)
            if success then
                self.Library:Notify({Title = "Config", Content = "Deleted: " .. name, Type = "Success"})
                self.Library.Options.SaveManager_ConfigList:SetValues(self:GetConfigs())
            else
                self.Library:Notify({Title = "Error", Content = err, Type = "Error"})
            end
        end
    })
    
    section:AddButton({
        Text = "Refresh List",
        Callback = function()
            self.Library.Options.SaveManager_ConfigList:SetValues(self:GetConfigs())
        end
    })
    
    return section
end

return SaveManager
