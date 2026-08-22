if GetResourceState('qb-core') ~= 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source)
    local xPlayer = QBCore.Functions.GetPlayer(source).PlayerData
    return xPlayer.citizenid 
end

function CheckPermission(source, permission)
    if permission.type == "ace" then
        return IsPlayerAceAllowed(source, permission.name)
    elseif permission.type == "job" then
        local xPlayer = QBCore.Functions.GetPlayer(source).PlayerData
        local name = xPlayer.job.name
        local rank = xPlayer.job.grade.level
        return (permission.name == name and permission.rank <= rank)
    elseif permission.type == "group" then
        return QBCore.Functions.HasPermission(source, permission.name)
    end
end