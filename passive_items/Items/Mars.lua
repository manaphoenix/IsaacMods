local registry = require("ItemRegistry")
local game = Game()
local isBoss = false
local isMiniBoss = false
local damage = 0

-- TODO: Add synergy +3 dmg from conquest.

MorePassiveItems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local room = game:GetRoom()
	local roomType = room:GetType()
	if roomType == RoomType.ROOM_BOSS then
		isBoss = true
	elseif roomType == RoomType.ROOM_MINIBOSS then
		isMiniBoss = true
	else
		isBoss = false
		isMiniBoss = false
	end
end)

MorePassiveItems:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	if npc:IsBoss() and (isBoss or isMiniBoss) then
		if isMiniBoss then
			damage = damage + 0.3
		elseif isBoss then
			damage = damage + 1
		end
		isBoss = false
		isMiniBoss = false
	end
end)

MorePassiveItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cache)
	if (damage > 0) and player:HasCollectible(registry.Mars) then
		if cache == CacheFlag.CACHE_DAMAGE then
			local DamageMultiplier = (player.Damage > 3.5 and 3.5 / player.Damage or player.Damage / 3.5)
			player.Damage = player.Damage + (damage * DamageMultiplier)
		end
	else
		damage = 0
	end
end)
