--[[
    Snow - Kvizzi Menu
    Связь: @Kvizzi
    Ключ: key12345
    Открытие меню: LControl (левый Ctrl)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Создаем основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SnowMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
local isMenuOpen = false
local mainFrame = nil
local menuToggleKey = Enum.KeyCode.LeftControl

-- Функция для анимаций
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenObj = TweenService:Create(obj, tweenInfo, props)
    tweenObj:Play()
    return tweenObj
end

-- Функция показа уведомления (уже с обводкой и закругленными краями)
local function showNotification(title, text, icon)
    if not notificationsEnabled then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 280, 0, 60)  -- Уже и меньше
    notification.Position = UDim2.new(1, -300, 1, -80)
    notification.BackgroundColor3 = themes[currentTheme].header
    notification.BorderSizePixel = 1
    notification.BorderColor3 = themes[currentTheme].accent
    notification.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 15, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "ℹ️"
    iconLabel.TextColor3 = themes[currentTheme].accent
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 200, 0, 20)
    titleLabel.Position = UDim2.new(0, 55, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = themes[currentTheme].accent
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 25)
    textLabel.Position = UDim2.new(0, 55, 0, 30)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = themes[currentTheme].text
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    
    notification.Parent = ScreenGui
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 280, 1, -80)
    tween(notification, {Position = UDim2.new(1, -300, 1, -80)}, 0.3)
    
    -- Автоматическое скрытие через 3 секунды
    task.spawn(function()
        task.wait(3)
        tween(notification, {Position = UDim2.new(1, 280, 1, -80)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Функция настройки привязки клавиши
local function setupKeyBind()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == menuToggleKey then
            if not isMenuOpen then
                createMainMenu()
            else
                closeMenu()
            end
        end
    end)
    
    showNotification("Key Bind", "Press LControl to open menu", "⌨️")
end

-- Функция закрытия меню
local function closeMenu()
    if not mainFrame then return end
    
    isMenuOpen = false
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    task.wait(0.3)
    mainFrame:Destroy()
    mainFrame = nil
end

-- Функция открытия меню
local function openMenu()
    if isMenuOpen then
        closeMenu()
        return
    end
    isMenuOpen = true
    createMainMenu()
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
end

-- Прогресс бар загрузки
local function createLoadingScreen()
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 400, 0, 250)
    loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ZIndex = 10
    loadingFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = loadingFrame
    
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
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBarBack
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBack
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, 4)
    progressFillCorner.Parent = progressBar
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = "0%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.TextSize = 14
    progressText.Font = Enum.Font.GothamBold
    progressText.Parent = progressBarBack
    
    local progress = 0
    local connection
    connection = RunService.RenderStepped:Connect(function()
        progress = math.min(progress + 0.5, 100)
        progressBar.Size = UDim2.new(progress / 100, 0, 1, 0)
        progressText.Text = math.floor(progress) .. "%"
        
        if progress >= 100 then
            progressBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            connection:Disconnect()
            
            task.spawn(function()
                task.wait(0.5)
                loadingFrame:Destroy()
                createKeyInput()
            end)
        end
    end)
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
    sidebar.Size = UDim2.new(0, 100, 0, 310)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = themes[currentTheme].header
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0, 350, 0, 310)
    contentFrame.Position = UDim2.new(0, 100, 0, 40)
    contentFrame.BackgroundColor3 = themes[currentTheme].bg
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    local sections = {
        main = "🏠 Main",
        tech = "🔧 Tech",
        extra = "⭐ Extra",
        settings = "⚙️ Settings"
    }
    
    local currentSection = "main"
    local sectionFrames = {}
    
    local function switchSection(section)
        currentSection = section
        
        for name, frame in pairs(sectionFrames) do
            frame.Visible = (name == section)
        end
        
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn.Name == section and themes[currentTheme].accent or themes[currentTheme].button
            end
        end
    end
    
    local buttonY = 10
    for name, text in pairs(sections) do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 80, 0, 35)
        button.Position = UDim2.new(0, 10, 0, buttonY)
        button.BackgroundColor3 = name == "main" and themes[currentTheme].accent or themes[currentTheme].button
        button.TextColor3 = themes[currentTheme].text
        button.Text = text
        button.TextSize = 12
        button.Font = Enum.Font.Gotham
        button.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(function()
            switchSection(name)
        end)
        
        buttonY = buttonY + 40
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
    speedLabel.Text = "Speed: 16"
    speedLabel.TextColor3 = themes[currentTheme].text
    speedLabel.TextSize = 16
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = mainSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 30)
    jumpLabel.Position = UDim2.new(0, 20, 0, 70)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump: 50"
    jumpLabel.TextColor3 = themes[currentTheme].text
    jumpLabel.TextSize = 16
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = mainSection
    
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
    
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(0, 120, 0, 30)
    themeLabel.Position = UDim2.new(0, 20, 0, settingsY)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "🎨 Theme: dark"
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
    
    settingsY = settingsY + 40
    
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
    
    settingsY = settingsY + 40
    
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
    
    settingsY = settingsY + 50
    
    local exitButton = Instance.new("TextButton")
    exitButton.Size = UDim2.new(0, 200, 0, 40)
    exitButton.Position = UDim2.new(0.5, -100, 0, settingsY)
    exitButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitButton.Text = "❌ Exit Script"
    exitButton.TextSize = 16
    exitButton.Font = Enum.Font.GothamBold
    exitButton.Parent = settingsSection
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 4)
    exitCorner.Parent = exitButton
    
    exitButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        showNotification("Exit", "Script ended", "👋")
    end)
    
    -- Анимация открытия меню
    tween(mainFrame, {Size = UDim2.new(0, 450, 0, 350), Position = UDim2.new(0.5, -225, 0.5, -175)}, 0.3)
end

-- Запускаем скрипт
createLoadingScreen()
