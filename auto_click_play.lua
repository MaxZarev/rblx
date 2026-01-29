-- АВТОМАТИЧЕСКОЕ НАЖАТИЕ НА КНОПКИ PLAY/ИГРАТЬ/JOIN
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== АВТОНАЖАТИЕ НА КНОПКИ PLAY ===")
print("Этот скрипт будет искать и нажимать на все кнопки связанные с началом игры")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

-- Функция для получения всего текста из элемента
local function getAllText(element)
    local text = ""

    -- Текст из самого элемента
    if element:IsA("TextButton") or element:IsA("TextLabel") then
        if element.Text and element.Text ~= "" then
            text = text .. element.Text .. " "
        end
    end

    -- Текст из дочерних TextLabel
    for _, child in ipairs(element:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text and child.Text ~= "" then
            text = text .. child.Text .. " "
        end
    end

    return text:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

-- Функция для проверки, является ли цвет зеленым
local function isGreenish(color)
    return color.G > 0.5 and color.R < 0.7 and color.B < 0.7
end

-- Функция для нажатия на кнопку (несколько методов)
local function clickButton(button, index, reason)
    print(string.format("\n🔘 ПОПЫТКА #%d: %s", index, button.Name))
    print(string.format("   Причина: %s", reason))
    print(string.format("   Путь: %s", button:GetFullName()))

    local clickSuccess = false

    -- МЕТОД 1: MouseButton1Click
    local method1 = pcall(function()
        for i = 1, 3 do
            button.MouseButton1Click:Fire()
            task.wait(0.3)
        end
    end)
    if method1 then
        print("   ✅ Метод 1 (MouseButton1Click) выполнен")
        clickSuccess = true
    else
        print("   ❌ Метод 1 не сработал")
    end

    task.wait(0.5)

    -- МЕТОД 2: Activated
    local method2 = pcall(function()
        for i = 1, 3 do
            button.Activated:Fire()
            task.wait(0.3)
        end
    end)
    if method2 then
        print("   ✅ Метод 2 (Activated) выполнен")
        clickSuccess = true
    else
        print("   ❌ Метод 2 не сработал")
    end

    task.wait(0.5)

    -- МЕТОД 3: VirtualInputManager (симуляция клика мышью)
    local method3Success = pcall(function()
        local VirtualInputManager = game:GetService("VirtualInputManager")
        local pos = button.AbsolutePosition
        local size = button.AbsoluteSize
        local centerX = pos.X + size.X / 2
        local centerY = pos.Y + size.Y / 2

        for i = 1, 3 do
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            task.wait(0.3)
        end
    end)
    if method3Success then
        print("   ✅ Метод 3 (VirtualInput) выполнен")
        clickSuccess = true
    else
        print("   ❌ Метод 3 не сработал")
    end

    if clickSuccess then
        print("   ⏳ Жду 2 секунды для проверки эффекта...")
        task.wait(2)
    end

    return clickSuccess
end

-- Собираем все потенциальные кнопки
print("\n" .. string.rep("=", 80))
print("🔍 ПОИСК ПОТЕНЦИАЛЬНЫХ КНОПОК...")
print(string.rep("=", 80))

local candidateButtons = {}

for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("Frame")) and gui.Visible then
        local name = gui.Name:lower()
        local path = gui:GetFullName():lower()
        local allText = getAllText(gui)

        -- Исключаем меню разработчика
        local isDeveloperMenu = path:find("developmentshortcuts") or
                               path:find("shortcuts") or
                               path:find("debug")

        if not isDeveloperMenu then
            local reasons = {}

            -- Проверка 1: По тексту
            if allText:find("играть") or allText:find("play") or
               allText:find("join") or allText:find("start") then
                table.insert(reasons, "текст содержит 'играть/play/join/start'")
            end

            -- Проверка 2: По имени элемента
            if name:find("play") or name:find("start") or
               name:find("join") or name:find("begin") then
                table.insert(reasons, "имя содержит 'play/start/join'")
            end

            -- Проверка 3: По пути
            if path:find("play") or path:find("start") or
               path:find("loading") or path:find("menu") then
                table.insert(reasons, "путь содержит 'play/start/loading/menu'")
            end

            -- Проверка 4: Зеленая кнопка (как на скрине)
            local hasColor = pcall(function() return gui.BackgroundColor3 end)
            if hasColor and gui.BackgroundColor3 then
                if isGreenish(gui.BackgroundColor3) then
                    local size = gui.AbsoluteSize
                    if size.X > 100 and size.Y > 40 then
                        table.insert(reasons, "зеленая большая кнопка (как 'Играть!')")
                    end
                end
            end

            -- Если есть хотя бы одна причина - добавляем в кандидаты
            if #reasons > 0 then
                table.insert(candidateButtons, {
                    obj = gui,
                    reasons = reasons,
                    text = allText,
                    priority = #reasons  -- Чем больше причин, тем выше приоритет
                })
            end
        end
    end
