local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------
-- Sharp, High-Contrast Arcade Theme
---------------------------------------------------------------------
local Theme = {
	Bg = Color3.fromRGB(18, 14, 38),
	Panel = Color3.fromRGB(32, 26, 64),
	Row = Color3.fromRGB(46, 38, 88),
	RowHover = Color3.fromRGB(60, 50, 110),
	Pink = Color3.fromRGB(255, 60, 155),
	Cyan = Color3.fromRGB(0, 220, 255),
	Gold = Color3.fromRGB(255, 195, 30),
	Green = Color3.fromRGB(45, 230, 110),
	Red = Color3.fromRGB(255, 45, 80),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(210, 200, 240),
	Dark = Color3.fromRGB(15, 10, 25),
}
local TITLE_FONT = Enum.Font.FredokaOne
local BODY_FONT = Enum.Font.FredokaOne

---------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------
local function make(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function round(inst, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, inst)
end

local function stroke(inst, color, thickness)
	return make("UIStroke", {
		Color = color,
		Thickness = thickness or 2.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

local function gradient(inst, c1, c2, rotation)
	make("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rotation or 90 }, inst)
end

-- 1234 -> "1,234", 25000 -> "25.0K", 3200000 -> "3.20M"
local function fmt(n)
	n = math.floor(n or 0)
	if n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e4 then
		return string.format("%.1fK", n / 1e3)
	end
	local s = tostring(n)
	return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function playSfx(name)
	local id = Config.Sounds and Config.Sounds[name]
	if not id or id == 0 then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 0.7
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 4)
end

-- Tactile juicy button pop
local function animate(button)
	local scale = make("UIScale", { Scale = 1 }, button)
	local function to(value)
		TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function() to(1.05) end)
	button.MouseLeave:Connect(function() to(1.0) end)
	button.MouseButton1Down:Connect(function() to(0.93) end)
	button.MouseButton1Up:Connect(function() to(1.05) end)
end

---------------------------------------------------------------------
-- Screen Containers
---------------------------------------------------------------------
local gui = make("ScreenGui", { Name = "EscapeUI", ResetOnSpawn = false, DisplayOrder = 2 }, playerGui)
local fxGui = make("ScreenGui", { Name = "EscapeFX", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10 }, playerGui)

local flash = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, fxGui)

local function flashScreen(color)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 0.6
	TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
end

local function shakeCamera(duration, strength)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	task.spawn(function()
		local started = os.clock()
		while os.clock() - started < duration do
			hum.CameraOffset = Vector3.new((math.random() - 0.5) * strength, (math.random() - 0.5) * strength, 0)
			task.wait()
		end
		hum.CameraOffset = Vector3.zero
	end)
end

local sfxColors = {
	Caught = Theme.Red,
	Deposit = Theme.Green,
	Upgrade = Theme.Cyan,
	Legendary = Theme.Gold,
}
Remotes:WaitForChild("Sfx").OnClientEvent:Connect(function(name)
	playSfx(name)
	if sfxColors[name] then
		flashScreen(sfxColors[name])
	end
	if name == "Caught" then
		shakeCamera(0.4, 1.4)
	end
end)

---------------------------------------------------------------------
-- Modern Top Arcade HUD: Coins + Carry Counters
---------------------------------------------------------------------
local hudContainer = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 10),
	Size = UDim2.fromOffset(380, 56),
	BackgroundTransparency = 1,
}, gui)

-- Main Coin Pill
local coinPill = make("Frame", {
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromOffset(230, 54),
	BackgroundColor3 = Theme.Panel,
}, hudContainer)
round(coinPill, 27)
stroke(coinPill, Theme.Gold, 3)
gradient(coinPill, Color3.fromRGB(48, 38, 86), Color3.fromRGB(24, 18, 48), 90)

make("TextLabel", {
	Position = UDim2.fromOffset(8, 7),
	Size = UDim2.fromOffset(40, 40),
	BackgroundTransparency = 1,
	Text = "🪙",
	TextScaled = true,
}, coinPill)

local coinText = make("TextLabel", {
	Position = UDim2.fromOffset(52, 4),
	Size = UDim2.new(1, -60, 0, 28),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = TITLE_FONT,
	TextScaled = true,
	TextColor3 = Theme.Gold,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(20, 15, 30),
	Text = "0",
}, coinPill)

