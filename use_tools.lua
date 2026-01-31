local V = 'v1.1.0'
local PLACE_ID = 920587237  -- ID игры Adopt Me на платформе Roblox
local MIN_PLAYERS_PREFERRED = 5  -- Предпочтительное минимальное количество игроков на сервере
local MAX_PLAYERS_ALLOWED = 100  -- Максимальное количество игроков (принимаем почти любой сервер)
local SEARCH_TIMEOUT = 60  -- Таймаут поиска в секундах, после которого снижаются требования
local TELEPORT_COOLDOWN = 15  -- Задержка перед телепортацией (сокращенная)
local SCRIPT_URL = "https://raw.githubusercontent.com/MaxZarev/rblx/refs/heads/main/use_tools.lua"

local WATCHDOG_TIMEOUT = 720

local API_URL = "https://aerogenic-averi-subnutritiously.ngrok-free.dev"

local Tools = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/tools.lua?t=" .. tick()))()
local Auth = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/auth.lua?t=" .. tick()))()


local API_KEY = Auth.getApiKey()

if _G.BotRunning then
    Tools.sendMessageAPI("Скрипт уже запущен!")
    return
end
_G.BotRunning = true

Tools.setup(API_URL, API_KEY, MIN_PLAYERS_PREFERRED, MAX_PLAYERS_ALLOWED, SEARCH_TIMEOUT, TELEPORT_COOLDOWN, PLACE_ID, SCRIPT_URL)

task.spawn(function()
    task.wait(WATCHDOG_TIMEOUT)
    
    pcall(function() Tools.sendMessageAPI("[WATCHDOG-1] Таймаут " .. WATCHDOG_TIMEOUT .. "с") end)
    
    for i = 1, 3 do
        pcall(function() Tools.serverHop() end)
        task.wait(30)
    end
    
    pcall(function()
        game:GetService("TeleportService"):Teleport(PLACE_ID, game:GetService("Players").LocalPlayer)
    end)
end)


Tools.sendMessageAPI("Скрипт запущен " .. V)
Tools.connectChatListener()


Tools.randomDelay(3, 7)

if not Tools.isEnabled() then
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


if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

Tools.randomDelay(5, 10)

local casualMsg = Tools.getCasualMessage()
Tools.sendChat(casualMsg)

Tools.randomDelay(8, 15)

if not Tools.isEnabled() then
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

if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

Tools.serverHop()
