local obstacle = {}
obstacle.__index = obstacle

function obstacle.new(_points : {Vector3})
    local self = setmetatable({
        points = _points,
        isCompleted = true
    }, obstacle)

    return self
end

function obstacle:PushBack(point : Vector3)
    if #self.points > 0 then
        if (point - self.points[0]).Magnitude < 10.0 then
            obstacle:Complete()
            return
        end
    end

    table.insert(self.points, point)
end

function obstacle:Complete()
    self.isCompleted = true
    if obstacle:GetDeterminant() > 0 then
        obstacle:FlipVertex()
    end
end

function obstacle:FlipVertex()
    for i=#self.points, 1, -1 do
        self.points[i], self.points[self.points-i] = self.points[self.points-i], self.points[i]
    end
end

--https://en.wikipedia.org/wiki/Curve_orientation
function obstacle:GetDeterminant() : number
	if (#self.points < 3) then return 0 end
	
	local determinant = 0
	local countNegative = 0
	local countPositive = 0

	for i=1, #self.points-2 do
		local A = self.points[i]
		local B = self.points[i+1]
		local C = self.points[i+2]

		local f1 = B.x * C.y + A.x * B.y + C.x * A.y
		local f2 = A.y * B.x + B.y * C.x + C.y * A.x
		determinant = f1 - f2

		if determinant < 0 then countNegative += 1 end
		if determinant > 0 then countPositive += 1 end
    end

	if determinant < 0 and countPositive > countNegative then
		return -determinant
    end

	if determinant > 0 and countPositive < countNegative then
		return -determinant
    end

	return determinant
end

return obstacle