-- M4 Reliable Guard & Waypoints Builder
-- Stop Play mode first!
-- Paste into Studio Command Bar and press Enter.

local Players = game:GetService("Players")

-- 1. Waypoints
local oldWP = workspace:FindFirstChild("GuardWaypoints")
if oldWP then oldWP:Destroy() end
local waypoints = Instance.new("Folder")
waypoints.Name = "GuardWaypoints"
waypoints.Parent = workspace

local points = {
	{ -120, 70 }, { 0, 90 }, { 120, 70 },
	{ -120, -10 }, { -40, -30 }, { 40, -30 }, { 120, -10 },
	{ -120, -95 }, { -60, -110 }, { 0, -95 }, { 60, -110 }, { 120, -95 }, { 0, -70 },
}
for _, p in ipairs(points) do
	local part = Instance.new("Part")
	part.Name = "Waypoint"
	part.Size = Vector3.new(2, 2, 2)
	part.Position = Vector3.new(p[1], 3, p[2])
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = waypoints
end

-- 2. Guard Model
local oldGuard = workspace:FindFirstChild("Guard")
if oldGuard then oldGuard:Destroy() end

local ok, rig = pcall(function()
	local desc = Instance.new("HumanoidDescription")
	desc.WidthScale = 1.5
	desc.HeightScale = 1.2
	return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
end)

if not ok or not rig then
	-- Fallback if HumanoidDescription fails offline
	rig = Instance.new("Model")
	rig.Name = "Guard"
	local hum = Instance.new("Humanoid")
	hum.Parent = rig
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(4, 7, 3)
	root.Color = Color3.fromRGB(220, 40, 40) -- bright red
	root.Material = Enum.Material.Neon
	root.CanCollide = true
	root.Parent = rig
	rig.PrimaryPart = root
end

rig.Name = "Guard"

-- Add a visible overhead Billboard
local hrp = rig:FindFirstChild("HumanoidRootPart") or rig:FindFirstChildWhichIsA("BasePart")
if hrp then
	local bb = Instance.new("BillboardGui")
	bb.Name = "GuardTag"
	bb.Size = UDim2.fromOffset(200, 50)
	bb.StudsOffset = Vector3.new(0, 5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = hrp

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "🚨 BIG GUS (GUARD) 🚨"
	label.TextColor3 = Color3.fromRGB(255, 50, 50)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = bb
end

-- Ensure unanchored so it can walk
for _, part in ipairs(rig:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Anchored = false
	end
end

rig.Parent = workspace
rig:PivotTo(CFrame.new(0, 5, 20)) -- spawns right in the central hallway

print("M4 waypoints and Guard created successfully at", tostring(rig:GetPivot().Position))
