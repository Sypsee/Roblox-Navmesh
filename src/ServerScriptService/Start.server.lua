-- This is an example script on how to use the custom navmesh solution

local rs = game:GetService("ReplicatedStorage")
local modules = rs:WaitForChild("Src").Modules

local navmeshService = require(modules.Navmesh)
local obstacleService = require(modules.Obstacle)

local obstaclePoints = {
    Vector3.new(10, 1, 10),
    Vector3.new(10, -1, 10),
    Vector3.new(-10, 1, -10),
    Vector3.new(-10, -1, -10),
    Vector3.new(10, 1, -10),
    Vector3.new(10, 1, -10),
    Vector3.new(-10, -1, 10),
    Vector3.new(-10, -1, 10),
}
local obstacle = obstacleService.new(obstaclePoints)

local navmesh = navmeshService.Init({size = Vector3.one * 100, position = Vector3.zero})
navmesh:AddObstacle(obstacle)
navmesh:Calc()
navmesh:Draw()