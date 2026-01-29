-- ==================== РЕКЛАМНЫЙ БОТ ДЛЯ ADOPT ME ====================
-- Простой скрипт, который рекламирует RBLX.PW в чате и автоматически переключает серверы
-- ============================================================================

-- ==================== НАСТРОЙКИ ====================
local PLACE_ID = 920587237  -- ID игры Adopt Me на платформе Roblox
local MIN_PLAYERS_PREFERRED = 5  -- Предпочтительное минимальное количество игроков на сервере
local MIN_PLAYERS_FALLBACK = 3  -- Запасное минимальное количество, если поиск затягивается
local MAX_PLAYERS_ALLOWED = 100  -- Максимальное количество игроков (принимаем почти любой сервер)
local SEARCH_TIMEOUT = 60  -- Таймаут поиска в секундах, после которого снижаются требования
local TELEPORT_COOLDOWN = 15  -- Задержка перед телепортацией (сокращенная)
local SCRIPT_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/reklamabot/refs/heads/main/reklama.lua"  -- URL скрипта для автозагрузки

-- Рекламные сообщения (на английском языке для международной аудитории)
-- Специально используются опечатки и пробелы для обхода фильтров чата Roblox
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

--==================== СЕРВИСЫ ROBLOX ====================
-- Получаем доступ к различным сервисам игрового движка Roblox
local Players = game:GetService("Players")  -- Сервис для работы с игроками
local TextChatService = game:GetService("TextChatService")  -- Новая система чата Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")  -- Хранилище для старого чата
local TeleportService = game:GetService("TeleportService")  -- Сервис телепортации между серверами
local HttpService = game:GetService("HttpService")  -- Сервис для HTTP запросов и JSON
local VirtualInputManager = game:GetService("VirtualInputManager")  -- Виртуальный ввод (для анти-АФК)
local player = Players.LocalPlayer  -- Локальный игрок (мы)

-- Настройка HTTP для разных исполнителей (эксплоитов)
local httprequest = http.request  -- Функция HTTP запросов (зависит от эксплоита)
local queueFunc = queueonteleport  -- Функция для запуска кода после телепортации

--==================== ЛОГИРОВАНИЕ И СТАТИСТИКА ====================
local logLines = {}  -- Массив для хранения строк лога
local stats = {  -- Таблица статистики работы бота
    serversVisited = 0,  -- Количество посещенных серверов
    totalPlayersEncountered = 0,  -- Общее количество встреченных игроков
    startTime = os.time()  -- Время запуска бота (Unix timestamp)
}

-- Функция для записи сообщения в лог с временной меткой
local function log(msg)
    local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")  -- Форматируем текущую дату/время
    local logMsg = timestamp .. " " .. msg  -- Добавляем временную метку к сообщению
    print(logMsg)  -- Выводим в консоль
    table.insert(logLines, logMsg)  -- Сохраняем в массив для последующей записи в файл
end

-- Функция сохранения лога в файл (если эксплоит поддерживает writefile)
local function saveLog()
    if writefile then  -- Проверяем, доступна ли функция записи файлов
        local content = table.concat(logLines, "\n")  -- Объединяем все строки лога через перенос
        writefile("adoptme_advertiser.log", content)  -- Записываем в файл
    end
end

-- Функция сохранения статистики в файл
local function saveStats()
    if writefile then  -- Проверяем доступность функции записи
        local runTime = os.time() - stats.startTime  -- Вычисляем время работы бота в секундах
        local hours = math.floor(runTime / 3600)  -- Конвертируем в часы
        local minutes = math.floor((runTime % 3600) / 60)  -- Остаток конвертируем в минуты

        -- Форматируем текст статистики с использованием string.format
        local statsContent = string.format(
            "=== СТАТИСТИКА БОТА ADOPT ME ===\n" ..
            "Посещено серверов: %d\n" ..
            "Встречено игроков: %d\n" ..
            "Среднее кол-во игроков на сервер: %.1f\n" ..
            "Время работы: %dч %dм\n" ..
            "Последнее обновление: %s\n",
            stats.serversVisited,  -- Количество серверов
            stats.totalPlayersEncountered,  -- Общее количество игроков
            stats.serversVisited > 0 and (stats.totalPlayersEncountered / stats.serversVisited) or 0,  -- Среднее
            hours, minutes,  -- Время работы
            os.date("%Y-%m-%d %H:%M:%S")  -- Текущая дата/время
        )
        writefile("adoptme_stats.txt", statsContent)  -- Записываем в файл
    end
