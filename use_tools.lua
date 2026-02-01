local V = 'v1.2.0'
local PLACE_ID = 920587237 
local MIN_PLAYERS_PREFERRED = 5 
local MAX_PLAYERS_ALLOWED = 100
local SEARCH_TIMEOUT = 60
local TELEPORT_COOLDOWN = 15
local SCRIPT_URL = "https://raw.githubusercontent.com/MaxZarev/rblx/refs/heads/main/use_tools.lua"
local WATCHDOG_TIMEOUT = 360
local API_URL = "https://aerogenic-averi-subnutritiously.ngrok-free.dev"

local Tools = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/tools.lua?t=" .. tick()))()
local Auth = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/auth.lua?t=" .. tick()))()

if _G.BotRunning then
    warn("Скрипт уже запущен!")
    return
end
_G.BotRunning = true

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function runBot()
    local botState = Tools.getBotState()
    if not botState.running then return end

    Tools.setup(API_URL, Tools.apiKey, MIN_PLAYERS_PREFERRED, MAX_PLAYERS_ALLOWED, SEARCH_TIMEOUT, TELEPORT_COOLDOWN, PLACE_ID, SCRIPT_URL, Auth)
    Tools.enabled = true

    task.spawn(function()
        task.wait(WATCHDOG_TIMEOUT)
        
        pcall(function() Tools.sendMessageAPI("[WATCHDOG-1] Таймаут " .. WATCHDOG_TIMEOUT .. "с") end)
        
        for i = 1, 3 do
            pcall(function() Tools.serverHop() end)
            task.wait(30)
        end
        
        pcall(function()
            game:GetService("TeleportService"):Teleport(PLACE_ID, player)
        end)
    end)

    Tools.sendMessageAPI("Скрипт запущен " .. V)
    Tools.connectChatListener()

    Tools.randomDelay(3, 7)

    if not botState.running then
        Tools.sendMessageAPI("[BOT] Остановлен пользователем")
        return
    end

    if Tools.waitForPlayButton(20) then
        Tools.randomDelay(3, 6)
        Tools.clickPlayButton()
        Tools.sendMessageAPI("PlayButton OK")
    else
        Tools.sendMessageAPI("PlayButton не найден")
    end

    if Tools.waitForAdoptionIslandButton(20) then
        Tools.randomDelay(3, 6)
        local success, message = Tools.clickAdoptionIslandButton()
        if success then
            Tools.sendMessageAPI("Клик по кнопке Adoption Island выполнен успешно")
        else
            Tools.sendMessageAPI("Клик по кнопке Adoption Island не выполнен")
        end
    end

    if not botState.running then
        Tools.sendMessageAPI("[BOT] Остановлен пользователем")
        return
    end

    Tools.randomDelay(5, 10)

    local casualMsg = Tools.getCasualMessage()
    Tools.sendChat(casualMsg)

    Tools.randomDelay(8, 15)

    if not botState.running then
        Tools.sendMessageAPI("[BOT] Остановлен пользователем")
        return
    end

    local adData = Tools.getAdMessage()

    if adData then
        Tools.sendChat(adData.message)
        Tools.checkAndDeactivateIfFiltered(adData.id, 2)
    else
        Tools.sendChat("RBLX . PW - sell you pets for real money")
        Tools.sendMessageAPI("[AD] Fallback")
    end

    Tools.randomDelay(5, 10)

    if not botState.running then
        Tools.sendMessageAPI("[BOT] Остановлен пользователем")
        return
    end

    Tools.serverHop()
end

local savedApiKey = Tools.loadSavedApiKey()

if savedApiKey then
    local botState = Tools.getBotState()
    botState.running = true
    
    Tools.createSettingsGUI(runBot)
    
    task.spawn(function()
        runBot()
    end)
else
    Tools.createSettingsGUI(runBot)
end
