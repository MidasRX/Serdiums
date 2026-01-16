--[[
    Serdiums UI Library
    Gamesense Style UI
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Library = {
    Theme = {
        Background = Color3.fromRGB(17, 17, 17),
        Sidebar = Color3.fromRGB(22, 22, 22),
        Section = Color3.fromRGB(25, 25, 25),
        SectionHeader = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(200, 200, 200),
        TextDark = Color3.fromRGB(120, 120, 120),
        Accent = Color3.fromRGB(150, 180, 50),
        SliderFill = Color3.fromRGB(150, 180, 50),
        Border = Color3.fromRGB(40, 40, 40),
        Dropdown = Color3.fromRGB(35, 35, 35),
        Input = Color3.fromRGB(30, 30, 30),
        Toggle = Color3.fromRGB(150, 180, 50),
        Risky = Color3.fromRGB(255, 50, 50)
    },
    Toggles = {},
    Options = {},
    Registry = {},
    ScreenGui = nil,
    Open = true,
    ToggleKey = Enum.KeyCode.RightControl
}

-- Utility
local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.15), props):Play()
end

local function AddToRegistry(element, props)
    table.insert(Library.Registry, {Element = element, Properties = props})
end

-- Icons (simple text icons)
local Icons = {
    Combat = "⊕",
    Visuals = "◉", 
    Misc = "⚙",
    Settings = "☰",
    Player = "◈",
    World = "◎"
}

