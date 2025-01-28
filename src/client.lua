ESX = nil
local Job = nil
local Job2 = nil
local PlayerData = nil
Hidden = true

local isTalking = false
local loaded = false

function format_money(integer)
	if integer >= 0 then
		for i = 1, math.floor((string.len(integer)-1) / 3) do
			integer = string.sub(integer, 1, -3*i-i) .. '.' .. string.sub(integer, -3*i-i+1)
		end
	end
    return integer
end

exports("setMumbleRange", function(range)
	if range == 1 or range == 4 then
		local color = '#ffff00'
		local procent = 30
		--print 'whisper'
		SendNUIMessage({action = "voiceChange", setcolor = color, value = procent})
	elseif range == 2 then
		local color = '#00FF00'
		local procent = 70
		--print 'normal'
		SendNUIMessage({action = "voiceChange", setcolor = color, value = procent})
	elseif range == 3 then
		local color = '#FF0000'
		local procent = 100
		SendNUIMessage({action = "voiceChange", setcolor = color, value = procent})
		--print 'shjout'
	end
	--SendNUIMessage({action = "voiceChange", setcolor = color, value = procent})
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end
	while not ESX.IsPlayerLoaded() do
		Citizen.Wait(500)
	end

	Citizen.Wait(500)
	PlayerData = ESX.GetPlayerData()

	Job = PlayerData.job
	Job2 = PlayerData.job2


	TriggerEvent('es:setMoneyDisplay', 0.0)
	ESX.UI.HUD.SetDisplay(0.0)

	local accounts = PlayerData.accounts
	local playerId = PlayerId()
	local playerServerId = GetPlayerServerId(playerId)
	SendNUIMessage({action = "setId", key = "id", value = playerServerId})
	for k,v in pairs(accounts) do
		local account = v
		if account.name == "bank" then
			SendNUIMessage({action = "setValue", key = "bankmoney", value = "€ "..format_money(account.money)})
		elseif account.name == "black_money" then
			SendNUIMessage({action = "setValue", key = "dirtymoney", value = "€ "..format_money(account.money)})
		end
	end

	local job = PlayerData.job
	local job2 = PlayerData.job2
	SendNUIMessage({action = "setValue", key = "job", value = job.label.." - ".. job.grade_label, icon = job.name})
	if Job2 then
	SendNUIMessage({action = "setValue", key = "job2", value = Job2.label.." - ".. Job2.grade_label, icon = Job2.name})
	end

	-- Money
	SendNUIMessage({action = "setValue", key = "money", value = "€"..format_money(PlayerData.money)})
	loaded = true
	OnLoaded()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    local accounts = PlayerData.accounts
    for k,v in pairs(accounts) do
        local account = v
        if account.name == "bank" then
            SendNUIMessage({action = "setValue", key = "bankmoney", value = "€ "..format_money(account.money)})
        elseif account.name == "black_money" then
            SendNUIMessage({action = "setValue", key = "dirtymoney", value = "€ "..format_money(account.money)})
        elseif account.name == "money" then
            SendNUIMessage({action = "setValue", key = "money", value = "€ "..format_money(account.money)})
        end
    end

    -- Job
    local job = PlayerData.job
    local job2 = PlayerData.job2
    SendNUIMessage({action = "setValue", key = "job", value = job.label.." - "..job.grade_label, icon = job.name})
    SendNUIMessage({action = "setValue", key = "job2", value = job2.label.." - "..job2.grade_label, icon = job2.name})
    -- Money
    SendNUIMessage({action = "setValue", key = "money", value = "€ "..PlayerData.money})
end)

function OnLoaded()
	local accounts = PlayerData.accounts
	for k,v in pairs(accounts) do
		local account = v
		if account.name == "bank" then
			SendNUIMessage({action = "setValue", key = "bankmoney", value = "€ "..format_money(account.money)})
		elseif account.name == "black_money" then
			SendNUIMessage({action = "setValue", key = "dirtymoney", value = "€ "..format_money(account.money)})
		end
	end

	RefreshJobs()

	-- Money
	SendNUIMessage({action = "setValue", key = "money", value = "€ "..format_money(PlayerData.money)})
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	OnLoaded()
end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while (not IsScreenFadedIn() or IsPlayerSwitchInProgress() or GetIsLoadingScreenActive()) and not loaded do
		Citizen.Wait(500)
	end
	SendNUIMessage({action = "startUI"})
	while true do
		Citizen.Wait(250)
		if isTalking == false then
			if NetworkIsPlayerTalking(PlayerId()) then
				isTalking = true
				SendNUIMessage({action = "setTalking", value = true})
			end
		else
			if NetworkIsPlayerTalking(PlayerId()) == false then
				isTalking = false
				SendNUIMessage({action = "setTalking", value = false})
			end
		end
	end
