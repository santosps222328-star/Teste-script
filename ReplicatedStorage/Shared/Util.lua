local Util = {}

function Util.dist2(a, b)
    local d = a - b
    return d:Dot(d)
end

function Util.horizontalDist(a, b)
    local dx, dz = a.X - b.X, a.Z - b.Z
    return math.sqrt(dx * dx + dz * dz)
end

function Util.isAlive(humanoid)
    return humanoid and humanoid.Parent and humanoid.Health > 0
end

function Util.truncate(value, n)
    local s = tostring(value or "")
    if #s <= n then return s end
    return s:sub(1, math.max(1, n - 1)) .. "…"
end

return Util
