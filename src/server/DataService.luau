local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- same store name as v1, so existing saves keep working (old saves are upgraded automatically)
local store = DataStoreService:GetDataStore("EscapeBrainrot_v1")

local VERSION = 2
local SESSION_ID = HttpService:GenerateGUID(false) -- unique per server
local LOCK_TIMEOUT = RunService:IsStudio() and 25 or 120 -- seconds before a dead server's lock is ignored

local DEFAULT = {
	Coins = 0,
	Stored = {},
	Levels = { Speed = 0, Capacity = 0, Slots = 0 },
	Codes = {},
	Receipts = {},
	Rebirths = 0,
	Daily = { LastClaim = 0, Streak = 0 },
	Tutorial = { Step = 1, Done = false, Gift = false },
}

local function deepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = type(v) == "table" and deepCopy(v) or v
	end
	return copy
end

-- fills in any missing fields so old saves keep working after updates
local function reconcile(data, default)
	for k, v in pairs(default) do
		if data[k] == nil then
			data[k] = type(v) == "table" and deepCopy(v) or v
		elseif type(v) == "table" and type(data[k]) == "table" then
			reconcile(data[k], v)
		end
	end
end

-- a lock is "free" if it is empty, ours, or older than LOCK_TIMEOUT (the other server crashed)
local function lockIsFree(wrapper)
	local lock = wrapper.Lock
	if not lock or lock.Id == "" or lock.Id == SESSION_ID then
		return true
	end
	return os.time() - (lock.Time or 0) > LOCK_TIMEOUT
end

local function newLock()
	return { Id = SESSION_ID, Time = os.time() }
end

local DataService = {}
local cache = {}  -- [player] = data table
local owned = {}  -- [player] = true when this server holds the lock (safe to save)

local function keyOf(player)
	return "Player_" .. player.UserId
end

-- tries once to take the lock and read the data. Returns ok, locked, data
local function tryLoad(key)
	local locked = false
	local result
	local ok = pcall(function()
		result = store:UpdateAsync(key, function(old)
			if old == nil then
				return { __v = VERSION, Data = {}, Lock = newLock() }
			end
			if type(old) ~= "table" then
				return { __v = VERSION, Data = {}, Lock = newLock() }
			end
			if old.__v ~= VERSION then
				-- v1 save (plain data table): wrap it
				return { __v = VERSION, Data = old, Lock = newLock() }
			end
			if not lockIsFree(old) then
				locked = true
				return nil -- cancel, another server is using this player
			end
			old.Lock = newLock()
			return old
		end)
	end)
	if ok and not locked and result then
		return true, false, result.Data
	end
	return ok, locked, nil
end

function DataService.Load(player)
	local key = keyOf(player)
	local data
	local wasLocked = false

	for _ = 1, 10 do
		local ok, locked, loaded = tryLoad(key)
		if ok and loaded then
			data = loaded
			break
		end
		wasLocked = locked
		task.wait(locked and 4 or 2)
		if not player.Parent then
			return nil
		end
	end

	if data then
		owned[player] = true
	else
		if RunService:IsStudio() then
			warn("DataStore unavailable or locked in Studio. Enable API Services in Game Settings > Security. Using temporary data (not saved).")
			data = {}
		elseif wasLocked then
			player:Kick("Your data is still in use by another server. Please rejoin in a minute.")
			return nil
		else
			player:Kick("Could not load your data. Please rejoin.")
			return nil
		end
	end

	reconcile(data, DEFAULT)
	cache[player] = data
	return data
end

function DataService.Get(player)
	return cache[player]
end

function DataService.IsLoaded(player)
	return cache[player] ~= nil
end

-- release = true also frees the lock (used when the player leaves or the server closes)
function DataService.Save(player, release)
	local data = cache[player]
	if not data or not owned[player] then
		return false
	end
	local key = keyOf(player)
	for _ = 1, 3 do
		local lostLock = false
		local ok = pcall(function()
			store:UpdateAsync(key, function(old)
				if type(old) == "table" and old.__v == VERSION and not lockIsFree(old) then
					lostLock = true
					return nil -- another server owns this player now, do not overwrite
				end
				local lock = release and { Id = "", Time = 0 } or newLock()
				return { __v = VERSION, Data = data, Lock = lock }
			end)
		end)
		if ok then
			if lostLock then
				warn("Save skipped for " .. player.Name .. ": another server holds the lock.")
				return false
			end
			return true
		end
		task.wait(2)
	end
	return false
end

function DataService.Release(player)
	DataService.Save(player, true)
	cache[player] = nil
	owned[player] = nil
end

-- autosave every minute (also refreshes the lock time)
task.spawn(function()
	while true do
		task.wait(60)
		for player in pairs(cache) do
			task.spawn(DataService.Save, player)
		end
	end
end)

-- save and unlock everyone when the server shuts down
game:BindToClose(function()
	local pending = 0
	for player in pairs(cache) do
		pending += 1
		task.spawn(function()
			DataService.Save(player, true)
			pending -= 1
		end)
	end
	local started = os.clock()
	while pending > 0 and os.clock() - started < 25 do
		task.wait(0.2)
	end
end)

return DataService
