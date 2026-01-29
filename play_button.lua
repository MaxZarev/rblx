local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("=== ПОИСК КНОПОК PLAY (УЛУЧШЕННЫЙ) ===")
print("Ждем 3 секунды для загрузки UI...")
task.wait(3)

local foundButtons = {}

for _, gui in pairs(playerGui:GetDescendants()) do
    if gui:IsA("TextButton") or gui:IsA("ImageButton") then
        -- Безопасно получаем текст (только для TextButton)
        local text = ""
        if gui:IsA("TextButton") then
            text = (gui.Text or ""):lower()
        end

        local name = gui.Name:lower()
        local path = gui:GetFullName():lower()

        -- ИСКЛЮЧАЕМ ложные срабатывания (меню разработчика)
        local isDeveloperMenu = path:find("developmentshortcuts") or
                               path:find("shortcuts") or
                               path:find("admin") or
                               path:find("debug")

        -- Ищем кнопки "Играть" или "Play"
        -- Проверяем ТОЧНОЕ совпадение или кнопки начинающиеся с этих слов
        local isPlayButton = (text == "play" or text == "играть" or
                             text:match("^play%s") or text:match("^играть%s") or
                             name == "playbutton" or name == "play" or
                             name == "startbutton" or name == "start")

        -- Добавляем кнопку только если это НЕ меню разработчика И это кнопка Play
        if isPlayButton and gui.Visible and not isDeveloperMenu then
            table.insert(foundButtons, gui)
            print("\n✅ НАЙДЕНА КНОПКА:")
            print("  Имя: " .. gui.Name)
            print("  Класс: " .. gui.ClassName)

            -- Безопасно выводим текст
            if gui:IsA("TextButton") then
                print("  Текст: " .. (gui.Text or "[нет текста]"))
            else
                print("  Текст: [ImageButton - нет текста]")
            end

            print("  Путь: " .. gui:GetFullName())
            print("  Видима: " .. tostring(gui.Visible))
            print("  Активна: " .. tostring(gui.Active))
            print("  Позиция: " .. tostring(gui.AbsolutePosition))
            print("  Размер: " .. tostring(gui.AbsoluteSize))

            -- Показываем родительский контейнер
            local parent = gui.Parent
            if parent then
                print("  Родитель: " .. parent.Name .. " (" .. parent.ClassName .. ")")
            end
        end
    end
end

print("\n" .. string.rep("=", 60))
print("ИТОГО: Найдено кнопок Play: " .. #foundButtons)

if #foundButtons == 0 then
    print("\n⚠️ Кнопка Play не найдена!")
    print("Попробуем показать ВСЕ видимые кнопки:\n")

    for _, gui in pairs(playerGui:GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
            local path = gui:GetFullName():lower()
            local isDeveloperMenu = path:find("developmentshortcuts") or path:find("shortcuts")

            if not isDeveloperMenu then
                -- Безопасно получаем текст
                local buttonText = "[нет текста]"
                if gui:IsA("TextButton") then
                    buttonText = gui.Text or "[нет текста]"
                elseif gui:IsA("ImageButton") then
                    buttonText = "[ImageButton]"
                end

                print(string.format("🔘 %s | '%s' | %s",
                    gui.Name,
                    buttonText,
                    gui:GetFullName()
                ))
            end
        end
    end
end