

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")


local queueFunc = queueonteleport
local httprequest = http_request or http.request or request or (syn and syn.request)

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")

local Tools = {
    apiUrl = "",
    apiKey = "",
    minPlayersPreferred = 5,
    minPlayersFallback = 3,
    maxPlayersAllowed = 15,
    searchTimeout = 60,
    teleportCooldown = 15,
    placeId = 920587237,
    scriptUrl = "",
    enabled = true,  -- Состояние скрипта (включен/выключен)
    gui = nil,       -- Ссылка на GUI элемент
}

-- Создание GUI с переключателем On/Off
function Tools.createToggleGUI()
    -- Удаляем старый GUI если существует
    local oldGui = playerGui:FindFirstChild("BotToggleGUI")
    if oldGui then
        oldGui:Destroy()
    end

    -- Создаем ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BotToggleGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Создаем Frame (фон)
    local frame = Instance.new("Frame")
    frame.Name = "ToggleFrame"
    frame.Size = UDim2.new(0, 150, 0, 60)
    frame.Position = UDim2.new(0, 10, 1, -70)  -- Слева снизу
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    frame.Parent = screenGui

    -- Скругленные углы
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Текст "Bot Status"
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "Bot Status"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    -- Кнопка переключения
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 130, 0, 25)
    toggleButton.Position = UDim2.new(0, 10, 0, 28)
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  -- Зеленый (ON)
    toggleButton.Text = "ON"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 16
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = toggleButton

    -- Обработчик клика
    toggleButton.MouseButton1Click:Connect(function()
        Tools.enabled = not Tools.enabled

        if Tools.enabled then
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)  -- Зеленый
            toggleButton.Text = "ON"
            Tools.sendMessageAPI("[GUI] Bot включен")
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)  -- Красный
            toggleButton.Text = "OFF"
            Tools.sendMessageAPI("[GUI] Bot выключен")
        end
    end)

    -- Делаем фрейм перетаскиваемым
    local dragging = false
    local dragStart = nil
    local startPos = nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    screenGui.Parent = playerGui
    Tools.gui = screenGui

    return screenGui
end

-- Проверка, включен ли бот
function Tools.isEnabled()
    return Tools.enabled
end

-- Инициализация модуля с API параметрами
function Tools.setup(apiUrl, apiKey, minPlayersPreferred, minPlayersFallback, maxPlayersAllowed, searchTimeout, teleportCooldown, placeId, scriptUrl)
    if apiUrl then Tools.apiUrl = apiUrl end
    if apiKey then Tools.apiKey = apiKey end
    if minPlayersPreferred then Tools.minPlayersPreferred = minPlayersPreferred end
    if minPlayersFallback then Tools.minPlayersFallback = minPlayersFallback end
    if maxPlayersAllowed then Tools.maxPlayersAllowed = maxPlayersAllowed end
    if searchTimeout then Tools.searchTimeout = searchTimeout end
    if teleportCooldown then Tools.teleportCooldown = teleportCooldown end
    if placeId then Tools.placeId = placeId end
    if scriptUrl then Tools.scriptUrl = scriptUrl end

    -- Создаем GUI
    Tools.createToggleGUI()

    return Tools
end

-- Ожидание появления кнопки PlayButton (максимум 60 секунд)
function Tools.waitForPlayButton(timeout)
    timeout = timeout or 60
    local startTime = tick()

    while tick() - startTime < timeout do
        if Tools.isPlayButtonVisible() then
            return true
        end
        task.wait(0.5)
    end

    return false
end

-- Проверка видимости кнопки PlayButton
function Tools.isPlayButtonVisible()
    local newsApp = playerGui and playerGui:FindFirstChild("NewsApp")

    if not newsApp or newsApp.Enabled == false then
        return false
    end

    local enclosingFrame = newsApp:FindFirstChild("EnclosingFrame")
    local mainFrame = enclosingFrame and enclosingFrame:FindFirstChild("MainFrame")
    local buttons = mainFrame and mainFrame:FindFirstChild("Buttons")
    local playButton = buttons and buttons:FindFirstChild("PlayButton")

    return playButton ~= nil
