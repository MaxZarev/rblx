

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
    maxPlayersAllowed = 100,
    searchTimeout = 60,
    teleportCooldown = 15,
    placeId = 920587237,
    scriptUrl = "",
}

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
    Tools.sendMessageAPI("[HOP] Ищу серверы с " .. currentMinPlayers .. "+ игроков...")

    while pagesChecked < maxPages do
        -- Проверяем таймаут
        local elapsedTime = tick() - searchStartTime
        if elapsedTime > Tools.searchTimeout and currentMinPlayers ~= Tools.minPlayersFallback then
            currentMinPlayers = Tools.minPlayersFallback
            Tools.sendMessageAPI("[HOP] Снижаю требования до " .. currentMinPlayers .. "+ игроков...")
        end

        pagesChecked = pagesChecked + 1
        task.wait(5)

        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100%s",
            Tools.placeId,
            cursor ~= "" and "&cursor=" .. cursor or ""
        )

        Tools.sendMessageAPI("[HOP] Страница " .. pagesChecked .. "...")

        local success, response = pcall(function()
            return httprequest({Url = url})
        end)

        if success and response.StatusCode == 200 then
            local data = HttpService:JSONDecode(response.Body)

            -- Ищем подходящий сервер
            for _, server in pairs(data.data) do
                local playerCount = server.playing
                local maxPlayers = server.maxPlayers
                local serverId = server.id

                -- Проверяем условия: достаточно игроков, не полный сервер, не текущий сервер
                if playerCount >= currentMinPlayers and
                   playerCount < maxPlayers and
                   serverId ~= game.JobId then

                    Tools.sendMessageAPI("[HOP] Найден сервер: " .. playerCount .. "/" .. maxPlayers .. " игроков")

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
        else
            Tools.sendMessageAPI("[HOP] Ошибка HTTP: " .. (response and response.StatusCode or "unknown"))
            task.wait(5)
        end
    end

    Tools.sendMessageAPI("[HOP] Не удалось найти подходящий сервер за " .. maxPages .. " страниц")
    return false
end


return Tools