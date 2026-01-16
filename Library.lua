--[[
    Serdiums UI Library
    Gamesense Style 1:1 Clone
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.Theme = {
    Main = Color3.fromRGB(24, 24, 24),
    Sidebar = Color3.fromRGB(20, 20, 20),
    SidebarBtn = Color3.fromRGB(32, 32, 32),
    SidebarBtnActive = Color3.fromRGB(45, 45, 45),
    Section = Color3.fromRGB(28, 28, 28),
    SectionHeader = Color3.fromRGB(36, 36, 36),
    Element = Color3.fromRGB(32, 32, 32),
    Text = Color3.fromRGB(170, 170, 170),
    TextDim = Color3.fromRGB(100, 100, 100),
    TextBright = Color3.fromRGB(220, 220, 220),
    Accent = Color3.fromRGB(172, 208, 66),
    AccentDim = Color3.fromRGB(130, 160, 50),
    Risky = Color3.fromRGB(232, 93, 93),
    Slider = Color3.fromRGB(45, 45, 45),
    SliderFill = Color3.fromRGB(172, 208, 66),
    Dropdown = Color3.fromRGB(38, 38, 38),
    DropdownBorder = Color3.fromRGB(55, 55, 55),
    Checkbox = Color3.fromRGB(45, 45, 45),
    CheckboxBorder = Color3.fromRGB(60, 60, 60),
    Border = Color3.fromRGB(50, 50, 50),
    Separator = Color3.fromRGB(45, 45, 45)
}
Library.Toggles = {}
Library.Options = {}
Library.Flags = {}
Library.ScreenGui = nil
Library.Open = true
Library.ToggleKey = Enum.KeyCode.RightControl

-- Icons (simple text-based for now, can be replaced with ImageLabels)
local Icons = {
    crosshair = "⊕",
    eye = "◉",
    shield = "◈",
    settings = "⚙",
    save = "💾",
    person = "👤",
    radar = "◎",
    misc = "☰"
}

--// HELPERS \\--
local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() inst[k] = v end) end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--// WINDOW \\--
function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Serdiums"
    local size = config.Size or UDim2.new(0, 600, 0, 450)

    -- Destroy old
    if Library.ScreenGui then Library.ScreenGui:Destroy() end

    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "Serdiums",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    Library.ScreenGui = ScreenGui

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Library.Theme.Main,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})
    Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Main})

    -- Sidebar (left)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = Library.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    -- Cover right corners
    Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Library.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    local TabButtons = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabButtons
    })

    -- Content Area
    local Content = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -54, 1, -8),
        Position = UDim2.new(0, 52, 0, 4),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    MakeDraggable(Main, Main)

    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            Main.Visible = Library.Open
        end
    end)

    local Window = {Main = Main, Sidebar = Sidebar, TabButtons = TabButtons, Content = Content, Tabs = {}, ActiveTab = nil}

    function Window:AddTab(name, icon)
        local iconText = Icons[icon] or icon or "◉"

        local TabBtn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 38, 0, 38),
            BackgroundColor3 = Library.Theme.SidebarBtn,
            BorderSizePixel = 0,
            Text = iconText,
            TextColor3 = Library.Theme.TextDim,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            Parent = TabButtons
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        local TabContent = Create("Frame", {
            Name = name .. "_Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = Content
        })

        -- Two columns
        local LeftCol = Create("ScrollingFrame", {
            Name = "Left",
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = LeftCol})
        Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = LeftCol})

        local RightCol = Create("ScrollingFrame", {
            Name = "Right",
            Size = UDim2.new(0.5, -4, 1, 0),
            Position = UDim2.new(0.5, 4, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabContent
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = RightCol})
        Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2), Parent = RightCol})

        local Tab = {Name = name, Button = TabBtn, Content = TabContent, Left = LeftCol, Right = RightCol}
        table.insert(Window.Tabs, Tab)

        TabBtn.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Library.Theme.SidebarBtnActive})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                Tween(TabBtn, {BackgroundColor3 = Library.Theme.SidebarBtn})
            end
        end)
        TabBtn.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        -- Select first tab
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end

        -- Section builder
        function Tab:AddLeftSection(name) return Library:CreateSection(LeftCol, name) end
        function Tab:AddRightSection(name) return Library:CreateSection(RightCol, name) end

        return Tab
    end

    function Window:SelectTab(tab)
        if Window.ActiveTab then
            Window.ActiveTab.Content.Visible = false
            Window.ActiveTab.Button.BackgroundColor3 = Library.Theme.SidebarBtn
            Window.ActiveTab.Button.TextColor3 = Library.Theme.TextDim
        end
        Window.ActiveTab = tab
        tab.Content.Visible = true
        tab.Button.BackgroundColor3 = Library.Theme.SidebarBtnActive
        tab.Button.TextColor3 = Library.Theme.Accent
    end

    return Window
