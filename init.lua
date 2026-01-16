--[[
    Serdiums Loader
    Single loadstring to load all modules
]]

local repo = "https://raw.githubusercontent.com/MidasRX/Serdiums/main/"

local Serdiums = {}

-- Load main library
Serdiums.Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

-- Load addons
Serdiums.SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
Serdiums.ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
Serdiums.ESP = loadstring(game:HttpGet(repo .. "addons/ESP.lua"))()
Serdiums.Chams = loadstring(game:HttpGet(repo .. "addons/Chams.lua"))()

-- Auto-setup managers with library
Serdiums.SaveManager:SetLibrary(Serdiums.Library)
Serdiums.ThemeManager:SetLibrary(Serdiums.Library)

-- Expose globals
getgenv().Serdiums = Serdiums

return Serdiums
