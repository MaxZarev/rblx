
local PLACE_ID = 920587237  -- ID игры Adopt Me на платформе Roblox
local MIN_PLAYERS_PREFERRED = 5  -- Предпочтительное минимальное количество игроков на сервере
local MIN_PLAYERS_FALLBACK = 3  -- Запасное минимальное количество, если поиск затягивается
local MAX_PLAYERS_ALLOWED = 100  -- Максимальное количество игроков (принимаем почти любой сервер)
local SEARCH_TIMEOUT = 60  -- Таймаут поиска в секундах, после которого снижаются требования
local TELEPORT_COOLDOWN = 15  -- Задержка перед телепортацией (сокращенная)
local SCRIPT_URL = "https://raw.githubusercontent.com/MaxZarev/rblx/refs/heads/main/use_tools.lua" 

local API_URL = "https://aerogenic-averi-subnutritiously.ngrok-free.dev"

local Tools = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/tools.lua?t=" .. tick()))()
local Auth = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/auth.lua?t=" .. tick()))()


local API_KEY = Auth.getApiKey()

-- Защита от дублирования скрипта
if _G.BotRunning then
    Tools.sendMessageAPI("Скрипт уже запущен!")
    return
end
_G.BotRunning = true


Tools.setup(API_URL, API_KEY, MIN_PLAYERS_PREFERRED, MIN_PLAYERS_FALLBACK, MAX_PLAYERS_ALLOWED, SEARCH_TIMEOUT, TELEPORT_COOLDOWN, PLACE_ID, SCRIPT_URL)

Tools.sendMessageAPI("Скрипт запущен")

-- Ждем пока бот будет включен
while not Tools.isEnabled() do
    task.wait(1)
end

task.wait(5)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

if Tools.waitForPlayButton(20) then
    task.wait(5)
    Tools.clickPlayButton()
    Tools.sendMessageAPI("Клик по кнопке PlayButton выполнен успешно")
else
    Tools.sendMessageAPI("Кнопка PlayButton не найдена")
end

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

task.wait(5)

-- Получаем сообщение из базы данных (сразу отмечается использованным)
local messageData = Tools.getAdMessage()

if messageData then
    Tools.sendChat(messageData.message)
    Tools.sendMessageAPI("[AD] ID: " .. messageData.id)
else
    Tools.sendChat("RBLX . PW - best Adopt Me marketplace")
    Tools.sendMessageAPI("[AD] Fallback")
end

task.wait(5)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

Tools.serverHop()

task.wait(5)
