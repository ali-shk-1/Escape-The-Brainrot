local Config = {}

Config.GameName = "Escape the Brainrot"

Config.Player = {
	WalkSpeed = 30,
	JumpPower = 50,
}

Config.Player.BaseCapacity = 1 -- creatures you can carry (upgrades come in M5)

Config.Rarities = {
	Common    = { Color = Color3.fromRGB(201, 209, 217), Scale = 1.0,  LightBrightness = 0,   Outline = false, Particles = 0 },
	Uncommon  = { Color = Color3.fromRGB(74, 222, 128),  Scale = 1.1,  LightBrightness = 0.6, Outline = false, Particles = 0 },
	Rare      = { Color = Color3.fromRGB(56, 189, 248),  Scale = 1.25, LightBrightness = 1.2, Outline = true,  Particles = 0 },
	Epic      = { Color = Color3.fromRGB(192, 132, 252), Scale = 1.4,  LightBrightness = 2,   Outline = true,  Particles = 6 },
	Legendary = { Color = Color3.fromRGB(251, 191, 36),  Scale = 1.6,  LightBrightness = 3,   Outline = true,  Particles = 14 },
}

-- Income = coins per second while stored in a stall (used from M3)
Config.Creatures = {
	SirNoodleSneakers     = { Name = "Sir Noodle Sneakers",         Rarity = "Common",    Income = 1 },
	BonkoBananaBoots      = { Name = "Bonko Banana Boots",          Rarity = "Common",    Income = 2 },
	CaptainToastini       = { Name = "Captain Toastini",            Rarity = "Uncommon",  Income = 5 },
	SprinkleGoblin        = { Name = "Sprinkle Goblin",             Rarity = "Uncommon",  Income = 7 },
	WobbloBubbleMonk      = { Name = "Wobblo the Bubble Tea Monk",  Rarity = "Rare",      Income = 20 },
	DiscoDumpling         = { Name = "Disco Dumpling",              Rarity = "Rare",      Income = 25 },
	TurboTacoWizard       = { Name = "Turbo Taco Wizard",           Rarity = "Epic",      Income = 80 },
	CheesePharaoh         = { Name = "Cheese Pharaoh",              Rarity = "Epic",      Income = 100 },
	MegaPickleDuchess     = { Name = "Mega Pickle Duchess",         Rarity = "Legendary", Income = 400 },
	GalacticSpaghettiKing = { Name = "Galactic Spaghetti King",     Rarity = "Legendary", Income = 600 },
}

-- What can spawn on a pad, by its "Tier" attribute (weights, not percentages)
Config.TierRarities = {
	[1] = { Common = 70, Uncommon = 30 },
	[2] = { Uncommon = 40, Rare = 45, Epic = 15 },
	[3] = { Rare = 30, Epic = 50, Legendary = 20 },
}

Config.Spawn = {
	Interval = 6,    -- seconds between spawns
	MaxActive = 16,  -- max creatures in the mall at once
	Lifetime = 75,   -- seconds before an ungrabbed creature disappears
}

Config.BaseSlots = 3      -- slots a new player starts with
Config.MaxSlotParts = 12  -- Slot1..Slot12 exist in every base

Config.Upgrades = {
	Speed    = { Max = 10, BaseCost = 150, Growth = 1.7 },
	Capacity = { Max = 4,  BaseCost = 500, Growth = 3.0 },
	Slots    = { Max = 7,  BaseCost = 300, Growth = 1.8 },
}

function Config.UpgradeCost(name, level)
	local def = Config.Upgrades[name]
	return math.floor(def.BaseCost * def.Growth ^ level)
end

-- Redeem codes (name -> coins). Add new ones each update.
Config.Codes = {
	RELEASE = 1000,
	ESCAPE = 2500,
}

-- Paid crates. The shop shows these odds to players (required for paid random items).
Config.Crates = {
	LuckyCrate = { Common = 40, Uncommon = 30, Rare = 20, Epic = 9, Legendary = 1 },
	MegaCrate  = { Uncommon = 30, Rare = 40, Epic = 25, Legendary = 5 },
}

-- IMPORTANT: replace each 0 with the real ID from Creator Hub (step 6)
Config.Passes = {
	DoubleCoins = 2074581548,
	SuperSpeed  = 2076273496,
	CarryMore   = 2075937536,
	VIP         = 2075577487,
}

