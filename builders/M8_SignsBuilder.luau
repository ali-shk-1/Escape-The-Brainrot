-- M8 Neon Signs Builder
-- Paste into Studio Command Bar (View > Command Bar) and press Enter.

local old = workspace:FindFirstChild("NeonSigns")
if old then old:Destroy() end
local signs = Instance.new("Folder")
signs.Name = "NeonSigns"
signs.Parent = workspace

local function sign(text, pos, color)
	local s = Instance.new("Part")
	s.Name = "Sign"
	s.Size = Vector3.new(24, 4, 0.6)
	s.Position = pos
	s.Color = color
	s.Anchored = true
	s.Parent = signs
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = s
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Parent = gui
end
sign("FOOD COURT", Vector3.new(0, 18, 108), Color3.fromRGB(255, 150, 80))
sign("TECH ZONE", Vector3.new(0, 18, 28), Color3.fromRGB(56, 224, 255))
sign("VAULT", Vector3.new(0, 18, -128), Color3.fromRGB(255, 200, 60))
print("Signs built")