function Library:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Serdiums"
    local size = config.Size or UDim2.new(0, 600, 0, 450)
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    -- Main GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "Serdiums",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    
    self.ScreenGui = ScreenGui

    -- Main Frame
    local Main = Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Main})
    Create("UIStroke", {Color = self.Theme.Border, Thickness = 1, Parent = Main})

    -- Left Sidebar (Icons)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 45, 1, 0),
        BackgroundColor3 = self.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Sidebar})

    local TabButtons = Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = TabButtons
    })

    -- Tab Content Area
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -50, 1, -10),
        Position = UDim2.new(0, 50, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    -- Dragging
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == self.ToggleKey then
            self.Open = not self.Open
            Main.Visible = self.Open
        end
    end)

    local Window = {
        Main = Main,
        TabButtons = TabButtons,
        TabContainer = TabContainer,
        Tabs = {},
        ActiveTab = nil
    }

    function Window:AddTab(name, icon)
        icon = icon or "◈"
        local tabIndex = #self.Tabs + 1

        -- Tab Button
        local TabBtn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 35, 0, 35),
            BackgroundColor3 = Library.Theme.Section,
            BorderSizePixel = 0,
            Text = icon,
            TextColor3 = Library.Theme.TextDark,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = self.TabButtons
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = TabBtn})

        -- Tab Content (2 columns)
        local TabFrame = Create("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = self.TabContainer
        })

        local Columns = Create("Frame", {
            Name = "Columns",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = TabFrame
        })

        local LeftColumn = Create("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -5, 1, 0),
            BackgroundTransparency = 1,
            Parent = Columns
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = LeftColumn})

        local RightColumn = Create("Frame", {
            Name = "Right",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            Parent = Columns
        })
        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = RightColumn})

        local Tab = {
            Button = TabBtn,
            Frame = TabFrame,
            LeftColumn = LeftColumn,
            RightColumn = RightColumn,
            Sections = {},
            SectionCount = 0
        }

        function Tab:AddSection(name, side)
            side = side or (self.SectionCount % 2 == 0 and "Left" or "Right")
            local column = side == "Left" and self.LeftColumn or self.RightColumn
            self.SectionCount = self.SectionCount + 1

            local Section = Create("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Library.Theme.Section,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = column
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Section})
            Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Section})

            -- Header
            local Header = Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = Library.Theme.SectionHeader,
                BorderSizePixel = 0,
                Parent = Section
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Header})

            Create("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Library.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header
            })

            local Content = Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 25),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Section
            })
            Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = Content})
            Create("UIPadding", {PaddingBottom = UDim.new(0, 8), Parent = Content})

            local SectionObj = {Content = Content}

            -- TOGGLE (Gamesense style: ☐/☑ inline)
            function SectionObj:AddToggle(id, config)
                config = config or {}
                local default = config.Default or false

                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                local Checkbox = Create("TextButton", {
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(0, 0, 0.5, -7),
                    BackgroundColor3 = Library.Theme.Input,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Checkbox})
                Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Checkbox})

                local Check = Create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0.5, -4, 0.5, -4),
                    BackgroundColor3 = config.Risky and Library.Theme.Risky or Library.Theme.Toggle,
                    Visible = default,
                    Parent = Checkbox
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Check})

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = config.Text or id,
                    TextColor3 = config.Risky and Library.Theme.Risky or Library.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })

                local Toggle = {Value = default, Type = "Toggle"}
                Library.Toggles[id] = Toggle

                local function SetValue(val)
                    Toggle.Value = val
                    Check.Visible = val
                    if config.Callback then config.Callback(val) end
                end

                Checkbox.MouseButton1Click:Connect(function()
                    SetValue(not Toggle.Value)
                end)

                function Toggle:SetValue(val) SetValue(val) end
                
                AddToRegistry(Check, {BackgroundColor3 = config.Risky and "Risky" or "Toggle"})
                return Toggle
            end

            -- SLIDER (Gamesense style: colored fill bar)
            function SectionObj:AddSlider(id, config)
                config = config or {}
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local rounding = config.Rounding or 0
                local suffix = config.Suffix or ""

                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                local Label = Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = config.Text or id,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })

                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 14),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = Container
                })

                local SliderBG = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Library.Theme.Input,
                    BorderSizePixel = 0,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = SliderBG})

                local Fill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.Theme.SliderFill,
                    BorderSizePixel = 0,
                    Parent = SliderBG
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Fill})

                local Slider = {Value = default, Type = "Slider", Min = min, Max = max}
                Library.Options[id] = Slider

                local function SetValue(val)
                    val = math.clamp(val, min, max)
                    if rounding == 0 then val = math.floor(val) else val = math.floor(val * 10^rounding) / 10^rounding end
                    Slider.Value = val
                    Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                    ValueLabel.Text = tostring(val) .. suffix
                    if config.Callback then config.Callback(val) end
                end

                local dragging = false
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                SliderBG.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = (input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X
                        SetValue(min + (max - min) * math.clamp(pos, 0, 1))
                    end
                end)
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local pos = (input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X
                        SetValue(min + (max - min) * math.clamp(pos, 0, 1))
                    end
                end)

                function Slider:SetValue(val) SetValue(val) end
                
                AddToRegistry(Fill, {BackgroundColor3 = "SliderFill"})
                AddToRegistry(ValueLabel, {TextColor3 = "Accent"})
                return Slider
            end

            -- DROPDOWN (Gamesense style: inline compact)
            function SectionObj:AddDropdown(id, config)
                config = config or {}
                local values = config.Values or {}
                local default = config.Default or values[1]
                local multi = config.Multi or false

                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
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
                    Text = "  " .. tostring(default or "Select..."),
                    TextColor3 = Library.Theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DropBtn})
                Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = DropBtn})

                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 18, 1, 0),
                    Position = UDim2.new(1, -18, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 8,
                    Font = Enum.Font.GothamBold,
                    Parent = DropBtn
                })

                local OptionsList = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 36),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 10,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = OptionsList})
                Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0), Parent = OptionsList})

                local Dropdown = {Value = multi and {} or default, Values = values, Type = "Dropdown", Multi = multi}
                Library.Options[id] = Dropdown

                local isOpen = false
                local optionBtns = {}

                local function UpdateText()
                    if multi then
                        local selected = {}
                        for v, s in pairs(Dropdown.Value) do if s then table.insert(selected, v) end end
                        DropBtn.Text = "  " .. (#selected > 0 and table.concat(selected, ", ") or "None")
                    else
                        DropBtn.Text = "  " .. tostring(Dropdown.Value)
                    end
                end

                local function BuildOptions()
                    for _, btn in pairs(optionBtns) do btn:Destroy() end
                    optionBtns = {}

                    for _, val in ipairs(values) do
                        local Opt = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 18),
                            BackgroundColor3 = Library.Theme.Dropdown,
                            BackgroundTransparency = 0.5,
                            BorderSizePixel = 0,
                            Text = "  " .. val,
                            TextColor3 = Library.Theme.Text,
                            TextSize = 11,
                            Font = Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 11,
                            Parent = OptionsList
                        })
                        table.insert(optionBtns, Opt)

                        Opt.MouseButton1Click:Connect(function()
                            if multi then
                                Dropdown.Value[val] = not Dropdown.Value[val]
                                Opt.TextColor3 = Dropdown.Value[val] and Library.Theme.Accent or Library.Theme.Text
                            else
                                Dropdown.Value = val
                                isOpen = false
                                OptionsList.Visible = false
                                Container.Size = UDim2.new(1, 0, 0, 36)
                            end
                            UpdateText()
                            if config.Callback then config.Callback(Dropdown.Value) end
                        end)

                        if multi and Dropdown.Value[val] then
                            Opt.TextColor3 = Library.Theme.Accent
                        end
                    end
                    OptionsList.Size = UDim2.new(1, 0, 0, #values * 18)
                end

                BuildOptions()

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    OptionsList.Visible = isOpen
                    Container.Size = UDim2.new(1, 0, 0, isOpen and (36 + #values * 18) or 36)
                    Arrow.Text = isOpen and "▲" or "▼"
                end)

                function Dropdown:SetValue(val)
                    if multi then
                        Dropdown.Value = val
                    else
                        Dropdown.Value = val
                    end
                    UpdateText()
                    if config.Callback then config.Callback(val) end
                end

                function Dropdown:SetValues(newVals)
                    values = newVals
                    Dropdown.Values = newVals
                    BuildOptions()
                end

                return Dropdown
            end

            -- BUTTON
            function SectionObj:AddButton(config)
                config = config or {}
                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Library.Theme.Input,
                    BorderSizePixel = 0,
                    Text = config.Text or "Button",
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    Parent = Content
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Btn})
                Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = Btn})

                Btn.MouseButton1Click:Connect(function()
                    if config.Callback then config.Callback() end
                end)
                return Btn
            end

            -- INPUT
            function SectionObj:AddInput(id, config)
                config = config or {}
                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = config.Text or id,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })

                local Box = Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 18),
                    Position = UDim2.new(0, 0, 0, 16),
                    BackgroundColor3 = Library.Theme.Input,
                    BorderSizePixel = 0,
                    Text = config.Default or "",
                    PlaceholderText = config.Placeholder or "",
                    TextColor3 = Library.Theme.Text,
                    PlaceholderColor3 = Library.Theme.TextDark,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = Box})
                Create("UIPadding", {PaddingLeft = UDim.new(0, 5), Parent = Box})

                local Input = {Value = config.Default or "", Type = "Input"}
                Library.Options[id] = Input

                Box.FocusLost:Connect(function()
                    Input.Value = Box.Text
                    if config.Callback then config.Callback(Box.Text) end
                end)

                function Input:SetValue(val)
                    Box.Text = val
                    Input.Value = val
                end

                return Input
            end

            -- COLORPICKER
            function SectionObj:AddColorPicker(id, config)
                config = config or {}
                local default = config.Default or Color3.new(1, 1, 1)

                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                Create("TextLabel", {
                    Size = UDim2.new(1, -25, 1, 0),
                    BackgroundTransparency = 1,
                    Text = config.Text or id,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Container
                })

                local ColorBox = Create("TextButton", {
                    Size = UDim2.new(0, 20, 0, 12),
                    Position = UDim2.new(1, -20, 0.5, -6),
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Text = "",
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = ColorBox})
                Create("UIStroke", {Color = Library.Theme.Border, Thickness = 1, Parent = ColorBox})

                local ColorPicker = {Value = default, Type = "ColorPicker"}
                Library.Options[id] = ColorPicker

                -- Simple color picker popup
                local Popup = Create("Frame", {
                    Size = UDim2.new(0, 150, 0, 100),
                    Position = UDim2.new(1, 5, 0, 0),
                    BackgroundColor3 = Library.Theme.Section,
                    Visible = false,
                    ZIndex = 20,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Popup})
                Create("UIStroke", {Color = Library.Theme.Border, Parent = Popup})

                local colors = {
                    Color3.new(1,1,1), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1),
                    Color3.new(1,1,0), Color3.new(1,0,1), Color3.new(0,1,1), Color3.new(1,0.5,0),
                    Color3.fromRGB(150,180,50), Color3.new(0.5,0,1), Color3.new(0,0.5,1), Color3.new(0,0,0)
                }

                for i, col in ipairs(colors) do
                    local x = ((i-1) % 4) * 35 + 10
                    local y = math.floor((i-1) / 4) * 28 + 10
                    local ColBtn = Create("TextButton", {
                        Size = UDim2.new(0, 30, 0, 22),
                        Position = UDim2.new(0, x, 0, y),
                        BackgroundColor3 = col,
                        Text = "",
                        ZIndex = 21,
                        Parent = Popup
                    })
                    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ColBtn})
                    ColBtn.MouseButton1Click:Connect(function()
                        ColorPicker.Value = col
                        ColorBox.BackgroundColor3 = col
                        Popup.Visible = false
                        if config.Callback then config.Callback(col) end
                    end)
                end

                ColorBox.MouseButton1Click:Connect(function()
                    Popup.Visible = not Popup.Visible
                end)

                function ColorPicker:SetValue(col)
                    ColorPicker.Value = col
                    ColorBox.BackgroundColor3 = col
                end

                return ColorPicker
            end

            -- KEYBIND
            function SectionObj:AddKeybind(id, config)
                config = config or {}
                local default = config.Default or "None"

                local Container = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = Content
                })

                Create("TextLabel", {
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
                    Position = UDim2.new(1, -45, 0.5, -7),
                    BackgroundColor3 = Library.Theme.Input,
                    BorderSizePixel = 0,
                    Text = "[" .. default .. "]",
                    TextColor3 = Library.Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = KeyBtn})

                local Keybind = {Value = default ~= "None" and Enum.KeyCode[default] or nil, Type = "Keybind"}
                Library.Options[id] = Keybind

                local binding = false
                KeyBtn.MouseButton1Click:Connect(function()
                    binding = true
                    KeyBtn.Text = "[...]"
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        Keybind.Value = input.KeyCode
                        KeyBtn.Text = "[" .. input.KeyCode.Name .. "]"
                        if config.ChangedCallback then config.ChangedCallback(input.KeyCode) end
                    elseif not processed and Keybind.Value and input.KeyCode == Keybind.Value then
                        if config.Callback then config.Callback() end
                    end
                end)

                function Keybind:SetValue(key)
                    Keybind.Value = key
                    KeyBtn.Text = "[" .. key.Name .. "]"
                end

                return Keybind
            end

            -- DIVIDER
            function SectionObj:AddDivider()
                Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Library.Theme.Border,
                    BorderSizePixel = 0,
                    Parent = Content
                })
            end

            table.insert(self.Sections, SectionObj)
            return SectionObj
        end

        -- Tab switching
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(self.Tabs) do
                t.Frame.Visible = false
                t.Button.TextColor3 = Library.Theme.TextDark
                t.Button.BackgroundColor3 = Library.Theme.Section
            end
            Tab.Frame.Visible = true
            Tab.Button.TextColor3 = Library.Theme.Accent
            Tab.Button.BackgroundColor3 = Library.Theme.SectionHeader
            self.ActiveTab = Tab
        end)

        table.insert(self.Tabs, Tab)

        -- Auto-select first tab
        if #self.Tabs == 1 then
            Tab.Frame.Visible = true
            Tab.Button.TextColor3 = Library.Theme.Accent
            Tab.Button.BackgroundColor3 = Library.Theme.SectionHeader
            self.ActiveTab = Tab
        end

        return Tab
    end

    return Window
end

function Library:Notify(config)
    config = config or {}
    local text = config.Content or config.Title or "Notification"
    print("[Serdiums]", text)
end

function Library:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return Library
