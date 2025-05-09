ESX = nil
Citizen.CreateThread(function ()
    while ESX == nil do
       ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(500)
    end

    while not ESX.IsPlayerLoaded() do
        Citizen.Wait(500)
    end

    PlayerData = GetPlayerServerId(xPlayer)
end)

local clientPeds = {}
local isPedDeleted = true

function createBlip(blipData, coords)
    if not blipData.enabled then
        return 
    end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipData.sprite)
    SetBlipScale(blip, blipData.scale)
    SetBlipColour(blip, blipData.colour)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.name)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)
    return blip
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    TriggerServerEvent("gemeentepasjes:RequestCoords")
end)


RegisterNetEvent("gemeentepasjes:sendPedCoords")
AddEventHandler("gemeentepasjes:sendPedCoords", function(coords)
    clientPeds = coords
	
	for pedType, coordsList in pairs(clientPeds) do
        for _, coordData in ipairs(coordsList) do
            local pedData = Config.Peds[pedType] or {} 
            local blipData = pedData.blip
            local blip = createBlip(blipData, vec3(coordData.x, coordData.y, coordData.z))
            if isPedDeleted then
                handlePedData({
                    type = pedType,
                    ped = pedData.ped,
                   -- scenario = pedData.ped and pedData.ped.scenario or "WORLD_HUMAN_HANG_OUT_STREET_CLUBHOUSE", -- Default scenario
                    coords = coordData
                })
            end
        end
    end
end)

function handlePedData(data)
    local modelhash = GetHashKey(data.ped.model)
    RequestModel(modelhash)

    while not HasModelLoaded(modelhash) do
        Citizen.Wait(50)
    end

    local ped = CreatePed(26, modelhash, data.coords.x, data.coords.y, data.coords.z, data.coords.h, false, true)
    SetModelAsNoLongerNeeded(modelhash)
    TaskStartScenarioInPlace(ped, data.scenario, 0, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    local options = targetOptions(data)
    exports.ox_target:addEntity(ped, options)
    exports.ox_target:addLocalEntity(ped, options)
end

function targetOptions(data)
    local options = {
        {
            name = "ped-" .. data.type,
            icon = "fa-solid fa-address-card",
            label = _U('request-identification_interaction'),
            distance = 3,
            onSelect = function()
                IdkaartAanvraag(data.type)
            end
        },
        {
            name = "ped-" .. data.type,
            icon = "fa-solid fa-address-card",
            label = _U('request-driverslicense_interaction'),
            distance = 3,
            onSelect = function()
                RijbewijsAanvraag(data.type)
            end
        },
--[[         {
            name = "ped-" .. data.type,
            icon = "fa-solid fa-address-card",
            label = "Auto Koopcontract aanvragen",
            distance = 3,
            onSelect = function()
                contractAanvraag(data.type)
            end
        } ]]
    }
    return options
end

function RijbewijsAanvraag()
    local geld = exports.ox_inventory:GetItemCount("money", metadata, strict)
    local serverId = GetPlayerServerId(source)
    local target = GetPlayerServerId(source)
    if geld >= 500 then
        ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
            if hasDriversLicense then
                TriggerEvent("gemeentepasjes:playerid")
                exports.ox_lib:progressCircle({
                    position = 'bottom',
                    duration = 5000,
                    label = _U('request-driverslicense_progress'),
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                    },
                })
                TriggerServerEvent("gemeentepasjes:RijbewijsAanvraagkopen")
            else
                exports.ox_lib:notify({
                    title = _U('notify-title'),
                    description = _U('no-driverslicense'),
                    type = 'info'
                })
            end
        end, GetPlayerServerId(PlayerId()), 'drive')
    else
        exports.ox_lib:notify({
            title = _U('notify-title'),
            description = _U('no-money'),
            type = 'error'
        })
    end
end

function IdkaartAanvraag()
    local geld = exports.ox_inventory:GetItemCount("money", metadata, strict)
    local serverId = GetPlayerServerId(source)
    local target = GetPlayerServerId(source)
    if geld >= 500 then
        exports.ox_lib:progressCircle({
            duration = 5000,
            position = 'bottom',
            label = _U('request-identification_progress'),
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
        })
        TriggerServerEvent("gemeentepasjes:IdkaartAanvraagkopen")
    else
        exports.ox_lib:notify({
            title = _U('notify-title'),
            description = _U('no-money'),
            type = 'error'
        })
    end
end

function contractAanvraag()
    local geld = exports.ox_inventory:GetItemCount("money", metadata, strict)
    local serverId = GetPlayerServerId(source)
    local target = GetPlayerServerId(source)
    if geld >= 750 then
        exports.ox_lib:progressCircle({
            duration = 5000,
            position = 'bottom',
            label = 'Auto Koopcontract aanvragen..',
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
            },
        })
        TriggerServerEvent("gemeentepasjes:ContractAanvraagkopen")
    else
        exports.ox_lib:notify({
            title = _U('notify-title'),
            description = _U('no-money'),
            type = 'error'
        })
    end
end

TriggerEvent('chat:addSuggestion', '/geefbewijs', 'Geef spelers rijbewijzen, vaarbewijzen & vliegbrevetten', {
    { name="spelerid", help="De speler zijn id" },
    { name="type", help="Type bewijs: dmv, drive, drive_bike, drive_truck, boat, weapon, vliegbrevet" }
})
