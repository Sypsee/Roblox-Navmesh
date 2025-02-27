local utils = {}

type Triangle = {
    point1: Vector3,
    point2: Vector3,
    point3: Vector3
}

function utils.isPointInTriangle(point: Vector3, triangle: Triangle): boolean
    local p = point
    local a = triangle.point1
    local b = triangle.point2
    local c = triangle.point3

    a -= p
    b -= p
    c -= p

    local u = b:Cross(c)
    local v = c:Cross(a)
    local w = a:Cross(b)

    if u:Dot(v) < 0.0 then return false end
    if u:Dot(w) < 0.0 then return false end

    return true
end

return utils