end

--// SECTION \\--
function Library:CreateSection(parent, name)
    local Section = Create("Frame", {
        Name = name,
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Library.Theme.Section,
        BorderSizePixel = 0,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Section})

    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Library.Theme.SectionHeader,
        BorderSizePixel = 0,
        Parent = Section
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Header})
    -- Cover bottom corners
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = Library.Theme.SectionHeader,
        BorderSizePixel = 0,
        Parent = Header
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Library.Theme.TextBright,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })

    -- Elements container
    local Elements = Create("Frame", {
        Name = "Elements",
        Size = UDim2.new(1, -8, 0, 0),
        Position = UDim2.new(0, 4, 0, 26),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = Section
    })
    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = Elements})
    Create("UIPadding", {PaddingBottom = UDim.new(0, 6), Parent = Elements})

    local SectionObj = {Frame = Section, Elements = Elements}

    function SectionObj:AddToggle(id, config)
        return Library:CreateToggle(Elements, id, config)
    end

    function SectionObj:AddSlider(id, config)
        return Library:CreateSlider(Elements, id, config)
    end

    function SectionObj:AddDropdown(id, config)
        return Library:CreateDropdown(Elements, id, config)
    end

    function SectionObj:AddColorPicker(id, config)
        return Library:CreateColorPicker(Elements, id, config)
    end

    function SectionObj:AddKeybind(id, config)
        return Library:CreateKeybind(Elements, id, config)
    end

    function SectionObj:AddButton(text, callback)
        return Library:CreateButton(Elements, text, callback)
    end

    function SectionObj:AddLabel(text)
        return Library:CreateLabel(Elements, text)
    end

    function SectionObj:AddSeparator()
        return Library:CreateSeparator(Elements)
    end

    return SectionObj
end

