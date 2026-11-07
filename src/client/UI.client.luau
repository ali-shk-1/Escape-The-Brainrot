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
-- Theme
---------------------------------------------------------------------
local Theme = {
	Bg = Color3.fromRGB(22, 18, 45),
	Panel = Color3.fromRGB(36, 30, 72),
	Row = Color3.fromRGB(50, 42, 98),
	Pink = Color3.fromRGB(255, 77, 166),
	Cyan = Color3.fromRGB(56, 224, 255),
	Gold = Color3.fromRGB(255, 200, 60),
	Green = Color3.fromRGB(74, 222, 128),
	Red = Color3.fromRGB(255, 59, 92),
	Text = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(190, 180, 230),
	Dark = Color3.fromRGB(20, 20, 30),
}
local TITLE_FONT = Enum.Font.FredokaOne
local BODY_FONT = Enum.Font.GothamMedium

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
		Thickness = thickness or 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

local function gradient(inst, c1, c2, rotation)
	make("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rotation or 90 }, inst)
end

-- 1234 -> "1,234", 25000 -> "25.0K", 3200000 -> "3.20M"
local function fmt(n)
	n = math.floor(n)
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
	sound.Volume = 0.6
	sound.Parent = SoundService
	sound:Play()
	Debris:AddItem(sound, 5)
end

-- hover and press "pop" animation
local function animate(button)
	local scale = make("UIScale", { Scale = 1 }, button)
	local function to(value)
		TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function() to(1.06) end)
	button.MouseLeave:Connect(function() to(1) end)
	button.MouseButton1Down:Connect(function() to(0.94) end)
	button.MouseButton1Up:Connect(function() to(1.06) end)
end

---------------------------------------------------------------------
-- Screens
---------------------------------------------------------------------
local gui = make("ScreenGui", { Name = "EscapeUI", ResetOnSpawn = false }, playerGui)
local fxGui = make("ScreenGui", { Name = "EscapeFX", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10 }, playerGui)

local flash = make("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, fxGui)

local function flashScreen(color)
	flash.BackgroundColor3 = color
	flash.BackgroundTransparency = 0.7
	TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
end

local function shakeCamera(duration, strength)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
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
		shakeCamera(0.4, 1.2)
	end
end)

---------------------------------------------------------------------
-- HUD: coin pill + carry pill
---------------------------------------------------------------------
local coinPill = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 8),
	Size = UDim2.fromOffset(230, 54),
	BackgroundColor3 = Theme.Panel,
}, gui)
round(coinPill, 27)
stroke(coinPill, Theme.Gold, 3)
gradient(coinPill, Theme.Panel, Theme.Bg, 90)

make("TextLabel", {
	Position = UDim2.fromOffset(10, 7),
	Size = UDim2.fromOffset(40, 40),
	BackgroundTransparency = 1,
	Text = "🪙",
	TextScaled = true,
}, coinPill)

local coinText = make("TextLabel", {
	Position = UDim2.fromOffset(56, 3),
	Size = UDim2.new(1, -66, 0, 31),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = TITLE_FONT,
	TextScaled = true,
	TextColor3 = Theme.Gold,
	Text = "0",
}, coinPill)

local incomeText = make("TextLabel", {
	Position = UDim2.fromOffset(56, 34),
	Size = UDim2.new(1, -66, 0, 16),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = BODY_FONT,
	TextSize = 14,
	TextColor3 = Theme.Green,
	Text = "+0/s",
}, coinPill)

local carryPill = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 68),
	Size = UDim2.fromOffset(200, 28),
	BackgroundColor3 = Theme.Panel,
	TextColor3 = Theme.Text,
	Font = TITLE_FONT,
	TextSize = 16,
	Text = "",
}, gui)
round(carryPill, 14)
stroke(carryPill, Theme.Cyan, 2)

local function refreshHud()
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	coinText.Text = fmt(coins and coins.Value or 0)
	incomeText.Text = "+" .. fmt(player:GetAttribute("IncomePerSec") or 0) .. "/s"
	carryPill.Text = string.format(
		"🎒 %d/%d     🏠 %d/%d",
		player:GetAttribute("CarryCount") or 0,
		player:GetAttribute("Capacity") or 1,
		player:GetAttribute("StoredCount") or 0,
		player:GetAttribute("Slots") or Config.BaseSlots
	)
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
-- Toast messages (slide in from the top)
---------------------------------------------------------------------
local toast = make("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, -70),
	Size = UDim2.new(0.9, 0, 0, 40),
	BackgroundColor3 = Theme.Pink,
	TextColor3 = Theme.Text,
	Font = TITLE_FONT,
	TextSize = 20,
	TextWrapped = true,
	Text = "",
}, gui)
make("UISizeConstraint", { MaxSize = Vector2.new(440, 60) }, toast)
round(toast, 20)
stroke(toast, Color3.new(1, 1, 1), 2)

