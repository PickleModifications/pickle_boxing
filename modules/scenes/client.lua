local sceneCam
local startingScene = false
sceneActive = false

function CreateSceneCam(pos, rot, fov)
    if sceneCam then 
        DeleteSceneCam(sceneCam)
    end
    local ped = PlayerPedId()
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov or 45.00, false, 0)
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 1, true, true)
    return cam
end

function DeleteSceneCam(cam)
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 1, true, true)
    DestroyCam(cam) 
end

function StartRotateScene(pos, heading, distance, doneCb)
    if startingScene then return end
    startingScene = true
    local startTime = GetGameTimer()
    local distance = distance or 7.0
    CreateThread(function()
        StopScene(true)
        startingScene = false
        local tilt = 0.0
        local step = 1
        sceneActive = true
        tilt = -5.0
        local offset = vector3(distance, distance, distance)
        local offsetCoords = pos + offset
        local heading = GetHeadingFromVector_2d(pos.x - offsetCoords.x, pos.y - offsetCoords.y)
        if not sceneCam then
            sceneCam = CreateSceneCam(offsetCoords, vector3(tilt, 0.0, heading), 75.0)
        end
        DoScreenFadeIn(500)
        SetCamCoord(sceneCam, offsetCoords.x, offsetCoords.y, offsetCoords.z)
        local fov = 90.0
        while tilt > -35.0 do
            tilt = tilt - (tilt < 0 and 0.05 or 0.1)
            fov = fov + 0.0075
            SetCamFov(sceneCam, fov)
            SetCamRot(sceneCam, tilt, 0.0, heading)
            Wait(0)
        end
        if doneCb then
            doneCb(GetGameTimer() - startTime)
        end
    end)
end

function StartFighterScene(ped)
    if startingScene then return end
    startingScene = true

    CreateThread(function()
        StopScene(true)
        startingScene = false
        local distance = 0.75
        local tilt = 0.0
        sceneActive = true
        tilt = -15.0
        local offsetCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.25, 0.5)
        local heading = GetEntityHeading(ped) + 180.0
        if not sceneCam then
            sceneCam = CreateSceneCam(offsetCoords, vector3(tilt, 0.0, heading), 70.0)
        end
        DoScreenFadeIn(500)
        local fov = 90.0
        local time = 0.0
        while time < 1 do
            local increment = 0.002
            if time > 0.9 then
                increment = 0.001
            elseif time > 0.7 then
                increment = 0.00125
            elseif time > 0.5 then
                increment = 0.0015
            end
            time = time + increment
            SetCamFov(sceneCam, lerp(70, 80, time))
            SetCamRot(sceneCam, lerp(-15, 5, time), 0.0, heading)
            SetCamCoord(sceneCam, offsetCoords.x, offsetCoords.y, lerp(offsetCoords.z - 1.0, offsetCoords.z - 0.25, time))
            Wait(0)
        end
    end)
end

function StopScene(skipFadeIn)
    DoScreenFadeOut(500)
    Wait(600)
    if sceneCam then
        DeleteSceneCam(sceneCam)
        sceneCam = nil
    end
    sceneActive = false
    if skipFadeIn then return end
    DoScreenFadeIn(500)
end

CreateThread(function()
    --StartRotateScene(Config.Locations[1].center.coords, Config.Locations[1].center.heading)
    --StartFighterScene(Config.Locations[1].fighterPositions[id].coords, Config.Locations[1].fighterPositions[id].heading, PlayerPedId())
end)