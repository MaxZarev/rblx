-- КЛИК ПО КООРДИНАТАМ (самый надежный метод)
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== КЛИК ПО КООРДИНАТАМ КНОПКИ 'ИГРАТЬ' ===")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

-- Функция для получения всего текста из элемента
local function getAllText(element)
    local text = ""
    if element:IsA("TextButton") or element:IsA("TextLabel") then
        if element.Text and element.Text ~= "" then
            text = text .. element.Text .. " "
        end
    end
    for _, child in ipairs(element:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text and child.Text ~= "" then
            text = text .. child.Text .. " "
        end
    end
    return text:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

-- Функция для проверки зеленого цвета
local function isGreenish(color)
    return color.G > 0.5 and color.R < 0.7 and color.B < 0.7
end

-- Функция клика по координатам
local function clickAtPosition(x, y, name)
    print(string.format("\n🖱️  КЛИК ПО КООРДИНАТАМ: %.0f, %.0f", x, y))
    print(string.format("   Элемент: %s", name))

    -- Метод 1: Одинарный клик
    local success1 = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)

    if success1 then
        print("   ✅ Метод 1: Одинарный клик выполнен")
    else
        print("   ❌ Метод 1: Не сработал")
    end

    task.wait(1)

    -- Метод 2: Двойной клик (иногда нужен)
    local success2 = pcall(function()
        for i = 1, 2 do
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            task.wait(0.1)
        end
    end)

    if success2 then
        print("   ✅ Метод 2: Двойной клик выполнен")
    else
        print("   ❌ Метод 2: Не сработал")
    end

    task.wait(1)

    -- Метод 3: Клик с движением мыши (имитация реального пользователя)
    local success3 = pcall(function()
        -- Сначала перемещаем курсор к кнопке
        VirtualInputManager:SendMouseMoveEvent(x - 10, y - 10, game)
        task.wait(0.1)
        VirtualInputManager:SendMouseMoveEvent(x, y, game)
        task.wait(0.1)

        -- Затем кликаем
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)

    if success3 then
        print("   ✅ Метод 3: Клик с движением мыши выполнен")
    else
        print("   ❌ Метод 3: Не сработал")
    end

    print("   ⏳ Жду 2 секунды для проверки эффекта...")
    task.wait(2)
end

-- Поиск кнопки "Играть"
print("\n" .. string.rep("=", 80))
print("🔍 ПОИСК КНОПКИ 'ИГРАТЬ'...")
print(string.rep("=", 80))

local playButtons = {}

for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("Frame")) and gui.Visible then
        local name = gui.Name:lower()
        local path = gui:GetFullName():lower()
        local allText = getAllText(gui)

        -- Исключаем меню разработчика
        local isDeveloperMenu = path:find("developmentshortcuts") or path:find("shortcuts")

        if not isDeveloperMenu then
            local score = 0
            local reasons = {}

            -- Проверяем текст
            if allText:find("играть") or allText:find("play") then
                score = score + 10
                table.insert(reasons, "текст 'играть/play'")
            end

            -- Проверяем имя
            if name:find("play") or name:find("start") then
                score = score + 5
                table.insert(reasons, "имя 'play/start'")
            end

            -- Проверяем зеленый цвет
            local hasColor = pcall(function() return gui.BackgroundColor3 end)
            if hasColor and gui.BackgroundColor3 and isGreenish(gui.BackgroundColor3) then
                local size = gui.AbsoluteSize
                if size.X > 100 and size.Y > 40 then
                    score = score + 15  -- Зеленая кнопка = высокий приоритет!
                    table.insert(reasons, "ЗЕЛЕНАЯ БОЛЬШАЯ кнопка")
                end
            end

            if score > 0 then
                table.insert(playButtons, {
                    obj = gui,
                    score = score,
                    reasons = reasons,
                    text = allText
                })
            end
        end
    end
end

-- Сортируем по приоритету
table.sort(playButtons, function(a, b) return a.score > b.score end)

print(string.format("\n✅ Найдено потенциальных кнопок: %d\n", #playButtons))

if #playButtons == 0 then
    print("❌ Кнопка не найдена!")
    print("\n💡 Попробуйте:")
    print("   1. Запустить скрипт на экране с кнопкой 'Играть'")
    print("   2. Увеличить время ожидания в начале")
else
    -- Показываем найденные кнопки
    print("📋 НАЙДЕННЫЕ КНОПКИ (по приоритету):")
    print(string.rep("-", 80))

    for i, btn in ipairs(playButtons) do
        if i <= 5 then  -- Показываем первые 5
            local pos = btn.obj.AbsolutePosition
            local size = btn.obj.AbsoluteSize
            local centerX = pos.X + size.X / 2
            local centerY = pos.Y + size.Y / 2

            print(string.format("\n  #%d | %s (Приоритет: %d)", i, btn.obj.Name, btn.score))
            print(string.format("     Причины: %s", table.concat(btn.reasons, ", ")))
            if btn.text ~= "" then
                print(string.format("     Текст: '%s'", btn.text))
            end
            print(string.format("     Координаты центра: %.0f, %.0f", centerX, centerY))
            print(string.format("     Размер: %.0fx%.0f", size.X, size.Y))
        end
    end

    -- Начинаем кликать
    print("\n" .. string.rep("=", 80))
    print("🖱️  НАЧИНАЮ КЛИКИ ПО КООРДИНАТАМ...")
    print(string.rep("=", 80))

    local maxClicks = math.min(3, #playButtons)  -- Пробуем первые 3 кнопки

    for i = 1, maxClicks do
        local btn = playButtons[i]
        local pos = btn.obj.AbsolutePosition
        local size = btn.obj.AbsoluteSize
        local centerX = pos.X + size.X / 2
        local centerY = pos.Y + size.Y / 2

        print(string.format("\n═══ ПОПЫТКА #%d ═══", i))
        clickAtPosition(centerX, centerY, btn.obj.Name)

        -- Проверяем, не исчезла ли кнопка
        if not btn.obj.Parent or not btn.obj.Visible then
            print("\n   🎯 УСПЕХ! Кнопка исчезла после клика!")
            print(string.format("   ✅ Рабочая кнопка: %s", btn.obj.Name))
            print(string.format("   📍 Координаты: %.0f, %.0f", centerX, centerY))
            print("\n   Жду 5 секунд для загрузки...")
            task.wait(5)
            break
        end

        if i < maxClicks then
            print("\n   ⏸️  Пауза 3 секунды перед следующей попыткой...")
            task.wait(3)
        end
    end
end

print("\n" .. string.rep("=", 80))
print("✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО")
print(string.rep("=", 80))

print("\n💡 ЕСЛИ КНОПКА НЕ НАЖАЛАСЬ:")
print("   1. Попробуйте нажать ВРУЧНУЮ мышью и посмотрите что происходит")
print("   2. Возможно нужно сначала прогрузить персонажа")
print("   3. Некоторые игры требуют загрузки дополнительных ресурсов")
print("   4. Попробуйте запустить скрипт в другой момент игры")
