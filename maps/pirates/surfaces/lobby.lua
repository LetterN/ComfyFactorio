-- This file is part of thesixthroc's Pirate Ship softmod, licensed under GPLv3 and stored at https://github.com/danielmartin0/ComfyFactorio-Pirates.


local Memory = require 'maps.pirates.memory'
local Math = require 'maps.pirates.math'
-- local Balance = require 'maps.pirates.balance'
local Boats = require 'maps.pirates.structures.boats.boats'
local Common = require 'maps.pirates.common'
local CoreData = require 'maps.pirates.coredata'
local Utils = require 'maps.pirates.utils_local'
local _inspect = require 'utils.inspect'.inspect


local Public = {}

Public.StartingBoats = {
	{
		type = Boats.enum.SLOOP,
		position = {x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-001',
	},
	{
		type = Boats.enum.SLOOP,
		position = {x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1 + (23 + Boats[Boats.enum.SLOOP].Data.height/2)},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-002',
	},
	{
		type = Boats.enum.SLOOP,
		position = {x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1 - (23 + Boats[Boats.enum.SLOOP].Data.height/2)},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-003',
	},
	{
		type = Boats.enum.SLOOP,
		position = {x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1 + 2 * (23 + Boats[Boats.enum.SLOOP].Data.height/2)},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-004',
	},
	{
		type = Boats.enum.SLOOP,
		position = {x = Boats[Boats.enum.SLOOP].Data.width - 65, y = -1 - 2 * (23 + Boats[Boats.enum.SLOOP].Data.height/2)},
		surface_name = CoreData.lobby_surface_name,
		force_name = 'crew-005',
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
Public.Data.display_name = {'pirates.location_displayname_lobby_1'}
Public.Data.width = 224
Public.Data.height = 256
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

	if Math.distance(args.p, {x = -316, y = 0}) < 230 then
		args.tiles[#args.tiles + 1] = {name = 'dirt-3', position = args.p}
		if x <= -80 and (y >= 10 or y <= -10) and math.random() < 0.1 then
			local tree_name = 'tree-05'
			if math.random() < 0.2 then
				tree_name = 'tree-07'
			end
			args.entities[#args.entities + 1] = {name = tree_name, position = args.p}
		elseif x <= -80 and y < 3 and y > -5 then
			args.tiles[#args.tiles + 1] = {name = 'stone-path', position = args.p}
		end
	elseif Math.distance(args.p, {x = -264, y = 0}) < 180 then
			args.tiles[#args.tiles + 1] = {name = 'water-shallow', position = args.p}
	elseif Math.abs(Common.lobby_spawnpoint.x - x) < 3 and Math.abs(Common.lobby_spawnpoint.y - y) < 3 then
		args.tiles[#args.tiles + 1] = {name = CoreData.walkway_tile, position = args.p}
	else
		args.tiles[#args.tiles + 1] = {name = 'water', position = args.p}
		if math.random(1, 400) == 1 then
			args.entities[#args.entities + 1] = {name = 'fish', position = args.p}
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

	local offset = {x = -47, y = -1}

	local tiles = {}
	for _, p in pairs(Common.tile_positions_from_blueprint(Public.Data.jetty_bp, offset)) do
		tiles[#tiles + 1] = {name = CoreData.walkway_tile, position = p, force = 'environment'}
	end

	surface.set_tiles(tiles, true)

	-- for y = -3.5, 3.5 do
	-- 	local e = surface.create_entity{name = 'stone-wall', position = {x = -68.5, y = y}, force = 'environment'}
	-- 	e.destructible = false
	-- 	e.minable = false
	-- 	e.rotatable = false
	-- 	e.operable = false
	-- end

	local entities = Common.build_from_blueprint(Public.Data.jetty_objects_bp, surface, {x=-61, y=-1}, 'environment')
	for _, e in pairs(entities) do
		if e and e.valid then
			e.destructible = false
			e.minable = false
			e.rotatable = false
		end
	end


end

Public.Data.jetty_bp = [[0eNqV3c2uZMd5ptF7qTENZHy/EbwVwwPZLhgFSBRB0YYNQ/felFryqNuoNaSwVUzs9xQjzzNY8d9f/vn3//7151++/fTrlx//+8uffvrdz//w6x//4d9++favf/nn//zy484PX/7ry4/n1J9/+PLtX/7405++/PiPvz357d9++t3v//LMr//189cvP3759uvXP3z54ctPv/vDX/7pt+f+5Zevv3798pf/00//+vW3P+j8+Z9++PLrt99//b9/wM9//NO3X7/98ae//Ws+f/23dP75//VH/P+eLnq66emhp5eevvT0k6fn831PH3rfh973ofd96H0fet+H3veh933ofQe976D3HfS+g9530PsOet9B7zvofSe976T3nfS+k9530vtOet9J7zvpfRe976L3XfS+i9530fsuet9F77vofTe976b33fS+m9530/tuet9N77vpfQ+976H3PfS+h9730Pseet9D73vofS+976X3vfS+l9730vteet9L73vpfd+/Pk0PH3k45OGUh0sebnl45OGVh688/GgUm5A2PDTioRUPzXhox0NDHlry0JSHtgzaMuzvI20ZtGXQlkFbBm0ZtGXQlkFbJm2ZtGXaf1xpy6Qtk7ZM2jJpy6Qtk7Ys2rJoy6Ity05K2rJoy6Iti7Ys2rJoy6Ytm7Zs2rJpy7avPbRl05ZNWzZt2bSlfdcd2nJoy6Eth7Yc+w5LWw5tObTl0JZLWy5tubTl0pZLWy5tufYLCW25tOXSlpe2vLTlpS0vbXlpy0tbXtry2m+XtOWlLR9t+WjLR1s+2vLRlo+2fLTloy2fpQJsBRYLPlYLPpYLPtYLPhYMPlYMPpYMPtYMPhYNPraqJiBbFSPQ91agJ/3xSX980h+f9Mcn/fFJf3zSH5/0xyf98Ul/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fFRf3zUHx/1x0f98VF/fNQfH/XHR/3xUX981B8f9cdH/fF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bi2dj8Wwsno3Fs7F4NhbPxuLZWDwbi2dj8WwsnkPFc6h4DhXPoeI5VDyHiudQ8RwqnkPFc6h4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5VjzHiudY8RwrnmPFc6x4jhXPseI5WDwHi+dg8RwsnoPFc7B4DhbPweI5WDwHi+dg8RwsnoPFc7B4LhXPpeK5VDyXiudS8VwqnkvFc6l4LhXPpeK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiuda8VwrnmvFc614rhXPteK5VjzXiudi8VwsnovFc7F4LhbPxeK5WDwXi+di8VwsnovFc7F4LhbPxeJ5qXheKp6Xiuel4nmpeF4qnpeK56Xieal4Xiqe14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue14nmteF4rnteK57Xiea14Xiue14rnteJ5rXheK57Xiue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INBcizYVIcyHSXIg0FyLNhUhzIdJciDQXIs2FSHMh0lyINBcizYVIcyHSXIg0FyLRhUh0IRJdiEQXItGFSHQhEl2IRBci0YVIciGSXIgkFyLJhUhyIZJciCQXIsmFSHIh0lyINBcizYVIcyHSXIg0FyLNhUhzIdJciDQXIs2FSHMh0lyINBcizYVIcyHSXIg0FyLRhUh0IRJdiEQXItGFSHQhEl2IRBci0YVIciGSXIgkFyLJhUhyIZJciCQXIsmFSHIh0lyINBcizYVIcyHSXIg0FyLNhUhzIdJciDQXIs2FSHMh0lyINBcizYVIcyHSXIg0FyLRhUh0IRJdiEQXItGFSHQhEl2IRBci0YVIciGSXIgkFyLJhUhyIZJciCQXIsmFSHIh0lyINBcizYVIcyHSXIg0FyLNhUhzIdJciDQXIs2FSHMh0lyINBcizYVIcyHSXIg0FyLRhUh0IRJdiEQXItGFSHQhEl2IRBci0YUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IUociGKXIgiF6LIhShyIYpciCIXosiFKHIhylyIMheizIUocyHKXIgyF6LMhShzIcpciDIXosyFKHMhylyIMheizIUocyHKXIgyF6LQhSh0IQpdiEIXotCFKHQhCl2IQhei0IVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YVociGaXIgmF6LJhWhyIZpciCYXosmFaHIh2lyINheizYVocyHaXIg2F6LNhWhzIdpciDYXos2FaHMh2lyINheizYVocyHaXIg2F6LRhWh0IRpdiEYXotGFaHQhGl2IRhei0YUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IUYciGGXIghF2LIhRhyIYZciCEXYsiFGHIhxlyIMRdizIUYcyHGXIgxF2LMhRhzIcZciDEXYsyFGHMhxlyIMRdizIUYcyHGXIgxF2LQhRh0IQZdiEEXYtCFGHQhBl2IQRdi0IVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi0YVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi0YVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi0YVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi0YVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi0YVYciGWXIglF2LJhVhyIZZciCUXYsmFWHIh1lyINRdizYVYcyHWXIg1F2LNhVhzIdZciDUXYs2FWHMh1lyINRdizYVYcyHWXIg1F2LRhVh0IRZdiEUXYtGFWHQhFl2IRRdi/1cX4p9++PLt169/+O1/++ff//vXn3/59tOvX3748h9ff/nTX/+EuKf2xd575/32b/zz/wHg7omN]]


Public.Data.jetty_objects_bp = [[0eNqdWutu2zwMfRf/VgbdL3mVoSicVl9qzDfYzraiyLtPTpc030LKpn8VTq3DoyNSpCh/FIf6FPuhaqdi/1GMbdnvpm53HKrX+fl3sRdcseI9/RXizIrqpWvHYv89vVod27KeX5re+1jsi2qKTcGKtmzmp19d9xrb3ctbHKdiHti+xhnt/MSK2E7VVMVPnMvD+3N7ag5xSC/ACKzouzEN6tq/tJT5Zi68+DdzPrMHHHnDaeJrdWp2sY4v01C97Pqujo94+oonEl4aG6vj26E7DTNJy4R/Amyom42xKet6V5dNDyDbO2QARVNnrGAcQ8WRMI4lKmfUHd4/ykkGCudWCWdVnqgnErUSJ2pZgIgGogkncBOeCQHZEHyVGl7k1RCCyNVznGtgQoJcqWHlA24kMRYatLIusEJYUEQTyQafIQvrQQ46h3D9irrxdBin8jL2EcZ/gjywA8NMfMVZNXQ4t+sGZRFu1EBT4W6yDztCmqqExQxUMQWyFUpORkJ8SIp1Et5wNIIjt2ooLOCMnilwL5ErUxK/B4dwyElJeATJ0ASUSJaUlpzesMrArUWyS5w8mRPmsGTXl4jDKk6eHYYktrqsNEDcS6YcWERJcv2DiKgUGQmbuqaKiHIyZCSM0+oACEtIbuvCKv24sMlNVGAG3I6Up21HCtk9FbUO0+6KCKSgNH8N0tXrKjHt78EhHGrkGJujG5gG86Wm5hRrMmYSaQ1WY3pdTrF2SRVqOeZ0jq5k2oB0DbVEVTkzmmlw29J2XdWul1ShBmOQObqGabAU1NQaTnCRswNrElZpIrhcEMWQk5jGDsWbk9gF8XHnMKDTGXIS08hWZ8hJTGMifsVbP3THoWya8lDH3djH8kd64RHx6qvmswfSl2lMnOI89Y+ir8v3Q/ny4/lnV59m1KTs7bdj3R3Sgqex/5X1GFmRHrpfz0ni9/6ta6+/n+d/xGF6/j/0+JbevfzjNv7yU9c+N2Vf7KfhFK8jmziO5XGeVAFOmhr9NxkNf1zv5D1Wgeu9Lvpv7mmQWtRQo/+aKY0H2IKRb8iRnzORAgBslJhA3l+yM2EWzNB2XYYW4R4cwqFuC8Ln6AZmwQxtqRlauowZi3mjVZudPgCzMWk2zHHQkib6fUD0J/dN5toFRCKfCy2y81pqtwRjRD4VWuQUbgM1DWJIjm9NgxbI/snfnAX7uuTuvUOO1o6cUB2yxTpyQnVILeHITRGHnMCcWXfQcEs41F797S7CAS3O5CTOMQ+Wdo6aqIzJWbLMgWnErTsw2kWBqenI6hzdpAq4HXpqWDmVMxOYB9OIF+vOGmpBFU/u3ssM3TR5D6YjT01HQeTMSObBmtvrlacNsSSLIdcuPEcYFoWcpxyyl/vN7RvnwFD0YCh6Yu/GIccQH7bS9UDnO00+gPoGcsvfI7VhICexgCSMIKn5G0VSW0UMQC82LUlyYVBFTVv0gNRAgVzfBcR9AjluAhI3gdz3R5HIFd6l5QFC0e+8OFK/piXdfMfEgcZu8jnBFXxjTb0V49i1JyeHiODYNSVXW7vEn/z+vWRLegpuYAE0rVOcEcBs7RUjpOdVszBpu7VfjJgyyRR88cwdrWec0cdv7RojpG0iHWDSYWvnGDE1f/EBf/Kx9psPvagP+bOPW/8YIZ1yA/KtA/njj6/SC7aFiaOIbeSMOl9xeuiqGux63nxQcBjDUDc7j7GxtA7DX6Qn9vlt3f7uWz1W/IzDeBkjvdAuSOe9t0HI8/kPMPDSAw==]]


return Public