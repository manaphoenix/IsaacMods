local registry = require("ItemRegistry")

MorePassiveItems:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function (_, tear)
	local p = tear.SpawnerEntity
	if (p:ToPlayer()) then
		p = p:ToPlayer()
		if (p:HasCollectible(registry.TestItem, true)) then
			tear:Remove()
			p:AddBlueFlies(1, p.Position, nil)
		end
	end
end)

MorePassiveItems:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cache)
		if (cache & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR and player:HasCollectible(registry.TestItem, true)) then
			player.TearColor = Color(1, 1, 1, 0, 0, 0, 0) --R,G,B,A,RO,GO,BO
		end
end)
