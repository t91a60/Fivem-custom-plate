# FiveM Custom License Plate Resource

A production-ready, optimized FiveM resource for custom license plates using CreateDui runtime texture replacement. Supports ESX, QBCore, and Ox_Core frameworks with automatic detection.

## Features

- **Framework Support**: Automatic detection of ESX, QBCore, or Ox_Core frameworks
- **Async DUI Creation**: Non-blocking texture loading prevents client freezing
- **Diffuse & Normal Maps**: Support for both main texture and normal map (bump mapping)
- **Configurable Resolution**: Easily adjust DUI resolution for quality/performance balance
- **Optimized**: Runs initialization once on resource start, no generic loops
- **Error Handling**: Comprehensive error checking and logging
- **Exports**: Query plate state from other resources

## Installation

1. Clone or download this resource into your `resources` folder
2. Add to your `server.cfg`:
   ```
   ensure custom-plate
   ```

## Configuration

Edit `config.lua` to customize:

### Framework Selection
```lua
Config.Framework = 'auto'  -- 'auto', 'esx', 'qbcore', 'ox', or 'standalone'
```

### Texture URLs
```lua
Config.DiffuseImageUrl = "https://example.com/plate-diffuse.png"  -- Main plate texture
Config.NormalMapUrl = "https://example.com/plate-normal.png"      -- Bump map (optional)
```

### DUI Resolution
```lua
Config.DuiWidth = 540   -- Width in pixels
Config.DuiHeight = 300  -- Height in pixels
```

### Plate Targets
Customize which textures are replaced:
```lua
Config.PlateTextures = {
	{ dictionary = "vehshare", texture = "plate01" },
	{ dictionary = "vehshare", texture = "plate02" },
	-- Add more as needed
}

Config.PlateNormalTextures = {
	{ dictionary = "vehshare", texture = "plate01_n" },
	{ dictionary = "vehshare", texture = "plate02_n" },
	-- Add more as needed
}
```

### Debug Logging
```lua
Config.Debug = false  -- Set to true for detailed console output
```

## Image Requirements

- **Recommended Resolution**: 1200x700 pixels (or similar aspect ratio)
- **Format**: PNG or JPG
- **Hosting**: Must be accessible via HTTP/HTTPS URL

## Usage

### Basic Setup

1. Prepare your custom plate images (diffuse and optionally normal map)
2. Host them on a web server or CDN
3. Update `config.lua` with the URLs
4. Restart the resource

### Querying Plate State

From another resource:
```lua
local isInitialized = exports['custom-plate']:IsInitialized()
local state = exports['custom-plate']:GetPlateState()

print("Initialized:", state.initialized)
print("Diffuse URL:", state.diffuseUrl)
print("Normal URL:", state.normalUrl)
```

## How It Works

1. **Resource Start**: Initializes framework detection and creates runtime texture dictionary
2. **DUI Creation**: Asynchronously loads diffuse and normal map images
3. **Texture Replacement**: Applies loaded textures to all configured plate models
4. **Resource Stop**: Cleans up DUI objects and textures

## Performance Considerations

- **One-time Initialization**: Texture replacement runs once on resource start
- **Async Loading**: DUI creation doesn't block the main client thread
- **VRAM Usage**: Higher resolutions use more VRAM; 540x300 is recommended
- **Network**: Image loading depends on CDN/server response time

## Troubleshooting

### Plates not showing custom texture
- Check `config.lua` for valid image URLs
- Verify images are accessible (test URLs in browser)
- Enable `Config.Debug = true` for detailed logging
- Check console for error messages

### Client freezing during load
- Reduce `Config.DuiWidth` and `Config.DuiHeight`
- Ensure images are optimized and not too large
- Check network connectivity

### Framework not detected
- Ensure the framework resource is started before this resource
- Set `Config.Framework` explicitly if auto-detection fails

## License

Created by Boryss#6534

## Support

For issues or questions, refer to the debug logging output or check the console for error messages.
