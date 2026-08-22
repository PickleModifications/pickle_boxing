Matches = {}
MatchThreads = {}
PlayerInfo = {}

function RegisterMatch(data)
    local index
    repeat
        index = math.random(1,9999) .. "_" .. math.random(1,9999)
    until not Matches[index]
    Matches[index] = {
        blip = data.blip,
        settings = data.defaultSettings,
        permissions = data.permissions,
        joinPermissions = data.joinPermissions,
        interact = data.interact,
        center = data.center,
        fighterPositions = data.fighterPositions,
        fighters = {}
    }
    return Matches[index]
end

function StartMatch(matchId)
    local match = Matches[matchId]
    if match.game then return end
    Matches[matchId].game = {
        currentStage = "intro_ring",
    }
    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "startStage", values = {  } })
    CreateThread(function() 
        Wait(8000)
        for i=1, #Matches[matchId].fighters do 
            Matches[matchId].game = {
                currentStage = "intro_fighter",
            }
            TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "startStage", values = { i } })
            Wait(8000)
        end
        for i=1, match.settings.rounds do 
            local stageId = math.random(1,9999) .. "_" .. math.random(1,9999)
            Matches[matchId].game = {
                currentStage = "in_round",
                stageId = stageId,
                round = i,
                roundTime = (60 * match.settings.roundLength) -- Delay 2 seconds for smooth round starts
            }        
            TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "startStage", values = { i } })
            Wait(4000)
            while Matches[matchId].game and stageId == (Matches[matchId].game.stageId or 0) do 
                if not (Matches[matchId].game.paused) then
                    Matches[matchId].game.roundTime = Matches[matchId].game.roundTime - 1
                end
                Wait(1000)
                if not Matches[matchId].game or (not Matches[matchId].game.paused and Matches[matchId].game.roundTime <= 1) then
                    break
                end
            end
            if not Matches[matchId].game then break end
        end
        if Matches[matchId].game then
            EndMatch(matchId)
        end
    end)
end

function EndMatch(matchId, forceEnd)
    local fighters = Matches[matchId].fighters
    local draw = false
    if forceEnd then
        Matches[matchId].game = nil
        Matches[matchId].fighters = {}
        TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "endMatch", values = { fighters,  true } })
    else
        if fighters[2].knockedOut or fighters[1].hits >= fighters[2].hits then
            fighters[1].winner = true
        end
        if fighters[1].knockedOut or fighters[2].hits >= fighters[1].hits then
            fighters[2].winner = true
        end
        if fighters[1].winner and fighters[2].winner then
            if fighters[1].knockedOut and fighters[2].knockedOut then
                draw = true
            elseif fighters[1].knockedOut and not fighters[2].knockedOut then
                fighters[1].winner = false
            elseif fighters[2].knockedOut and not fighters[1].knockedOut then
                fighters[2].winner = false
            end
        end
        if draw then
            PlayerInfo[fighters[1].source].record.ties = PlayerInfo[fighters[1].source].record.ties + 1
            PlayerInfo[fighters[2].source].record.ties = PlayerInfo[fighters[2].source].record.ties + 1
        elseif fighters[1].winner then
            PlayerInfo[fighters[1].source].record.wins = PlayerInfo[fighters[1].source].record.wins + 1
            PlayerInfo[fighters[2].source].record.losses = PlayerInfo[fighters[2].source].record.losses + 1
        else 
            PlayerInfo[fighters[2].source].record.wins = PlayerInfo[fighters[2].source].record.wins + 1
            PlayerInfo[fighters[1].source].record.losses = PlayerInfo[fighters[1].source].record.losses + 1
        end
        UpdatePlayerFighterInfo(fighters[1].source)
        UpdatePlayerFighterInfo(fighters[2].source)
        Matches[matchId].game = nil
        Matches[matchId].fighters = {}
        TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "endMatch", values = { fighters } })
    end
end

function PauseRound(matchId) 
    Matches[matchId].game.paused = true
    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "pauseRound", values = { Matches[matchId].game.roundTime } })
end

function ResumeRound(matchId) 
    Matches[matchId].game.paused = false
    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "resumeRound", values = { Matches[matchId].game.roundTime } })
end

function GetPlayerMatch(source)
    for k,v in pairs(Matches) do 
        for a,b in pairs(v.fighters) do 
            if b.source == source then 
                return k, v, a, b
            end
        end
    end
end