end)

RegisterNetEvent('ui:toggle')
AddEventHandler('ui:toggle', function(show)
	SendNUIMessage({action = "toggle", show = show})
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	if account.name == "bank" then
		SendNUIMessage({action = "setValue", key = "bankmoney", value = "€"..format_money(account.money)})
	elseif account.name == "black_money" then
		SendNUIMessage({action = "setValue", key = "dirtymoney", value = "€"..format_money(account.money)})
	elseif account.name == 'cash' or account.name == 'money' then
		SendNUIMessage({action = "setValue", key = "money", value = "€"..format_money(account.money)})
	end
end)

function RefreshJobs()
    -- Job
    local job = PlayerData.job
    local job2 = PlayerData.job2

    local jobGrade = job.grade_label
    if GetFakeJob() then
        jobGrade = GetFakeJob()
    end
    if job and job.label and job.grade_label then
        SendNUIMessage({
            action = "setValue",
            key = "job",
            value = job.label .. " - " .. jobGrade,
            icon = job.name
        })
    end
    if job2 and job2.label and job2.grade_label then
        SendNUIMessage({
            action = "setValue",
            key = "job2",
            value = job2.label .. " - " .. job2.grade_label,
            icon = job2.name
        })
    end
end

function GetFakeJob()
	local fakeJob = GetResourceKvpString("fakeJob")
	if not fakeJob or fakeJob == "" or fakeJob == " " or fakeJob == "nil" then
		return nil
	end
	if CanUseFakegrade() then
		return fakeJob
	end
	return nil
end

function CanUseFakegrade()
    if PlayerData.job ~= nil and ((PlayerData.job.name == 'police' and PlayerData.job.grade > 6) or (PlayerData.job.name == 'kmar' and PlayerData.job.grade > 14) or (PlayerData.job.name == 'offpolice' and PlayerData.job.grade > 6) or (PlayerData.job.name == 'offkmar' and PlayerData.job.grade > 14))  then
        return true
    end
    return false
end

local function setHudState(value)
	TriggerEvent("ui:toggle", value)
end

local function toggleHud()
	if GlobalState.IsHudDisabled then
		setHudState(true)
	else
		setHudState(false)
	end
end

RegisterCommand('togglehud', function(source, args, raw)
	if not args or not args[1] then
		toggleHud()
	else
		local a = tostring(args[1])
		if a == "off" or a == "uit" then
			setHudState(false)
		elseif a == "on" or a == "aan" then
			setHudState(true)
		else
			toggleHud()
		end
	end
end)

TriggerEvent('esx:addSuggestion', 'togglehud', { help = "Schakel je HUD elementen aan en uit", arguments = { name = "aan/uit", help = "on/off"} })

RegisterNetEvent('ui:toggle')
AddEventHandler('ui:toggle', function(show)
	SendNUIMessage({
		action = "toggle",
		show = show
	})
	GlobalState.IsHudDisabled = not show
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	RefreshJobs()
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
	PlayerData.job2 = job2
	RefreshJobs()
end)

TriggerEvent('chat:addSuggestion', '/fake_grade', 'Pas rang die weergegeven wordt in UI aan', {
    { name="job_grade", help="Neppe job grade om in te stellen, laat leeg om te resetten" },
})

RegisterCommand("fake_grade", function(source, args, raw)
	local text = ""
	if args[1] ~= nil then
		text = table.concat(args, " ") or ""
	end
	SetResourceKvp("fakeJob", text)
	RefreshJobs()
end)


RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(e)
	SendNUIMessage({action = "setValue", key = "money", value = "€"..format_money(e)})
end)

RegisterNetEvent('esx_customui:updateStatus')
AddEventHandler('esx_customui:updateStatus', function(status)
	SendNUIMessage({action = "updateStatus", status = status})
end)

AddEventHandler('esx_customui:setProximity', function(proximity)
    SendNUIMessage({action = "setProximity", value = proximity})
end)

RegisterNetEvent('esx_customui:updateWeight')
AddEventHandler('esx_customui:updateWeight', function(weight)
	local weightprc = (weight/8000)*100
	SendNUIMessage({action = "updateWeight", weight = weightprc})
end)
