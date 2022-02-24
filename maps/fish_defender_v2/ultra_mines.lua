local Event = require 'utils.event'
local Public = require 'maps.fish_defender_v2.table'
local radius = 8

local function damage_entities_around_target(entity, damage)
    for _, e in pairs(
        entity.surface.find_entities_filtered(
            {
                area = {
                    {entity.position.x - radius, entity.position.y - radius},
                    {entity.position.x + radius, entity.position.y + radius}
                }
            }
        )
    ) do
        if e.health then
            if e.force.name ~= 'player' then
                local distance_from_center = math.sqrt((e.position.x - entity.position.x) ^ 2 + (e.position.y - entity.position.y) ^ 2)
                if distance_from_center <= radius then
                    e.damage(damage, 'player', 'explosion')
                end
            end
        end
    end
end

local function on_entity_died(event)
    local ultra_mines_unlocked = Public.get('ultra_mines_unlocked')
    if not ultra_mines_unlocked then
        return
    end
    local entity = event.entity
    if not entity.valid then
        return
    end

    if entity.name ~= 'land-mine' then
        return
    end

    entity.surface.create_entity(
        {
            name = 'big-artillery-explosion',
            position = entity.position
        }
    )

    local damage = (1 + entity.force.get_ammo_damage_modifier('grenade')) * 250

    damage_entities_around_target(entity, damage)
end

Event.add(defines.events.on_entity_died, on_entity_died)

return Public
