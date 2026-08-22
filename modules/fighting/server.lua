local DEFAULT_FIGHTER_DATA = { health = 100, hits = 0, contacts = 0 }

function GetRandomRange(tbl)
    return (tbl[1] < tbl[2] and math.random(tbl[1], tbl[2]) or tbl[1])
end

function AddFighterHealth(source, amount)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    SetFighterHealth(source, Matches[matchId].fighters[fighterId].health + amount)
end

function RemoveFighterHealth(source, amount)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    SetFighterHealth(source, Matches[matchId].fighters[fighterId].health - amount)
end

function SetFighterHealth(source, amount)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    local amount = amount
    if amount == nil or amount > 100 then
        amount = 100
    elseif amount < 0 then
        amount = 0
    end
    Matches[matchId].fighters[fighterId].health = amount
    TriggerClientEvent("pickle_boxing:updateHealth", source, Matches[matchId].fighters[fighterId].health)
end

function StartFighterKnockout(source)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    Matches[matchId].fighters[fighterId].knockedOut = true
    PauseRound(matchId)
    TriggerClientEvent("pickle_boxing:knockoutStart", source)
end

function IsFighterKnockedOut(source)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    return Matches[matchId].fighters[fighterId].knockedOut
end

RegisterNetEvent("pickle_boxing:playerPunched", function(attacker)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    local attackerMatchId, attackerMatch, attackerFighterId, attackerFighter = GetPlayerMatch(attacker)
    if not matchId or not attackerMatchId or matchId ~= attackerMatchId then return end
    if Matches[matchId].fighters[fighterId].knockedOut then return end
    RemoveFighterHealth(source, GetRandomRange(Config.Fights.AttackDamage))
    Matches[matchId].fighters[fighterId].contacts = Matches[matchId].fighters[fighterId].contacts + 1
    if Matches[matchId].fighters[fighterId].contacts % Config.Fights.KnockoutInterval == 0 or Matches[matchId].fighters[fighterId].health <= 0 then
        Matches[matchId].fighters[fighterId].knockedOut = (math.random(1, 100) <= (100 - Matches[matchId].fighters[fighterId].health))
    else 
        Matches[matchId].fighters[fighterId].knockedOut = false
    end
    if IsFighterKnockedOut(source) then 
        StartFighterKnockout(source)
    end
    Matches[matchId].fighters[attackerFighterId].hits = Matches[matchId].fighters[attackerFighterId].hits + 1
    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "playerPunched", values = { } })
end)

RegisterNetEvent("pickle_boxing:knockoutResult", function(recovered)
    local matchId, match, fighterId, fighter = GetPlayerMatch(source)
    if not matchId then return end
    if recovered then
        Matches[matchId].fighters[fighterId].knockedOut = false
        AddFighterHealth(source, GetRandomRange(Config.Fights.RecoverHealth))
        ResumeRound(matchId)
    else
        EndMatch(matchId)
    end
end)