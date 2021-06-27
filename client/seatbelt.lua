SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage);
local seatbeltOn = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsPedInAnyVehicle(PlayerPedId()) and seatbeltOn then
            DisableControlAction(0, 75, true) -- Disable exit vehicle when stop
            DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
        else
            seatbeltOn = false
            Citizen.Wait(1000)
        end
    end
end)

function toggleSeatbelt(makeSound, toggle)
    if toggle == nil then
        if seatbeltOn then
            QBCore.Functions.Notify('Unbuckled', 'error')
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
        else
            QBCore.Functions.Notify('Buckled', 'success')
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0);
        end
        seatbeltOn = not seatbeltOn
    else
        if toggle then
            QBCore.Functions.Notify('Buckled', 'success')
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0);
        else
            QBCore.Functions.Notify('Unbuckled', 'error')
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
        end
        seatbeltOn = toggle
    end
end

function playSound(action)
    if Config.playSound then
        if Config.playSoundForPassengers then
            local veh = GetVehiclePedIsUsing(ped)
            local maxpeds = GetVehicleMaxNumberOfPassengers(veh) - 2
            local passengers = {}
            for i = -1, maxpeds do
                if not IsVehicleSeatFree(veh, i) then
                    local ped = GetPlayerServerId( NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(veh, i)) )
                    table.insert(passengers, ped)
                end
            end
            TriggerServerEvent('seatbelt:server:PlaySound', action, json.encode(passengers))
        else
            SendNUIMessage({type = action, volume = Config.volume})
        end
    end
end

RegisterCommand('toggleseatbelt', function(source, args, rawCommand)
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local class = GetVehicleClass(GetVehiclePedIsIn(PlayerPedId()))
        if class ~= 8 and class ~= 13 and class ~= 14 then
            toggleSeatbelt(true)
        end
    end
end, false)

exports("status", function() return seatbeltOn end)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')