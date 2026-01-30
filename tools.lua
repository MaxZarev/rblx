

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
        -- TextChatService (новая система чата Roblox)
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local ch = TextChatService.TextChannels.RBXGeneral
            if ch then
                pcall(function()
                    ch:SendAsync(msg)
                end)
                Tools.sendMessageAPI("Sent chat message successfully")
            end
        end

        -- Legacy chat fallback (старая система чата для обратной совместимости)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local say = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if say then
            say = say:FindFirstChild("SayMessageRequest")
            if say then
                pcall(function()
                    say:FireServer(msg, "All")
                end)
                Tools.sendMessageAPI("Sent chat message successfully")
            end
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


function Tools.serverHop()
    if not httprequest then
        warn("[HOP] HTTP функция недоступна!")
        return false
    end

    Tools.sendMessageAPI("[HOP] Начинаю переключение сервера...")
    local cursor = ""
    local maxPages = 30
    local pagesChecked = 0
    local searchStartTime = tick()
    local currentMinPlayers = Tools.minPlayersPreferred
    local consecutiveRateLimits = 0
    Tools.sendMessageAPI("[HOP] Ищу серверы с " .. currentMinPlayers .. "+ игроков. Максимальное количество игроков: " .. Tools.maxPlayersAllowed)

    while pagesChecked < maxPages do
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

        pagesChecked = pagesChecked + 1
        task.wait(5)

        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
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

                -- Проверяем условия: достаточно игроков, есть запас мест, не текущий сервер
                -- Оставляем минимум 5 свободных мест для надежной телепортации
                local freeSlots = maxPlayers - playerCount
                if playerCount >= currentMinPlayers and
                   freeSlots >= 5 and
                   playerCount <= Tools.maxPlayersAllowed and
                   serverId ~= game.JobId then

                    Tools.sendMessageAPI("[HOP] Найден сервер: " .. playerCount .. "/" .. maxPlayers .. " игроков (свободно: " .. freeSlots .. ")")

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
                end
            end

            -- Обновляем курсор для следующей страницы
            if data.nextPageCursor then
                cursor = data.nextPageCursor
            else
                Tools.sendMessageAPI("[HOP] Больше нет страниц, серверы не найдены")
                return false
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

    Tools.sendMessageAPI("[HOP] Не удалось найти подходящий сервер за " .. maxPages .. " страниц")
    return false
end


return Tools