local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local infiniteJumpEnabled = false

-- Создаем кнопку
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.85, 0, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
button.Text = "Выкл"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.Parent = screenGui

local isDragging = false
local dragStart

-- Обработка нажатия
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        dragStart = input.Position
    end
end)

-- Обработка отпускания
button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and not isDragging then
        infiniteJumpEnabled = not infiniteJumpEnabled
        
        if infiniteJumpEnabled then
            button.BackgroundColor3 = Color3.fromRGB(60, 220, 60)
            button.Text = "Вкл"
        else
            button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
            button.Text = "Выкл"
        end
    end
    isDragging = false
end)

-- Перетаскивание
button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragStart then
        local dragDistance = (input.Position - dragStart).Magnitude
        if dragDistance > 10 then
            isDragging = true
            button.Position = UDim2.new(0, input.Position.X - 50, 0, input.Position.Y - 25)
        end
    end
end)

-- Бесконечный прыжок
UIS.JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

print("Телефонный бесконечный прыжок загружен!")
