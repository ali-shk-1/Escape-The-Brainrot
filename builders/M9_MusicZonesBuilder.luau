-- M9 Music Zones Builder
-- Paste this entire script into Roblox Studio's Command Bar (View > Command Bar) and press Enter.
-- Run it ONCE. Then save the place.

local old = workspace:FindFirstChild("MusicZones")
if old then old:Destroy() end
local zones = Instance.new("Folder")
zones.Name = "MusicZones"
zones.Parent = workspace

local function zone(name, z, priority)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(360, 40, 80)
	p.Position = Vector3.new(0, 20, z)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	if priority then
		p:SetAttribute("Priority", priority)
	end
	p.Parent = zones
end
zone("FoodCourt", 70)
zone("Electronics", -10)
zone("Vault", -90, 10)
print("M9 music zones built")
