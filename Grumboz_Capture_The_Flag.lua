-- Grumbo'z Capture The Flag System -Wil-O-Whisp-
-- by slp13at420 of EmuDevs.com
-- For Trinity Core2 3.3.5a
-- Released to EmuDevs.com . Please dont remove any credits.

-- - Wil-o-whisp - Version
-- A Chaotic system that will spawn a world flag at a same/different location.
-- with wil-o-whisp on. the world flag will randomly spawn in the world and players must find it.
-- with wil-o-whisp off. the world flag will spawn at 1 location.
-- your players job is to get there team flag to the world flag and tag it.

print("\n *********************************")
print("******* Grumbo'z CTF System *******")
print("* Capture The Flag System Loading *")

-- CTF is the operational switch. system 1=on/0=off
-- wil_o_whisp is for world single spawn point or multiple spawn points. 0 == one spawn point(#1) / 1 == multiple spawn points
-- required_players is minimum required players for system to start a round. default 4 players.
-- CTF_round_timer is the duration of a round
-- CTF_spawn_timer is the pause between rounds
-- World_flag_loc is the table of all the locations the world flag can spawn at.
-- team_flag_loc is the table for the 2 team flag spawn locations.
-- flag_id is the starting flag Gobject id.

local CTF = 1; -- system operation switch. 0=system off/1=system on
local wil_o_whisp = 1; -- default == 1/on(world flag random spawning on)
local required_players = 4; -- minimum required players
local CTF_Player_Check = 10000; -- in ms. :: when not minimum players this timer will check often for minimum players
local CTF_round_timer = 1800000; -- in ms. :: Default = 1800000 :: 300000 = 5 minutes // 600000 = 10 minutes // 900000 = 15 minutes //  1800000 = 30 minutes
local CTF_spawn_timer = 600000; -- in ms. :: Default = 1800000 :: 300000 = 5 minutes // 600000 = 10 minutes // 900000 = 15 minutes //  1800000 = 30 minutes

local World_flag_loc = {
			[1] = {0, -13327.975586, -342.763367, 14.706733, 2.067787}, -- [PRIMARY] flag location Crystalein cave
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
			[12] = {1, -3965.707275, -2578.417969, 229.510910, 5.87359}, -- central flag location Dustwallow Marsh
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
			[3] = "Realm",
					},
		gear = 0,
		service = 0,
		flag_allow = 0,
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

local function RemoveFlag(go, team_id)

	if((go)and(go:RemoveFromWorld()))then

		local team = team_id + 1
		go:RemoveFromWorld()
		World_CTF.FLAG[team] = nil;
	end
end
	
local function RemoveWorldFlag(go, team_id)

	if((go)and(go:RemoveFromWorld()))then

		local team = team_id
		go:RemoveFromWorld()
		World_CTF.FLAG[team] = nil;
	end
end

local function PlayerAddAura(player)

	local aura = World_CTF.Aura[player:GetTeam()+1]
	player:AddAura(aura, player)

end

-- ************
-- * SPAWNING *
-- ************

local function Spawn_Team_Flags(team_id)

local team = team_id+1

	local flag_id, map, x, y, z, o = table.unpack(team_flag_loc[team])

	if(flag_id)then
		World_CTF.FLAG[team] = PerformIngameSpawn(2, flag_id, map, 0, x, y, z, o)
	else
		print("CTF_"..World_CTF.team_name[team].."_FLAG_SPAWN_ERR")
	end
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
	
		if(map)then
			World_CTF.FLAG[3] = PerformIngameSpawn(2, flag, map, 0, x, y, z, o)
			print("CTF_FLAG_LOC", loc)
		end
end

local function Spawn_Flags()

	World_CTF.flag_allow = 1;
	Spawn_Team_Flags(0)
	Spawn_Team_Flags(1)
	Spawn_World_Flag()
	CreateLuaEvent(RemoveAllAuras, ((World_CTF.Start + CTF_round_timer) - GetGameTime()), 1)
	print("CTF_ROUND_START")

end

-- **********

local function EndRound() 

World_CTF.flag_allow = 0;
ClearFlagHolder(0)
ClearFlagHolder(1)
RemoveAllAuras(1,1,1)

	if(World_CTF.FLAG[1])then RemoveFlag(World_CTF.FLAG[1], 0); end
	if(World_CTF.FLAG[2])then RemoveFlag(World_CTF.FLAG[2], 1); end
	if(World_CTF.FLAG[3])then RemoveWorldFlag(World_CTF.FLAG[3], 3); end
			
print("CTF_ROUND_END")
end	

-- *****************
-- * Flag Triggers *
-- *****************

local function Tag_Team_Flag(event, player, go)

	local team_name = GetTeamName(player:GetTeam())

	RemoveFlag(go, player:GetTeam())
	SetFlagHolder(player:GetGUIDLow(), player:GetTeam())
	PlayerAddAura(player)
	print("CTF_TAG_ATF")
end

RegisterGameObjectGossipEvent(flag_id, 1, Tag_Team_Flag)
RegisterGameObjectGossipEvent(flag_id+1, 1, Tag_Team_Flag)

local function Tag_World_Flag(event, player, go)


	if(player:GetTeam() ~= (World_CTF.team - 1))then

		local team_name = GetTeamName(player:GetTeam())
		
		if(World_CTF[team_name] == player:GetGUIDLow())then
	
			if((player:HasAura(23335))or(player:HasAura(23333)))then
				EndRound()
				World_CTF.team = (player:GetTeam()+1)
				SendWorldMessage("The "..World_CTF.team_name[player:GetTeam()+1].." has Captured The World Flag.")
				SendWorldMessage("!! NOW, kneel before the  power of the "..World_CTF.team_name[player:GetTeam()+1].." !!")
				print("CTF_TAG_WF")
			else
				player:SendBroadcastMessage("You seem to have dropped the flag...")
			end
		else
			player:SendBroadcastMessage(World_CTF.Ann_conf[math.random(1, #World_CTF.Ann_conf)])
		end
	else
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

local function clear_aura(event, player)

	if(player:InBattleground() == false)then

		RemovePlayerAura(player)
	end
end

RegisterPlayerEvent(3, clear_aura) -- login
RegisterPlayerEvent(36, clear_aura) -- revive

local function Return_Flag(event, a, b, c)

if(event == (6 or 8))then player = c else player = a; end

	if(player:InBattleground() == false)then

		if((player:GetGUIDLow() == World_CTF.Alliance)or(player:GetGUIDLow() == World_CTF.Horde))then
			ClearFlagHolder(player:GetTeam())
			
				if(World_CTF.flag_allow == 1)then
					Spawn_Team_Flags(player:GetTeam())
				end
		end
	end
end

RegisterPlayerEvent(4, Return_Flag) -- logout
RegisterPlayerEvent(6, Return_Flag) -- die by plr
RegisterPlayerEvent(8, Return_Flag) -- die by npc

local function PlayerMounts(eventid, player, spellid)

	if(eventid == 5)then
	
		if(player:InBattleground() == false)then
		
			if((player:HasAura(23335))or(player:HasAura(23333)))then
				 Return_Flag(event, player)
			end
		end
	end
end

RegisterPlayerEvent(5, PlayerMounts)

local function Player_Change_Zone(event, player, newZone, newArea)

	if((player:GetGUIDLow() == World_CTF.Alliance)or(player:GetGUIDLow() == World_CTF.Horde))then

		PlayerAddAura(player)
	else
	end
end

RegisterPlayerEvent(27, Player_Change_Zone)

local function Proccess()

local pIw = #GetPlayersInWorld()

World_CTF.gear = (World_CTF.gear + 1)

	if((World_CTF.service == 1)and(World_CTF.gear == 3))then  World_CTF.gear = 1; end

	if(World_CTF.gear == 3)then
		SendWorldMessage("Grumboz Capture the Flag has ended for this round.")
		EndRound()
		CreateLuaEvent(Proccess, CTF_spawn_timer, 1)
		World_CTF.gear = 0;
	end

	if(World_CTF.gear == 1)then
	
		World_CTF.Start = GetGameTime()

			if(pIw >= required_players)then
				World_CTF.service = 0;
				Spawn_Flags()
				CreateLuaEvent(Proccess, CTF_round_timer, 1)
			else
				if(World_CTF.service == 0)then print("CTF_ROUND_PAUSE_REQUIRE_PLAYERS_"..pIw.."_OF_"..required_players); end
				CreateLuaEvent(Proccess, CTF_Player_Check, 1)
				World_CTF.service = 1;
			end
		
		World_CTF.gear = 2;
	end
end

	if(CTF == 0)then
		print("** Capture The Flag System idle. **")
		print(" *********************************\n")
	end
	if(CTF == 1)then 
		print("*       Team Flag timers on       *")
			if(wil_o_whisp == 1)then
				print("*      Wil - o - Whisp active     *") 
				print("*       Location Randomized       *")
			else
				print("*      Wil - o - Whisp -idle-     *")
				print("*        Standard Location        *")
			end
		print("*       World Flag timer on       *")
	 	print("** Capture The Flag System ready **") 
		print(" *********************************\n")
		Proccess()
	 end
