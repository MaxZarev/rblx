local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")

local Tools = {}

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
            end
        end
    end)
end

-- Отправка сообщения через API сервер
function Tools.sendMessageAPI(apiUrl, apiKey, message)
    local HttpService = game:GetService("HttpService")
    local httprequest = http_request or request or syn.request

    if not httprequest then
        warn("HTTP request function not available")
        return false
    end

    local success, result = pcall(function()
        return httprequest({
            Url = apiUrl .. "/send_chat?message=" .. HttpService:UrlEncode(message),
            Method = "POST",
            Headers = {
                ["Authorization"] = "Bearer " .. apiKey,
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


return Tools