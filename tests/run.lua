local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print('PASS ' .. name)
end
local Validation = dofile('script/validation.lua')
local function config()
    return {
        Framework = 'standalone', DiffuseImageUrl = 'https://example.test/plate.png',
        NormalMapUrl = '', DuiWidth = 540, DuiHeight = 300, DuiTimeoutMs = 30,
        PlateTextures = {{dictionary = 'vehshare', texture = 'plate01'},
            {dictionary = 'vehshare', texture = 'plate02'}},
        PlateNormalTextures = {{dictionary = 'vehshare', texture = 'plate01_n'}},
    }
end
local function boot(cfg, options)
    options = options or {}
    local events, api = {}, {}
    local calls = {duis = 0, runtime = 0, added = 0, removed = 0, destroyed = 0, order = {}}
    local now, waitCount = 0, 0
    local env = setmetatable({}, {__index = _G})
    env.print = function() end
    env.require = function(name)
        if name == 'config' then return cfg end
        if name == 'script.validation' then return Validation end
        if name == 'script.framework' then
            return {Init = function() if options.frameworkError then error('Missing framework') end end}
        end
        error('Unexpected module ' .. name)
    end
    env.GetCurrentResourceName = function() return 'custom-plate' end
    env.AddEventHandler = function(name, fn) events[name] = fn end
    env.exports = function(name, fn) api[name] = fn end
    env.CreateThread = function(fn) fn() end
    env.GetGameTimer = function() return now end
    env.Wait = function()
        now = now + 10
        waitCount = waitCount + 1
        if options.stopWhileWaiting then events.onClientResourceStop('custom-plate') end
    end
    env.CreateRuntimeTxd = function(name)
        assert(name == 'custom_plate_custom-plate')
        if options.dictionaryFail then return 0 end
        return 123
    end
    env.CreateDui = function(url, width, height)
        assert(type(url) == 'string' and width == cfg.DuiWidth and height == cfg.DuiHeight)
        calls.duis = calls.duis + 1
        if options.duiFail or options.failDuiNumber == calls.duis then return 0 end
        return calls.duis
    end
    env.IsDuiAvailable = function()
        assert(calls.destroyed == 0, 'Polled a destroyed DUI')
        return not options.timeout and not options.stopWhileWaiting and waitCount >= (options.waits or 0)
    end
    env.GetDuiHandle = function(id)
        if options.handleFail then return '' end
        return 'browser:' .. id
    end
    env.CreateRuntimeTextureFromDuiHandle = function(dictionary, name, handle)
        assert(dictionary == 123 and name:match('^plate_') and handle:match('^browser:'))
        calls.runtime = calls.runtime + 1
        if options.runtimeFail then return 0 end
        return 456
    end
    env.AddReplaceTexture = function(_, _, dictionary, _)
        assert(type(dictionary) == 'string' and dictionary == 'custom_plate_custom-plate')
        calls.added = calls.added + 1
        if options.replaceFail == calls.added then error('Native failure') end
    end
    env.RemoveReplaceTexture = function()
        calls.removed = calls.removed + 1
        calls.order[#calls.order + 1] = 'remove'
    end
    env.DestroyDui = function()
        calls.destroyed = calls.destroyed + 1
        calls.order[#calls.order + 1] = 'destroy'
    end
    assert(loadfile('script/plate.lua', 't', env))()
    events.onClientResourceStart('other-resource')
    assert(calls.duis == 0)
    events.onClientResourceStart('custom-plate')
    return api, calls, events
end

test('legacy config without timeout', function()
    local c = config(); c.DuiTimeoutMs = nil
    assert(Validation.Check(c, 'custom-plate').timeout == 10000)
end)
test('local image path', function()
    assert(Validation.ResolveUrl('assets/plate.png', 'renamed') == 'https://cfx-nui-renamed/assets/plate.png')
end)
test('reject unsafe image schemes and traversal', function()
    for _, value in ipairs({'file:///c:/plate.png', 'javascript:alert(1)', 'assets/../secret.png',
        'assets/a b.png', 'assets/page.html', 42, false}) do
        assert(not Validation.ResolveUrl(value, 'custom-plate'))
    end
end)
test('reject missing sources', function()
    local c = config(); c.DiffuseImageUrl = ''
    assert(not Validation.Check(c, 'custom-plate'))
end)
test('reject malformed dimensions and timeout', function()
    for _, value in ipairs({0, -1, 4097, 1.5, '540', false}) do
        local c = config(); c.DuiWidth = value
        assert(not Validation.Check(c, 'custom-plate'))
    end
    local c = config(); c.DuiTimeoutMs = false
    assert(not Validation.Check(c, 'custom-plate'))
end)
test('reject duplicate and malformed targets', function()
    local c = config(); c.PlateTextures[2] = c.PlateTextures[1]
    assert(not Validation.Check(c, 'custom-plate'))
    c = config(); c.PlateTextures[1].texture = 42
    assert(not Validation.Check(c, 'custom-plate'))
    c = config(); c.PlateTextures.extra = c.PlateTextures[1]
    assert(not Validation.Check(c, 'custom-plate'))
end)
test('one runtime texture per channel and stop cleanup', function()
    local c = config(); c.NormalMapUrl = 'https://example.test/normal.png'
    local api, calls, events = boot(c, {waits = 2})
    assert(api.IsInitialized() and calls.runtime == 2 and calls.added == 3)
    assert(api.GetPlateState().diffuseUrl == c.DiffuseImageUrl)
    assert(api.GetPlateState().normalUrl == c.NormalMapUrl)
    assert(api.GetPlateState().replacementsApplied and api.GetPlateState().replacementCount == 3)
    events.onClientResourceStart('custom-plate')
    assert(calls.duis == 2)
    events.onClientResourceStop('other-resource'); assert(api.IsInitialized())
    events.onClientResourceStop('custom-plate')
    assert(not api.IsInitialized() and calls.removed == 3 and calls.destroyed == 2)
    assert(table.concat(calls.order, ',') == 'remove,remove,remove,destroy,destroy')
    events.onClientResourceStop('custom-plate'); assert(calls.destroyed == 2)
end)
test('normal-only configuration', function()
    local c = config(); c.DiffuseImageUrl = ''; c.NormalMapUrl = 'assets/normal.png'
    local api, calls = boot(c)
    assert(api.IsInitialized() and calls.runtime == 1 and calls.added == 1)
end)
test('invalid config creates no browsers', function()
    local c = config(); c.DuiHeight = 0
    local api, calls = boot(c)
    assert(not api.IsInitialized() and api.GetPlateState().error and calls.duis == 0)
end)
test('framework failure does not block textures', function()
    local api = boot(config(), {frameworkError = true})
    assert(api.IsInitialized())
end)
test('DUI timeout cleans up', function()
    local api, calls = boot(config(), {timeout = true})
    assert(not api.IsInitialized() and calls.added == 0 and calls.destroyed == 1)
end)
test('stop during DUI wait cancels initialization', function()
    local api, calls = boot(config(), {stopWhileWaiting = true})
    assert(not api.IsInitialized() and calls.added == 0 and calls.destroyed == 1)
end)
test('partial replacement failure rolls back', function()
    local api, calls = boot(config(), {replaceFail = 2})
    assert(not api.IsInitialized() and calls.removed == 2 and calls.destroyed == 1)
    assert(api.GetPlateState().replacementCount == 0 and api.GetPlateState().error)
end)
test('normal channel failure cleans prepared diffuse without replacing targets', function()
    local c = config(); c.NormalMapUrl = 'https://example.test/normal.png'
    local api, calls = boot(c, {failDuiNumber = 2})
    assert(not api.IsInitialized() and calls.added == 0 and calls.destroyed == 1)
    assert(api.GetPlateState().error == 'Initialization failed at normal DUI')
end)
for _, failure in ipairs({'dictionaryFail', 'duiFail', 'handleFail', 'runtimeFail'}) do
    test(failure .. ' prevents ready state', function()
        local api, calls = boot(config(), {[failure] = true})
        assert(not api.IsInitialized() and calls.added == 0 and api.GetPlateState().error)
        if failure == 'handleFail' or failure == 'runtimeFail' then assert(calls.destroyed == 1) end
    end)
end

test('framework standalone, fallback and fail-closed helpers', function()
    local env = setmetatable({
        GetResourceState = function() return 'missing' end,
        exports = {}, print = function() end,
    }, {__index = _G})
    local framework = assert(loadfile('script/framework.lua', 't', env))()
    assert(framework.Init('auto') == 'standalone')
    assert(framework.Init('standalone') == 'standalone')
    assert(framework.Init('esx') == 'standalone')
    assert(framework.Init('qbcore') == 'standalone')
    assert(framework.Init('ox') == 'standalone')
    assert(framework.GetPlayerIdentifier() == nil and framework.HasPermission() == false)
end)
print(('PASS: %d tests; Lua %s'):format(passed, _VERSION))
