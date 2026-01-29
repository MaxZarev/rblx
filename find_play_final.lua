-- ФИНАЛЬНЫЙ ПОИСК КНОПКИ PLAY (для ImageButton без текста)
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== ФИНАЛЬНЫЙ ПОИСК КНОПКИ PLAY ===")
print("Ждем 5 секунд для загрузки UI...")
task.wait(5)

local allButtons = {}

-- Собираем ВСЕ видимые кнопки
for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
        local path = gui:GetFullName():lower()
        local isDeveloperMenu = path:find("developmentshortcuts") or path:find("shortcuts")

        if not isDeveloperMenu then
            -- Ищем текст в дочерних TextLabel
            local childText = ""
            for _, child in ipairs(gui:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                    childText = childText .. " " .. child.Text
                end
            end

            table.insert(allButtons, {
                obj = gui,
                name = gui.Name,
                path = gui:GetFullName(),
                childText = childText:lower():gsub("^%s+", ""),  -- Убираем пробелы в начале
                size = gui.AbsoluteSize,
                pos = gui.AbsolutePosition
            })
        end
    end
end

print(string.format("\n📊 Всего найдено кнопок: %d", #allButtons))
print(string.rep("=", 80))

-- СТРАТЕГИЯ 1: Ищем по имени GUI контейнера
print("\n🎯 СТРАТЕГИЯ 1: Ищем GUI с именами связанными с началом игры")
print(string.rep("-", 80))

local strategy1 = {}
for _, btn in ipairs(allButtons) do
    local pathLower = btn.path:lower()
    -- Ищем GUI контейнеры с именами: PlayButton, StartGame, LoadingScreen, MainMenu, etc.
    if pathLower:find("play") or pathLower:find("start") or
       pathLower:find("loading") or pathLower:find("menu") or
       pathLower:find("lobby") or pathLower:find("spawn") then
        table.insert(strategy1, btn)
        print(string.format("  🔘 %s | Размер: %.0fx%.0f", btn.name, btn.size.X, btn.size.Y))
        if btn.childText ~= "" then
            print(string.format("     💬 Текст из TextLabel: '%s'", btn.childText))
        end
        print(string.format("     📍 Путь: %s", btn.path))
        print("")
    end
end
if #strategy1 == 0 then print("  ❌ Не найдено\n") end

-- СТРАТЕГИЯ 2: Ищем по тексту в дочерних TextLabel
print("🎯 СТРАТЕГИЯ 2: Кнопки с TextLabel содержащими 'play' или 'играть'")
print(string.rep("-", 80))

local strategy2 = {}
for _, btn in ipairs(allButtons) do
    if btn.childText:find("play") or btn.childText:find("играть") or
       btn.childText:find("start") or btn.childText:find("begin") then
        table.insert(strategy2, btn)
        print(string.format("  🔘 %s | Размер: %.0fx%.0f", btn.name, btn.size.X, btn.size.Y))
        print(string.format("     💬 Текст: '%s'", btn.childText))
        print(string.format("     📍 Путь: %s", btn.path))
        print("")
    end
end
if #strategy2 == 0 then print("  ❌ Не найдено\n") end

-- СТРАТЕГИЯ 3: Большие центральные кнопки
print("🎯 СТРАТЕГИЯ 3: Большие кнопки в центре экрана (вероятно главные)")
print(string.rep("-", 80))

local screenSize = workspace.CurrentCamera.ViewportSize
local centerX = screenSize.X / 2
local centerY = screenSize.Y / 2

local strategy3 = {}
for _, btn in ipairs(allButtons) do
    -- Большая кнопка
    if btn.size.X > 120 and btn.size.Y > 50 then
        -- Близко к центру экрана
        local btnCenterX = btn.pos.X + btn.size.X / 2
        local btnCenterY = btn.pos.Y + btn.size.Y / 2
        local distanceFromCenter = math.sqrt((btnCenterX - centerX)^2 + (btnCenterY - centerY)^2)

        if distanceFromCenter < screenSize.X / 3 then  -- В пределах трети экрана от центра
            table.insert(strategy3, {
                btn = btn,
                distance = distanceFromCenter
            })
        end
    end
end

-- Сортируем по близости к центру
table.sort(strategy3, function(a, b) return a.distance < b.distance end)

for i, item in ipairs(strategy3) do
    local btn = item.btn
    print(string.format("  🔘 #%d | %s | Размер: %.0fx%.0f", i, btn.name, btn.size.X, btn.size.Y))
    print(string.format("     📏 Расстояние от центра: %.0f px", item.distance))
    if btn.childText ~= "" then
        print(string.format("     💬 Текст: '%s'", btn.childText))
    end
    print(string.format("     📍 Путь: %s", btn.path))
    print("")
end
if #strategy3 == 0 then print("  ❌ Не найдено\n") end

-- СТРАТЕГИЯ 4: Показать ВСЕ кнопки по группам GUI
print("🎯 СТРАТЕГИЯ 4: Все кнопки сгруппированные по GUI контейнерам")
print(string.rep("-", 80))

-- Группируем кнопки по родительскому ScreenGui
local guiGroups = {}
for _, btn in ipairs(allButtons) do
    -- Находим первый ScreenGui в пути
    local screenGuiName = btn.path:match("PlayerGui%.([^%.]+)")
    if screenGuiName then
        if not guiGroups[screenGuiName] then
            guiGroups[screenGuiName] = {}
        end
        table.insert(guiGroups[screenGuiName], btn)
    end
end

-- Выводим по группам
for guiName, buttons in pairs(guiGroups) do
    print(string.format("\n  📁 %s (%d кнопок):", guiName, #buttons))
    for _, btn in ipairs(buttons) do
        local info = string.format("     - %s (%.0fx%.0f)", btn.name, btn.size.X, btn.size.Y)
        if btn.childText ~= "" then
            info = info .. string.format(" | '%s'", btn.childText)
        end
        print(info)
    end
end

-- ИТОГИ
print("\n" .. string.rep("=", 80))
print("📈 ИТОГИ:")
print(string.format("  Стратегия 1 (по пути): %d кнопок", #strategy1))
print(string.format("  Стратегия 2 (по тексту в TextLabel): %d кнопок", #strategy2))
print(string.format("  Стратегия 3 (большие центральные): %d кнопок", #strategy3))
print("\n💡 РЕКОМЕНДАЦИИ:")
print("  1. Если кнопка Play найдена в Стратегии 1-2 - используйте путь оттуда")
print("  2. Если не найдена - посмотрите Стратегию 3 (центральные кнопки)")
print("  3. Проверьте группы GUI в Стратегии 4 - ищите подозрительные названия")
print("  4. Возможно кнопка появляется только после определенного действия")
print(string.rep("=", 80))
