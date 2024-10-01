-- This file is part of thesixthroc's Pirate Ship softmod, licensed under GPLv3 and stored at https://github.com/ComfyFactory/ComfyFactorio and https://github.com/danielmartin0/ComfyFactorio-Pirates.

local Memory = require('maps.pirates.memory')
local Math = require('maps.pirates.math')
-- local Balance = require 'maps.pirates.balance'
local Boats = require('maps.pirates.structures.boats.boats')
local Common = require('maps.pirates.common')
local CoreData = require('maps.pirates.coredata')
local Utils = require('maps.pirates.utils_local')
local _inspect = require('utils.inspect').inspect

local Public = {}

Public.StartingBoats = {
	{
		type = Boats.enum.SLOOP,
		position = { x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1 },
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-001',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 + (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-002',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 - (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-003',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 + 2 * (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-004',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 - 2 * (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-005',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 + 3 * (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-006',
	},
	{
		type = Boats.enum.SLOOP,
		position = {
			x = Boats[Boats.enum.SLOOP].Data.width - 65,
			y = -1 - 3 * (23 + Boats[Boats.enum.SLOOP].Data.height / 2),
		},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-007',
	},
	-- {
	-- 	type = Boats.enum.CUTTER,
	-- 	position = {x = Boats[Boats.enum.CUTTER].Data.width - 56, y = (70.5 + Boats[Boats.enum.CUTTER].Data.height/2)},
	-- 	surface_name = CoreData.lobby_surface_name,
	-- 	force_name = 'environment',
	-- 	speedticker1 = 0,
	-- 	speedticker2 = 1/3 * Common.boat_steps_at_a_time,
	-- 	speedticker3 = 2/3 * Common.boat_steps_at_a_time,
	-- },
}

Public.Data = {}
Public.Data.display_name = { 'pirates.location_displayname_lobby_1' }
Public.Data.width = 224
Public.Data.height = 384
-- Public.Data.noiseparams = {
-- 	land = {
-- 		type = 'simplex_2d',
-- 		normalised = false,
-- 		params = {
-- 			{wavelength = 128, amplitude = 10/100},
-- 			{wavelength = 64, amplitude = 10/100},
-- 			{wavelength = 32, amplitude = 5/100},
-- 			{wavelength = 12, amplitude = 5/100},
-- 		},
-- 	}
-- }

Public.Data.iconized_map_width = 4
Public.Data.iconized_map_height = 20

function Public.terrain(args)
	local x, y = args.p.x, args.p.y

	if Math.distance(args.p, { x = -316, y = 0 }) < 230 then
		args.tiles[#args.tiles + 1] = { name = 'dirt-3', position = args.p }
		if x <= -80 and (y >= 10 or y <= -10) and math.random() < 0.1 then
			local tree_name = 'tree-05'
			if math.random() < 0.2 then
				tree_name = 'tree-07'
			end
			args.entities[#args.entities + 1] = { name = tree_name, position = args.p }
		elseif x <= -80 and y < 3 and y > -5 then
			args.tiles[#args.tiles + 1] = { name = 'stone-path', position = args.p }
		end
	elseif Math.distance(args.p, { x = -264, y = 0 }) < 180 then
		args.tiles[#args.tiles + 1] = { name = 'water-shallow', position = args.p }
	elseif Math.abs(Common.lobby_spawnpoint.x - x) < 3 and Math.abs(Common.lobby_spawnpoint.y - y) < 3 then
		args.tiles[#args.tiles + 1] = { name = CoreData.walkway_tile, position = args.p }
	else
		args.tiles[#args.tiles + 1] = { name = 'water', position = args.p }
		if math.random(1, 300) == 1 then
			args.entities[#args.entities + 1] = { name = 'fish', position = args.p }
		end
	end
end

function Public.chunk_structures()
	return nil
end

function Public.create_starting_dock_surface()
	-- local memory = Memory.get_crew_memory()

	local starting_dock_name = CoreData.lobby_surface_name

	local width = Public.Data.width
	local height = Public.Data.height
	local map_gen_settings = Common.default_map_gen_settings(width, height)

	local surface = game.create_surface(starting_dock_name, map_gen_settings)
	surface.freeze_daytime = true
	surface.daytime = 0
end

function Public.place_starting_dock_showboat(id)
	local global_memory = Memory.get_global_memory()

	Memory.set_working_id(id)

	local boat = Utils.deepcopy(Public.StartingBoats[id])

	global_memory.lobby_boats[id] = boat

	Boats.place_boat(boat, CoreData.static_boat_floor, true, true, false)
	-- Boats.place_boat(boat, CoreData.static_boat_floor, true, true, false, true) --this final argument is to enable the comfy graphic to be placed on the boat, but that argument is disabled for now, so luacheck forbids this line
end

function Public.place_lobby_jetty_and_boats()
	local surface = game.surfaces[CoreData.lobby_surface_name]

	for id, _ in pairs(Public.StartingBoats) do
		Public.place_starting_dock_showboat(id)
	end

	local offset = { x = -48, y = -28 }

	local tiles = {}
	for _, p in pairs(Common.tile_positions_from_blueprint(Public.Data.jetty_bp, offset)) do
		tiles[#tiles + 1] = { name = CoreData.walkway_tile, position = p, force = 'environment' }
	end

	surface.set_tiles(tiles, true)

	-- for y = -3.5, 3.5 do
	-- 	local e = surface.create_entity{name = 'stone-wall', position = {x = -68.5, y = y}, force = 'environment'}
	-- 	e.destructible = false
	-- 	e.minable = false
	-- 	e.rotatable = false
	-- 	e.operable = false
	-- end

	local entities =
		Common.build_from_blueprint(Public.Data.jetty_objects_bp, surface, { x = -61, y = -1 }, 'environment')
	for _, e in pairs(entities) do
		if e and e.valid then
			e.destructible = false
			e.minable = false
			e.rotatable = false
		end
	end
end

Public.Data.jetty_bp =
	[[0eNqV3cEObsdxndF34VgG2F1Vu/roVYIMHJtICNiUINFJDEPvHjmJNUvANXRwLF/8fUFsVT5w/dsP/+Wf/uWnP/7p519+/eH3//bDn3/5+z/+3a9/+Lv/+qef//Hf/+f/+cPvN7/74V9/+P15/Zff/fDzP/zhlz//8Pv/9Ncvf/6vv/z9P/37N7/+6x9/+uH3P/z860///MPvfvjl7//53/+n//GHP/zjT7/83T/8t5/+/OsP//6/+Ms//vTX/7Dzl//8ux9+/fmffvo//yF//MOff/715z/88n//T53/83/pzF/+9p/z1/97//Cnn3796a//Gf/Pz2Ofr33+7POPPr8/2ufHPr+/7fNrv/u13/3a737td7/2u1/73a/97td+97Lfvex3L/vdy373st+97Hcv+93Lfve2373td2/73dt+97bfve13b/vd2373sd997Hcf+93Hfvex333sdx/73cd+99jvHvvdY7977HeP/e6x3z32u8d+97Xffe13X/vd1373td997Xdf+93Xfvdnv/uz3/3Z7/7sd3/2uz/73Z/97s9+9+9/f36Xvn709Sdf14/09aGv6Tepoq+bvh76OvQ1vWXRWxa9ZdNbNr1l01s2vWXTWza9ZdNbNr1l01s2veXQWw695dBbDr3l0FsOveXQWw695dBbDr1l6C1Dbxl6y9Bbht4y9Jahtwy9ZegtQ2+59JZLb7n0lktvufSWS2+59JZLb7n0lktv+egtH73lo7d89JaP3vLRWz56y0dv+egtH73lR2/50Vt+9JYfveVHb/nRW370lh+95Udv+dFbnh9/tM+PfX7t87LP2z4f+zz2+drnzz63Vz32qsde9dirHnvVY6967FWPveqxVz32qsde9dqrXntVO6uca6967VWvveq1V7Wb0LGj0LGr0LGz0LG70LHD0LHL0LHT0LHb0LHj0LHr0LHz0LH70LED0bEL0bET0bEb0bEj0bEr0bEz0bE70bFD0bFL0bFT0bFb0bFj0bFr0bFz0bF70bGD0bGL0bGT0bGb0bGj0bGr0bGz0bG70bHD0bHL0bHT0bHb0bHj0bHr0bHz0bH70bED0rEL0rET0rEb0rEj0rEr0rEz0rE70rFD0rFL0rFT0rFb0rFj0rFr0rFz0rF70rGD0rGL0rGT0rGb0rGj0rGr0rGz0rG70rHD0rHL0rHT0rHb0rX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py0bKspGybKQsGynLRsqykbJspCwbKctGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBspzEYKs5HCbKQwGynMRgqzkcJspDAbKcxGCrORwmykMBtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0baspG2bKQtG2nLRtqykbZspC0bactG2rKRtmykLRtpy0Yas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxG2nMRhqzkcZspDEbacxGGrORxmykMRtpzEYas5HGbKQxGxnLRsaykbFsZCwbGctGxrKRsWxkLBsZy0bGspGxbGQsGxnLRsaykbFsZCwbGctGxrKRsWxkLBsZy0bGspGxbGQ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ojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo2UaSNl2kiZNlKmjZRpI2XaSJk2UqaNlGkjZdpImTZSpo0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojhdpIoTZSqI0UaiOF2kihNlKojRRqI4XaSKE2UqiNFGojbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo20aSNt2kibNtKmjbRpI23aSJs20qaNtGkjbdpImzbSpo00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojjdpIozbSqI00aiON2kijNtKojTRqI43aSKM20qiNNGojY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo2MaSNj2siYNjKmjYxpI2PayJg2MqaNjGkjY9rImDYypo0MaiOD2sigNjKojQxqI4PayKA2MqiNDGojg9rIoDYyqI0MaiOD2sigNjKojQx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ayJo2sqaNrGkja9rImjaypo0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo2saSNr2siaNrKmjaxpI2vayJo2sqaNrGkja9rImjaypo0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiNLGoji9rIojayqI0saiOL2siiNrKojSxqI4vayKI2sqiN7P9XG/nPv/vh519/+ue//r/9l3/6l5/++Keff/n1h9/98N9/+tOf//d/wn2n97v73st37l/+8r8Ac2wwZQ==]]

Public.Data.jetty_objects_bp =
	[[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]]

return Public
