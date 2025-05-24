local RSGCore = exports['rsg-core']:GetCoreObject()


RSGCore.Functions.CreateUseableItem('voodoodoll', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return end
    TriggerClientEvent('rsg-voodoodoll:client:openVoodooMenu', source)
end)


local cooldowns = {}


RegisterNetEvent('rsg-voodoodoll:server:getNearbyPlayers', function()
    local src = source
    local users = RSGCore.Functions.GetPlayers()
    local nearbyPlayers = {}
    local userCoords = GetEntityCoords(GetPlayerPed(src))

    for _, playerId in pairs(users) do
        if playerId ~= src then
            local targetPed = GetPlayerPed(playerId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(userCoords - targetCoords)
            if distance <= Config.MaxDistance then
                local Player = RSGCore.Functions.GetPlayer(playerId)
                if Player then
                    table.insert(nearbyPlayers, {
                        id = playerId,
                        name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
                    })
                end
            end
        end
    end

    TriggerClientEvent('rsg-voodoodoll:client:showPlayerSelection', src, nearbyPlayers)
end)


RegisterNetEvent('rsg-voodoodoll:server:cursePlayer', function(targetId, curse)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    
    if cooldowns[src] and cooldowns[src] > GetGameTimer() then
        
        return
    end

   
    local targetPlayer = RSGCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('rsg-voodoodoll:client:notify', src, {
            title = 'Voodoo Doll',
            description = 'Target player is no longer available.',
            type = 'error'
        })
        return
    end

    local userCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    if #(userCoords - targetCoords) > Config.MaxDistance then
        TriggerClientEvent('rsg-voodoodoll:client:notify', src, {
            title = 'Voodoo Doll',
            description = 'Target player is too far away.',
            type = 'error'
        })
        return
    end

    
    local validCurse = false
    for _, c in ipairs(Config.Curses) do
        if c.anim == curse.anim or c.animDict == curse.animDict then
            validCurse = true
            break
        end
    end
    if not validCurse then
        TriggerClientEvent('rsg-voodoodoll:client:notify', src, {
            title = 'Voodoo Doll',
            description = 'Invalid curse selected.',
            type = 'error'
        })
        return
    end

    
    TriggerClientEvent('rsg-voodoodoll:client:applyCurse', targetId, curse)
    
    TriggerClientEvent('rsg-voodoodoll:client:notify', src, {
        title = 'Voodoo Doll',
        description = 'You cursed ' .. targetPlayer.PlayerData.charinfo.firstname .. ' ' .. targetPlayer.PlayerData.charinfo.lastname .. '!',
        type = 'success'
    })
   
    cooldowns[src] = GetGameTimer() + Config.Cooldown
end)


AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    local users = RSGCore.Functions.GetPlayers()
    for _, playerId in pairs(users) do
        TriggerClientEvent('rsg-voodoodoll:client:clearTasks', playerId)
    end
    
    cooldowns = {}
end)