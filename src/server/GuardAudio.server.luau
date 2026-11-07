local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local guard = workspace:WaitForChild("Guard")
local humanoid = guard:WaitForChild("Humanoid")
local root = guard:WaitForChild("HumanoidRootPart")

local function make3DSound(name, id, looped, volume, maxDistance)
	if not id or id == 0 then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = "rbxassetid://" .. id
	sound.Looped = looped
	sound.Volume = volume
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = 8
	sound.RollOffMaxDistance = maxDistance
	sound.Parent = root
	return sound
end

local footsteps = make3DSound("GuardFootsteps", Config.Sounds.Footstep, true, 0.7, 70)
local whistle = make3DSound("GuardWhistle", Config.Sounds.Whistle, false, 0.8, 90)

-- footsteps play while he is moving, faster when he runs
if footsteps then
	humanoid.Running:Connect(function(speed)
		if speed > 0.5 then
			footsteps.PlaybackSpeed = math.clamp(speed / 12, 0.8, 1.6)
			if not footsteps.IsPlaying then
				footsteps:Play()
			end
		else
			footsteps:Pause()
		end
	end)
end

-- whistle when he starts chasing
if whistle then
	guard:GetAttributeChangedSignal("Chasing"):Connect(function()
		if guard:GetAttribute("Chasing") == true then
			whistle:Play()
		end
	end)
end
