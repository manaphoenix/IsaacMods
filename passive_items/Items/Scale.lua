local registry = require("ItemRegistry")

local items = {
	bombs = 0,
	keys = 0,
	coins = 0,
	firstset = true
}

local function setPickups(player, count)
	player:AddCoins(-99)
	player:AddBombs(-99)
	player:AddKeys(-99)
	player:AddCoins(count)
	player:AddBombs(count)
	player:AddKeys(count)
	items.bombs = count
	items.keys = count
	items.coins = count
end

function MorePassiveItems:PlayerUpdate(player)
	if player:HasCollectible(registry.Scale) then
		local bombs = player:GetNumBombs()
		local coins = player:GetNumCoins()
		local keys = player:GetNumKeys()
		if items.firstset then
			local count = 0
			count = (count < coins and coins) or (count < keys and keys) or bombs
			setPickups(player, count)
			items.firstset = false
		else
			if bombs ~= items.bombs then
				setPickups(player, bombs)
			elseif coins ~= items.coins then
				setPickups(player, coins)
			elseif keys ~= items.keys then
				setPickups(player, keys)
			end
		end
	end
end
MorePassiveItems:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MorePassiveItems.PlayerUpdate)