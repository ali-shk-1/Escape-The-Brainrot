-- M2 Map Builder: paste this entire script into Roblox Studio's Command Bar (View > Command Bar) and press Enter.
-- Run it ONCE. Then save the place.

local function folder(name)
	local old = workspace:FindFirstChild(name)
	if old then old:Destroy() end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = workspace
	return f
end

local function part(parent, name, size, pos, color, material, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = parent
	return p
end

local NAVY = Color3.fromRGB(36, 30, 72)
local VIOLET = Color3.fromRGB(50, 42, 98)
local CYAN = Color3.fromRGB(56, 224, 255)
local GOLD = Color3.fromRGB(255, 200, 60)
local PEACH = Color3.fromRGB(255, 150, 80)

local map = folder("MallMap")
local spawns = folder("CreatureSpawns")

local oldSpawn = workspace:FindFirstChildOfClass("SpawnLocation")
if oldSpawn then oldSpawn:Destroy() end

part(map, "FloorPlaza", Vector3.new(360, 1, 80), Vector3.new(0, 0.5, 150), NAVY)
part(map, "FloorFood", Vector3.new(360, 1, 80), Vector3.new(0, 0.5, 70), Color3.fromRGB(90, 55, 80))
part(map, "FloorTech", Vector3.new(360, 1, 80), Vector3.new(0, 0.5, -10), Color3.fromRGB(30, 60, 100))
part(map, "FloorVault", Vector3.new(360, 1, 80), Vector3.new(0, 0.5, -90), Color3.fromRGB(60, 25, 60))

part(map, "WallN", Vector3.new(360, 30, 2), Vector3.new(0, 15, -131), VIOLET)
part(map, "WallS", Vector3.new(360, 30, 2), Vector3.new(0, 15, 191), VIOLET)
part(map, "WallE", Vector3.new(2, 30, 322), Vector3.new(181, 15, 30), VIOLET)
part(map, "WallW", Vector3.new(2, 30, 322), Vector3.new(-181, 15, 30), VIOLET)
part(map, "VaultWallL", Vector3.new(168, 24, 2), Vector3.new(-96, 12, -50), VIOLET)
part(map, "VaultWallR", Vector3.new(168, 24, 2), Vector3.new(96, 12, -50), VIOLET)
part(map, "VaultDoorTop", Vector3.new(24, 4, 2), Vector3.new(0, 22, -50), GOLD, Enum.Material.Neon)

local function pad(x, z, tier, color)
	local p = part(spawns, "Pad", Vector3.new(6, 0.4, 6), Vector3.new(x, 1.2, z), color, Enum.Material.Neon, { CanCollide = false, Transparency = 0.5 })
	p:SetAttribute("Tier", tier)
end
for _, x in ipairs({ -120, -60, 0, 60, 120 }) do pad(x, 60, 1, PEACH) end
for _, x in ipairs({ -90, 0, 90 }) do pad(x, 92, 1, PEACH) end
for _, x in ipairs({ -130, -70, -10, 50, 110 }) do pad(x, -5, 2, CYAN) end
for _, x in ipairs({ -100, -30, 30, 100 }) do pad(x, -30, 2, CYAN) end
for _, x in ipairs({ -120, -70, -20, 20, 70, 120 }) do pad(x, -100, 3, GOLD) end

local startSpawn = Instance.new("SpawnLocation")
startSpawn.Name = "StartSpawn"
startSpawn.Size = Vector3.new(6, 1, 6)
startSpawn.Position = Vector3.new(0, 1.6, 120)
startSpawn.Anchored = true
startSpawn.Transparency = 1
startSpawn.Neutral = true
startSpawn.Parent = map

print("M2 map built")
