-- M3 Base Builder: paste this entire script into Roblox Studio's Command Bar (View > Command Bar) and press Enter.
-- Run it ONCE. Then save the place.

local old = workspace:FindFirstChild("Bases")
if old then old:Destroy() end
local bases = Instance.new("Folder")
bases.Name = "Bases"
bases.Parent = workspace

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

local VIOLET = Color3.fromRGB(50, 42, 98)
local PINK = Color3.fromRGB(255, 77, 166)
local CYAN = Color3.fromRGB(56, 224, 255)
local MINT = Color3.fromRGB(74, 222, 128)

for i = 1, 6 do
	local bx = -150 + (i - 1) * 60
	local bz = 150
	local base = Instance.new("Model")
	base.Name = "Base" .. i
	part(base, "Platform", Vector3.new(56, 1, 44), Vector3.new(bx, 0.6, bz), VIOLET)
	part(base, "Spawn", Vector3.new(6, 0.4, 6), Vector3.new(bx, 1.3, bz - 4), CYAN, Enum.Material.Neon, { CanCollide = false, Transparency = 0.5 })
	part(base, "DropZone", Vector3.new(16, 0.4, 8), Vector3.new(bx, 1.3, bz - 14), MINT, Enum.Material.Neon, { CanCollide = false })
	for s = 1, 12 do
		local row = (s - 1) // 6
		local col = (s - 1) % 6
		part(base, "Slot" .. s, Vector3.new(7, 0.4, 7), Vector3.new(bx + (col - 2.5) * 8.5, 1.3, bz + 6 + row * 9), PINK, Enum.Material.Neon, { CanCollide = false, Transparency = 0.4 })
	end
	base.PrimaryPart = base.Platform
	base.Parent = bases
end
print("M3 bases built")
