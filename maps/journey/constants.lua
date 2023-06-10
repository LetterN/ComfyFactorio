--luacheck: ignore
local Public = {}

Public.mothership_teleporter_position = {x = 0, y = 12}
Public.teleporter_tile = "lab-dark-2"

Public.mothership_radius = 48

Public.particle_spawn_vectors = {}
for x = Public.mothership_radius * -1 - 32, Public.mothership_radius + 32, 1 do
	for y = Public.mothership_radius * -1 - 64, Public.mothership_radius + 32, 1 do
		local position = {x = x, y = y}
		local distance = math.sqrt(position.x ^ 2 + position.y ^ 2)
		if distance > Public.mothership_radius then
			table.insert(Public.particle_spawn_vectors, {position.x, position.y})
		end
	end
end
Public.size_of_particle_spawn_vectors = #Public.particle_spawn_vectors

Public.world_selector_width = 6
Public.world_selector_height = 8
Public.max_satellites = 3

local area = {
	left_top = {x = -3, y = 4 + math.floor(Public.mothership_radius * 0.5) * -1},
	right_bottom = {x = 3, y = 4 + math.floor(Public.mothership_radius * 0.5) * -1 + Public.world_selector_height},
}

Public.world_selector_areas = {
	[1] = {
		left_top = {x = area.left_top.x - 14, y = area.left_top.y},
		right_bottom = {x = area.left_top.x - 8, y = area.right_bottom.y},
	},
	[2] = area,
	[3] = {
		left_top = {x = area.right_bottom.x + 8, y = area.left_top.y},
		right_bottom = {x = area.right_bottom.x + 14, y = area.right_bottom.y},
	},
}

Public.world_selector_colors = {
	[1] = {r = 200, g = 200, b = 0, a = 255},
	[2] = {r = 150, g = 150, b = 255, a = 255},
	[3] = {r = 200, g = 100, b = 100, a = 255},
}

Public.reroll_selector_area_color = {r = 220, g = 220, b = 220, a = 255}
Public.reroll_selector_area = {
	left_top = {x = -4, y = math.floor(Public.mothership_radius - 6) * -1},
	right_bottom = {x = 4, y = math.floor(Public.mothership_radius - 6) * -1 + 5},
}

Public.mothership_messages = {
	waiting = {
		"Return to me, so we can continue the journey!",
		"Don't leave me waiting for so long. Let's continue our journey.",
		"Please return to me.",
		"Board me, so we can continue this adventure!",
	},
	answers = {
		"Yes, great idea.",
		"Yes, wonderful.",
		"Yes, definitely.",
		"Yes, i love it!",
		"The calculations say yes.",
		"I don't know how to feel about this.",
		"Ask again later, my processors are very busy.",
		"No, this is certainly wrong.",
		"No, i don't think so.",
		"No, you are wrong.",
		"No, that would be weird.",
		"The calculations say no.",
	},
}

Public.mothership_gen_settings = {
	["water"] = 0,
	["starting_area"] = 1,
	["cliff_settings"] = {cliff_elevation_interval = 0, cliff_elevation_0 = 0},
	["default_enable_all_autoplace_controls"] = false,
	["autoplace_settings"] = {
		["entity"] = {treat_missing_as_default = false},
		["tile"] = {treat_missing_as_default = false},
		["decorative"] = {treat_missing_as_default = false},
	},
	autoplace_controls = {
		["coal"] = {frequency = 0, size = 0, richness = 0},
		["stone"] = {frequency = 0, size = 0, richness = 0},
		["copper-ore"] = {frequency = 0, size = 0, richness = 0},
		["iron-ore"] = {frequency = 0, size = 0, richness = 0},
		["uranium-ore"] = {frequency = 0, size = 0, richness = 0},
		["crude-oil"] = {frequency = 0, size = 0, richness = 0},
		["trees"] = {frequency = 0, size = 0, richness = 0},
		["enemy-base"] = {frequency = 0, size = 0, richness = 0}
	},
}

