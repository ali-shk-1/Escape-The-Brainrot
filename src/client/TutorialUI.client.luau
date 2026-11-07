local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIKit = require(ReplicatedStorage.Modules:WaitForChild("UIKit"))

local player = Players.LocalPlayer
local Theme = UIKit.Theme

local gui = UIKit.screen("Tutorial", 7)

local banner = UIKit.make("Frame", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -96),
	Size = UDim2.new(0.9, 0, 0, 70),
	BackgroundColor3 = Theme.Bg,
	Visible = false,
}, gui)
UIKit.make("UISizeConstraint", { MaxSize = Vector2.new(420, 70) }, banner)
UIKit.round(banner, 16)
UIKit.stroke(banner, Theme.Pink, 3)

local stepLabel = UIKit.make("TextLabel", {
	Position = UDim2.fromOffset(12, 4),
	Size = UDim2.new(1, -24, 0, 18),
	BackgroundTransparency = 1,
	Font = UIKit.BodyFont,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Theme.Cyan,
	Text = "",
}, banner)

local textLabel = UIKit.make("TextLabel", {
	Position = UDim2.fromOffset(12, 22),
	Size = UDim2.new(1, -24, 0, 44),
	BackgroundTransparency = 1,
	Font = UIKit.TitleFont,
	TextSize = 18,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Theme.Text,
	Text = "",
}, banner)

local STEPS = {
	[1] = "Walk into the mall and HOLD the Grab button on a creature!",
	[2] = "Run home and step on the glowing DROP HERE pad at your stall!",
	[3] = "Tap the SHOP button and buy your first upgrade!",
}

-- arrow above your own drop zone (step 2)
local arrow
local function findMyDropZone()
	local bases = workspace:FindFirstChild("Bases")
	if not bases then
		return nil
	end
	for _, base in ipairs(bases:GetChildren()) do
		if base:GetAttribute("OwnerUserId") == player.UserId then
			return base:FindFirstChild("DropZone")
		end
	end
	return nil
end

local function setArrow(enabled)
	if not enabled then
		if arrow then
			arrow:Destroy()
			arrow = nil
		end
		return
	end
	if arrow and arrow.Parent then
		return
	end
	local zone = findMyDropZone()
	if not zone then
		return
	end
	arrow = UIKit.make("BillboardGui", {
		Name = "TutorialArrow",
		Adornee = zone,
		AlwaysOnTop = true,
		Size = UDim2.fromOffset(120, 60),
		StudsOffset = Vector3.new(0, 7, 0),
	}, zone)
	UIKit.make("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "⬇ DROP HERE ⬇",
		Font = UIKit.TitleFont,
		TextScaled = true,
		TextColor3 = Theme.Green,
		TextStrokeTransparency = 0,
	}, arrow)
end

local function refresh()
	local step = player:GetAttribute("TutorialStep") or 0
	if step == 0 or not STEPS[step] then
		banner.Visible = false
		setArrow(false)
		return
	end
	banner.Visible = true
	stepLabel.Text = "FIRST STEPS  " .. step .. "/3"
	textLabel.Text = STEPS[step]
	setArrow(step == 2)
end

player:GetAttributeChangedSignal("TutorialStep"):Connect(refresh)
refresh()

-- the arrow needs the base to be assigned, so keep checking while step 2 is active
task.spawn(function()
	while true do
		task.wait(1)
		if player:GetAttribute("TutorialStep") == 2 then
			setArrow(true)
		end
	end
end)
