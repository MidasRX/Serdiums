--[[
    Serdiums UI Library - Elements Module
    Toggle, Slider, Dropdown, etc.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Elements = {}

-- Create Toggle (Gamesense style: ☐ checkbox inline with text)
function Elements.CreateToggle(Library, parent, id, config)
    config = config or {}
    local default = config.Default or false
    local hasDropdown = config.Dropdown ~= nil

    local height = hasDropdown and 38 or 20

    local Container = Library.Create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Parent = parent
    })

    -- Checkbox (☐ style - small square)
    local Checkbox = Library.Create("TextButton", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 2, 0, 4),
        BackgroundColor3 = Library.Theme.Checkbox,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Checkbox})
    Library.Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Checkbox})

    -- Checkmark (inner filled square when checked)
    local Check = Library.Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0.5, -3, 0.5, -3),
        BackgroundColor3 = config.Risky and Library.Theme.Risky or Library.Theme.CheckboxCheck,
        Visible = default,
        Parent = Checkbox
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 1), Parent = Check})

    -- Label
    local Label = Library.Create("TextButton", {
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
        if config.Callback then
            task.spawn(config.Callback, val)
        end
    end

    local function OnClick()
        SetValue(not Toggle.Value)
    end

    Checkbox.MouseButton1Click:Connect(OnClick)
    Label.MouseButton1Click:Connect(OnClick)

    function Toggle:SetValue(val)
        SetValue(val)
    end

    -- Inline Dropdown (like gamesense - dropdown appears below toggle on same row area)
    if hasDropdown then
        local dropConfig = config.Dropdown
        local dropValues = dropConfig.Values or {}
        local dropDefault = dropConfig.Default or dropValues[1]

        local DropBtn = Library.Create("TextButton", {
            Size = UDim2.new(1, -4, 0, 16),
            Position = UDim2.new(0, 2, 0, 20),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = Container
        })
        Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
        Library.Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = DropBtn})

        local DropText = Library.Create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(dropDefault),
            TextColor3 = Library.Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = DropBtn
        })

        local Arrow = Library.Create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -16, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = Library.Theme.TextDark,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Parent = DropBtn
        })

        local Dropdown = {Value = dropDefault, Values = dropValues, Type = "Dropdown"}
        if dropConfig.Flag then
            Library.Options[dropConfig.Flag] = Dropdown
        end

        local isOpen = false
        local OptionsList

        local function CloseDropdown()
            if OptionsList then
                OptionsList:Destroy()
                OptionsList = nil
            end
            isOpen = false
            Arrow.Text = "▾"
        end

        local function OpenDropdown()
            if isOpen then
                CloseDropdown()
                return
            end

            isOpen = true
            Arrow.Text = "▴"

            OptionsList = Library.Create("Frame", {
                Size = UDim2.new(1, 0, 0, #dropValues * 18),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = Library.Theme.Dropdown,
                ZIndex = 100,
                Parent = DropBtn
            })
            Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptionsList})
            Library.Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = OptionsList})
            Library.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList})

            for _, val in ipairs(dropValues) do
                local Opt = Library.Create("TextButton", {
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
                    CloseDropdown()
                    if dropConfig.Callback then
                        task.spawn(dropConfig.Callback, val)
                    end
                end)
            end
        end

        DropBtn.MouseButton1Click:Connect(OpenDropdown)

        function Dropdown:SetValue(val)
            Dropdown.Value = val
            DropText.Text = val
            if dropConfig.Callback then
                task.spawn(dropConfig.Callback, val)
            end
        end

        Toggle.Dropdown = Dropdown
    end

    return Toggle
end

-- Create Slider (Gamesense style: label on left, value+bar)
function Elements.CreateSlider(Library, parent, id, config)
    config = config or {}
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or min, min, max)
    local rounding = config.Rounding or 0
    local suffix = config.Suffix or ""

    local Container = Library.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent
    })

    -- Label
    local Label = Library.Create("TextLabel", {
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

    -- Value display (right side, shows percentage or value)
    local ValueLabel = Library.Create("TextLabel", {
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

    -- Slider bar background
    local SliderBg = Library.Create("Frame", {
        Size = UDim2.new(1, -4, 0, 6),
        Position = UDim2.new(0, 2, 0, 20),
        BackgroundColor3 = Library.Theme.SliderBg,
        BorderSizePixel = 0,
        Parent = Container
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = SliderBg})

    -- Slider fill
    local Fill = Library.Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = SliderBg
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Fill})

    local Slider = {Value = default, Type = "Slider", Min = min, Max = max}
    Library.Options[id] = Slider

    local function FormatValue(val)
        if rounding == 0 then
            return tostring(math.floor(val))
        else
            return string.format("%." .. rounding .. "f", val)
        end
    end

    local function SetValue(val)
        val = math.clamp(val, min, max)
        if rounding == 0 then
            val = math.floor(val)
        else
            val = math.floor(val * 10^rounding + 0.5) / 10^rounding
        end
        Slider.Value = val

        local percent = (val - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        ValueLabel.Text = FormatValue(val) .. suffix

        if config.Callback then
            task.spawn(config.Callback, val)
        end
    end

    SetValue(default)

    -- Dragging
    local dragging = false

    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local percent = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SetValue(min + (max - min) * percent)
        end
    end)

    SliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local percent = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SetValue(min + (max - min) * percent)
        end
    end)

    function Slider:SetValue(val)
        SetValue(val)
    end

    return Slider
end

-- Create Dropdown (Standalone - Gamesense style)
function Elements.CreateDropdown(Library, parent, id, config)
    config = config or {}
    local values = config.Values or {}
    local default = config.Default or values[1]
    local multi = config.Multi or false

    local Container = Library.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = parent
    })

    -- Label
    local Label = Library.Create("TextLabel", {
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

    -- Dropdown button
    local DropBtn = Library.Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 18),
        Position = UDim2.new(0, 2, 0, 18),
        BackgroundColor3 = Library.Theme.Dropdown,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = Container
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
    Library.Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = DropBtn})

    local DropText = Library.Create("TextLabel", {
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

    local Arrow = Library.Create("TextLabel", {
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

    if multi and default then
        Dropdown.Value = default
    end

    local isOpen = false
    local OptionsList

    local function UpdateText()
        if multi then
            local selected = {}
            for v, s in pairs(Dropdown.Value) do
                if s then table.insert(selected, v) end
            end
            DropText.Text = #selected > 0 and table.concat(selected, ", ") or "None"
        else
            DropText.Text = tostring(Dropdown.Value)
        end
    end

    local function CloseDropdown()
        if OptionsList then
            OptionsList:Destroy()
            OptionsList = nil
        end
        isOpen = false
        Arrow.Text = "▾"
    end

    local function OpenDropdown()
        if isOpen then
            CloseDropdown()
            return
        end

        isOpen = true
        Arrow.Text = "▴"

        local listHeight = math.min(#values * 18, 150)
        OptionsList = Library.Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, listHeight),
            Position = UDim2.new(0, 0, 1, 2),
            BackgroundColor3 = Library.Theme.Dropdown,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, #values * 18),
            ZIndex = 100,
            Parent = DropBtn
        })
        Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptionsList})
        Library.Create("UIStroke", {Color = Library.Theme.DropdownBorder, Thickness = 1, Parent = OptionsList})
        Library.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = OptionsList})

        for _, val in ipairs(values) do
            local isSelected = multi and Dropdown.Value[val] or (Dropdown.Value == val)

            local Opt = Library.Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = "  " .. val,
                TextColor3 = isSelected and Library.Theme.Accent or Library.Theme.Text,
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
                    if config.Callback then
                        task.spawn(config.Callback, Dropdown.Value)
                    end
                else
                    Dropdown.Value = val
                    UpdateText()
                    CloseDropdown()
                    if config.Callback then
                        task.spawn(config.Callback, val)
                    end
                end
            end)
        end
    end

    DropBtn.MouseButton1Click:Connect(OpenDropdown)

    function Dropdown:SetValue(val)
        if multi then
            Dropdown.Value = val
        else
            Dropdown.Value = val
        end
        UpdateText()
        if config.Callback then
            task.spawn(config.Callback, val)
        end
    end

    function Dropdown:SetValues(newValues)
        values = newValues
        Dropdown.Values = newValues
    end

    UpdateText()
    return Dropdown
