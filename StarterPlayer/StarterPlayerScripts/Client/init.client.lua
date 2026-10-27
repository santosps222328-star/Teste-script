local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Config = require(ReplicatedStorage.Shared.Config)
local MainPanel = require(script.Parent.UI.MainPanel)

local folder = Remotes.wait()
if not folder then warn("Remotes não foram criados pelo servidor."); return end
local setStateEvent = folder:WaitForChild("SetState")
local stateUpdateEvent = folder:WaitForChild("StateUpdate")
local commandEvent = folder:WaitForChild("Command")
local getState = folder:WaitForChild("GetState")

local ok, initial = pcall(function() return getState:InvokeServer() end)
local state = ok and initial and initial.cfg or Config.sanitize(Config.Defaults)

local panel = MainPanel.new(state, function(patch)
    setStateEvent:FireServer(patch)
end, function(command, argument)
    commandEvent:FireServer(command, argument)
end)

stateUpdateEvent.OnClientEvent:Connect(function(newState)
    if type(newState) == "table" and type(newState.cfg) == "table" then
        panel:updateState(newState.cfg)
    end
end)
