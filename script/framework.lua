-- ============================================================================
-- FRAMEWORK DETECTION & INITIALIZATION
-- ============================================================================

local Framework = {}

-- Detect which framework is running
local function DetectFramework()
	-- Check for ESX
	if GetResourceState('es_extended') == 'started' then
		return 'esx'
	end

	-- Check for QBCore
	if GetResourceState('qb-core') == 'started' then
		return 'qbcore'
	end

	-- Check for Ox_Core
	if GetResourceState('ox_core') == 'started' then
		return 'ox'
	end

	return nil
end

-- Initialize framework based on config
function Framework.Init(configFramework)
	local detectedFramework = configFramework

	if configFramework == 'auto' then
		detectedFramework = DetectFramework()
		if not detectedFramework then
			print("^3[CustomPlate] Warning: No framework detected. Running in standalone mode.^7")
			return 'standalone'
		end
	end

	if detectedFramework == 'esx' then
		Framework.ESX = exports['es_extended']:getSharedObject()
		print("^2[CustomPlate] ESX framework initialized.^7")
		return 'esx'
	elseif detectedFramework == 'qbcore' then
		Framework.QBCore = exports['qb-core']:GetCoreObject()
		print("^2[CustomPlate] QBCore framework initialized.^7")
		return 'qbcore'
	elseif detectedFramework == 'ox' then
		Framework.Ox = exports.ox_core
		print("^2[CustomPlate] Ox_Core framework initialized.^7")
		return 'ox'
	else
		print("^3[CustomPlate] Warning: Unknown framework specified. Running in standalone mode.^7")
		return 'standalone'
	end
end

-- Get player identifier based on framework
function Framework.GetPlayerIdentifier(playerId)
	if Framework.ESX then
		local xPlayer = Framework.ESX.GetPlayerFromId(playerId)
		return xPlayer and xPlayer.identifier or nil
	elseif Framework.QBCore then
		local Player = Framework.QBCore.Functions.GetPlayer(playerId)
		return Player and Player.PlayerData.citizenid or nil
	elseif Framework.Ox then
		return GetPlayerIdentifier(playerId, 0)
	else
		return GetPlayerIdentifier(playerId, 0)
	end
end

-- Check if player has permission (for future use)
function Framework.HasPermission(playerId, permission)
	-- Placeholder for permission checks
	-- Can be extended based on framework
	return true
end

return Framework
