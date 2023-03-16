ESX = nil
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterNetEvent('rvl_referral:CodeCreated')
AddEventHandler('rvl_referral:CodeCreated', function(code)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.insert('UPDATE referrals SET code = @code, name = @name WHERE identifier = @identifier', {
        ['@identifier'] = tostring(xPlayer.identifier),
        ['@name'] = tostring(xPlayer.getName()),
        ['@code'] = tostring(code)
    }, function(result)
    end)
end)

RegisterNetEvent('rvl_referral:Rewards')
AddEventHandler('rvl_referral:Rewards', function(source, target)
    local xPlayer = ESX.GetPlayerFromId(source) -- the player how do /referral
    local xTarget = nil -- the Owner of the Code

    for k, v in ipairs(ESX.GetPlayers()) do
        local players = ESX.GetPlayerFromId(v)
        if players.identifier == target then
            xTarget = ESX.GetPlayerFromId(v)
        end
    end

    Citizen.Wait(100)
    if xTarget or xTarget ~= nil then
        -- add here what you want to reward. put xPlayer for source and xTarget for Owner Code --
        xPlayer.addMoney(Config.RewardPlayer) -- the player how do /referral get money .
        xTarget.addMoney(Config.RewardOwnerCode) -- The Owner get much more money.

        TriggerClientEvent('esx:showNotification', xPlayer, "You get 100€ for use /referral")
        TriggerClientEvent('esx:showNotification', xTarget, "You get 1000€ a player used your Referral Code")
    else
        TriggerClientEvent('esx:showNotification', source, "Code Owner is not on Server!")
    end
end)

ESX.RegisterServerCallback('rvl_referral:ClaimStatus', function(source, cb, code)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM referrals WHERE code = @code', {
        ['@code'] = code
    }, function(result)
        local db = result[1]
        if db == nil then
            TriggerClientEvent('esx:showNotification', source, "That code don't exist!")
        elseif db then
            MySQL.Async.fetchAll('SELECT * FROM referrals_historic WHERE identifier = @identifier', {
                ['@identifier'] = tostring(xPlayer.identifier)
            }, function(result)
                local db = result[1]
                if db == nil then
                    cb(false)
                    local CodeOwnerName = nil
                    local OwnerIdentifier = nil
                    local OwnerUsedQty = nil
                    MySQL.Async.fetchAll('SELECT * FROM referrals WHERE code = @code', {
                        ['@code'] = code
                    }, function(result2)
                        local db = result2[1]
                        CodeOwnerName = db.name
                        OwnerIdentifier = db.identifier
                        OwnerUsedQty = db.used
                        TriggerEvent('rvl_referral:Rewards', source, OwnerIdentifier)
                        Citizen.Wait(250)

                        MySQL.Async.insert('UPDATE referrals SET used = @used WHERE identifier = @identifier', {
                            ['@identifier'] = tostring(OwnerIdentifier),
                            ['@used'] = OwnerUsedQty + 1
                        }, function(result3)

                            Citizen.Wait(250)

                            MySQL.Async.fetchAll(
                                'INSERT INTO referrals_historic (identifier, name, used_code, code_owner, name_owner) VALUES (@identifier, @name, @used_code, @code_owner, @name_owner)',
                                {
                                    ['@identifier'] = tostring(xPlayer.identifier),
                                    ['@name'] = tostring(xPlayer.getName()),
                                    ['@used_code'] = code,
                                    ['@code_owner'] = tostring(OwnerIdentifier),
                                    ['@name_owner'] = tostring(CodeOwnerName)
                                }, function(result)
                                    local db = result[1]
                                end)
                        end)
                    end)
                elseif db then
                    cb(true)
                end
            end)
        end
    end)
end)

ESX.RegisterServerCallback("rvl_referral:CodeVerify", function(source, cb, code)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM referrals WHERE code = @code', {
        ['@code'] = code
    }, function(result)
        local db = result[1]
        if db == nil then
            cb(db, true)
        elseif db then
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback("rvl_referral:CodeStatus", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local Exist = nil

    MySQL.Async.fetchAll('SELECT * FROM referrals WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        local db = result[1]
        if db == nil then
            Exist = false
        elseif db then
            Exist = true
        end

        if Exist == false then
            MySQL.Async.fetchAll('INSERT INTO referrals (identifier) VALUES (@identifier)', {
                ['@identifier'] = xPlayer.identifier
            })
            Citizen.Wait(150)
            MySQL.Async.fetchAll('SELECT code FROM referrals WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(result)

                if result[1].code == nil then
                    cb(true)
                else
                    cb(false)
                end
            end)
        elseif Exist == true then
            MySQL.Async.fetchAll('SELECT code FROM referrals WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(result)

                if result[1].code == nil then
                    cb(true)

                else
                    cb(false)

                end
            end)
        end

    end)
end)

