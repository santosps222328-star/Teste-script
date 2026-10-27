local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)
local NavigationService = require(script.Parent.NavigationService)

local InventoryService = {}
InventoryService.__index = InventoryService

function InventoryService.new(player)
    return setmetatable({ player = player, lastCollect = 0, snapshot = {} }, InventoryService)
end

function InventoryService:snapshotInventory()
    self.snapshot = GameAPI.getInventory(self.player)
    return self.snapshot
end

function InventoryService:step(cfg)
    if not cfg.autoCollect or os.clock() - self.lastCollect < 0.75 then return end
    self.lastCollect = os.clock()
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local allowed = {}
    for _, id in ipairs(cfg.collectList or {}) do
        if type(id) == "string" then allowed[id] = true end
    end

    local closest, closestDistance
    for _, item in ipairs(GameAPI.listCollectibles(self.player)) do
        if type(item) == "table" and allowed[item.id] and typeof(item.position) == "Vector3" then
            local distance = (root.Position - item.position).Magnitude
            if not closestDistance or distance < closestDistance then
                closest, closestDistance = item, distance
            end
        end
    end
    if not closest then return end
    if closestDistance > 12 then
        NavigationService.moveTo(self.player, closest.position)
    else
        GameAPI.tryCollect(self.player, closest.id)
    end
end

return InventoryService
