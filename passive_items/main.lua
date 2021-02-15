_G.MorePassiveItems = RegisterMod("More Passive Items", 1)
local MyMod = _G.MorePassiveItems

-- init
local game = Game()
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
local items = {
	bombs = 0,
	keys = 0,
	coins = 0,
	firstset = true
}
--local flawless = require("flawlessAPI")
--flawless:init(MyMod)

-- collectibles
local Tumbler = Isaac.GetItemIdByName("Rock Tumbler")
local Scale = Isaac.GetItemIdByName("Scale")

-- utils
local function IsGridType(ent)
	for i = 1, #destroyTypes do
		if (ent == destroyTypes[i]) then
			return true
		end
	end
	return false
end

local function destroyRocks(level)
	local curroom = level:GetCurrentRoom()
	local size = curroom:GetGridSize()
	if not curroom:IsFirstVisit() then return end

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

-- callbacks
function MyMod:PostPlayerInit(newPlayer)
	game = Game()
	level = game:GetLevel()
	stage = level:GetStage()
	room = game:GetRoom()
end
MyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyMod.PostPlayerInit)

function MyMod:NewRoomEntered()
	for p = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(p)
		
		if player:HasCollectible(Tumbler) then
			destroyRocks(game:GetLevel())
		end
	end
end
MyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MyMod.NewRoomEntered)

function MyMod:PlayerUpdate(player)
	if player:HasCollectible(Scale) then
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
MyMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MyMod.PlayerUpdate)

--[[
function MyMod:RoomCleared()
	print("Flawless return: ")
	print("Was Boss: " .. tostring(flawless.IsBoss))
	print("Was MiniBoss: " .. tostring(flawless.IsMiniBoss))
	print("# Of Bosses: " .. flawless.ContainedBosses)
	print("# Of Enemies: " .. flawless.ContainedEnemies)
	print("Took Damage: " .. tostring(flawless.TookDamage))
	--game:Spawn(type, type's subtype, spawnPos, Momement, Controller, SubType Variant)
	--game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, room:GetCenterPos(), Vector(0,0), nil, 100)
end

flawless:AddCallback(MyMod.RoomCleared)
]]