end

-- Create ColorPicker
function Elements.CreateColorPicker(Library, parent, id, config)
    config = config or {}
    local default = config.Default or Color3.new(1, 1, 1)

    local Container = Library.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Library.Create("TextLabel", {
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

    local ColorBtn = Library.Create("TextButton", {
        Size = UDim2.new(0, 24, 0, 14),
        Position = UDim2.new(1, -26, 0.5, -7),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Text = "",
        Parent = Container
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ColorBtn})
    Library.Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = ColorBtn})

    local ColorPicker = {Value = default, Type = "ColorPicker"}
    Library.Options[id] = ColorPicker

    -- Simple color grid popup
    local Popup
    local isOpen = false

    local presetColors = {
        Color3.new(1, 1, 1),
        Color3.new(1, 0, 0),
        Color3.new(0, 1, 0),
        Color3.new(0, 0, 1),
        Color3.new(1, 1, 0),
        Color3.new(1, 0, 1),
        Color3.new(0, 1, 1),
        Color3.new(1, 0.5, 0),
        Color3.fromRGB(160, 190, 60),
        Color3.new(0.5, 0, 1),
        Color3.new(0, 0.5, 1),
        Color3.new(0, 0, 0)
    }

    ColorBtn.MouseButton1Click:Connect(function()
        if isOpen and Popup then
            Popup:Destroy()
            Popup = nil
            isOpen = false
            return
        end

        isOpen = true
        Popup = Library.Create("Frame", {
            Size = UDim2.new(0, 130, 0, 85),
            Position = UDim2.new(1, 5, 0, 0),
            BackgroundColor3 = Library.Theme.Section,
            ZIndex = 100,
            Parent = Container
        })
        Library.Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Popup})
        Library.Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Popup})

        for i, col in ipairs(presetColors) do
            local x = ((i-1) % 4) * 30 + 5
            local y = math.floor((i-1) / 4) * 24 + 5
            local ColBtn = Library.Create("TextButton", {
                Size = UDim2.new(0, 26, 0, 20),
                Position = UDim2.new(0, x, 0, y),
                BackgroundColor3 = col,
                BorderSizePixel = 0,
                Text = "",
                ZIndex = 101,
                Parent = Popup
            })
            Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ColBtn})

            ColBtn.MouseButton1Click:Connect(function()
                ColorPicker.Value = col
                ColorBtn.BackgroundColor3 = col
                Popup:Destroy()
                Popup = nil
                isOpen = false
                if config.Callback then
                    task.spawn(config.Callback, col)
                end
            end)
        end
    end)

    function ColorPicker:SetValue(col)
        ColorPicker.Value = col
        ColorBtn.BackgroundColor3 = col
    end

    return ColorPicker
