--[[
    Serdiums UI Library
    Gamesense ESP Style UI Library for Roblox
    
    © 2026 Serdiums
]]

local cloneref = cloneref or function(i) return i end
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextService = cloneref(game:GetService("TextService"))
local HttpService = cloneref(game:GetService("HttpService"))

local getgenv = getgenv or function() return shared end
local gethui = gethui or function() return CoreGui end
local protectgui = protectgui or (syn and syn.protect_gui) or function() end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

-- Globals
local Toggles = {}
local Options = {}

local Library = {
    Version = "1.0.0",
    Name = "Serdiums",
    
    ScreenGui = nil,
    Main = nil,
    Toggled = true,
    Unloaded = false,
    
    ToggleKey = Enum.KeyCode.RightControl,
    TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    
    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},
    
    Toggles = Toggles,
    Options = Options,
    
    Notifications = {},
    
    Theme = {
        Background = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(24, 24, 24),
        Tertiary = Color3.fromRGB(32, 32, 32),
        Accent = Color3.fromRGB(134, 96, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Outline = Color3.fromRGB(45, 45, 45),
        DarkOutline = Color3.fromRGB(25, 25, 25),
        Toggle = Color3.fromRGB(60, 60, 60),
        ToggleEnabled = Color3.fromRGB(134, 96, 255),
        Slider = Color3.fromRGB(134, 96, 255),
        Dropdown = Color3.fromRGB(28, 28, 28),
        Risk = Color3.fromRGB(255, 80, 80),
    },
    
    Font = Font.fromEnum(Enum.Font.Code),
    FontSize = 13,
    
    Registry = {},
    Signals = {},
}

-- Utility Functions
local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            if typeof(v) == "table" and v.SchemeColor then
                inst[k] = Library.Theme[v.SchemeColor]
            else
                inst[k] = v
            end
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, props, duration)
    duration = duration or 0.15
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function GetTextSize(text, size, font)
    return TextService:GetTextSize(text, size or Library.FontSize, font or Library.Font.Family, Vector2.new(math.huge, math.huge))
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Library.Theme.Outline,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function AddPadding(parent, padding)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

-- Registry for theme updates
function Library:AddToRegistry(inst, props)
    self.Registry[inst] = props
end

function Library:RemoveFromRegistry(inst)
    self.Registry[inst] = nil
end

function Library:UpdateTheme()
    for inst, props in pairs(self.Registry) do
        for prop, themeKey in pairs(props) do
            if self.Theme[themeKey] then
                inst[prop] = self.Theme[themeKey]
            end
        end
    end
end

