-- ============================================================================
-- CUSTOM LICENSE PLATE RESOURCE - CONFIGURATION
-- ============================================================================

Config = {}

-- ============================================================================
-- FRAMEWORK CONFIGURATION
-- ============================================================================
-- Options: 'auto', 'esx', 'qbcore', 'ox'
-- 'auto' will attempt to detect the framework automatically
Config.Framework = 'auto'

-- ============================================================================
-- TEXTURE CONFIGURATION
-- ============================================================================
-- Diffuse Image (main plate texture)
-- Recommended resolution: 1200x700 or similar aspect ratio
Config.DiffuseImageUrl = ""  -- Paste your diffuse image URL here

-- Normal Map Image (bump/detail map for 3D effect)
-- Recommended resolution: 1200x700 (same as diffuse for consistency)
Config.NormalMapUrl = ""     -- Paste your normal map URL here

-- ============================================================================
-- DUI RESOLUTION
-- ============================================================================
-- Width and height of the DUI texture
-- Higher values = better quality but more VRAM usage
-- Recommended: 540x300 for balanced quality/performance
Config.DuiWidth = 540
Config.DuiHeight = 300

-- ============================================================================
-- PLATE TEXTURE TARGETS
-- ============================================================================
-- Define which textures to replace
-- Format: { dictionary = "vehshare", texture = "plate01" }
Config.PlateTextures = {
	-- Diffuse textures (main appearance)
	{ dictionary = "vehshare", texture = "plate01" },
	{ dictionary = "vehshare", texture = "plate02" },
	{ dictionary = "vehshare", texture = "plate03" },
	{ dictionary = "vehshare", texture = "plate04" },
	{ dictionary = "vehshare", texture = "plate05" },
}

Config.PlateNormalTextures = {
	-- Normal map textures (bump/detail)
	{ dictionary = "vehshare", texture = "plate01_n" },
	{ dictionary = "vehshare", texture = "plate02_n" },
	{ dictionary = "vehshare", texture = "plate03_n" },
	{ dictionary = "vehshare", texture = "plate04_n" },
	{ dictionary = "vehshare", texture = "plate05_n" },
}

-- ============================================================================
-- DEBUG & LOGGING
-- ============================================================================
Config.Debug = false  -- Set to true for detailed console logging

return Config
