
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

-- Рандомная пауза в диапазоне [min, max] секунд
local function randomWait(min, max)
    local delay = min + math.random() * (max - min)
    task.wait(delay)
    return delay
end

-- Защита от дублирования скрипта
if _G.BotRunning then
    Tools.sendMessageAPI("Скрипт уже запущен!")
    return
end
_G.BotRunning = true


Tools.setup(API_URL, API_KEY, MIN_PLAYERS_PREFERRED, MIN_PLAYERS_FALLBACK, MAX_PLAYERS_ALLOWED, SEARCH_TIMEOUT, TELEPORT_COOLDOWN, PLACE_ID, SCRIPT_URL)

Tools.sendMessageAPI("Скрипт запущен")

-- Подключаем слушатель чата сразу при старте (чтобы собирать сообщения)
Tools.connectChatListener()


randomWait(3, 7)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

if Tools.waitForPlayButton(20) then
    randomWait(3, 6)
    Tools.clickPlayButton()
    Tools.sendMessageAPI("PlayButton OK")
else
    Tools.sendMessageAPI("PlayButton не найден")
end


if Tools.waitForAdoptionIslandButton(20) then
    local success, message = Tools.clickAdoptionIslandButton()
    if success then
        Tools.sendMessageAPI("Клик по кнопке Adoption Island выполнен успешно")
    else
        Tools.sendMessageAPI("Клик по кнопке Adoption Island не выполнен")
    end
end


-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

-- Пауза после входа в игру
randomWait(5, 10)

-- 1. Отправляем обычное сообщение (камуфляж)
local casualMsg = Tools.getCasualMessage()
Tools.sendChat(casualMsg)
Tools.sendMessageAPI("[CASUAL] " .. casualMsg)

-- Пауза между сообщениями
randomWait(8, 15)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

-- 2. Отправляем рекламное сообщение
local adData = Tools.getAdMessage()

if adData then
    Tools.sendChat(adData.message)
    Tools.sendMessageAPI("[AD] ID: " .. adData.id)

    -- Проверяем фильтрацию через 2 секунды
    Tools.checkAndDeactivateIfFiltered(adData.id, 2)
else
    Tools.sendChat("RBLX . PW - best Adopt Me marketplace")
    Tools.sendMessageAPI("[AD] Fallback")
end

-- Пауза перед сменой сервера
randomWait(5, 10)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

Tools.serverHop()
