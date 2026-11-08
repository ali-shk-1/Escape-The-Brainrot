-- MegaVisualsBuilder: High-production mall architecture with pixel-perfect grid alignment!
-- Paste into Studio Command Bar (View > Command Bar) while stopped, then save the place.

local map = workspace:FindFirstChild("MallMap")
if not map then
	warn("MallMap not found in Workspace!")
	return
end

local function makePart(parent, name, size, pos, color, material, props)
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

local decoFolder = workspace:FindFirstChild("MallDecorations")
if decoFolder then decoFolder:Destroy() end
decoFolder = Instance.new("Folder")
decoFolder.Name = "MallDecorations"
decoFolder.Parent = workspace

local VIOLET_DARK = Color3.fromRGB(26, 20, 48)
local VIOLET_MED  = Color3.fromRGB(40, 32, 72)
local CYAN_NEON   = Color3.fromRGB(56, 224, 255)
local PINK_NEON   = Color3.fromRGB(255, 77, 166)
local GOLD_NEON   = Color3.fromRGB(255, 200, 60)
local MINT_NEON   = Color3.fromRGB(74, 222, 128)

---------------------------------------------------------------------
-- 1. Precision Concourse Architectural Pillars (Symmetrical Alignment)
---------------------------------------------------------------------
local zPillars = { 180, 140, 100, 60, 20, -20, -60, -100, -125 }
for _, z in ipairs(zPillars) do
	for _, x in ipairs({ -176, 176 }) do
		-- Pillar column
		makePart(decoFolder, "Pillar", Vector3.new(6, 30, 6), Vector3.new(x, 15, z), VIOLET_MED)
		-- Glowing vertical neon accent strip
		local stripX = (x > 0) and (x - 3.1) or (x + 3.1)
		local accentColor = (z > 50 and PINK_NEON) or (z > -40 and CYAN_NEON) or GOLD_NEON
		makePart(decoFolder, "PillarStrip", Vector3.new(0.3, 26, 1.6), Vector3.new(stripX, 15, z), accentColor, Enum.Material.Neon)
	end
end

---------------------------------------------------------------------
-- 2. Zone Transition Archways (Centered at X = 0)
---------------------------------------------------------------------
local function makeArch(z, name, color, labelText)
	local archModel = Instance.new("Model")
	archModel.Name = "Arch_" .. name
	archModel.Parent = decoFolder

	-- Left column
	makePart(archModel, "ColL", Vector3.new(4, 26, 4), Vector3.new(-60, 13, z), VIOLET_DARK)
	makePart(archModel, "ColL_Neon", Vector3.new(1, 24, 1), Vector3.new(-58, 13, z), color, Enum.Material.Neon)
	-- Right column
	makePart(archModel, "ColR", Vector3.new(4, 26, 4), Vector3.new(60, 13, z), VIOLET_DARK)
	makePart(archModel, "ColR_Neon", Vector3.new(1, 24, 1), Vector3.new(58, 13, z), color, Enum.Material.Neon)
	-- Top header beam
	makePart(archModel, "TopBeam", Vector3.new(124, 5, 4), Vector3.new(0, 25, z), VIOLET_DARK)
	makePart(archModel, "BeamNeon", Vector3.new(122, 1, 4.2), Vector3.new(0, 22.8, z), color, Enum.Material.Neon)

	-- Overhead Zone Banner
	local sign = makePart(archModel, "Banner", Vector3.new(34, 6, 1), Vector3.new(0, 28, z), VIOLET_DARK)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.Parent = sign
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.Font = Enum.Font.FredokaOne
	lbl.TextScaled = true
	lbl.TextColor3 = color
	lbl.TextStrokeColor3 = Color3.fromRGB(10, 5, 20)
	lbl.TextStrokeTransparency = 0
	lbl.Parent = sg
end

makeArch(110, "FoodCourt", PINK_NEON, "🍔 FOOD COURT 🍟")
makeArch(30, "TechZone", CYAN_NEON, "⚡ TECH ZONE ⚡")

---------------------------------------------------------------------
-- 3. Heavy Vault Gateway Frame & Caution Hazard Trim
---------------------------------------------------------------------
local vaultArch = Instance.new("Model")
vaultArch.Name = "VaultEntrance"
vaultArch.Parent = decoFolder

