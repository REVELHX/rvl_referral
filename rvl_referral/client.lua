ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(10)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    Citizen.Wait(1500)
    ESX.TriggerServerCallback('rvl_referral:CodeStatus', function(cb)
        if cb == true then
            GenClientCode() -- will check if the player got a code, if not it will run 
        end
    end)
end)



RegisterCommand(Config.ReferralCommand, function(source, args) -- command to claim refs codes (ex: /referral CODE)
    local code = args[1]
    if code == nil then
        ESX.ShowNotification("Please! Write a code!")
    elseif code ~= nil then
        ESX.TriggerServerCallback('rvl_referral:ClaimStatus', function(cb)
            if cb == false then
                ESX.ShowNotification("Code has been Claimed!")
            elseif cb == true then
                ESX.ShowNotification("You already have claimed a code before!")
            end
        end, code)
    end
end)

function GenClientCode()
    local numbers = math.random(1111, 9999)
    local code = Config.CodePerfix .. numbers
    local CodeExist = true
    local confirmed = false
    while true do
        Citizen.Wait(10)
        if CodeExist and not confirmed then
            CodeExist = false
            ESX.TriggerServerCallback('rvl_referral:CodeVerify', function(using)
                if using ~= nil then
                    CodeExist = true
                    code = Config.CodePerfix .. numbers
                elseif using == nil then
                    confirmed = true
                    CodeExist = false
                end
            end, code)
        elseif not CodeExist and confirmed then
            break
        end
    end
    TriggerServerEvent('rvl_referral:CodeCreated', code)
end


-- TEST COMMAND

--[[RegisterCommand("gen", function(source)
    ESX.TriggerServerCallback('rvl_referral:CodeStatus', function(cb)
        if cb == true then
            GenClientCode()
            print("Generated your first code")
        else
            print("this user already have code")
        end
    end)
end)]]--