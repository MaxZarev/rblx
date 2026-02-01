-- Универсальная поддержка разных эксплоитов
local write = writefile or write_file or (syn and syn.write_file)
local read = readfile or read_file or (syn and syn.read_file)
local checkfile = isfile or isfile_custom or (syn and syn.is_file)
local deletefile = delfile or delete_file or (syn and syn.delete_file)

local Auth = {}

-- Функция запроса пароля через GUI
local function requestPassword()
    local password = ""
    local entered = false

    -- Создаём GUI для ввода пароля
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local TextBox = Instance.new("TextBox")
    local Button = Instance.new("TextButton")

    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 350, 0, 200)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BorderSizePixel = 0

    Title.Parent = Frame
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = "Введите API ключ"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 20
    Title.Font = Enum.Font.SourceSansBold

    TextBox.Parent = Frame
    TextBox.Size = UDim2.new(0.85, 0, 0, 40)
    TextBox.Position = UDim2.new(0.075, 0, 0.35, 0)
    TextBox.PlaceholderText = "Введите ваш API ключ"
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.new(1, 1, 1)
    TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TextBox.BorderSizePixel = 0
    TextBox.Font = Enum.Font.SourceSans
    TextBox.TextSize = 18
    TextBox.ClearTextOnFocus = false

    Button.Parent = Frame
    Button.Size = UDim2.new(0.85, 0, 0, 45)
    Button.Position = UDim2.new(0.075, 0, 0.65, 0)
    Button.Text = "Войти"
    Button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Button.BorderSizePixel = 0
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 18

    Button.MouseButton1Click:Connect(function()
        password = TextBox.Text
        entered = true
        ScreenGui:Destroy()
    end)

    -- Ждём ввода
    repeat task.wait(0.1) until entered

    return password
end

-- Создание постоянного меню в левом нижнем углу
local function createSettingsMenu()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local PasswordBox = Instance.new("TextBox")
    local SaveButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")

    ScreenGui.Name = "AuthSettingsMenu"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    Frame.Parent = ScreenGui
    Frame.Size = UDim2.new(0, 280, 0, 160)
    Frame.Position = UDim2.new(0, 10, 1, -170)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 1
    Frame.BorderColor3 = Color3.fromRGB(60, 60, 60)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame

    Title.Parent = Frame
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "🔑 API Ключ"
    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
    Title.TextSize = 16
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    PasswordBox.Name = "PasswordBox"
    PasswordBox.Parent = Frame
    PasswordBox.Size = UDim2.new(1, -20, 0, 35)
    PasswordBox.Position = UDim2.new(0, 10, 0, 40)
    PasswordBox.PlaceholderText = "Введите API ключ"
    PasswordBox.Text = ""
    PasswordBox.TextColor3 = Color3.new(1, 1, 1)
    PasswordBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    PasswordBox.BorderSizePixel = 1
    PasswordBox.BorderColor3 = Color3.fromRGB(70, 70, 70)
    PasswordBox.Font = Enum.Font.SourceSans
    PasswordBox.TextSize = 16
    PasswordBox.ClearTextOnFocus = false
    PasswordBox.TextXAlignment = Enum.TextXAlignment.Left

    local PasswordUICorner = Instance.new("UICorner")
    PasswordUICorner.CornerRadius = UDim.new(0, 4)
    PasswordUICorner.Parent = PasswordBox

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 8)
    UIPadding.Parent = PasswordBox

    SaveButton.Parent = Frame
    SaveButton.Size = UDim2.new(1, -20, 0, 35)
    SaveButton.Position = UDim2.new(0, 10, 0, 85)
    SaveButton.Text = "💾 Сохранить"
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    SaveButton.BorderSizePixel = 0
    SaveButton.TextColor3 = Color3.new(1, 1, 1)
    SaveButton.Font = Enum.Font.SourceSansBold
    SaveButton.TextSize = 16

    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 4)
    ButtonUICorner.Parent = SaveButton

    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = Frame
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 130)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
    StatusLabel.TextSize = 13
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

    -- Маскировка текста точками
    local actualPassword = ""
    PasswordBox:GetPropertyChangedSignal("Text"):Connect(function()
        local currentText = PasswordBox.Text
        
        if #currentText > #actualPassword then
            actualPassword = actualPassword .. currentText:sub(#actualPassword + 1)
        elseif #currentText < #actualPassword then
            actualPassword = currentText
        end
        
        PasswordBox.Text = string.rep("•", #actualPassword)
    end)

    -- Обработчик кнопки сохранения
    SaveButton.MouseButton1Click:Connect(function()
        if actualPassword and actualPassword ~= "" then
            if write and type(write) == "function" then
                local success = pcall(function()
                    write("password.txt", actualPassword)
                end)
                
                if success then
                    StatusLabel.Text = "✓ Ключ сохранён"
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
                else
                    StatusLabel.Text = "✗ Ошибка сохранения"
                    StatusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
                end
            else
                StatusLabel.Text = "✗ Функция недоступна"
                StatusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
            end
            
            task.delay(3, function()
                StatusLabel.Text = ""
            end)
        else
            StatusLabel.Text = "⚠ Введите ключ"
            StatusLabel.TextColor3 = Color3.fromRGB(200, 150, 100)
            
            task.delay(2, function()
                StatusLabel.Text = ""
            end)
        end
    end)

    return ScreenGui
end

-- Получение API ключа (с кэшированием)
function Auth.getApiKey()
    -- Проверяем кэш
    if checkfile and read and type(checkfile) == "function" and type(read) == "function" then
        local success, fileExists = pcall(function()
            return checkfile("password.txt")
        end)

        if success and fileExists then
            local readSuccess, result = pcall(function()
                return read("password.txt")
            end)

            if readSuccess and result and result ~= "" then
                print("✓ API ключ загружен из кэша")
                return result
            end
        end
    end

    -- Запрашиваем пароль
    print("Запрос API ключа...")
    local API_KEY = requestPassword()

    if not API_KEY or API_KEY == "" then
        error("API ключ не введён!")
    end

    -- Сохраняем
    if write and type(write) == "function" then
        pcall(function()
            write("password.txt", API_KEY)
            print("✓ API ключ сохранён")
        end)
    end

    return API_KEY
end

-- Сброс сохранённого пароля
function Auth.resetPassword()
    if deletefile and checkfile then
        local success, fileExists = pcall(function()
            return checkfile("password.txt")
        end)

        if success and fileExists then
            local deleteSuccess = pcall(function()
                deletefile("password.txt")
            end)

            if deleteSuccess then
                print("✓ Сохранённый пароль удалён")
                return true
            else
                print("✗ Не удалось удалить файл пароля")
                return false
            end
        else
            print("⚠ Файл пароля не найден")
            return false
        end
    else
        print("⚠ Функция удаления файлов недоступна")
        return false
    end
end

-- Инициализация меню настроек
function Auth.initSettingsMenu()
    pcall(function()
        local existingGui = game.CoreGui:FindFirstChild("AuthSettingsMenu")
        if existingGui then
            existingGui:Destroy()
        end
    end)
    
    return createSettingsMenu()
end

return Auth
