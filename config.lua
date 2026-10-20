Config = {}

-- Optional compatibility setting: auto, standalone, esx, qbcore, ox.
-- Texture replacement does not require a framework.
Config.Framework = 'auto'

-- Existing http(s) URLs still work. Prefer assets/plate.png for a bundled image.
-- At least one source is required. Empty values disable that channel.
Config.DiffuseImageUrl = ''
Config.NormalMapUrl = ''

-- Keep the image composition and aspect ratio suited to your vehicle's plate UVs.
Config.DuiWidth = 540
Config.DuiHeight = 300
Config.DuiTimeoutMs = 10000

Config.PlateTextures = {
    { dictionary = 'vehshare', texture = 'plate01' },
    { dictionary = 'vehshare', texture = 'plate02' },
    { dictionary = 'vehshare', texture = 'plate03' },
    { dictionary = 'vehshare', texture = 'plate04' },
    { dictionary = 'vehshare', texture = 'plate05' },
}
Config.PlateNormalTextures = {
    { dictionary = 'vehshare', texture = 'plate01_n' },
    { dictionary = 'vehshare', texture = 'plate02_n' },
    { dictionary = 'vehshare', texture = 'plate03_n' },
    { dictionary = 'vehshare', texture = 'plate04_n' },
    { dictionary = 'vehshare', texture = 'plate05_n' },
}

Config.Debug = false
return Config
