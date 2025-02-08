local graph = {
    nodes = {},
    connections = {}
}
local nodeService = require(script.Parent.Node)

type Connection = {
    from : typeof(nodeService),
    to : typeof(nodeService)
}

function graph.AddNode(node : typeof(nodeService)?)
    table.insert(graph.nodes, node)
end

function graph.AddConnection(connection : Connection)
    table.insert(graph.connections, connection)
end

function graph.GetNodeInRange(pos : Vector3, maxDistance : number) : typeof(nodeService)?
    for i, node in graph.nodes do
        if (node.position - pos).Magnitude < maxDistance then
            return node
        end
    end

    return nil
end

function graph.RemoveNode(node : typeof(nodeService))
    table.remove(graph.nodes, table.find(graph.nodes, node))

    for i, connection in graph.connections do
        if connection.from == node or connection.to == node then
            table.remove(graph.connections, i)
        end
    end

    print("Removed node!")
end

return graph