end

-- Функция вывода статистики в лог
local function logStats()
    log(string.format(
        "[STATS] Серверов: %d | Всего игроков: %d | Среднее: %.1f игроков/сервер",
        stats.serversVisited,  -- Счетчик серверов
        stats.totalPlayersEncountered,  -- Счетчик игроков
        stats.serversVisited > 0 and (stats.totalPlayersEncountered / stats.serversVisited) or 0  -- Вычисляем среднее
    ))
end

-- Автоматическое сохранение лога и статистики каждые 30 секунд
task.spawn(function()  -- Создаем асинхронную задачу (отдельный поток)
    while true do  -- Бесконечный цикл
        task.wait(30)  -- Ждем 30 секунд
        saveLog()  -- Сохраняем лог
        saveStats()  -- Сохраняем статистику
    end
end)





-- ==================== АНТИ-АФК ДВИЖЕНИЕ ====================
-- Таблица с направлениями движения для создания круговой траектории
-- Бот будет двигаться по кругу, чтобы система не кикнула за неактивность
local DIRECTION_KEYS = {
    {Enum.KeyCode.W},  -- Вперед
    {Enum.KeyCode.W, Enum.KeyCode.D},  -- Вперед-вправо (диагональ)
    {Enum.KeyCode.D},  -- Вправо
    {Enum.KeyCode.D, Enum.KeyCode.S},  -- Назад-вправо (диагональ)
    {Enum.KeyCode.S},  -- Назад
    {Enum.KeyCode.S, Enum.KeyCode.A},  -- Назад-влево (диагональ)
    {Enum.KeyCode.A},  -- Влево
    {Enum.KeyCode.A, Enum.KeyCode.W},  -- Вперед-влево (диагональ)
}

-- Функция начала кругового движения на заданное время
local function startCircleMove(duration)
    log("[ANTI-AFK] Начинаю круговое движение...")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)  -- Зажимаем пробел (прыжок)
    local startTime = tick()  -- Запоминаем время старта (в секундах)
    local step = 1  -- Текущий шаг направления (1-8)
    task.spawn(function()  -- Создаем асинхронную задачу
        while tick() - startTime < duration do  -- Пока не прошло заданное время
            -- Нажимаем клавиши для текущего направления
            for _, k in DIRECTION_KEYS[step] do
                VirtualInputManager:SendKeyEvent(true, k, false, game)  -- Зажимаем клавишу
            end
            task.wait(0.1)  -- Держим клавишу 0.1 секунды
            -- Отпускаем клавиши
            for _, k in DIRECTION_KEYS[step] do
                VirtualInputManager:SendKeyEvent(false, k, false, game)  -- Отпускаем клавишу
            end
            step = step % 8 + 1  -- Переходим к следующему направлению (циклично 1-8)
        end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)  -- Отпускаем пробел
        log("[ANTI-AFK] Движение завершено")
    end)
end

-- Ожидание с периодическим анти-АФК движением
local function waitWithMovement(duration)
    local elapsed = 0  -- Счетчик прошедшего времени
    while elapsed < duration do  -- Пока не истекло нужное время
        local waitTime = math.min(10, duration - elapsed)  -- Ждем максимум 10 секунд
        task.wait(waitTime)  -- Выполняем ожидание
        elapsed = elapsed + waitTime  -- Увеличиваем счетчик

        if elapsed < duration then  -- Если еще есть время
            startCircleMove(3)  -- Двигаемся 3 секунды
            task.wait(3)  -- Ждем завершения движения
            elapsed = elapsed + 3  -- Добавляем 3 секунды к счетчику
        end
    end
end

--==================== ФУНКЦИЯ ОТПРАВКИ СООБЩЕНИЙ В ЧАТ ====================
-- Универсальная функция для отправки сообщений, работающая с обеими системами чата
local function sendChat(msg)
    task.spawn(function()  -- Запускаем в асинхронном потоке
        -- TextChatService (новая система чата Roblox)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then  -- Проверяем версию чата
            local ch = TextChatService.TextChannels.RBXGeneral  -- Получаем общий канал
            if ch then  -- Если канал найден
                pcall(function()  -- Защищенный вызов (чтобы не крашнуть скрипт при ошибке)
                    ch:SendAsync(msg)  -- Отправляем сообщение асинхронно
                end)
            end
        end

        -- Legacy chat fallback (старая система чата для обратной совместимости)
        local say = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")  -- Ищем систему чата
        if say then  -- Если нашли
            say = say:FindFirstChild("SayMessageRequest")  -- Получаем event для отправки
            if say then  -- Если event существует
                pcall(function()  -- Защищенный вызов
                    say:FireServer(msg, "All")  -- Отправляем на сервер (в канал "All")
                end)
            end
        end
    end)
