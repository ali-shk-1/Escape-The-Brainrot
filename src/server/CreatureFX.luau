local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local CreatureFX = {}

local FONT = Enum.Font.FredokaOne

local function makeLabel(parent, text, color, y, height)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, height)
	label.Position = UDim2.fromScale(0, y)
	label.Font = FONT
	label.TextScaled = true
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeColor3 = Color3.fromRGB(15, 10, 30)
	label.TextStrokeTransparency = 0
	label.Parent = parent
	return label
end

-- Distinct physical silhouettes & materials per creature
local CREATURE_SHAPES = {
	SirNoodleSneakers     = { Mesh = "Cylinder", Material = Enum.Material.Neon, SizeMult = Vector3.new(0.9, 1.4, 0.9) },
	BonkoBananaBoots      = { Mesh = "Block",    Material = Enum.Material.SmoothPlastic, SizeMult = Vector3.new(1.1, 1.2, 0.9) },
	CaptainToastini       = { Mesh = "Block",    Material = Enum.Material.SmoothPlastic, SizeMult = Vector3.new(1.3, 1.3, 0.5) },
	SprinkleGoblin        = { Mesh = "Ball",     Material = Enum.Material.Neon, SizeMult = Vector3.new(1.1, 1.1, 1.1) },
	WobbloBubbleMonk      = { Mesh = "Cylinder", Material = Enum.Material.Glass, SizeMult = Vector3.new(1.2, 1.5, 1.2) },
	DiscoDumpling         = { Mesh = "Ball",     Material = Enum.Material.Foil, SizeMult = Vector3.new(1.3, 1.0, 1.3) },
	TurboTacoWizard       = { Mesh = "Block",    Material = Enum.Material.Neon, SizeMult = Vector3.new(1.4, 0.9, 1.2) },
	CheesePharaoh         = { Mesh = "Block",    Material = Enum.Material.Neon, SizeMult = Vector3.new(1.2, 1.6, 1.2) },
	MegaPickleDuchess     = { Mesh = "Cylinder", Material = Enum.Material.Neon, SizeMult = Vector3.new(1.1, 2.0, 1.1) },
	GalacticSpaghettiKing = { Mesh = "Ball",     Material = Enum.Material.ForceField, SizeMult = Vector3.new(1.5, 1.5, 1.5) },
	-- Event creatures
	GlitchyGelatoGhost   = { Mesh = "Ball",     Material = Enum.Material.ForceField, SizeMult = Vector3.new(1.4, 1.6, 1.4) },
	NinjaNuggetSensei    = { Mesh = "Block",    Material = Enum.Material.Neon, SizeMult = Vector3.new(1.3, 1.1, 1.3) },
	CosmicCorndogCaptain = { Mesh = "Cylinder", Material = Enum.Material.Neon, SizeMult = Vector3.new(1.0, 2.2, 1.0) },
	HoloHotdogHero       = { Mesh = "Cylinder", Material = Enum.Material.ForceField, SizeMult = Vector3.new(1.1, 2.3, 1.1) },
}

