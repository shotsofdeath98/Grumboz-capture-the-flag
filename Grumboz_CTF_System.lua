-- Grumbo'z Capture The Flag System - Wil-o-whisp -
-- by slp13at420 of EmuDevs.com
-- For Trinity Core 2 3.3.5a
-- A system that will randomly spawn a world flag at different locations.
-- your job is to get your team flag to the world flag and tag it.
-- with wil-o-whisp on. the world flag will randomly spawn in the world and players must find it.

print("\n *********************************")
print("******* Grumbo'z CTF System *******")
print("* Capture The Flag System Loading *")

-- CTF is the operational switch. system 1=on/0=off
-- wil_o_whisp is for world single spawn point or multiple spawn points. 0 == one spawn point(#1) / 1 == multiple spawn points
-- CTF_round_timer is the duration of a round
-- CTF_spawn_timer is the pause between rounds
-- World_flag_loc is the table of all the locations the world flag can spawn at.
-- team_flag_loc is the table for the 2 team flag spawn locations.
-- flag_id is the starting flag Gobject id.

local CTF = 1; -- system operation switch. 0=system off/1=system on
local wil_o_whisp = 1; -- default == 1/on(world flag random spawning on)
local CTF_round_timer = 1500000; -- in ms. :: Default = 1800000 :: 300000 = 5 minutes // 600000 = 10 minutes // 900000 = 15 minutes //  1800000 = 30 minutes
local CTF_spawn_timer = 300000; -- in ms. :: Default = 1800000 :: 300000 = 5 minutes // 600000 = 10 minutes // 900000 = 15 minutes //  1800000 = 30 minutes

local World_flag_loc = {
			[1] = {0, -13327.975586, -342.763367, 14.706733, 2.067787}, -- [PRIMARY] central flag location Crystalein cave
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
						};
						
-- DON'T Edit ANYTHING Below here UNLESS you REALLY know what your doing --

local flag_id = 600000;

local team_flag_loc = {
			[1] = {flag_id, 0, -4857.419434, -1032.148804, 502.190125, 5.370824}, -- ally King's Hall
			[2] = {flag_id+1, 1, 1920.868042, -4142.223633, 40.614372, 4.802613}, -- horde King's Hall
						};

local World_CTF = { 
		Alliance = nil,
		Horde = nil,
		World = nil,
		Start = nil,
		team = 3,
		team_name = {
			[1] = "Alliance",
			[2] = "Horde",
			[3] = "World",
					},
		gear = 0,
		Aura = { -- flag holder auras from wsg.
		[1] = 23335,
		[2] = 23333,
				},
		FLAG = {
				[1] = nil,
				[2] = nil,
				[3] = nil,
					},
		Ann_mad = {
				[1] = "That Tickles",
				[2] = "!! STOP THAT !!",
				[3] = "He hehe he",
				[4] = "!! STOP Poking ME !!",
				[5] = "hehe your funny..",
					},
		Ann_conf = {
				[1] = "? Huh .. What ..?",
				[2] = "Stop bothering me..",
				[3] = "!! I was trying to sleep.!!",
					},
			};

local function GetTeamName(team_id)

	local team = team_id+1
	return World_CTF.team_name[team];

end

local function RemovePlayerAura(player)

	player:RemoveAura(World_CTF.Aura[player:GetTeam()+1])

end

local function RemoveAllAuras(event, duration, cycle)

local pIw = GetPlayersInWorld()

	if(pIw)then

		for _,v in ipairs(pIw)do
	
			if(v:InBattleground() == false)then
	
				RemovePlayerAura(v)
	
			end
		end
	end
end

local function ClearFlagHolder(team_id)

local team = team_id+1

	if(team)then
		local team_name = GetTeamName(team)
		World_CTF[team_name] = nil
	end
end

local function SetFlagHolder(guid, team)

	if(team)then
		local team_name = GetTeamName(team)
		World_CTF[team_name] = guid
	end
end

local function RemoveFlag(eventid, duration, cycles, go)

	if(go)then

		if(go:RemoveFromWorld())then

			go:RemoveEvents()
			go:RemoveFromWorld()
		end
	end
end
	
local function RemoveWorldFlag(eventid, duration, cycles, go)

	if(go)then
	
		if(go:RemoveFromWorld())then
			go:RemoveEvents()
			go:RemoveFromWorld()
		end
	end
end

local function PlayerAddAura(player)

	local aura = World_CTF.Aura[player:GetTeam()+1]
	player:AddAura(aura, player)
	player:RegisterEvent(RemoveAllAuras, ((World_CTF.Start + CTF_round_timer) - GetGameTime()), 1)
	CreateLuaEvent(RemoveAllAuras, ((World_CTF.Start + CTF_round_timer) - GetGameTime()), 1)

end

-- ************
-- * SPAWNING *
-- ************

local function Spawn_Team_Flags(team_id)

local team = team_id+1

	local flag_id, map, x, y, z, o = table.unpack(team_flag_loc[team])
	local gob = PerformIngameSpawn(2, flag_id, map, 0, x, y, z, o)
	World_CTF.FLAG[team] = gob

end

local function Spawn_World_Flag()

math.randomseed(GetGameTime()*GetGameTime())
	
	local loc = 0
	
		if(wil_o_whisp > 0)then
			loc = math.random(1, #World_flag_loc)
			SendWorldMessage("The "..World_CTF.team_name[World_CTF.team].."'s World Flag has been placed some where.")
			SendWorldMessage("Now it's time to FIND that World Flag for your team's honor.")
		else
			SendWorldMessage("The "..World_CTF.team_name[World_CTF.team].."'s World Flag has been spawned.")
			SendWorldMessage("Now it's time to Fight and take that World Flag.")
			loc = 1
		end
	
	local map, x, y, z, o = table.unpack(World_flag_loc[loc])
	local flag = (flag_id + 1) + World_CTF.team
	local gob = PerformIngameSpawn(2, flag, map, 0, x, y, z, o)
	World_CTF.FLAG[3] = gob
end

local function Spawn_Flags()

Spawn_Team_Flags(0)
Spawn_Team_Flags(1)
Spawn_World_Flag()

end

-- **********

local function EndRound() -- event, duration, cycles, 

ClearFlagHolder(0)
ClearFlagHolder(1)
RemoveAllAuras(1,1,1)

World_CTF.FLAG[1]:RegisterEvent(RemoveFlag, 100, 1)
World_CTF.FLAG[2]:RegisterEvent(RemoveFlag, 200, 1)
World_CTF.FLAG[3]:RegisterEvent(RemoveFlag, 300, 1)

end	

-- *****************
-- * Flag Triggers *
-- *****************

local function Tag_Team_Flag(event, player, go)

	if(player:GetTeam())then
	
		local team_name = GetTeamName(player:GetTeam())
	
		RemoveFlag(1, 1, 1, go)
		SetFlagHolder(player:GetGUIDLow(), player:GetTeam())
		PlayerAddAura(player)

print("TAG_ALLY", "ALLY", World_CTF.Alliance, "HORDE", World_CTF.Horde,"team_name", team_name)
	end
end

RegisterGameObjectGossipEvent(flag_id, 1, Tag_Team_Flag)
RegisterGameObjectGossipEvent(flag_id+1, 1, Tag_Team_Flag)

local function Tag_World_Flag(event, player, go)


	if(player:GetTeam() ~= (World_CTF.team - 1))then

		local team_name = GetTeamName(player:GetTeam())
		
		if(World_CTF[team_name] == player:GetGUIDLow())then
	
			if((player:HasAura(23335))or(player:HasAura(23333)))then
				EndRound()
				World_CTF.FLAG[1]:RegisterEvent(RemoveFlag, 100, 1)
				World_CTF.FLAG[2]:RegisterEvent(RemoveFlag, 110, 1)
				World_CTF.FLAG[3]:RegisterEvent(RemoveFlag, 120, 1)
				World_CTF.team = (player:GetTeam()+1)
				SendWorldMessage("The "..World_CTF.team_name[player:GetTeam()+1].." has Captured The World Flag.")
				SendWorldMessage("!! NOW, kneel before the  power of the "..World_CTF.team_name[player:GetTeam()+1].." !!")
			else
				player:SendBroadcastMessage("You seem to have dropped the flag...")
			end
		else
			player:SendBroadcastMessage(World_CTF.Ann_conf[math.random(1, #World_CTF.Ann_conf)])
		end
	else
		RemovePlayerAura(player)
		Spawn_Team_Flags(player:GetTeam())
		player:SendBroadcastMessage(World_CTF.Ann_mad[math.random(1, #World_CTF.Ann_mad)])
	end
end

RegisterGameObjectGossipEvent(flag_id+2, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+3, 1, Tag_World_Flag)
RegisterGameObjectGossipEvent(flag_id+4, 1, Tag_World_Flag)

-- **************
-- * Catch 22's *
-- **************

local function Return_Flag(team)
	
	Spawn_Team_Flags(team)

end

local function Player_Change_Zone(event, player, newZone, newArea)

	if((player:GetGUIDLow() == World_CTF.Alliance)or(player:GetGUIDLow() == World_CTF.Horde))then

		PlayerAddAura(player)
	else
	end
end

RegisterPlayerEvent(27, Player_Change_Zone)

local function Team_Flag_Holder_logout(event, player)

	if(player)then
		if((player:GetGUIDLow() == World_CTF.Alliance)or(player:GetGUIDLow() == World_CTF.Horde))then

			Spawn_Team_Flags(player:GetTeam())
			ClearFlagHolder(player:GetTeam())
			RemovePlayerAura(player)
		end
	end
end

RegisterPlayerEvent(4, Team_Flag_Holder_logout)

local function Team_Flag_Holder_reset(event, _, player)

	if(player)then

		if((player:GetGUIDLow() == World_CTF.Alliance)or(player:GetGUIDLow() == World_CTF.Horde))then

			Spawn_Team_Flags(player:GetTeam())
			ClearFlagHolder(player:GetTeam())
			RemovePlayerAura(player)
		end
	end
end

RegisterPlayerEvent(6, Team_Flag_Holder_reset)
RegisterPlayerEvent(8, Team_Flag_Holder_reset)

local function Proccess()

World_CTF.gear = (World_CTF.gear + 1)

	if(World_CTF.gear == 3)then
		SendWorldMessage("Grumboz Capture the Flag has ended for this round.")
		EndRound()
		CreateLuaEvent(Proccess, CTF_spawn_timer, 1)
		World_CTF.gear = 0;
	end

	if(World_CTF.gear == 1)then
		World_CTF.Start = GetGameTime()
		Spawn_Flags()
		CreateLuaEvent(Proccess, CTF_round_timer, 1)
		World_CTF.gear = 2;
	end
end

	if(CTF == 1)then 
		Proccess()
		print("******* Team Flag timers on *******")
		print("******* World Flag timer on *******")
	 	print("** Capture The Flag System ready **") 
	 else 
	 	print("** Capture The Flag System idle. **")
	 end
print(" *********************************\n")
