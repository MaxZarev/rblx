-- ПОИСК ЗЕЛЕНОЙ КНОПКИ "ИГРАТЬ!" ПО ЦВЕТУ И ПОЗИЦИИ
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== ПОИСК ЗЕЛЕНОЙ КНОПКИ 'ИГРАТЬ!' ===")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

-- Функция для проверки, является ли цвет зеленым
local function isGreenish(color)
    -- Зеленый цвет: R < 0.5, G > 0.5, B < 0.5
    return color.G > 0.5 and color.R < 0.7 and color.B < 0.7
end

-- Функция для получения всего текста из элемента и его детей
local function getAllText(element)
    local text = ""

    -- Если это TextButton или TextLabel с текстом
    if element:IsA("TextButton") or element:IsA("TextLabel") then
        if element.Text and element.Text ~= "" then
            text = text .. element.Text .. " "
        end
    end

    -- Ищем текст в дочерних элементах
    for _, child in ipairs(element:GetDescendants()) do
        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text and child.Text ~= "" then
            text = text .. child.Text .. " "
        end
    end

    return text:lower()
end

local foundButtons = {}

-- Ищем все GUI элементы
for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("Frame")) and gui.Visible then
        -- Проверяем цвет фона
        local hasColor = pcall(function() return gui.BackgroundColor3 end)

        if hasColor and gui.BackgroundColor3 then
            local isGreen = isGreenish(gui.BackgroundColor3)

            if isGreen then
                -- Получаем весь текст
                local allText = getAllText(gui)
                local size = gui.AbsoluteSize
                local pos = gui.AbsolutePosition

                -- Проверяем размер (должна быть достаточно большой)
                if size.X > 100 and size.Y > 40 then
                    table.insert(foundButtons, {
                        obj = gui,
                        name = gui.Name,
                        text = allText,
                        path = gui:GetFullName(),
                        size = size,
                        pos = pos,
                        color = gui.BackgroundColor3
                    })
                end
            end
        end
    end
end

print(string.format("\n📊 Найдено зеленых кнопок: %d\n", #foundButtons))
print(string.rep("=", 80))

if #foundButtons > 0 then
    -- Сортируем по размеру (большие первыми)
    table.sort(foundButtons, function(a, b)
        return (a.size.X * a.size.Y) > (b.size.X * b.size.Y)
    end)

    for i, btn in ipairs(foundButtons) do
        print(string.format("\n🟢 ЗЕЛЕНАЯ КНОПКА #%d:", i))
        print(string.format("   Имя: %s", btn.name))
        print(string.format("   Класс: %s", btn.obj.ClassName))
        print(string.format("   Размер: %.0fx%.0f", btn.size.X, btn.size.Y))
        print(string.format("   Позиция: %.0f, %.0f", btn.pos.X, btn.pos.Y))
        print(string.format("   Цвет RGB: %.2f, %.2f, %.2f", btn.color.R, btn.color.G, btn.color.B))

        if btn.text ~= "" then
            print(string.format("   ⭐ Текст: '%s'", btn.text:gsub("%s+$", "")))
        end

        print(string.format("   📍 Путь: %s", btn.path))

        -- Проверяем, содержит ли текст "играть" или "play"
        if btn.text:find("играть") or btn.text:find("play") then
            print("   ✅ ЭТО СКОРЕЕ ВСЕГО КНОПКА 'ИГРАТЬ!'")
        end
    end

    -- Ищем наиболее вероятную кнопку "Играть"
    print("\n" .. string.rep("=", 80))
    print("🎯 НАИБОЛЕЕ ВЕРОЯТНАЯ КНОПКА 'ИГРАТЬ!':")
    print(string.rep("=", 80))

    local playButton = nil
    for _, btn in ipairs(foundButtons) do
        if btn.text:find("играть") or btn.text:find("play") then
            playButton = btn
            break
        end
    end

    if not playButton and #foundButtons > 0 then
        -- Если не нашли по тексту, берем самую большую зеленую кнопку
        playButton = foundButtons[1]
    end

    if playButton then
        print(string.format("\n✅ НАЙДЕНА: %s", playButton.name))
        print(string.format("📍 Полный путь: %s", playButton.path))
        print(string.format("💬 Текст: '%s'", playButton.text:gsub("%s+$", "")))

        -- Показываем код для нажатия на кнопку
        print("\n" .. string.rep("=", 80))
        print("💡 КОД ДЛЯ НАЖАТИЯ НА ЭТУ КНОПКУ:")
        print(string.rep("=", 80))
        print(string.format([[
-- Вариант 1: Прямой путь
local button = %s
for i = 1, 3 do
    button.Activated:Fire()
    task.wait(0.5)
end

-- Вариант 2: Через Mouse1Click
for i = 1, 3 do
    firesignal(button.MouseButton1Click)
    task.wait(0.5)
end

-- Вариант 3: Симуляция клика мышью
local VirtualInputManager = game:GetService("VirtualInputManager")
local pos = button.AbsolutePosition + button.AbsoluteSize/2
VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
task.wait(0.1)
VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
]], playButton.path))

        print(string.rep("=", 80))
    end
else
    print("❌ Зеленых кнопок не найдено!")
    print("\n💡 Возможные причины:")
    print("   1. Кнопка 'Играть' еще не загрузилась")
    print("   2. Вы уже в игре (кнопка исчезла)")
    print("   3. Кнопка имеет другой цвет")
    print("\nПопробуйте:")
    print("   - Перезайти в игру и запустить скрипт на экране загрузки")
    print("   - Увеличить время ожидания в начале скрипта")
end

print("\n" .. string.rep("=", 80))
print("✅ ПОИСК ЗАВЕРШЕН")
print(string.rep("=", 80))
