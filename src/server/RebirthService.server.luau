local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataService = require(script.Parent.DataService)
local GameService = require(script.Parent.GameService)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RebirthRemote = Remotes:FindFirstChild("Rebirth")
if not RebirthRemote then
	RebirthRemote = Instance.new("RemoteEvent")
	RebirthRemote.Name = "Rebirth"
	RebirthRemote.Parent = Remotes
end

local function publish(player, data)
	local count = data.Rebirths
	player:SetAttribute("Rebirths", count)
	player:SetAttribute("RebirthMax", count >= Config.Rebirth.Max)
	player:SetAttribute("RebirthCost", Config.RebirthCost(count))
	player:SetAttribute("RebirthBonus", count * Config.Rebirth.BonusPerRebirth)
end

local busy = {}

RebirthRemote.OnServerEvent:Connect(function(player)
	if busy[player] then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	if data.Rebirths >= Config.Rebirth.Max then
		GameService.Notify(player, "You reached the maximum rebirth!")
		return
	end
	local cost = Config.RebirthCost(data.Rebirths)
	if data.Coins < cost then
		GameService.Notify(player, "Not enough coins to rebirth. Need " .. cost .. ".")
		return
	end

	busy[player] = true

	data.Rebirths += 1
	data.Coins = Config.Rebirth.StartCoins
	data.Stored = {}
	for name in pairs(data.Levels) do
		data.Levels[name] = 0
	end

	GameService.ClearCarry(player)
	GameService.GiveCoins(player, 0) -- refreshes the leaderboard number
	GameService.SyncAttributes(player)
	GameService.ApplyWalkSpeed(player)
	GameService.RefreshBase(player)
	publish(player, data)

	GameService.Notify(player, "REBIRTH " .. data.Rebirths .. "! Permanent +" .. (data.Rebirths * Config.Rebirth.BonusPerRebirth * 100) .. "% coins!")
	if GameService.Sfx then
		GameService.Sfx(player, "Legendary")
	end

	task.spawn(DataService.Save, player)
	busy[player] = nil
end)

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local data = DataService.Get(player)
			if data then
				publish(player, data)
			end
		end
		task.wait(1)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	busy[player] = nil
end)
