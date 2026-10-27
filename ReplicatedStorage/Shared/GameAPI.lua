-- CONTRATO da API do jogo. Substitua os retornos padrão pela lógica do seu jogo.
-- Os retornos padrão mantêm os recursos desativados; não concedem dano/XP/loot.

local GameAPI = {}

function GameAPI.attack(_player, _targetModel) return false end
function GameAPI.getResources(_player) return { health = 1, energy = 1 } end
function GameAPI.listCollectibles(_player) return {} end
function GameAPI.tryCollect(_player, _itemId) return false end

function GameAPI.listRaids(_player) return {} end
function GameAPI.startRaid(_player, _raidId) return false end
function GameAPI.raidStatus(_player) return nil end

function GameAPI.listBosses(_player) return {} end
function GameAPI.getMastery(_player) return {} end
function GameAPI.equipCategory(_player, _category) return false end

function GameAPI.getLevel(_player) return 1 end
function GameAPI.getXP(_player) return 0 end
function GameAPI.getInventory(_player) return {} end
function GameAPI.inventorySpace(_player) return { used = 0, max = 50 } end

return GameAPI
