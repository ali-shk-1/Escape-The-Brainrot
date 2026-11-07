local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local UIKit = require(ReplicatedStorage.Modules:WaitForChild("UIKit"))

local player = Players.LocalPlayer
local Theme = UIKit.Theme

local button = UIKit.sideButton("🔥", 2, Theme.Pink)
local panel = UIKit.panel("EventPanel", "Weekly Event", 300, Theme.Pink)
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

local rarityLabel = label(0, 22, 16, Theme.Pink, UIKit.TitleFont)
local nameLabel = label(24, 36, 26, Theme.Text, UIKit.TitleFont)
local incomeLabel = label(64, 24, 18, Theme.Green, UIKit.TitleFont)
local timeLabel = label(94, 24, 18, Theme.Gold, UIKit.TitleFont)
label(126, 80, 14, Theme.Muted).Text = "This creature only appears this week, so grab it before it is gone! It spawns deep in the mall, where Big Gus patrols most. Keep it forever, it earns a LOT of coins."

local function refresh()
	local id = workspace:GetAttribute("EventCreature")
	local endsAt = workspace:GetAttribute("EventEndsAt")
	local info = id and Config.Creatures[id]
	if not info then
		nameLabel.Text = "No event right now"
		rarityLabel.Text = ""
		incomeLabel.Text = ""
		timeLabel.Text = ""
		UIKit.setBadge(button, false)
		return
	end
	rarityLabel.Text = "LIMITED TIME CREATURE"
	nameLabel.Text = info.Name
	incomeLabel.Text = "+" .. UIKit.fmt(info.Income) .. " coins per second"
	timeLabel.Text = "Ends in " .. UIKit.formatTime((endsAt or 0) - os.time())
	UIKit.setBadge(button, true)
end

button.Activated:Connect(panel.Toggle)
workspace:GetAttributeChangedSignal("EventCreature"):Connect(refresh)

task.spawn(function()
	while true do
		refresh()
		task.wait(1)
	end
end)