end

-- Клик по кнопке PlayButton
function Tools.clickPlayButton()
    local newsApp = playerGui and playerGui:FindFirstChild("NewsApp")
    if not newsApp or newsApp.Enabled == false then
        return false
    end

    local enclosingFrame = newsApp:FindFirstChild("EnclosingFrame")
    local mainFrame = enclosingFrame and enclosingFrame:FindFirstChild("MainFrame")
    local buttons = mainFrame and mainFrame:FindFirstChild("Buttons")
    local playButton = buttons and buttons:FindFirstChild("PlayButton")

    if not playButton then
        return false
    end

    local absolutePos = playButton.AbsolutePosition
    local absoluteSize = playButton.AbsoluteSize
    local guiInset = GuiService:GetGuiInset()

    local centerX = absolutePos.X + absoluteSize.X / 2
    local centerY = absolutePos.Y + absoluteSize.Y / 2 + guiInset.Y

    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)

    return true
end


-- Отправка сообщения в чат Roblox (локально)
function Tools.sendChat(msg)
    task.spawn(function()  -- Запускаем в асинхронном потоке
        local sent = false

        -- TextChatService (новая система чата Roblox)
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService.TextChannels.RBXGeneral
            if ch then
                local success = pcall(function()
                    ch:SendAsync(msg)
                end)
                if success then
                    sent = true
                end
            end
        end

        -- Legacy chat fallback (старая система чата для обратной совместимости)
        if not sent then
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local say = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if say then
                say = say:FindFirstChild("SayMessageRequest")
                if say then
                    local success = pcall(function()
                        say:FireServer(msg, "All")
                    end)
                    if success then
                        sent = true
                    end
                end
            end
        end

        -- Отправляем уведомление только один раз
        if sent then
            Tools.sendMessageAPI("[CHAT] Sent: " .. msg)
        end
    end)
end

-- Отправка сообщения через API сервер
function Tools.sendMessageAPI(message)
    if not httprequest then
        warn("HTTP request function not available")
        return false
    end

    local success, result = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/send_chat?message=" .. HttpService:UrlEncode(message),
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and result.StatusCode == 200 then
        print("✓ Сообщение отправлено через API")
        return true
    else
        warn("✗ Ошибка отправки через API:", result and result.StatusCode or "unknown")
        return false
    end
end

-- Получить список посещенных серверов
function Tools.getVisitedServers(hours)
    hours = hours or 24
    if not httprequest then
        warn("[SERVERS] HTTP функция недоступна!")
        return {}
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/servers/visited?hours=" .. hours,
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.success then
            Tools.sendMessageAPI("[SERVERS] Загружено " .. data.count .. " посещенных серверов")
            return data.servers
        end
    else
        warn("[SERVERS] Ошибка загрузки серверов:", response and response.StatusCode or "unknown")
    end

    return {}
end

