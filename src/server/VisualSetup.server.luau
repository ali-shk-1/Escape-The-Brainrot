local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

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
Lighting.ClockTime = 20.5 -- Dusk/night transition for rich deep indigo sky
Lighting.Brightness = 2.0
Lighting.OutdoorAmbient = Color3.fromRGB(110, 100, 160)
Lighting.Ambient = Color3.fromRGB(120, 110, 170) -- Raised so shadows are clearly visible
Lighting.ColorShift_Top = Color3.fromRGB(240, 180, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(40, 30, 70)
Lighting.ExposureCompensation = 0.35 -- Extra punch so nothing looks dingy
Lighting.EnvironmentDiffuseScale = 0.8
Lighting.EnvironmentSpecularScale = 0.8
Lighting.GlobalShadows = true

-- Color Correction: Crisp, rich saturation, clean whites
local cc = getOrCreate(Lighting, "ColorCorrectionEffect", "MallColor")
cc.Brightness = 0.04
cc.Contrast = 0.15
cc.Saturation = 0.35
cc.TintColor = Color3.fromRGB(255, 245, 255)

-- Bloom: Dreamy glow around neon parts without blinding haze
local bloom = getOrCreate(Lighting, "BloomEffect", "MallBloom")
bloom.Intensity = 0.6
bloom.Size = 22
bloom.Threshold = 0.85

-- Atmosphere: Soft cosmic purple haze
local atmosphere = getOrCreate(Lighting, "Atmosphere", "MallAtmosphere")
atmosphere.Density = 0.22 -- Lowered from 0.28 so far distances remain sharp
atmosphere.Offset = 0.15
atmosphere.Color = Color3.fromRGB(140, 120, 210)
atmosphere.Decay = Color3.fromRGB(60, 40, 110)
atmosphere.Glare = 0
atmosphere.Haze = 0.6 -- Lowered from 1.2 to eliminate foggy blur

---------------------------------------------------------------------
-- Mall Ceiling Lights (Adds ambient illumination along the concourse)
---------------------------------------------------------------------
local lightsFolder = getOrCreate(workspace, "Folder", "MallLighting")
if #lightsFolder:GetChildren() == 0 then
	local zPositions = { 150, 110, 70, 30, -10, -50, -90, -120 }
	for i, z in ipairs(zPositions) do
		local lightPart = Instance.new("Part")
		lightPart.Name = "CeilingLight_" .. i
		lightPart.Size = Vector3.new(20, 1, 4)
		lightPart.Position = Vector3.new(0, 28, z)
		lightPart.Anchored = true
		lightPart.CanCollide = false
		lightPart.CanQuery = false
		lightPart.CanTouch = false
		lightPart.Material = Enum.Material.Neon
		lightPart.Color = Color3.fromRGB(255, 240, 255)
		lightPart.Transparency = 0.2
		lightPart.Parent = lightsFolder

		local pointLight = Instance.new("PointLight")
		pointLight.Color = (z > 40 and Color3.fromRGB(255, 200, 160)) -- Warm for Plaza / Food
			or (z > -60 and Color3.fromRGB(160, 220, 255)) -- Cool Cyan for Tech
			or Color3.fromRGB(255, 170, 240) -- Neon Magenta for Vault
		pointLight.Brightness = 1.8
		pointLight.Range = 65
		pointLight.Shadows = false
		pointLight.Parent = lightPart
	end
end

---------------------------------------------------------------------
-- Neon signs: any Part inside Workspace > NeonSigns glows with a light
---------------------------------------------------------------------
local signs = workspace:FindFirstChild("NeonSigns")
if signs then
	for _, part in ipairs(signs:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Neon
			local light = part:FindFirstChildOfClass("PointLight") or Instance.new("PointLight")
			light.Color = part.Color
			light.Range = 16
			light.Brightness = 2.0
			light.Parent = part
		end
	end
end

---------------------------------------------------------------------
-- Glowing, pulsing drop zones with a "DROP HERE" label
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

			TweenService:Create(
				zone,
				TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Transparency = 0.6 }
			):Play()
		end
	end
end

---------------------------------------------------------------------
-- Guard: flashlight, turns red and shows "!" while chasing
---------------------------------------------------------------------
local guard = workspace:WaitForChild("Guard", 10)
if guard then
	local head = guard:WaitForChild("Head", 5) or guard:WaitForChild("HumanoidRootPart", 5)
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

		guard:GetAttributeChangedSignal("Chasing"):Connect(function()
			local chasing = guard:GetAttribute("Chasing") == true
			alert.Enabled = chasing
			flashlight.Color = chasing and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 245, 215)
		end)
	end
end
