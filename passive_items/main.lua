_G.MorePassiveItems = RegisterMod("More Passive Items", 1)
MorePassiveItems.RNG = RNG()

-- init
	local RNG = RNG()
-- APIs
	require("ItemRegistry")
	require("EIDRegistry")
-- Items
	require("Items/Scale.lua")
	require("Items/RockTumbler.lua")
	require("Items/Mars.lua")
	require("Items/Fireflower.lua")
	require("Items/TestItem.lua")

-- Sprite Attempt
local function GetScreenSize() -- By Kilburn himself.
    local room = Game():GetRoom()
    local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset

    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)

    return rx*2 + 13*26, ry*2 + 7*26
end

local mysprite = Sprite()
local testSprite = Sprite()
local center = Vector(0,0)
local posx,posy = GetScreenSize()

mysprite:Load("gfx/ui/halo.anm2", true)
mysprite:Play("Idle")

--testSprite:Load("gfx/ui/FrameTest.anm2", true)
--testSprite:Play("Idle")

function MorePassiveItems:RenderLayer()
	--mysprite:Render(Vector(posx*0.12,posy*0.9),center,center)
	--testSprite:Render(Vector(posx*0.12,posy*0.9),center,center)
end
MorePassiveItems:AddCallback(ModCallbacks.MC_POST_RENDER, MorePassiveItems.RenderLayer)

-- [[ Loading ]] --


MorePassiveItems:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
--[[
    local TotPlayers = Isaac.CountEntities(nil, EntityType.ENTITY_PLAYER, -1, -1)

    if TotPlayers == 0 then -- If the run just started
        if game:GetFrameCount() == 0 then -- not from save
        else -- from save
        end
    end
]]
MorePassiveItems.RNG:SetSeed(Game():GetSeeds():GetStartSeed(), 0)
end)

--[[
MC_POST_NEW_LEVEL and MC_PRE_GAME_EXIT

function MorePassiveItems:TearFired(tear)
	local InnerR, InnerG, InnerB = math.random(0, 100)/100, math.random(0, 100)/100, math.random(0, 100)/100
	local OuterR, OuterG, OuterB = math.random(-255, 255), math.random(-255, 255), math.random(-255, 255)

	local Alpha = 1 -- how see through is the tear? (0 = invis, 1 = completely vis)

	-- note: set Outer to 0,0,0 if you don't want an overlay color
	-- note2: set Inner to 1, 1, 1 to have a default inner tear color
	local col = Color(InnerR, InnerG, InnerB, Alpha, OuterR, OuterG, OuterB);
	tear:SetColor(col, -1, 1, false, false)
end
MorePassiveItems:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, MorePassiveItems.TearFired)

local flawless = require("flawlessAPI")
flawless:init(MorePassiveItems)

function MorePassiveItems:RoomCleared()
	print("Flawless return: ")
	print("Was Boss: " .. tostring(flawless.IsBoss))
	print("Was MiniBoss: " .. tostring(flawless.IsMiniBoss))
	print("# Of Bosses: " .. flawless.ContainedBosses)
	print("# Of Enemies: " .. flawless.ContainedEnemies)
	print("Took Damage: " .. tostring(flawless.TookDamage))
	print("Boss Id: " .. flawless.BossId)
	--game:Spawn(type, type's subtype, spawnPos, Momement, Controller, SubType Variant)
	--game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, room:GetCenterPos(), Vector(0,0), nil, 100)
end

flawless:AddCallback(MorePassiveItems.RoomCleared)
]]--
