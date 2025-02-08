local navmesh = {}
navmesh.__index = navmesh

local node = require(script.Parent.Node)
local obstacle = require(script.Parent.Obstacle)
local graph = require(script.Parent.Graph)

type Triangle = {
    point1 : typeof(node),
    point2 : typeof(node),
    point3 : typeof(node)
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
    for _, p in self.vertices do
        local part = Instance.new("Part", workspace)
        part.Anchored = true
        part.CanCollide = false
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.one * 10
        part.Position = p
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
        currentNode = graph.GetNodeInRange(vertex, 10.0)
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

function navmesh:Calc()
    -- why are you using self fucking idiot? just do :X() : (that does not work stupid metatables)
    navmesh.clear(self)
    navmesh.setupVertices(self)
    navmesh.AddObstacleVertices(self)
    navmesh.CreateNodesAndGraphs(self)

    print(graph)
end

return navmesh