local incomeText = make("TextLabel", {
	Position = UDim2.fromOffset(52, 32),
	Size = UDim2.new(1, -60, 0, 18),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = BODY_FONT,
	TextSize = 14,
	TextColor3 = Theme.Green,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(10, 40, 15),
	Text = "+0/s",
}, coinPill)

-- Carry & Base Slot Pill
local carryPill = make("Frame", {
	Position = UDim2.fromOffset(238, 0),
	Size = UDim2.fromOffset(142, 54),
	BackgroundColor3 = Theme.Panel,
}, hudContainer)
round(carryPill, 27)
stroke(carryPill, Theme.Cyan, 3)
gradient(carryPill, Color3.fromRGB(48, 38, 86), Color3.fromRGB(24, 18, 48), 90)

local carryText = make("TextLabel", {
	Position = UDim2.fromOffset(10, 4),
	Size = UDim2.new(1, -20, 0, 24),
	BackgroundTransparency = 1,
	Font = TITLE_FONT,
	TextSize = 15,
	TextColor3 = Theme.Cyan,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(10, 30, 45),
	Text = "🎒 0/1",
}, carryPill)

local stallText = make("TextLabel", {
	Position = UDim2.fromOffset(10, 28),
	Size = UDim2.new(1, -20, 0, 22),
	BackgroundTransparency = 1,
	Font = TITLE_FONT,
	TextSize = 14,
	TextColor3 = Theme.Pink,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(40, 10, 30),
	Text = "🏠 0/3",
}, carryPill)

-- Floating Coin Popups
local function showCoinPopup(amount)
	if amount <= 0 then return end
	local popup = make("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, math.random(-50, 50), 0, 68),
		Size = UDim2.fromOffset(140, 28),
		BackgroundTransparency = 1,
		Font = TITLE_FONT,
		TextSize = 22,
		TextColor3 = Theme.Gold,
		TextStrokeColor3 = Color3.fromRGB(20, 15, 30),
		TextStrokeTransparency = 0,
		Text = "+" .. fmt(amount) .. " 🪙",
	}, gui)

	local tween = TweenService:Create(
		popup,
		TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{
			Position = popup.Position - UDim2.fromOffset(0, 42),
			TextTransparency = 1,
			TextStrokeTransparency = 1,
		}
	)
	tween:Play()
	tween.Completed:Once(function()
		popup:Destroy()
	end)
end

local lastCoins = nil
local function refreshHud()
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	local currentCoins = coins and coins.Value or 0
	if lastCoins and currentCoins > lastCoins then
		showCoinPopup(currentCoins - lastCoins)
	end
	lastCoins = currentCoins

	coinText.Text = fmt(currentCoins)
	incomeText.Text = "+" .. fmt(player:GetAttribute("IncomePerSec") or 0) .. "/s"
	carryText.Text = string.format("🎒 %d/%d CARRY", player:GetAttribute("CarryCount") or 0, player:GetAttribute("Capacity") or 1)
	stallText.Text = string.format("🏠 %d/%d STALL", player:GetAttribute("StoredCount") or 0, player:GetAttribute("Slots") or Config.BaseSlots)
end

for _, attr in ipairs({ "IncomePerSec", "CarryCount", "Capacity", "StoredCount", "Slots" }) do
	player:GetAttributeChangedSignal(attr):Connect(refreshHud)
end
task.spawn(function()
	local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
	coins.Changed:Connect(refreshHud)
	refreshHud()
end)

---------------------------------------------------------------------
-- Toast Messages (Slide in from top)
---------------------------------------------------------------------
local toast = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -80),
	Size = UDim2.new(0.9, 0, 0, 44),
	BackgroundColor3 = Theme.Pink,
	TextColor3 = Color3.new(1, 1, 1),
	Font = TITLE_FONT,
	TextSize = 20,
	TextWrapped = true,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(30, 10, 20),
	Text = "",
}, gui)
make("UISizeConstraint", { MaxSize = Vector2.new(460, 64) }, toast)
round(toast, 22)
stroke(toast, Color3.new(1, 1, 1), 3)

