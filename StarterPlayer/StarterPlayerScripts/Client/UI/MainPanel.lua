local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Components = require(script.Parent.Components)

local MainPanel = {}
MainPanel.__index = MainPanel
local T = Config.Theme

local ITEMS = {
    { section = "Progressão", id = "autoFarm", label = "Auto Farm Level", kind = "toggle" },
    { section = "Combate PvE", id = "autoCombat", label = "Combate contra NPCs", kind = "toggle" },
    { section = "Coleta", id = "autoCollect", label = "Coletar itens permitidos", kind = "toggle" },
    { section = "Raids", id = "autoRaid", label = "Gerenciar raids", kind = "toggle" },
    { section = "Chefes", id = "autoBoss", label = "Monitorar chefes", kind = "toggle" },
    { section = "Navegação", id = "autoNavigate", label = "Navegação automática", kind = "toggle" },
}

function MainPanel.new(initialState, onPatch, onCommand)
    local self = setmetatable({}, MainPanel)
    self.state = initialState or Config.sanitize(Config.Defaults)
    self.onPatch, self.onCommand = onPatch, onCommand
    self.widgets = {}

    local gui = Instance.new("ScreenGui")
    gui.Name = "AutomationUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.gui = gui

    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.new(0, 360, 0, 390)
    win.Position = UDim2.new(0.03, 0, 0.2, 0)
    win.BackgroundColor3 = T.Bg
    win.BorderSizePixel = 0
    win.Parent = gui
    self.win = win
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 9); corner.Parent = win

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 36)
    title.Position = UDim2.fromOffset(10, 0)
    title.BackgroundTransparency = 1
    title.Text = "AUTOMAÇÃO PvE"
    title.TextColor3 = T.Text
    title.Font = T.FontBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = win

    local stop = Components.button(win, { text = "STOP", size = UDim2.fromOffset(54, 25), position = UDim2.new(1, -62, 0, 5), color = T.Danger })
    stop.Activated:Connect(function()
        if self.onCommand then self.onCommand("stopAll") end
    end)

    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -16, 0, 30)
    search.Position = UDim2.fromOffset(8, 40)
    search.BackgroundColor3 = T.PanelAlt
    search.TextColor3 = T.Text
    search.PlaceholderColor3 = T.SubText
    search.PlaceholderText = "Buscar função..."
    search.Text = ""
    search.ClearTextOnFocus = false
    search.Font = T.Font
    search.TextSize = 13
    search.Parent = win
    self.search = search
    local sc = Instance.new("UICorner"); sc.CornerRadius = UDim.new(0, 5); sc.Parent = search

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -16, 1, -82)
    content.Position = UDim2.fromOffset(8, 76)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 5
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = win
    self.content = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local lastSection
    for _, item in ipairs(ITEMS) do
        if item.section ~= lastSection then
            Components.section(content, item.section)
            lastSection = item.section
        end
        local value = self.state[item.id] == true
        local button, setState = Components.toggle(content, item.label, value, function(newValue)
            self.state[item.id] = newValue
            if self.onPatch then self.onPatch({ [item.id] = newValue }) end
        end)
        self.widgets[item.id] = setState
        button:SetAttribute("SearchLabel", item.label:lower())
    end

    search:GetPropertyChangedSignal("Text"):Connect(function()
        local query = search.Text:lower()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("TextButton") then
                local label = child:GetAttribute("SearchLabel") or child.Text:lower()
                child.Visible = query == "" or label:find(query, 1, true) ~= nil
            elseif child:IsA("TextLabel") then
                child.Visible = query == "" or child.Text:lower():find(query, 1, true) ~= nil
            end
        end
    end)

    -- Arrastar a janela com mouse ou toque.
    local dragging, dragStart, startPosition
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPosition = true, input.Position, win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return self
end

function MainPanel:updateState(state)
    self.state = state
    for id, setter in pairs(self.widgets) do
        if type(state[id]) == "boolean" then setter(state[id], true) end
    end
end

return MainPanel