-- Отметить сервер как посещенный
function Tools.markServerVisited(serverId, userId, placeId)
    if not httprequest then
        warn("[SERVERS] HTTP функция недоступна!")
        return false
    end

    local url = Tools.apiUrl .. "/servers/visit?server_id=" .. HttpService:UrlEncode(serverId)
    if userId then
        url = url .. "&user_id=" .. HttpService:UrlEncode(userId)
    end
    if placeId then
        url = url .. "&place_id=" .. tostring(placeId)
    end

    local success, response = pcall(function()
        return httprequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        Tools.sendMessageAPI("[SERVERS] Сервер отмечен как посещенный: " .. serverId)
        return true
    else
        warn("[SERVERS] Ошибка записи сервера:", response and response.StatusCode or "unknown")
        return false
    end
end

-- Получить сохраненный курсор
function Tools.getSavedCursor(placeId)
    if not httprequest then
        return nil
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/cursor/get?place_id=" .. tostring(placeId),
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.success and data.cursor then
            return {cursor = data.cursor, pageNumber = data.page_number}
        end
    end

    return nil
end

-- Сохранить курсор
function Tools.saveCursor(placeId, cursor, pageNumber)
    if not httprequest then
        return false
    end

    local url = Tools.apiUrl .. "/cursor/save?place_id=" .. tostring(placeId) ..
                "&cursor=" .. HttpService:UrlEncode(cursor) ..
                "&page_number=" .. tostring(pageNumber)

    local success, response = pcall(function()
        return httprequest({
            Url = url,
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    return success and response.StatusCode == 200
end

-- Очистить курсор
function Tools.clearCursor(placeId)
    if not httprequest then
        return false
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/cursor/clear?place_id=" .. tostring(placeId),
            Method = "DELETE",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    return success and response.StatusCode == 200
end

-- ============================================
-- ФУНКЦИИ ДЛЯ РАБОТЫ С СООБЩЕНИЯМИ
-- ============================================

-- Получить обычное сообщение (камуфляж)
function Tools.getCasualMessage()
    if not httprequest then
        return "hi"
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/messages/casual",
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if ok and data.success then
            return data.message
        end
    end

    return "hi"
end

-- Получить рекламное сообщение из базы
function Tools.getAdMessage()
    if not httprequest then
        warn("[AD] HTTP функция недоступна!")
        return nil
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/messages/get",
            Method = "GET",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    if success and response.StatusCode == 200 then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)

        if ok and data.success then
            return {
                id = data.id,
                message = data.message
            }
        end
    end

    return nil
end

-- Отметить сообщение как использованное (запускает период остывания)
function Tools.markAdMessageUsed(messageId)
    if not httprequest then
        return false
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/messages/used/" .. tostring(messageId),
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    return success and response.StatusCode == 200
end

-- Деактивировать сообщение (если заблокировано фильтром)
function Tools.deactivateAdMessage(messageId)
    if not httprequest then
        return false
    end

    local success, response = pcall(function()
        return httprequest({
            Url = Tools.apiUrl .. "/messages/deactivate/" .. tostring(messageId),
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. Tools.apiKey,
                ["Content-Type"] = "application/json"
            }
        })
    end)

    return success and response.StatusCode == 200
end

-- ============================================
-- ФУНКЦИИ ДЛЯ ПАРСИНГА ЧАТА
-- ============================================

-- Буфер для хранения последних сообщений чата
Tools.chatMessageBuffer = {}
Tools.chatBufferMaxSize = 50
Tools.chatListenerConnected = false

-- Подключить слушатель чата (вызывается один раз)
function Tools.connectChatListener()
    if Tools.chatListenerConnected then
        return true
    end

    local TextChatService = game:GetService("TextChatService")

    -- Пробуем подключиться к TextChatService (новый чат Roblox)
    local success = pcall(function()
        local channels = TextChatService:WaitForChild("TextChannels", 5)
        if channels then
            local rbxGeneral = channels:FindFirstChild("RBXGeneral")
            if rbxGeneral then
                rbxGeneral.MessageReceived:Connect(function(textChatMessage)
                    local messageText = textChatMessage.Text or ""
                    local senderName = "Unknown"

                    if textChatMessage.TextSource then
                        local senderId = textChatMessage.TextSource.UserId
                        local senderPlayer = Players:GetPlayerByUserId(senderId)
                        if senderPlayer then
                            senderName = senderPlayer.Name
                        end
                    end

                    -- Добавляем в буфер
                    table.insert(Tools.chatMessageBuffer, 1, {
                        text = messageText,
                        sender = senderName,
                        timestamp = os.time()
                    })

                    -- Ограничиваем размер буфера
                    while #Tools.chatMessageBuffer > Tools.chatBufferMaxSize do
                        table.remove(Tools.chatMessageBuffer)
                    end
                end)

                Tools.chatListenerConnected = true
                Tools.sendMessageAPI("[CHAT_LISTENER] Подключен к RBXGeneral (TextChatService)")
                return
            end
        end
    end)

    -- Fallback: Legacy chat system
    if not Tools.chatListenerConnected then
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")

        if chatEvents then
            local onMessage = chatEvents:FindFirstChild("OnMessageDoneFiltering")
            if onMessage then
                onMessage.OnClientEvent:Connect(function(messageData)
                    local messageText = messageData.Message or messageData.FilteredMessage or ""
                    local senderName = messageData.FromSpeaker or "Unknown"

                    table.insert(Tools.chatMessageBuffer, 1, {
                        text = messageText,
                        sender = senderName,
                        timestamp = os.time()
                    })

                    while #Tools.chatMessageBuffer > Tools.chatBufferMaxSize do
                        table.remove(Tools.chatMessageBuffer)
                    end
                end)

                Tools.chatListenerConnected = true
                Tools.sendMessageAPI("[CHAT_LISTENER] Подключен к LegacyChat")
            end
        end
    end

    if not Tools.chatListenerConnected then
        Tools.sendMessageAPI("[CHAT_LISTENER] ОШИБКА: Не удалось подключиться к чату!")
    end

    return Tools.chatListenerConnected
end

-- Получить последние сообщения из буфера
function Tools.getRecentChatMessages(count)
    count = count or 10

    -- Подключаем слушатель если ещё не подключен
    if not Tools.chatListenerConnected then
        Tools.connectChatListener()
    end

    local messages = {}
    for i = 1, math.min(count, #Tools.chatMessageBuffer) do
        table.insert(messages, Tools.chatMessageBuffer[i].text)
    end

    Tools.sendMessageAPI("[CHAT_PARSE] Сообщений в буфере: " .. #Tools.chatMessageBuffer .. ", возвращаю: " .. #messages)

    -- Логируем сообщения для диагностики
    for i, msg in ipairs(messages) do
        local shortMsg = #msg > 60 and (msg:sub(1, 60) .. "...") or msg
        Tools.sendMessageAPI("[CHAT_PARSE] " .. i .. ": " .. shortMsg)
    end

    return messages
end

-- Проверить, было ли сообщение зафильтровано (содержит много ###)
function Tools.isMessageFiltered(messages, hashThreshold)
    hashThreshold = hashThreshold or 3

    Tools.sendMessageAPI("[FILTER_CHECK] Проверяю " .. #messages .. " сообщений на фильтрацию (порог: " .. hashThreshold .. "+ символов #)")

    for idx, msg in ipairs(messages) do
        -- Считаем количество последовательных #
        local hashCount = 0
        local maxConsecutive = 0

        for i = 1, #msg do
            local char = msg:sub(i, i)
            if char == "#" then
                hashCount = hashCount + 1
                if hashCount > maxConsecutive then
                    maxConsecutive = hashCount
                end
            else
                hashCount = 0
            end
        end

        if maxConsecutive > 0 then
            Tools.sendMessageAPI("[FILTER_CHECK] Сообщение " .. idx .. " содержит " .. maxConsecutive .. " подряд символов #")
        end

        if maxConsecutive > hashThreshold then
            Tools.sendMessageAPI("[FILTER_CHECK] ОБНАРУЖЕНА ФИЛЬТРАЦИЯ в сообщении " .. idx)
            return true, msg
        end
    end

    Tools.sendMessageAPI("[FILTER_CHECK] Фильтрация не обнаружена")
    return false, nil
end

-- Проверить фильтрацию после отправки рекламы и деактивировать если нужно
function Tools.checkAndDeactivateIfFiltered(adMessageId, waitTime)
    waitTime = waitTime or 2

    Tools.sendMessageAPI("[FILTER] Начинаю проверку фильтрации для ID:" .. tostring(adMessageId) .. ", жду " .. waitTime .. " сек...")

    -- Ждем пока сообщение появится в чате
    task.wait(waitTime)

    -- Получаем последние 10 сообщений
    local recentMessages = Tools.getRecentChatMessages(10)

    Tools.sendMessageAPI("[FILTER] Получено сообщений для анализа: " .. #recentMessages)

    if #recentMessages == 0 then
        Tools.sendMessageAPI("[FILTER] ПРЕДУПРЕЖДЕНИЕ: Не удалось получить сообщения из чата!")
        return false
    end

    -- Проверяем на фильтрацию
    local wasFiltered, filteredMsg = Tools.isMessageFiltered(recentMessages, 3)

    if wasFiltered then
        Tools.sendMessageAPI("[FILTER] !!! ФИЛЬТРАЦИЯ ОБНАРУЖЕНА !!!")
        Tools.sendMessageAPI("[FILTER] Зафильтрованное сообщение: " .. (filteredMsg or "unknown"))

        -- Деактивируем сообщение
        if adMessageId then
            local success = Tools.deactivateAdMessage(adMessageId)
            if success then
                Tools.sendMessageAPI("[FILTER] Сообщение ID:" .. adMessageId .. " ДЕАКТИВИРОВАНО")
            else
                Tools.sendMessageAPI("[FILTER] ОШИБКА деактивации сообщения ID:" .. adMessageId)
            end
        end

        return true
    else
        Tools.sendMessageAPI("[FILTER] Сообщение прошло без фильтрации")
    end

    return false
end


function Tools.serverHop()
    if not httprequest then
        warn("[HOP] HTTP функция недоступна!")
        return false
    end

    Tools.sendMessageAPI("[HOP] Начинаю переключение сервера...")

    -- Загружаем список посещенных серверов за последние 24 часа
    local visitedServers = Tools.getVisitedServers(24)
    local visitedSet = {}
    for _, serverId in ipairs(visitedServers) do
        visitedSet[serverId] = true
    end

    -- Пытаемся загрузить сохраненный курсор
    local savedCursor = Tools.getSavedCursor(Tools.placeId)
    local cursor = ""
    local pagesChecked = 1
    local lastSavedCursor = ""  -- Отслеживаем последний сохраненный курсор

    if savedCursor then
        cursor = savedCursor.cursor
        pagesChecked = savedCursor.pageNumber
        lastSavedCursor = cursor
        Tools.sendMessageAPI("[HOP] Продолжаю с сохраненной страницы " .. (pagesChecked + 1))
    else
        Tools.sendMessageAPI("[HOP] Начинаю с первой страницы")
    end

    local searchStartTime = tick()
    local currentMinPlayers = Tools.minPlayersPreferred
    local consecutiveRateLimits = 0
    Tools.sendMessageAPI("[HOP] Ищу серверы с " .. currentMinPlayers .. "+ игроков. Максимальное количество игроков: " .. Tools.maxPlayersAllowed)

    while true do
        -- Проверяем, включен ли бот
        if not Tools.isEnabled() then
            Tools.sendMessageAPI("[HOP] Остановлено пользователем")
            return false
        end

        -- Проверяем таймаут
        local elapsedTime = tick() - searchStartTime
        if elapsedTime > Tools.searchTimeout and currentMinPlayers ~= Tools.minPlayersFallback then
            currentMinPlayers = Tools.minPlayersFallback
            Tools.sendMessageAPI("[HOP] Снижаю требования до " .. currentMinPlayers .. "+ игроков...")
        end

        task.wait(5)

        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true%s",
            Tools.placeId,
            cursor ~= "" and "&cursor=" .. cursor or ""
        )

        Tools.sendMessageAPI("[HOP] Страница " .. pagesChecked .. "...")

        local success, response = pcall(function()
            return httprequest({Url = url})
        end)

        if success and response.StatusCode == 200 then
            consecutiveRateLimits = 0 -- Сброс счетчика при успешном запросе
            local data = HttpService:JSONDecode(response.Body)

            -- Ищем подходящий сервер
            for _, server in pairs(data.data) do
                local playerCount = server.playing
                local maxPlayers = server.maxPlayers
                local serverId = server.id

                -- Проверяем условия: достаточно игроков, есть запас мест, не текущий сервер, не был посещен
                -- Оставляем минимум 5 свободных мест для надежной телепортации
                local freeSlots = maxPlayers - playerCount
                local notVisited = not visitedSet[serverId]

                if playerCount >= currentMinPlayers and
                   freeSlots >= 10 and
                   playerCount <= Tools.maxPlayersAllowed and
                   serverId ~= game.JobId and
                   notVisited then

                    Tools.sendMessageAPI("[HOP] Найден сервер: " .. playerCount .. "/" .. maxPlayers .. " игроков (свободно: " .. freeSlots .. ")")

                    -- Отмечаем сервер как посещенный
                    Tools.markServerVisited(serverId, tostring(player.UserId), Tools.placeId)

                    -- Сохраняем текущий курсор перед телепортацией только если он изменился
                    if cursor ~= "" and cursor ~= lastSavedCursor then
                        Tools.saveCursor(Tools.placeId, cursor, pagesChecked)
                        Tools.sendMessageAPI("[HOP] Курсор сохранен для следующего запуска")
                        lastSavedCursor = cursor
                    end

                    -- Телепортация
                    local teleportSuccess = pcall(function()
                        queueFunc('loadstring(game:HttpGet("' .. Tools.scriptUrl .. '"))()')
                        TeleportService:TeleportToPlaceInstance(Tools.placeId, serverId, player)
                    end)

                    if teleportSuccess then
                        Tools.sendMessageAPI("[HOP] Телепортация...")
                        return true
                    else
                        warn("[HOP] Ошибка телепортации, продолжаю поиск...")
                    end
                elseif visitedSet[serverId] and playerCount >= currentMinPlayers then
                    -- Сервер уже был посещен, пропускаем
                    -- Не логируем каждый пропуск, чтобы не спамить
                end
            end

            -- Обновляем курсор для следующей страницы
            if data.nextPageCursor then
                cursor = data.nextPageCursor
                -- Сохраняем курсор для следующей попытки только если он изменился
                if cursor ~= lastSavedCursor then
                    pagesChecked = pagesChecked + 1
                    Tools.saveCursor(Tools.placeId, cursor, pagesChecked)
                    lastSavedCursor = cursor
                end
            else
                -- Достигли конца, начинаем заново
                Tools.sendMessageAPI("[HOP] Достигнут конец списка, начинаю с начала")
                Tools.clearCursor(Tools.placeId)
                cursor = ""
                pagesChecked = 0
                lastSavedCursor = ""
            end
        elseif success and response.StatusCode == 429 then
            -- Обработка rate limit с exponential backoff
            consecutiveRateLimits = consecutiveRateLimits + 1
            local waitTime = math.min(10 * (2 ^ (consecutiveRateLimits - 1)), 120) -- От 10 до 120 секунд
            Tools.sendMessageAPI(string.format("[HOP] Rate limit (429). Жду %d сек...", waitTime))

            -- Ждем с проверкой состояния бота каждую секунду
            for _ = 1, waitTime do
                if not Tools.isEnabled() then
                    Tools.sendMessageAPI("[HOP] Остановлено пользователем во время ожидания")
                    return false
                end
                task.wait(1)
            end

            pagesChecked = pagesChecked - 1 -- Повторяем эту же страницу
        else
            consecutiveRateLimits = 0
            Tools.sendMessageAPI("[HOP] Ошибка HTTP: " .. (response and response.StatusCode or "unknown"))
            task.wait(5)
        end
    end
end


return Tools