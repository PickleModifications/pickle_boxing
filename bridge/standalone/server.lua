if GetResourceState('es_extended') == 'started' then return end
if GetResourceState('qb-core') == 'started' then return end

function ShowNotification(target, text)
	TriggerClientEvent(GetCurrentResourceName()..":showNotification", target, text)
end

function GetIdentifier(source) -- By default, use steam. Any other identifier is up to you.
    for k,v in pairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            return v
        end
    end
end

function CheckPermission(source, permission)
    if permission.type == "ace" then
        return IsPlayerAceAllowed(source, permission.name)
    end
end