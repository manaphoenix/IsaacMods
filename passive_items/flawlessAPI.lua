--[[ this API returns information about how a room was beaten
Included:
	- IsBossRoom
	- IsMiniBoss
	- Number of bosses contained in room (does not count post-spawned)
	- Number of enemies contained in room (does not count post-spawned)
	- TookDamage
]]--

local flawless = {
	IsBoss = false,
	IsMiniBoss = false,
	ContainedBosses = 0,
	ContainedEnemies = 0,
	TookDamage = false
}

local cleared  = false
local isready = false
local callbacks = {}

function flawless:AddCallback(func)
	table.insert(callbacks, func)
end

function flawless:init(mod)
	local mod = mod
	local room = Game():GetRoom()
	
	function mod:ResetInfo()
		room = Game():GetRoom()
		local roomtype = room:GetType()
		cleared = false
		
		flawless.IsBoss = roomtype == RoomType.ROOM_BOSS
		flawless.IsMiniBoss = roomtype == RoomType.ROOM_MINIBOSS
		flawless.ContainedBosses = room:GetAliveBossesCount()
		flawless.ContainedEnemies = room:GetAliveEnemiesCount()
		flawless.TookDamage = false
		isready = true
	end
	mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.ResetInfo)
	
	function mod:DamageTaken(ent, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames, entType)
		if DamageAmount > 0 and not flawless.TookDamage and not room:IsClear() then
			flawless.TookDamage = true
		end
	end
	mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.DamageTaken, EntityType.ENTITY_PLAYER)
	
	function mod:CheckRoomDone(ent)
		if room:IsClear() and room:IsFirstVisit() and not cleared and isready then
			cleared = true
			isready = false
			if #callbacks > 0 then
				for i = 1, #callbacks do
					callbacks[i]()
				end
			end
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, mod.CheckRoomDone)
end

return flawless