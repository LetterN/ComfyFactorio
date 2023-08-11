local Color = require 'utils.color_presets'
local Public = require 'maps.mountain_fortress_v3.table'
local Task = require 'utils.task'
local Server = require 'utils.server'
local Collapse = require 'modules.collapse'
local WD = require 'modules.wave_defense.table'

local mapkeeper = '[color=blue]Mapkeeper:[/color]'

commands.add_command(
    'scenario',
    'Usable only for admins - controls the scenario!',
    function(cmd)
        local p
        local player = game.player

        if not player or not player.valid then
            p = log
        else
            p = player.print
            if not player.admin then
                return
            end
        end

        local this = Public.get()
        local param = cmd.parameter

        if param == 'restart' or param == 'shutdown' or param == 'reset' or param == 'restartnow' then
            goto continue
        else
            p('[ERROR] Arguments are:\nrestart\nshutdown\nreset\nrestartnow')
            return
        end

        ::continue::

        if not this.reset_are_you_sure then
            this.reset_are_you_sure = true
            p('[WARNING] This command will disable the soft-reset feature, run this command again if you really want to do this!')
            return
        end

        if param == 'restart' then
            if this.restart then
                this.reset_are_you_sure = nil
                this.restart = false
                this.soft_reset = true
                p('[SUCCESS] Soft-reset is enabled.')
                return
            else
                this.reset_are_you_sure = nil
                this.restart = true
                this.soft_reset = false
                if this.shutdown then
                    this.shutdown = false
                end
                p('[WARNING] Soft-reset is disabled! Server will restart from scenario to load new changes.')
                return
            end
        elseif param == 'restartnow' then
            this.reset_are_you_sure = nil
            Server.start_scenario('Mountain_Fortress_v3')
            return
        elseif param == 'shutdown' then
            if this.shutdown then
                this.reset_are_you_sure = nil
                this.shutdown = false
                this.soft_reset = true
                p('[SUCCESS] Soft-reset is enabled.')
                return
            else
                this.reset_are_you_sure = nil
                this.shutdown = true
                this.soft_reset = false
                if this.restart then
                    this.restart = false
                end
                p('[WARNING] Soft-reset is disabled! Server will shutdown. Most likely because of updates.')
                return
            end
        elseif param == 'reset' then
            this.reset_are_you_sure = nil
            if player and player.valid then
                game.print(mapkeeper .. ' ' .. player.name .. ', has reset the game!', {r = 0.98, g = 0.66, b = 0.22})
            else
                game.print(mapkeeper .. ' server, has reset the game!', {r = 0.98, g = 0.66, b = 0.22})
            end
            Public.reset_map()
            p('[WARNING] Game has been reset!')
            return
        end
    end
)

commands.add_command(
    'set_queue_speed',
    'Usable only for admins - sets the queue speed of this map!',
    function(cmd)
        local player = game.player
        local param = tonumber(cmd.parameter)

        if player and player.valid then
            if not player.admin then
                player.print("[ERROR] You're not admin!", Color.fail)
                return
            end
            if not param then
                return
            end
            player.print('Queue speed set to: ' .. param)
            Task.set_queue_speed(param)
        else
            log('Queue speed set to: ' .. param)
            Task.set_queue_speed(param)
        end
    end
)

commands.add_command(
    'disable_biters',
    'Usable only for admins - disables wave defense!',
    function()
        local player = game.player

        if not player or not player.valid then
            return
        end
        if not player.admin then
            player.print("[ERROR] You're not admin!", Color.fail)
            return
        end

        local this = Public.get()
        local tbl = WD.get()

        if not this.disable_biters_are_you_sure then
            this.disable_biters_are_you_sure = true
            player.print('[WARNING] This command will disable the wave_defense in-game, run this command again if you really want to do this!', Color.warning)
            return
        end

        if not tbl.game_lost then
            game.print(mapkeeper .. ' ' .. player.name .. ', has disabled the wave_defense module!', {r = 0.98, g = 0.66, b = 0.22})
            tbl.game_lost = true
        else
            game.print(mapkeeper .. ' ' .. player.name .. ', has enabled the wave_defense module!', {r = 0.98, g = 0.66, b = 0.22})
            tbl.game_lost = false
        end

        this.disable_biters_are_you_sure = nil
    end
)

commands.add_command(
    'toggle_orbital_strikes',
    'Usable only for admins - toggles orbital strikes!',
    function()
        local player = game.player
        if not player or not player.valid then
            return
        end
        if not player.admin then
            player.print("[ERROR] You're not admin!", Color.fail)
            return
        end

        local this = Public.get()

        if not this.orbital_strikes_are_you_sure then
            this.orbital_strikes_are_you_sure = true
            player.print('[WARNING] This command will disable the orbital_strikes in-game, run this command again if you really want to do this!', Color.warning)
            return
        end

        if this.orbital_strikes.enabled then
            game.print(mapkeeper .. ' ' .. player.name .. ', has disabled the orbital_strikes module!', {r = 0.98, g = 0.66, b = 0.22})
            this.orbital_strikes.enabled = false
        else
            game.print(mapkeeper .. ' ' .. player.name .. ', has enabled the orbital_strikes module!', {r = 0.98, g = 0.66, b = 0.22})
            this.orbital_strikes.enabled = true
        end

        this.orbital_strikes_are_you_sure = nil
    end
)

commands.add_command(
    'toggle_end_game',
    'Usable only for admins - initiates the final battle!',
    function()
        local player = game.player
        if not player or not player.valid then
            return
        end
        if not player.admin then
            player.print("[ERROR] You're not admin!", Color.fail)
            return
        end

        local this = Public.get()

        if not this.final_battle_are_you_sure then
            this.final_battle_are_you_sure = true
            player.print('[WARNING] This command will trigger the final battle, ONLY run this command again if you really want to do this!', Color.warning)
            return
        end

        Public.stateful.set_stateful('final_battle', true)
        Public.set('final_battle', true)

        game.print(mapkeeper .. ' ' .. player.name .. ', has triggered the final battle sequence!', {r = 0.98, g = 0.66, b = 0.22})

        this.final_battle_are_you_sure = nil
    end
)

commands.add_command(
    'get_queue_speed',
    'Usable only for admins - gets the queue speed of this map!',
    function()
        local p
        local player = game.player

        if player and player.valid then
            p = player.print
            if not player.admin then
                p("[ERROR] You're not admin!", Color.fail)
                return
            end
            p(Task.get_queue_speed())
        else
            p = log
            p(Task.get_queue_speed())
        end
    end
)

commands.add_command(
    'disable_collapse',
    'Toggles the collapse feature',
    function()
        local player = game.player

        if player and player.valid then
            if not player.admin then
                player.print("[ERROR] You're not admin!", Color.fail)
                return
            end
            if Collapse.get_disable_state() then
                Collapse.disable_collapse(false)
                game.print(mapkeeper .. ' ' .. player.name .. ', has enabled collapse!', {r = 0.98, g = 0.66, b = 0.22})
                log(player.name .. ', has enabled collapse!')
            else
                Collapse.disable_collapse(true)
                game.print(mapkeeper .. ' ' .. player.name .. ', has disabled collapse!', {r = 0.98, g = 0.66, b = 0.22})
                log(player.name .. ', has disabled collapse!')
            end
        else
            if Collapse.get_disable_state() then
                Collapse.disable_collapse(false)
                log('Collapse has started.')
            else
                Collapse.disable_collapse(true)
                log('Collapse has stopped.')
            end
        end
    end
)

return Public