--// TOGGLE \\--
function Library:CreateToggle(parent, id, config)
    config = config or {}
    local default = config.Default or false
    local hasDropdown = config.Dropdown ~= nil
    local isRisky = config.Risky or false

    local height = 18
    if hasDropdown then height = height + 22 end

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Parent = parent
    })

    -- Checkbox (small square)
    local Checkbox = Create("TextButton", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = Library.Theme.Checkbox,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Checkbox})
    Create("UIStroke", {Color = Library.Theme.CheckboxBorder, Thickness = 1, Parent = Checkbox})

    -- Check indicator (inner square)
    local Check = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0.5, -3, 0.5, -3),
        BackgroundColor3 = isRisky and Library.Theme.Risky or Library.Theme.Accent,
        Visible = default,
        Parent = Checkbox
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = Check})

    -- Label
    local Label = Create("TextButton", {
        Size = UDim2.new(1, -14, 0, 18),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = isRisky and Library.Theme.Risky or Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = Container
    })

    local Toggle = {Value = default, Type = "Toggle"}
    Library.Toggles[id] = Toggle
    if config.Flag then Library.Flags[config.Flag] = Toggle end

    local function SetValue(val)
        Toggle.Value = val
        Check.Visible = val
        Checkbox.BackgroundColor3 = val and (isRisky and Library.Theme.Risky or Library.Theme.Accent) or Library.Theme.Checkbox
        Check.BackgroundColor3 = isRisky and Library.Theme.Risky or Library.Theme.Accent
        if config.Callback then task.spawn(config.Callback, val) end
    end

    local function OnClick()
        SetValue(not Toggle.Value)
    end

    Checkbox.MouseButton1Click:Connect(OnClick)
    Label.MouseButton1Click:Connect(OnClick)

    function Toggle:SetValue(v) SetValue(v) end

    -- Inline dropdown under toggle
    if hasDropdown then
        local dc = config.Dropdown
        local vals = dc.Values or {}
        local ddef = dc.Default or vals[1]

        local DropBtn = Create("TextButton", {
            Size = UDim2.new(1, -14, 0, 18),
            Position = UDim2.new(0, 14, 0, 20),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = false,
            Parent = Container
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
        Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = DropBtn})

        local DropText = Create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(ddef),
            TextColor3 = Library.Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = DropBtn
        })

        local Arrow = Create("TextLabel", {
            Size = UDim2.new(0, 14, 1, 0),
            Position = UDim2.new(1, -14, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = Library.Theme.TextDim,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Parent = DropBtn
        })

        local Dropdown = {Value = ddef, Values = vals, Type = "Dropdown"}
        if dc.Flag then Library.Options[dc.Flag] = Dropdown Library.Flags[dc.Flag] = Dropdown end

        local isOpen = false
        local OptionsList

        local function Close()
            if OptionsList then OptionsList:Destroy() OptionsList = nil end
            isOpen = false
            Arrow.Text = "▾"
        end

        local function Open()
            if isOpen then Close() return end
            isOpen = true
            Arrow.Text = "▴"

            OptionsList = Create("Frame", {
                Size = UDim2.new(1, 0, 0, math.min(#vals * 18, 100)),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Library.Theme.Dropdown,
                ZIndex = 50,
                ClipsDescendants = true,
                Parent = DropBtn
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptionsList})
            Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = OptionsList})
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList})

            for _, val in ipairs(vals) do
                local Opt = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "  " .. val,
                    TextColor3 = val == Dropdown.Value and Library.Theme.Accent or Library.Theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 51,
                    Parent = OptionsList
                })
                Opt.MouseEnter:Connect(function() Tween(Opt, {BackgroundTransparency = 0.9, BackgroundColor3 = Library.Theme.Accent}) end)
                Opt.MouseLeave:Connect(function() Tween(Opt, {BackgroundTransparency = 1}) end)
                Opt.MouseButton1Click:Connect(function()
                    Dropdown.Value = val
                    DropText.Text = val
                    Close()
                    if dc.Callback then task.spawn(dc.Callback, val) end
                end)
            end
        end

        DropBtn.MouseButton1Click:Connect(Open)
        function Dropdown:SetValue(v) Dropdown.Value = v DropText.Text = v if dc.Callback then task.spawn(dc.Callback, v) end end
        Toggle.Dropdown = Dropdown
    end

    return Toggle
end

--// SLIDER \\--
function Library:CreateSlider(parent, id, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    local rounding = config.Rounding or 0
    local suffix = config.Suffix or ""

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.65, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local ValueLabel = Create("TextLabel", {
        Size = UDim2.new(0.35, 0, 0, 14),
        Position = UDim2.new(0.65, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Library.Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Container
    })

    local SliderBg = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 5),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundColor3 = Library.Theme.Slider,
        BorderSizePixel = 0,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = SliderBg})

    local Fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = SliderBg
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Fill})

    local Slider = {Value = default, Type = "Slider", Min = min, Max = max}
    Library.Options[id] = Slider
    if config.Flag then Library.Flags[config.Flag] = Slider end

    local function FormatVal(v)
        if rounding == 0 then return tostring(math.floor(v)) .. suffix
        else return string.format("%." .. rounding .. "f", v) .. suffix end
    end

    local function SetValue(val)
        val = math.clamp(val, min, max)
        if rounding == 0 then val = math.floor(val)
        else val = math.floor(val * 10^rounding + 0.5) / 10^rounding end
        Slider.Value = val
        local pct = (val - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        ValueLabel.Text = FormatVal(val)
        if config.Callback then task.spawn(config.Callback, val) end
    end

    SetValue(default)

    local dragging = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local p = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SetValue(min + (max - min) * p)
        end
    end)
    SliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SetValue(min + (max - min) * p)
        end
    end)

    function Slider:SetValue(v) SetValue(v) end
    return Slider
end

