-- Framework de maestria: exibe os dados do jogo e solicita equipamento válido.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)

local MasteryService = {}
MasteryService.__index = MasteryService
local VALID = { Sword = true, Melee = true, Fruit = true, Gun = true }

function MasteryService.new(player)
    return setmetatable({ player = player, lastEquip = 0 }, MasteryService)
end

function MasteryService:step(cfg)
    if os.clock() - self.lastEquip < 2 then return end
    local category = cfg.masteryTarget
    if not VALID[category] then return end
    self.lastEquip = os.clock()
    GameAPI.equipCategory(self.player, category)
end

return MasteryService
