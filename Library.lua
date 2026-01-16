--[[
    Serdiums UI Library
    Exact Gamesense Style 1:1
    
    Features:
    - Left sidebar with icon tabs
    - 2 column layout per tab
    - Inline checkboxes (☐ style)
    - Inline dropdowns after toggles
    - Colored slider fills with percentage
    - Dark theme matching gamesense exactly
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
    ToggleKey = Enum.KeyCode.RightControl
}

--// UTILITY FUNCTIONS \\--

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

Library.Create = Create
Library.Tween = Tween

--// ELEMENT CREATORS \\--

local function CreateToggle(parent, id, config)
    config = config or {}
    local default = config.Default or false
    local hasDropdown = config.Dropdown ~= nil
    local height = hasDropdown and 40 or 20

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Parent = parent
    })

    -- Checkbox
    local Checkbox = Create("TextButton", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 2, 0, 4),
        BackgroundColor3 = Library.Theme.Checkbox,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Checkbox})
    Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Checkbox})

    -- Checkmark
    local Check = Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0.5, -3, 0.5, -3),
        BackgroundColor3 = config.Risky and Library.Theme.Risky or Library.Theme.CheckboxCheck,
        Visible = default,
        Parent = Checkbox
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = Check})

    -- Label
    local Label = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = config.Risky and Library.Theme.Risky or Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = Container
    })

    local Toggle = {Value = default, Type = "Toggle"}
    Library.Toggles[id] = Toggle

    local function SetValue(val)
        Toggle.Value = val
        Check.Visible = val
        if config.Callback then task.spawn(config.Callback, val) end
    end

    local function OnClick()
        SetValue(not Toggle.Value)
    end

    Checkbox.MouseButton1Click:Connect(OnClick)
    Label.MouseButton1Click:Connect(OnClick)

    function Toggle:SetValue(val) SetValue(val) end

    -- Inline Dropdown
    if hasDropdown then
        local dc = config.Dropdown
        local vals = dc.Values or {}
        local ddef = dc.Default or vals[1]

        local DropBtn = Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 16),
            Position = UDim2.new(0, 2, 0, 22),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
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
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -16, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = Library.Theme.TextDark,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Parent = DropBtn
        })

        local Dropdown = {Value = ddef, Values = vals, Type = "Dropdown"}
        if dc.Flag then Library.Options[dc.Flag] = Dropdown end

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
                Size = UDim2.new(1, 0, 0, #vals * 18),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Library.Theme.Dropdown,
                ZIndex = 100,
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
                    ZIndex = 101,
                    Parent = OptionsList
                })
                Opt.MouseEnter:Connect(function()
                    Opt.BackgroundTransparency = 0.8
                    Opt.BackgroundColor3 = Library.Theme.Accent
                end)
                Opt.MouseLeave:Connect(function()
                    Opt.BackgroundTransparency = 1
                end)
                Opt.MouseButton1Click:Connect(function()
                    Dropdown.Value = val
                    DropText.Text = val
                    Close()
                    if dc.Callback then task.spawn(dc.Callback, val) end
                end)
            end
        end

        DropBtn.MouseButton1Click:Connect(Open)

        function Dropdown:SetValue(val)
            Dropdown.Value = val
            DropText.Text = val
            if dc.Callback then task.spawn(dc.Callback, val) end
        end

        Toggle.Dropdown = Dropdown
    end

    return Toggle
end

local function CreateSlider(parent, id, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    local rounding = config.Rounding or 0
    local suffix = config.Suffix or ""

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 16),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local ValueLabel = Create("TextLabel", {
        Size = UDim2.new(0.4, -4, 0, 16),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Library.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = Container
    })

    local SliderBg = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 6),
        Position = UDim2.new(0, 2, 0, 20),
        BackgroundColor3 = Library.Theme.SliderBg,
        BorderSizePixel = 0,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = SliderBg})

    local Fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = SliderBg
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Fill})

    local Slider = {Value = default, Type = "Slider", Min = min, Max = max}
    Library.Options[id] = Slider

    local function FormatValue(val)
        if rounding == 0 then return tostring(math.floor(val))
        else return string.format("%." .. rounding .. "f", val) end
    end

    local function SetValue(val)
        val = math.clamp(val, min, max)
        if rounding == 0 then val = math.floor(val)
        else val = math.floor(val * 10^rounding + 0.5) / 10^rounding end
        Slider.Value = val
        local percent = (val - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        ValueLabel.Text = FormatValue(val) .. suffix
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

    function Slider:SetValue(val) SetValue(val) end
    return Slider
end

local function CreateDropdown(parent, id, config)
    config = config or {}
    local values = config.Values or {}
    local default = config.Default or values[1]
    local multi = config.Multi or false

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 16),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local DropBtn = Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 18),
        Position = UDim2.new(0, 2, 0, 18),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
    Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = DropBtn})

    local DropText = Create("TextLabel", {
        Size = UDim2.new(1, -22, 1, 0),
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
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = Library.Theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Parent = DropBtn
    })

    local Dropdown = {Value = multi and {} or default, Values = values, Type = "Dropdown", Multi = multi}
    Library.Options[id] = Dropdown

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

        local h = math.min(#values * 18, 150)
        OptionsList = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, h),
            Position = UDim2.new(0, 0, 1, 2),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, #values * 18),
            ZIndex = 100,
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
                ZIndex = 101,
                Parent = OptionsList
            })
            Opt.MouseEnter:Connect(function()
                Opt.BackgroundTransparency = 0.85
                Opt.BackgroundColor3 = Library.Theme.Accent
            end)
            Opt.MouseLeave:Connect(function()
                Opt.BackgroundTransparency = 1
            end)
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

    function Dropdown:SetValue(val)
        Dropdown.Value = val
        UpdateText()
        if config.Callback then task.spawn(config.Callback, val) end
    end

    function Dropdown:SetValues(newVals)
        values = newVals
        Dropdown.Values = newVals
    end

    UpdateText()
    return Dropdown