-- Notification System
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    local type_ = options.Type or "Info"
    
    local colors = {
        Info = Library.Theme.Accent,
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 60),
        Error = Color3.fromRGB(255, 80, 80),
    }
    
    local notifColor = colors[type_] or colors.Info
    
    local notif = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 70),
        Position = UDim2.new(1, 300, 1, -80 - (#self.Notifications * 80)),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = self.ScreenGui
    })
    AddCorner(notif, 6)
    AddStroke(notif, Library.Theme.Outline)
    
    local accent = Create("Frame", {
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = notifColor,
        Parent = notif
    })
    AddCorner(accent, 2)
    
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        FontFace = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })
    
    local contentLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        FontFace = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notif
    })
    
    table.insert(self.Notifications, notif)
    
    Tween(notif, {Position = UDim2.new(1, -290, 1, -80 - ((#self.Notifications - 1) * 80))}, 0.3)
    
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 300, notif.Position.Y.Scale, notif.Position.Y.Offset)}, 0.3)
        task.wait(0.35)
        local idx = table.find(self.Notifications, notif)
        if idx then table.remove(self.Notifications, idx) end
        notif:Destroy()
        
        for i, n in ipairs(self.Notifications) do
            Tween(n, {Position = UDim2.new(1, -290, 1, -80 - ((i - 1) * 80))}, 0.2)
        end
    end)
    
    return notif
end

-- Create Window
function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Serdiums"
    local subtitle = options.Subtitle or "v1.0.0"
    local size = options.Size or UDim2.new(0, 550, 0, 400)
    local position = options.Position or UDim2.new(0.5, -275, 0.5, -200)
    
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    
    -- Main ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "Serdiums",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    protectgui(screenGui)
    screenGui.Parent = gethui()
    self.ScreenGui = screenGui
    
    -- Main Window
    local main = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = position,
        BackgroundColor3 = Library.Theme.Background,
        Parent = screenGui
    })
    AddCorner(main, 8)
    AddStroke(main, Library.Theme.DarkOutline)
    self.Main = main
    
    -- Top Bar
    local topBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = topBar})
    
    local topBarFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = topBar
    })
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, -10, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Theme.Text,
        TextSize = 15,
        FontFace = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    local subtitleLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, -10, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        FontFace = Library.Font,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topBar
    })
    
    -- Tab Container
    local tabHolder = Create("Frame", {
        Name = "TabHolder",
        Size = UDim2.new(0, 120, 1, -42),
        Position = UDim2.new(0, 5, 0, 37),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = main
    })
    AddCorner(tabHolder, 6)
    
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = tabHolder
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        Parent = tabList
    })
    
    -- Content Container
    local contentHolder = Create("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -135, 1, -42),
        Position = UDim2.new(0, 130, 0, 37),
        BackgroundColor3 = Library.Theme.Secondary,
        ClipsDescendants = true,
        Parent = main
    })
    AddCorner(contentHolder, 6)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Toggle Visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKey then
            self.Toggled = not self.Toggled
            main.Visible = self.Toggled
        end
    end)
    
    local Window = {
        TabList = tabList,
        ContentHolder = contentHolder,
        Tabs = {}
    }
    
    function Window:AddTab(name, icon)
        local tab = {}
        
        -- Tab Button
        local tabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = Library.Theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            Parent = tabList
        })
        AddCorner(tabBtn, 4)
        
        local tabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.Theme.SubText,
            TextSize = 13,
            FontFace = Library.Font,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabBtn
        })
        
        -- Tab Content
        local tabContent = Create("ScrollingFrame", {
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = contentHolder
        })
        
        local contentLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 6),
            Parent = tabContent
        })
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab selection
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Button.BackgroundTransparency = 1
                t.Label.TextColor3 = Library.Theme.SubText
                t.Content.Visible = false
            end
            tabBtn.BackgroundTransparency = 0
            tabLabel.TextColor3 = Library.Theme.Text
            tabContent.Visible = true
            Library.ActiveTab = tab
        end)
        
        tab.Button = tabBtn
        tab.Label = tabLabel
        tab.Content = tabContent
        tab.Name = name
        tab.Sections = {}
        
        table.insert(Window.Tabs, tab)
        table.insert(Library.Tabs, tab)
        Library.TabButtons[name] = tabBtn
        
        -- Select first tab
        if #Window.Tabs == 1 then
            tabBtn.BackgroundTransparency = 0
            tabLabel.TextColor3 = Library.Theme.Text
            tabContent.Visible = true
            Library.ActiveTab = tab
        end
        
        -- Update canvas size
        tabList.CanvasSize = UDim2.new(0, 0, 0, (#Window.Tabs * 32) + 10)
        
        -- Add Section
        function tab:AddSection(sectionName)
            local section = {}
            
            local sectionFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.Tertiary,
                Parent = tabContent
            })
            AddCorner(sectionFrame, 4)
            
            local sectionTitle = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 24),
                Position = UDim2.new(0, 8, 0, 3),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Library.Theme.Text,
                TextSize = 13,
                FontFace = Library.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })
            
            local sectionContent = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 0),
                Position = UDim2.new(0, 4, 0, 26),
                BackgroundTransparency = 1,
                Parent = sectionFrame
            })
            
            local sectionLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = sectionContent
            })
            
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContent.Size = UDim2.new(1, -8, 0, sectionLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 32)
            end)
            
            section.Frame = sectionFrame
            section.Content = sectionContent
            section.Elements = {}
            
            table.insert(tab.Sections, section)
            
            -- Add Toggle
            function section:AddToggle(idx, options)
                options = options or {}
                local default = options.Default or false
                local text = options.Text or "Toggle"
                local callback = options.Callback or function() end
                local risky = options.Risky or false
                
                local toggle = {
                    Value = default,
                    Type = "Toggle"
                }
                
                local toggleFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local toggleLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = risky and Library.Theme.Risk or Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                local toggleBtn = Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -22, 0.5, -9),
                    BackgroundColor3 = default and Library.Theme.ToggleEnabled or Library.Theme.Toggle,
                    Parent = toggleFrame
                })
                AddCorner(toggleBtn, 4)
                AddStroke(toggleBtn, Library.Theme.Outline)
                
                local toggleIndicator = Create("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    Position = UDim2.new(0.5, -5, 0.5, -5),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = default and 0 or 1,
                    Parent = toggleBtn
                })
                AddCorner(toggleIndicator, 2)
                
                local clickDetector = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = toggleFrame
                })
                
                function toggle:SetValue(val)
                    toggle.Value = val
                    Tween(toggleBtn, {BackgroundColor3 = val and Library.Theme.ToggleEnabled or Library.Theme.Toggle})
                    Tween(toggleIndicator, {BackgroundTransparency = val and 0 or 1})
                    callback(val)
                end
                
                function toggle:OnChanged(fn)
                    toggle.Changed = fn
                end
                
                clickDetector.MouseButton1Click:Connect(function()
                    toggle:SetValue(not toggle.Value)
                    if toggle.Changed then toggle.Changed(toggle.Value) end
                end)
                
                toggle.Frame = toggleFrame
                Toggles[idx] = toggle
                table.insert(section.Elements, toggle)
                
                if default then callback(default) end
                
                return toggle
            end
            
            -- Add Slider
            function section:AddSlider(idx, options)
                options = options or {}
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local text = options.Text or "Slider"
                local rounding = options.Rounding or 0
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end
                
                local slider = {
                    Value = default,
                    Type = "Slider",
                    Min = min,
                    Max = max
                }
                
                local sliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local sliderLabel = Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                local valueLabel = Create("TextLabel", {
                    Size = UDim2.new(0.4, -8, 0, 16),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = sliderFrame
                })
                
                local sliderBg = Create("Frame", {
                    Size = UDim2.new(1, -8, 0, 12),
                    Position = UDim2.new(0, 4, 0, 20),
                    BackgroundColor3 = Library.Theme.Toggle,
                    Parent = sliderFrame
                })
                AddCorner(sliderBg, 4)
                
                local sliderFill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme.Slider,
                    Parent = sliderBg
                })
                AddCorner(sliderFill, 4)
                
                function slider:SetValue(val)
                    val = math.clamp(val, min, max)
                    if rounding == 0 then
                        val = math.floor(val)
                    else
                        val = tonumber(string.format("%." .. rounding .. "f", val))
                    end
                    slider.Value = val
                    valueLabel.Text = tostring(val) .. suffix
                    Tween(sliderFill, {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}, 0.1)
                    callback(val)
                end
                
                function slider:OnChanged(fn)
                    slider.Changed = fn
                end
                
                local dragging = false
                
                sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        slider:SetValue(min + (max - min) * ratio)
                        if slider.Changed then slider.Changed(slider.Value) end
                    end
                end)
                
                sliderBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local ratio = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                        slider:SetValue(min + (max - min) * ratio)
                        if slider.Changed then slider.Changed(slider.Value) end
                    end
                end)
                
                slider.Frame = sliderFrame
                Options[idx] = slider
                table.insert(section.Elements, slider)
                
                return slider
            end
            
            -- Add Button
            function section:AddButton(options)
                options = options or {}
                local text = options.Text or "Button"
                local callback = options.Callback or function() end
                
                local button = {}
                
                local buttonFrame = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Library.Theme.Toggle,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    FontFace = Library.Font,
                    Parent = sectionContent
                })
                AddCorner(buttonFrame, 4)
                
                buttonFrame.MouseEnter:Connect(function()
                    Tween(buttonFrame, {BackgroundColor3 = Library.Theme.Accent}, 0.1)
                end)
                
                buttonFrame.MouseLeave:Connect(function()
                    Tween(buttonFrame, {BackgroundColor3 = Library.Theme.Toggle}, 0.1)
                end)
                
                buttonFrame.MouseButton1Click:Connect(callback)
                
                button.Frame = buttonFrame
                table.insert(section.Elements, button)
                
                return button
            end
            
            -- Add Dropdown
            function section:AddDropdown(idx, options)
                options = options or {}
                local text = options.Text or "Dropdown"
                local values = options.Values or {}
                local default = options.Default
                local multi = options.Multi or false
                local callback = options.Callback or function() end
                
                local dropdown = {
                    Value = multi and {} or nil,
                    Values = values,
                    Multi = multi,
                    Type = "Dropdown"
                }
                
                local dropdownFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = sectionContent
                })
                
                local dropdownLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownFrame
                })
                
                local dropdownBtn = Create("TextButton", {
                    Size = UDim2.new(1, -8, 0, 24),
                    Position = UDim2.new(0, 4, 0, 18),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    Text = "",
                    Parent = dropdownFrame
                })
                AddCorner(dropdownBtn, 4)
                AddStroke(dropdownBtn, Library.Theme.Outline)
                
                local selectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "Select...",
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 11,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = dropdownBtn
                })
                
                local arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 16, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 10,
                    FontFace = Library.Font,
                    Parent = dropdownBtn
                })
                
                local dropdownList = Create("Frame", {
                    Size = UDim2.new(1, -8, 0, 0),
                    Position = UDim2.new(0, 4, 0, 44),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = dropdownFrame
                })
                AddCorner(dropdownList, 4)
                AddStroke(dropdownList, Library.Theme.Outline)
                
                local listLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = dropdownList
                })
                AddPadding(dropdownList, 4)
                
                local open = false
                
                local function updateDisplay()
                    if multi then
                        local selected = {}
                        for k, v in pairs(dropdown.Value) do
                            if v then table.insert(selected, k) end
                        end
                        selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
                    else
                        selectedLabel.Text = dropdown.Value or "Select..."
                    end
                end
                
                local function createOption(value)
                    local optBtn = Create("TextButton", {
                        Size = UDim2.new(1, -8, 0, 22),
                        BackgroundColor3 = Library.Theme.Tertiary,
                        BackgroundTransparency = 1,
                        Text = tostring(value),
                        TextColor3 = Library.Theme.SubText,
                        TextSize = 11,
                        FontFace = Library.Font,
                        ZIndex = 11,
                        Parent = dropdownList
                    })
                    AddCorner(optBtn, 3)
                    
                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, {BackgroundTransparency = 0}, 0.1)
                    end)
                    
                    optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, {BackgroundTransparency = 1}, 0.1)
                    end)
                    
                    optBtn.MouseButton1Click:Connect(function()
                        if multi then
                            dropdown.Value[value] = not dropdown.Value[value]
                            optBtn.TextColor3 = dropdown.Value[value] and Library.Theme.Accent or Library.Theme.SubText
                        else
                            dropdown.Value = value
                            open = false
                            Tween(dropdownList, {Size = UDim2.new(1, -8, 0, 0)}, 0.15)
                            task.wait(0.15)
                            dropdownList.Visible = false
                            Tween(arrow, {Rotation = 0}, 0.15)
                        end
                        updateDisplay()
                        callback(dropdown.Value)
                    end)
                    
                    return optBtn
                end
                
                for _, v in ipairs(values) do
                    createOption(v)
                end
                
                dropdownBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        dropdownList.Visible = true
                        local height = math.min(#values * 24 + 10, 150)
                        Tween(dropdownList, {Size = UDim2.new(1, -8, 0, height)}, 0.15)
                        Tween(arrow, {Rotation = 180}, 0.15)
                    else
                        Tween(dropdownList, {Size = UDim2.new(1, -8, 0, 0)}, 0.15)
                        task.wait(0.15)
                        dropdownList.Visible = false
                        Tween(arrow, {Rotation = 0}, 0.15)
                    end
                end)
                
                function dropdown:SetValue(val)
                    if multi then
                        dropdown.Value = val
                    else
                        dropdown.Value = val
                    end
                    updateDisplay()
                    callback(dropdown.Value)
                end
                
                function dropdown:SetValues(newValues)
                    for _, c in ipairs(dropdownList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    dropdown.Values = newValues
                    for _, v in ipairs(newValues) do
                        createOption(v)
                    end
                end
                
                function dropdown:OnChanged(fn)
                    dropdown.Changed = fn
                end
                
                if default then
                    dropdown:SetValue(default)
                end
                
                dropdown.Frame = dropdownFrame
                Options[idx] = dropdown
                table.insert(section.Elements, dropdown)
                
                return dropdown
            end
            
            -- Add Input
            function section:AddInput(idx, options)
                options = options or {}
                local text = options.Text or "Input"
                local default = options.Default or ""
                local placeholder = options.Placeholder or "Enter text..."
                local callback = options.Callback or function() end
                
                local input = {
                    Value = default,
                    Type = "Input"
                }
                
                local inputFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local inputLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -8, 0, 16),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = inputFrame
                })
                
                local inputBox = Create("TextBox", {
                    Size = UDim2.new(1, -8, 0, 24),
                    Position = UDim2.new(0, 4, 0, 18),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    Text = default,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Library.Theme.SubText,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 11,
                    FontFace = Library.Font,
                    ClearTextOnFocus = false,
                    Parent = inputFrame
                })
                AddCorner(inputBox, 4)
                AddStroke(inputBox, Library.Theme.Outline)
                
                inputBox.FocusLost:Connect(function()
                    input.Value = inputBox.Text
                    callback(input.Value)
                    if input.Changed then input.Changed(input.Value) end
                end)
                
                function input:SetValue(val)
                    input.Value = val
                    inputBox.Text = val
                    callback(val)
                end
                
                function input:OnChanged(fn)
                    input.Changed = fn
                end
                
                input.Frame = inputFrame
                Options[idx] = input
                table.insert(section.Elements, input)
                
                return input
            end
            
            -- Add Label
            function section:AddLabel(text)
                local label = {}
                
                local labelFrame = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 11,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sectionContent
                })
                
                function label:SetText(newText)
                    labelFrame.Text = newText
                end
                
                label.Frame = labelFrame
                table.insert(section.Elements, label)
                
                return label
            end
            
            -- Add Divider
            function section:AddDivider()
                local divider = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Library.Theme.Outline,
                    Parent = sectionContent
                })
                return divider
            end
            
            -- Add Keybind
            function section:AddKeybind(idx, options)
                options = options or {}
                local text = options.Text or "Keybind"
                local default = options.Default or "None"
                local callback = options.Callback or function() end
                local changedCallback = options.ChangedCallback or function() end
                
                local keybind = {
                    Value = default,
                    Type = "Keybind"
                }
                
                local keybindFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local keybindLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = keybindFrame
                })
                
                local keybindBtn = Create("TextButton", {
                    Size = UDim2.new(0, 60, 0, 20),
                    Position = UDim2.new(1, -64, 0.5, -10),
                    BackgroundColor3 = Library.Theme.Toggle,
                    Text = default,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 10,
                    FontFace = Library.Font,
                    Parent = keybindFrame
                })
                AddCorner(keybindBtn, 4)
                
                local listening = false
                
                keybindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keybindBtn.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            keybind.Value = input.KeyCode.Name
                            keybindBtn.Text = input.KeyCode.Name
                            listening = false
                            changedCallback(keybind.Value)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                            keybind.Value = "None"
                            keybindBtn.Text = "None"
                            listening = false
                            changedCallback(keybind.Value)
                        end
                    else
                        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode.Name == keybind.Value then
                                callback()
                            end
                        end
                    end
                end)
                
                function keybind:SetValue(key)
                    keybind.Value = key
                    keybindBtn.Text = key
                    changedCallback(key)
                end
                
                keybind.Frame = keybindFrame
                Options[idx] = keybind
                table.insert(section.Elements, keybind)
                
                return keybind
            end
            
            -- Add ColorPicker
            function section:AddColorPicker(idx, options)
                options = options or {}
                local text = options.Text or "Color"
                local default = options.Default or Color3.new(1, 1, 1)
                local callback = options.Callback or function() end
                
                local colorpicker = {
                    Value = default,
                    Type = "ColorPicker"
                }
                
                local cpFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Parent = sectionContent
                })
                
                local cpLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Library.Theme.SubText,
                    TextSize = 12,
                    FontFace = Library.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = cpFrame
                })
                
                local colorBtn = Create("TextButton", {
                    Size = UDim2.new(0, 30, 0, 18),
                    Position = UDim2.new(1, -34, 0.5, -9),
                    BackgroundColor3 = default,
                    Text = "",
                    Parent = cpFrame
                })
                AddCorner(colorBtn, 4)
                AddStroke(colorBtn, Library.Theme.Outline)
                
                function colorpicker:SetValue(color)
                    colorpicker.Value = color
                    colorBtn.BackgroundColor3 = color
                    callback(color)
                end
                
                function colorpicker:SetValueRGB(color)
                    colorpicker:SetValue(color)
                end
                
                -- Simple color picker popup (basic implementation)
                local pickerOpen = false
                local pickerFrame
                
                colorBtn.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    if pickerOpen then
                        pickerFrame = Create("Frame", {
                            Size = UDim2.new(0, 160, 0, 180),
                            Position = UDim2.new(1, -164, 0, 26),
                            BackgroundColor3 = Library.Theme.Secondary,
                            ZIndex = 20,
                            Parent = cpFrame
                        })
                        AddCorner(pickerFrame, 6)
                        AddStroke(pickerFrame, Library.Theme.Outline)
                        
                        local hue, sat, val = colorpicker.Value:ToHSV()
                        
                        -- Saturation/Value picker
                        local svPicker = Create("ImageButton", {
                            Size = UDim2.new(0, 140, 0, 100),
                            Position = UDim2.new(0, 10, 0, 10),
                            BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                            ZIndex = 21,
                            Parent = pickerFrame
                        })
                        AddCorner(svPicker, 4)
                        
                        local svGradient = Create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                            }),
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            }),
                            Parent = svPicker
                        })
                        
                        local svDark = Create("Frame", {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            ZIndex = 22,
                            Parent = svPicker
                        })
                        Create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                            }),
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0)
                            }),
                            Rotation = 90,
                            Parent = svDark
                        })
                        AddCorner(svDark, 4)
                        
                        -- Hue slider
                        local hueSlider = Create("ImageButton", {
                            Size = UDim2.new(0, 140, 0, 16),
                            Position = UDim2.new(0, 10, 0, 118),
                            ZIndex = 21,
                            Parent = pickerFrame
                        })
                        AddCorner(hueSlider, 4)
                        
                        Create("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                                ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                                ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                                ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                                ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
                            }),
                            Parent = hueSlider
                        })
                        
                        -- Apply button
                        local applyBtn = Create("TextButton", {
                            Size = UDim2.new(0, 140, 0, 24),
                            Position = UDim2.new(0, 10, 0, 142),
                            BackgroundColor3 = Library.Theme.Accent,
                            Text = "Apply",
                            TextColor3 = Library.Theme.Text,
                            TextSize = 11,
                            FontFace = Library.Font,
                            ZIndex = 21,
                            Parent = pickerFrame
                        })
                        AddCorner(applyBtn, 4)
                        
                        local function updateColor()
                            local color = Color3.fromHSV(hue, sat, val)
                            svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                            colorpicker:SetValue(color)
                        end
                        
                        local svDragging = false
                        local hueDragging = false
                        
                        svPicker.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                svDragging = true
                            end
                        end)
                        
                        svPicker.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                svDragging = false
                            end
                        end)
                        
                        hueSlider.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                hueDragging = true
                            end
                        end)
                        
                        hueSlider.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                hueDragging = false
                            end
                        end)
                        
                        UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if svDragging then
                                    sat = math.clamp((input.Position.X - svPicker.AbsolutePosition.X) / svPicker.AbsoluteSize.X, 0, 1)
                                    val = 1 - math.clamp((input.Position.Y - svPicker.AbsolutePosition.Y) / svPicker.AbsoluteSize.Y, 0, 1)
                                    updateColor()
                                elseif hueDragging then
                                    hue = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                                    updateColor()
                                end
                            end
                        end)
                        
                        applyBtn.MouseButton1Click:Connect(function()
                            pickerOpen = false
                            pickerFrame:Destroy()
                        end)
                    else
                        if pickerFrame then
                            pickerFrame:Destroy()
                        end
                    end
                end)
                
                colorpicker.Frame = cpFrame
                Options[idx] = colorpicker
                table.insert(section.Elements, colorpicker)
                
                return colorpicker
            end
            
            return section
        end
        
        return tab
    end
    
    return Window
end

-- Unload
function Library:Unload()
    self.Unloaded = true
    for _, signal in ipairs(self.Signals) do
        if typeof(signal) == "RBXScriptConnection" then
            signal:Disconnect()
        end
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

-- Make globals accessible
getgenv().Toggles = Toggles
getgenv().Options = Options

return Library