local toastId = 0
Remotes:WaitForChild("Notify").OnClientEvent:Connect(function(text)
	toastId += 1
	local myId = toastId
	toast.Text = text
	TweenService:Create(
		toast,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, 104) }
	):Play()
	task.delay(3, function()
		if toastId == myId then
			TweenService:Create(toast, TweenInfo.new(0.25), { Position = UDim2.new(0.5, 0, 0, -70) }):Play()
		end
	end)
end)

---------------------------------------------------------------------
-- Shop window
---------------------------------------------------------------------
local shopButton = make("TextButton", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 0),
	Size = UDim2.fromOffset(110, 50),
	BackgroundColor3 = Theme.Pink,
	TextColor3 = Theme.Text,
	Font = TITLE_FONT,
	TextSize = 22,
	Text = "🛍 SHOP",
}, gui)
round(shopButton, 14)
stroke(shopButton, Color3.new(1, 1, 1), 3)
animate(shopButton)

local panel = make("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.92, 0.8),
	BackgroundColor3 = Theme.Bg,
	Visible = false,
}, gui)
make("UISizeConstraint", { MinSize = Vector2.new(280, 300), MaxSize = Vector2.new(480, 430) }, panel)
round(panel, 18)
stroke(panel, Theme.Pink, 3)
gradient(panel, Theme.Panel, Theme.Bg, 90)
local panelScale = make("UIScale", { Scale = 1 }, panel)

make("TextLabel", {
	Position = UDim2.fromOffset(14, 8),
	Size = UDim2.new(1, -70, 0, 34),
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = TITLE_FONT,
	TextSize = 26,
	TextColor3 = Theme.Text,
	Text = "🛍 MALL SHOP",
}, panel)

local closeButton = make("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 8),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = Theme.Red,
	TextColor3 = Theme.Text,
	Font = TITLE_FONT,
	TextSize = 20,
	Text = "✕",
}, panel)
round(closeButton, 17)
animate(closeButton)

local shopOpen = false
local function setShop(open)
	shopOpen = open
	playSfx("Click")
	if open then
		panel.Visible = true
		panelScale.Scale = 0.8
		TweenService:Create(
			panelScale,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	else
		local tween = TweenService:Create(panelScale, TweenInfo.new(0.15), { Scale = 0.8 })
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

-- tabs
local tabBar = make("Frame", {
	Position = UDim2.fromOffset(8, 48),
	Size = UDim2.new(1, -16, 0, 36),
	BackgroundTransparency = 1,
}, panel)
make("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
}, tabBar)

local pageHolder = make("Frame", {
	Position = UDim2.fromOffset(8, 92),
	Size = UDim2.new(1, -16, 1, -100),
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
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Pink,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Visible = false,
	}, pageHolder)
	make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	pages[def[1]] = page
end

-- one reusable row: title, description, buy button
local function makeRow(page, title, desc, buttonText, buttonColor, onClick)
	local row = make("Frame", {
		Size = UDim2.new(1, -6, 0, 72),
		BackgroundColor3 = Theme.Row,
		LayoutOrder = #page:GetChildren() + 1,
	}, page)
	round(row, 12)

	make("TextLabel", {
		Position = UDim2.fromOffset(10, 6),
		Size = UDim2.new(1, -130, 0, 24),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = TITLE_FONT,
		TextSize = 18,
		TextColor3 = Theme.Text,
		Text = title,
	}, row)

	local descLabel = make("TextLabel", {
		Position = UDim2.fromOffset(10, 30),
		Size = UDim2.new(1, -130, 0, 36),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Font = BODY_FONT,
		TextSize = 12,
		TextColor3 = Theme.Muted,
		Text = desc,
	}, row)

	local button = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(108, 46),
		BackgroundColor3 = buttonColor,
		TextColor3 = Theme.Dark,
		Font = TITLE_FONT,
		TextSize = 18,
		Text = buttonText,
	}, row)
	round(button, 10)
	animate(button)
	button.Activated:Connect(function()
		playSfx("Click")
		onClick()
	end)

	return button, descLabel