end

local function CreateColorPicker(parent, id, config)
    config = config or {}
    local default = config.Default or Color3.new(1, 1, 1)

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local ColorBtn = Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 14),
        Position = UDim2.new(1, -26, 0.5, -7),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Text = "",
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ColorBtn})
    Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = ColorBtn})

    local CP = {Value = default, Type = "ColorPicker"}
    Library.Options[id] = CP

    local Popup, isOpen
    local colors = {
        Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1),
        Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1), Color3.new(1,0.5,0),
        Color3.fromRGB(160,190,60), Color3.new(0.5,0,1), Color3.new(0,0.5,1), Color3.new(0,0,0)
    }

    ColorBtn.MouseButton1Click:Connect(function()
        if isOpen and Popup then
            Popup:Destroy()
            Popup = nil
            isOpen = false
            return
        end
        isOpen = true
        Popup = Create("Frame", {
            Size = UDim2.new(0, 130, 0, 85),
            Position = UDim2.new(1, 5, 0, 0),
            BackgroundColor3 = Library.Theme.Section,
            ZIndex = 100,
            Parent = Container
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Popup})
        Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Popup})

        for i, col in ipairs(colors) do
            local x = ((i-1) % 4) * 30 + 5
            local y = math.floor((i-1) / 4) * 24 + 5
            local ColBtn = Create("TextButton", {
                Size = UDim2.new(0, 26, 0, 20),
                Position = UDim2.new(0, x, 0, y),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                Text = "",
                ZIndex = 101,
                Parent = Popup
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ColBtn})
            ColBtn.MouseButton1Click:Connect(function()
                CP.Value = col
                ColorBtn.BackgroundColor3 = col
                Popup:Destroy()
                Popup = nil
                isOpen = false
                if config.Callback then task.spawn(config.Callback, col) end
            end)
        end
    end)

    function CP:SetValue(col)
        CP.Value = col
        ColorBtn.BackgroundColor3 = col
    end

    return CP
end

local function CreateKeybind(parent, id, config)
    config = config or {}
    local default = config.Default

    local Container = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -55, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Text or id,
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Container
    })

    local KeyBtn = Create("TextButton", {
        Size = UDim2.new(0, 50, 0, 16),
        Position = UDim2.new(1, -52, 0.5, -8),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = default and ("[" .. default .. "]") or "[...]",
        TextColor3 = Library.Theme.TextDark,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        Parent = Container
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = KeyBtn})

    local KB = {Value = default and Enum.KeyCode[default] or nil, Type = "Keybind"}
    Library.Options[id] = KB

    local binding = false
    KeyBtn.MouseButton1Click:Connect(function()
        binding = true
        KeyBtn.Text = "[...]"
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if binding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                binding = false
                if input.KeyCode == Enum.KeyCode.Escape then
                    KB.Value = nil
                    KeyBtn.Text = "[...]"
                else
                    KB.Value = input.KeyCode
                    KeyBtn.Text = "[" .. input.KeyCode.Name .. "]"
                end
                if config.ChangedCallback then task.spawn(config.ChangedCallback, KB.Value) end
            end
        elseif not processed and KB.Value and input.KeyCode == KB.Value then
            if config.Callback then task.spawn(config.Callback) end
        end
    end)

    function KB:SetValue(key)
        KB.Value = key
        KeyBtn.Text = key and ("[" .. key.Name .. "]") or "[...]"
    end

    return KB
end

local function CreateButton(parent, config)
    config = config or {}
    local Btn = Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 22),
        Position = UDim2.new(0, 2, 0, 0),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = config.Text or "Button",
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false,
        Parent = parent
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Btn})
    Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Btn})

    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.DropdownBorder}, 0.1) end)
    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Library.Theme.Dropdown}, 0.1) end)
    Btn.MouseButton1Click:Connect(function()
        if config.Callback then task.spawn(config.Callback) end
    end)

    return Btn
end

