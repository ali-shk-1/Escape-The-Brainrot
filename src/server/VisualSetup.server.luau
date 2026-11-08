local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local function getOrCreate(parent, className, name)
	local inst = parent:FindFirstChild(name)
	if not inst then
		inst = Instance.new(className)
		inst.Name = name
		inst.Parent = parent
	end
	return inst
end

---------------------------------------------------------------------
-- Tuned Neon Midnight Lighting (Crisp visibility + rich contrast)
---------------------------------------------------------------------
Lighting.ClockTime = 20.8
Lighting.Brightness = 2.2
Lighting.OutdoorAmbient = Color3.fromRGB(115, 105, 165)
Lighting.Ambient = Color3.fromRGB(125, 115, 175)
Lighting.ColorShift_Top = Color3.fromRGB(245, 185, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(45, 35, 75)
Lighting.ExposureCompensation = 0.38
Lighting.EnvironmentDiffuseScale = 0.85
Lighting.EnvironmentSpecularScale = 0.85
Lighting.GlobalShadows = true

-- Color Correction
local cc = getOrCreate(Lighting, "ColorCorrectionEffect", "MallColor")
cc.Brightness = 0.04
cc.Contrast = 0.16
cc.Saturation = 0.38
cc.TintColor = Color3.fromRGB(255, 248, 255)

-- Bloom
local bloom = getOrCreate(Lighting, "BloomEffect", "MallBloom")
bloom.Intensity = 0.65
bloom.Size = 24
bloom.Threshold = 0.85

-- Atmosphere
local atmosphere = getOrCreate(Lighting, "Atmosphere", "MallAtmosphere")
atmosphere.Density = 0.20
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(145, 125, 215)
atmosphere.Decay = Color3.fromRGB(65, 45, 115)
atmosphere.Glare = 0
atmosphere.Haze = 0.5

---------------------------------------------------------------------
-- Mall Ceiling Lights (Concourse illumination)
---------------------------------------------------------------------
local lightsFolder = getOrCreate(workspace, "Folder", "MallLighting")
if #lightsFolder:GetChildren() == 0 then
	local zPositions = { 150, 110, 70, 30, -10, -50, -90, -120 }
	for i, z in ipairs(zPositions) do
		local lightPart = Instance.new("Part")
		lightPart.Name = "CeilingLight_" .. i
		lightPart.Size = Vector3.new(24, 1.2, 4)
		lightPart.Position = Vector3.new(0, 28, z)
		lightPart.Anchored = true
		lightPart.CanCollide = false
		lightPart.CanQuery = false
		lightPart.CanTouch = false
		lightPart.Material = Enum.Material.Neon
		lightPart.Color = Color3.fromRGB(255, 245, 255)
		lightPart.Transparency = 0.15
		lightPart.Parent = lightsFolder

		local pointLight = Instance.new("PointLight")
		pointLight.Color = (z > 40 and Color3.fromRGB(255, 210, 170))
			or (z > -60 and Color3.fromRGB(170, 230, 255))
			or Color3.fromRGB(255, 180, 245)
		pointLight.Brightness = 2.0
		pointLight.Range = 70
		pointLight.Shadows = false
		pointLight.Parent = lightPart
	end
end

---------------------------------------------------------------------
-- Glowing Drop Zones with Vertical Light Beacons
---------------------------------------------------------------------
local bases = workspace:WaitForChild("Bases", 10)
if bases then
	for _, base in ipairs(bases:GetChildren()) do
		local zone = base:FindFirstChild("DropZone")
		if zone then
			zone.Material = Enum.Material.Neon
			zone.Color = Color3.fromRGB(74, 222, 128)
			zone.Transparency = 0.25

			local surface = zone:FindFirstChildOfClass("SurfaceGui")
			if not surface then
				surface = Instance.new("SurfaceGui")
				surface.Face = Enum.NormalId.Top
				surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
				surface.PixelsPerStud = 40
				surface.LightInfluence = 0
				surface.Parent = zone

				local label = Instance.new("TextLabel")
				label.Size = UDim2.fromScale(1, 1)
				label.BackgroundTransparency = 1
				label.Text = "⬇ DROP HERE ⬇"
				label.TextScaled = true
				label.Font = Enum.Font.FredokaOne
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextStrokeColor3 = Color3.fromRGB(20, 100, 40)
				label.TextStrokeTransparency = 0
				label.Parent = surface
			end

			-- Vertical neon beacon shooting into ceiling
			local beacon = zone:FindFirstChild("Beacon")
			if not beacon then
				beacon = Instance.new("Part")
				beacon.Name = "Beacon"
				beacon.Size = Vector3.new(4, 28, 4)
				beacon.Position = zone.Position + Vector3.new(0, 14, 0)
				beacon.Anchored = true
				beacon.CanCollide = false
				beacon.CanQuery = false
				beacon.CanTouch = false
				beacon.Material = Enum.Material.ForceField
				beacon.Color = Color3.fromRGB(74, 222, 128)
				beacon.Transparency = 0.75
				beacon.Parent = zone

				TweenService:Create(
					beacon,
					TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Transparency = 0.92 }
				):Play()
			end

			TweenService:Create(
				zone,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Transparency = 0.55 }
			):Play()
		end
	end
