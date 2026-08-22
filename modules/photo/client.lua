local photoProp
local photoCam

function GetDirectionFromRotation(rot)
    local dm = (math.pi / 180)
    return vector3(-math.sin(dm * rot.z) * math.abs(math.cos(dm * rot.x)), math.cos(dm * rot.z) * math.abs(math.cos(dm * rot.x)), math.sin(dm * rot.x))
end

function CreatePhotoCam(pos, heading)
    local ped = PlayerPedId()
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, 0.0, 0.00, heading, 45.00, false, 0)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 1, true, true)
    return cam
end

function DeletePhotoCam(cam)
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 1, true, true)
    DestroyCam(cam) 
end

function StartPhoto(returnSettings, cb)
    local ped = PlayerPedId()
    local photoCoords = Config.Photos.coords
    local photoHeading = Config.Photos.heading
    local startBox = photoCoords + vector3(2.0, 1.0, 2.0)
    local endBox = photoCoords - vector3(2.0, 1.0, 2.0)
    local startBox2 = photoCoords + vector3(2.0, 2.0, 0.45)
    local endBox2 = photoCoords - vector3(2.0, 2.0, 0.45)
    DoScreenFadeOut(1000)
    Wait(1100)
    SetEntityCoords(ped, photoCoords.x, photoCoords.y, photoCoords.z - 0.55)
    SetEntityHeading(ped, 0)
    FreezeEntityPosition(ped, true)
    ClearPedTasksImmediately(ped)
    CreatePhotoCam(GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.75, 0.35), GetEntityHeading(ped) - 180.0)
    Wait(100)
    DoScreenFadeIn(1000)
    local photoURL
    CreateThread(function()
        repeat
            while true do 
                Wait(0)
                if (not ShowInteractText(_L("take_photo")) and IsControlJustPressed(1, 51)) then 
                    break
                end
            end
            local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0,  1.0, 1.65)
            local rot = GetEntityRotation(ped, 2)
            rot = vector3(rot.x, rot.y, rot.z - 180.0)
            local dir = GetDirectionFromRotation(rot)
            local url = nil
            SetTimeout(300, function()
                exports['screenshot-basic']:requestScreenshotUpload(Config.Photos.url, Config.Photos.uploadProtocol, function(data)
                    local resp = json.decode(data)
                    url = Config.Photos.ResponseHandler(resp)
                end)
            end)
            while not url do
                Wait(0)
                DrawSpotLight(pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, 255, 255, 255, 100.0, Config.Photos.brightness, 0.0, 1000.0, 1.0)
            end
            Wait(100)
            for i=1, 10 do
                Wait(0)
                DrawSpotLight(pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, 255, 255, 255, 100.0, Config.Photos.brightness, 0.0, 1000.0, 1.0)
            end
            Wait(100)
            for i=1, 10 do
                Wait(0)
                DrawSpotLight(pos.x, pos.y, pos.z, dir.x, dir.y, dir.z, 255, 255, 255, 100.0, Config.Photos.brightness, 0.0, 1000.0, 1.0)
            end
            local alert = lib.alertDialog({
                header = _L("photo_taken"),
                content = '![Photo Image]('..url..')\n\n' .. _L("photo_ask"),
                centered = true,
                cancel = true
            })
            if (alert == "confirm") then 
                photoURL = url
            end
        until photoURL
        CreateThread(function()
            DoScreenFadeOut(1000)
            Wait(1100)
            SetEntityCoords(ped, returnSettings.coords.x, returnSettings.coords.y, returnSettings.coords.z - 0.55)
            SetEntityHeading(ped, returnSettings.heading)
            FreezeEntityPosition(ped, false)
            ClearPedTasksImmediately(ped)
            DeletePhotoCam(cam)
            Wait(100)
            DoScreenFadeIn(1000)
        end)
        cb(photoURL)
    end)
    CreateThread(function()
        local playerId = PlayerId()
        while not photoURL do
            DrawBox(startBox.x, startBox.y, startBox.z, endBox.x, endBox.y, endBox.z, 16, 22, 27, 255)
            local players = GetActivePlayers()
            for i=1, #players do 
                if players[i] ~= playerId and players[i] ~= -1 then
                    SetEntityLocallyInvisible(GetPlayerPed(players[i]))
                end
            end
            Wait(0)
        end
    end)
end

AddEventHandler("onResourceStop", function(name)
    if name ~= GetCurrentResourceName() then return end
    if photoProp and DoesEntityExist(photoProp) then
        DeleteEntity(photoProp)
        photoProp = nil
    end
end)