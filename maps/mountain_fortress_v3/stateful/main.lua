local Public = require 'maps.mountain_fortress_v3.stateful.table'
local Event = require 'utils.event'
local WD = require 'modules.wave_defense.table'
local Beam = require 'modules.render_beam'
local RPG = require 'modules.rpg.main'

Public.stateful_gui = require 'maps.mountain_fortress_v3.stateful.gui'
Public.stateful_terrain = require 'maps.mountain_fortress_v3.stateful.terrain'
Public.stateful_generate = require 'maps.mountain_fortress_v3.stateful.generate'
Public.stateful_blueprints = require 'maps.mountain_fortress_v3.stateful.blueprints'

local random = math.random
local shuffle = table.shuffle_table

Event.add(
    defines.events.on_research_finished,
    function(event)
        local research = event.research
        if not research then
            return
        end

        local name = research.name
        local objectives = Public.get_stateful('objectives')
        if not objectives then
            return
        end
        if not objectives.research_level_selection then
            return
        end

        if name == objectives.research_level_selection.name then
            objectives.research_level_selection.research_count = objectives.research_level_selection.research_count + 1
        end
    end
)

Event.on_nth_tick(
    120,
    function()
        local final_battle = Public.get_stateful('final_battle')
        if not final_battle then
            return
        end

        local collection = Public.get_stateful('collection')
        if not collection then
            return
        end

        if collection.final_arena_disabled then
            return
        end

        Public.allocate()
        Public.set_final_battle()

        if collection.time_until_attack and collection.time_until_attack <= 0 and collection.survive_for and collection.survive_for > 0 then
            local surface = game.get_surface('boss_room')
            if not surface or not surface.valid then
                return
            end

            local spawn_positions = Public.stateful_spawn_points
            local sizeof = Public.sizeof_stateful_spawn_points

            local area = spawn_positions[random(1, sizeof)]

            shuffle(area)

            WD.build_worm_custom()

            WD.set_spawn_position(area[1])
            Event.raise(WD.events.on_spawn_unit_group, {fs = true, bypass = true, random_bosses = true, scale = 4, force = 'aggressors_frenzy'})
            return
        end

        if collection.time_until_attack and collection.survive_for and collection.survive_for == 0 then
            if not collection.game_won then
                collection.game_won = true
            end
        end
    end
)

Event.add(
    defines.events.on_player_crafted_item,
    function(event)
        local player = game.get_player(event.player_index)
        if not player or not player.valid then
            return
        end

        local item = event.item_stack
        if not item or not item.valid_for_read then
            return
        end

        local objectives = Public.get_stateful('objectives')

        local handcrafted_items_any = objectives.handcrafted_items_any
        if handcrafted_items_any then
            handcrafted_items_any.actual = handcrafted_items_any.actual + item.count
        end

        local handcrafted_items = objectives.handcrafted_items
        if handcrafted_items then
            if item.name ~= handcrafted_items.name then
                return
            end

            handcrafted_items.actual = handcrafted_items.actual + item.count
        end
    end
)

Event.add(
    defines.events.on_entity_died,
    function(event)
        local entity = event.entity
        if not entity or not entity.valid then
            return
        end

        if not Public.valid_enemy_forces[entity.force.name] then
            return
        end

        local objectives = Public.get_stateful('objectives')

        local damage_type = event.damage_type
        if not damage_type then
            return
        end
        local killed_enemies = objectives.killed_enemies_type
        if not killed_enemies then
            return
        end

        if killed_enemies.damage_type ~= damage_type.name then
            return
        end

        if entity.type == 'unit' then
            killed_enemies.actual = killed_enemies.actual + 1
        end
    end
)

Event.add(
    defines.events.on_rocket_launched,
    function(event)
        local rocket_inventory = event.rocket.get_inventory(defines.inventory.rocket)
        local slot = rocket_inventory[1]
        if slot and slot.valid and slot.valid_for_read then
            local objectives = Public.get_stateful('objectives')

            local launch_item = objectives.launch_item
            if launch_item then
                if slot.name ~= launch_item.name then
                    return
                end

                launch_item.actual = launch_item.actual + slot.count
            end
        end
    end
)

Event.add(
    RPG.events.on_spell_cast_success,
    function(event)
        local player = game.get_player(event.player_index)
        if not player or not player.valid then
            return
        end

        local spell_name = event.spell_name
        local amount = event.amount

        if not player.character or not player.character.valid then
            return
        end

        local objectives = Public.get_stateful('objectives')

        local cast_spell_any = objectives.cast_spell_any
        if cast_spell_any then
            cast_spell_any.actual = cast_spell_any.actual + amount
        end

        local cast_spell = objectives.cast_spell
        if cast_spell then
            if spell_name ~= cast_spell.name then
                return
            end

            cast_spell.actual = cast_spell.actual + amount
        end
    end
)

Event.on_nth_tick(
    14400,
    function()
        local final_battle = Public.get_stateful('final_battle')
        if not final_battle then
            return
        end

        local collection = Public.get_stateful('collection')
        if not collection then
            return
        end

        if collection.final_arena_disabled then
            return
        end

        local surface = game.get_surface('boss_room')
        if not surface or not surface.valid then
            return
        end

        if collection.time_until_attack and collection.time_until_attack <= 0 and collection.survive_for > 0 then
            Beam.new_beam(surface, game.tick + 150)
        end
    end
)

Event.add(defines.events.on_pre_player_died, Public.on_pre_player_died)
Event.add(Public.events.on_market_item_purchased, Public.on_market_item_purchased)

return Public
