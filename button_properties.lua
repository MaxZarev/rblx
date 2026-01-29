-- ПОЛНАЯ ДИАГНОСТИКА ВСЕХ СВОЙСТВ КНОПОК
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== ДИАГНОСТИКА ВСЕХ СВОЙСТВ КНОПОК ===")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

-- Функция для получения всех свойств объекта
local function getAllProperties(obj)
    local properties = {}

    -- Список наиболее важных свойств для GUI элементов
    local commonProps = {
        "Name", "ClassName", "Text", "Title", "Caption", "Label",
        "Visible", "Active", "AbsolutePosition", "AbsoluteSize",
        "BackgroundColor3", "TextColor3", "Font", "TextSize",
        "Image", "ImageRectOffset", "ImageRectSize", "ImageColor3"
    }

    for _, propName in ipairs(commonProps) do
        local success, value = pcall(function()
            return obj[propName]
        end)

        if success and value ~= nil then
            properties[propName] = tostring(value)
        end
    end

    return properties
end

-- Функция для вывода информации о кнопке
local function printButtonInfo(btn, index)
    print(string.format("\n🔘 КНОПКА #%d", index))
    print(string.rep("-", 70))

    local props = getAllProperties(btn)

    for propName, propValue in pairs(props) do
        -- Выделяем текстовые свойства
        if propName:lower():find("text") or propName:lower():find("title") or
           propName:lower():find("caption") or propName:lower():find("label") then
            print(string.format("  ⭐ %s: %s", propName, propValue))
        else
            print(string.format("     %s: %s", propName, propValue))
        end
    end

    print(string.format("  📍 Путь: %s", btn:GetFullName()))

    -- Проверяем дочерние элементы (иногда текст в TextLabel внутри)
    local children = btn:GetChildren()
    if #children > 0 then
        print("  👶 Дочерние элементы:")
        for _, child in ipairs(children) do
            if child:IsA("TextLabel") or child:IsA("TextBox") or
               child:IsA("ImageLabel") then
                local childProps = getAllProperties(child)
                print(string.format("     - %s (%s)", child.Name, child.ClassName))
                for propName, propValue in pairs(childProps) do
                    if propName:lower():find("text") or propName == "Image" then
                        print(string.format("       ⭐ %s: %s", propName, propValue))
                    end
                end
            end
        end
    end
end

-- Собираем все видимые кнопки
local allButtons = {}
for _, gui in pairs(playerGui:GetDescendants()) do
    if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
        local path = gui:GetFullName():lower()
        local isDeveloperMenu = path:find("developmentshortcuts") or path:find("shortcuts")

        if not isDeveloperMenu then
            table.insert(allButtons, gui)
        end
    end
end

print(string.format("\n📊 Найдено кнопок: %d", #allButtons))
print(string.rep("=", 70))

-- Выводим информацию о первых 10 кнопках (чтобы не перегружать вывод)
local limit = math.min(10, #allButtons)
print(string.format("\n📋 Показываю первые %d кнопок:", limit))

for i = 1, limit do
    printButtonInfo(allButtons[i], i)
end

if #allButtons > 10 then
    print(string.format("\n⚠️ Показано только первые 10 из %d кнопок", #allButtons))
    print("💡 Если среди них нет кнопки Play, давайте поищем более специфично:")

    -- Дополнительный поиск по размеру (большие кнопки обычно важные)
    print("\n🔍 БОЛЬШИЕ КНОПКИ (возможно это кнопка Play):")
    print(string.rep("-", 70))

    local bigButtons = {}
    for _, btn in ipairs(allButtons) do
        local size = btn.AbsoluteSize
        if size.X > 150 and size.Y > 50 then
            table.insert(bigButtons, btn)
        end
    end

    if #bigButtons > 0 then
        print(string.format("Найдено больших кнопок: %d\n", #bigButtons))
        for i, btn in ipairs(bigButtons) do
            if i <= 5 then  -- Показываем первые 5 больших
                printButtonInfo(btn, i)
            end
        end
    else
        print("  ❌ Больших кнопок не найдено")
    end
end

print("\n" .. string.rep("=", 70))
print("✅ ДИАГНОСТИКА ЗАВЕРШЕНА")
print("\n💡 ПОДСКАЗКА: Ищите свойства выделенные ⭐ - они содержат текст")
print(string.rep("=", 70))