--// DROPDOWN \\--
function Library:CreateDropdown(parent, id, config)
    config = config or {}
    local values = config.Values or {}
    local default = config.Default or values[1]
    local multi = config.Multi or false

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local DropBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 16),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
    Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = DropBtn})

    local DropText = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = multi and "None" or tostring(default or "..."),
        TextColor3 = Library.Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = DropBtn
    })

    local Arrow = Create("TextLabel", {
        Size = UDim2.new(0, 14, 1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = Library.Theme.TextDim,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Parent = DropBtn
    })

    local Dropdown = {Value = multi and {} or default, Values = values, Type = "Dropdown", Multi = multi}
    Library.Options[id] = Dropdown
    if config.Flag then Library.Flags[config.Flag] = Dropdown end

    local isOpen = false
    local OptionsList

    local function UpdateText()
        if multi then
            local sel = {}
            for v, s in pairs(Dropdown.Value) do if s then table.insert(sel, v) end end
            DropText.Text = #sel > 0 and table.concat(sel, ", ") or "None"
        else
            DropText.Text = tostring(Dropdown.Value)
        end
    end

    local function Close()
        if OptionsList then OptionsList:Destroy() OptionsList = nil end
        isOpen = false
        Arrow.Text = "▾"
    end

    local function Open()
        if isOpen then Close() return end
        isOpen = true
        Arrow.Text = "▴"

        local h = math.min(#values * 18, 120)
        OptionsList = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.new(0, 0, 1, 2),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, #values * 18),
            ZIndex = 50,
            Parent = DropBtn
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptionsList})
        Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = OptionsList})
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList})

        for _, val in ipairs(values) do
            local isSel = multi and Dropdown.Value[val] or (Dropdown.Value == val)
            local Opt = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = "  " .. val,
                TextColor3 = isSel and Library.Theme.Accent or Library.Theme.Text,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 51,
                Parent = OptionsList
            })
            Opt.MouseEnter:Connect(function() Tween(Opt, {BackgroundTransparency = 0.9, BackgroundColor3 = Library.Theme.Accent}) end)
            Opt.MouseLeave:Connect(function() Tween(Opt, {BackgroundTransparency = 1}) end)
            Opt.MouseButton1Click:Connect(function()
                if multi then
                    Dropdown.Value[val] = not Dropdown.Value[val]
                    Opt.TextColor3 = Dropdown.Value[val] and Library.Theme.Accent or Library.Theme.Text
                    UpdateText()
                    if config.Callback then task.spawn(config.Callback, Dropdown.Value) end
                else
                    Dropdown.Value = val
                    UpdateText()
                    Close()
                    if config.Callback then task.spawn(config.Callback, val) end
                end
            end)
        end
    end

    DropBtn.MouseButton1Click:Connect(Open)
    function Dropdown:SetValue(v) Dropdown.Value = v UpdateText() if config.Callback then task.spawn(config.Callback, v) end end
    function Dropdown:Refresh(newVals) Dropdown.Values = newVals values = newVals end
    return Dropdown
end

--// COLOR PICKER \\--
function Library:CreateColorPicker(parent, id, config)
    config = config or {}
    local default = config.Default or Color3.fromRGB(255, 255, 255)

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local ColorBtn = Create("TextButton", {
        Size = UDim2.new(0, 18, 0, 12),
        Position = UDim2.new(1, -18, 0, 3),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = ColorBtn})
    Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = ColorBtn})

    local ColorPicker = {Value = default, Type = "ColorPicker"}
    Library.Options[id] = ColorPicker
    if config.Flag then Library.Flags[config.Flag] = ColorPicker end

    function ColorPicker:SetValue(col)
        ColorPicker.Value = col
        ColorBtn.BackgroundColor3 = col
        if config.Callback then task.spawn(config.Callback, col) end
    end

    -- Simple color picker popup (basic)
    local isOpen = false
    local Popup

    ColorBtn.MouseButton1Click:Connect(function()
        if isOpen then
            if Popup then Popup:Destroy() end
            isOpen = false
            return
        end
        isOpen = true

        Popup = Create("Frame", {
            Size = UDim2.new(0, 150, 0, 100),
            Position = UDim2.new(1, 4, 0, 0),
            BackgroundColor3 = Library.Theme.Section,
            ZIndex = 60,
            Parent = ColorBtn
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Popup})
        Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Popup})

        -- Simple RGB sliders
        local yPos = 8
        for i, channel in ipairs({"R", "G", "B"}) do
            local rgb = {ColorPicker.Value.R * 255, ColorPicker.Value.G * 255, ColorPicker.Value.B * 255}

            local Lbl = Create("TextLabel", {
                Size = UDim2.new(0, 15, 0, 14),
                Position = UDim2.new(0, 6, 0, yPos),
                BackgroundTransparency = 1,
                Text = channel,
                TextColor3 = Library.Theme.Text,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                ZIndex = 61,
                Parent = Popup
            })

            local SliderBg = Create("Frame", {
                Size = UDim2.new(1, -30, 0, 10),
                Position = UDim2.new(0, 22, 0, yPos + 2),
                BackgroundColor3 = Library.Theme.Slider,
                ZIndex = 61,
                Parent = Popup
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = SliderBg})

            local Fill = Create("Frame", {
                Size = UDim2.new(rgb[i] / 255, 0, 1, 0),
                BackgroundColor3 = channel == "R" and Color3.new(1,0.3,0.3) or channel == "G" and Color3.new(0.3,1,0.3) or Color3.new(0.3,0.3,1),
                ZIndex = 62,
                Parent = SliderBg
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Fill})

            local dragging = false
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local p = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    rgb[i] = math.floor(p * 255)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    local newCol = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
                    ColorPicker:SetValue(newCol)
                end
            end)
            SliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    rgb[i] = math.floor(p * 255)
                    Fill.Size = UDim2.new(p, 0, 1, 0)
                    local r = ColorPicker.Value.R * 255
                    local g = ColorPicker.Value.G * 255
                    local b = ColorPicker.Value.B * 255
                    if channel == "R" then r = rgb[i] elseif channel == "G" then g = rgb[i] else b = rgb[i] end
                    ColorPicker:SetValue(Color3.fromRGB(r, g, b))
                end
            end)

            yPos = yPos + 24
        end
    end)

    return ColorPicker