end

---------------------------------------------------------------------
-- Guard: Menacing Red Catch Radius & Flashlight
---------------------------------------------------------------------
local guard = workspace:WaitForChild("Guard", 10)
if guard then
	local head = guard:WaitForChild("Head", 5) or guard:WaitForChild("HumanoidRootPart", 5)
	local root = guard:WaitForChild("HumanoidRootPart", 5)

	if head then
		local flashlight = head:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
		flashlight.Face = Enum.NormalId.Front
		flashlight.Angle = 75
		flashlight.Range = 55
		flashlight.Brightness = 3.5
		flashlight.Color = Color3.fromRGB(255, 245, 215)
		flashlight.Parent = head

		local alert = head:FindFirstChild("AlertGui") or Instance.new("BillboardGui")
		alert.Name = "AlertGui"
		alert.Size = UDim2.fromOffset(60, 60)
		alert.StudsOffset = Vector3.new(0, 4, 0)
		alert.AlwaysOnTop = true
		alert.Enabled = false
		alert.Parent = head

		if not alert:FindFirstChildOfClass("TextLabel") then
			local bang = Instance.new("TextLabel")
			bang.Size = UDim2.fromScale(1, 1)
			bang.BackgroundTransparency = 1
			bang.Text = "!"
			bang.TextScaled = true
			bang.Font = Enum.Font.FredokaOne
			bang.TextColor3 = Color3.fromRGB(255, 59, 92)
			bang.TextStrokeColor3 = Color3.new(0, 0, 0)
			bang.TextStrokeTransparency = 0
			bang.Parent = alert
		end

		-- Floor Catch Radius Ring
		if root and not root:FindFirstChild("CatchRing") then
			local catchRing = Instance.new("Part")
			catchRing.Name = "CatchRing"
			catchRing.Shape = Enum.PartType.Cylinder
			catchRing.Size = Vector3.new(0.2, 10, 10) -- 5 stud radius
			catchRing.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
			catchRing.Material = Enum.Material.Neon
			catchRing.Color = Color3.fromRGB(255, 60, 60)
			catchRing.Transparency = 0.75
			catchRing.CanCollide = false
			catchRing.CanTouch = false
			catchRing.CanQuery = false
			catchRing.Parent = root

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = root
			weld.Part1 = catchRing
			weld.Parent = catchRing

			guard:GetAttributeChangedSignal("Chasing"):Connect(function()
				local chasing = guard:GetAttribute("Chasing") == true
				alert.Enabled = chasing
				flashlight.Color = chasing and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 245, 215)
				catchRing.Transparency = chasing and 0.45 or 0.82
			end)
		end
	end
end

---------------------------------------------------------------------
-- Player Sprint Trail Particles (When upgraded or SuperSpeed)
---------------------------------------------------------------------
local function setupPlayerTrails(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp or hrp:FindFirstChild("SpeedTrail") then return end

	local trailPart = Instance.new("ParticleEmitter")
	trailPart.Name = "SpeedTrail"
	trailPart.Rate = 0
	trailPart.Speed = NumberRange.new(2, 6)
	trailPart.Lifetime = NumberRange.new(0.3, 0.6)
	trailPart.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 0),
	})
	trailPart.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	trailPart.Color = ColorSequence.new(Color3.fromRGB(56, 224, 255), Color3.fromRGB(255, 77, 166))
	trailPart.LightEmission = 1
	trailPart.Parent = hrp

	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Running:Connect(function(speed)
			if speed > 22 then
				trailPart.Rate = 25
			else
				trailPart.Rate = 0
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(setupPlayerTrails)
	if p.Character then setupPlayerTrails(p.Character) end
end)
for _, p in ipairs(Players:GetPlayers()) do
	if p.Character then setupPlayerTrails(p.Character) end
	p.CharacterAdded:Connect(setupPlayerTrails)
end
