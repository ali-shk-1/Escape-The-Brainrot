local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local GameService = require(script.Parent.GameService)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local caughtEvent = ServerStorage:WaitForChild("PlayerCaught")

Players.PlayerAdded:Connect(GameService.OnPlayerAdded)
Players.PlayerRemoving:Connect(GameService.OnPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(GameService.OnPlayerAdded, player)
end

-- Drop zones: only the base owner can deposit (touched + overlap checker)
local lastDeposit = {}
local baseZones = {}

for _, base in ipairs(workspace:WaitForChild("Bases"):GetChildren()) do
	local zone = base:WaitForChild("DropZone")
	table.insert(baseZones, { Base = base, Zone = zone })

	local function tryDeposit(player)
		if not player or not player.Parent then return end
		if base:GetAttribute("OwnerUserId") ~= player.UserId then return end
		if os.clock() - (lastDeposit[player] or 0) < 0.4 then return end
		lastDeposit[player] = os.clock()
		GameService.Deposit(player)
	end

	zone.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorOfClass("Model")
		local player = model and Players:GetPlayerFromCharacter(model)
		if player then
			tryDeposit(player)
		end
	end)
end

-- Spatial check in case fast sprinting skips Touched
task.spawn(function()
	while true do
		task.wait(0.2)
		for _, bz in ipairs(baseZones) do
			local ownerId = bz.Base:GetAttribute("OwnerUserId")
			if ownerId then
				local owner = Players:GetPlayerByUserId(ownerId)
				local char = owner and owner.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local rel = bz.Zone.CFrame:PointToObjectSpace(hrp.Position)
					local half = bz.Zone.Size / 2
					if math.abs(rel.X) <= (half.X + 1) and math.abs(rel.Z) <= (half.Z + 1) and math.abs(rel.Y) <= 5 then
						if os.clock() - (lastDeposit[owner] or 0) >= 0.4 then
							lastDeposit[owner] = os.clock()
							GameService.Deposit(owner)
						end
					end
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	lastDeposit[player] = nil
end)

Remotes.BuyUpgrade.OnServerEvent:Connect(GameService.BuyUpgrade)
Remotes.RedeemCode.OnServerEvent:Connect(GameService.RedeemCode)
caughtEvent.Event:Connect(GameService.Caught)

GameService.StartSpawning()
GameService.StartIncome()

print("Escape the Brainrot Core Engine active")
