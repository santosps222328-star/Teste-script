local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.Shared.Config)

local ConfigStore = {}
local cache = {}
local store
pcall(function() store = DataStoreService:GetDataStore("AutoCfg_v1") end)

local function key(userId) return "u_" .. tostring(userId) end

function ConfigStore.load(player)
    if cache[player.UserId] then return cache[player.UserId] end
    local data
    if store then
        local ok, result = pcall(function() return store:GetAsync(key(player.UserId)) end)
        if ok then data = result end
    end
    cache[player.UserId] = Config.sanitize(data or Config.Defaults)
    return cache[player.UserId]
end

function ConfigStore.get(player)
    return cache[player.UserId] or ConfigStore.load(player)
end

function ConfigStore.save(player)
    local data = cache[player.UserId]
    if not store or not data then return end
    local snapshot = Config.sanitize(data)
    task.spawn(function()
        local ok, err = pcall(function() store:UpdateAsync(key(player.UserId), function() return snapshot end) end)
        if not ok then warn("[ConfigStore] Falha ao salvar:", err) end
    end)
end

function ConfigStore.update(player, patch)
    local cur = ConfigStore.load(player)
    if type(patch) ~= "table" then return cur end
    -- Atualiza apenas chaves conhecidas; objetos aninhados são sanitizados.
    for k, v in pairs(patch) do
        if Config.Defaults[k] ~= nil and type(v) == type(Config.Defaults[k]) then
            cur[k] = v
        end
    end
    cache[player.UserId] = Config.sanitize(cur)
    ConfigStore.save(player)
    return cache[player.UserId]
end

Players.PlayerRemoving:Connect(function(player)
    ConfigStore.save(player)
    cache[player.UserId] = nil
end)

return ConfigStore
