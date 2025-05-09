---@diagnostic disable: redefined-local
local ESX = exports["es_extended"]:getSharedObject()
local pedCoords = {}

function getCoordsForPedType(pedData)
    return pedData.coords
end

function updatePedCoords()
    pedCoords = {}

    for pedType, pedData in pairs(Config.Peds) do
        local coords = getCoordsForPedType(pedData)
        pedCoords[pedType] = coords
    end
end

RegisterServerEvent("gemeentepasjes:RequestCoords")
AddEventHandler("gemeentepasjes:RequestCoords",function()
	TriggerClientEvent("gemeentepasjes:sendPedCoords", source, pedCoords) 
end)


Citizen.CreateThread(function()
    updatePedCoords()
end)

RegisterServerEvent("gemeentepasjes:RijbewijsAanvraagkopen")
AddEventHandler("gemeentepasjes:RijbewijsAanvraagkopen",function(_source)
    local ox_inventory = exports.ox_inventory
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    local naam = xPlayer.getName()
    MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {['@identifier'] = identifier},
            function(user)
                for i = 1, #user do
                    local row = user[i]
                    if row.sex == 'm' then
                        sex = _U('gender-male')
                    else
                        sex = _U('gender-female')
                    end
                    
                    local metadata = {
                        type = naam,
                        description = _U('dateofbirth')..': '..row.dateofbirth..'  \n '.._U('gender')..': '..sex..'  \n '.._U('height')..': '..row.height..' cm'
					}
					ox_inventory:RemoveItem(_source, 'money', 500)
                    ox_inventory:AddItem(_source, Config.item2, 1, metadata)
                end
    end)
end)

RegisterServerEvent("gemeentepasjes:IdkaartAanvraagkopen")
AddEventHandler("gemeentepasjes:IdkaartAanvraagkopen",function(_source)
    local ox_inventory = exports.ox_inventory
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    local naam = xPlayer.getName()
    MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = @identifier', {['@identifier'] = identifier},
            function(user)
                for i = 1, #user do
                    local row = user[i]
                    if row.sex == 'm' then
                        sex = _U('gender-male')
                    else
                        sex = _U('gender-female')
                    end
                    
                    local metadata = {
                        type = naam,
                        description = _U('dateofbirth')..': '..row.dateofbirth..'  \n '.._U('gender')..': '..sex..'  \n '.._U('height')..': '..row.height..' cm' 
                    }
                    ox_inventory:RemoveItem(_source, 'money', 500)
                    ox_inventory:AddItem(_source, Config.item1, 1, metadata)
                end
    end)
end)

RegisterServerEvent("gemeentepasjes:ContractAanvraagkopen")
AddEventHandler("gemeentepasjes:ContractAanvraagkopen",function(_source)
    local ox_inventory = exports.ox_inventory
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.identifier
    local naam = xPlayer.getName()
    ox_inventory:RemoveItem(_source, 'money', 750)
    ox_inventory:AddItem(_source, "contract", 1)
end)

RegisterServerEvent("gemeentepasjes:requestLicences")
AddEventHandler("gemeentepasjes:requestLicences",function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = xPlayer.getIdentifier()
    MySQL.Async.fetchAll('SELECT user_licenses.type, licenses.label FROM user_licenses LEFT JOIN licenses ON user_licenses.type = licenses.type WHERE owner = ?', {
		['@owner'] = identifier,
	}, function(result)
		if result[1] then
			cb(result[1].owner == identifier)
            print(result)
		else
			cb(false)
		end
    end)    
end)

ESX = nil
ESX = exports["es_extended"]:getSharedObject()

RegisterCommand('geefbewijs', function(source, args, showError)
	local playerId = source
    local targetPlayer = (args[1] and tonumber(args[1]) or false)
    local licenseType = args[2]
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local Admin = xPlayer.getGroup() == 'admin'
	if not Admin then
		TriggerClientEvent("esx:showNotification", source, "Geen permissies")
		return
	end
	if not targetPlayer or not licenseType then
		TriggerClientEvent("esx:showNotification", source, "Ongeldige ID of Type")
		return
	end
	local tPlayer = ESX.GetPlayerFromId(targetPlayer)
	if not tPlayer then
		TriggerClientEvent("esx:showNotification", source, "Speler niet online")
		return
	end
	TriggerEvent('esx_license:getLicensesList', function(licenses)
		local license;
		for i=1, #licenses, 1 do
			if licenses[i].type == licenseType then
				license = licenses[i]
				break
			end
		end

		if not license then
			TriggerClientEvent("esx:showNotification", source, "Geen geldige Type")
			return
		end
		
		TriggerEvent('esx_license:checkLicense', tPlayer.source, licenseType, function(isExist)
			if isExist then
				TriggerClientEvent("esx:showNotification", source, "Speler is al in bezit van: "..license.label)
				return
			end
			TriggerEvent('esx_license:addLicense', tPlayer.source, licenseType)
			TriggerClientEvent("esx:showNotification", source, "Je gaf een "..license.label.." aan "..tPlayer.name)
			TriggerClientEvent("esx:showNotification", tPlayer.source, "Je hebt nu een "..license.label.." gekregen")
		end)
	end)
end)
-- WIP | Roy
--[[ RegisterCommand('verwijderbewijs', function(source, args, showError)
	local playerId = source
    local targetPlayer = (args[1] and tonumber(args[1]) or false)
    local licenseType = args[2]
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local Admin = xPlayer.getGroup() == 'admin'
	if not Admin then
		TriggerClientEvent("esx:showNotification", source, "Geen permissies")
		return
	end
	if not targetPlayer or not licenseType then
		TriggerClientEvent("esx:showNotification", source, "Ongeldige ID of Type")
		return
	end
	local tPlayer = ESX.GetPlayerFromId(targetPlayer)
	if not tPlayer then
		TriggerClientEvent("esx:showNotification", source, "Speler niet online")
		return
	end
	TriggerEvent('esx_license:getLicensesList', function(licenses)
		local license;
		for i=1, #licenses, 1 do
			if licenses[i].type == licenseType then
				license = licenses[i]
				break
			end
		end

		if not license then
			TriggerClientEvent("esx:showNotification", source, "Geen geldige Type")
			return
		end
		
		TriggerEvent('esx_license:checkLicense', tPlayer.source, licenseType, function(heeftType)
			if not heeftType then
				TriggerClientEvent("esx:showNotification", source, "Speler heeft geen: "..license.label)
				return
			end
			TriggerEvent('esx_license:removeLicense', tPlayer.source, licenseType)
			TriggerClientEvent("esx:showNotification", source, "Je nam: "..license.label..". In van: "..tPlayer.name)
			TriggerClientEvent("esx:showNotification", tPlayer.source, "Je "..license.label.." is ingevorderd")
		end)
	end)
end) ]]