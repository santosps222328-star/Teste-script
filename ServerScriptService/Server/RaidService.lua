-- Framework de raids. A lógica real depende das funções da GameAPI do seu jogo.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)

local RaidService = {}
RaidService.__index = RaidService

function RaidService.new(player)
    return setmetatable({ player = player, lastStart = 0, message = "Aguardando GameAPI" }, RaidService)
end

function RaidService:step(cfg)
    if not cfg.autoRaid or os.clock() - self.lastStart < 3 then return end
    local raids = GameAPI.listRaids(self.player)
    if type(raids) ~= "table" then self.message = "GameAPI.listRaids inválida"; return end
    for _, raid in ipairs(raids) do
        if type(raid) == "table" and type(raid.id) == "string" then
            if GameAPI.startRaid(self.player, raid.id) then
                self.lastStart = os.clock()
                self.message = "Raid iniciada: " .. tostring(raid.name or raid.id)
                return
            end
        end
    end
    self.message = "Nenhuma raid elegível ou GameAPI ainda não implementada"
end

return RaidService
