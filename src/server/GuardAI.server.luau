local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ServerStorage = game:GetService("ServerStorage")

local caughtEvent = ServerStorage:WaitForChild("PlayerCaught")
local guard = workspace:WaitForChild("Guard")
local humanoid = guard:WaitForChild("Humanoid")
local root = guard:WaitForChild("HumanoidRootPart")
local waypointFolder = workspace:WaitForChild("GuardWaypoints")

local PATROL_SPEED = 12
local CHASE_SPEED = 17      -- a little above base speed
local DETECT_RANGE = 75
local CATCH_RANGE = 6.5     -- slightly expanded to prevent fast-player tunneling

pcall(function()
	root:SetNetworkOwner(nil) -- smooth movement controlled by server
end)

-- Find closest player carrying creatures who is alive and valid
local function findTarget()
	local best, bestDistance = nil, DETECT_RANGE
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.Health > 0 and (player:GetAttribute("CarryCount") or 0) > 0 then
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
		AgentRadius = 2.5,
		AgentHeight = 5.5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	})
	local ok = pcall(function()
		path:ComputeAsync(root.Position, position)
	end)
	if ok and path.Status == Enum.PathStatus.Success then
		local points = path:GetWaypoints()
		local nextPoint = points[2] or points[1]
		if nextPoint then
			if nextPoint.Action == Enum.PathWaypointAction.Jump then
				humanoid.Jump = true
			end
			humanoid:MoveTo(nextPoint.Position)
			return
		end
	end
	-- Fallback direct step
	humanoid:MoveTo(position)
end

-- Stun / Cooldown after catch
local stunUntil = 0
local lastPos = root.Position
local stuckTime = 0
local patrolTarget = nil

while true do
	local now = os.clock()
	if now < stunUntil then
		humanoid.WalkSpeed = 0
		task.wait(0.2)
		continue
	end

	-- Watchdog: detect if stuck against geometry
	local movedDist = (root.Position - lastPos).Magnitude
	lastPos = root.Position
	if movedDist < 0.4 and humanoid.WalkSpeed > 0 then
		stuckTime += 0.25
		if stuckTime > 1.8 then
			-- Stuck! Jump and force pick a new target
			humanoid.Jump = true
			patrolTarget = nil
			stuckTime = 0
		end
	else
		stuckTime = 0
	end

	local target = findTarget()
	local isChasing = target ~= nil
	guard:SetAttribute("Chasing", isChasing)

	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		humanoid.WalkSpeed = CHASE_SPEED
		local hrp = target.Character.HumanoidRootPart
		local dist = (hrp.Position - root.Position).Magnitude
		if dist <= CATCH_RANGE then
			caughtEvent:Fire(target)
			stunUntil = now + 2.5 -- pause after catch
			humanoid.WalkSpeed = 0
			patrolTarget = nil
		else
			stepToward(hrp.Position)
		end
	else
		humanoid.WalkSpeed = PATROL_SPEED
		local points = waypointFolder:GetChildren()
		if #points > 0 then
			if not patrolTarget or (patrolTarget.Position - root.Position).Magnitude < 7 then
				patrolTarget = points[math.random(#points)]
			end
			if patrolTarget then
				stepToward(patrolTarget.Position)
			end
		end
	end

	task.wait(0.25)
end