-- mode: "world" (in the mall), "display" (in a stall), "carry" (on a player's head)
function CreatureFX.Decorate(model, id, mode)
	local info = Config.Creatures[id]
	local look = info and Config.Rarities[info.Rarity]
	local primary = model.PrimaryPart
	if not look or not primary then
		return
	end

	-- Shape customization
	local shape = CREATURE_SHAPES[id]
	if shape then
		primary.Material = shape.Material
		if shape.SizeMult then
			primary.Size = Vector3.new(3, 3, 3) * shape.SizeMult
		end
		if shape.Mesh == "Ball" and primary:IsA("Part") then
			primary.Shape = Enum.PartType.Ball
		elseif shape.Mesh == "Cylinder" and primary:IsA("Part") then
			primary.Shape = Enum.PartType.Cylinder
		end
	end

	-- Scale
	local scale = look.Scale or 1
	if mode == "carry" then
		scale *= 0.65
	end
	model:ScaleTo(scale)
	local height = model:GetExtentsSize().Y

	-- Clean up old guis
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BillboardGui") then
			d:Destroy()
		end
	end

	-- Name Tag
	if mode ~= "carry" then
		local tag = Instance.new("BillboardGui")
		tag.Name = "NameTag"
		tag.AlwaysOnTop = true
		tag.StudsOffset = Vector3.new(0, height / 2 + 1.8, 0)
		tag.Size = UDim2.fromOffset(240, mode == "world" and 70 or 38)
		tag.MaxDistance = mode == "world" and 95 or 55
		tag.Parent = primary

		if mode == "world" then
			makeLabel(tag, "★ " .. string.upper(info.Rarity) .. " ★", look.Color, 0, 0.28)
			makeLabel(tag, info.Name, Color3.new(1, 1, 1), 0.28, 0.42)
			makeLabel(tag, "💰 +" .. info.Income .. " coins/s", Color3.fromRGB(74, 222, 128), 0.72, 0.28)
		else
			makeLabel(tag, "+" .. info.Income .. "/s", Color3.fromRGB(74, 222, 128), 0, 1)
		end
	end

	-- Glowing outline (Rare and above)
	if mode == "world" and look.Outline then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = model
		highlight.FillColor = look.Color
		highlight.FillTransparency = 0.7
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 0.1
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = model
	end

	-- Colored glow light
	if mode ~= "carry" and (look.LightBrightness or 0) > 0 then
		local light = Instance.new("PointLight")
		light.Color = look.Color
		light.Brightness = look.LightBrightness * 1.6
		light.Range = 14 + scale * 5
		light.Shadows = false
		light.Parent = primary
	end

	-- Pedestal / Orbit ring for Rare and above in World
	if mode == "world" and (info.Rarity == "Rare" or info.Rarity == "Epic" or info.Rarity == "Legendary" or info.Rarity == "Event") then
		local ring = Instance.new("Part")
		ring.Name = "AuraRing"
		ring.Size = Vector3.new(5 * scale, 0.2, 5 * scale)
		ring.Material = Enum.Material.Neon
		ring.Color = look.Color
		ring.Transparency = 0.5
		ring.CanCollide = false
		ring.Anchored = false
		ring.CFrame = primary.CFrame * CFrame.new(0, -height/2, 0)
		ring.Parent = model

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = primary
		weld.Part1 = ring
		weld.Parent = ring
	end

	-- Sparkles (Epic and Legendary; in stalls only Legendary & Event)
	local rate = look.Particles
	if mode == "carry" or (mode == "display" and info.Rarity ~= "Legendary" and info.Rarity ~= "Event") then
		rate = 0
	end
	if rate > 0 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, look.Color),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
		})
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(1, 0),
		})
		sparkles.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		sparkles.Lifetime = NumberRange.new(1, 2)
		sparkles.Speed = NumberRange.new(1, 4)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Rate = rate
		sparkles.Parent = primary
	end

	-- tags so the client can float/spin them
	if mode == "world" then
		CollectionService:AddTag(model, "FloatingCreature")
	elseif mode == "display" then
		CollectionService:AddTag(model, "DisplayCreature")
	end
end

-- confetti-style burst, used when you drop creatures in your stall
function CreatureFX.Burst(position, color)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = Vector3.one
	part.Position = position
	part.Parent = workspace

	local burst = Instance.new("ParticleEmitter")
	burst.Rate = 0
	burst.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 77, 166)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 224, 255)),
	})
	burst.LightEmission = 1
	burst.Speed = NumberRange.new(15, 26)
	burst.SpreadAngle = Vector2.new(180, 180)
	burst.Lifetime = NumberRange.new(0.6, 1.4)
	burst.Acceleration = Vector3.new(0, -26, 0)
	burst.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.1),
		NumberSequenceKeypoint.new(1, 0),
	})
	burst.Parent = part
	burst:Emit(45)

	Debris:AddItem(part, 2)
end

return CreatureFX