makePart(vaultArch, "GatePillarL", Vector3.new(10, 28, 8), Vector3.new(-32, 14, -50), Color3.fromRGB(38, 24, 42))
makePart(vaultArch, "GatePillarR", Vector3.new(10, 28, 8), Vector3.new(32, 14, -50), Color3.fromRGB(38, 24, 42))
makePart(vaultArch, "GateTop", Vector3.new(74, 8, 8), Vector3.new(0, 26, -50), Color3.fromRGB(32, 18, 36))

-- Hazard stripes & caution light
makePart(vaultArch, "HazardL", Vector3.new(1.2, 26, 8.2), Vector3.new(-26.5, 14, -50), GOLD_NEON, Enum.Material.Neon)
makePart(vaultArch, "HazardR", Vector3.new(1.2, 26, 8.2), Vector3.new(26.5, 14, -50), GOLD_NEON, Enum.Material.Neon)

-- Overhead "RESTRICTED VAULT" Sign
local vaultSign = makePart(vaultArch, "VaultSign", Vector3.new(46, 7, 2), Vector3.new(0, 31, -50), VIOLET_DARK)
local vsg = Instance.new("SurfaceGui")
vsg.Face = Enum.NormalId.Front
vsg.Parent = vaultSign
local vlbl = Instance.new("TextLabel")
vlbl.Size = UDim2.fromScale(1, 1)
vlbl.BackgroundTransparency = 1
vlbl.Text = "⚠️ RESTRICTED VAULT ⚠️"
vlbl.Font = Enum.Font.FredokaOne
vlbl.TextScaled = true
vlbl.TextColor3 = GOLD_NEON
vlbl.TextStrokeTransparency = 0
vlbl.Parent = vsg

---------------------------------------------------------------------
-- 4. Polished Floor Center Runway Track (Z-Fighting Free: Y = 1.02)
---------------------------------------------------------------------
makePart(decoFolder, "CenterTrack", Vector3.new(3.5, 0.05, 305), Vector3.new(0, 1.03, 30), CYAN_NEON, Enum.Material.Neon, { Transparency = 0.55 })
makePart(decoFolder, "TrackBorderL", Vector3.new(0.4, 0.06, 305), Vector3.new(-1.95, 1.03, 30), PINK_NEON, Enum.Material.Neon, { Transparency = 0.4 })
makePart(decoFolder, "TrackBorderR", Vector3.new(0.4, 0.06, 305), Vector3.new(1.95, 1.03, 30), PINK_NEON, Enum.Material.Neon, { Transparency = 0.4 })

---------------------------------------------------------------------
-- 5. Player Base Stalls (Perfected Elevation & Clean Frames)
---------------------------------------------------------------------
local bases = workspace:FindFirstChild("Bases")
if bases then
	for _, base in ipairs(bases:GetChildren()) do
		local platform = base:FindFirstChild("Platform")
		if platform then
			local bPos = platform.Position
			-- Back wall frame
			local existingWall = base:FindFirstChild("StallWall")
			if existingWall then existingWall:Destroy() end
			local existingTrim = base:FindFirstChild("StallTrim")
			if existingTrim then existingTrim:Destroy() end

			makePart(base, "StallWall", Vector3.new(56, 12, 1.5), bPos + Vector3.new(0, 6, 21.5), VIOLET_MED)
			makePart(base, "StallTrim", Vector3.new(56, 1, 1.6), bPos + Vector3.new(0, 12, 21.5), PINK_NEON, Enum.Material.Neon)
		end

		-- Elevate slot pads into sleek 3D pedestals with clean top plane
		for s = 1, 12 do
			local slot = base:FindFirstChild("Slot" .. s)
			if slot and slot:IsA("BasePart") then
				slot.Size = Vector3.new(7, 0.7, 7)
				slot.Position = Vector3.new(slot.Position.X, 1.35, slot.Position.Z)
				slot.Material = Enum.Material.Neon
				slot.Transparency = 0.22
				slot.Color = Color3.fromRGB(255, 95, 175)
			end
		end
	end
end

print("🎉 ALIGNED ARCHITECTURE & PERFORMANCE GRAPHICS BUILT!")
