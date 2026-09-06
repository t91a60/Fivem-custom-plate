# FiveM Custom Plates

A client-side FiveM resource that replaces GTA V license-plate textures with images loaded through DUI runtime textures. It can replace the diffuse texture, an optional normal map, or both.

## Features

- Replaces the configured `vehshare` plate textures at resource startup.
- Supports one diffuse image and an optional normal-map image.
- Configurable DUI width and height for the quality/VRAM trade-off.
- Detects ESX, QBCore, or Ox Core and falls back to standalone mode.
- Initializes once, reports configuration errors, and destroys DUI objects when the resource stops.
- Exposes initialization state to other client resources.

The replacement is global for the texture names listed in `Config.PlateTextures` and `Config.PlateNormalTextures`. This resource does not assign a different image to each vehicle or plate number.

## Installation

1. Place the repository in your FiveM server's `resources` directory. You may rename the folder to a short resource name such as `custom-plate`.
2. Set at least `Config.DiffuseImageUrl` in `config.lua`.
3. Add the resource to `server.cfg`, using the actual folder name:

```text
ensure custom-plate
```

4. Restart the resource or server and check the client console for `[CustomPlate]` messages.

## Configuration

All user-facing settings are in `config.lua`.

### Framework

```lua
Config.Framework = 'auto'
```

Accepted values are `auto`, `esx`, `qbcore`, `ox`, and `standalone`. Framework integration is currently limited to detection and helper setup; texture replacement also works without a framework.

### Images

```lua
Config.DiffuseImageUrl = 'https://example.com/plate-diffuse.png'
Config.NormalMapUrl = 'https://example.com/plate-normal.png' -- optional
```

The URLs must be reachable by players' FiveM clients. The configuration recommends images around `1200×700` with a matching aspect ratio for diffuse and normal textures.

### Runtime texture size

```lua
Config.DuiWidth = 540
Config.DuiHeight = 300
```

Higher values can improve detail but consume more VRAM. Start with the defaults and increase them only when the source image and target display justify it.

### Target textures

```lua
Config.PlateTextures = {
    { dictionary = 'vehshare', texture = 'plate01' },
    { dictionary = 'vehshare', texture = 'plate02' },
}

Config.PlateNormalTextures = {
    { dictionary = 'vehshare', texture = 'plate01_n' },
    { dictionary = 'vehshare', texture = 'plate02_n' },
}
```

The default configuration covers `plate01` through `plate05` and their `_n` normal-map variants.

### Debug output

```lua
Config.Debug = true
```

Debug mode adds detailed client-console messages for DUI creation and individual texture replacements.

## Exports

Call the exports with the name of the folder installed on your server:

```lua
local ready = exports['custom-plate']:IsInitialized()
local state = exports['custom-plate']:GetPlateState()

print('Initialized:', ready)
print('Replacements applied:', state.replacementsApplied)
print('Diffuse URL:', state.diffuseUrl)
print('Normal URL:', state.normalUrl)
```

`GetPlateState()` returns `initialized`, `replacementsApplied`, `diffuseUrl`, and `normalUrl`.

## Troubleshooting

If the plate texture does not appear:

1. Confirm that `Config.DiffuseImageUrl` is non-empty and publicly reachable.
2. Enable `Config.Debug` and inspect the FiveM client console.
3. Verify that the configured texture dictionary and names match the vehicle assets.
4. Reduce the DUI dimensions and image file size if clients struggle to load the image.
5. Ensure a selected framework starts before this resource, or use `standalone`.

## Project structure

```text
__resource.lua        FiveM resource manifest
config.lua            framework, image, resolution, and texture settings
script/framework.lua  framework detection helpers
script/plate.lua      DUI lifecycle and texture replacement
```

## License

This repository does not currently include a license file. Contact the repository owner before reusing or redistributing the code.
