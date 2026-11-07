local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

if not RunService:IsStudio() then
	return
end

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local function check(kind, list, infoType)
	for name, id in pairs(list) do
		if id == 0 then
			warn(kind .. " " .. name .. ": ID is still 0 (not set)")
		else
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(id, infoType)
			end)
			if ok and info then
				print(kind .. " " .. name .. ": OK -> " .. tostring(info.Name) .. " (" .. tostring(info.PriceInRobux) .. " R$)")
			else
				warn(kind .. " " .. name .. ": ID " .. id .. " not found. Check the number.")
			end
		end
	end
end

check("Pass", Config.Passes, Enum.InfoType.GamePass)
check("Product", Config.Products, Enum.InfoType.Product)
