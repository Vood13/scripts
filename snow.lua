--[[
    Snow - Kvizzi Menu
    Связь: @Kvizzi
    Ключ: key12345
    Открытие меню: LControl (левый Ctrl)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")

-- Настройки темы
local themes = {
    dark = {
        bg = Color3.fromRGB(25, 25, 35),
        header = Color3.fromRGB(35, 35, 45),
        text = Color3.fromRGB(255, 255, 255),
        accent = Color3.fromRGB(0, 150, 255),
        button = Color3.fromRGB(45, 45, 55),
        slider = Color3.fromRGB(0, 150, 255)
    },
    white = {
        bg = Color3.fromRGB(245, 245, 245),
        header = Color3.fromRGB(230, 230, 230),
        text = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 100, 200),
        button = Color3.fromRGB(220, 220, 220),
        slider = Color3.fromRGB(0, 100, 200)
    },
    green = {
        bg = Color3.fromRGB(20, 40, 20),
        header = Color3.fromRGB(30, 60, 30),
        text = Color3.fromRGB(220, 255, 220),
        accent = Color3.fromRGB(100, 255, 100),
        button = Color3.fromRGB(40, 80, 40),
        slider = Color3.fromRGB(100, 255, 100)
    },
    red = {
        bg = Color3.fromRGB(40, 20, 20),
        header = Color3.fromRGB(60, 30, 30),
        text = Color3.fromRGB(255, 220, 220),
        accent = Color3.fromRGB(255, 100, 100),
        button = Color3.fromRGB(80, 40, 40),
        slider = Color3.fromRGB(255, 100, 100)
    }
}

local currentTheme = "dark"
local notificationsEnabled = true
local settings = {
    speed = 16,
    jump = 50,
    noclip = false,
    fly = false
}

-- Создаем основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SnowMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Переменные для управления меню
local isMenuOpen = false
local mainFrame = nil
local menuToggleKey = Enum.KeyCode.LeftControl
local keyInputConnections = {}
local updateConnections = {}

-- Функция для анимаций
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Функция показа уведомления
local function showNotification(title, text, icon)
    if not notificationsEnabled then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = themes[currentTheme].header
    notification.BorderSizePixel = 0
    notification.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 20, 0.5, -20)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "ℹ️"
    iconLabel.TextColor3 = themes[currentTheme].accent
    iconLabel.TextSize = 24
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 220, 0, 25)
    titleLabel.Position = UDim2.new(0, 70, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = themes[currentTheme].accent
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 220, 0, 35)
    textLabel.Position = UDim2.new(0, 70, 0, 40)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = themes[currentTheme].text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    
    notification.Parent = ScreenGui
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 300, 1, -100)
    tween(notification, {Position = UDim2.new(1, -320, 1, -100)}, 0.3)
    
    -- Автоматическое скрытие через 5 секунд
    task.spawn(function()
        task.wait(5)
        tween(notification, {Position = UDim2.new(1, 300, 1, -100)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Функция получения реального времени через HTTP
local function getRealTime()
    local success, result = pcall(function()
        -- Используем TimeAPI для получения времени
        local response = HttpService:GetAsync("http://worldtimeapi.org/api/timezone/Europe/Moscow")
        local data = HttpService:JSONDecode(response)
        return data.datetime
    end)
    
    if success and result then
        return result
    else
        -- Если HTTP запрос не удался, используем локальное время
        return os.date("%Y-%m-%d %H:%M:%S")
    end
end

-- Функция получения пинга
local function getPing()
    if StatsService and StatsService.Network then
        local pingStat = StatsService.Network.ServerStatsItem["Data Ping"]
        if pingStat then
            return math.floor(pingStat:GetValue())
        end
    end
    return 0
end

-- Функция закрытия меню
local function closeMenu()
    if not mainFrame then return end
    
    isMenuOpen = false
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    task.wait(0.3)
    mainFrame:Destroy()
    mainFrame = nil
    
    -- Очищаем соединения для обновлений
    for _, connection in pairs(updateConnections) do
        connection:Disconnect()
    end
    updateConnections = {}
    
    showNotification("Menu", "Menu closed", "📱")
end

-- Функция открытия меню
local function openMenu()
    if isMenuOpen then
        closeMenu()
        return
    end
    
    isMenuOpen = true
    createMainMenu()
    showNotification("Menu", "Menu opened", "📱")
end

-- Функция для форматирования времени
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Прогресс бар загрузки
local function createLoadingScreen()
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(1, 0, 1, 0)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ZIndex = 10
    loadingFrame.Parent = ScreenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0.5, -100, 0.4, -20)
    title.BackgroundTransparency = 1
    title.Text = "Snow - Kvizzi"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = loadingFrame
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(0, 400, 0, 20)
    description.Position = UDim2.new(0.5, -200, 0.5, -10)
    description.BackgroundTransparency = 1
    description.Text = "if u want to get key, write me: @Kvizzi"
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 14
    description.Font = Enum.Font.Gotham
    description.Parent = loadingFrame
    
    local progressBarBack = Instance.new("Frame")
    progressBarBack.Size = UDim2.new(0, 300, 0, 20)
    progressBarBack.Position = UDim2.new(0.5, -150, 0.6, -10)
    progressBarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBarBack.BorderSizePixel = 0
    progressBarBack.Parent = loadingFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = progressBarBack
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBack
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBar
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.TextSize = 14
    progressText.Font = Enum.Font.GothamBold
    progressText.Parent = progressBarBack
    
    -- Анимация загрузки
    local progress = 0
    local connection
    connection = RunService.RenderStepped:Connect(function()
        progress = math.min(progress + 0.5, 100)
        progressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
        progressText.Text = math.floor(progress) .. "%"
        
        if progress == 100 then
            progressBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            connection:Disconnect()
            
            -- Задержка перед показом ввода ключа
            task.wait(0.5)
            loadingFrame:Destroy()
            createKeyInput()
        end
    end)
end

-- Экран ввода ключа
local function createKeyInput()
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 400, 0, 250)
    keyFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    keyFrame.BackgroundColor3 = themes[currentTheme].bg
    keyFrame.BorderSizePixel = 0
    keyFrame.ZIndex = 10
    keyFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = keyFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 0, 40)
    title.Position = UDim2.new(0.5, -150, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Snow - Kvizzi"
    title.TextColor3 = themes[currentTheme].accent
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = keyFrame
    
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(0, 350, 0, 40)
    description.Position = UDim2.new(0.5, -175, 0, 60)
    description.BackgroundTransparency = 1
    description.Text = "Enter key to continue\nif u want to get key, write me: @Kvizzi"
    description.TextColor3 = themes[currentTheme].text
    description.TextSize = 14
    description.Font = Enum.Font.Gotham
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextWrapped = true
    description.Parent = keyFrame
    
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0, 300, 0, 40)
    keyBox.Position = UDim2.new(0.5, -150, 0.5, -20)
    keyBox.BackgroundColor3 = themes[currentTheme].button
    keyBox.TextColor3 = themes[currentTheme].text
    keyBox.Text = ""
    keyBox.PlaceholderText = "Enter key here..."
    keyBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyBox.TextSize = 16
    keyBox.Font = Enum.Font.Gotham
    keyBox.ClearTextOnFocus = false
    keyBox.Parent = keyFrame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = keyBox
    
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0, 100, 0, 40)
    submitButton.Position = UDim2.new(0.5, -50, 0.8, -20)
    submitButton.BackgroundColor3 = themes[currentTheme].accent
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Text = "SUBMIT"
    submitButton.TextSize = 16
    submitButton.Font = Enum.Font.GothamBold
    submitButton.Parent = keyFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = submitButton
    
    submitButton.MouseButton1Click:Connect(function()
        if keyBox.Text == "key12345" then
            showNotification("✅ Success", "Welcome to Snow - Kvizzi! Press LControl to open menu", "✅")
            task.wait(0.5)
            keyFrame:Destroy()
            setupKeyBind()
        else
            keyBox.Text = ""
            keyBox.PlaceholderText = "Wrong key! Try again..."
            showNotification("❌ Error", "Invalid key!", "❌")
        end
    end)
    
    -- Анимация появления
    keyFrame.Position = UDim2.new(0.5, -200, 0.3, 0)
    keyFrame.BackgroundTransparency = 1
    tween(keyFrame, {Position = UDim2.new(0.5, -200, 0.5, -125), BackgroundTransparency = 0}, 0.5)
