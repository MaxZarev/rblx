-- работающий код по клику кнопки при входе на сервер
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local playButton = playerGui:WaitForChild("NewsApp")
    :WaitForChild("EnclosingFrame")
    :WaitForChild("MainFrame")
    :WaitForChild("Buttons")
    :WaitForChild("PlayButton")

local VirtualInputManager = game:GetService("VirtualInputManager")

local absolutePos = playButton.AbsolutePosition
local absoluteSize = playButton.AbsoluteSize

-- Получаем inset от TopBar
local guiInset = game:GetService("GuiService"):GetGuiInset()

-- Координаты центра кнопки С учётом inset
local centerX = absolutePos.X + absoluteSize.X / 2
local centerY = absolutePos.Y + absoluteSize.Y / 2 + guiInset.Y

-- Клик
VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
task.wait(0.05)
VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)

print("Кнопка PlayButton нажата!")



-- поиск и проверка видимости кнопки 

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")

local function findPlayButton()
    local newsApp = playerGui and playerGui:FindFirstChild("NewsApp")
    
    -- Проверяем что ScreenGui включён
    if not newsApp or newsApp.Enabled == false then
        return nil
    end
    
    local enclosingFrame = newsApp:FindFirstChild("EnclosingFrame")
    local mainFrame = enclosingFrame and enclosingFrame:FindFirstChild("MainFrame")
    local buttons = mainFrame and mainFrame:FindFirstChild("Buttons")
    local playButton = buttons and buttons:FindFirstChild("PlayButton")
    
    return playButton
end

local playButton = findPlayButton()

if playButton then
    print("Кнопка найдена и видима!")
else
    print("Кнопка не найдена или скрыта!")
end


