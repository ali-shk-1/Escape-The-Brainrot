-- CreatureModelsBuilder: Builds all 10 distinct 3D stylized character models
-- and places them into ServerStorage > Creatures automatically!
-- Paste into Studio Command Bar (View > Command Bar) while stopped, then save the place.

local ServerStorage = game:GetService("ServerStorage")

local creaturesFolder = ServerStorage:FindFirstChild("Creatures")
if not creaturesFolder then
	creaturesFolder = Instance.new("Folder")
	creaturesFolder.Name = "Creatures"
	creaturesFolder.Parent = ServerStorage
end

local function makePart(parent, name, size, offset, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = parent.PrimaryPart.CFrame * CFrame.new(offset)
	p.Parent = parent

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = parent.PrimaryPart
	weld.Part1 = p
	weld.Parent = p
	return p
end

local function createBaseModel(name, mainSize, mainColor, mainMaterial, mainShape)
	local existing = creaturesFolder:FindFirstChild(name)
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = mainSize
	body.Color = mainColor
	body.Material = mainMaterial or Enum.Material.SmoothPlastic
	if mainShape then body.Shape = mainShape end
	body.Anchored = false
	body.CanCollide = false
	body.CanTouch = false
	body.CanQuery = false
	body.Massless = true
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.Position = Vector3.new(0, 10, 0)
	body.Parent = model
	model.PrimaryPart = body

	return model
end

---------------------------------------------------------------------
-- 1. Sir Noodle Sneakers (Ramen Cup + Noodles + Red Sneakers)
---------------------------------------------------------------------
local c1 = createBaseModel("SirNoodleSneakers", Vector3.new(2.4, 2.8, 2.4), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
c1.PrimaryPart.CFrame *= CFrame.Angles(0, 0, math.rad(90))
makePart(c1, "CupStripe", Vector3.new(2.45, 0.5, 2.45), Vector3.new(0, 0.4, 0), Color3.fromRGB(220, 40, 40), Enum.Material.Neon, Enum.PartType.Cylinder)
makePart(c1, "Noodles", Vector3.new(2.2, 0.8, 2.2), Vector3.new(0, 1.4, 0), Color3.fromRGB(255, 215, 90), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
-- Sneakers
makePart(c1, "SneakerL", Vector3.new(0.9, 0.7, 1.6), Vector3.new(-0.8, -1.6, 0.2), Color3.fromRGB(220, 30, 30), Enum.Material.SmoothPlastic)
makePart(c1, "SneakerR", Vector3.new(0.9, 0.7, 1.6), Vector3.new(0.8, -1.6, 0.2), Color3.fromRGB(220, 30, 30), Enum.Material.SmoothPlastic)
makePart(c1, "SoleL", Vector3.new(0.95, 0.2, 1.65), Vector3.new(-0.8, -1.95, 0.2), Color3.fromRGB(255, 255, 255))
makePart(c1, "SoleR", Vector3.new(0.95, 0.2, 1.65), Vector3.new(0.8, -1.95, 0.2), Color3.fromRGB(255, 255, 255))
-- Eyes
makePart(c1, "EyeL", Vector3.new(0.4, 0.4, 0.1), Vector3.new(-0.5, 0.3, 1.25), Color3.fromRGB(20, 20, 20), Enum.Material.Neon)
makePart(c1, "EyeR", Vector3.new(0.4, 0.4, 0.1), Vector3.new(0.5, 0.3, 1.25), Color3.fromRGB(20, 20, 20), Enum.Material.Neon)
c1.Parent = creaturesFolder

---------------------------------------------------------------------
-- 2. Bonko Banana Boots (Banana + Giant Black Combat Boots)
---------------------------------------------------------------------
local c2 = createBaseModel("BonkoBananaBoots", Vector3.new(1.8, 3.4, 1.8), Color3.fromRGB(255, 220, 40), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
makePart(c2, "BananaTip", Vector3.new(0.6, 0.8, 0.6), Vector3.new(0, 2.0, 0), Color3.fromRGB(70, 140, 40), Enum.Material.SmoothPlastic)
makePart(c2, "BootL", Vector3.new(1.1, 1.1, 1.9), Vector3.new(-0.9, -1.8, 0.3), Color3.fromRGB(25, 25, 30))
makePart(c2, "BootR", Vector3.new(1.1, 1.1, 1.9), Vector3.new(0.9, -1.8, 0.3), Color3.fromRGB(25, 25, 30))
makePart(c2, "EyeL", Vector3.new(0.35, 0.35, 0.1), Vector3.new(-0.4, 0.5, 0.95), Color3.fromRGB(10, 10, 10))
makePart(c2, "EyeR", Vector3.new(0.35, 0.35, 0.1), Vector3.new(0.4, 0.5, 0.95), Color3.fromRGB(10, 10, 10))
c2.Parent = creaturesFolder

---------------------------------------------------------------------
-- 3. Captain Toastini (Golden Toast + Butter Pat + Pirate Hat)
---------------------------------------------------------------------
local c3 = createBaseModel("CaptainToastini", Vector3.new(3.0, 3.0, 0.9), Color3.fromRGB(225, 175, 95), Enum.Material.SmoothPlastic)
makePart(c3, "CrustTop", Vector3.new(3.1, 0.3, 1.0), Vector3.new(0, 1.55, 0), Color3.fromRGB(160, 95, 40))
makePart(c3, "Butter", Vector3.new(0.9, 0.3, 0.9), Vector3.new(-0.4, 0.6, 0.55), Color3.fromRGB(255, 240, 90), Enum.Material.Neon)
-- Pirate Hat
makePart(c3, "HatBrim", Vector3.new(3.6, 0.4, 2.2), Vector3.new(0, 1.7, 0), Color3.fromRGB(25, 20, 35))
makePart(c3, "HatCrown", Vector3.new(2.0, 1.2, 1.5), Vector3.new(0, 2.3, 0), Color3.fromRGB(25, 20, 35))
makePart(c3, "HatSkull", Vector3.new(0.6, 0.6, 0.1), Vector3.new(0, 2.3, 0.8), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
-- Eyes & Eyepatch
makePart(c3, "Eye", Vector3.new(0.4, 0.4, 0.1), Vector3.new(0.6, 0.2, 0.5), Color3.fromRGB(10, 10, 10))
makePart(c3, "EyePatch", Vector3.new(0.55, 0.55, 0.1), Vector3.new(-0.6, 0.2, 0.5), Color3.fromRGB(15, 15, 20))
c3.Parent = creaturesFolder

---------------------------------------------------------------------
-- 4. Sprinkle Goblin (Frosted Donut + Rainbow Sprinkles + Horns)
---------------------------------------------------------------------
local c4 = createBaseModel("SprinkleGoblin", Vector3.new(3.2, 1.6, 3.2), Color3.fromRGB(215, 160, 100), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
makePart(c4, "Frosting", Vector3.new(3.0, 0.4, 3.0), Vector3.new(0, 0.9, 0), Color3.fromRGB(255, 105, 180), Enum.Material.Neon, Enum.PartType.Cylinder)
-- Sprinkles
local sColors = { Color3.fromRGB(56, 224, 255), Color3.fromRGB(255, 215, 0), Color3.fromRGB(74, 222, 128), Color3.fromRGB(255, 255, 255) }
for i = 1, 6 do
	local angle = i * (math.pi / 3)
	local sx = math.cos(angle) * 0.9
	local sz = math.sin(angle) * 0.9
	makePart(c4, "Sprinkle_" .. i, Vector3.new(0.3, 0.15, 0.6), Vector3.new(sx, 1.15, sz), sColors[(i % #sColors) + 1], Enum.Material.Neon)
end
-- Goblin Horns
makePart(c4, "HornL", Vector3.new(0.5, 0.9, 0.5), Vector3.new(-1.1, 1.4, 0), Color3.fromRGB(180, 50, 220), Enum.Material.Neon)
makePart(c4, "HornR", Vector3.new(0.5, 0.9, 0.5), Vector3.new(1.1, 1.4, 0), Color3.fromRGB(180, 50, 220), Enum.Material.Neon)
c4.Parent = creaturesFolder

---------------------------------------------------------------------
-- 5. WobbloBubbleMonk (Boba Milk Tea Cup + Tapioca Pearls + Straw)
---------------------------------------------------------------------
local c5 = createBaseModel("WobbloBubbleMonk", Vector3.new(2.6, 3.2, 2.6), Color3.fromRGB(235, 195, 155), Enum.Material.Glass, Enum.PartType.Cylinder)
makePart(c5, "CupLid", Vector3.new(2.8, 0.4, 2.8), Vector3.new(0, 1.7, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
makePart(c5, "BobaStraw", Vector3.new(0.4, 2.2, 0.4), Vector3.new(0.4, 2.4, 0), Color3.fromRGB(255, 90, 160), Enum.Material.Neon)
-- Tapioca pearls
for i = 1, 5 do
	local angle = i * (math.pi * 2 / 5)
	makePart(c5, "Pearl_" .. i, Vector3.new(0.65, 0.65, 0.65), Vector3.new(math.cos(angle) * 0.8, -1.1, math.sin(angle) * 0.8), Color3.fromRGB(30, 20, 25), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
end
c5.Parent = creaturesFolder

---------------------------------------------------------------------
-- 6. Disco Dumpling (Foil Dumpling + Star Sunglasses)
---------------------------------------------------------------------
local c6 = createBaseModel("DiscoDumpling", Vector3.new(3.0, 2.2, 3.0), Color3.fromRGB(240, 240, 255), Enum.Material.Foil, Enum.PartType.Ball)
makePart(c6, "DumplingPleats", Vector3.new(1.2, 0.6, 1.2), Vector3.new(0, 1.15, 0), Color3.fromRGB(255, 255, 255), Enum.Material.SmoothPlastic)
-- Star Sunglasses
makePart(c6, "SunGlasses", Vector3.new(2.4, 0.7, 0.3), Vector3.new(0, 0.2, 1.4), Color3.fromRGB(20, 20, 30), Enum.Material.Glass)
makePart(c6, "StarL", Vector3.new(0.8, 0.8, 0.1), Vector3.new(-0.7, 0.2, 1.56), Color3.fromRGB(255, 220, 40), Enum.Material.Neon)
makePart(c6, "StarR", Vector3.new(0.8, 0.8, 0.1), Vector3.new(0.7, 0.2, 1.56), Color3.fromRGB(255, 220, 40), Enum.Material.Neon)
c6.Parent = creaturesFolder

---------------------------------------------------------------------
-- 7. Turbo Taco Wizard (Taco Shell + Fillings + Wizard Hat)
---------------------------------------------------------------------
local c7 = createBaseModel("TurboTacoWizard", Vector3.new(3.2, 1.9, 1.4), Color3.fromRGB(235, 175, 75), Enum.Material.SmoothPlastic)
makePart(c7, "Lettuce", Vector3.new(3.0, 0.5, 0.9), Vector3.new(0, 0.9, 0), Color3.fromRGB(70, 205, 70), Enum.Material.Neon)
makePart(c7, "Salsa", Vector3.new(2.6, 0.4, 0.7), Vector3.new(0, 1.1, 0), Color3.fromRGB(220, 40, 40), Enum.Material.Neon)
-- Wizard Hat
makePart(c7, "HatBrim", Vector3.new(2.4, 0.3, 2.4), Vector3.new(0, 1.35, 0), Color3.fromRGB(90, 40, 160), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
makePart(c7, "HatCone", Vector3.new(1.3, 2.0, 1.3), Vector3.new(0, 2.3, 0), Color3.fromRGB(110, 50, 190), Enum.Material.Neon)
c7.Parent = creaturesFolder

---------------------------------------------------------------------
-- 8. Cheese Pharaoh (Swiss Cheese Wedge + Pharaoh Headdress)
---------------------------------------------------------------------
local c8 = createBaseModel("CheesePharaoh", Vector3.new(2.8, 2.8, 2.6), Color3.fromRGB(255, 205, 50), Enum.Material.Neon)
-- Swiss holes
makePart(c8, "Hole1", Vector3.new(0.7, 0.7, 0.1), Vector3.new(-0.7, 0.5, 1.32), Color3.fromRGB(190, 140, 25))
makePart(c8, "Hole2", Vector3.new(0.5, 0.5, 0.1), Vector3.new(0.6, -0.4, 1.32), Color3.fromRGB(190, 140, 25))
-- Pharaoh Nemes Headdress
makePart(c8, "HeaddressTop", Vector3.new(3.4, 0.8, 2.8), Vector3.new(0, 1.7, 0), Color3.fromRGB(40, 80, 200), Enum.Material.SmoothPlastic)
makePart(c8, "GoldUraeus", Vector3.new(0.4, 0.9, 0.4), Vector3.new(0, 2.0, 1.4), Color3.fromRGB(255, 220, 50), Enum.Material.Neon)
c8.Parent = creaturesFolder

---------------------------------------------------------------------
-- 9. Mega Pickle Duchess (Giant Bumpy Pickle + Queen Crown)
---------------------------------------------------------------------
local c9 = createBaseModel("MegaPickleDuchess", Vector3.new(2.2, 4.0, 2.2), Color3.fromRGB(50, 160, 50), Enum.Material.Neon, Enum.PartType.Cylinder)
-- Pickle bumps
for i = 1, 6 do
	local py = -1.2 + (i * 0.45)
	local px = (i % 2 == 0) and 1.1 or -1.1
	makePart(c9, "Bump_" .. i, Vector3.new(0.4, 0.4, 0.4), Vector3.new(px, py, 0.6), Color3.fromRGB(35, 120, 35), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
end
-- Duchess Crown
makePart(c9, "CrownBase", Vector3.new(2.0, 0.4, 2.0), Vector3.new(0, 2.1, 0), Color3.fromRGB(255, 215, 40), Enum.Material.Neon, Enum.PartType.Cylinder)
makePart(c9, "CrownGem", Vector3.new(0.5, 0.5, 0.5), Vector3.new(0, 2.5, 0.9), Color3.fromRGB(255, 50, 120), Enum.Material.Neon)
c9.Parent = creaturesFolder

---------------------------------------------------------------------
-- 10. Galactic Spaghetti King (Cosmic Swirl + Space Meatballs + Royal Crown)
---------------------------------------------------------------------
local c10 = createBaseModel("GalacticSpaghettiKing", Vector3.new(3.4, 2.2, 3.4), Color3.fromRGB(140, 60, 220), Enum.Material.ForceField, Enum.PartType.Ball)
makePart(c10, "CosmicSauce", Vector3.new(3.1, 1.4, 3.1), Vector3.new(0, 0.5, 0), Color3.fromRGB(220, 50, 150), Enum.Material.Neon, Enum.PartType.Ball)
-- Meatballs
makePart(c10, "Meatball1", Vector3.new(1.1, 1.1, 1.1), Vector3.new(-0.8, 1.2, 0.5), Color3.fromRGB(70, 30, 20), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
makePart(c10, "Meatball2", Vector3.new(1.0, 1.0, 1.0), Vector3.new(0.8, 1.1, -0.4), Color3.fromRGB(70, 30, 20), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
-- Golden King Crown
makePart(c10, "KingCrown", Vector3.new(2.4, 0.7, 2.4), Vector3.new(0, 1.9, 0), Color3.fromRGB(255, 215, 30), Enum.Material.Neon, Enum.PartType.Cylinder)
c10.Parent = creaturesFolder

print("✨ ALL 10 3D CREATURE MODELS CREATED IN ServerStorage > Creatures! ✨")
