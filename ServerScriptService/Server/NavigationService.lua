local PathfindingService = game:GetService("PathfindingService")
local NavigationService = {}
local tokens = {}

local function getCharacter(player)
    local character = player.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if root and humanoid and humanoid.Health > 0 then return character, root, humanoid end
end

function NavigationService.moveTo(player, destination, options)
    if typeof(destination) ~= "Vector3" then return false, "destino inválido" end
    local character, root, humanoid = getCharacter(player)
    if not character then return false, "personagem indisponível" end

    local path = PathfindingService:CreatePath({
        AgentRadius = (options and options.agentRadius) or 2,
        AgentHeight = (options and options.agentHeight) or 5,
        AgentCanJump = true,
        AgentCanClimb = false,
    })
    local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
    if not ok or path.Status ~= Enum.PathStatus.Success then return false, "sem rota" end

    tokens[player] = (tokens[player] or 0) + 1
    local token = tokens[player]
    local waypoints = path:GetWaypoints()

    task.spawn(function()
        for index = 2, #waypoints do
            if tokens[player] ~= token or not player.Parent then return end
            local waypoint = waypoints[index]
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(waypoint.Position)
            local reached = false
            local connection
            connection = humanoid.MoveToFinished:Connect(function(success)
                reached = success
                if connection then connection:Disconnect() end
            end)
            local deadline = os.clock() + 5
            while os.clock() < deadline and not reached do
                if tokens[player] ~= token then
                    if connection then connection:Disconnect() end
                    return
                end
                if (root.Position - waypoint.Position).Magnitude < 3 then reached = true end
                task.wait(0.1)
            end
            if connection then connection:Disconnect() end
        end
    end)
    return true
end

function NavigationService.cancel(player)
    tokens[player] = (tokens[player] or 0) + 1
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if root and humanoid then humanoid:MoveTo(root.Position) end
end

return NavigationService
