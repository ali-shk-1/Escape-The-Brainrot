local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataService = require(script.Parent.DataService)
local GameService = require(script.Parent.GameService)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClaimRemote = Remotes:FindFirstChild("ClaimDaily")
if not ClaimRemote then
	ClaimRemote = Instance.new("RemoteEvent")
	ClaimRemote.Name = "ClaimDaily"
	ClaimRemote.Parent = Remotes
end

local rewards = Config.Daily.Rewards

-- returns ready, secondsLeft, currentStreak (after reset check), nextDay (1 to #rewards)
local function status(data)
	local daily = data.Daily
	local now = os.time()
	local since = now - daily.LastClaim
	local streak = daily.Streak
	if daily.LastClaim ~= 0 and since >= Config.Daily.ResetSeconds then
		streak = 0
	end
	local ready = daily.LastClaim == 0 or since >= Config.Daily.CooldownSeconds
	local secondsLeft = ready and 0 or (Config.Daily.CooldownSeconds - since)
	local nextDay = (streak % #rewards) + 1
	return ready, secondsLeft, streak, nextDay
end

local function publish(player, data)
	local ready, secondsLeft, streak, nextDay = status(data)
	player:SetAttribute("DailyReady", ready)
	player:SetAttribute("DailySeconds", secondsLeft)
	player:SetAttribute("DailyStreak", streak)
	player:SetAttribute("DailyDay", nextDay)
end

local busy = {}

ClaimRemote.OnServerEvent:Connect(function(player)
	if busy[player] then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	local ready, _, streak, nextDay = status(data)
	if not ready then
		GameService.Notify(player, "Your daily reward is not ready yet.")
		return
	end

	busy[player] = true
	local reward = rewards[nextDay]
	data.Daily.LastClaim = os.time()
	data.Daily.Streak = streak + 1

	if reward.Coins then
		GameService.GiveCoins(player, reward.Coins)
	end
	local text = "Daily reward! Day " .. nextDay .. ": +" .. (reward.Coins or 0) .. " coins"
	if reward.Crate and Config.Crates[reward.Crate] then
		GameService.OpenCrate(player, reward.Crate)
		text ..= " and a bonus creature!"
	end
	GameService.Notify(player, text)
	if GameService.Sfx then
		GameService.Sfx(player, "Upgrade")
	end

	publish(player, data)
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
