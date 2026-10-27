local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local GameAPI = require(ReplicatedStorage.Shared.GameAPI)
local ConfigStore = require(script.Parent.ConfigStore)
local NavigationService = require(script.Parent.NavigationService)
local CombatService = require(script.Parent.CombatService)
local AutoFarmService = require(script.Parent.AutoFarmService)
local InventoryService = require(script.Parent.InventoryService)
local RaidService = require(script.Parent.RaidService)
local BossService = require(script.Parent.BossService)
local MasteryService = require(script.Parent.MasteryService)

local R = Remotes.ensure()
local sessions = {}

local function buildState(player, session)
    return {
        cfg = session.cfg,
        level = GameAPI.getLevel(player),
        xp = GameAPI.getXP(player),
        resources = GameAPI.getResources(player),
        mastery = GameAPI.getMastery(player),
        inventory = GameAPI.getInventory(player),
        space = GameAPI.inventorySpace(player),
        raid = GameAPI.raidStatus(player),
        combatTarget = session.combat.target and session.combat.target.Name or nil,
        farmTarget = session.farm.currentTarget and session.farm.currentTarget.Name or nil,
        bossTarget = session.boss.currentBoss,
        online = true,
    }
end

local function validPatch(patch)
    if type(patch) ~= "table" then return false end
    local allowed = {
        autoFarm = "boolean", autoCollect = "boolean", autoCombat = "boolean",
        autoNavigate = "boolean", autoRaid = "boolean", autoBoss = "boolean",
        autoFarmPriority = "string", autoFarmMaxDist = "number",
        combatPriority = "string", combatMaxDist = "number",
        minHealthToFight = "number", masteryTarget = "string",
        collectList = "table", raidPriority = "table", bossList = "table",
        limits = "table", ui = "table",
    }
    for key, value in pairs(patch) do
        if allowed[key] == nil or type(value) ~= allowed[key] then return false end
    end
    return true
end

Players.PlayerAdded:Connect(function(player)
    local cfg = ConfigStore.load(player)
    sessions[player] = {
        cfg = cfg,
        combat = CombatService.new(player),
        farm = nil,
        inv = InventoryService.new(player),
        raid = RaidService.new(player),
        boss = BossService.new(player),
        mastery = MasteryService.new(player),
    }
    sessions[player].farm = AutoFarmService.new(player, sessions[player].combat)
end)

R.funcs.GetState.OnServerInvoke = function(player)
    local session = sessions[player]
    if not session then return nil end
    return buildState(player, session)
end

R.events.SetState.OnServerEvent:Connect(function(player, patch)
    local session = sessions[player]
    if not session or not validPatch(patch) then return end
    session.cfg = ConfigStore.update(player, patch)
end)

R.events.Command.OnServerEvent:Connect(function(player, command, argument)
    local session = sessions[player]
    if not session or type(command) ~= "string" then return end
    if command == "stopAll" then
        for _, key in ipairs({"autoFarm", "autoCombat", "autoCollect", "autoRaid", "autoBoss", "autoNavigate"}) do
            session.cfg[key] = false
        end
        NavigationService.cancel(player)
        ConfigStore.save(player)
    elseif command == "navigateTo" and type(argument) == "table"
        and type(argument.x) == "number" and type(argument.y) == "number" and type(argument.z) == "number" then
        local dest = Vector3.new(argument.x, argument.y, argument.z)
        if dest.Magnitude < 100000 then NavigationService.moveTo(player, dest) end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    local session = sessions[player]
    if session then
        session.combat:destroy()
        session.farm:destroy()
        NavigationService.cancel(player)
    end
    ConfigStore.save(player)
    sessions[player] = nil
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        for player, session in pairs(sessions) do
            local ok, err = pcall(function()
                session.combat:step(session.cfg)
                session.farm:step(session.cfg)
                session.inv:step(session.cfg)
                session.raid:step(session.cfg)
                session.boss:step(session.cfg)
                session.mastery:step(session.cfg)
            end)
            if not ok then warn("[Automation] Erro em", player.Name, err) end
            local stateOk, state = pcall(buildState, player, session)
            if stateOk and state then R.events.StateUpdate:FireClient(player, state) end
        end
    end
end)