end

--// KEYBIND \\--
function Library:CreateKeybind(parent, id, config)
    config = config or {}
    local default = config.Default or Enum.KeyCode.Unknown

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local KeyBtn = Create("TextButton", {
        Size = UDim2.new(0, 45, 0, 14),
        Position = UDim2.new(1, -45, 0, 2),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = default.Name or "...",
        TextColor3 = Library.Theme.Text,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = KeyBtn})
    Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = KeyBtn})

    local Keybind = {Value = default, Type = "Keybind", Binding = false}
    Library.Options[id] = Keybind
    if config.Flag then Library.Flags[config.Flag] = Keybind end

    function Keybind:SetValue(key)
        Keybind.Value = key
        KeyBtn.Text = key.Name or "..."
        if config.Callback then task.spawn(config.Callback, key) end
    end

    KeyBtn.MouseButton1Click:Connect(function()
        if Keybind.Binding then return end
        Keybind.Binding = true
        KeyBtn.Text = "..."

        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind:SetValue(input.KeyCode)
                Keybind.Binding = false
                conn:Disconnect()
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                -- Cancel
                KeyBtn.Text = Keybind.Value.Name or "..."
                Keybind.Binding = false
                conn:Disconnect()
            end
        end)
    end)

    -- Listen for key press
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and not Keybind.Binding and input.KeyCode == Keybind.Value then
            if config.OnPressed then config.OnPressed() end
        end
    end)

    return Keybind
end

--// BUTTON \\--
function Library:CreateButton(parent, text, callback)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Button})
    Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = Button})

    Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3 = Library.Theme.SidebarBtnActive}) end)
    Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3 = Library.Theme.Dropdown}) end)
    Button.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)

    return Button
end

--// LABEL \\--
function Library:CreateLabel(parent, text)
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent
    })
    return Label
end

--// SEPARATOR \\--
function Library:CreateSeparator(parent)
    local Sep = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Library.Theme.Separator,
        BorderSizePixel = 0,
        Parent = parent
    })
    return Sep
end

--// NOTIFY \\--
function Library:Notify(title, text, duration)
    duration = duration or 3

    local Notif = Create("Frame", {
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(1, -260, 1, -70),
        BackgroundColor3 = Library.Theme.Section,
        Parent = Library.ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Notif})
    Create("UIStroke", {Color = Library.Theme.Accent, Thickness = 1, Parent = Notif})

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 8, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Library.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notif
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 8, 0, 25),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Library.Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = Notif
    })

    task.delay(duration, function()
        Tween(Notif, {Position = UDim2.new(1, 10, 1, -70)}, 0.3)
        task.wait(0.3)
        Notif:Destroy()
    end)
end

return Library
