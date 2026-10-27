local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage.Shared.Util)
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)
local NavigationService = require(script.Parent.NavigationService)

local AutoFarmService = {}
AutoFarmService.__index = AutoFarmService

function AutoFarmService.new(player, combat)
    return setmetatable({
        player = player, combat = combat, startedAt = os.time(),
        deaths = 0, wasDead = false, currentTarget = nil,
    }, AutoFarmService)
end

function AutoFarmService:_findTarget(cfg)
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local level = GameAPI.getLevel(self.player)
    local best, bestScore
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:GetAttribute("IsNPC") == true then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and targetRoot then
                local dist = Util.horizontalDist(root.Position, targetRoot.Position)
                if dist <= (cfg.autoFarmMaxDist or 250) then
                    local npcLevel = tonumber(model:GetAttribute("Level")) or 1
                    local score = dist
                    if cfg.autoFarmPriority == "Level" then score = math.abs(npcLevel - level) * 100 + dist end
                    if not bestScore or score < bestScore then
                        best, bestScore = { model = model, root = targetRoot }, score
                    end
                end
            end
        end
    end
    return best
end

function AutoFarmService:step(cfg)
    if not cfg.autoFarm then self.currentTarget = nil; return end
    if (os.time() - self.startedAt) / 60 >= cfg.limits.maxSessionMinutes then cfg.autoFarm = false; return end

    local character = self.player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        if not self.wasDead then self.deaths = self.deaths + 1 end
        self.wasDead = true
        if self.deaths > cfg.limits.maxDeaths then cfg.autoFarm = false end
        return
    end
    self.wasDead = false

    local resources = GameAPI.getResources(self.player)
    if type(resources) ~= "table" or (tonumber(resources.health) or 0) < cfg.minHealthToFight then return end

    local target = self:_findTarget(cfg)
    if not target then self.currentTarget = nil; return end
    self.currentTarget = target.model

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if (root.Position - target.root.Position).Magnitude > 18 then
        NavigationService.moveTo(self.player, target.root.Position)
    elseif not cfg.autoCombat then
        GameAPI.attack(self.player, target.model)
    end
end

function AutoFarmService:destroy()
    self.currentTarget = nil
end

return AutoFarmService
