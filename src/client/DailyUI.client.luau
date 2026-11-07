local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local UIKit = require(ReplicatedStorage.Modules:WaitForChild("UIKit"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClaimRemote = Remotes:WaitForChild("ClaimDaily")

local player = Players.LocalPlayer
local Theme = UIKit.Theme

local button = UIKit.sideButton("🎁", 0, Theme.Gold)
local panel = UIKit.panel("DailyPanel", "Daily Reward", 330, Theme.Gold)
local body = panel.Body

local rewards = Config.Daily.Rewards
local tiles = {}

local grid = UIKit.make("Frame", {
	Size = UDim2.new(1, 0, 0, 150),
	BackgroundTransparency = 1,
}, body)
UIKit.make("UIGridLayout", {
	CellSize = UDim2.new(0.25, -6, 0, 70),
	CellPadding = UDim2.fromOffset(6, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, grid)

for i, reward in ipairs(rewards) do
	local tile = UIKit.make("Frame", {
		BackgroundColor3 = Theme.Row,
		LayoutOrder = i,
	}, grid)
	UIKit.round(tile, 10)
	local outline = UIKit.stroke(tile, Theme.Panel, 2)

	UIKit.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 4),
		BackgroundTransparency = 1,
		Text = "Day " .. i,
		Font = UIKit.BodyFont,
		TextSize = 13,
		TextColor3 = Theme.Muted,
	}, tile)
	local text = reward.Crate and "🎁" or "🪙"
	UIKit.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromOffset(0, 22),
		BackgroundTransparency = 1,
		Text = text,
		TextSize = 20,
		Font = UIKit.BodyFont,
		TextColor3 = Theme.Text,
	}, tile)
	UIKit.make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.fromOffset(0, 46),
		BackgroundTransparency = 1,
		Text = UIKit.fmt(reward.Coins or 0),
		Font = UIKit.TitleFont,
		TextSize = 15,
		TextColor3 = Theme.Gold,
	}, tile)
	tiles[i] = { tile = tile, outline = outline }
end

local info = UIKit.make("TextLabel", {
	Position = UDim2.fromOffset(0, 158),
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	Text = "",
	Font = UIKit.BodyFont,
	TextSize = 15,
	TextColor3 = Theme.Cyan,
}, body)

local claim = UIKit.make("TextButton", {
	Position = UDim2.fromOffset(0, 190),
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundColor3 = Theme.Green,
	Text = "CLAIM",
	Font = UIKit.TitleFont,
	TextSize = 22,
	TextColor3 = Theme.Dark,
	AutoButtonColor = false,
}, body)
UIKit.round(claim, 12)
UIKit.pop(claim)

claim.Activated:Connect(function()
	if player:GetAttribute("DailyReady") then
		ClaimRemote:FireServer()
	end
end)

button.Activated:Connect(panel.Toggle)

local function refresh()
	local ready = player:GetAttribute("DailyReady") == true
	local seconds = player:GetAttribute("DailySeconds") or 0
	local streak = player:GetAttribute("DailyStreak") or 0
	local day = player:GetAttribute("DailyDay") or 1

	for i, t in ipairs(tiles) do
		local done = i < day
		t.tile.BackgroundColor3 = done and Theme.Panel or Theme.Row
		t.outline.Color = (i == day) and Theme.Gold or Theme.Panel
		t.outline.Thickness = (i == day) and 3 or 2
	end
	info.Text = "Streak: " .. streak .. " day(s)"
	if ready then
		claim.Text = "CLAIM DAY " .. day
		claim.BackgroundColor3 = Theme.Green
	else
		claim.Text = "Next in " .. UIKit.formatTime(seconds)
		claim.BackgroundColor3 = Theme.Muted
	end
	UIKit.setBadge(button, ready)
end

for _, name in ipairs({ "DailyReady", "DailySeconds", "DailyStreak", "DailyDay" }) do
	player:GetAttributeChangedSignal(name):Connect(refresh)
end
refresh()

-- auto-open once after joining if a reward is waiting (and the tutorial is not running)
task.delay(10, function()
	if player:GetAttribute("DailyReady") == true and (player:GetAttribute("TutorialStep") or 0) == 0 then
		panel.Open()
	end
end)
