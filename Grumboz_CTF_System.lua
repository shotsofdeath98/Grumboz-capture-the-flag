-- Grumbo'z Capture The Flag System
-- by slp13at420 of EmuDevs.com
-- For Trinity Core 2 3.3.5a
-- simple system that will randomly spawn a world flag at different locations.
-- your job is to get your team flag to the world flag and tag it.

print("\n***********************************")
print("******* Grumbo'z CTF System *******")
print("* Capture The Flag System Loading *")

local flag_id = 600000
local CTF_timer = 1800000 -- in ms. :: Default = 1800000 :: 300000 = 5 minutes // 600000 = 10 minutes // 900000 = 15 minutes //  1800000 = 30 minutes

local team_flag_loc = {
		[1] = {flag_id, 0, -4857.419434, -1032.148804, 502.190125, 5.370824}, -- ally King's Hall
		[2] = {flag_id+1, 1, 1920.868042, -4142.223633, 40.614372, 4.802613}, -- horde King's Hall
			};

local World_flag_loc = {
		[1] = {0, -13327.975586, -342.763367, 14.706733, 2.067787}, -- central flag location Crystalein cave
		[2] = {530, -1863.494751, 5430.419434, -7.748078, 2.067787}, -- central flag location Shattrath
		[3] = {0, -7303.852539, -1063.009888, 277.069305, 6.033762}, -- central flag location BlackRock Mountain
		[4] = {1, -1030.969238, 1790.895264, 65.066193, 5.895199}, -- central flag location Desolace
		[5] = {1, -6611.236328, -1429.580200, -268.325745, 3.924639}, -- central flag location Lakkari Tar Pits
		[6] = {1, -3032.970947, -3087.337646, 66.752686, 5.794240}, -- central flag location Dustwallow Marsh
		[7] = {530, -424.795105, 1661.167969, 57.115944, 0.642495}, -- central flag location The Legion Front
		[8] = {530, -722.230864, 5513.937012, 23.676741, 0.961376}, -- central flag location ZangarMarsh
		[9] = {530, 3523.850586, 2934.691406, 137.001068, 3.845476}, -- central flag location Eco-Dome Midrealm
		[10] = {571, 2649.121826, 317.876343, 93.201843, 6.254735}, -- central flag location The Frozen Sea
		[11] = {571, 6149.879395, 5117.969727, -97.113358, 2.221082}, -- central flag location MistWhisper Refuge
			}; -- add more key locations so the world flag will jump around the world randomly.

local World_CTF = {
		alliance = nil,
		horde = nil,
		team = nil,
		team_name = {
			[1] = "Alliance", 
			[2] = "Horde"
					},
			};

local function GetTeamName(team)
	if(team == 0)then return "Alliance" else return "Horde"; end
end

local function RemoveFlag(event, duration, cycle, go)
	 go:Despawn()
	 go:RemoveFromWorld()
end

local function Spawn_Team_Flags(team)

local flag_id, map, x, y, z, o = table.unpack(team_flag_loc[team])

PerformIngameSpawn(2, flag_id, map, 0, x, y, z, o)

end	

local function Spawn_World_Flag(team)

local loc = math.random(1, #World_flag_loc)
local map, x, y, z, o = table.unpack(World_flag_loc[loc])
local flag = (flag_id + 1)+team

PerformIngameSpawn(2, flag, map, 0, x, y, z, o)

end

local function Spawn_Flags()

Spawn_Team_Flags(1)
Spawn_Team_Flags(2)

	if(World_CTF.team)then
		Spawn_World_Flag(World_CTF.team)
		SendWorldMessage("The "..World_CTF.team_name[World_CTF.team].."'s World Flag has been placed.")
		SendWorldMessage("Time to Find that World Flag for your team's honor.")
	else
		Spawn_World_Flag(3)
	end
end

Spawn_Flags()

print("******** Team Flags Spawned *******")
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
		World_CTF.team = (player:GetTeam()+1)
		go:RegisterEvent(RemoveFlag, 1, 1)
		player:RemoveAura(23333)
		player:RemoveAura(23335)
		local pause = CreateLuaEvent(Spawn_Flags, CTF_timer, 1)
		SendWorldMessage("The "..World_CTF.team_name[player:GetTeam()+1].." have Captured The World Flag.")
	else
	end
end

RegisterGameObjectGossipEvent(flag_id+2, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+3, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+4, 1, Tag_World_Flag)

local function Player_Change_Zone(event, player, newZone, newArea)

	if((player:GetGUIDLow() == World_CTF.alliance)or(player:GetGUIDLow() == World_CTF.horde))then

		if(player:GetTeam() == 0)then player:AddAura(23335, player); end
		if(player:GetTeam() == 1)then player:AddAura(23333, player); end
	end
end

RegisterPlayerEvent(27, Player_Change_Zone)

local function ReturnFlag(player)

	if((player:GetGUIDLow() == World_CTF.alliance)or(player:GetGUIDLow() == World_CTF.horde))then

		if(player:GetTeam() == 0)then World_CTF.alliance = nil Spawn_Team_Flags(player:GetTeam()+1) player:RemoveAura(23335); end
		if(player:GetTeam() == 1)then World_CTF.horde = nil Spawn_Team_Flags(player:GetTeam()+1) player:RemoveAura(23333); end
	end
end

local function Team_Flag_Holder_Died(event, killer, player)
	ReturnFlag(player)
end

RegisterPlayerEvent(8, Team_Flag_Holder_Died)
RegisterPlayerEvent(6, Team_Flag_Holder_Died)

local function PlayerLogOut(event, player)
	ReturnFlag(player)
end

RegisterPlayerEvent(4, PlayerLogOut)

print("** Capture The Flag System ready **")
print("***********************************\n")
