-- Grumbo'z Capture The Flag System
-- by slp13at420 of EmuDevs.com
-- For Trinity Core 2 3.3.5a
-- simple system that will randomly spawn a world flag at different locations.
-- your job is to get your team flag to the world flag and tag it.

print("\n***********************************")
print("******* Grumbo'z CTF System *******")
print("* Capture The Flag System Loading *")

local flag_id = 600000

local team_flag_loc = {
		[1] = {flag_id, map, x, y, z, o}, -- ally flag location
		[2] = {flag_id+1, map, x, y, z, o}, -- horde flag location
			};

local World_flag_loc = {
		[1] = {map, x, y, z, o}, -- central flag location
			};

local World_CTF = {
		alliance = 0,
		horde = 0,
		flag_guid = nil,
			};

local function RemoveFlag(event, duration, cycle, go)
	 go:Despawn()
	 go:RemoveFromWorld()
end

local function Spawn_Team_Flags(team)

local flag_id, map, x, y, z, o = table.unpack(team_flag_loc[team])
	
PerformIngameSpawn(2, flag_id, map, 0, x, y, z, o)

end

Spawn_Team_Flags(1)
Spawn_Team_Flags(2)

print("******** Team Flags Spawned *******")

local function Spawn_World_Flag(team)

local map, x, y, z, o = table.unpack(World_flag_loc[1])
local flag = (flag_id + 1)+team
	
PerformIngameSpawn(2, flag, map, 0, x, y, z, o)

end

Spawn_World_Flag(3)

print("******** World Flag Spawned *******")

local function Tag_Ally_Flag(event, player, go)

	if(player:GetTeam() == 0)then World_CTF.alliance = player:GetGUIDLow()
		player:AddAura(23335, player)
		go:RegisterEvent(RemoveFlag, 1, 1)
	end
end

local function Tag_Horde_Flag(event, player, go)

	if(player:GetTeam() == 1)then World_CTF.horde = player:GetGUIDLow()
		player:AddAura(23333, player)
		go:RegisterEvent(RemoveFlag, 1, 1)
	end
end

RegisterGameObjectGossipEvent(flag_id, 1, Tag_Ally_Flag)
RegisterGameObjectGossipEvent(flag_id+1, 1, Tag_Horde_Flag)

local function Tag_World_Flag(event, player, go)

	if((player:GetGUIDLow() == World_CTF.alliance)or(player:GetGUIDLow() == World_CTF.horde))then
		World_CTF.alliance = 0
		World_CTF.horde = 0
		go:RegisterEvent(RemoveFlag, 1, 1)
		Spawn_World_Flag(player:GetTeam()+1)
		player:RemoveAura(23333)
		player:RemoveAura(23335)
	else
	end
end

RegisterGameObjectGossipEvent(flag_id+2, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+3, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+4, 1, Tag_World_Flag)


local function Team_Flag_Holder_Died(event, killer, victim)

	if((victim:GetGUIDLow() == World_CTF.alliance)or(victim:GetGUIDLow() == World_CTF.horde))then
		if(victim:GetTeam() == 0)then World_CTF.alliance = nil Spawn_Team_Flags(victim:GetTeam()+1); end
		if(victim:GetTeam() == 1)then World_CTF.horde = nil Spawn_Team_Flags(victim:GetTeam()+1); end
	end
end

RegisterPlayerEvent(6, Team_Flag_Holder_Died)
RegisterPlayerEvent(8, Team_Flag_Holder_Died)

print("** Capture The Flag System ready **")
print("***********************************\n")
