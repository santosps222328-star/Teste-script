local Config = {}

Config.Version = "1.0.0"
Config.Theme = {
    Bg = Color3.fromRGB(18, 18, 20),
    Panel = Color3.fromRGB(28, 28, 32),
    PanelAlt = Color3.fromRGB(38, 38, 44),
    Accent = Color3.fromRGB(210, 35, 35),
    AccentDim = Color3.fromRGB(120, 25, 25),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(165, 165, 170),
    Success = Color3.fromRGB(70, 200, 90),
    Warn = Color3.fromRGB(240, 180, 60),
    Danger = Color3.fromRGB(220, 70, 70),
    Border = Color3.fromRGB(58, 58, 65),
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

Config.Defaults = {
    autoFarm = false,
    autoFarmPriority = "Level",
    autoFarmMaxDist = 250,
    autoCollect = false,
    collectList = {},
    autoCombat = false,
    combatPriority = "Distance",
    combatMaxDist = 60,
    minHealthToFight = 0.40,
    autoNavigate = false,
    navigationDest = nil,
    autoRaid = false,
    raidPriority = {},
    autoBoss = false,
    bossList = {},
    masteryTarget = "Sword",
    limits = { maxSessionMinutes = 60, maxDeaths = 3 },
    ui = { x = 0.02, y = 0.20, w = 520, h = 380, minimized = false },
}

local function clone(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for k, v in pairs(value) do out[k] = clone(v) end
    return out
end

function Config.sanitize(cfg)
    local out = clone(Config.Defaults)
    if type(cfg) ~= "table" then return out end

    for k, v in pairs(cfg) do
        if Config.Defaults[k] ~= nil and type(v) == type(Config.Defaults[k]) then
            out[k] = v
        end
    end

    if type(out.limits) ~= "table" then out.limits = clone(Config.Defaults.limits) end
    out.limits.maxSessionMinutes = math.clamp(tonumber(out.limits.maxSessionMinutes) or 60, 1, 240)
    out.limits.maxDeaths = math.clamp(tonumber(out.limits.maxDeaths) or 3, 0, 99)
    out.autoFarmMaxDist = math.clamp(tonumber(out.autoFarmMaxDist) or 250, 50, 1000)
    out.combatMaxDist = math.clamp(tonumber(out.combatMaxDist) or 60, 10, 200)
    out.minHealthToFight = math.clamp(tonumber(out.minHealthToFight) or 0.4, 0, 0.95)

    if type(out.collectList) ~= "table" then out.collectList = {} end
    if type(out.raidPriority) ~= "table" then out.raidPriority = {} end
    if type(out.bossList) ~= "table" then out.bossList = {} end
    if type(out.ui) ~= "table" then out.ui = clone(Config.Defaults.ui) end
    return out
end

return Config
