--[[
    Snow - Kvizzi Menu
    Связь: @Kvizzi
    Ключ: key12345
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Создаем основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SnowMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Функция для анимаций
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenObj = TweenService:Create(obj, tweenInfo, props)
    tweenObj:Play()
    return tweenObj
end

-- 2. Функция показа уведомления
local function showNotification(title, text, icon)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    notification.BorderSizePixel = 0
    notification.ZIndex = 100
    notification.Parent = ScreenGui
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = title .. ": " .. text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = notification
    
    notification.Position = UDim2.new(1, 300, 1, -100)
    tween(notification, {Position = UDim2.new(1, -320, 1, -100)}, 0.3)
    
    task.spawn(function()
        task.wait(3)
        tween(notification, {Position = UDim2.new(1, 300, 1, -100)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- 3. Функция настройки привязки клавиши
local function setupKeyBind()
    print("✅ Key bind setup completed!")
    showNotification("Success", "Press LControl to open menu", "✅")
end

-- 4. Экран ввода ключа
local function createKeyInput()
    print("DEBUG: Creating key input screen")
    
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 400, 0, 250)
    keyFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    keyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    keyFrame.BorderSizePixel = 0
    keyFrame.ZIndex = 10
    keyFrame.Parent = ScreenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 0, 40)
    title.Position = UDim2.new(0.5, -150, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Snow - Kvizzi"
    title.TextColor3 = Color3.fromRGB(0, 150, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = keyFrame
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(0, 350, 0, 40)
    description.Position = UDim2.new(0.5, -175, 0, 60)
    description.BackgroundTransparency = 1
    description.Text = "Enter key to continue\nif u want to get key, write me: @Kvizzi"
    description.TextColor3 = Color3.fromRGB(255, 255, 255)
    description.TextSize = 14
    description.Font = Enum.Font.Gotham
    description.Parent = keyFrame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0, 300, 0, 40)
    keyBox.Position = UDim2.new(0.5, -150, 0.5, -20)
    keyBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.Text = ""
    keyBox.PlaceholderText = "Enter key here..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyBox.TextSize = 16
    keyBox.Font = Enum.Font.Gotham
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = keyFrame
    
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0, 100, 0, 40)
    submitButton.Position = UDim2.new(0.5, -50, 0.8, -20)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Text = "SUBMIT"
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.GothamBold
    submitButton.Parent = keyFrame
    
    submitButton.MouseButton1Click:Connect(function()
        print("DEBUG: Submit button clicked, key entered:", keyBox.Text)
        if keyBox.Text == "key12345" then
            showNotification("✅ Success", "Welcome to Snow - Kvizzi!", "✅")
            task.wait(0.5)
            keyFrame:Destroy()
            setupKeyBind()
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Wrong key! Try again..."
            showNotification("❌ Error", "Invalid key!", "❌")
        end
    end)
    
    print("DEBUG: Key input screen created successfully")
end

-- 5. Прогресс бар загрузки
local function createLoadingScreen()
    print("DEBUG: Creating loading screen")
    
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 400, 0, 250)
    loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ZIndex = 10
    loadingFrame.Parent = ScreenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0.5, -100, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Snow - Kvizzi"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = loadingFrame
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(0, 350, 0, 40)
    description.Position = UDim2.new(0.5, -175, 0, 80)
    description.BackgroundTransparency = 1
    description.Text = "if u want to get key, write me: @Kvizzi"
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 14
    description.Font = Enum.Font.Gotham
    description.Parent = loadingFrame
    
    local progressBarBack = Instance.new("Frame")
    progressBarBack.Size = UDim2.new(0, 300, 0, 20)
    progressBarBack.Position = UDim2.new(0.5, -150, 0.7, -10)
    progressBarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBarBack.BorderSizePixel = 0
    progressBarBack.Parent = loadingFrame
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBack
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.TextSize = 14
    progressText.Font = Enum.Font.GothamBold
    progressText.Parent = progressBarBack
    
    -- Исправленная анимация загрузки
    local progress = 0
    local connection
    connection = RunService.RenderStepped:Connect(function()
        progress = math.min(progress + 0.5, 100)
        progressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
        progressText.Text = math.floor(progress) .. "%"
        
        if progress >= 100 then
            progressBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            connection:Disconnect()  -- Останавливаем цикл ПЕРВЫМ делом
            
            -- Удаляем загрузочный экран и создаем экран ввода ключа
            task.spawn(function()
                task.wait(0.5)
                loadingFrame:Destroy()
                createKeyInput()  -- Создаем новое меню
            end)
        end
    end)
    
    print("DEBUG: Loading screen created successfully")
end

-- Запускаем скрипт
print("=== SNOW MENU STARTING ===")
print("1. Functions check:")
print("   - createLoadingScreen:", type(createLoadingScreen) == "function" and "✅ OK" or "❌ MISSING")
print("   - createKeyInput:", type(createKeyInput) == "function" and "✅ OK" or "❌ MISSING")
print("   - setupKeyBind:", type(setupKeyBind) == "function" and "✅ OK" or "❌ MISSING")
print("   - showNotification:", type(showNotification) == "function" and "✅ OK" or "❌ MISSING")
print("   - tween:", type(tween) == "function" and "✅ OK" or "❌ MISSING")
print("=== STARTING LOADING SCREEN ===")

createLoadingScreen()

print("✅ All functions defined correctly!")
