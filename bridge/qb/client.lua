if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

function ShowNotification(text)
	QBCore.Functions.Notify(text)
end

RegisterNetEvent(GetCurrentResourceName()..":showNotification", function(text)
    ShowNotification(text)
end)

local firstTime = true

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if not firstTime then return end
    firstTime = false
    TriggerServerEvent("pickle_boxing:initializePlayer")
end)