local toastId = 0
Remotes:WaitForChild("Notify").OnClientEvent:Connect(function(text)
	toastId += 1
	local myId = toastId
	toast.Text = text
	TweenService:Create(
		toast,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, 72) }
	):Play()
	task.delay(3.2, function()
		if toastId == myId then
			TweenService:Create(toast, TweenInfo.new(0.25), { Position = UDim2.new(0.5, 0, 0, -80) }):Play()
		end
	end)
end)

---------------------------------------------------------------------
-- High-Impact SHOP Button & Window
---------------------------------------------------------------------
local shopButton = make("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 14, 0.5, -20),
	Size = UDim2.fromOffset(125, 54),
	BackgroundColor3 = Theme.Pink,
	TextColor3 = Color3.new(1, 1, 1),
	Font = TITLE_FONT,
	TextSize = 22,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(30, 5, 20),
	Text = "🛍 SHOP",
}, gui)
round(shopButton, 16)
stroke(shopButton, Color3.new(1, 1, 1), 3.5)
gradient(shopButton, Color3.fromRGB(255, 90, 180), Color3.fromRGB(220, 30, 110), 90)
animate(shopButton)

-- Shop Modal Frame
local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.92, 0.82),
	BackgroundColor3 = Theme.Bg,
	Visible = false,
}, gui)
make("UISizeConstraint", { MinSize = Vector2.new(300, 320), MaxSize = Vector2.new(500, 450) }, panel)
round(panel, 20)
stroke(panel, Theme.Pink, 3.5)
gradient(panel, Color3.fromRGB(36, 28, 68), Theme.Bg, 90)
local panelScale = make("UIScale", { Scale = 1 }, panel)

-- Header Title
make("TextLabel", {
	Position = UDim2.fromOffset(16, 8),
	Size = UDim2.new(1, -70, 0, 36),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = TITLE_FONT,
	TextSize = 28,
	TextColor3 = Theme.Text,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(15, 10, 25),
	Text = "🛍 MALL SHOP",
}, panel)

local closeButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 8),
	Size = UDim2.fromOffset(36, 36),
	BackgroundColor3 = Theme.Red,
	TextColor3 = Theme.Text,
	Font = TITLE_FONT,
	TextSize = 22,
	Text = "✕",
}, panel)
round(closeButton, 18)
stroke(closeButton, Color3.new(1, 1, 1), 2)
animate(closeButton)

local shopOpen = false
local function setShop(open)
	shopOpen = open
	playSfx("Click")
	if open then
		panel.Visible = true
		panelScale.Scale = 0.85
		TweenService:Create(
			panelScale,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	else
		local tween = TweenService:Create(panelScale, TweenInfo.new(0.15), { Scale = 0.85 })
		tween:Play()
		tween.Completed:Once(function()
			if not shopOpen then
				panel.Visible = false
			end
		end)
	end
end
shopButton.Activated:Connect(function()
	setShop(not shopOpen)
end)
closeButton.Activated:Connect(function()
	setShop(false)
end)

-- Navigation Tabs
local tabBar = make("Frame", {
	Position = UDim2.fromOffset(10, 48),
	Size = UDim2.new(1, -20, 0, 38),
	BackgroundTransparency = 1,
}, panel)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local pageHolder = make("Frame", {
	Position = UDim2.fromOffset(10, 94),
	Size = UDim2.new(1, -20, 1, -104),
	BackgroundTransparency = 1,
}, panel)

local tabDefs = {
	{ "Upgrades", "⚡ Upgrades" },
	{ "Passes", "💎 Passes" },
	{ "Coins", "💰 Coins" },
	{ "Codes", "🎁 Codes" },
}
local pages, tabButtons = {}, {}

local function setTab(name)
	for key, page in pairs(pages) do
		page.Visible = (key == name)
	end
	for key, button in pairs(tabButtons) do
		button.BackgroundColor3 = (key == name) and Theme.Pink or Theme.Row
	end
end

for i, def in ipairs(tabDefs) do
	local button = make("TextButton", {
		Size = UDim2.new(0.25, -5, 1, 0),
		BackgroundColor3 = Theme.Row,
		TextColor3 = Theme.Text,
		Font = TITLE_FONT,
		TextScaled = true,
		Text = def[2],
		LayoutOrder = i,
	}, tabBar)
	make("UITextSizeConstraint", { MaxTextSize = 16 }, button)
	round(button, 10)
	stroke(button, Color3.fromRGB(70, 60, 120), 2)
	animate(button)
	button.Activated:Connect(function()
		playSfx("Click")
		setTab(def[1])
	end)
	tabButtons[def[1]] = button

	local page = make("ScrollingFrame", {
		Name = def[1],
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Theme.Pink,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Visible = false,
	}, pageHolder)
	make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	pages[def[1]] = page
end

-- Reusable high-contrast item row
local function makeRow(page, title, desc, buttonText, buttonColor, onClick)
	local row = make("Frame", {
		Size = UDim2.new(1, -6, 0, 74),
		BackgroundColor3 = Theme.Row,
		LayoutOrder = #page:GetChildren() + 1,
	}, page)
	round(row, 12)
	stroke(row, Color3.fromRGB(75, 65, 130), 2)

	make("TextLabel", {
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -135, 0, 26),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = TITLE_FONT,
		TextSize = 19,
		TextColor3 = Theme.Text,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(15, 10, 25),
		Text = title,
	}, row)

	local descLabel = make("TextLabel", {
		Position = UDim2.fromOffset(12, 32),
		Size = UDim2.new(1, -135, 0, 36),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Font = BODY_FONT,
		TextSize = 13,
		TextColor3 = Theme.TextDim,
		Text = desc,
	}, row)

	local button = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(112, 48),
		BackgroundColor3 = buttonColor,
		TextColor3 = Color3.new(1, 1, 1),
		Font = TITLE_FONT,
		TextSize = 19,
		TextStrokeTransparency = 0,
		TextStrokeColor3 = Color3.fromRGB(15, 10, 25),
		Text = buttonText,
	}, row)
	round(button, 12)
	stroke(button, Color3.new(1, 1, 1), 2.5)
	animate(button)
	button.Activated:Connect(function()
		playSfx("Click")
		onClick()
	end)

	return button, descLabel
