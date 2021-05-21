local chars = {
  SoulHearts = {
    PlayerType.PLAYER_XXX,
    PlayerType.PLAYER_XXX_B,
    PlayerType.PLAYER_BETHANY,
    PlayerType.PLAYER_THEFORGOTTEN_B
  },
  BlackHearts = PlayerType.PLAYER_JUDAS_B,
  BoneHearts = PlayerType.PLAYER_THEFORGOTTEN,
  Flies = PlayerType.PLAYER_THELOST_B,
  Blanket = PlayerType.PLAYER_THELOST
}

--TODO: Added a reward for tainted keeper

local function GiveReward(player)
  local type = player:GetPlayerType()

  if (type == chars.BlackHearts) then
    player:AddBlackHearts(4)
  elseif (type == chars.BoneHearts) then
    player:BoneHearts(2)
  elseif (type == chars.Flies) then
    player:AddBlueFlies ( 3, player.Position, nil)
  elseif (type == chars.Blanket) then
    return CollectibleType.COLLECTIBLE_BLANKET
  else
    for i = 1, #chars.SoulHearts do
      if (type == chars.SoulHearts[i]) then
        player:AddSoulHearts(4)
        return 0
      end
    end

    player:AddMaxHearts(2, true)
  end

  return 0
end

return GiveReward
