-- Framework de chefes PvE. A seleção real depende de GameAPI.listBosses.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)

local BossService = {}
BossService.__index = BossService

function BossService.new(player)
    return setmetatable({ player = player, lastCheck = 0, currentBoss = nil }, BossService)
end

function BossService:step(cfg)
    if not cfg.autoBoss or os.clock() - self.lastCheck < 2 then return end
    self.lastCheck = os.clock()
    local bosses = GameAPI.listBosses(self.player)
    if type(bosses) ~= "table" then self.currentBoss = nil; return end
    local allow = {}
    for _, id in ipairs(cfg.bossList or {}) do if type(id) == "string" then allow[id] = true end end
    for _, boss in ipairs(bosses) do
        if type(boss) == "table" and type(boss.id) == "string" and (next(allow) == nil or allow[boss.id]) then
            self.currentBoss = boss.id
            return
        end
    end
    self.currentBoss = nil
end

return BossService
