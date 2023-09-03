ESX = exports["es_extended"]:getSharedObject()
local IsSpawned = false
local CoolDownActive = false
local Turn = false

--loadmodel function
LoadModel = function (hash)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
end

--load animation
LoadAnimition = function (anim_dir)
    RequestAnimDict(anim_dir)
    while not HasAnimDictLoaded(anim_dir) do
        Wait(0)
    end
end
-- spawn ped function
SpawnPeds = function (hash, x, y, z, w, anin_dir, anim)
    LoadModel(hash)
    LoadAnimition(anin_dir)
    local Ped = CreatePed(2, hash, x, y, z, w, true, false)
    FreezeEntityPosition(Ped, true)
    SetBlockingOfNonTemporaryEvents(Ped, true)
    SetEntityInvincible(Ped, true)
    TaskPlayAnim(Ped, anin_dir, anim,8.0, 8.0, -1, 1, 0.0, false, false, false)
end
 Display3DText = function(text, x, y, z)
    local onScreen, worldX, worldY = World3dToScreen2d(x, y, z)

    if onScreen then
        SetTextScale(0.40, 0.40)
        SetTextFont(8)
        SetTextProportional(1)
        SetTextColour(229, 255, 204, 215)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(worldX, worldY)
    end
end

SpawnBoat = function (hash,x, y,z,w)
    LoadModel(hash)
    Boat = CreateVehicle(hash, x, y, z, w, true, false)
    SetPedIntoVehicle(PlayerPedId(), Boat, -1)
    Blip = AddBlipForCoord(Config.Ped_Dilever.position.x, Config.Ped_Dilever.position.y, Config.Ped_Dilever.position.z)
    SetBlipColour(Blip, 3)
    SetBlipSprite(Blip, 58)
    IsSpawned = true

end
function CoolDown(duration)
    if not CoolDownActive then
        CoolDownActive = true
        Citizen.CreateThread(function()
             initial = 0
            while initial < duration * 1000 do
                initial = initial + 1000 -- Increment by 1000 (1 second)
                Wait(1000)
            end
            CoolDownActive = false
        end)
    end
end

CreateThread(function()
    CreateThread(function ()
        while true do
            Wait(0)
            local PlayerPos = GetEntityCoords(PlayerPedId())
            local PedPos = vector3(Config.Ped_Rent.position.x, Config.Ped_Rent.position.y, Config.Ped_Rent.position.z)
            local Dist = #(PlayerPos - PedPos)
            if Dist < 7.0 then
                Display3DText("Press [E] To Rent a Boat", Config.Ped_Rent.position.x, Config.Ped_Rent.position.y, Config.Ped_Rent.position.z + 2.2) -- Replace with your desired position
            end
            if Dist < 2.0 then
                ESX.ShowHelpNotification("You Can Rent Boat Here", true, true, 1500)
                if IsControlJustPressed(0, 38) then
                    if not IsSpawned then
                       if not CoolDownActive then
                            SpawnBoat(Config.Boat.hash, Config.Boat.position)
                            CoolDown(180)
                            CreateThread(function ()
                                CreateThread(function ()
                                    while true do
                                        Wait(0)
                                        local PlayerPos = GetEntityCoords(PlayerPedId())
                                        local PedPos = vector3(Config.Ped_Dilever.position.x, Config.Ped_Dilever.position.y, Config.Ped_Dilever.position.z)
                                        local Dist = #(PlayerPos - PedPos)
                                        if Dist < 5.0 then
                                            if not Turn then
                                                Display3DText("Press [E] To Return a Boat", Config.Ped_Dilever.position.x, Config.Ped_Dilever.position.y, Config.Ped_Dilever.position.z + 2.2) -- Replace with your desired position

                                            end
                                        end
                                        if Dist < 4.0 then
                                            if IsControlJustPressed(0, 38) then
                                                DeleteEntity(Boat)
                                                DeleteEntity(Ped_Dilever)
                                                RemoveBlip(Blip)
                                                IsSpawned = false
                                                Turn = true
                                            end
                                        end
                                    end
                                end)
                                LoadModel(Config.Ped_Dilever.hash)
                                LoadAnimition(Config.Ped_Dilever.anim_dir)
                                Ped_Dilever = CreatePed(2, Config.Ped_Dilever.hash, Config.Ped_Dilever.position, true, false)
                                FreezeEntityPosition(Ped, true)
                                SetBlockingOfNonTemporaryEvents(Ped, true)
                                SetEntityInvincible(Ped, true)
                                TaskPlayAnim(Ped, anin_dir, anim,8.0, 8.0, -1, 1, 0.0, false, false, false)
                            end)
                        else
                            local num = 180
                            num = (num - initial / 1000)
                            ESX.ShowNotification("ColdDown is Active ".. num, "error", 1000)
                            PlaySoundFrontend(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", 1)
                            Wait(1000)
                        end
                    else
                        TriggerEvent('esx:showNotification', '~r~  You alreday take boat')

                    end
                end
            end
        end
    end)
    SpawnPeds(Config.Ped_Rent.hash, Config.Ped_Rent.position.x, Config.Ped_Rent.position.y, Config.Ped_Rent.position.z,Config.Ped_Rent.position.w,  Config.Ped_Rent.anim_dir, Config.Ped_Rent.anim)
end)

--next phase
