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
-- Master Cinematic Mall Lighting (Vibrant, high-brightness arcade feel)
---------------------------------------------------------------------
Lighting.ClockTime = 21.2
Lighting.Brightness = 2.6
Lighting.OutdoorAmbient = Color3.fromRGB(135, 120, 185)
Lighting.Ambient = Color3.fromRGB(145, 130, 195)
Lighting.ColorShift_Top = Color3.fromRGB(255, 205, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(55, 45, 90)
Lighting.ExposureCompensation = 0.45 -- Crisp, bright visuals
Lighting.EnvironmentDiffuseScale = 1.0
Lighting.EnvironmentSpecularScale = 1.0
Lighting.GlobalShadows = true

-- Color Correction: Ultra-rich neon saturation & clean crisp whites
local cc = getOrCreate(Lighting, "ColorCorrectionEffect", "MallColor")
cc.Brightness = 0.05
cc.Contrast = 0.18
cc.Saturation = 0.42
cc.TintColor = Color3.fromRGB(255, 250, 255)

-- Bloom: Luxurious soft neon highlights without blinding flare
local bloom = getOrCreate(Lighting, "BloomEffect", "MallBloom")
bloom.Intensity = 0.75
bloom.Size = 24
bloom.Threshold = 0.88

-- DepthOfField: Subtle cinematic distance smoothing
local dof = getOrCreate(Lighting, "DepthOfFieldEffect", "MallDepthOfField")
dof.FarIntensity = 0.25
dof.FocusDistance = 25
dof.InFocusRadius = 60
dof.NearIntensity = 0

-- Atmosphere: Soft atmospheric purple-lavender glow
local atmosphere = getOrCreate(Lighting, "Atmosphere", "MallAtmosphere")
atmosphere.Density = 0.18
atmosphere.Offset = 0.12
atmosphere.Color = Color3.fromRGB(155, 135, 225)
atmosphere.Decay = Color3.fromRGB(75, 55, 125)
atmosphere.Glare = 0
atmosphere.Haze = 0.35 -- Crystal clear visibility

---------------------------------------------------------------------
-- Concourse Downward SurfaceLights (Broad, soft mall interior glow)
---------------------------------------------------------------------
local lightsFolder = getOrCreate(workspace, "Folder", "MallLighting")
if #lightsFolder:GetChildren() == 0 then
	local zPositions = { 160, 120, 80, 40, 0, -40, -80, -115 }
	for i, z in ipairs(zPositions) do
		local lightFixture = Instance.new("Part")
		lightFixture.Name = "CeilingLight_" .. i
		lightFixture.Size = Vector3.new(28, 1.2, 5)
		lightFixture.Position = Vector3.new(0, 28, z)
		lightFixture.Anchored = true
		lightFixture.CanCollide = false
		lightFixture.CanQuery = false
		lightFixture.CanTouch = false
		lightFixture.Material = Enum.Material.Neon
		lightFixture.Color = Color3.fromRGB(255, 250, 255)
		lightFixture.Transparency = 0.1
		lightFixture.Parent = lightsFolder

		-- Downward surface light casts wide, non-glaring ambient floor illumination
		local surfaceLight = Instance.new("SurfaceLight")
		surfaceLight.Face = Enum.NormalId.Bottom
		surfaceLight.Color = (z > 40 and Color3.fromRGB(255, 220, 180))
			or (z > -60 and Color3.fromRGB(180, 235, 255))
			or Color3.fromRGB(255, 190, 245)
		surfaceLight.Brightness = 2.4
		surfaceLight.Range = 60
		surfaceLight.Angle = 110
		surfaceLight.Shadows = false
		surfaceLight.Parent = lightFixture
	end
end

---------------------------------------------------------------------
-- Glowing Drop Zones with Vertical Light Beacons (Perfect Grid Alignment)
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
				beacon.Size = Vector3.new(3.5, 27, 3.5)
				beacon.Position = zone.Position + Vector3.new(0, 13.5, 0)
				beacon.Anchored = true
				beacon.CanCollide = false
				beacon.CanQuery = false
				beacon.CanTouch = false
				beacon.Material = Enum.Material.ForceField
				beacon.Color = Color3.fromRGB(74, 222, 128)
				beacon.Transparency = 0.78
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
-- Big Gus: Powerful Flashlight + Danger Catch Indicator
---------------------------------------------------------------------
local guard = workspace:WaitForChild("Guard", 10)
if guard then
	local head = guard:WaitForChild("Head", 5) or guard:WaitForChild("HumanoidRootPart", 5)
	local root = guard:WaitForChild("HumanoidRootPart", 5)

	if head then
		local flashlight = head:FindFirstChildOfClass("SpotLight") or Instance.new("SpotLight")
		flashlight.Face = Enum.NormalId.Front
		flashlight.Angle = 80
		flashlight.Range = 60
		flashlight.Brightness = 4.2
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
			catchRing.Size = Vector3.new(0.15, 10, 10)
			catchRing.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
			catchRing.Material = Enum.Material.Neon
			catchRing.Color = Color3.fromRGB(255, 60, 60)
			catchRing.Transparency = 0.78
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
				catchRing.Transparency = chasing and 0.42 or 0.82
			end)
		end
	end
end

---------------------------------------------------------------------
-- Player Sprint Trail Particles
---------------------------------------------------------------------
local function setupPlayerTrails(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp or hrp:FindFirstChild("SpeedTrail") then return end

	local trailPart = Instance.new("ParticleEmitter")
	trailPart.Name = "SpeedTrail"
	trailPart.Rate = 0
	trailPart.Speed = NumberRange.new(2, 6)
	trailPart.Lifetime = NumberRange.new(0.3, 0.5)
	trailPart.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 0),
	})
	trailPart.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	trailPart.Color = ColorSequence.new(Color3.fromRGB(56, 224, 255), Color3.fromRGB(255, 77, 166))
	trailPart.LightEmission = 1
	trailPart.Parent = hrp

	local hum = char:WaitForChild("Humanoid", 5)
	if hum then
		hum.Running:Connect(function(speed)
			if speed > 22 then
				trailPart.Rate = 22
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
