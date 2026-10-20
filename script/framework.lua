local Framework = {}

local function detectFramework()
    if GetResourceState('es_extended') == 'started' then return 'esx' end
    if GetResourceState('qb-core') == 'started' then return 'qbcore' end
    if GetResourceState('ox_core') == 'started' then return 'ox' end
    return 'standalone'
end

function Framework.Init(configFramework)
    Framework.ESX, Framework.QBCore, Framework.Ox = nil, nil, nil
    local name = configFramework == 'auto' and detectFramework() or configFramework
    if name == 'standalone' then return name end
    local ok = pcall(function()
        if name == 'esx' then
            Framework.ESX = exports['es_extended']:getSharedObject()
        elseif name == 'qbcore' then
            Framework.QBCore = exports['qb-core']:GetCoreObject()
        elseif name == 'ox' and GetResourceState('ox_core') == 'started' then
            Framework.Ox = exports.ox_core
        else
            error('Framework unavailable')
        end
    end)
    if ok then return name end
    Framework.ESX, Framework.QBCore, Framework.Ox = nil, nil, nil
    print('[CustomPlate] Framework unavailable; continuing in standalone mode')
    return 'standalone'
end

-- Retain the old module API without invoking server-only functions on a client.
function Framework.GetPlayerIdentifier()
    return nil
end

-- Client-side helpers cannot authorize server actions.
function Framework.HasPermission()
    return false
end

return Framework