end

-- Сортируем по приоритету (больше причин = выше приоритет)
table.sort(candidateButtons, function(a, b)
    return a.priority > b.priority
end)

print(string.format("\n✅ Найдено потенциальных кнопок: %d\n", #candidateButtons))

if #candidateButtons == 0 then
    print("❌ Не найдено ни одной подходящей кнопки!")
    print("\n💡 Возможные причины:")
    print("   1. Кнопка 'Играть' еще не загрузилась")
    print("   2. Вы уже в игре (кнопка исчезла)")
    print("   3. Кнопка имеет нестандартное имя/текст")
    print("\nПопробуйте:")
    print("   - Перезайти в игру")
    print("   - Запустить скрипт раньше (сразу после загрузки)")
    print("   - Увеличить время ожидания")
else
    -- Показываем список найденных кнопок
    print("📋 СПИСОК КАНДИДАТОВ (по приоритету):")
    print(string.rep("-", 80))
    for i, btn in ipairs(candidateButtons) do
        print(string.format("\n  #%d | %s (Приоритет: %d)", i, btn.obj.Name, btn.priority))
        print(string.format("     Причины: %s", table.concat(btn.reasons, ", ")))
        if btn.text ~= "" then
            print(string.format("     Текст: '%s'", btn.text))
        end
        if i <= 5 then  -- Показываем путь только для первых 5
            print(string.format("     Путь: %s", btn.obj:GetFullName()))
        end
    end

    -- Начинаем автонажатие
    print("\n" .. string.rep("=", 80))
    print("🤖 НАЧИНАЮ АВТОМАТИЧЕСКОЕ НАЖАТИЕ...")
    print(string.rep("=", 80))
    print("\n⏳ Буду нажимать на каждую кнопку с паузой в 3 секунды")
    print("   Если произойдет переход/загрузка - значит кнопка рабочая!\n")

    local clickedCount = 0
    local maxClicks = math.min(10, #candidateButtons)  -- Максимум 10 кнопок

    for i = 1, maxClicks do
        local btn = candidateButtons[i]

        local success = clickButton(btn.obj, i, table.concat(btn.reasons, ", "))

        if success then
            clickedCount = clickedCount + 1
        end

        -- Проверяем, не изменился ли GUI (возможно кнопка сработала)
        if not btn.obj.Parent or not btn.obj.Visible then
            print("\n   🎯 ВНИМАНИЕ! Кнопка исчезла после нажатия!")
            print("   Это может означать, что она сработала!")
            print("   Жду 5 секунд для проверки загрузки...")
            task.wait(5)
            break
        end

        -- Пауза между кнопками
        if i < maxClicks then
            print(string.format("\n   ⏸️  Пауза 3 секунды перед следующей кнопкой...\n"))
            task.wait(3)
        end
    end

    -- Итоги
    print("\n" .. string.rep("=", 80))
    print("📊 ИТОГИ ТЕСТИРОВАНИЯ")
    print(string.rep("=", 80))
    print(string.format("Всего найдено кандидатов: %d", #candidateButtons))
    print(string.format("Протестировано: %d", maxClicks))
    print(string.format("Успешно нажато: %d", clickedCount))

    print("\n💡 РЕКОМЕНДАЦИИ:")
    print("   1. Если произошел переход в игру - запомните имя сработавшей кнопки")
    print("   2. Если ничего не произошло - возможно кнопки защищены или")
    print("      требуют дополнительных действий (например, прогрузку персонажа)")
    print("   3. Попробуйте запустить скрипт в другой момент (при загрузке)")

    if #candidateButtons > maxClicks then
        print(string.format("\n   ⚠️  Остались непроверенными: %d кнопок", #candidateButtons - maxClicks))
        print("      Измените maxClicks в коде, если хотите проверить больше")
    end
end

print("\n" .. string.rep("=", 80))
print("✅ ТЕСТИРОВАНИЕ ЗАВЕРШЕНО")
print(string.rep("=", 80))