local function CreateDivider(parent)
    return Create("Frame", {
        Size = UDim2.new(1, -8, 0, 1),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = Library.Theme.Separator,
        BorderSizePixel = 0,
        Parent = parent
    })
end

--// WINDOW CREATION \\--

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Serdiums"
    local size = config.Size or UDim2.new(0, 520, 0, 380)
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local ScreenGui = Create("ScreenGui", {
        Name = "Serdiums",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    self.ScreenGui = ScreenGui

    local Main = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})

    -- Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 42, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})
    Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    local TabBtns = Create("Frame", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = TabBtns
    })

    local Content = Create("Frame", {
        Size = UDim2.new(1, -47, 1, -10),
        Position = UDim2.new(0, 47, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    -- Dragging
    local drag, dStart, sPos = false, nil, nil
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dStart = i.Position
            sPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            Main.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputBegan:Connect(function(i, p)
        if not p and i.KeyCode == self.ToggleKey then
            self.Open = not self.Open
            Main.Visible = self.Open
        end
    end)

    local Window = {Main = Main, TabBtns = TabBtns, Content = Content, Tabs = {}, ActiveTab = nil}

    function Window:AddTab(name, icon)
        icon = icon or "◈"
        local idx = #self.Tabs + 1

        local TabBtn = Create("TextButton", {
            Size = UDim2.new(0, 32, 0, 32),
            BackgroundColor3 = Library.Theme.TabButton,
            BorderSizePixel = 0,
            Text = icon,
            TextColor3 = Library.Theme.TextDark,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            LayoutOrder = idx,
            Parent = self.TabBtns
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        local TabFrame = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.Content
        })

        local Left = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -5, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabFrame
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = Left})

        local Right = Create("ScrollingFrame", {
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabFrame
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = Right})

        local Tab = {Name = name, Button = TabBtn, Frame = TabFrame, Left = Left, Right = Right, Sections = {}, SectionCount = 0}

        function Tab:AddSection(sName, side)
            side = side or (self.SectionCount % 2 == 0 and "Left" or "Right")
            local col = side == "Left" and self.Left or self.Right
            self.SectionCount = self.SectionCount + 1

            local Sec = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Library.Theme.Section,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = self.SectionCount,
                Parent = col
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Sec})

            local Hdr = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = Library.Theme.SectionHeader,
                BorderSizePixel = 0,
                Parent = Sec
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Hdr})
            Create("Frame", {
                Size = UDim2.new(1, 0, 0, 8),
                Position = UDim2.new(0, 0, 1, -8),
                BackgroundColor3 = Library.Theme.SectionHeader,
                BorderSizePixel = 0,
                Parent = Hdr
            })
            Create("TextLabel", {
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sName,
                TextColor3 = Library.Theme.TextBright,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Hdr
            })

            local Cnt = Create("Frame", {
                Size = UDim2.new(1, -8, 0, 0),
                Position = UDim2.new(0, 4, 0, 24),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Sec
            })
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = Cnt})
            Create("UIPadding", {PaddingBottom = UDim.new(0, 8), Parent = Cnt})

            local S = {Section = Sec, Content = Cnt}
            function S:AddToggle(id, cfg) return CreateToggle(Cnt, id, cfg) end
            function S:AddSlider(id, cfg) return CreateSlider(Cnt, id, cfg) end
            function S:AddDropdown(id, cfg) return CreateDropdown(Cnt, id, cfg) end
            function S:AddColorPicker(id, cfg) return CreateColorPicker(Cnt, id, cfg) end
            function S:AddKeybind(id, cfg) return CreateKeybind(Cnt, id, cfg) end
            function S:AddButton(cfg) return CreateButton(Cnt, cfg) end
            function S:AddDivider() return CreateDivider(Cnt) end

            table.insert(self.Sections, S)
            return S
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Frame.Visible = false
                t.Button.BackgroundColor3 = Library.Theme.TabButton
                t.Button.TextColor3 = Library.Theme.TextDark
            end
            Tab.Frame.Visible = true
            Tab.Button.BackgroundColor3 = Library.Theme.TabButtonActive
            Tab.Button.TextColor3 = Library.Theme.Accent
            self.ActiveTab = Tab
        end)

        TabBtn.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then Tween(TabBtn, {BackgroundColor3 = Library.Theme.TabButtonActive}, 0.1) end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then Tween(TabBtn, {BackgroundColor3 = Library.Theme.TabButton}, 0.1) end
        end)

        table.insert(self.Tabs, Tab)
        if #self.Tabs == 1 then
            Tab.Frame.Visible = true
            Tab.Button.BackgroundColor3 = Library.Theme.TabButtonActive
            Tab.Button.TextColor3 = Library.Theme.Accent
            self.ActiveTab = Tab
        end

        return Tab
    end

    return Window
end

function Library:Notify(config)
    config = config or {}
    print("[Serdiums]", config.Content or config.Title or "Notification")
end

function Library:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return Library
