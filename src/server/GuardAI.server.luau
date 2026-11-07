local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")

local caughtEvent = ServerStorage:WaitForChild("PlayerCaught")
local guard = workspace:WaitForChild("Guard")
local humanoid = guard:WaitForChild("Humanoid")
local root = guard:WaitForChild("HumanoidRootPart")
local waypointFolder = workspace:WaitForChild("GuardWaypoints")

local PATROL_SPEED = 12
local CHASE_SPEED = 17      -- a little above a normal player; upgraded players can outrun him
local DETECT_RANGE = 70
local CATCH_RANGE = 5

pcall(function()
	root:SetNetworkOwner(nil) -- smooth movement controlled by the server
end)

-- the guard only hunts players who are carrying creatures
local function findTarget()
	local best, bestDistance = nil, DETECT_RANGE
	for _, player in ipairs(Players:GetPlayers()) do
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp and (player:GetAttribute("CarryCount") or 0) > 0 then
			local distance = (hrp.Position - root.Position).Magnitude
			if distance < bestDistance then
				best, bestDistance = player, distance
			end
		end
	end
	return best
end

local function stepToward(position)
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
	})
	local ok = pcall(function()
		path:ComputeAsync(root.Position, position)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		local points = path:GetWaypoints()
		local nextPoint = points[2] or points[1]
		if nextPoint.Action == Enum.PathWaypointAction.Jump then
			humanoid.Jump = true
		end
		humanoid:MoveTo(nextPoint.Position)
	else
		humanoid:MoveTo(position)
	end
end

local patrolTarget
while true do
	local target = findTarget()
	guard:SetAttribute("Chasing", target ~= nil) -- used later by graphics and audio
	if target then
		humanoid.WalkSpeed = CHASE_SPEED
		local hrp = target.Character.HumanoidRootPart
		if (hrp.Position - root.Position).Magnitude <= CATCH_RANGE then
			caughtEvent:Fire(target)
			task.wait(3) -- short pause after a catch
		else
			stepToward(hrp.Position)
		end
	else
		humanoid.WalkSpeed = PATROL_SPEED
		local points = waypointFolder:GetChildren()
		if #points > 0 then
			if not patrolTarget or (patrolTarget.Position - root.Position).Magnitude < 6 then
				patrolTarget = points[math.random(#points)]
			end
			stepToward(patrolTarget.Position)
		end
	end
	task.wait(0.25)
end
