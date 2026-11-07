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
-- Neon midnight mood
---------------------------------------------------------------------
Lighting.ClockTime = 0
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(80, 65, 130)
Lighting.OutdoorAmbient = Color3.fromRGB(80, 65, 130)
Lighting.ColorShift_Top = Color3.fromRGB(255, 120, 220)
Lighting.ExposureCompensation = 0.2
Lighting.EnvironmentDiffuseScale = 0.6
Lighting.EnvironmentSpecularScale = 0.6

local cc = getOrCreate(Lighting, "ColorCorrectionEffect", "MallColor")
cc.Brightness = 0.02
cc.Contrast = 0.18
cc.Saturation = 0.3
cc.TintColor = Color3.fromRGB(255, 238, 255)

local bloom = getOrCreate(Lighting, "BloomEffect", "MallBloom")
bloom.Intensity = 0.7
bloom.Size = 28
bloom.Threshold = 0.9

local atmosphere = getOrCreate(Lighting, "Atmosphere", "MallAtmosphere")
atmosphere.Density = 0.28
atmosphere.Offset = 0.2
atmosphere.Color = Color3.fromRGB(150, 110, 200)
atmosphere.Decay = Color3.fromRGB(70, 40, 120)
atmosphere.Glare = 0
atmosphere.Haze = 1.2

---------------------------------------------------------------------
-- Neon signs: any Part inside Workspace > NeonSigns glows with a light
---------------------------------------------------------------------
local signs = workspace:FindFirstChild("NeonSigns")
if signs then
	for _, part in ipairs(signs:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Neon
			local light = Instance.new("PointLight")
			light.Color = part.Color
			light.Range = 14
			light.Brightness = 1.5
			light.Parent = part
		end
	end
end

---------------------------------------------------------------------
-- Glowing, pulsing drop zones with a "DROP HERE" label
---------------------------------------------------------------------
local bases = workspace:WaitForChild("Bases")
for _, base in ipairs(bases:GetChildren()) do
	local zone = base:FindFirstChild("DropZone")
	if zone then
		zone.Material = Enum.Material.Neon
		zone.Color = Color3.fromRGB(74, 222, 128)
		zone.Transparency = 0.35

		local surface = Instance.new("SurfaceGui")
		surface.Face = Enum.NormalId.Top
		surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		surface.PixelsPerStud = 40
		surface.LightInfluence = 0
		surface.Parent = zone

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "DROP HERE"
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextStrokeTransparency = 0
		label.Parent = surface

		TweenService:Create(
			zone,
			TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.7 }
		):Play()
	end
end

---------------------------------------------------------------------
-- Guard: flashlight, turns red and shows "!" while chasing
---------------------------------------------------------------------
local guard = workspace:WaitForChild("Guard")
local head = guard:WaitForChild("Head", 5) or guard:WaitForChild("HumanoidRootPart")

local flashlight = Instance.new("SpotLight")
flashlight.Face = Enum.NormalId.Front
flashlight.Angle = 70
flashlight.Range = 45
flashlight.Brightness = 3
flashlight.Color = Color3.fromRGB(255, 240, 200)
flashlight.Parent = head

local alert = Instance.new("BillboardGui")
alert.Size = UDim2.fromOffset(60, 60)
alert.StudsOffset = Vector3.new(0, 3.5, 0)
alert.AlwaysOnTop = true
alert.Enabled = false
alert.Parent = head

local bang = Instance.new("TextLabel")
bang.Size = UDim2.fromScale(1, 1)
bang.BackgroundTransparency = 1
bang.Text = "!"
bang.TextScaled = true
bang.Font = Enum.Font.FredokaOne
bang.TextColor3 = Color3.fromRGB(255, 59, 92)
bang.TextStrokeTransparency = 0
bang.Parent = alert

guard:GetAttributeChangedSignal("Chasing"):Connect(function()
	local chasing = guard:GetAttribute("Chasing") == true
	alert.Enabled = chasing
	flashlight.Color = chasing and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 240, 200)
end)
