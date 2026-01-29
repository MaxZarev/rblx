-- ИССЛЕДОВАНИЕ ВСЕХ GUI ЭЛЕМЕНТОВ ИГРОКА
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("=== ПОЛНОЕ ИССЛЕДОВАНИЕ GUI ИГРОКА ===")
print("Ждем 3 секунды для загрузки...")
task.wait(3)

print("\n" .. string.rep("=", 80))

-- ==================== 1. PLAYERGUI ====================
print("\n📁 1. PLAYERGUI (основной GUI контейнер)")
print(string.rep("-", 80))

local playerGui = player:WaitForChild("PlayerGui", 5)
if playerGui then
    local guiCount = 0
    for _, gui in ipairs(playerGui:GetChildren()) do
        guiCount = guiCount + 1
        print(string.format("  %d. %s (%s)", guiCount, gui.Name, gui.ClassName))

        -- Показываем первые 3 дочерних элемента
        local children = gui:GetChildren()
        if #children > 0 then
            for i = 1, math.min(3, #children) do
                print(string.format("     └─ %s (%s)", children[i].Name, children[i].ClassName))
            end
            if #children > 3 then
                print(string.format("     └─ ... и еще %d элементов", #children - 3))
            end
        end
    end
    print(string.format("\nВсего ScreenGui: %d", guiCount))
else
    print("  ❌ PlayerGui не найден")
end

-- ==================== 2. CHARACTER ====================
print("\n\n📁 2. CHARACTER (персонаж игрока)")
print(string.rep("-", 80))

local character = player.Character
if character then
    print(string.format("Персонаж: %s", character.Name))

    -- Показываем основные части
    local parts = {}
    local guis = {}

    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BasePart") then
            table.insert(parts, child.Name)
        elseif child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
            table.insert(guis, {
                name = child.Name,
                parent = child.Parent.Name,
                class = child.ClassName
            })
        end
    end

    print(string.format("  Части тела: %d", #parts))
    print(string.format("  GUI на персонаже: %d", #guis))

    if #guis > 0 then
        print("\n  GUI элементы на персонаже:")
        for i, gui in ipairs(guis) do
            print(string.format("    %d. %s (%s) на %s", i, gui.name, gui.class, gui.parent))
        end
    end
else
    print("  ❌ Character не загружен")
end

-- ==================== 3. PLAYER (прямо в объекте Player) ====================
print("\n\n📁 3. PLAYER (объект игрока)")
print(string.rep("-", 80))

print(string.format("Имя: %s", player.Name))
print(string.format("UserId: %d", player.UserId))

local playerChildren = {}
for _, child in ipairs(player:GetChildren()) do
    table.insert(playerChildren, {
        name = child.Name,
        class = child.ClassName
    })
end

print(string.format("\nДочерние объекты Player: %d", #playerChildren))
for i, child in ipairs(playerChildren) do
    print(string.format("  %d. %s (%s)", i, child.name, child.class))
end

-- ==================== 4. COREGUI (системный GUI) ====================
print("\n\n📁 4. COREGUI (системный GUI - может быть недоступен)")
print(string.rep("-", 80))

local success, coreGui = pcall(function()
    return game:GetService("CoreGui")
end)

if success and coreGui then
    local coreGuiCount = 0
    for _, gui in ipairs(coreGui:GetChildren()) do
        coreGuiCount = coreGuiCount + 1
        print(string.format("  %d. %s (%s)", coreGuiCount, gui.Name, gui.ClassName))
    end
    print(string.format("\nВсего элементов CoreGui: %d", coreGuiCount))
else
    print("  ⚠️ CoreGui недоступен (защищен)")
end

-- ==================== 5. ПОИСК ВСЕХ КНОПОК ====================
print("\n\n📁 5. ВСЕ КНОПКИ (TextButton, ImageButton)")
print(string.rep("-", 80))

local allButtons = {}

-- В PlayerGui
if playerGui then
    for _, btn in pairs(playerGui:GetDescendants()) do
        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
            table.insert(allButtons, {
                obj = btn,
                location = "PlayerGui",
                parent = btn.Parent and btn.Parent.Name or "Unknown"
            })
        end
    end
end

-- В Character
if character then
    for _, btn in pairs(character:GetDescendants()) do
        if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
            table.insert(allButtons, {
                obj = btn,
                location = "Character",
                parent = btn.Parent and btn.Parent.Name or "Unknown"
            })
        end
    end
end

print(string.format("Всего найдено видимых кнопок: %d\n", #allButtons))

-- Группируем по местоположению
local byLocation = {}
for _, btn in ipairs(allButtons) do
    if not byLocation[btn.location] then
        byLocation[btn.location] = {}
    end
    table.insert(byLocation[btn.location], btn)
end

for location, buttons in pairs(byLocation) do
    print(string.format("\n  📍 В %s: %d кнопок", location, #buttons))
    for i, btn in ipairs(buttons) do
        if i <= 10 then  -- Показываем первые 10
            local text = ""
            if btn.obj:IsA("TextButton") then
                text = btn.obj.Text or ""
            end
            print(string.format("    %d. %s | Родитель: %s%s",
                i, btn.obj.Name, btn.parent,
                text ~= "" and " | Текст: '" .. text .. "'" or ""))
        end
    end
    if #buttons > 10 then
        print(string.format("    ... и еще %d кнопок", #buttons - 10))
    end
end

-- ==================== 6. СПЕЦИАЛЬНЫЙ ПОИСК "ИГРАТЬ" ====================
print("\n\n📁 6. СПЕЦИАЛЬНЫЙ ПОИСК КНОПКИ 'ИГРАТЬ'")
print(string.rep("-", 80))

local playButtons = {}

for _, btn in ipairs(allButtons) do
    local obj = btn.obj
    local name = obj.Name:lower()
    local path = obj:GetFullName():lower()

    -- Получаем текст
    local text = ""
    if obj:IsA("TextButton") then
        text = (obj.Text or ""):lower()
    end

    -- Ищем текст в дочерних TextLabel
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("TextLabel") and child.Text then
            text = text .. " " .. child.Text:lower()
        end
    end

    -- Проверяем на совпадение
    if text:find("играть") or text:find("play") or
       name:find("play") or name:find("start") or
       path:find("play") or path:find("start") then
        table.insert(playButtons, {
            obj = obj,
            text = text:gsub("^%s+", ""):gsub("%s+$", ""),
            location = btn.location,
            path = obj:GetFullName()
        })
    end
end

if #playButtons > 0 then
    print(string.format("✅ Найдено потенциальных кнопок 'Играть': %d\n", #playButtons))
    for i, btn in ipairs(playButtons) do
        print(string.format("  %d. %s", i, btn.obj.Name))
        print(string.format("     Местоположение: %s", btn.location))
        if btn.text ~= "" then
            print(string.format("     Текст: '%s'", btn.text))
        end
        print(string.format("     Путь: %s", btn.path))
        print("")
    end
else
    print("❌ Кнопки 'Играть' не найдены")
end

-- ==================== ИТОГИ ====================
print("\n" .. string.rep("=", 80))
print("✅ ИССЛЕДОВАНИЕ ЗАВЕРШЕНО")
print(string.rep("=", 80))
print("\n💡 Используйте найденные пути для доступа к элементам")
print("   Например: player.PlayerGui.ScreenGuiName.ButtonName")
print(string.rep("=", 80))
