if GetResourceState('es_extended') == 'started' then return end
if GetResourceState('qb-core') == 'started' then return end

function ShowNotification(text)
	BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(true, true)
end

RegisterNetEvent(GetCurrentResourceName()..":showNotification", function(text)
    ShowNotification(text)
end)

local firstTime = true

AddEventHandler('playerSpawned',function(xPlayer, isNew, skin)
    if not firstTime then return end
    firstTime = false
    TriggerServerEvent("pickle_boxing:initializePlayer")
end)