end

-- Query Robux price
local function loadPrice(button, id, infoType)
	if id == 0 then return end
	task.spawn(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(id, infoType)
		end)
		if ok and info and info.PriceInRobux and button.Text == "BUY" then
			button.Text = "R$ " .. info.PriceInRobux
		end
	end)
end

---------------------------------------------------------------------
-- Upgrades Tab (Coins)
---------------------------------------------------------------------
local upgradeRows = {}

local function refreshUpgrades()
	for key, row in pairs(upgradeRows) do
		local def = Config.Upgrades[key]
		local level = player:GetAttribute(key .. "Level") or 0
		row.desc.Text = string.format("Level %d/%d - %s", level, def.Max, row.base)
		if level >= def.Max then
			row.button.Text = "MAXED"
			row.button.BackgroundColor3 = Color3.fromRGB(90, 85, 120)
		else
			row.button.Text = fmt(Config.UpgradeCost(key, level)) .. " 🪙"
			row.button.BackgroundColor3 = Theme.Green
		end
	end
end

local upgradeInfo = {
	{ "Speed", "⚡ Speed", "Sprint faster to outrun Big Gus." },
	{ "Capacity", "🎒 Capacity", "Carry more creatures per trip." },
	{ "Slots", "🏠 Stall Slots", "Store more creatures for bigger income." },
}
for _, info in ipairs(upgradeInfo) do
	local key = info[1]
	local button, desc = makeRow(pages.Upgrades, info[2], info[3], "", Theme.Green, function()
		Remotes.BuyUpgrade:FireServer(key)
	end)
	upgradeRows[key] = { button = button, desc = desc, base = info[3] }
	player:GetAttributeChangedSignal(key .. "Level"):Connect(refreshUpgrades)
end
refreshUpgrades()

---------------------------------------------------------------------
-- Passes Tab (Robux)
---------------------------------------------------------------------
local passRows = {}

local function refreshPasses()
	for key, button in pairs(passRows) do
		if player:GetAttribute(key) then
			button.Text = "OWNED ✔"
			button.BackgroundColor3 = Color3.fromRGB(90, 85, 120)
		end
	end
end

