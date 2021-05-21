local BetterRewards = RegisterMod("Better Rewards", 1)
local json = require("json")
local rush = require("BossRushReward")

-- [[ init ]] --
local state = {
  DidBossRush = false,
  DidHush = false,
  DidVoid = false,
  GotKey = false,
  DidSatan = false,
  Won = false
}

local mapItems = {
  CollectibleType.COLLECTIBLE_TREASURE_MAP,
  CollectibleType.COLLECTIBLE_BLUE_MAP,
  CollectibleType.COLLECTIBLE_COMPASS
}

local Game = Game()
local room = Game:GetRoom()
local pool = Game:GetItemPool()
local config = Isaac.GetItemConfig()
local CanSave = false
local Zero = Vector.Zero or Vector(0, 0)

-- [[ Helper Funcs ]] --
local function GetRoomItem(defaultPool, AllowActives, MinQuality)
  defaultPool = defaultPool or ItemPoolType.POOL_GOLDEN_CHEST
  MinQuality = MinQuality or 0
  if AllowActives == nil then
    AllowActives = true
  end

  local itemType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
  itemType = itemType > - 1 and itemType or defaultPool
  local collectible = pool:GetCollectible(itemType)

  if (not AllowActives or MinQuality > 0) then
    local itemConfig = config:GetCollectible(collectible)
    local active = (AllowActives == true) and true or itemConfig.Type == ItemType.ITEM_PASSIVE
    local quality = MinQuality == 0 and true or itemConfig.Quality >= MinQuality
    while (not quality and not active) do
      collectible = pool:GetCollectible(itemType)
      itemConfig = config:GetCollectible(collectible)
      active = (AllowActives == true) and true or itemConfig.Type == ItemType.ITEM_PASSIVE
      quality = MinQuality == 0 and true or itemConfig.Quality >= MinQuality
    end
  end

  return collectible
end

local function SaveGame()
  if not CanSave then return end

  BetterRewards:SaveData(json.encode(state))
end

local function LoadGame()
  local load
  if BetterRewards:HasData() then
    local st = json.decode(BetterRewards:LoadData())
    if (st.DidSatan == nil) then
      print("Bad save data for Better_Rewards")
      print("Resetting, you will not receive any rewards from last run")
      print("Sorry!")
      return
    end
    state = st
  end
end

local GridPositions = {}

local function GiveRewards(player)
  if not state.Won then return end

  if state.DidBossRush then
    local reward = rush(player)
    if (reward ~= 0) then
      Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, reward, GridPositions.TopLeft, Zero, nil)
    end
  end

  if state.DidHush then
    local collectible = GetRoomItem(ItemPoolType.POOL_TREASURE, false)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, GridPositions.TopRight, Zero, nil)
  end

  if state.DidVoid then
    local collectible = GetRoomItem(ItemPoolType.POOL_TREASURE, false, 3)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, GridPositions.BottomLeft, Zero, nil)
  end

  if state.GotKey then
    local collectible = mapItems[RNG():RandomInt(#mapItems)]
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, GridPositions.BottomRight, Zero, nil)
  end

  if state.DidSatan then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_JOKER, room:GetCenterPos(), Zero, nil)
  end
end
-- [[ Loading ]] --

BetterRewards:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContin)
  LoadGame()
  room = Game:GetRoom()

  -- SpawnPositions
  GridPositions.TopLeft = room:GetGridPosition(16)
  GridPositions.TopRight = room:GetGridPosition(28)
  GridPositions.BottomLeft = room:GetGridPosition(106)
  GridPositions.BottomRight = room:GetGridPosition(118)

  if (not isContin) then
    local players = Isaac.FindByType(EntityType.ENTITY_PLAYER)
    for i, v in pairs(players) do
      GiveRewards(v:ToPlayer())
    end
    for i, v in pairs(state) do
      state[i] = false
    end
  end

  CanSave = true
  SaveGame()
end)

BetterRewards:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, command, args)
  if (command == "BRReward") then
  for i, v in pairs(state) do
    state[i] = true
  end
  GiveRewards(Isaac.GetPlayer(0))
  for i, v in pairs(state) do
    state[i] = false
  end
end
--TODO: Add debug cmds
end)

-- [[ Saving ]] --
BetterRewards:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(_)
SaveGame()
end)

BetterRewards:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_)
SaveGame()
end)

-- [[ Checking Won State ]] --
BetterRewards:AddCallback(ModCallbacks.MC_POST_GAME_END, function(_, Died)
if not Died then
state.DidBossRush = Game:GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
state.DidHush = Game:GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
state.Won = true;
end
end)

-- [[ Checking Key State On Next Floor ]] --
BetterRewards:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
if (state.GotKey) then return end
for i = 0, Game:GetNumPlayers() - 1 do
local player = Isaac.GetPlayer(i)
if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) and player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
  state.GotKey = true
end
end
end)

BetterRewards:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, NPC)
state.DidVoid = true
end, EntityType.ENTITY_DELIRIUM)

BetterRewards:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, NPC)
state.DidSatan = true
end, EntityType.ENTITY_MEGA_SATAN_2)
