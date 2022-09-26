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

RegisterServerEvent('Buisness-taxes:setTaxRate')
AddEventHandler('Buisness-taxes:setTaxRate', function(updateTax)
    local _source = source
    local jobCode = updateTax
    print(jobCode)

    -- UPDATE [table] SET [row name] = [new value] WHERE [row name] = [value]
    exports.ghmattimysql:execute("UPDATE society_ledger SET taxRate = @updateTax WHERE job = @jobcode", { ['taxRate'] = updateTax, ['jobCode'] = jobCode }, function(result)
        if result[1] ~= nil then
            --Something
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