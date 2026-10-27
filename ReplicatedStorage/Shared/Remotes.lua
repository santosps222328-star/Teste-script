local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = {}
local FOLDER_NAME = "_AutomationRemotes"

local EVENT_NAMES = { "SetState", "StateUpdate", "Command" }
local FUNC_NAMES = { "GetState" }

local function getOrCreate(className, name, parent)
    local obj = parent:FindFirstChild(name)
    if obj and obj.ClassName == className then return obj end
    if obj then obj:Destroy() end
    obj = Instance.new(className)
    obj.Name = name
    obj.Parent = parent
    return obj
end

function Remotes.ensure()
    local folder = getOrCreate("Folder", FOLDER_NAME, ReplicatedStorage)
    local events, funcs = {}, {}
    for _, name in ipairs(EVENT_NAMES) do
        events[name] = getOrCreate("RemoteEvent", name, folder)
    end
    for _, name in ipairs(FUNC_NAMES) do
        funcs[name] = getOrCreate("RemoteFunction", name, folder)
    end
    return { folder = folder, events = events, funcs = funcs }
end

function Remotes.wait()
    return ReplicatedStorage:WaitForChild(FOLDER_NAME, 15)
end

return Remotes
