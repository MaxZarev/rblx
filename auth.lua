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

return Auth
