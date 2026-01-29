-- ==================== ПОЛУЧЕНИЕ СПИСКА СЕРВЕРОВ ====================
-- Отдельный модуль для запроса и отображения списка серверов Adopt Me
-- Используется для тестирования и отладки работы с Roblox API
-- ============================================================================

-- ==================== НАСТРОЙКИ ====================
local PLACE_ID = 920587237  -- ID игры Adopt Me
local MAX_PAGES = 5  -- Сколько страниц загрузить (каждая страница = до 100 серверов)

-- ==================== СЕРВИСЫ ====================
local HttpService = game:GetService("HttpService")  -- Для работы с JSON

-- Функция HTTP запроса (зависит от эксплоита)
local httprequest = http and http.request

-- ==================== ПРОВЕРКА ДОСТУПНОСТИ ====================
if not httprequest then
    warn("❌ ОШИБКА: httprequest недоступен в вашем эксплоите!")
    warn("Этот скрипт требует эксплоит с поддержкой HTTP запросов")
    warn("Попробуйте: Synapse X, Script-Ware, Electron")
    return
end

print("✅ httprequest доступен, начинаю запрос серверов...")
print("=" .. string.rep("=", 60))

-- ==================== ОСНОВНАЯ ФУНКЦИЯ ====================
local function getServerList()
    local cursor = ""  -- Курсор для пагинации (переход между страницами)
    local allServers = {}  -- Массив всех найденных серверов
    local totalServersFound = 0  -- Счетчик серверов

    -- Проходим по страницам
    for page = 1, MAX_PAGES do
        print(string.format("\n📄 СТРАНИЦА %d/%d", page, MAX_PAGES))
        print("-" .. string.rep("-", 60))

        -- Формируем URL для API запроса
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s",
            PLACE_ID,  -- ID игры
            cursor ~= "" and "&cursor=" .. cursor or ""  -- Курсор для следующей страницы
        )

        print("🌐 URL: " .. url)

        -- Делаем HTTP запрос
        local success, response = pcall(function()
            return httprequest({
                Url = url,
                Method = "GET"
            })
        end)

        -- Проверяем успешность запроса
        if not success then
            warn("❌ Ошибка HTTP запроса: " .. tostring(response))
            break
        end

        if not response or not response.Body then
            warn("❌ Пустой ответ от API")
            break
        end

        -- Проверяем код ответа
        print("📊 Код ответа: " .. tostring(response.StatusCode or "N/A"))

        -- Проверка на rate limiting
        if response.StatusCode == 429 then
            warn("⏳ Rate limit! API ограничил частоту запросов")
            warn("Подождите 60 секунд и попробуйте снова")
            break
        end

        -- Парсим JSON
        local bodySuccess, body = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if not bodySuccess then
            warn("❌ Ошибка парсинга JSON: " .. tostring(body))
            break
        end

        if not body or not body.data then
            warn("❌ В ответе отсутствует поле 'data'")
            break
        end

        -- Обрабатываем серверы на текущей странице
        local serversOnPage = #body.data
        totalServersFound = totalServersFound + serversOnPage

        print(string.format("✅ Найдено серверов на странице: %d", serversOnPage))
        print("")

        -- Статистика игроков на текущей странице
        local playerCounts = {}

        -- Перебираем серверы
        for index, server in ipairs(body.data) do
            local players = server.playing or 0
            local maxPlayers = server.maxPlayers or 0
            local serverId = server.id or "unknown"
            local ping = server.ping or 0

            table.insert(playerCounts, players)
            table.insert(allServers, server)

            -- Определяем статус сервера
            local status = ""
            if players == 0 then
                status = "🔴 Пустой"
            elseif players < 5 then
                status = "🟡 Мало игроков"
            elseif players >= 5 and players < 15 then
                status = "🟢 Нормальный"
            else
                status = "🔵 Полный"
            end

            -- Выводим информацию о сервере
            print(string.format(
                "#%d | %s | Игроков: %d/%d | Пинг: %dмс | ID: %s",
                (page - 1) * 100 + index,
                status,
                players,
                maxPlayers,
                ping,
                serverId:sub(1, 20)  -- Обрезаем ID для читаемости
            ))
        end

        -- Статистика по игрокам на странице
        if #playerCounts > 0 then
            table.sort(playerCounts)
            local minPlayers = playerCounts[1]
            local maxPlayers = playerCounts[#playerCounts]
            local avgPlayers = 0
            for _, count in ipairs(playerCounts) do
                avgPlayers = avgPlayers + count
            end
            avgPlayers = math.floor(avgPlayers / #playerCounts)

            print("")
            print(string.format("📊 Статистика страницы: мин=%d | макс=%d | среднее=%d",
                minPlayers, maxPlayers, avgPlayers))
        end

        -- Получаем курсор для следующей страницы
        cursor = body.nextPageCursor or ""

        if cursor == "" then
            print("\n⚠️ Больше нет страниц (достигнут конец списка)")
            break
        end

        -- Задержка между запросами (чтобы не получить rate limit)
        if page < MAX_PAGES then
            print("\n⏳ Жду 2 секунды перед следующим запросом...")
            task.wait(2)
        end
    end

    -- ==================== ИТОГОВАЯ СТАТИСТИКА ====================
    print("\n" .. string.rep("=", 60))
    print("📈 ИТОГОВАЯ СТАТИСТИКА")
    print(string.rep("=", 60))
    print(string.format("Всего найдено серверов: %d", totalServersFound))

    if #allServers > 0 then
        -- Собираем статистику по всем серверам
        local allPlayerCounts = {}
        local emptyServers = 0
        local lowPopServers = 0  -- < 5 игроков
        local goodServers = 0     -- 5-15 игроков
        local fullServers = 0     -- > 15 игроков

        for _, server in ipairs(allServers) do
            local players = server.playing or 0
            table.insert(allPlayerCounts, players)

            if players == 0 then
                emptyServers = emptyServers + 1
            elseif players < 5 then
                lowPopServers = lowPopServers + 1
            elseif players < 15 then
                goodServers = goodServers + 1
            else
                fullServers = fullServers + 1
            end
        end

        table.sort(allPlayerCounts)

        local totalPlayers = 0
        for _, count in ipairs(allPlayerCounts) do
            totalPlayers = totalPlayers + count
        end

        print(string.format("\nРаспределение серверов по игрокам:"))
        print(string.format("  🔴 Пустые (0 игроков): %d (%.1f%%)",
            emptyServers, emptyServers / #allServers * 100))
        print(string.format("  🟡 Мало игроков (<5): %d (%.1f%%)",
            lowPopServers, lowPopServers / #allServers * 100))
        print(string.format("  🟢 Нормальные (5-15): %d (%.1f%%)",
            goodServers, goodServers / #allServers * 100))
        print(string.format("  🔵 Полные (>15): %d (%.1f%%)",
            fullServers, fullServers / #allServers * 100))

        print(string.format("\nОбщая статистика игроков:"))
        print(string.format("  Минимум на сервере: %d", allPlayerCounts[1]))
        print(string.format("  Максимум на сервере: %d", allPlayerCounts[#allPlayerCounts]))
        print(string.format("  Среднее на сервер: %.1f", totalPlayers / #allServers))
        print(string.format("  Всего игроков онлайн: %d", totalPlayers))

        print(string.format("\nПервые 10 серверов по игрокам: %s",
            table.concat({table.unpack(allPlayerCounts, 1, math.min(10, #allPlayerCounts))}, ", ")))
    end

    print("\n" .. string.rep("=", 60))
    print("✅ СКАНИРОВАНИЕ ЗАВЕРШЕНО")
    print(string.rep("=", 60))
end

-- ==================== ЗАПУСК ====================
print("\n🚀 ЗАПУСК СКАНЕРА СЕРВЕРОВ ADOPT ME")
print("Место: Adopt Me (ID: " .. PLACE_ID .. ")")
print("Страниц для загрузки: " .. MAX_PAGES)
print("")

-- Запускаем функцию
local success, err = pcall(getServerList)

if not success then
    warn("\n❌ КРИТИЧЕСКАЯ ОШИБКА:")
    warn(tostring(err))
end