local passInfo = {
	{ "DoubleCoins", "💰 2x Coins", "Double all creature income forever!" },
	{ "SuperSpeed", "🚀 Super Speed", "+8 permanent sprint speed boost!" },
	{ "CarryMore", "🎒 Carry +2", "Hold 2 extra creatures every run." },
	{ "VIP", "👑 VIP Pass", "+25% coins bonus & +2 extra stall slots." },
}
for _, info in ipairs(passInfo) do
	local key = info[1]
	local button = makeRow(pages.Passes, info[2], info[3], "BUY", Theme.Gold, function()
		if player:GetAttribute(key) then return end
		local id = Config.Passes[key]
		if id == 0 then
			warn("Set Config.Passes." .. key .. " to the real pass ID")
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, id)
	end)
	passRows[key] = button
	loadPrice(button, Config.Passes[key], Enum.InfoType.GamePass)
	player:GetAttributeChangedSignal(key):Connect(refreshPasses)
end
refreshPasses()

---------------------------------------------------------------------
-- Coins & Crates Tab (Robux)
---------------------------------------------------------------------
local ORDER = { "Common", "Uncommon", "Rare", "Epic", "Legendary" }
local function oddsText(weights)
	local total = 0
	for _, w in pairs(weights) do total += w end
	local parts = {}
	for _, rarity in ipairs(ORDER) do
		if weights[rarity] then
			local percent = math.floor(weights[rarity] / total * 1000 + 0.5) / 10
			table.insert(parts, string.format("%s %g%%", rarity, percent))
		end
	end
	return table.concat(parts, " | ")
end

local productInfo = {
	{ "CoinsSmall", "💰 Small Coin Pack", "Instant +" .. fmt(Config.CoinPackAmounts.CoinsSmall) .. " coins!" },
	{ "CoinsMedium", "💰 Medium Coin Pack", "Instant +" .. fmt(Config.CoinPackAmounts.CoinsMedium) .. " coins!" },
	{ "CoinsLarge", "💰 Large Coin Pack", "Instant +" .. fmt(Config.CoinPackAmounts.CoinsLarge) .. " coins!" },
	{ "LuckyCrate", "🎁 Lucky Crate", "Odds: " .. oddsText(Config.Crates.LuckyCrate) },
	{ "MegaCrate", "💎 Mega Crate", "Odds: " .. oddsText(Config.Crates.MegaCrate) },
}
for _, info in ipairs(productInfo) do
	local key = info[1]
	local button = makeRow(pages.Coins, info[2], info[3], "BUY", Theme.Gold, function()
		local id = Config.Products[key]
		if id == 0 then
			warn("Set Config.Products." .. key .. " to the real product ID")
			return
		end
		MarketplaceService:PromptProductPurchase(player, id)
	end)
	loadPrice(button, Config.Products[key], Enum.InfoType.Product)
end

---------------------------------------------------------------------
-- Codes Tab
---------------------------------------------------------------------
local codeBox = make("TextBox", {
	Size = UDim2.new(1, -6, 0, 48),
	BackgroundColor3 = Theme.Row,
	TextColor3 = Theme.Text,
	PlaceholderText = "Type code here...",
	PlaceholderColor3 = Theme.TextDim,
	Font = TITLE_FONT,
	TextSize = 20,
	Text = "",
	ClearTextOnFocus = false,
	LayoutOrder = 1,
}, pages.Codes)
round(codeBox, 12)
stroke(codeBox, Theme.Cyan, 2.5)

local redeemButton = make("TextButton", {
	Size = UDim2.new(1, -6, 0, 48),
	BackgroundColor3 = Theme.Green,
	TextColor3 = Color3.new(1, 1, 1),
	Font = TITLE_FONT,
	TextSize = 22,
	TextStrokeTransparency = 0,
	TextStrokeColor3 = Color3.fromRGB(10, 40, 15),
	Text = "REDEEM",
	LayoutOrder = 2,
}, pages.Codes)
round(redeemButton, 12)
stroke(redeemButton, Color3.new(1, 1, 1), 2.5)
animate(redeemButton)
redeemButton.Activated:Connect(function()
	playSfx("Click")
	Remotes.RedeemCode:FireServer(codeBox.Text)
end)

make("TextLabel", {
	Size = UDim2.new(1, -6, 0, 42),
	BackgroundTransparency = 1,
	TextWrapped = true,
	Font = BODY_FONT,
	TextSize = 14,
	TextColor3 = Theme.TextDim,
	Text = "Join our group & Discord for exclusive codes with every update!",
	LayoutOrder = 3,
}, pages.Codes)

setTab("Upgrades")
