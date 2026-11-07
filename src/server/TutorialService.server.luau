local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataService = require(script.Parent.DataService)
local GameService = require(script.Parent.GameService)

local LAST_STEP = 3

local function stepDone(player, data, step)
	if step == 1 then
		return (player:GetAttribute("CarryCount") or 0) > 0 or #data.Stored > 0
	elseif step == 2 then
		return #data.Stored > 0
	elseif step == 3 then
		local levels = data.Levels
		return levels.Speed + levels.Capacity + levels.Slots > 0
	end
	return false
end

local function update(player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local tutorial = data.Tutorial

	-- veterans (old saves) skip the tutorial silently
	if not tutorial.Done and tutorial.Step == 1 and (#data.Stored >= 3 or data.Rebirths > 0) then
		tutorial.Done = true
	end

	if tutorial.Done then
		player:SetAttribute("TutorialStep", 0)
		return
	end

	-- may complete several steps at once (for example depositing right after grabbing)
	while tutorial.Step <= LAST_STEP and stepDone(player, data, tutorial.Step) do
		tutorial.Step += 1
		if tutorial.Step == 2 then
			GameService.Notify(player, "Nice! Big Gus chases anyone carrying creatures. Run home!")
		end
	end

	-- starter gift so the player can afford the first upgrade
	if tutorial.Step == 3 and not tutorial.Gift then
		tutorial.Gift = true
		GameService.GiveCoins(player, Config.Tutorial.UpgradeGift)
		GameService.Notify(player, "Stored! Here is " .. Config.Tutorial.UpgradeGift .. " coins. Open the SHOP!")
	end

	if tutorial.Step > LAST_STEP then
		tutorial.Done = true
		player:SetAttribute("TutorialStep", 0)
		GameService.GiveCoins(player, Config.Tutorial.FinishReward)
		GameService.Notify(player, "Tutorial complete! +" .. Config.Tutorial.FinishReward .. " coins. Now go get the rare ones!")
		if GameService.Sfx then
			GameService.Sfx(player, "Upgrade")
		end
		task.spawn(DataService.Save, player)
		return
	end

	player:SetAttribute("TutorialStep", tutorial.Step)
end

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			update(player)
		end
		task.wait(0.5)
	end
end)
