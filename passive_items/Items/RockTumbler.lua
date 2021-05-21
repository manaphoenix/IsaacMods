local registry = require("ItemRegistry")

local destroyTypes = {
	GridEntityType.GRID_ROCK,
	GridEntityType.GRID_ROCKB,
	GridEntityType.GRID_ROCKT,
	GridEntityType.GRID_ROCK_BOMB,
	GridEntityType.GRID_ROCK_ALT,
	GridEntityType.GRID_SPIDERWEB,
	GridEntityType.GRID_LOCK,
	GridEntityType.GRID_TNT,
	GridEntityType.GRID_POOP,
	GridEntityType.GRID_DOOR,
	GridEntityType.GRID_ROCK_SS
}
local game = Game()

local function IsGridType(ent)
	for i = 1, #destroyTypes do
		if (ent == destroyTypes[i]) then
			return true
		end
	end
	return false
end

local function destroyRocks(curroom)
	if not curroom:IsFirstVisit() then return end
	local size = curroom:GetGridSize()
	
	for i = 0, size do
		local ent = curroom:GetGridEntity(i)
		if (ent ~= nil) then
			local typ = ent:GetType()
			if (IsGridType(typ)) then
				ent:Destroy()
				ent:Update()
			end
		end
	end
end

function MorePassiveItems:NewRoomEntered()
	for p = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		
		if player:HasCollectible(registry.Tumbler) then
			destroyRocks(game:GetRoom())
		end
	end
end
MorePassiveItems:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MorePassiveItems.NewRoomEntered)