Public.modifiers_old = {
	["trees"] = {-20, -10, "Trees"},
	["tree_durability"] = {-30, -15, "Tree Durability"},
	["cliff_settings"] = {20, 40, "Cliffs"},
	["water"] = {-20, -10, "Water"},
	["coal"] = {-20, -10, "Coal"},
	["stone"] = {-20, -10, "Stone"},
	["iron-ore"] = {-20, -10, "Iron Ore"},
	["copper-ore"] = {-20, -10, "Copper Ore"},
	["crude-oil"] = {-20, -10, "Oil"},
	["uranium-ore"] = {-20, -10, "Uranium Ore"},
	["mixed_ore"] = {-20, -10, "Mixed Ore"},
	["enemy-base"] = {10, 20, "Nests"},
	["expansion_cooldown"] = {-30, -15, "Nest Expansion Cooldown"},
	["enemy_attack_pollution_consumption_modifier"] = {-20, -10, "Nest Pollution Consumption"},
	["max_unit_group_size"] = {15, 30, "Biter Group Size Maximum"},
	["time_factor"] = {15, 30, "Evolution Time Factor"},
	["destroy_factor"] = {15, 30, "Evolution Destroy Factor"},
	["pollution_factor"] = {15, 30, "Evolution Pollution Factor"},
	["ageing"] = {-20, -10, "Terrain Pollution Consumption"},
	["diffusion_ratio"] = {10, 20, "Pollution Diffusion"},
	["technology_price_multiplier"] = {10, 20, "Technology Price"},
}
Public.modifiers = {
	["trees"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Trees"},
	["tree_durability"] = {min = 0.01, max = 10, base = 1, dmin = -30, dmax =-15, name = "Tree Durability"},
	["cliff_settings"] = {min = 0.01, max = 10, base = 1, dmin = 20, dmax = 40, name = "Cliffs"},
	["water"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Water"},
	["coal"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Coal"},
	["stone"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Stone"},
	["iron-ore"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Iron Ore"},
	["copper-ore"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Copper Ore"},
	["crude-oil"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Oil"},
	["uranium-ore"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Uranium Ore"},
	["mixed_ore"] = {min = 0.01, max = 10, base = 1, dmin = -20, dmax = -10, name = "Mixed Ore"},
	["enemy-base"] = {min = 0.01, max = 10, base = 1, dmin = 10, dmax = 20, name = "Nests"},
	["expansion_cooldown"] = {min = 3600, max = 28800, base = 14400, dmin = -20, dmax = -10, name = "Nest Expansion Cooldown"},
	["enemy_attack_pollution_consumption_modifier"] = {min = 0.2, max = 10, base = 1, dmin = -10, dmax = -5, name = "Nest Pollution Consumption"},
	["max_unit_group_size"] = {min = 10, max = 500, base = 100, dmin = 10, dmax = 20, name = "Biter Group Size Maximum"},
	["time_factor"] = {min = 0.000001, max = 0.0001, base = 0.000004, dmin = 15, dmax = 30, name = "Evolution Time Factor"},
	["destroy_factor"] = {min = 0.0002, max = 0.2, base = 0.002, dmin = 15, dmax = 30, name = "Evolution Destroy Factor"},
	["pollution_factor"] = {min = 0.00000009, max = 0.00009, base = 0.0000009, dmin = 15, dmax = 30, name = "Evolution Pollution Factor"},
	["ageing"] = {min = 0.01, max = 4, base = 1, dmin = -20, dmax = -10, name = "Terrain Pollution Consumption"},
	["diffusion_ratio"] = {min = 0.01, max = 0.1, base = 0.02, dmin = 10, dmax = 20, name = "Pollution Diffusion"},
	["technology_price_multiplier"] = {min = 0.5, max = 10, base = 1, dmin = 10, dmax = 20, name = "Technology Price"},
}

Public.starter_goods_pool = {
	{"accumulator", 8, 16},
	{"big-electric-pole", 8, 16},
	{"burner-inserter", 64, 128},
	{"burner-mining-drill", 8, 16},
	{"car", 2, 4},
	{"copper-cable", 128, 256},
	{"copper-plate", 64, 128},
	{"electric-furnace", 4, 8},
	{"electric-mining-drill", 4, 8},
	{"firearm-magazine", 64, 128},
	{"grenade", 8, 16},
	{"gun-turret", 4, 8},
	{"inserter", 32, 64},
	{"iron-gear-wheel", 64, 128},
	{"iron-plate", 64, 128},
	{"lab", 2, 4},
	{"long-handed-inserter", 32, 64},
	{"medium-electric-pole", 16, 32},
	{"pipe", 128, 256},
	{"radar", 4, 8},
	{"small-lamp", 64, 128},
	{"solar-panel", 8, 16},
	{"solid-fuel", 256, 512},
	{"stack-inserter", 16, 32},
	{"stack-filter-inserter", 16, 32},
	{"steam-turbine", 4, 8},
	{"steel-chest", 16, 32},
	{"steel-furnace", 8, 16},
	{"steel-plate", 32, 64},
	{"stone-wall", 128, 256},
	{"substation", 4, 8},
	{"green-wire", 256, 512},
	{"red-wire", 256, 512},
}

Public.build_type_whitelist = {
	["arithmetic-combinator"] = true,
	["constant-combinator"] = true,
	["decider-combinator"] = true,
	["electric-energy-interface"] = true,
	["electric-pole"] = true,
	["gate"] = true,
	["heat-pipe"] = true,
	["lamp"] = true,
	["pipe"] = true,
	["pipe-to-ground"] = true,
	["programmable-speaker"] = true,
	["transport-belt"] = true,
	["wall"] = true,
}

Public.unique_world_traits = {
	["lush"] = {"Lush", "Pure Vanilla.", 1},
	["abandoned_library"] = {"Abandoned Library", "No blueprints to be found.", 3},
	["lazy_bastard"] = {"Lazy Bastard", "The machine does the job.", 4},
	["oceanic"] = {"Oceanic", "Arrrr, the flame turrets seem to malfunction in this climate.", 2},
	["ribbon"] = {"Ribbon", "Go right. (or left)", 4},
	["wasteland"] = {"Wasteland", "Rusty treasures.", 2},
	["infested"] = {"Infested", "They lurk inside.", 4},
	["pitch_black"] = {"Pitch Black", "No light may reach this realm.", 2},
	["volcanic"] = {"Volcanic", "The floor is (almost) lava.", 4},
	["matter_anomaly"] = {"Matter Anomaly", "Why can't i hold all these ores.\nThe laser turret structures seem to malfunction.", 2},
	["mountainous"] = {"Mountainous", "Diggy diggy hole!", 2},
	["eternal_night"] = {"Eternal Night", "This world seems to be missing a sun.", 2},
	["dense_atmosphere"] = {"Dense Atmosphere", "Your roboport structures seem to malfunction.", 3},
	["undead_plague"] = {"Undead Plague", "The dead are restless.", 4},
	["swamps"] = {"Swamps", "No deep water to be found in this world.", 3},
	["chaotic_resources"] = {"Chaotic Resources", "Something to sort out.", 2},
	["low_mass"] = {"Low Mass", "You feel light footed and the robots are buzzing.", 2},
	["eternal_day"] = {"Eternal Day", "The sun never moves.", 1},
	["quantum_anomaly"] = {"Quantum Anomaly", "Research complete.", 2},
	["replicant_fauna"] = {"Replicant Fauna", "The biters feed on your structures.", 4},
	["tarball"] = {"Tarball", "Door stuck, Door stuck...", 4},
	--[[
	]]
}

return Public
