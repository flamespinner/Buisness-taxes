---------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- Server File (This is code that is run globally on the server) ----------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------


---------------- Initialize Vorpcore ----------------
local VorpCore = {}

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

VORP = exports.vorp_core:vorpAPI()

function SendWebhookMessage(webhook,message)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = "Server", content = message}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('Buisness-taxes:getTaxRate')
AddEventHandler('Buisness-taxes:getTaxRate', function(inputResult)
    local _source = source
    local jobCode = inputResult
    print(jobCode)

    --normal mySQL Query: SELECT taxRate FROM society_ledger WHERE job = 'vtsaloon';
    exports.ghmattimysql:execute("SELECT taxRate FROM society_ledger WHERE job = @jobCode", { ['jobCode'] = jobCode }, function(result)
        if result[1] ~= nil then
            local taxRate = result[1].taxRate
            print(result[1].taxRate)
            TriggerClientEvent('vorp:TipRight', _source, "The Tax Rate is: $" .. taxRate, 4000)
        end
    end)
end)






---------------- DataBase Query Examples ----------------
---------------- SQL Knowledge is needed to utilize DataBase Queries ----------------
---------------- Examples are very simplistic and should be drasstically expanded upon if used. ----------------
RegisterCommand("sqltest", function(source, args, rawCommand)
    local User = VorpCore.getUser(source)
    local _source = source
    local Character = User.getUsedCharacter
    local identifier = Character.identifier
    local charid = Character.charIdentifier
    message = GetPlayerName(source)

    local webhook = Config.webhookURL

    -- Insert/Add data to a database table, the table is named 'test'
    exports.ghmattimysql:execute("INSERT INTO test (id, name) VALUES (@identifier, @name)", {["@identifier"] = identifier, ["@name"] = 'testuser'}, function(result)
        if result then
            TriggerClientEvent('vorp:ShowAdvancedRightNotification', _source, "your text", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
            SendWebhookMessage(webhook,message)
        end
    end)
   
    -- Grab all data from a database table, the table is named 'test'
    exports.ghmattimysql:execute("SELECT * FROM test", {}, function(result)
        if result[1] then
            TriggerClientEvent('vorp:ShowAdvancedRightNotification', _source, "your text", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
            SendWebhookMessage(webhook,message)
        end
    end)

    -- Grab a specific data column from a database table, the table is named 'test', where the name of the user is 'testuser'
    exports.ghmattimysql:execute("SELECT id FROM test WHERE name = @name", {["@name"] = 'testuser'}, function(result)
        if result[1] then
            TriggerClientEvent('vorp:ShowAdvancedRightNotification', _source, "something", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
            SendWebhookMessage(webhook,message)
        end
    end)

    exports.ghmattimysql:execute("UPDATE test SET name = @name WHERE identifier = @identifier", {["@update"] = 'testuser1', ["@identifier"] = identifier}, function(result)
        TriggerClientEvent('vorp:ShowAdvancedRightNotification', _source, "Data Updated", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
        SendWebhookMessage(webhook,message)
    end)

    exports.ghmattimysql:execute("DELETE FROM test WHERE identifier = @identifier", {["@identifier"] = identifier}, function(result)
        if result then
            if result.affectedRows >= 1 then
                TriggerClientEvent('vorp:ShowAdvancedRightNotification', _source, "Data Removed", "generic_textures", "tick", "COLOR_PURE_WHITE", 4000)
            end
        end
    end)
end)

RegisterCommand("getTime", function (source, args, rawCommand)
    local source = source
    local time = os.date("%H:%M:%S")
    local day = os.date("%A")

    if (day == "Monday") then
        print("It's Monday!")
        
    end
    if (day == "Tuesday") then
        print("It's Tuesday!")
    end
    if (day == "Wednesday") then
        print("It's Wednesday!")
    end
    if (day == "Thursday") then
        print("It's Thursday!")
    end
    if (day == "Friday") then
        print("It's Friday!")
    end

    print("The Time is:", time)

end)

RegisterCommand("getRepo", function (source, args, rawCommand)
    local webhook = Config.webhookURL

    exports.ghmattimysql:execute("SELECT repo FROM society_ledger WHERE repo = @repo", {["@repo"] = '1'}, function(Reporesult)
        SendWebhookMessage(webhook,Reporesult)
    end)
end)