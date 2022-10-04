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

--end of setup

AddEventHandler('onResourceStart', function(buisnesstaxes)
    local day = Config.repotime.day
    local dayActual = os.date("%d")
    local hour = Config.repotime.hour
    local hourActual = os.date("%H")
    local minute = Config.repotime.minute
    local minuteActual = os.date("%M")
    if (GetCurrentResourceName() ~= buisnesstaxes) then -- check to make sure it is the right resource, if not correct, return
      return
    end
    print('The resource ' .. buisnesstaxes .. ' has been started...')
    print('Day: ', day, ' Hour: ', hour, ' Minute: ', minute) --debug
    print('Day Actual: ', dayActual, ' Hour Actual: ', hourActual, ' Minute Actual: ', minuteActual) --debug

    
    if (day == dayActual) then --Check Date
        print(day, dayActual)
        if (hour == hourActual) then
            if (minute == minuteActual) then
                print("It's Tax Day")
                --print(day, dayActual, hour, hourActual, minute, minuteActual) --debug
            else
                print("It's not Tax Day")
                --print(day, dayActual, hour, hourActual, minute, minuteActual) --debug
            end
        end
    end
end)

RegisterServerEvent('buisnesstaxes:getTaxRate')
AddEventHandler('buisnesstaxes:getTaxRate', function(inputResult)
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

--[[ RegisterServerEvent('buisnesstaxes:setTaxRate')
AddEventHandler('buisnesstaxes:setTaxRate', function(job, newTaxValue)
    local _source = source
    local jobCode = job
    local taxValue = newTaxValue
    print("Server Event", jobCode, taxValue)

    -- UPDATE [table] SET [row name] = [new value] WHERE [row name] = [value]
    exports.ghmattimysql:execute("UPDATE society_ledger SET taxRate = @updateTax WHERE job = @jobcode", { ['taxRate'] = taxValue, ['jobCode'] = jobCode }, function(result)
        if result[1] ~= nil then
            --TriggerClientEvent('vorp:TipRight', _source, "The Tax Rate is: $" .. taxRate, 4000)
        end
    end)
end) ]]

RegisterServerEvent('buisnesstaxes:taxTime')
AddEventHandler('buisnesstaxes:taxTime', function ()

    exports.ghmattimysql:execute("SELECT job,taxRate,ledger,(ledger-taxRate) as col3 FROM society_ledger;", function(result)
        if result[1] ~= nil then
            for k,v in pairs(result) do
                local jobCode = v.job
                local col3 = v.col3
                --print("jobcode:",jobCode, "col3:",col3) --debug. Print to console job code and Math results (ledger - taxRate)
                Wait(200)
                -- UPDATE [table] SET [row name] = [new value] WHERE [row name] = [value]
                exports.ghmattimysql:execute("UPDATE society_ledger SET ledger = @updatedTax WHERE job = @jobID;", {
                    ['updatedTax'] = tonumber(v.col3),
                    ['jobID'] =  tostring(v.job)
                })
                print("jobcode", jobCode, "Updated Tax:", col3) --debug 
            end
        end
    end)
end)

RegisterServerEvent('buisnesstaxes:repoSet')
AddEventHandler('buisnesstaxes:repoSet', function ()
    exports.ghmattimysql:execute("SELECT job FROM society_ledger WHERE ledger < 0;", function (result)
        if result[1] ~= nil then
            for k,v in pairs(result) do
                print(v.job) -- debug print jobs that have a negative ledger value
                exports.ghmattimysql:execute("UPDATE society_ledger SET repo = 1 WHERE job = @jobID;", {
                    ['jobID'] =  tostring(v.job)
                })
            end
        end
    end)
end)


RegisterServerEvent("buisnesstaxes:getRepoStatus")
AddEventHandler("buisnesstaxes:getRepoStatus", function()
    local webhook = Config.webhookURL

    exports.ghmattimysql:execute("SELECT job FROM society_ledger WHERE repo = 1", function(repoResult)
        if type(repoResult) == "table" then
            for k,v in pairs(repoResult) do
                local tableRow = tostring(k)
                local jobCode = tostring(v.job)
                print(tableRow, jobCode) --debug
                SendWebhookMessage(webhook,"RepoStatus: " .. jobCode)
            end
        end
    end)
end)


--[[ %a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´ ]]