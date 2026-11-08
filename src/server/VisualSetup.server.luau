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
-- Sharp, High-Energy, Ultra-Bright Arcade Lighting
---------------------------------------------------------------------
-- Remove any blurry DepthOfField
local oldDof = Lighting:FindFirstChildOfClass("DepthOfFieldEffect")
if oldDof then oldDof:Destroy() end

Lighting.ClockTime = 14.5 -- Crisp, bright daylight interior balance
Lighting.Brightness = 3.2 -- High energy, bright & clean!
Lighting.GlobalShadows = true
Lighting.Technology = Enum.Technology.Future -- High-end crisp shadows

-- Pure, vivid ambient light so NO corner is dark
Lighting.OutdoorAmbient = Color3.fromRGB(180, 175, 210)
Lighting.Ambient = Color3.fromRGB(190, 185, 220)
Lighting.ColorShift_Top = Color3.fromRGB(255, 240, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(100, 90, 130)
Lighting.ExposureCompensation = 0.55 -- Extra punchy vibrancy
Lighting.EnvironmentDiffuseScale = 1.0
Lighting.EnvironmentSpecularScale = 1.0

-- Color Correction: Razor-sharp contrast, punchy saturation, clean whites
local cc = getOrCreate(Lighting, "ColorCorrectionEffect", "MallColor")
cc.Brightness = 0.05
cc.Contrast = 0.22 -- High contrast for punchy 3D edges
cc.Saturation = 0.45 -- Vivid, saturated colors
cc.TintColor = Color3.fromRGB(255, 255, 255)

-- Bloom: Crisp neon pop without any blinding milkiness
local bloom = getOrCreate(Lighting, "BloomEffect", "MallBloom")
bloom.Intensity = 0.5
bloom.Size = 16
bloom.Threshold = 0.92 -- Only true neon glows, rest is crystal sharp

-- Atmosphere: 100% Clear, zero fog/blur!
local atmosphere = getOrCreate(Lighting, "Atmosphere", "MallAtmosphere")
atmosphere.Density = 0.06 -- Ultra low density for crystal clarity
atmosphere.Offset = 0
atmosphere.Color = Color3.fromRGB(180, 160, 240)
atmosphere.Decay = Color3.fromRGB(100, 80, 160)
atmosphere.Glare = 0
atmosphere.Haze = 0 -- ZERO haze, pure sharpness!

---------------------------------------------------------------------
-- High-Power Overhead Stadium Floodlights (Even, Bright Mall Glow)
---------------------------------------------------------------------
local lightsFolder = getOrCreate(workspace, "Folder", "MallLighting")
lightsFolder:ClearAllChildren()

local zPositions = { 170, 130, 90, 50, 10, -30, -70, -110 }
for i, z in ipairs(zPositions) do
	local lightFixture = Instance.new("Part")
	lightFixture.Name = "StadiumLight_" .. i
	lightFixture.Size = Vector3.new(32, 1.5, 6)
	lightFixture.Position = Vector3.new(0, 28, z)
	lightFixture.Anchored = true
	lightFixture.CanCollide = false
	lightFixture.CanQuery = false
	lightFixture.CanTouch = false
	lightFixture.Material = Enum.Material.Neon
	lightFixture.Color = Color3.fromRGB(255, 255, 255)
	lightFixture.Transparency = 0
	lightFixture.Parent = lightsFolder

	-- Dual high-output surface lights casting downward
	local sl = Instance.new("SurfaceLight")
	sl.Face = Enum.NormalId.Bottom
	sl.Color = (z > 40 and Color3.fromRGB(255, 235, 210))
		or (z > -50 and Color3.fromRGB(210, 245, 255))
		or Color3.fromRGB(255, 210, 250)
	sl.Brightness = 3.6
	sl.Range = 75
	sl.Angle = 120
	sl.Shadows = false
	sl.Parent = lightFixture

	-- PointLight fill to eliminate any ceiling gloom
	local pl = Instance.new("PointLight")
	pl.Color = sl.Color
	pl.Brightness = 2.0
	pl.Range = 50
	pl.Shadows = false
	pl.Parent = lightFixture
end

---------------------------------------------------------------------
-- Vibrant Glowing Drop Zones & Beacons
---------------------------------------------------------------------
local bases = workspace:WaitForChild("Bases", 10)
if bases then
	for _, base in ipairs(bases:GetChildren()) do
		local zone = base:FindFirstChild("DropZone")
		if zone then
			zone.Material = Enum.Material.Neon
			zone.Color = Color3.fromRGB(50, 255, 120) -- Ultra vivid green
			zone.Transparency = 0.15

			local surface = zone:FindFirstChildOfClass("SurfaceGui")
			if not surface then
				surface = Instance.new("SurfaceGui")
				surface.Face = Enum.NormalId.Top
				surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
				surface.PixelsPerStud = 45
				surface.LightInfluence = 0
				surface.Parent = zone

				local label = Instance.new("TextLabel")
				label.Size = UDim2.fromScale(1, 1)
				label.BackgroundTransparency = 1
				label.Text = "⬇ DEPOSIT HERE ⬇"
				label.TextScaled = true
				label.Font = Enum.Font.FredokaOne
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextStrokeColor3 = Color3.fromRGB(0, 80, 20)
				label.TextStrokeTransparency = 0
				label.Parent = surface
			end

			local beacon = zone:FindFirstChild("Beacon")
			if not beacon then
				beacon = Instance.new("Part")
				beacon.Name = "Beacon"
				beacon.Size = Vector3.new(3, 27, 3)
				beacon.Position = zone.Position + Vector3.new(0, 13.5, 0)
				beacon.Anchored = true
				beacon.CanCollide = false
				beacon.CanQuery = false
				beacon.CanTouch = false
				beacon.Material = Enum.Material.ForceField
				beacon.Color = Color3.fromRGB(50, 255, 120)
				beacon.Transparency = 0.7
				beacon.Parent = zone
			end
		end
	end
end

---------------------------------------------------------------------
-- Big Gus: High-Visibility Searchlight & Threat Ring
---------------------------------------------------------------------
local guard = workspace:WaitForChild("Guard", 10)
if guard then
	local head = guard:WaitForChild("Head", 5) or guard:WaitForChild("HumanoidRootPart", 5)
	local root = guard:WaitForChild("HumanoidRootPart", 5)

	if head then
		local flashlight = head:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
		flashlight.Face = Enum.NormalId.Front
		flashlight.Angle = 80
		flashlight.Range = 65
		flashlight.Brightness = 5.0
		flashlight.Color = Color3.fromRGB(255, 250, 220)
		flashlight.Parent = head

		local alert = head:FindFirstChild("AlertGui") or Instance.new("BillboardGui")
		alert.Name = "AlertGui"
		alert.Size = UDim2.fromOffset(64, 64)
		alert.StudsOffset = Vector3.new(0, 4.2, 0)
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
			bang.TextColor3 = Color3.fromRGB(255, 40, 60)
			bang.TextStrokeColor3 = Color3.new(0, 0, 0)
			bang.TextStrokeTransparency = 0
			bang.Parent = alert
		end

		if root and not root:FindFirstChild("CatchRing") then
			local catchRing = Instance.new("Part")
			catchRing.Name = "CatchRing"
			catchRing.Shape = Enum.PartType.Cylinder
			catchRing.Size = Vector3.new(0.2, 10, 10)
			catchRing.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
			catchRing.Material = Enum.Material.Neon
			catchRing.Color = Color3.fromRGB(255, 40, 60)
			catchRing.Transparency = 0.7
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
				flashlight.Color = chasing and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(255, 250, 220)
				catchRing.Transparency = chasing and 0.35 or 0.75
			end)
		end
	end
end

---------------------------------------------------------------------
-- Sprint Trails
---------------------------------------------------------------------
local function setupPlayerTrails(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp or hrp:FindFirstChild("SpeedTrail") then return end

	local trailPart = Instance.new("ParticleEmitter")
	trailPart.Name = "SpeedTrail"
	trailPart.Rate = 0
	trailPart.Speed = NumberRange.new(3, 7)
	trailPart.Lifetime = NumberRange.new(0.25, 0.45)
	trailPart.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 0),
	})
	trailPart.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	trailPart.Color = ColorSequence.new(Color3.fromRGB(56, 224, 255), Color3.fromRGB(255, 77, 166))
	trailPart.LightEmission = 1
	trailPart.Parent = hrp

	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Running:Connect(function(speed)
			if speed > 22 then
				trailPart.Rate = 28
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
