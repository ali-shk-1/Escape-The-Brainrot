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

-- Drop zones: only the base owner can deposit
local lastDeposit = {}
for _, base in ipairs(workspace:WaitForChild("Bases"):GetChildren()) do
	local zone = base:WaitForChild("DropZone")
	zone.Touched:Connect(function(hit)
		local model = hit:FindFirstAncestorOfClass("Model")
		local player = model and Players:GetPlayerFromCharacter(model)
		if not player then
			return
		end
		if base:GetAttribute("OwnerUserId") ~= player.UserId then
			return
		end
		if os.clock() - (lastDeposit[player] or 0) < 0.5 then
			return
		end
		lastDeposit[player] = os.clock()
		GameService.Deposit(player)
	end)
end

Players.PlayerRemoving:Connect(function(player)
	lastDeposit[player] = nil
end)

Remotes.BuyUpgrade.OnServerEvent:Connect(GameService.BuyUpgrade)
Remotes.RedeemCode.OnServerEvent:Connect(GameService.RedeemCode)
caughtEvent.Event:Connect(GameService.Caught)

GameService.StartSpawning()
GameService.StartIncome()

print("Escape the Brainrot M5 loaded")
