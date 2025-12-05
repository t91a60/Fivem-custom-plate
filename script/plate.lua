-- ============================================================================
-- CUSTOM LICENSE PLATE RESOURCE - MAIN SCRIPT
-- ============================================================================
-- Optimized FiveM resource for custom license plates using CreateDui
-- Supports: ESX, QBCore, Ox_Core/Ox_Lib
-- ============================================================================

local Config = require 'config'
local Framework = require 'script.framework'

-- ============================================================================
-- STATE MANAGEMENT
-- ============================================================================

local PlateState = {
	initialized = false,
	textureDictionary = nil,
	duiObjects = {},
	replacementsApplied = false,
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function Log(message, level)
	level = level or 'info'
	local prefix = "^2[CustomPlate]^7"

	if level == 'error' then
		prefix = "^1[CustomPlate ERROR]^7"
	elseif level == 'warn' then
		prefix = "^3[CustomPlate WARN]^7"
	elseif level == 'debug' then
		if not Config.Debug then return end
		prefix = "^5[CustomPlate DEBUG]^7"
	end

	print(prefix .. " " .. message)
end

-- Validate URL is not empty
local function IsValidUrl(url)
	return url and url ~= "" and type(url) == "string"
end

-- ============================================================================
-- DUI CREATION (ASYNC)
-- ============================================================================

-- Create DUI asynchronously to prevent client freezing
local function CreateDuiAsync(imageUrl, width, height, textureName)
	return function()
		if not IsValidUrl(imageUrl) then
			Log("Invalid URL for texture '" .. textureName .. "': " .. tostring(imageUrl), 'warn')
			return nil
		end

		local success, duiObject = pcall(function()
			return CreateDui(imageUrl, width, height)
		end)

		if not success or not duiObject then
			Log("Failed to create DUI for '" .. textureName .. "'", 'error')
			return nil
		end

		Log("DUI created for '" .. textureName .. "'", 'debug')
		return duiObject
	end
end

-- ============================================================================
-- TEXTURE REPLACEMENT
-- ============================================================================

-- Apply texture replacements for diffuse (main) textures
local function ApplyDiffuseTextures()
	if not PlateState.duiObjects.diffuse then
		Log("Diffuse DUI object not available", 'warn')
		return false
	end

	local handle = GetDuiHandle(PlateState.duiObjects.diffuse)
	if not handle then
		Log("Failed to get DUI handle for diffuse texture", 'error')
		return false
	end

	for _, plateInfo in ipairs(Config.PlateTextures) do
		local success = pcall(function()
			CreateRuntimeTextureFromDuiHandle(
				PlateState.textureDictionary,
				"duiTex_diffuse",
				handle
			)
			AddReplaceTexture(
				plateInfo.dictionary,
				plateInfo.texture,
				PlateState.textureDictionary,
				"duiTex_diffuse"
			)
		end)

		if success then
			Log("Applied diffuse texture to " .. plateInfo.texture, 'debug')
		else
			Log("Failed to apply diffuse texture to " .. plateInfo.texture, 'error')
		end
	end

	return true
end

-- Apply texture replacements for normal maps
local function ApplyNormalTextures()
	if not PlateState.duiObjects.normal then
		Log("Normal map DUI object not available", 'warn')
		return false
	end

	local handle = GetDuiHandle(PlateState.duiObjects.normal)
	if not handle then
		Log("Failed to get DUI handle for normal map texture", 'error')
		return false
	end

	for _, plateInfo in ipairs(Config.PlateNormalTextures) do
		local success = pcall(function()
			CreateRuntimeTextureFromDuiHandle(
				PlateState.textureDictionary,
				"duiTex_normal",
				handle
			)
			AddReplaceTexture(
				plateInfo.dictionary,
				plateInfo.texture,
				PlateState.textureDictionary,
				"duiTex_normal"
			)
		end)

		if success then
			Log("Applied normal texture to " .. plateInfo.texture, 'debug')
		else
			Log("Failed to apply normal texture to " .. plateInfo.texture, 'error')
		end
	end

	return true
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

-- Main initialization function (runs once on resource start)
local function InitializeCustomPlates()
	if PlateState.initialized then
		Log("Custom plates already initialized", 'debug')
		return
	end

	-- Validate configuration
	if not IsValidUrl(Config.DiffuseImageUrl) then
		Log("Diffuse image URL is not configured. Please set Config.DiffuseImageUrl in config.lua", 'error')
		return
	end

	-- Initialize framework
	Framework.Init(Config.Framework)

	-- Create runtime texture dictionary (only once)
	local success = pcall(function()
		PlateState.textureDictionary = CreateRuntimeTxd('duiTxd')
	end)

	if not success or not PlateState.textureDictionary then
		Log("Failed to create runtime texture dictionary", 'error')
		return
	end

	Log("Runtime texture dictionary created", 'debug')

	-- Create diffuse DUI asynchronously
	local createDiffuseDui = CreateDuiAsync(
		Config.DiffuseImageUrl,
		Config.DuiWidth,
		Config.DuiHeight,
		"Diffuse"
	)

	PlateState.duiObjects.diffuse = createDiffuseDui()

	-- Create normal map DUI asynchronously (if configured)
	if IsValidUrl(Config.NormalMapUrl) then
		local createNormalDui = CreateDuiAsync(
			Config.NormalMapUrl,
			Config.DuiWidth,
			Config.DuiHeight,
			"Normal Map"
		)

		PlateState.duiObjects.normal = createNormalDui()
	else
		Log("Normal map URL not configured. Skipping normal map texture", 'debug')
	end

	-- Apply texture replacements
	local diffuseSuccess = ApplyDiffuseTextures()
	local normalSuccess = true

	if PlateState.duiObjects.normal then
		normalSuccess = ApplyNormalTextures()
	end

	if diffuseSuccess then
		PlateState.replacementsApplied = true
		PlateState.initialized = true
		Log("Custom license plates initialized successfully", 'info')
	else
		Log("Failed to apply texture replacements", 'error')
	end
end

-- ============================================================================
-- RESOURCE LIFECYCLE
-- ============================================================================

-- Initialize on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	InitializeCustomPlates()
end)

-- Cleanup on resource stop
AddEventHandler('onClientResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	if PlateState.duiObjects.diffuse then
		pcall(function() DestroyDui(PlateState.duiObjects.diffuse) end)
	end

	if PlateState.duiObjects.normal then
		pcall(function() DestroyDui(PlateState.duiObjects.normal) end)
	end

	PlateState.initialized = false
	PlateState.replacementsApplied = false

	Log("Resource cleaned up", 'debug')
end)

-- ============================================================================
-- EXPORTS (For external access)
-- ============================================================================

-- Check if custom plates are initialized
exports('IsInitialized', function()
	return PlateState.initialized
end)

-- Get current plate state
exports('GetPlateState', function()
	return {
		initialized = PlateState.initialized,
		replacementsApplied = PlateState.replacementsApplied,
		diffuseUrl = Config.DiffuseImageUrl,
		normalUrl = Config.NormalMapUrl,
	}
end)
