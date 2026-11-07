local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local UIKit = require(ReplicatedStorage.Modules:WaitForChild("UIKit"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RebirthRemote = Remotes:WaitForChild("Rebirth")

local player = Players.LocalPlayer
local Theme = UIKit.Theme

local button = UIKit.sideButton("🔄", 1, Theme.Cyan)
local panel = UIKit.panel("RebirthPanel", "Rebirth", 360, Theme.Cyan)
local body = panel.Body

local function label(y, height, size, color, font)
	return UIKit.make("TextLabel", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		TextWrapped = true,
		Font = font or UIKit.BodyFont,
		TextSize = size,
		TextColor3 = color,
		Text = "",
	}, body)
end

local current = label(0, 26, 20, Theme.Cyan, UIKit.TitleFont)
local nextInfo = label(28, 40, 15, Theme.Text)
local costLabel = label(72, 24, 18, Theme.Gold, UIKit.TitleFont)

local barBack = UIKit.make("Frame", {
	Position = UDim2.fromOffset(0, 102),
	Size = UDim2.new(1, 0, 0, 20),
	BackgroundColor3 = Theme.Row,
}, body)
UIKit.round(barBack, 10)
local barFill = UIKit.make("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = Theme.Green,
}, barBack)
UIKit.round(barFill, 10)

label(130, 66, 13, Theme.Muted).Text = "Resets your coins, creatures and upgrades. You KEEP your passes, codes and rebirths, and get a permanent coin bonus."

local action = UIKit.make("TextButton", {
	Position = UDim2.fromOffset(0, 210),
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundColor3 = Theme.Cyan,
	Text = "REBIRTH",
	Font = UIKit.TitleFont,
	TextSize = 22,
	TextColor3 = Theme.Dark,
	AutoButtonColor = false,
}, body)
UIKit.round(action, 12)
UIKit.pop(action)

local function coins()
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Coins")
	return value and value.Value or 0
end

local confirmUntil = 0

local function refresh()
	local count = player:GetAttribute("Rebirths") or 0
	local cost = player:GetAttribute("RebirthCost") or Config.RebirthCost(0)
	local maxed = player:GetAttribute("RebirthMax") == true
	local have = coins()
	local bonus = Config.Rebirth.BonusPerRebirth

	current.Text = "Rebirths: " .. count .. "  (+" .. (count * bonus * 100) .. "% coins)"
	if maxed then
		nextInfo.Text = "You reached the maximum rebirth. Legend!"
		costLabel.Text = ""
		barFill.Size = UDim2.fromScale(1, 1)
		action.Text = "MAXED"
		action.BackgroundColor3 = Theme.Muted
		UIKit.setBadge(button, false)
		return
	end
	nextInfo.Text = "Next rebirth gives +" .. (bonus * 100) .. "% more coins forever."
	costLabel.Text = "Cost: " .. UIKit.fmt(cost) .. " coins  (you have " .. UIKit.fmt(have) .. ")"
	barFill.Size = UDim2.fromScale(math.clamp(have / cost, 0, 1), 1)

	local can = have >= cost
	UIKit.setBadge(button, can)
	if os.clock() < confirmUntil and can then
		action.Text = "TAP AGAIN TO CONFIRM"
		action.BackgroundColor3 = Theme.Red
	elseif can then
		action.Text = "REBIRTH"
		action.BackgroundColor3 = Theme.Cyan
	else
		action.Text = "Need more coins"
		action.BackgroundColor3 = Theme.Muted
	end
end

action.Activated:Connect(function()
	local cost = player:GetAttribute("RebirthCost") or Config.RebirthCost(0)
	if player:GetAttribute("RebirthMax") == true or coins() < cost then
		return
	end
	if os.clock() < confirmUntil then
		confirmUntil = 0
		RebirthRemote:FireServer()
	else
		confirmUntil = os.clock() + 3
	end
	refresh()
end)

button.Activated:Connect(panel.Toggle)

for _, name in ipairs({ "Rebirths", "RebirthCost", "RebirthMax" }) do
	player:GetAttributeChangedSignal(name):Connect(refresh)
end
task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local value = stats:WaitForChild("Coins")
	value.Changed:Connect(refresh)
	refresh()
end)
task.spawn(function()
	while true do
		task.wait(0.5)
		if panel.IsOpen() then
			refresh()
		end
	end
end)
refresh()