Config.Products = {
	CoinsSmall  = 3729299723,
	CoinsMedium = 3729299951,
	CoinsLarge  = 3729300342,
	LuckyCrate  = 3729300491,
	MegaCrate   = 3729300689,
}

Config.CoinPackAmounts = {
	CoinsSmall  = 2500,
	CoinsMedium = 15000,
	CoinsLarge  = 75000,
}

Config.Sounds = {
	Grab = 9069609200,
	Deposit = 9069608933,
	Caught = 9069609503,
	Upgrade = 9069609071,
	Legendary = 9069608581,
	Click = 6895079853,
	Whistle = 9114223171,   -- guard whistle (3D, played by GuardAudio)
	Footstep = 9114223499,  -- guard footsteps loop (3D, played by GuardAudio)
}

-- Background music. Id = 0 means that track is skipped.
-- Volume is the track's own loudness (0 to 1). MasterVolume scales all music.
Config.Music = {
	MasterVolume = 1,
	FadeTime = 2.5,       -- seconds to crossfade between zones
	ChaseFadeTime = 0.4,  -- chase music comes in fast
	ChaseHold = 3,        -- seconds chase music stays after the guard loses you
	ChaseRange = 90,      -- guard must be this close (studs) to trigger chase music
	DuckVolume = 0.35,    -- music drops to this fraction during stings
	DuckTime = 1.6,       -- seconds the music stays ducked

	Tracks = {
		Base        = { Id = 1843404009, Volume = 0.30 },
		FoodCourt   = { Id = 1848354536, Volume = 0.30 },
		Electronics = { Id = 1837849285, Volume = 0.30 },
		Vault       = { Id = 1837059999, Volume = 0.32 },
		Chase       = { Id = 1845554017, Volume = 0.38 },
	},
}

-- Daily reward: claim every 20 hours. Missing 48 hours resets the streak.
Config.Daily = {
	CooldownSeconds = 20 * 3600,
	ResetSeconds = 48 * 3600,
	Rewards = {
		{ Coins = 500 },
		{ Coins = 1000 },
		{ Coins = 2000 },
		{ Coins = 4000 },
		{ Coins = 8000 },
		{ Coins = 15000 },
		{ Coins = 30000, Crate = "MegaCrate" }, -- day 7 bonus creature
	},
}

-- Rarity for weekly event creatures (extends the Config.Rarities table)
Config.Rarities.Event = { Color = Color3.fromRGB(255, 99, 214), Scale = 1.5, LightBrightness = 2.5, Outline = true, Particles = 10 }

-- Weekly event creatures. They never appear in normal spawns (they are not in Config.TierRarities),
-- only through EventService. Income is higher than Legendary.
Config.Creatures.GlitchyGelatoGhost   = { Name = "Glitchy Gelato Ghost",   Rarity = "Event", Income = 900 }
Config.Creatures.NinjaNuggetSensei    = { Name = "Ninja Nugget Sensei",    Rarity = "Event", Income = 1000 }
Config.Creatures.CosmicCorndogCaptain = { Name = "Cosmic Corndog Captain", Rarity = "Event", Income = 1100 }
Config.Creatures.HoloHotdogHero       = { Name = "Holo Hotdog Hero",       Rarity = "Event", Income = 1200 }

-- One creature per week, rotating in this order (the week number decides which one)
Config.Events = { "GlitchyGelatoGhost", "NinjaNuggetSensei", "CosmicCorndogCaptain", "HoloHotdogHero" }

Config.Event = {
	WeekSeconds = 7 * 24 * 3600,
	SpawnInterval = 60,  -- seconds between event spawn checks
	SpawnTier = 3,       -- spawns on Tier 3 pads (Basement Vault) when one is free
	MaxAtOnce = 1,       -- only one event creature in the mall at a time
}

-- Rebirth: reset coins, creatures and upgrades for a permanent coin multiplier
Config.Rebirth = {
	BaseCost = 250000,
	Growth = 2.2,
	Max = 20,
	BonusPerRebirth = 0.5, -- +50% coins per rebirth, permanent
	StartCoins = 500,      -- coins you start with after a rebirth
}

function Config.RebirthCost(count)
	return math.floor(Config.Rebirth.BaseCost * Config.Rebirth.Growth ^ count)
end

-- First-time player guide
Config.Tutorial = {
	UpgradeGift = 200,   -- coins given when the "buy an upgrade" step starts
	FinishReward = 1000, -- coins given when the tutorial is complete
}

return Config