end

-- ==================== ФУНКЦИЯ ПЕРЕКЛЮЧЕНИЯ СЕРВЕРОВ ====================
local function serverHop()
    log("[HOP] Начинаю переключение сервера...")
    saveLog()  -- Сохраняем лог перед переходом
    saveStats()  -- Сохраняем статистику перед переходом

    -- Проверяем доступность httprequest для API запросов
    if not httprequest then
        log("[HOP] httprequest недоступен! Использую простую телепортацию...")
        queueFunc('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')  -- Загружаем скрипт после телепортации
        local tpOk = pcall(function()  -- Защищенный вызов телепортации
            TeleportService:Teleport(PLACE_ID, player)  -- Телепортируем на случайный сервер игры
        end)
        if tpOk then
            log("[HOP] Простая телепортация запущена!")
            task.wait(999)  -- Ждем долго (пока не произойдет телепортация)
        end
        return
    end

    local cursor = ""  -- Курсор пагинации для API (для перехода между страницами)
    local maxPages = 30  -- Максимальное количество страниц для проверки
    local pagesChecked = 0  -- Счетчик проверенных страниц
    local searchStartTime = tick()  -- Время начала поиска
    local currentMinPlayers = MIN_PLAYERS_PREFERRED  -- Текущее минимальное требование игроков

    log("[HOP] Ищу серверы с " .. currentMinPlayers .. "+ игроков...")

    while pagesChecked < maxPages do  -- Цикл по страницам серверов
        -- Проверяем, не затянулся ли поиск
        local elapsedTime = tick() - searchStartTime  -- Сколько прошло времени
        if elapsedTime > SEARCH_TIMEOUT and currentMinPlayers ~= MIN_PLAYERS_FALLBACK then
            currentMinPlayers = MIN_PLAYERS_FALLBACK  -- Снижаем требования
            log("[HOP] Таймаут поиска! Снижаю требования до " .. currentMinPlayers .. "+ игроков...")
        end

        pagesChecked = pagesChecked + 1  -- Увеличиваем счетчик страниц
        task.wait(5)  -- Задержка для избежания rate limiting (ограничения запросов)

        -- Формируем URL для запроса списка серверов через Roblox API
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s",
            PLACE_ID,  -- ID игры
            cursor ~= "" and "&cursor=" .. cursor or ""  -- Добавляем курсор если есть
        )

        log("[HOP] Проверяю страницу " .. pagesChecked .. "...")

        -- Делаем HTTP запрос с защитой от ошибок
        local success, response = pcall(function()
            return httprequest({Url = url})  -- Выполняем GET запрос
        end)

        if not success then  -- Если запрос упал
            log("[HOP] Ошибка HTTP запроса: " .. tostring(response))
            task.wait(5)
            continue  -- Переходим к следующей итерации
        end

        if not response then  -- Если нет объекта ответа
            log("[HOP] Нет объекта ответа!")
            task.wait(5)
            continue
        end

        log("[HOP DEBUG] Код ответа: " .. tostring(response.StatusCode or "N/A"))

        -- Проверяем rate limiting (ограничение частоты запросов)
        if response.StatusCode == 429 then  -- Код 429 = Too Many Requests
            log("[HOP] Ограничение запросов! Жду 30 секунд...")
            task.wait(30)  -- Ждем 30 секунд
            continue  -- Переходим к следующей итерации
        end

        if not response.Body then  -- Если тело ответа пустое
            log("[HOP] Нет тела ответа! Rate-limited или заблокирован")
            task.wait(10)
            continue
        end

        -- Отладочная информация о полученном ответе
        log("[HOP DEBUG] Длина тела ответа: " .. #tostring(response.Body))
        log("[HOP DEBUG] Превью тела ответа: " .. tostring(response.Body):sub(1, 200))  -- Первые 200 символов

        -- Пытаемся распарсить JSON ответ
        local bodySuccess, body = pcall(function()
            return HttpService:JSONDecode(response.Body)  -- Декодируем JSON в Lua таблицу
        end)

        if not bodySuccess then  -- Если парсинг JSON не удался
            log("[HOP] Ошибка парсинга JSON: " .. tostring(body))
            task.wait(5)
            continue
        end

        if not body or not body.data then  -- Если в ответе нет поля data
            log("[HOP] В ответе отсутствует поле 'data'!")
            log("[HOP DEBUG] Ключи в body: " .. table.concat(body and {table.unpack(body)} or {}, ", "))
            task.wait(5)
            continue
        end

        -- Ищем подходящие серверы (любой сервер, кроме текущего)
        log("[HOP DEBUG] Всего серверов в ответе: " .. (body.data and #body.data or 0))
        log("[HOP DEBUG] Текущее требование: " .. currentMinPlayers .. "+ игроков")

        local servers = {}  -- Массив подходящих серверов
        local serverStats = {}  -- Для отладки - статистика по игрокам
        for _, server in pairs(body.data or {}) do  -- Перебираем все серверы из API
            local players = server.playing or 0  -- Количество игроков на сервере
            table.insert(serverStats, players)  -- Добавляем в статистику

            -- Проверяем, подходит ли сервер по критериям
            if server.id ~= game.JobId  -- Не текущий сервер
                and players >= currentMinPlayers  -- Минимум игроков
                and players <= MAX_PLAYERS_ALLOWED then  -- Максимум игроков
                table.insert(servers, server)  -- Добавляем в список подходящих
            end
        end

        -- Показываем распределение игроков по серверам (для отладки)
        if #serverStats > 0 then
            table.sort(serverStats)  -- Сортируем по возрастанию
            log("[HOP DEBUG] Количество игроков: мин=" .. serverStats[1] .. " макс=" .. serverStats[#serverStats] .. " (первые 10: " .. table.concat({table.unpack(serverStats, 1, math.min(10, #serverStats))}, ",") .. ")")
        end

        log("[HOP] Найдено " .. #servers .. " подходящих серверов на этой странице")

        if #servers > 0 then
            -- Перемешиваем список для случайности (алгоритм Fisher-Yates)
            for i = #servers, 2, -1 do
                local j = math.random(i)  -- Случайный индекс от 1 до i
                servers[i], servers[j] = servers[j], servers[i]  -- Меняем местами
            end

            -- Пробуем серверы по очереди
            for _, selected in ipairs(servers) do  -- Перебираем перемешанный список
                log("[HOP] Пробую сервер: " .. selected.id)

                queueFunc('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')  -- Загружаем скрипт после телепортации

                -- Пытаемся телепортироваться на конкретный сервер
                local tpOk, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, selected.id, player)  -- Телепорт на конкретный JobId
                end)

                if tpOk then  -- Если телепортация успешна
                    log("[HOP] Телепортация запущена!")
                    task.wait(999)  -- Ждем долго (пока не произойдет переход)
                    return  -- Выходим из функции
                else  -- Если телепортация не удалась
                    log("[HOP] Не удалось: " .. tostring(err) .. ", пробую следующий...")
                    task.wait(5)  -- Задержка перед следующей попыткой
                    -- Продолжаем цикл, пробуем следующий сервер
                end
            end

            log("[HOP] Все серверы на этой странице не подошли, пробую следующую страницу...")
        end
    end  -- Конец цикла while по страницам

    -- Если после всех попыток не нашли подходящий сервер
    log("[HOP] Не смог найти сервер после проверки " .. pagesChecked .. " страниц")
    log("[HOP] Использую запасной вариант: случайный сервер...")

    -- Запасной вариант: просто телепортируемся на случайный сервер (Roblox сам выберет)
    queueFunc('loadstring(game:HttpGet("' .. SCRIPT_URL .. '"))()')  -- Загружаем скрипт после телепортации

    local tpOk, err = pcall(function()  -- Защищенный вызов
        TeleportService:Teleport(PLACE_ID, player)  -- Телепортация без указания JobId (случайный сервер)
    end)

    if tpOk then  -- Если телепортация запустилась
        log("[HOP] Случайная телепортация запущена! Жду...")
        task.wait(999)  -- Ждем долго
    else  -- Если даже это не сработало
        log("[HOP] Случайная телепортация не удалась: " .. tostring(err))
        log("[HOP] Жду 30 секунд перед повтором...")
        task.wait(30)  -- Задержка перед повтором
    end
end

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
log("=== РЕКЛАМНЫЙ БОТ ADOPT ME ЗАПУЩЕН ===")
log("=== РЕКЛАМА RBLX.PW ===")
log("[STATS] Отслеживание статистики включено - сохранение в adoptme_stats.txt")

-- Ждем загрузки игры (но не ждем спавна персонажа в Adopt Me)
log("Жду загрузки игры...")
task.wait(15)  -- Просто ждем 15 секунд для загрузки UI
log("Игра загружена! Чат готов!")

-- Пытаемся автоматически нажать кнопку Play, если она есть
task.spawn(function()  -- Асинхронная задача
    task.wait(3)  -- Ждем 3 секунды
    local success = pcall(function()  -- Защищенный вызов
        local playerGui = player:WaitForChild("PlayerGui", 5)  -- Получаем GUI игрока (таймаут 5 сек)
        if playerGui then
            -- Перебираем все GUI элементы
            for _, gui in pairs(playerGui:GetDescendants()) do
                -- Ищем кнопку Play (по имени или тексту)
                if gui:IsA("TextButton") and (gui.Name == "PlayButton" or gui.Text:find("грать")) then
                    log("[AUTO] Нашел кнопку Play, нажимаю...")
                    for i = 1, 3 do  -- Нажимаем 3 раза для надежности
                        gui.Activated:Fire()  -- Симулируем клик
                        task.wait(0.5)  -- Задержка между кликами
                    end
                    break  -- Прерываем цикл после нахождения кнопки
                end
            end
        end
    end)
    if success then
        log("[AUTO] Попытка автонажатия кнопки Play выполнена")
    end
end)

-- Счетчик серверов для паттерна работы
local serverCount = 0

-- Основной цикл рекламирования
local function advertiseLoop()
    serverCount = serverCount + 1  -- Увеличиваем счетчик серверов
    local messagesToSend = 3  -- Всегда отправляем 3 сообщения

    -- Обновляем статистику
    stats.serversVisited = stats.serversVisited + 1  -- Увеличиваем счетчик посещенных серверов
    local currentPlayers = #Players:GetPlayers()  -- Количество игроков на текущем сервере
    stats.totalPlayersEncountered = stats.totalPlayersEncountered + currentPlayers  -- Добавляем к общему счету

    -- Каждый 3-й сервер: удвоенные задержки и точка в начале (для обхода фильтров)
    local isSlowServer = (serverCount % 3 == 0)  -- Проверяем, кратен ли счетчик 3
    local initialDelay = isSlowServer and 10 or 5  -- 10 сек на каждом 3-м, 5 сек обычно
    local messageDelay = isSlowServer and 4 or 2   -- 4 сек на каждом 3-м, 2 сек обычно
    local dotPrefix = isSlowServer and ". " or ""  -- Добавляем точку на каждом 3-м сервере

    log("[MAIN] Сервер #" .. serverCount .. " | Игроков: " .. currentPlayers .. (isSlowServer and " (МЕДЛЕННЫЙ РЕЖИМ - 2x задержки + точка)" or " (НОРМАЛЬНЫЙ РЕЖИМ)"))
    logStats()  -- Показываем статистику каждый сервер
    log("[MAIN] Жду " .. initialDelay .. " секунд после входа на сервер...")
    task.wait(initialDelay)  -- Ожидание после входа

    log("[MAIN] Отправляю " .. messagesToSend .. " сообщений, затем переключаюсь...")

    -- Отправляем 3 случайных сообщения с соответствующей задержкой
    for i = 1, messagesToSend do  -- Цикл от 1 до 3
        local message = dotPrefix .. MESSAGES[math.random(#MESSAGES)]  -- Выбираем случайное сообщение и добавляем префикс
        log("[CHAT] Отправляю сообщение " .. i .. "/" .. messagesToSend .. ": " .. message)
        sendChat(message)  -- Отправляем в чат
        task.wait(messageDelay)  -- Задержка между сообщениями (2 или 4 сек)
    end

    log("[MAIN] Все сообщения отправлены! Жду 5 секунд перед переключением сервера...")
    task.wait(5)  -- Даем игрокам время увидеть сообщения

    log("[MAIN] Переключаюсь на новый сервер...")
    serverHop()  -- Вызываем функцию смены сервера
end

-- Запускаем основной цикл с защитой от падения
while true do  -- Бесконечный цикл
    advertiseLoop()  -- Выполняем цикл рекламирования
    log("[MAIN] Перезапускаю цикл...")  -- Если функция вернулась (не должна), перезапускаем
    task.wait(2)  -- Задержка перед перезапуском
end