if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports.es_extended:getSharedObject()

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    return xPlayer.identifier
end

function CheckPermission(source, permission)
    if permission.type == "ace" then
        return IsPlayerAceAllowed(source, permission.name)
    elseif permission.type == "job" then
        local xPlayer = ESX.GetPlayerFromId(source)
        local name = xPlayer.job.name
        local rank = xPlayer.job.grade
        return (permission.name == name and permission.rank <= rank)
    elseif permission.type == "group" then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer.getGroup() == permission.name
    end
end