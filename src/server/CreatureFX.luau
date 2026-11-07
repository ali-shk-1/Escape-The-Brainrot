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
	label.TextStrokeColor3 = Color3.fromRGB(20, 12, 40)
	label.TextStrokeTransparency = 0
	label.Parent = parent
	return label
end

-- mode: "world" (in the mall), "display" (in a stall), "carry" (on a player's head)
function CreatureFX.Decorate(model, id, mode)
	local info = Config.Creatures[id]
	local look = info and Config.Rarities[info.Rarity]
	local primary = model.PrimaryPart
	if not look or not primary then
		return
	end

	-- bigger = rarer
	local scale = look.Scale or 1
	if mode == "carry" then
		scale *= 0.7
	end
	model:ScaleTo(scale)
	local height = model:GetExtentsSize().Y

	-- replace the plain placeholder label with a styled name tag
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BillboardGui") then
			d:Destroy()
		end
	end

	if mode ~= "carry" then
		local tag = Instance.new("BillboardGui")
		tag.Name = "NameTag"
		tag.AlwaysOnTop = true
		tag.StudsOffset = Vector3.new(0, height / 2 + 1.8, 0)
		tag.Size = UDim2.fromOffset(220, mode == "world" and 64 or 34)
		tag.MaxDistance = mode == "world" and 90 or 50
		tag.Parent = primary

		if mode == "world" then
			makeLabel(tag, string.upper(info.Rarity), look.Color, 0, 0.28)
			makeLabel(tag, info.Name, Color3.new(1, 1, 1), 0.28, 0.42)
			makeLabel(tag, "+" .. info.Income .. " coins/s", Color3.fromRGB(74, 222, 128), 0.72, 0.28)
		else
			makeLabel(tag, "+" .. info.Income .. "/s", Color3.fromRGB(74, 222, 128), 0, 1)
		end
	end

	-- glowing outline (Rare and above, only in the mall to save performance)
	if mode == "world" and look.Outline then
		local highlight = Instance.new("Highlight")
		highlight.Adornee = model
		highlight.FillColor = look.Color
		highlight.FillTransparency = 0.75
		highlight.OutlineColor = look.Color
		highlight.OutlineTransparency = 0
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = model
	end

	-- colored glow light
	if mode ~= "carry" and (look.LightBrightness or 0) > 0 then
		local light = Instance.new("PointLight")
		light.Color = look.Color
		light.Brightness = look.LightBrightness * 1.5
		light.Range = 12 + scale * 5
		light.Shadows = false
		light.Parent = primary
	end

	-- sparkles (Epic and Legendary; in stalls only Legendary)
	local rate = look.Particles
	if mode == "carry" or (mode == "display" and info.Rarity ~= "Legendary") then
		rate = 0
	end
	if rate > 0 then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Color = ColorSequence.new(look.Color)
		sparkles.LightEmission = 1
		sparkles.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0),
		})
		sparkles.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		})
		sparkles.Lifetime = NumberRange.new(1, 1.8)
		sparkles.Speed = NumberRange.new(1, 3)
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
	burst.Color = ColorSequence.new(color, Color3.fromRGB(255, 77, 166))
	burst.LightEmission = 1
	burst.Speed = NumberRange.new(12, 22)
	burst.SpreadAngle = Vector2.new(180, 180)
	burst.Lifetime = NumberRange.new(0.6, 1.2)
	burst.Acceleration = Vector3.new(0, -20, 0)
	burst.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 0),
	})
	burst.Parent = part
	burst:Emit(30)

	Debris:AddItem(part, 2)
end

return CreatureFX