end

-- Create Keybind
function Elements.CreateKeybind(Library, parent, id, config)
    config = config or {}
    local default = config.Default

    local Container = Library.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local Label = Library.Create("TextLabel", {
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

    local KeyBtn = Library.Create("TextButton", {
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
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = KeyBtn})

    local Keybind = {Value = default and Enum.KeyCode[default] or nil, Type = "Keybind"}
    Library.Options[id] = Keybind

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
                    Keybind.Value = nil
                    KeyBtn.Text = "[...]"
                else
                    Keybind.Value = input.KeyCode
                    KeyBtn.Text = "[" .. input.KeyCode.Name .. "]"
                end
                if config.ChangedCallback then
                    task.spawn(config.ChangedCallback, Keybind.Value)
                end
            end
        elseif not processed and Keybind.Value and input.KeyCode == Keybind.Value then
            if config.Callback then
                task.spawn(config.Callback)
            end
        end
    end)

    function Keybind:SetValue(key)
        Keybind.Value = key
        KeyBtn.Text = key and ("[" .. key.Name .. "]") or "[...]"
    end

    return Keybind
end

-- Create Button
function Elements.CreateButton(Library, parent, config)
    config = config or {}

    local Btn = Library.Create("TextButton", {
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
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Btn})
    Library.Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Btn})

    Btn.MouseEnter:Connect(function()
        Library.Tween(Btn, {BackgroundColor3 = Library.Theme.DropdownBorder}, 0.1)
    end)
    Btn.MouseLeave:Connect(function()
        Library.Tween(Btn, {BackgroundColor3 = Library.Theme.Dropdown}, 0.1)
    end)

    Btn.MouseButton1Click:Connect(function()
        if config.Callback then
            task.spawn(config.Callback)
        end
    end)

    return Btn
end

-- Create Divider/Separator
function Elements.CreateDivider(Library, parent)
    local Div = Library.Create("Frame", {
        Size = UDim2.new(1, -8, 0, 1),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundColor3 = Library.Theme.Separator,
        BorderSizePixel = 0,
        Parent = parent
    })
    return Div
end

return Elements
