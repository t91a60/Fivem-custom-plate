local Config = require 'config'
local Framework = require 'script.framework'
local Validation = require 'script.validation'
local resourceName = GetCurrentResourceName()
local dictionaryName = 'custom_plate_' .. resourceName
local state = {
    initialized = false,
    replacementsApplied = false,
    initializing = false,
    stopped = false,
    duis = {},
    replacements = {},
    error = nil,
}

local function log(message)
    print('[CustomPlate] ' .. message)
end

local function cleanup()
    -- Unbind textures before destroying the browsers that supply them.
    for index = #state.replacements, 1, -1 do
        local target = state.replacements[index]
        local ok = pcall(RemoveReplaceTexture, target.dictionary, target.texture)
        if not ok then log('Failed to remove a texture replacement') end
    end
    state.replacements = {}
    for _, dui in ipairs(state.duis) do
        local ok = pcall(DestroyDui, dui)
        if not ok then log('Failed to destroy a DUI object') end
    end
    state.duis = {}
    state.initialized = false
    state.replacementsApplied = false
end

local function initialize()
    if state.initialized or state.initializing or state.stopped then return end
    state.initializing = true
    local settings, configError = Validation.Check(Config, resourceName)
    if not settings then
        state.error = configError
        state.initializing = false
        log(configError)
        return
    end
    local frameworkOk = pcall(Framework.Init, Config.Framework or 'auto')
    if not frameworkOk then log('Framework unavailable; continuing in standalone mode') end
    local stage = 'runtime dictionary'
    local ok = pcall(function()
        local dictionary = CreateRuntimeTxd(dictionaryName)
        if not dictionary or dictionary == 0 then error('No runtime dictionary') end
        -- Prepare every source before modifying any game texture.
        for _, source in ipairs(settings.sources) do
            stage = source.name .. ' DUI'
            local dui = CreateDui(source.url, Config.DuiWidth, Config.DuiHeight)
            if not dui or dui == 0 then error('No DUI object') end
            state.duis[#state.duis + 1] = dui
            local started = GetGameTimer()
            while true do
                if state.stopped then return end
                if IsDuiAvailable(dui) then break end
                if GetGameTimer() - started >= settings.timeout then error('DUI timeout') end
                Wait(0)
            end
            if state.stopped then return end
            local handle = GetDuiHandle(dui)
            if not handle or handle == '' then error('No DUI handle') end
            source.textureName = 'plate_' .. source.name
            local texture = CreateRuntimeTextureFromDuiHandle(dictionary, source.textureName, handle)
            if not texture or texture == 0 then error('No runtime texture') end
        end
        for _, source in ipairs(settings.sources) do
            for _, target in ipairs(source.targets) do
                stage = source.name .. ' replacement'
                -- Track before the call so rollback also covers a native that throws.
                state.replacements[#state.replacements + 1] = target
                AddReplaceTexture(target.dictionary, target.texture, dictionaryName, source.textureName)
                if Config.Debug then log('Applied ' .. target.dictionary .. '/' .. target.texture) end
            end
        end
    end)
    state.initializing = false
    if state.stopped then return end
    if not ok then
        cleanup()
        state.error = 'Initialization failed at ' .. stage
        log(state.error)
        return
    end
    state.initialized = true
    state.replacementsApplied = true
    state.error = nil
    log('Custom plate backgrounds initialized')
end

AddEventHandler('onClientResourceStart', function(name)
    if name == resourceName then CreateThread(initialize) end
end)
AddEventHandler('onClientResourceStop', function(name)
    if name ~= resourceName then return end
    state.stopped = true
    cleanup()
end)
exports('IsInitialized', function() return state.initialized end)
exports('GetPlateState', function()
    return {
        initialized = state.initialized,
        replacementsApplied = state.replacementsApplied,
        diffuseUrl = Config.DiffuseImageUrl,
        normalUrl = Config.NormalMapUrl,
        initializing = state.initializing,
        error = state.error,
        replacementCount = #state.replacements,
    }
end)
