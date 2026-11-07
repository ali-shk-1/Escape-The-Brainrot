-- Mall Visual Polish: runs in Studio Command Bar
-- Cleans up floor & wall materials, adds neon trims and vibrant colors

local map = workspace:FindFirstChild("MallMap")
if not map then
	warn("MallMap not found in workspace!")
	return
end

-- 1. Floors: Smooth, clean look with distinctive zone hues
local floorColors = {
	FloorPlaza = Color3.fromRGB(30, 26, 56),      -- Deep midnight base
	FloorFood  = Color3.fromRGB(65, 35, 60),      -- Warm berry purple
	FloorTech  = Color3.fromRGB(25, 45, 80),      -- Cool cyber blue
	FloorVault = Color3.fromRGB(48, 20, 52),      -- Mystical dark plum
}

for name, color in pairs(floorColors) do
	local f = map:FindFirstChild(name)
	if f and f:IsA("BasePart") then
		f.Color = color
		f.Material = Enum.Material.SmoothPlastic
		f.Reflectance = 0.08 -- Subtle gloss
	end
end

-- 2. Walls: Sleek dark violet structure
for _, child in ipairs(map:GetChildren()) do
	if child:IsA("BasePart") and string.find(child.Name, "Wall") then
		child.Color = Color3.fromRGB(42, 35, 78)
		child.Material = Enum.Material.SmoothPlastic
	end
end

-- 3. Vault Door: Radiant golden gateway
local doorTop = map:FindFirstChild("VaultDoorTop")
if doorTop and doorTop:IsA("BasePart") then
	doorTop.Color = Color3.fromRGB(255, 215, 60)
	doorTop.Material = Enum.Material.Neon
end

-- 4. Creature Spawns: High visibility glowing pads
local spawns = workspace:FindFirstChild("CreatureSpawns")
if spawns then
	for _, pad in ipairs(spawns:GetChildren()) do
		if pad:IsA("BasePart") then
			pad.Material = Enum.Material.Neon
			pad.Transparency = 0.35 -- More visible than 0.5
			local tier = pad:GetAttribute("Tier") or 1
			if tier == 1 then
				pad.Color = Color3.fromRGB(255, 140, 70) -- Peach/Orange
			elseif tier == 2 then
				pad.Color = Color3.fromRGB(50, 220, 255)  -- Neon Cyan
			elseif tier == 3 then
				pad.Color = Color3.fromRGB(255, 205, 50)  -- Neon Gold
			end
		end
	end
end

print("✨ Mall visuals and colors polished successfully!")