end

-- Настройка привязки клавиши
local function setupKeyBind()
    -- Очищаем старые соединения
    for _, connection in pairs(keyInputConnections) do
        connection:Disconnect()
    end
    keyInputConnections = {}
    
    -- Назначаем клавишу для открытия/закрытия меню
    table.insert(keyInputConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == menuToggleKey then
            openMenu()
        end
    end))
    
    showNotification("Key Bind", "Menu toggle key set to: LControl", "⌨️")
end

-- Главное меню
local function createMainMenu()
    if mainFrame then
        mainFrame:Destroy()
    end
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = themes[currentTheme].bg
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = themes[currentTheme].header
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0.5, -100, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Snow - Kvizzi"
    title.TextColor3 = themes[currentTheme].accent
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = topBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        closeMenu()
    end)
    
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 120, 0, 360)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = themes[currentTheme].header
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0, 380, 0, 360)
    contentFrame.Position = UDim2.new(0, 120, 0, 40)
    contentFrame.BackgroundColor3 = themes[currentTheme].bg
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- Создаем разделы
    local sections = {
        main = "🏠 Main",
        tech = "🔧 Tech",
        extra = "⭐ Extra",
        settings = "⚙️ Settings"
    }
    
    local currentSection = "main"
    local sectionFrames = {}
    
    -- Функция смены раздела
    local function switchSection(section)
        currentSection = section
        
        for name, frame in pairs(sectionFrames) do
            frame.Visible = (name == section)
        end
        
        -- Обновляем кнопки
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn.Name == section and themes[currentTheme].accent or themes[currentTheme].button
            end
        end
    end
    
    -- Создаем кнопки сайдбара
    local buttonY = 10
    for name, text in pairs(sections) do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 100, 0, 40)
        button.Position = UDim2.new(0, 10, 0, buttonY)
        button.BackgroundColor3 = name == "main" and themes[currentTheme].accent or themes[currentTheme].button
        button.TextColor3 = themes[currentTheme].text
        button.Text = text
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            switchSection(name)
        end)
        
        buttonY = buttonY + 50
    end
    
    -- Раздел Main
    local mainSection = Instance.new("Frame")
    mainSection.Size = UDim2.new(1, 0, 1, 0)
    mainSection.BackgroundTransparency = 1
    mainSection.Parent = contentFrame
    sectionFrames.main = mainSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 100, 0, 30)
    speedLabel.Position = UDim2.new(0, 20, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. settings.speed
    speedLabel.TextColor3 = themes[currentTheme].text
    speedLabel.TextSize = 16
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainSection
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(0, 200, 0, 20)
    speedSlider.Position = UDim2.new(0, 130, 0, 25)
    speedSlider.BackgroundColor3 = themes[currentTheme].button
    speedSlider.Parent = mainSection
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = speedSlider
    
    local speedFill = Instance.new("Frame")
    speedFill.Size = UDim2.new((settings.speed - 16) / (100 - 16), 0, 1, 0)
    speedFill.BackgroundColor3 = themes[currentTheme].slider
    speedFill.BorderSizePixel = 0
    speedFill.Parent = speedSlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = speedFill
    
    local speedInput = Instance.new("TextBox")
    speedInput.Size = UDim2.new(0, 60, 0, 30)
    speedInput.Position = UDim2.new(0, 340, 0, 20)
    speedInput.BackgroundColor3 = themes[currentTheme].button
    speedInput.TextColor3 = themes[currentTheme].text
    speedInput.Text = tostring(settings.speed)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.Parent = mainSection
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = speedInput
    
    -- Обработчик слайдера скорости
    local dragging = false
    speedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    speedSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local relativeX = (pos.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            settings.speed = math.floor(16 + relativeX * (100 - 16))
            speedFill.Size = UDim2.new(relativeX, 0, 1, 0)
            speedLabel.Text = "Speed: " .. settings.speed
            speedInput.Text = tostring(settings.speed)
            
            -- Применяем скорость к игроку
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = settings.speed
                end
            end
        end
    end)
    
    speedInput.FocusLost:Connect(function()
        local num = tonumber(speedInput.Text)
        if num then
            num = math.clamp(num, 16, 100)
            settings.speed = num
            speedInput.Text = tostring(num)
            speedLabel.Text = "Speed: " .. num
            speedFill.Size = UDim2.new((num - 16) / (100 - 16), 0, 1, 0)
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = num
                end
            end
        else
            speedInput.Text = tostring(settings.speed)
        end
    end)
    
    -- Прыжок
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 30)
    jumpLabel.Position = UDim2.new(0, 20, 0, 70)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump: " .. settings.jump
    jumpLabel.TextColor3 = themes[currentTheme].text
    jumpLabel.TextSize = 16
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = mainSection
    
    local jumpSlider = Instance.new("Frame")
    jumpSlider.Size = UDim2.new(0, 200, 0, 20)
    jumpSlider.Position = UDim2.new(0, 130, 0, 75)
    jumpSlider.BackgroundColor3 = themes[currentTheme].button
    jumpSlider.Parent = mainSection
    
    local jumpSliderCorner = Instance.new("UICorner")
    jumpSliderCorner.CornerRadius = UDim.new(0, 4)
    jumpSliderCorner.Parent = jumpSlider
    
    local jumpFill = Instance.new("Frame")
    jumpFill.Size = UDim2.new((settings.jump - 50) / (200 - 50), 0, 1, 0)
    jumpFill.BackgroundColor3 = themes[currentTheme].slider
    jumpFill.BorderSizePixel = 0
    jumpFill.Parent = jumpSlider
    
    local jumpFillCorner = Instance.new("UICorner")
    jumpFillCorner.CornerRadius = UDim.new(0, 4)
    jumpFillCorner.Parent = jumpFill
    
    local jumpInput = Instance.new("TextBox")
    jumpInput.Size = UDim2.new(0, 60, 0, 30)
    jumpInput.Position = UDim2.new(0, 340, 0, 70)
    jumpInput.BackgroundColor3 = themes[currentTheme].button
    jumpInput.TextColor3 = themes[currentTheme].text
    jumpInput.Text = tostring(settings.jump)
    jumpInput.TextSize = 14
    jumpInput.Font = Enum.Font.Gotham
    jumpInput.Parent = mainSection
    
    local jumpInputCorner = Instance.new("UICorner")
    jumpInputCorner.CornerRadius = UDim.new(0, 4)
    jumpInputCorner.Parent = jumpInput
    
    -- Обработчик слайдера прыжка
    local jumpDragging = false
    jumpSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            jumpDragging = true
        end
    end)
    
    jumpSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            jumpDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if jumpDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local relativeX = (pos.X - jumpSlider.AbsolutePosition.X) / jumpSlider.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            settings.jump = math.floor(50 + relativeX * (200 - 50))
            jumpFill.Size = UDim2.new(relativeX, 0, 1, 0)
            jumpLabel.Text = "Jump: " .. settings.jump
            jumpInput.Text = tostring(settings.jump)
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = settings.jump
                end
            end
        end
    end)
    
    jumpInput.FocusLost:Connect(function()
        local num = tonumber(jumpInput.Text)
        if num then
            num = math.clamp(num, 50, 200)
            settings.jump = num
            jumpInput.Text = tostring(num)
            jumpLabel.Text = "Jump: " .. num
            jumpFill.Size = UDim2.new((num - 50) / (200 - 50), 0, 1, 0)
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = num
                end
            end
        else
            jumpInput.Text = tostring(settings.jump)
        end
    end)
    
    -- Noclip toggle
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(0, 100, 0, 30)
    noclipLabel.Position = UDim2.new(0, 20, 0, 120)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "Noclip: OFF"
    noclipLabel.TextColor3 = themes[currentTheme].text
    noclipLabel.TextSize = 16
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.Parent = mainSection
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Size = UDim2.new(0, 50, 0, 25)
    noclipToggle.Position = UDim2.new(0, 130, 0, 125)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    noclipToggle.Text = ""
    noclipToggle.Parent = mainSection
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = noclipToggle
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 21, 0, 21)
    toggleCircle.Position = UDim2.new(0, 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = noclipToggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = toggleCircle
    
    noclipToggle.MouseButton1Click:Connect(function()
        settings.noclip = not settings.noclip
        if settings.noclip then
            tween(toggleCircle, {Position = UDim2.new(0, 27, 0, 2)}, 0.2)
            noclipToggle.BackgroundColor3 = themes[currentTheme].accent
            noclipLabel.Text = "Noclip: ON"
            showNotification("Noclip", "Noclip enabled!", "🚫")
        else
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
            noclipToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            noclipLabel.Text = "Noclip: OFF"
            showNotification("Noclip", "Noclip disabled!", "🚫")
        end
    end)
    
    -- Раздел Tech
    local techSection = Instance.new("Frame")
    techSection.Size = UDim2.new(1, 0, 1, 0)
    techSection.BackgroundTransparency = 1
    techSection.Visible = false
    techSection.Parent = contentFrame
    sectionFrames.tech = techSection
    
    local techIcon = Instance.new("TextLabel")
    techIcon.Size = UDim2.new(0, 100, 0, 100)
    techIcon.Position = UDim2.new(0.5, -50, 0.3, -50)
    techIcon.BackgroundTransparency = 1
    techIcon.Text = "🔧"
    techIcon.TextColor3 = themes[currentTheme].text
    techIcon.TextSize = 64
    techIcon.Font = Enum.Font.GothamBold
    techIcon.Parent = techSection
    
    local techText = Instance.new("TextLabel")
    techText.Size = UDim2.new(0, 200, 0, 40)
    techText.Position = UDim2.new(0.5, -100, 0.6, -20)
    techText.BackgroundTransparency = 1
    techText.Text = "Nope"
    techText.TextColor3 = themes[currentTheme].accent
    techText.TextSize = 32
    techText.Font = Enum.Font.GothamBold
    techText.Parent = techSection
    
    -- Раздел Extra
    local extraSection = Instance.new("Frame")
    extraSection.Size = UDim2.new(1, 0, 1, 0)
    extraSection.BackgroundTransparency = 1
    extraSection.Visible = false
    extraSection.Parent = contentFrame
    sectionFrames.extra = extraSection
    
    local extraText = Instance.new("TextLabel")
    extraText.Size = UDim2.new(1, -40, 1, -40)
    extraText.Position = UDim2.new(0, 20, 0, 20)
    extraText.BackgroundTransparency = 1
    extraText.Text = "This section is empty"
    extraText.TextColor3 = themes[currentTheme].text
    extraText.TextSize = 20
    extraText.Font = Enum.Font.Gotham
    extraText.TextYAlignment = Enum.TextYAlignment.Top
    extraText.TextWrapped = true
    extraText.Parent = extraSection
    
    -- Раздел Settings
    local settingsSection = Instance.new("Frame")
    settingsSection.Size = UDim2.new(1, 0, 1, 0)
    settingsSection.BackgroundTransparency = 1
    settingsSection.Visible = false
    settingsSection.Parent = contentFrame
    sectionFrames.settings = settingsSection
    
    local settingsY = 20
    
    -- Тема
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(0, 120, 0, 30)
    themeLabel.Position = UDim2.new(0, 20, 0, settingsY)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "🎨 Theme: " .. currentTheme
    themeLabel.TextColor3 = themes[currentTheme].text
    themeLabel.TextSize = 16
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Parent = settingsSection
    
    local themeButton = Instance.new("TextButton")
    themeButton.Size = UDim2.new(0, 100, 0, 30)
    themeButton.Position = UDim2.new(0, 150, 0, settingsY)
    themeButton.BackgroundColor3 = themes[currentTheme].button
    themeButton.TextColor3 = themes[currentTheme].text
    themeButton.Text = "Change"
    themeButton.TextSize = 14
    themeButton.Font = Enum.Font.Gotham
    themeButton.Parent = settingsSection
    
    local themeBtnCorner = Instance.new("UICorner")
    themeBtnCorner.CornerRadius = UDim.new(0, 4)
    themeBtnCorner.Parent = themeButton
    
    local themeDropdown = Instance.new("Frame")
    themeDropdown.Size = UDim2.new(0, 100, 0, 0)
    themeDropdown.Position = UDim2.new(0, 150, 0, settingsY + 35)
    themeDropdown.BackgroundColor3 = themes[currentTheme].header
    themeDropdown.Visible = false
    themeDropdown.ClipsDescendants = true
    themeDropdown.Parent = settingsSection
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = themeDropdown
    
    local themesList = {"dark", "white", "green", "red"}
    local dropdownOpen = false
    
    themeButton.MouseButton1Click:Connect(function()
        dropdownOpen = not dropdownOpen
        
        if dropdownOpen then
            themeDropdown.Size = UDim2.new(0, 100, 0, 0)
            themeDropdown.Visible = true
            
            -- Удаляем старые кнопки
            for _, child in ipairs(themeDropdown:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Создаем кнопки тем
            for i, themeName in ipairs(themesList) do
                local themeBtn = Instance.new("TextButton")
                themeBtn.Size = UDim2.new(0, 100, 0, 30)
                themeBtn.Position = UDim2.new(0, 0, 0, (i-1)*35)
                themeBtn.BackgroundColor3 = themes[themeName].button
                themeBtn.TextColor3 = themes[themeName].text
                themeBtn.Text = themeName:upper()
                themeBtn.TextSize = 12
                themeBtn.Font = Enum.Font.Gotham
                themeBtn.Parent = themeDropdown
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = themeBtn
                
                themeBtn.MouseButton1Click:Connect(function()
                    currentTheme = themeName
                    themeLabel.Text = "🎨 Theme: " .. currentTheme
                    
                    -- Применяем тему ко всему меню
                    mainFrame.BackgroundColor3 = themes[currentTheme].bg
                    topBar.BackgroundColor3 = themes[currentTheme].header
                    title.TextColor3 = themes[currentTheme].accent
                    sidebar.BackgroundColor3 = themes[currentTheme].header
                    contentFrame.BackgroundColor3 = themes[currentTheme].bg
                    
                    -- Обновляем кнопки
                    for _, btn in ipairs(sidebar:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.BackgroundColor3 = btn.Name == currentSection and themes[currentTheme].accent or themes[currentTheme].button
                            btn.TextColor3 = themes[currentTheme].text
                        end
                    end
                    
                    -- Закрываем dropdown
                    dropdownOpen = false
                    tween(themeDropdown, {Size = UDim2.new(0, 100, 0, 0)}, 0.2)
                    task.wait(0.2)
                    themeDropdown.Visible = false
                    
                    showNotification("Theme", "Theme changed to " .. themeName, "🎨")
                end)
            end
            
            tween(themeDropdown, {Size = UDim2.new(0, 100, 0, #themesList * 35)}, 0.2)
        else
            tween(themeDropdown, {Size = UDim2.new(0, 100, 0, 0)}, 0.2)
            task.wait(0.2)
            themeDropdown.Visible = false
        end
    end)
    
    settingsY = settingsY + 40
    
    -- Server Time через HTTP
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 200, 0, 30)
    timeLabel.Position = UDim2.new(0, 20, 0, settingsY)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "🕒 Server Time: Loading..."
    timeLabel.TextColor3 = themes[currentTheme].text
    timeLabel.TextSize = 16
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = settingsSection
    
    settingsY = settingsY + 35
    
    -- Ping
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Size = UDim2.new(0, 200, 0, 30)
    pingLabel.Position = UDim2.new(0, 20, 0, settingsY)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "📶 Ping: -- ms"
    pingLabel.TextColor3 = themes[currentTheme].text
    pingLabel.TextSize = 16
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Parent = settingsSection
    
    settingsY = settingsY + 35
    
    -- Notifications toggle
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(0, 120, 0, 30)
    notifLabel.Position = UDim2.new(0, 20, 0, settingsY)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "🔔 Notifications: ON"
    notifLabel.TextColor3 = themes[currentTheme].text
    notifLabel.TextSize = 16
    notifLabel.Font = Enum.Font.Gotham
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = settingsSection
    
    local notifToggle = Instance.new("TextButton")
    notifToggle.Size = UDim2.new(0, 50, 0, 25)
    notifToggle.Position = UDim2.new(0, 150, 0, settingsY + 2)
    notifToggle.BackgroundColor3 = themes[currentTheme].accent
    notifToggle.Text = ""
    notifToggle.Parent = settingsSection
    
    local notifToggleCorner = Instance.new("UICorner")
    notifToggleCorner.CornerRadius = UDim.new(0, 12)
    notifToggleCorner.Parent = notifToggle
    
    local notifCircle = Instance.new("Frame")
    notifCircle.Size = UDim2.new(0, 21, 0, 21)
    notifCircle.Position = UDim2.new(0, 27, 0, 2)
    notifCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notifCircle.Parent = notifToggle
    
    local notifCircleCorner = Instance.new("UICorner")
    notifCircleCorner.CornerRadius = UDim.new(0.5, 0)
    notifCircleCorner.Parent = notifCircle
    
    notifToggle.MouseButton1Click:Connect(function()
        notificationsEnabled = not notificationsEnabled
        if notificationsEnabled then
            tween(notifCircle, {Position = UDim2.new(0, 27, 0, 2)}, 0.2)
            notifToggle.BackgroundColor3 = themes[currentTheme].accent
            notifLabel.Text = "🔔 Notifications: ON"
            showNotification("Notifications", "Notifications enabled!", "🔔")
        else
            tween(notifCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
            notifToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            notifLabel.Text = "🔔 Notifications: OFF"
        end
    end)
    
    settingsY = settingsY + 40
    
    -- Bind Key для открытия меню
    local bindLabel = Instance.new("TextLabel")
    bindLabel.Size = UDim2.new(0, 120, 0, 30)
    bindLabel.Position = UDim2.new(0, 20, 0, settingsY)
    bindLabel.BackgroundTransparency = 1
    bindLabel.Text = "⌨️ Open Key: LControl"
    bindLabel.TextColor3 = themes[currentTheme].text
    bindLabel.TextSize = 16
    bindLabel.Font = Enum.Font.Gotham
    bindLabel.TextXAlignment = Enum.TextXAlignment.Left
    bindLabel.Parent = settingsSection
    
    local bindButton = Instance.new("TextButton")
    bindButton.Size = UDim2.new(0, 100, 0, 30)
    bindButton.Position = UDim2.new(0, 150, 0, settingsY)
    bindButton.BackgroundColor3 = themes[currentTheme].button
    bindButton.TextColor3 = themes[currentTheme].text
    bindButton.Text = "Change"
    bindButton.TextSize = 14
    bindButton.Font = Enum.Font.Gotham
    bindButton.Parent = settingsSection
    
    local bindBtnCorner = Instance.new("UICorner")
    bindBtnCorner.CornerRadius = UDim.new(0, 4)
    bindBtnCorner.Parent = bindButton
    
    bindButton.MouseButton1Click:Connect(function()
        bindButton.Text = "Press any key..."
        bindButton.BackgroundColor3 = themes[currentTheme].accent
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                menuToggleKey = input.KeyCode
                bindLabel.Text = "⌨️ Open Key: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                bindButton.Text = "Change"
                bindButton.BackgroundColor3 = themes[currentTheme].button
                connection:Disconnect()
                
                showNotification("Key Bind", "Menu key changed to: " .. tostring(input.KeyCode):gsub("Enum.KeyCode.", ""), "⌨️")
            end
        end)
    end)
    
    settingsY = settingsY + 40
    
    -- Exit button
    local exitButton = Instance.new("TextButton")
    exitButton.Size = UDim2.new(0, 200, 0, 40)
    exitButton.Position = UDim2.new(0.5, -100, 0, settingsY)
    exitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitButton.Text = "❌ Exit & End Script"
    exitButton.TextSize = 16
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Parent = settingsSection
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 4)
    exitCorner.Parent = exitButton
    
    exitButton.MouseButton1Click:Connect(function()
        showNotification("Exit", "Script ending...", "👋")
        task.wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Анимация открытия меню
    tween(mainFrame, {Size = UDim2.new(0, 500, 0, 400), Position = UDim2.new(0.5, -250, 0.5, -200)}, 0.3)
    
    -- Обновление времени и пинга в реальном времени
    table.insert(updateConnections, RunService.RenderStepped:Connect(function()
        -- Обновление времени каждую секунду
        if tick() % 1 < 0.05 then  -- Обновляем каждую секунду
            local currentTime = getRealTime()
            timeLabel.Text = "🕒 Server Time: " .. currentTime
        end
        
        -- Обновление пинга
        local ping = getPing()
        pingLabel.Text = "📶 Ping: " .. ping .. " ms"
    end))
    
    -- Noclip обработка
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        if settings.noclip and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    table.insert(updateConnections, noclipConnection)
    
    -- Очистка при уничтожении
    mainFrame.Destroying:Connect(function()
        for _, connection in pairs(updateConnections) do
            connection:Disconnect()
        end
        updateConnections = {}
    end)
end

-- Запускаем скрипт
createLoadingScreen()
