
local PLACE_ID = 920587237  -- ID игры Adopt Me на платформе Roblox
local MIN_PLAYERS_PREFERRED = 5  -- Предпочтительное минимальное количество игроков на сервере
local MIN_PLAYERS_FALLBACK = 3  -- Запасное минимальное количество, если поиск затягивается
local MAX_PLAYERS_ALLOWED = 100  -- Максимальное количество игроков (принимаем почти любой сервер)
local SEARCH_TIMEOUT = 60  -- Таймаут поиска в секундах, после которого снижаются требования
local TELEPORT_COOLDOWN = 15  -- Задержка перед телепортацией (сокращенная)
local SCRIPT_URL = "https://raw.githubusercontent.com/MaxZarev/rblx/refs/heads/main/use_tools.lua" 

local API_URL = "https://aerogenic-averi-subnutritiously.ngrok-free.dev"

local MESSAGES = {
    "Best site to sell Adopt Me pets - RBLX . PW",  -- Лучший сайт для продажи питомцев
    "Got extra pets? Sell them on RBLX PW for mon3y",  -- "mon3y" вместо "money" для обхода фильтра
    "RBLX . PW - #1 marketplace for Adopt Me pets",  -- Номер 1 маркетплейс
    "Sel your Adopt Me pets safely on RBLX . PW",  -- "Sel" вместо "Sell" для обхода
    "Trade Adopt Me pets for cash at RBLX. PW",  -- Обменивай питомцев на деньги
    "RBLX . PW - instant payouts for your Adopt Me pets",  -- Мгновенные выплаты
    "Got duplicate pets? Cash them out on RBLX . PW",  -- Есть дубликаты? Обменяй на деньги
    "SeIIing Adopt Me pets? Check out RBLX.PW for best prices",  -- "SeIIing" с заглавными i
    "RBLX . PW - tra sted mark etplace for Adopt Me trading",  -- Разделенные слова для обхода
    "Turn your Adopt Me pets into cash at RBLX . PW",  -- Преврати питомцев в деньги
    "RBLX . PW - safe and fast Adopt Me pet sales",  -- Безопасно и быстро
    "Best pri ces for Adopt Me pets at RBLX . PW"  -- Разделенное "prices"
}



local Tools = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/tools.lua"))()
local Auth = loadstring(game:HttpGet("https://raw.githubusercontent.com/MaxZarev/rblx/main/auth.lua"))()


local API_KEY = Auth.getApiKey()
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

Tools.sendChat("Всем привет")
task.wait(5)

-- Проверяем перед выполнением действия
if not Tools.isEnabled() then
    Tools.sendMessageAPI("[BOT] Остановлен пользователем")
    return
end

Tools.serverHop()

task.wait(5)
