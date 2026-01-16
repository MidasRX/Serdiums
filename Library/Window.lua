--[[
    Serdiums UI Library - Window Module
    Creates main window, sidebar, tabs like Gamesense exactly
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Window = {}

function Window.CreateWindow(Library, Elements, config)
    config = config or {}
    local title = config.Title or "Serdiums"
    local size = config.Size or UDim2.new(0, 520, 0, 380)
    Library.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    -- Main ScreenGui
    local ScreenGui = Library.Create("ScreenGui", {
        Name = "Serdiums",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    Library.ScreenGui = ScreenGui

    -- Main Frame (dark background like gamesense)
    local Main = Library.Create("Frame", {
        Name = "Main",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})

    -- Left Sidebar (narrow with icons)
    local Sidebar = Library.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 42, 1, 0),
        BackgroundColor3 = Library.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Main
    })
    Library.Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})

    -- Cover right side of sidebar corner
    local SidebarCover = Library.Create("Frame", {
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = Library.Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Sidebar
    })

    -- Tab buttons container
    local TabButtonsContainer = Library.Create("Frame", {
        Name = "TabButtons",
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })
    Library.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 4),
        Parent = TabButtonsContainer
    })

    -- Content area (right side)
    local ContentArea = Library.Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -47, 1, -10),
        Position = UDim2.new(0, 47, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil

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
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Toggle UI visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Library.ToggleKey then
            Library.Open = not Library.Open
            Main.Visible = Library.Open
        end
    end)

    local WindowObj = {
        Main = Main,
        Sidebar = Sidebar,
        TabButtonsContainer = TabButtonsContainer,
        ContentArea = ContentArea,
        Tabs = {},
        ActiveTab = nil
    }

    -- AddTab function
    function WindowObj:AddTab(name, icon)
        icon = icon or "◈"
        local tabIndex = #self.Tabs + 1

        -- Tab button (icon in sidebar)
        local TabBtn = Library.Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 32, 0, 32),
            BackgroundColor3 = Library.Theme.TabButton,
            BorderSizePixel = 0,
            Text = icon,
            TextColor3 = Library.Theme.TextDark,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            LayoutOrder = tabIndex,
            Parent = self.TabButtonsContainer
        })
        Library.Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})

        -- Tab content frame (2 columns like gamesense)
        local TabFrame = Library.Create("Frame", {
            Name = name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = self.ContentArea
        })

        -- Left column
        local LeftColumn = Library.Create("ScrollingFrame", {
            Name = "Left",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabFrame
        })
        Library.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = LeftColumn
        })

        -- Right column
        local RightColumn = Library.Create("ScrollingFrame", {
            Name = "Right",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = TabFrame
        })
        Library.Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = RightColumn
        })

        local Tab = {
            Name = name,
            Button = TabBtn,
            Frame = TabFrame,
            LeftColumn = LeftColumn,
            RightColumn = RightColumn,
            Sections = {},
            SectionCount = 0
        }

        -- Add Section function
        function Tab:AddSection(sectionName, side)
            side = side or (self.SectionCount % 2 == 0 and "Left" or "Right")
            local column = side == "Left" and self.LeftColumn or self.RightColumn
            self.SectionCount = self.SectionCount + 1

            local Section = Library.Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Library.Theme.Section,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = self.SectionCount,
                Parent = column
            })
            Library.Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Section})

            -- Section header (darker bar with title)
            local Header = Library.Create("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = Library.Theme.SectionHeader,
                BorderSizePixel = 0,
                Parent = Section
            })
            Library.Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = Header})

            -- Cover bottom corners of header
            local HeaderCover = Library.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 8),
                Position = UDim2.new(0, 0, 1, -8),
                BackgroundColor3 = Library.Theme.SectionHeader,
                BorderSizePixel = 0,
                Parent = Header
            })

            local HeaderTitle = Library.Create("TextLabel", {
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Library.Theme.TextBright,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header
            })

            -- Content container
            local Content = Library.Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -8, 0, 0),
                Position = UDim2.new(0, 4, 0, 24),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = Section
            })
            Library.Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 3),
                Parent = Content
            })
            Library.Create("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                Parent = Content
            })

            local SectionObj = {
                Section = Section,
                Content = Content
            }

            -- Element adding methods
            function SectionObj:AddToggle(id, cfg)
                return Elements.CreateToggle(Library, Content, id, cfg)
            end

            function SectionObj:AddSlider(id, cfg)
                return Elements.CreateSlider(Library, Content, id, cfg)
            end

            function SectionObj:AddDropdown(id, cfg)
                return Elements.CreateDropdown(Library, Content, id, cfg)
            end

            function SectionObj:AddColorPicker(id, cfg)
                return Elements.CreateColorPicker(Library, Content, id, cfg)
            end

            function SectionObj:AddKeybind(id, cfg)
                return Elements.CreateKeybind(Library, Content, id, cfg)
            end

            function SectionObj:AddButton(cfg)
                return Elements.CreateButton(Library, Content, cfg)
            end

            function SectionObj:AddDivider()
                return Elements.CreateDivider(Library, Content)
            end

            table.insert(self.Sections, SectionObj)
            return SectionObj
        end

        -- Tab switching logic
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

        -- Hover effects
        TabBtn.MouseEnter:Connect(function()
            if self.ActiveTab ~= Tab then
                Library.Tween(TabBtn, {BackgroundColor3 = Library.Theme.TabButtonActive}, 0.1)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if self.ActiveTab ~= Tab then
                Library.Tween(TabBtn, {BackgroundColor3 = Library.Theme.TabButton}, 0.1)
            end
        end)

        table.insert(self.Tabs, Tab)

        -- Auto-select first tab
        if #self.Tabs == 1 then
            Tab.Frame.Visible = true
            Tab.Button.BackgroundColor3 = Library.Theme.TabButtonActive
            Tab.Button.TextColor3 = Library.Theme.Accent
            self.ActiveTab = Tab
        end

        return Tab
    end

    return WindowObj
end

return Window
