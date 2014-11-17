Grumboz CTF System
==================

My noooob Attempt at a capture the flag system

ok this is a rough draft....
there are 2 kinds of flags. team flags(ally , horde) and world flags(starter, ally, horde).

you goal is to get your team's flag to the world flag to capture the world flag.
 * the world flag will change based on what team captures the world flag.
 * the world flag will respawn at a random location from the `World_flag_loc` table.

the `CTF_timer` is the adjustable timer value for duration between World flag re-spawn's.

easy to add new world flag locations.
just find a random spot and add the gps coordinates (map, x, y, z, o)to the `world_flag_loc` table then restart core.
the world flag can be placed at any location now, the script will compensate for zone/map changes when flag bearrer teleports.
