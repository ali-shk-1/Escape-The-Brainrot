local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local GameService = require(script.Parent.GameService)

-- which creature is the weekly event creature right now, and when does the week end?
local function currentEvent()
	local week = math.floor(os.time() / Config.Event.WeekSeconds)
	local id = Config.Events[(week % #Config.Events) + 1]
	local endsAt = (week + 1) * Config.Event.WeekSeconds
	return id, endsAt
end

local function countInMall(id)
	local folder = workspace:FindFirstChild("ActiveCreatures")
	local n = 0
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child.Name == id then
				n += 1
			end
		end
	end
	return n
end

-- publish the event so every client can show it (workspace attributes replicate automatically)
task.spawn(function()
	while true do
		local id, endsAt = currentEvent()
		workspace:SetAttribute("EventCreature", id)
		workspace:SetAttribute("EventEndsAt", endsAt)
		task.wait(5)
	end
end)

-- spawn the event creature in the mall
task.spawn(function()
	task.wait(15) -- let the mall finish its first spawns
	while true do
		local id = currentEvent()
		if Config.Creatures[id] and countInMall(id) < Config.Event.MaxAtOnce then
			local pad = GameService.GetFreeSpawn(Config.Event.SpawnTier) or GameService.GetFreeSpawn(nil)
			if pad then
				GameService.SpawnWorldCreature(pad, id)
				local info = Config.Creatures[id]
				for _, player in ipairs(Players:GetPlayers()) do
					GameService.Notify(player, "WEEKLY EVENT! " .. info.Name .. " appeared in the mall!")
					if GameService.Sfx then
						GameService.Sfx(player, "Legendary")
					end
				end
			end
		end
		task.wait(Config.Event.SpawnInterval)
	end
end)
