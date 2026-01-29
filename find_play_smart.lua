-- УМНЫЙ ПОИСК КНОПКИ PLAY С АНАЛИЗОМ
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== УМНЫЙ ПОИСК КНОПКИ PLAY ===")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

local allButtons = {}

-- Собираем все видимые кнопки
for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
        local path = gui:GetFullName():lower()
        local isDeveloperMenu = path:find("developmentshortcuts") or path:find("shortcuts")

        if not isDeveloperMenu then
            local buttonText = ""
            if gui:IsA("TextButton") then
                buttonText = gui.Text or ""
            end

            table.insert(allButtons, {
                obj = gui,
                name = gui.Name,
                text = buttonText,
                path = gui:GetFullName(),
                size = gui.AbsoluteSize
            })
        end
    end
end

print(string.format("\n📊 Всего найдено кнопок: %d", #allButtons))
print(string.rep("=", 70))

-- КАТЕГОРИЯ 1: Кнопки с текстом содержащим "play" или "играть"
print("\n🎯 КАТЕГОРИЯ 1: Кнопки с текстом 'play' или 'играть'")
print(string.rep("-", 70))
local cat1 = {}
for _, btn in ipairs(allButtons) do
    local textLower = btn.text:lower()
    if textLower:find("play") or textLower:find("играть") or textLower:find("start") then
        table.insert(cat1, btn)
        print(string.format("  🔘 %s | Текст: '%s'", btn.name, btn.text))
        print(string.format("     Путь: %s", btn.path))
    end
end
if #cat1 == 0 then print("  ❌ Не найдено") end

-- КАТЕГОРИЯ 2: Кнопки с именем содержащим "play", "start", "begin"
print("\n🎯 КАТЕГОРИЯ 2: Кнопки с именем 'play', 'start', 'begin'")
print(string.rep("-", 70))
local cat2 = {}
for _, btn in ipairs(allButtons) do
    local nameLower = btn.name:lower()
    if nameLower:find("play") or nameLower:find("start") or nameLower:find("begin") then
        table.insert(cat2, btn)
        print(string.format("  🔘 %s | Текст: '%s'", btn.name, btn.text))
        print(string.format("     Путь: %s", btn.path))
    end
end
if #cat2 == 0 then print("  ❌ Не найдено") end

-- КАТЕГОРИЯ 3: Большие кнопки (вероятно важные)
print("\n🎯 КАТЕГОРИЯ 3: Большие кнопки (>100 пикселей)")
print(string.rep("-", 70))
local cat3 = {}
for _, btn in ipairs(allButtons) do
    if btn.size.X > 100 or btn.size.Y > 50 then
        table.insert(cat3, btn)
        print(string.format("  🔘 %s | Текст: '%s' | Размер: %.0fx%.0f",
            btn.name, btn.text, btn.size.X, btn.size.Y))
        print(string.format("     Путь: %s", btn.path))
    end
end
if #cat3 == 0 then print("  ❌ Не найдено") end

-- КАТЕГОРИЯ 4: Кнопки в главных GUI контейнерах
print("\n🎯 КАТЕГОРИЯ 4: Кнопки в главных ScreenGui (не вложенные глубоко)")
print(string.rep("-", 70))
local cat4 = {}
for _, btn in ipairs(allButtons) do
    -- Считаем глубину вложенности (количество точек в пути)
    local _, depth = btn.path:gsub("%.", "")
    if depth <= 5 then  -- Неглубоко вложенные элементы
        table.insert(cat4, btn)
        print(string.format("  🔘 %s | Текст: '%s' | Глубина: %d",
            btn.name, btn.text, depth))
        print(string.format("     Путь: %s", btn.path))
    end
end
if #cat4 == 0 then print("  ❌ Не найдено") end

-- КАТЕГОРИЯ 5: Кнопки с зеленым/ярким фоном (часто это главные действия)
print("\n🎯 КАТЕГОРИЯ 5: Кнопки с именами указывающими на действие")
print(string.rep("-", 70))
local cat5 = {}
local actionWords = {"button", "btn", "click", "press", "ok", "yes", "confirm", "accept", "go"}
for _, btn in ipairs(allButtons) do
    local nameLower = btn.name:lower()
    for _, word in ipairs(actionWords) do
        if nameLower:find(word) then
            table.insert(cat5, btn)
            print(string.format("  🔘 %s | Текст: '%s'", btn.name, btn.text))
            print(string.format("     Путь: %s", btn.path))
            break
        end
    end
end
if #cat5 == 0 then print("  ❌ Не найдено") end

-- ИТОГИ
print("\n" .. string.rep("=", 70))
print("📈 ИТОГОВАЯ СТАТИСТИКА:")
print(string.format("  Категория 1 (текст): %d кнопок", #cat1))
print(string.format("  Категория 2 (имя): %d кнопок", #cat2))
print(string.format("  Категория 3 (размер): %d кнопок", #cat3))
print(string.format("  Категория 4 (уровень): %d кнопок", #cat4))
print(string.format("  Категория 5 (действие): %d кнопок", #cat5))

print("\n💡 РЕКОМЕНДАЦИИ:")
print("  1. Ищите кнопку среди Категорий 1 и 2 (они наиболее релевантны)")
print("  2. Если не нашли - смотрите Категорию 3 (большие кнопки)")
print("  3. Попробуйте нажать на кнопки вручную и сверьте с путями выше")
print(string.rep("=", 70))
