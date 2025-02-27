local navmesh = {}
navmesh.__index = navmesh

local node = require(script.Parent.Node)
local obstacle = require(script.Parent.Obstacle)
local graph = require(script.Parent.Graph)
local utils = require(script.Parent.Utils)

type Triangle = {
    point1 : Vector3,
    point2 : Vector3,
    point3 : Vector3
}

type NodeTriangle = {
    point1 : typeof(node),
    point2 : typeof(node),
    point3 : typeof(node),
}

export type Boundary = {
    position : Vector3,
    size : Vector3
}

function navmesh.Init(_boundary : Boundary)
    local self = setmetatable({
        vertices = {},
        nodes = {},
        triangles = {},
        obstacles = {},
        boundary = _boundary,
    }, navmesh)

    return self
end

function navmesh:clear()
    table.clear(self.vertices)
    table.clear(self.nodes)
    table.clear(self.triangles)
end

function navmesh:setupVertices()
    local PosAddSize : Vector3 = self.boundary.position + self.boundary.size
    local PosSubSize : Vector3 = self.boundary.position - self.boundary.size

    table.insert(self.vertices, Vector3.new(PosAddSize.X, PosSubSize.Y, PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(PosAddSize.X, PosAddSize.Y, PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(-PosAddSize.X, PosSubSize.Y, -PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(-PosAddSize.X, PosAddSize.Y, -PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(PosAddSize.X, PosSubSize.Y, -PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(PosAddSize.X, PosAddSize.Y, -PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(-PosAddSize.X, PosSubSize.Y, PosAddSize.Z))
    table.insert(self.vertices, Vector3.new(-PosAddSize.X, PosAddSize.Y, PosAddSize.Z))
end

function navmesh:Draw()
    for _, t in self.triangles do
        local part = Instance.new("Part", workspace)
        part.Anchored = true
        part.CanCollide = false
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.one * 5
        part.Position = t.point1.position
        local highlight = Instance.new("Highlight", part)
        highlight.FillColor = Color3.new(1,0,0)

        local p2 = part:Clone()
        p2.Parent = workspace
        p2.Position = t.point2.position
        p2.Size = Vector3.one * 7
        local highlight1 = Instance.new("Highlight", p2)
        highlight1.FillColor = Color3.new(0,1,0)

        local p3 = part:Clone()
        p3.Parent = workspace
        p3.Position = t.point3.position
        p3.Size = Vector3.one * 10
        p3.Color = Color3.new(0,0,1)
        local highlight2 = Instance.new("Highlight", p3)
        highlight2.FillColor = Color3.new(0,0,1)

        local a0 = Instance.new("Attachment", part)
        a0.WorldPosition = p2.Position
        local a1 = Instance.new("Attachment", part)
        a1.WorldPosition = p3.Position

        local beam = Instance.new("Beam", part)
        beam.Attachment0 = a0
        beam.Attachment1 = a1
    end
end

function navmesh:AddObstacle(obstacle : typeof(obstacle))
    table.insert(self.obstacles, obstacle)
end

function navmesh:AddObstacleVertices()
    for i, obstacle in self.obstacles do
        for j, p in obstacle.points do
            table.insert(self.vertices, p)
        end
    end
end

function navmesh:CreateNodesAndGraphs()
    local prevNode : typeof(node)? = nil
    local firstNode : typeof(node)? = nil
    local currentNode : typeof(node)? = nil

    for i, vertex in self.vertices do
        currentNode = graph.GetNodeInRange(vertex, 5.0)
        if not currentNode then
            currentNode = {position = vertex}
            graph.AddNode(currentNode)
        end

        table.insert(self.nodes, currentNode)

        if prevNode then graph.AddConnection({from = prevNode, to = currentNode})
        else firstNode = currentNode end
        prevNode = currentNode
    end

    graph.AddConnection({from = firstNode, to = currentNode})
end

function navmesh:CanEarClip(prevIndex : number, currentIndex : number, nextIndex : number) : boolean
    local triangle : Triangle = {
        point1 = self.vertices[prevIndex],
        point2 = self.vertices[currentIndex],
        point3 = self.vertices[nextIndex]
    }
    local point1ToPoint2 = triangle.point2 - triangle.point1
    local point2ToPoint3 = triangle.point3 - triangle.point2

    -- Angle of a triangle is less then 90 degrees
    if point1ToPoint2:Dot(point2ToPoint3) < 0.0 then return false end

    -- Loop through all vertices and see if any of them are in the following triangle
    for i, vertex in self.vertices do
        if i ~= prevIndex and i ~= currentIndex and i ~= nextIndex then
            if utils.isPointInTriangle(vertex, triangle) then return false end
        end
    end

    return true
end

function navmesh:EarClip()
    local repeatedCounter = 0

    while #self.vertices >= 3 do
        local oldVerticesSize = #self.vertices
        for i, vertex in self.vertices do
            local prevIndex = i-1
            if prevIndex < 1 then prevIndex += #self.vertices end
            local nextIndex = (i+1) % #self.vertices
            if nextIndex <= 0 then nextIndex = 1 end

            if navmesh.CanEarClip(self, prevIndex, i, nextIndex) then
                graph.AddConnection({from = self.nodes[prevIndex], to = self.nodes[nextIndex]})
                local triangle : NodeTriangle = {point1 = self.nodes[prevIndex], point2 = self.nodes[i], point3 = self.nodes[nextIndex]}
                table.insert(self.triangles, triangle)

                table.remove(self.nodes, i)
                table.remove(self.vertices, i)
            end
        end

        if oldVerticesSize == #self.vertices then
            repeatedCounter += 1

            if repeatedCounter > 4 then
                break
            end
        end

        task.wait()
    end
end

function navmesh:Calc()
    -- why are you using self fucking idiot? just do :X() : (that does not work stupid metatables)
    navmesh.clear(self)
    navmesh.setupVertices(self)
    navmesh.AddObstacleVertices(self)
    navmesh.CreateNodesAndGraphs(self)
    navmesh.EarClip(self)
end

return navmesh