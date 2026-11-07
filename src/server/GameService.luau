local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataService = require(script.Parent.DataService)
local CreatureFX = require(script.Parent.CreatureFX)

local function getOrCreate(parent, className, name)
	local inst = parent:FindFirstChild(name)
	if not inst then
		inst = Instance.new(className)
		inst.Name = name
		inst.Parent = parent
	end
	return inst
end

local Remotes = getOrCreate(ReplicatedStorage, "Folder", "Remotes")
local NotifyRemote = getOrCreate(Remotes, "RemoteEvent", "Notify")
getOrCreate(Remotes, "RemoteEvent", "BuyUpgrade")
getOrCreate(Remotes, "RemoteEvent", "RedeemCode")
local SfxRemote = getOrCreate(Remotes, "RemoteEvent", "Sfx")
getOrCreate(ServerStorage, "BindableEvent", "PlayerCaught")

local creatureTemplates = ServerStorage:FindFirstChild("Creatures")
local bases = workspace:WaitForChild("Bases"):GetChildren()
local spawnPoints = workspace:WaitForChild("CreatureSpawns"):GetChildren()

local activeFolder = Instance.new("Folder")
activeFolder.Name = "ActiveCreatures"
activeFolder.Parent = workspace

local rng = Random.new()
local carrying = {} -- [player] = { {Id = "...", Model = Model}, ... }
local baseOf = {}   -- [player] = base Model
local occupied = {} -- [spawnPart] = true

local GameService = {}

local function notify(player, text)
	NotifyRemote:FireClient(player, text)
end
GameService.Notify = notify

function GameService.Sfx(player, name)
	SfxRemote:FireClient(player, name)
end

---------------------------------------------------------------------
-- Creature models (placeholder cube if no art exists yet)
---------------------------------------------------------------------
function GameService.MakeCreature(id)
	local template = creatureTemplates and creatureTemplates:FindFirstChild(id)
	if template then
		local clone = template:Clone()
		if not clone.PrimaryPart then
			clone.PrimaryPart = clone:FindFirstChildWhichIsA("BasePart", true)
		end
		return clone
	end

	local info = Config.Creatures[id]
	local model = Instance.new("Model")
	model.Name = id

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 3, 3)
	body.Color = Config.Rarities[info.Rarity].Color
	body.Material = Enum.Material.SmoothPlastic
	body.Parent = model
	model.PrimaryPart = body

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(170, 40)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = body

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.Text = info.Name
	label.Parent = gui

	return model
end

---------------------------------------------------------------------
-- Weighted random helpers
---------------------------------------------------------------------
local creaturesByRarity = {}
for id, info in pairs(Config.Creatures) do
	creaturesByRarity[info.Rarity] = creaturesByRarity[info.Rarity] or {}
	table.insert(creaturesByRarity[info.Rarity], id)
end

local function pickWeighted(weights)
	local total = 0
	for _, w in pairs(weights) do
		total += w
	end
	local roll = rng:NextNumber(0, total)
	local last
	for key, w in pairs(weights) do
		last = key
		roll -= w
		if roll <= 0 then
			return key
		end
	end
	return last
end

