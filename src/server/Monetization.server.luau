local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local DataService = require(script.Parent.DataService)
local GameService = require(script.Parent.GameService)

-- Game passes: activate instantly after purchase
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if not wasPurchased then
		return
	end
	for name, id in pairs(Config.Passes) do
		if id ~= 0 and id == passId then
			GameService.ApplyPass(player, name)
		end
	end
end)

-- Developer products (can be bought many times)
local handlers = {}

local function register(name, fn)
	local id = Config.Products[name]
	if id and id ~= 0 then
		handlers[id] = fn
	end
end

for _, packName in ipairs({ "CoinsSmall", "CoinsMedium", "CoinsLarge" }) do
	register(packName, function(player)
		GameService.GiveCoins(player, Config.CoinPackAmounts[packName])
		GameService.Notify(player, "+" .. Config.CoinPackAmounts[packName] .. " coins!")
	end)
end
register("LuckyCrate", function(player)
	GameService.OpenCrate(player, "LuckyCrate")
end)
register("MegaCrate", function(player)
	GameService.OpenCrate(player, "MegaCrate")
end)

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = DataService.Get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- never give the same purchase twice
	local key = tostring(receipt.PurchaseId)
	if data.Receipts[key] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local handler = handlers[receipt.ProductId]
	if not handler then
		warn("No handler for product", receipt.ProductId, "- did you paste the IDs into Config?")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok, err = pcall(handler, player)
	if not ok then
		warn(err)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	data.Receipts[key] = true
	if DataService.Save(player) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end