function GetPlayerFighterInfo(source)
    local data
    if PlayerInfo[source] then
        data = PlayerInfo[source]
    else
        local identifier = GetIdentifier(source)
        local results = MySQL.Sync.fetchAll("SELECT * FROM pickle_boxing WHERE identifier=@identifier;", { ["@identifier"] = identifier})
        data = results[1] or {}
        local info = (data and json.decode(data.info) or {})
        PlayerInfo[source] = {
            source = source,
            name = info.name or GetPlayerName(source),
            image = info.image or nil,
            record = { wins = data.wins or 0, losses = data.losses or 0, ties = data.ties or 0 },
            age = info.age or Config.DefaultFighterInfo.age,
            weight = info.weight or Config.DefaultFighterInfo.weight,
            height = info.height or Config.DefaultFighterInfo.height,
            emoteIntro = info.emoteIntro or Config.DefaultFighterInfo.emoteIntro,
            emoteWin = info.emoteWin or Config.DefaultFighterInfo.emoteWin,
            emoteLoss = info.emoteLoss or Config.DefaultFighterInfo.emoteLoss,
        }
        if not results[1] then
            MySQL.Async.execute("INSERT INTO pickle_boxing (identifier, info, wins, losses, ties) VALUES (?, ?, ?, ?, ?);", {
                identifier,
                json.encode({
                    name = PlayerInfo[source].name,
                    image = PlayerInfo[source].image,
                    age = PlayerInfo[source].age,
                    weight = PlayerInfo[source].weight,
                    height = PlayerInfo[source].height,
                    emoteIntro = PlayerInfo[source].emoteIntro,
                    emoteWin = PlayerInfo[source].emoteWin,
                    emoteLoss = PlayerInfo[source].emoteLoss
                }),
                PlayerInfo[source].record.wins,
                PlayerInfo[source].record.losses,
                PlayerInfo[source].record.ties
            })
        end
    end

    return PlayerInfo[source]
end 

function UpdatePlayerFighterInfo(source, info)
    local info = info or {}
    local identifier = GetIdentifier(source)
    if not PlayerInfo[source] then
        GetPlayerFighterInfo(source)
    end
    PlayerInfo[source].name = info.name or PlayerInfo[source].name
    PlayerInfo[source].image = info.image or PlayerInfo[source].image
    PlayerInfo[source].age = info.age or PlayerInfo[source].age
    PlayerInfo[source].weight = info.weight or PlayerInfo[source].weight
    PlayerInfo[source].height = info.height or PlayerInfo[source].height
    PlayerInfo[source].emoteIntro = info.emoteIntro or PlayerInfo[source].emoteIntro
    PlayerInfo[source].emoteWin = info.emoteWin or PlayerInfo[source].emoteWin
    PlayerInfo[source].emoteLoss = info.emoteLoss or PlayerInfo[source].emoteLoss

    MySQL.Async.execute("UPDATE pickle_boxing SET info = ?, wins = ?, losses = ?, ties = ? WHERE identifier = ?;", {
        json.encode({
            name = PlayerInfo[source].name,
            image = PlayerInfo[source].image,
            age = PlayerInfo[source].age,
            weight = PlayerInfo[source].weight,
            height = PlayerInfo[source].height,
            emoteIntro = PlayerInfo[source].emoteIntro,
            emoteWin = PlayerInfo[source].emoteWin,
            emoteLoss = PlayerInfo[source].emoteLoss
        }),
        PlayerInfo[source].record.wins,
        PlayerInfo[source].record.losses,
        PlayerInfo[source].record.ties,
        identifier
    })
end

function PlayerLeaveMatch(source)
    local currentMatchId, currentMatch = GetPlayerMatch(source)
    if not currentMatchId then return true end
    for i=1, #Matches[currentMatchId].fighters do 
        if Matches[currentMatchId].fighters[i].source == source then
            table.remove(Matches[currentMatchId].fighters, i)
            break
        end
    end
    if currentMatch.game then
        EndMatch(currentMatchId, true)
    else
        TriggerClientEvent("pickle_boxing:updateMatch", -1, currentMatchId, Matches[currentMatchId], { action = "leaveMatch", values = { source } })
    end
    return true
end

function PlayerJoinMatch(source, matchId)
    local targetMatch = Matches[matchId]
    if not targetMatch then return false, _L("match_not_exist") end
    if targetMatch.game then return false, _L("match_active") end
    if #targetMatch.fighterPositions < #targetMatch.fighters + 1 then return false, _L("match_full") end
    local currentMatchId, currentMatch = GetPlayerMatch(source)
    if currentMatchId then
        if not (currentMatchId ~= matchId and PlayerLeaveMatch(source)) then
            return false, _L("failed_join_match")
        end
    end
    local info = GetPlayerFighterInfo(source)
    table.insert(Matches[matchId].fighters, #Matches[matchId].fighters + 1, {
        source = source,
        name = info.name,
        record = info.record,
        image = info.image,
        age = info.age,
        weight = info.weight,
        height = info.height,
        emoteIntro = info.emoteIntro,
        emoteWin = info.emoteWin,
        emoteLoss = info.emoteLoss,
        health = 100,
        hits = 0, 
        contacts = 0,
        ready = false
    })
    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "joinMatch", values = { source } })
    if not MatchThreads[matchId] then
        MatchThreads[matchId] = true
        CreateThread(function()
            while MatchThreads[matchId] and #Matches[matchId].fighters > 0 do
                local match = Matches[matchId]
                for i=1, #match.fighters do
                    if match.fighters[i] then
                        local source = match.fighters[i].source
                        local ped = GetPlayerPed(source)
                        if not DoesEntityExist(ped) or #(GetEntityCoords(ped) - match.center.coords) > match.center.radius then
                            PlayerLeaveMatch(source)
                        end
                    end
                end
                Wait(2000)
            end
            MatchThreads[matchId] = nil
        end)
    end
    return true
