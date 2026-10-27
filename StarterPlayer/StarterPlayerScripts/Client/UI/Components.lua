local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Shared.Config)
local C, T = {}, Config.Theme

local function corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = instance
end

function C.button(parent, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Size = options.size or UDim2.fromOffset(120, 32)
    button.Position = options.position or UDim2.fromOffset(0, 0)
    button.BackgroundColor3 = options.color or T.PanelAlt
    button.Text = options.text or "Botão"
    button.TextColor3 = T.Text
    button.Font = T.Font
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = parent
    corner(button, 6)
    return button
end

function C.toggle(parent, label, initial, callback)
    local button = C.button(parent, {
        text = label .. (initial and "  [ON]" or "  [OFF]"),
        size = UDim2.new(1, 0, 0, 34),
        color = initial and T.AccentDim or T.PanelAlt,
    })
    local state = initial == true
    local function set(value, silent)
        state = value == true
        button.Text = label .. (state and "  [ON]" or "  [OFF]")
        button.BackgroundColor3 = state and T.AccentDim or T.PanelAlt
        if not silent and callback then callback(state) end
    end
    button.Activated:Connect(function() set(not state) end)
    return button, set, function() return state end
end

function C.section(parent, label)
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 26)
    text.BackgroundTransparency = 1
    text.Text = string.upper(label)
    text.TextColor3 = T.Accent
    text.Font = T.FontBold
    text.TextSize = 12
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = parent
    return text
end

return C