function GameService.RandomCreature(weights)
	local rarity = pickWeighted(weights)
	local list = creaturesByRarity[rarity]
	return list[rng:NextInteger(1, #list)]
end

---------------------------------------------------------------------
-- Player stats
---------------------------------------------------------------------
function GameService.GetCapacity(player)
	local data = DataService.Get(player)
	if not data then
		return 1
	end
	local cap = Config.Player.BaseCapacity + data.Levels.Capacity
	if player:GetAttribute("CarryMore") then
		cap += 2
	end
	return cap
end

function GameService.GetSlots(player)
	local data = DataService.Get(player)
	if not data then
		return Config.BaseSlots
	end
	local slots = Config.BaseSlots + data.Levels.Slots
	if player:GetAttribute("VIP") then
		slots += 2
	end
	return math.min(slots, Config.MaxSlotParts)
end

function GameService.GetMultiplier(player)
	local m = 1
	if player:GetAttribute("DoubleCoins") then
		m += 1
	end
	if player:GetAttribute("VIP") then
		m += 0.25
	end
	local data = DataService.Get(player)
	if data and data.Rebirths then
		m += data.Rebirths * Config.Rebirth.BonusPerRebirth
	end
	return m
end

function GameService.GetWalkSpeed(player)
	local data = DataService.Get(player)
	local level = data and data.Levels.Speed or 0
	local speed = Config.Player.WalkSpeed + level * 2
	if player:GetAttribute("SuperSpeed") then
		speed += 8
	end
	return speed
end

function GameService.ApplyWalkSpeed(player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = GameService.GetWalkSpeed(player)
	end
end

function GameService.SyncAttributes(player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	player:SetAttribute("SpeedLevel", data.Levels.Speed)
	player:SetAttribute("CapacityLevel", data.Levels.Capacity)
	player:SetAttribute("SlotsLevel", data.Levels.Slots)
	player:SetAttribute("Capacity", GameService.GetCapacity(player))
	player:SetAttribute("Slots", GameService.GetSlots(player))
end

---------------------------------------------------------------------
-- Coins
---------------------------------------------------------------------
function GameService.GiveCoins(player, amount)
	local data = DataService.Get(player)
	if not data then
		return
	end
	data.Coins += amount
	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Coins") then
		stats.Coins.Value = math.floor(data.Coins)
	end
end

---------------------------------------------------------------------
-- Bases
---------------------------------------------------------------------
function GameService.AssignBase(player)
	for _, base in ipairs(bases) do
		if not base:GetAttribute("OwnerUserId") then
			base:SetAttribute("OwnerUserId", player.UserId)
			baseOf[player] = base
			return base
		end
	end
	return nil
end

function GameService.ReleaseBase(player)
	local base = baseOf[player]
	if base then
		base:SetAttribute("OwnerUserId", nil)
		local display = base:FindFirstChild("Display")
		if display then
			display:ClearAllChildren()
		end
		baseOf[player] = nil
	end
end

function GameService.RefreshBase(player)
	local base = baseOf[player]
	local data = DataService.Get(player)
	if not base or not data then
		return
	end

	local display = base:FindFirstChild("Display")
	if not display then
		display = Instance.new("Folder")
		display.Name = "Display"
		display.Parent = base
	end
	display:ClearAllChildren()
	player:SetAttribute("StoredCount", #data.Stored)

	local slots = GameService.GetSlots(player)
	for i = 1, math.min(#data.Stored, slots) do
		local slot = base:FindFirstChild("Slot" .. i)
		if slot and Config.Creatures[data.Stored[i]] then
			local model = GameService.MakeCreature(data.Stored[i])
			CreatureFX.Decorate(model, data.Stored[i], "display")
			for _, part in ipairs(model:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = true
					part.CanCollide = false
				end
			end
			model:PivotTo(slot.CFrame * CFrame.new(0, 3, 0))
			model.Parent = display
		end
	end
end

---------------------------------------------------------------------
-- Carrying
---------------------------------------------------------------------
function GameService.AddCarry(player, id)
	local list = carrying[player]
	if not list or #list >= GameService.GetCapacity(player) then
		return false
	end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return false
	end

	local model = GameService.MakeCreature(id)
	CreatureFX.Decorate(model, id, "carry")
	model:PivotTo(hrp.CFrame * CFrame.new(0, 2.5 + #list * 3.5, 0))
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.Anchored = false
			obj.CanCollide = false
			obj.Massless = true
		elseif obj:IsA("ProximityPrompt") then
			obj:Destroy()
		end
	end
	model.Parent = char

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hrp
	weld.Part1 = model.PrimaryPart
	weld.Parent = model.PrimaryPart

	table.insert(list, { Id = id, Model = model })
	player:SetAttribute("CarryCount", #list)
	return true
end

function GameService.ClearCarry(player)
	local list = carrying[player]
	if not list then
		return
	end
	for _, item in ipairs(list) do
		if item.Model then
			item.Model:Destroy()
		end
	end
	carrying[player] = {}
	player:SetAttribute("CarryCount", 0)
end

function GameService.Deposit(player)
	local list = carrying[player]
	local data = DataService.Get(player)
	if not list or not data or #list == 0 then
		return
	end

	local slots = GameService.GetSlots(player)
	local kept = {}
	local stored = 0
	for _, item in ipairs(list) do
		if #data.Stored < slots then
			table.insert(data.Stored, item.Id)
			item.Model:Destroy()
			stored += 1
		else
			table.insert(kept, item)
		end
	end

	carrying[player] = kept
	player:SetAttribute("CarryCount", #kept)

	if stored > 0 then
		GameService.RefreshBase(player)
		notify(player, "Stored " .. stored .. " creature(s) in your stall!")
		GameService.Sfx(player, "Deposit")
		local base = baseOf[player]
		local zone = base and base:FindFirstChild("DropZone")
		if zone then
			CreatureFX.Burst(zone.Position + Vector3.new(0, 3, 0), Color3.fromRGB(255, 200, 60))
		end
	end
	if #kept > 0 then
		notify(player, "Your stall is full! Buy more Slots in the shop.")
	end
end

---------------------------------------------------------------------
-- World creature spawning
---------------------------------------------------------------------
function GameService.SpawnWorldCreature(spawnPart, forcedId)
	local tier = spawnPart:GetAttribute("Tier") or 1
	local id = forcedId or GameService.RandomCreature(Config.TierRarities[tier])
	local info = Config.Creatures[id]
	local model = GameService.MakeCreature(id)
	CreatureFX.Decorate(model, id, "world")

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end
	model:PivotTo(spawnPart.CFrame * CFrame.new(0, 3, 0))

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Grab"
	prompt.ObjectText = info.Name .. " (" .. info.Rarity .. ")"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = model.PrimaryPart

	prompt.Triggered:Connect(function(player)
		if not model.Parent then
			return
		end
		if GameService.AddCarry(player, id) then
			GameService.Sfx(player, "Grab")
			model:Destroy()
		else
			notify(player, "Hands full! Run back to your stall.")
		end
	end)

	occupied[spawnPart] = true
	model.Destroying:Connect(function()
		occupied[spawnPart] = nil
	end)

	model.Parent = activeFolder
	if info.Rarity == "Legendary" then
		for _, p in ipairs(Players:GetPlayers()) do
			notify(p, "A LEGENDARY " .. info.Name .. " just appeared!")
			GameService.Sfx(p, "Legendary")
		end
	end
	Debris:AddItem(model, Config.Spawn.Lifetime)
end

function GameService.GetFreeSpawn(tier)
	local free = {}
	for _, part in ipairs(spawnPoints) do
		local partTier = part:GetAttribute("Tier") or 1
		if not occupied[part] and (not tier or partTier == tier) then
			table.insert(free, part)
		end
	end
	if #free == 0 then
		return nil
	end
	return free[rng:NextInteger(1, #free)]
end

function GameService.StartSpawning()
	task.spawn(function()
		for _, part in ipairs(spawnPoints) do
			if #activeFolder:GetChildren() < Config.Spawn.MaxActive then
				GameService.SpawnWorldCreature(part)
			end
		end
		while true do
			task.wait(Config.Spawn.Interval)
			if #activeFolder:GetChildren() < Config.Spawn.MaxActive then
				local free = {}
				for _, part in ipairs(spawnPoints) do
					if not occupied[part] then
						table.insert(free, part)
					end
				end
				if #free > 0 then
					GameService.SpawnWorldCreature(free[rng:NextInteger(1, #free)])
				end
			end
		end
	end)
end

---------------------------------------------------------------------
-- Income loop (stored creatures earn coins every second)
---------------------------------------------------------------------
function GameService.StartIncome()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local data = DataService.Get(player)
				if data then
					local perSecond = 0
					for _, id in ipairs(data.Stored) do
						local info = Config.Creatures[id]
						if info then
							perSecond += info.Income
						end
					end
					perSecond *= GameService.GetMultiplier(player)
					player:SetAttribute("IncomePerSec", perSecond)
					if perSecond > 0 then
						GameService.GiveCoins(player, perSecond)
					end
				end
			end
		end
	end)
end

---------------------------------------------------------------------
-- Player join / leave
---------------------------------------------------------------------
function GameService.OnPlayerAdded(player)
	local data = DataService.Load(player)
	if not data then
		return
	end
	carrying[player] = {}

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = math.floor(data.Coins)
	coins.Parent = stats
	stats.Parent = player

	-- game passes (IDs are added in M7; skipped while the table is missing or 0)
	for name, passId in pairs(Config.Passes or {}) do
		if passId ~= 0 then
			local ok, owns = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if ok and owns then
				player:SetAttribute(name, true)
			end
		end
	end

	GameService.AssignBase(player)
	GameService.SyncAttributes(player)
	GameService.RefreshBase(player)
	player:SetAttribute("CarryCount", 0)

	local function onCharacter(char)
		GameService.ClearCarry(player)
		local hum = char:WaitForChild("Humanoid")
		char:WaitForChild("HumanoidRootPart")
		hum.UseJumpPower = true
		hum.JumpPower = Config.Player.JumpPower
		hum.WalkSpeed = GameService.GetWalkSpeed(player)
		local base = baseOf[player]
		if base and base:FindFirstChild("Spawn") then
			task.wait()
			char:PivotTo(base.Spawn.CFrame * CFrame.new(0, 5, 0))
		end
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
end

function GameService.OnPlayerRemoving(player)
	GameService.ClearCarry(player)
	GameService.ReleaseBase(player)
	carrying[player] = nil
	DataService.Release(player)
end

---------------------------------------------------------------------
-- Guard catches a player (M4)
---------------------------------------------------------------------
function GameService.Caught(player)
	if not player or not player.Parent then
		return
	end
	GameService.ClearCarry(player)
	GameService.Sfx(player, "Caught")
	local char = player.Character
	local base = baseOf[player]
	if char and base and base:FindFirstChild("Spawn") then
		char:PivotTo(base.Spawn.CFrame * CFrame.new(0, 5, 0))
	end
	notify(player, "The Mall Guard caught you! You dropped everything.")
end

---------------------------------------------------------------------
-- Upgrades and codes (M5)
---------------------------------------------------------------------
function GameService.BuyUpgrade(player, name)
	if type(name) ~= "string" then
		return
	end
	local def = Config.Upgrades[name]
	local data = DataService.Get(player)
	if not def or not data then
		return
	end

	local level = data.Levels[name]
	if level >= def.Max then
		notify(player, name .. " is already max level!")
		return
	end
	local cost = Config.UpgradeCost(name, level)
	if data.Coins < cost then
		notify(player, "Not enough coins! Need " .. cost .. ".")
		return
	end

	data.Coins -= cost
	data.Levels[name] += 1
	GameService.GiveCoins(player, 0) -- refresh leaderboard value
	GameService.SyncAttributes(player)
	if name == "Speed" then
		GameService.ApplyWalkSpeed(player)
	end
	if name == "Slots" then
		GameService.RefreshBase(player)
	end
	GameService.Sfx(player, "Upgrade")
	notify(player, name .. " upgraded!")
end

function GameService.RedeemCode(player, code)
	if type(code) ~= "string" then
		return
	end
	code = string.upper((string.gsub(code, "%s", "")))
	local data = DataService.Get(player)
	local reward = Config.Codes[code]
	if not data or not reward then
		notify(player, "Invalid code.")
		return
	end
	if data.Codes[code] then
		notify(player, "You already used that code.")
		return
	end
	data.Codes[code] = true
	GameService.GiveCoins(player, reward)
	notify(player, "Code redeemed! +" .. reward .. " coins")
end

---------------------------------------------------------------------
-- Crates and passes (M7)
---------------------------------------------------------------------
function GameService.AddStored(player, id)
	local data = DataService.Get(player)
	if not data then
		return false
	end
	if #data.Stored < GameService.GetSlots(player) then
		table.insert(data.Stored, id)
		GameService.RefreshBase(player)
		return true
	end
	-- stall full: refund coins instead of losing the creature
	local refund = Config.Creatures[id].Income * 120
	GameService.GiveCoins(player, refund)
	notify(player, "Stall full! Converted to " .. refund .. " coins. Buy more Slots!")
	return false
end

function GameService.OpenCrate(player, crateName)
	local id = GameService.RandomCreature(Config.Crates[crateName])
	local info = Config.Creatures[id]
	GameService.AddStored(player, id)
	notify(player, "Crate opened: " .. info.Name .. " (" .. info.Rarity .. ")!")
end

function GameService.ApplyPass(player, name)
	player:SetAttribute(name, true)
	GameService.SyncAttributes(player)
	GameService.ApplyWalkSpeed(player)
	GameService.RefreshBase(player)
	notify(player, "Thank you! " .. name .. " is now active.")
end

return GameService
