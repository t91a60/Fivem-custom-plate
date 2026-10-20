local Validation = {}

local function integer(value, minimum, maximum)
    return type(value) == 'number' and value % 1 == 0
        and value >= minimum and value <= maximum
end

function Validation.ResolveUrl(value, resourceName)
    if type(value) ~= 'string' or value == '' then
        return nil, 'Image source must be a non-empty string'
    end
    if value:find('[%c%s]') then
        return nil, 'Image source contains whitespace or control characters'
    end
    if value:match('^https?://[^/]+') then return value end
    if value:match('^assets/[%w_/%-%.]+$') and not value:find('..', 1, true)
        and (value:match('%.png$') or value:match('%.jpe?g$') or value:match('%.webp$')) then
        return ('https://cfx-nui-%s/%s'):format(resourceName, value)
    end
    return nil, 'Use an http(s) URL or an assets/ path to a PNG, JPG, JPEG or WebP image'
end

function Validation.Check(config, resourceName)
    if type(config) ~= 'table' then return nil, 'Config must be a table' end
    if not integer(config.DuiWidth, 1, 4096) or not integer(config.DuiHeight, 1, 4096) then
        return nil, 'DuiWidth and DuiHeight must be integers from 1 to 4096'
    end
    local timeout = config.DuiTimeoutMs
    if timeout == nil then timeout = 10000 end
    if not integer(timeout, 1, 60000) then return nil, 'DuiTimeoutMs must be 1 to 60000' end
    local sources, seen = {}, {}
    for _, spec in ipairs({
        { key = 'DiffuseImageUrl', targets = 'PlateTextures', name = 'diffuse' },
        { key = 'NormalMapUrl', targets = 'PlateNormalTextures', name = 'normal' },
    }) do
        local value = config[spec.key]
        if value ~= nil and value ~= '' then
            local url, err = Validation.ResolveUrl(value, resourceName)
            if not url then return nil, spec.key .. ': ' .. err end
            local targets = config[spec.targets]
            if type(targets) ~= 'table' or #targets == 0 then
                return nil, spec.targets .. ' must be a non-empty array'
            end
            local count = 0
            for index, target in pairs(targets) do
                if not integer(index, 1, #targets) or type(target) ~= 'table'
                    or type(target.dictionary) ~= 'string' or target.dictionary == ''
                    or type(target.texture) ~= 'string' or target.texture == '' then
                    return nil, spec.targets .. ' contains an invalid target'
                end
                local id = target.dictionary:lower() .. '\0' .. target.texture:lower()
                if seen[id] then return nil, 'Duplicate texture target' end
                seen[id] = true
                count = count + 1
            end
            if count ~= #targets then return nil, spec.targets .. ' must be a dense array' end
            sources[#sources + 1] = { name = spec.name, url = url, targets = targets }
        end
    end
    if #sources == 0 then return nil, 'Configure DiffuseImageUrl or NormalMapUrl' end
    return { sources = sources, timeout = timeout }
end

return Validation
