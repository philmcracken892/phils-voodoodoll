local RSGCore = exports['rsg-core']:GetCoreObject()
local isPlaying = false


local function ShowVoodooMenu()
    ExecuteCommand('closeInv')
    lib.registerContext({
        id = 'voodoodoll_selection_menu',
        title = 'Use Voodoo Doll',
        options = {
            {
                title = 'Cast Curse',
                description = 'Choose a nearby player to curse with the voodoo doll.',
                icon = 'fas fa-skull',
                onSelect = function()
                    TriggerServerEvent('rsg-voodoodoll:server:getNearbyPlayers')
                end
            }
        }
    })
    lib.showContext('voodoodoll_selection_menu')
end


RegisterNetEvent('rsg-voodoodoll:client:notify', function(data)
    lib.notify({
        title = data.title,
        description = data.description,
        type = data.type
    })
end)


RegisterNetEvent('rsg-voodoodoll:client:showPlayerSelection', function(players)
    if #players == 0 then
        lib.notify({
            title = 'Voodoo Doll',
            description = 'No players nearby to curse.',
            type = 'error'
        })
        return
    end

    local options = {}
    for _, player in ipairs(players) do
        table.insert(options, {
            title = player.name,
            description = 'Curse ' .. player.name .. ' with the voodoo doll.',
            onSelect = function()
               
                local curseOptions = {}
                for _, curse in ipairs(Config.Curses) do
                    table.insert(curseOptions, {
                        title = curse.desc,
                        description = 'Apply ' .. curse.desc .. ' to ' .. player.name,
                        onSelect = function()
                            TriggerEvent('rsg-voodoodoll:client:useVoodooDoll', player.id, curse)
                        end
                    })
                end
                lib.registerContext({
                    id = 'voodoodoll_curse_menu',
                    title = 'Select Curse for ' .. player.name,
                    options = curseOptions
                })
                lib.showContext('voodoodoll_curse_menu')
            end
        })
    end

    lib.registerContext({
        id = 'voodoodoll_player_menu',
        title = 'Select Player to Curse',
        options = options
    })
    lib.showContext('voodoodoll_player_menu')
end)


RegisterNetEvent('rsg-voodoodoll:client:useVoodooDoll', function(targetId, curse)
    if isPlaying then return end
    isPlaying = true
    local ped = PlayerPedId()
    local animType = 'WORLD_HUMAN_GUARD_LANTERN_NERVOUS'

    lib.notify({
        title = 'Using Voodoo Doll',
        description = 'Press [E] to stop using',
        type = 'info'
    })

   
    CreateThread(function()
        while isPlaying do
            ClearPedTasks(ped)
            TaskStartScenarioInPlace(ped, joaat(animType), Config.AnimationDuration, true, false, false, false)
            Wait(Config.AnimationDuration)
            if isPlaying then
                TriggerServerEvent('rsg-voodoodoll:server:cursePlayer', targetId, curse)
            end
        end
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        TaskClearLookAt(ped)
    end)

    
    CreateThread(function()
        while isPlaying do
            if IsControlJustPressed(0, 0xCEFD9220) then -- E key
                isPlaying = false
                break
            end
            Wait(0)
        end
    end)

    
    CreateThread(function()
        Wait(Config.Timeout)
        if isPlaying then
            isPlaying = false
        end
    end)
end)


RegisterNetEvent('rsg-voodoodoll:client:applyCurse', function(curse)
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)

    if curse.type == 'scenario' then
        TaskStartScenarioInPlace(ped, joaat(curse.anim), Config.CurseDuration, true, false, false, false)
    elseif curse.type == 'dict' then
        
        RequestAnimDict(curse.animDict)
        while not HasAnimDictLoaded(curse.animDict) do
            Wait(100)
        end
        
        TaskPlayAnim(ped, curse.animDict, curse.animName, 8.0, -8.0, Config.CurseDuration, 0, 0, false, false, false)
        
        CreateThread(function()
            Wait(Config.CurseDuration)
            ClearPedTasksImmediately(ped)
        end)
    end

    lib.notify({
        title = 'Cursed!',
        description = curse.desc,
        type = 'inform'
    })
end)


RegisterNetEvent('rsg-voodoodoll:client:clearTasks', function()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)
    TaskClearLookAt(ped)
    isPlaying = false
end)


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if isPlaying then
        local ped = PlayerPedId()
        ClearPedTasksImmediately(ped)
        ClearPedSecondaryTask(ped)
        TaskClearLookAt(ped)
        isPlaying = false
    end
end)


RegisterNetEvent('rsg-voodoodoll:client:openVoodooMenu', function()
    ShowVoodooMenu()
end)