end

function CanManageMatch(source, matchId)
    local match = Matches[matchId]
    if not matchId then return end
    local allowed = false 
    if not match.permissions then return true end
    for i=1, #match.permissions do 
        if CheckPermission(source, match.permissions[i]) then
            allowed = true
            break
        end
    end
    return allowed
end

function CanJoinMatch(source, matchId)
    local match = Matches[matchId]
    if not matchId then return end
    local allowed = false 
    if not match.joinPermissions then return true end
    for i=1, #match.joinPermissions do 
        if CheckPermission(source, match.joinPermissions[i]) then
            allowed = true
            break
        end
    end
    return allowed
end

lib.callback.register("pickle_boxing:attemptJoinMatch", function(source, matchId, info)
    UpdatePlayerFighterInfo(source, info)
    return PlayerJoinMatch(source, matchId)
end)

lib.callback.register("pickle_boxing:getFighterSettings", function(source)
    return GetPlayerFighterInfo(source)
end)

lib.callback.register("pickle_boxing:getTopFighters", function(source)
    local results = MySQL.Sync.fetchAll("SELECT * FROM pickle_boxing ORDER BY wins DESC LIMIT 10;")
    local data = {}
    for i=1, #results do 
        local info = json.decode(results[i].info)
        data[#data + 1] = {
            name = info.name,
            image = info.image,
            record = { wins = results[i].wins or 0, losses = results[i].losses or 0, ties = results[i].ties or 0 },
            age = info.age or Config.DefaultFighterInfo.age,
            weight = info.weight or Config.DefaultFighterInfo.weight,
            height = info.height or Config.DefaultFighterInfo.height,
        }
    end
    return data
end)

lib.callback.register("pickle_boxing:canManageMatch", function(source, matchId)
    return CanManageMatch(source, matchId)
end)

lib.callback.register("pickle_boxing:canJoinMatch", function(source, matchId) 
    return CanJoinMatch(source, matchId)
end)

lib.callback.register("pickle_boxing:requestMatchData", function(source, matchId)
    return Matches[matchId]
end)

RegisterNetEvent("pickle_boxing:toggleReadyFight", function() 
    local currentMatchId, currentMatch, playerIndex, player = GetPlayerMatch(source)
    if not currentMatchId then return end
    if player.ready then
        PlayerLeaveMatch(source)
    else
        Matches[currentMatchId].fighters[playerIndex].ready = true
        if (#Matches[currentMatchId].fighterPositions == #Matches[currentMatchId].fighters) then
            local notReady = false
            for i=1, #Matches[currentMatchId].fighters do 
                if (not Matches[currentMatchId].fighters[i].ready) then
                    notReady = true
                    break
                end
            end
            if not notReady then 
                StartMatch(currentMatchId)
            end
        end
        TriggerClientEvent("pickle_boxing:updateMatch", -1, currentMatchId, Matches[currentMatchId], { action = "toggleReady", values = { source, true } })
    end
end)

RegisterNetEvent("pickle_boxing:updateMatchSettings", function(matchId, settings)
    if not CanManageMatch(source, matchId) then return ShowNotification(source, _L("no_match_management")) end
    Matches[matchId].settings.rounds = (settings.rounds > 0 and settings.rounds or Matches[matchId].settings.rounds)
    Matches[matchId].settings.roundLength = (settings.roundLength > 0 and settings.roundLength or Matches[matchId].settings.roundLength)
    Matches[matchId].settings.fightType = ((settings.fightType == "boxing" or settings.fightType == "mma") and settings.fightType or Matches[matchId].settings.fightType)
    Matches[matchId].settings.event = (settings.event or Matches[matchId].settings.event)

    TriggerClientEvent("pickle_boxing:updateMatch", -1, matchId, Matches[matchId], { action = "updateSettings", values = {  } })
end)

RegisterNetEvent("pickle_boxing:initializePlayer", function()
    local source = source
    TriggerClientEvent("pickle_boxing:syncMatches", source, Matches)
end)

CreateThread(function()
    for i=1, #Config.Locations do 
        RegisterMatch(Config.Locations[i])
    end
end)