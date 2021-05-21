local registry = require("ItemRegistry")
local col = Color(1,0.937254901960784,0.329411764705882, 1, 239, 87, 82)
-- TODO MAGIC MUSH SYNERGY +1.5x chance

MorePassiveItems:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider)
	local parent = tear.Parent:ToPlayer() or tear.Parent:ToFamiliar().Player
	if (collider:IsActiveEnemy(false) and tear:GetData()["IsFireFlower"]) then
		collider:AddBurn(EntityRef(parent), 102, 1)
	end
end)

MorePassiveItems:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
	local chance = MorePassiveItems.RNG:RandomInt(100)
	local parent = tear.Parent:ToPlayer()
	if chance <= 10 and parent:HasCollectible(registry.Fireflower) then
		tear:SetColor(col, -1, 1, false, false)
		tear:GetData()["IsFireFlower"] = true
	end
end)