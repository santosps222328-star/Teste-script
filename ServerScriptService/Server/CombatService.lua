local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Util = require(ReplicatedStorage.Shared.Util)
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)

local CombatService = {}
CombatService.__index = CombatService
local COOLDOWN = 0.45

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then return true end
    end
    return false
end

function CombatService.new(player)
    return setmetatable({ player = player, lastAttack = 0, target = nil, active = false }, CombatService)
end

function CombatService:_character()
    local character = self.player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if root and humanoid and humanoid.Health > 0 then return character, root, humanoid end
end

function CombatService:_pickTarget(root, cfg)
    local candidates = {}
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:GetAttribute("IsNPC") == true and not isPlayerCharacter(model) then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and targetRoot then
                local distance = Util.horizontalDist(root.Position, targetRoot.Position)
                if distance <= (cfg.combatMaxDist or 60) then
                    table.insert(candidates, {
                        model = model,
                        level = tonumber(model:GetAttribute("Level")) or 1,
                        distance = distance,
                    })
                end
            end
        end
    end
    table.sort(candidates, function(a, b)
        if cfg.combatPriority == "Level" and a.level ~= b.level then return a.level < b.level end
        return a.distance < b.distance
    end)
    return candidates[1]
end

function CombatService:step(cfg)
    self.active = false
    if not cfg.autoCombat then self.target = nil; return end
    local _, root = self:_character()
    if not root then self.target = nil; return end

    local resources = GameAPI.getResources(self.player)
    if type(resources) ~= "table" or (tonumber(resources.health) or 0) < (cfg.minHealthToFight or 0.4) then
        self.target = nil
        return
    end
    if os.clock() - self.lastAttack < COOLDOWN then return end

    local chosen = self:_pickTarget(root, cfg)
    if not chosen then self.target = nil; return end
    self.target = chosen.model
    if GameAPI.attack(self.player, chosen.model) then
        self.lastAttack = os.clock()
        self.active = true
    end
end

function CombatService:destroy()
    self.target = nil
    self.active = false
end

return CombatService
