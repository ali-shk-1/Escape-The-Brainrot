local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local MUSIC = Config.Music
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Sound group (one volume knob for all music)
---------------------------------------------------------------------
local group = Instance.new("SoundGroup")
group.Name = "MusicGroup"
group.Volume = MUSIC.MasterVolume
group.Parent = SoundService

local sounds = {} -- [trackName] = Sound
for name, info in pairs(MUSIC.Tracks) do
	if info.Id and info.Id ~= 0 then
		local sound = Instance.new("Sound")
		sound.Name = name
		sound.SoundId = "rbxassetid://" .. info.Id
		sound.Looped = true
		sound.Volume = 0
		sound.SoundGroup = group
		sound.Parent = SoundService
		sounds[name] = sound
	end
end

if next(sounds) == nil then
	warn("MusicController: no track IDs set in Config.Music.Tracks, so no music will play.")
end

---------------------------------------------------------------------
-- Crossfade
---------------------------------------------------------------------
local current = nil

local function resolveTrack(name)
	if sounds[name] then
		return name
	end
	if sounds.Base then
		return "Base"
	end
	return nil
end

local function playTrack(requested)
	local name = resolveTrack(requested)
	if name == current then
		return
	end
	current = name

	local fade = (requested == "Chase") and MUSIC.ChaseFadeTime or MUSIC.FadeTime
	for trackName, sound in pairs(sounds) do
		if trackName == name then
			if not sound.IsPlaying then
				sound:Play()
			end
			TweenService:Create(sound, TweenInfo.new(fade), { Volume = MUSIC.Tracks[trackName].Volume }):Play()
		else
			TweenService:Create(sound, TweenInfo.new(fade), { Volume = 0 }):Play()
			task.delay(fade + 0.2, function()
				if current ~= trackName and sound.IsPlaying then
					sound:Pause()
				end
			end)
		end
	end
end

---------------------------------------------------------------------
-- Which zone is the player in?
---------------------------------------------------------------------
local zonesFolder = workspace:FindFirstChild("MusicZones")

local function insidePart(part, position)
	local rel = part.CFrame:PointToObjectSpace(position)
	local half = part.Size / 2
	return math.abs(rel.X) <= half.X and math.abs(rel.Y) <= half.Y and math.abs(rel.Z) <= half.Z
end

local function zoneTrack(position)
	if not zonesFolder then
		return "Base"
	end
	local bestTrack = "Base"
	local bestPriority = -math.huge
	for _, zone in ipairs(zonesFolder:GetChildren()) do
		if zone:IsA("BasePart") and insidePart(zone, position) then
			local priority = zone:GetAttribute("Priority") or 0
			if priority > bestPriority then
				bestPriority = priority
				bestTrack = zone:GetAttribute("Track") or zone.Name
			end
		end
	end
	return bestTrack
end

---------------------------------------------------------------------
-- Is the guard chasing me?
---------------------------------------------------------------------
local function isChased(position)
	local guard = workspace:FindFirstChild("Guard")
	if not guard or guard:GetAttribute("Chasing") ~= true then
		return false
	end
	local guardRoot = guard:FindFirstChild("HumanoidRootPart")
	if not guardRoot then
		return false
	end
	return (guardRoot.Position - position).Magnitude <= MUSIC.ChaseRange
end

---------------------------------------------------------------------
-- Main loop (checks twice a second, very cheap)
---------------------------------------------------------------------
local lastChase = -math.huge

task.spawn(function()
	while true do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local now = os.clock()
			if isChased(hrp.Position) then
				lastChase = now
			end
			if now - lastChase <= MUSIC.ChaseHold then
				playTrack("Chase")
			else
				playTrack(zoneTrack(hrp.Position))
			end
		else
			playTrack("Base")
		end
		task.wait(0.5)
	end
end)

---------------------------------------------------------------------
-- Ducking: music dips while stings and effects play
---------------------------------------------------------------------
local duckToken = 0
local duckNames = { Caught = true, Legendary = true, Upgrade = true, Deposit = true }

local function duck()
	duckToken += 1
	local myToken = duckToken
	TweenService:Create(group, TweenInfo.new(0.15), { Volume = MUSIC.MasterVolume * MUSIC.DuckVolume }):Play()
	task.delay(MUSIC.DuckTime, function()
		if myToken == duckToken then
			TweenService:Create(group, TweenInfo.new(0.8), { Volume = MUSIC.MasterVolume }):Play()
		end
	end)
end

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local sfx = remotes:WaitForChild("Sfx", 15)
	if sfx then
		sfx.OnClientEvent:Connect(function(name)
			if duckNames[name] and not player:GetAttribute("MusicMuted") then
				duck()
			end
		end)
	end
end)

---------------------------------------------------------------------
-- Mute button (small round button under the SHOP button, left side)
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "MusicToggle"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.AnchorPoint = Vector2.new(0, 0.5)
button.Position = UDim2.new(0, 10, 0.5, 64)
button.Size = UDim2.fromOffset(48, 48)
button.BackgroundColor3 = Color3.fromRGB(36, 30, 72)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 24
button.Text = "🎵"
button.AutoButtonColor = true
button.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = button

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(56, 224, 255)
outline.Thickness = 2
outline.Parent = button

local function applyMute()
	local muted = player:GetAttribute("MusicMuted") == true
	duckToken += 1
	group.Volume = muted and 0 or MUSIC.MasterVolume
	button.Text = muted and "🔇" or "🎵"
	outline.Color = muted and Color3.fromRGB(255, 59, 92) or Color3.fromRGB(56, 224, 255)
end

button.Activated:Connect(function()
	player:SetAttribute("MusicMuted", not (player:GetAttribute("MusicMuted") == true))
	applyMute()
end)
applyMute()