end

-- show real Robux prices from Roblox
local function loadPrice(button, id, infoType)
	if id == 0 then
		return
	end
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
-- Upgrades tab (coins)
---------------------------------------------------------------------
local upgradeRows = {}

local function refreshUpgrades()
	for key, row in pairs(upgradeRows) do
		local def = Config.Upgrades[key]
		local level = player:GetAttribute(key .. "Level") or 0
		row.desc.Text = string.format("Lv %d/%d - %s", level, def.Max, row.base)
		if level >= def.Max then
			row.button.Text = "MAX"
			row.button.BackgroundColor3 = Theme.Muted
		else
			row.button.Text = fmt(Config.UpgradeCost(key, level)) .. " 🪙"
			row.button.BackgroundColor3 = Theme.Green
		end
	end
end

local upgradeInfo = {
	{ "Speed", "⚡ Speed", "Run faster to escape the guard." },
	{ "Capacity", "🎒 Carry", "Carry more creatures per trip." },
	{ "Slots", "🏠 Stall Slots", "Store more creatures to earn more." },
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
-- Passes tab (Robux)
---------------------------------------------------------------------
local passRows = {}

local function refreshPasses()
	for key, button in pairs(passRows) do
		if player:GetAttribute(key) then
			button.Text = "OWNED ✔"
			button.BackgroundColor3 = Theme.Muted
		end
	end
end

local passInfo = {
	{ "DoubleCoins", "💰 2x Coins", "Double your income forever!" },
	{ "SuperSpeed", "🚀 Super Speed", "+8 walk speed. Outrun the guard!" },
	{ "CarryMore", "🎒 Carry +2", "Grab 2 more creatures every run." },
	{ "VIP", "👑 VIP", "+25% coins and +2 stall slots." },
}
for _, info in ipairs(passInfo) do
	local key = info[1]
	local button = makeRow(pages.Passes, info[2], info[3], "BUY", Theme.Gold, function()
		if player:GetAttribute(key) then
			return
		end
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
-- Coins and crates tab (Robux)
---------------------------------------------------------------------
local ORDER = { "Common", "Uncommon", "Rare", "Epic", "Legendary" }
local function oddsText(weights)
	local total = 0
	for _, w in pairs(weights) do
		total += w
	end
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
	{ "CoinsSmall", "💰 Small Coin Pack", "Get " .. fmt(Config.CoinPackAmounts.CoinsSmall) .. " coins instantly." },
	{ "CoinsMedium", "💰 Medium Coin Pack", "Get " .. fmt(Config.CoinPackAmounts.CoinsMedium) .. " coins instantly." },
	{ "CoinsLarge", "💰 Large Coin Pack", "Get " .. fmt(Config.CoinPackAmounts.CoinsLarge) .. " coins instantly." },
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
-- Codes tab
---------------------------------------------------------------------
local codeBox = make("TextBox", {
	Size = UDim2.new(1, -6, 0, 46),
	BackgroundColor3 = Theme.Row,
	TextColor3 = Theme.Text,
	PlaceholderText = "Type a code here...",
	PlaceholderColor3 = Theme.Muted,
	Font = TITLE_FONT,
	TextSize = 20,
	Text = "",
	ClearTextOnFocus = false,
	LayoutOrder = 1,
}, pages.Codes)
round(codeBox, 10)
stroke(codeBox, Theme.Cyan, 2)

local redeemButton = make("TextButton", {
	Size = UDim2.new(1, -6, 0, 46),
	BackgroundColor3 = Theme.Green,
	TextColor3 = Theme.Dark,
	Font = TITLE_FONT,
	TextSize = 20,
	Text = "REDEEM",
	LayoutOrder = 2,
}, pages.Codes)
round(redeemButton, 10)
animate(redeemButton)
redeemButton.Activated:Connect(function()
	playSfx("Click")
	Remotes.RedeemCode:FireServer(codeBox.Text)
end)

make("TextLabel", {
	Size = UDim2.new(1, -6, 0, 40),
	BackgroundTransparency = 1,
	TextWrapped = true,
	Font = BODY_FONT,
	TextSize = 13,
	TextColor3 = Theme.Muted,
	Text = "Join our group and Discord for new codes with every update!",
	LayoutOrder = 3,
}, pages.Codes)

setTab("Upgrades")
