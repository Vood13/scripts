--[[
    Snow - Kvizzi Menu
    Связь: @Kvizzi
    Открытие меню: LControl (левый Ctrl)
    Меню можно двигать мышкой
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Создаем основной экран
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SnowMenu"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Настройки темы
local themes = {
    dark = {
        bg = Color3.fromRGB(20, 20, 30),
        header = Color3.fromRGB(30, 30, 40),
        text = Color3.fromRGB(240, 240, 245),
        accent = Color3.fromRGB(0, 170, 255),
        button = Color3.fromRGB(40, 40, 50),
        slider = Color3.fromRGB(0, 170, 255),
        border = Color3.fromRGB(50, 50, 60)
    },
    white = {
        bg = Color3.fromRGB(250, 250, 250),
        header = Color3.fromRGB(235, 235, 235),
        text = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 120, 215),
        button = Color3.fromRGB(225, 225, 225),
        slider = Color3.fromRGB(0, 120, 215),
        border = Color3.fromRGB(210, 210, 210)
    },
    neon = {
        bg = Color3.fromRGB(10, 10, 20),
        header = Color3.fromRGB(20, 20, 30),
        text = Color3.fromRGB(220, 255, 220),
        accent = Color3.fromRGB(0, 255, 170),
        button = Color3.fromRGB(30, 40, 40),
        slider = Color3.fromRGB(0, 255, 170),
        border = Color3.fromRGB(0, 100, 80)
    },
    purple = {
        bg = Color3.fromRGB(25, 15, 35),
        header = Color3.fromRGB(35, 25, 45),
        text = Color3.fromRGB(240, 220, 255),
        accent = Color3.fromRGB(170, 100, 255),
        button = Color3.fromRGB(45, 35, 55),
        slider = Color3.fromRGB(170, 100, 255),
        border = Color3.fromRGB(80, 50, 100)
    }
}

local currentTheme = "dark"
local notificationsEnabled = true
local isMenuOpen = false
local mainFrame = nil
local menuToggleKey = Enum.KeyCode.LeftControl
local keyBindConnection = nil
local playerSettings = {
    speed = 16,
    jump = 50,
    noclip = false
}
local noclipConnection = nil
local themeDropdown = nil
local dragging = false
local dragStart = nil
local menuStart = nil
local mouseButton1Down = false
local startTime = os.time()

-- Блокировка действий при открытом меню
local originalMouseIcon = nil
local actionsBlocked = false

-- Функция блокировки действий
local function toggleActions(block)
    if actionsBlocked == block then return end
    actionsBlocked = block
    
    if block then
        -- Сохраняем оригинальный курсор
        originalMouseIcon = UserInputService.MouseIcon
        
        -- Меняем курсор на стандартный
        UserInputService.MouseIcon = ""
        
        -- Блокируем клики по игре
        for _, conn in pairs(getconnections(UserInputService.InputBegan)) do
            -- Пытаемся отключить обработчики ввода
            pcall(function() conn:Disable() end)
        end
        
        showNotification("Game actions blocked", "🚫")
    else
        -- Восстанавливаем курсор
        if originalMouseIcon then
            UserInputService.MouseIcon = originalMouseIcon
        end
        
        showNotification("Game actions enabled", "✅")
    end
end

-- Получение времени
local function getServerTime()
    local success, result = pcall(function()
        return os.date("%H:%M:%S")
    end)
    return success and result or "00:00:00"
end

-- Получение пинга
local function getPing()
    local success, ping = pcall(function()
        if StatsService and StatsService.Network then
            local pingStat = StatsService.Network:FindFirstChild("ServerStatsItem")
            if pingStat then
                local dataPing = pingStat:FindFirstChild("Data Ping")
                if dataPing then
                    return math.floor(dataPing:GetValue())
                end
            end
        end
        return 0
    end)
    return success and ping or 0
end

-- Функция для анимаций
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenObj = TweenService:Create(obj, tweenInfo, props)
    tweenObj:Play()
    return tweenObj
end

-- Уведомления (современный дизайн)
local function showNotification(text, icon)
    if not notificationsEnabled then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 320, 0, 60)
    notification.Position = UDim2.new(1, -340, 1, -80)
    notification.BackgroundColor3 = themes[currentTheme].header
    notification.BorderSizePixel = 1
    notification.BorderColor3 = themes[currentTheme].border
    notification.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    -- Градиентный акцент
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 5, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = themes[currentTheme].accent
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 101
    accentBar.Parent = notification
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accentBar
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 15, 0.5, -20)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "✨"
    iconLabel.TextColor3 = themes[currentTheme].accent
    iconLabel.TextSize = 22
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 240, 1, -20)
    textLabel.Position = UDim2.new(0, 70, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = themes[currentTheme].text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    
    notification.Parent = ScreenGui
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 320, 1, -80)
    tween(notification, {Position = UDim2.new(1, -340, 1, -80)}, 0.3)
    
    -- Автоматическое скрытие через 3 секунды
    task.spawn(function()
        task.wait(3)
        tween(notification, {Position = UDim2.new(1, 320, 1, -80)}, 0.3)
        task.wait(0.3)
        notification:Destroy()
    end)
end

-- Функция для noclip
local function updateNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if playerSettings.noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        showNotification("Noclip enabled", "🚫")
    else
        showNotification("Noclip disabled", "✅")
    end
end

-- Функция закрытия меню
local function closeMenu()
    if not mainFrame then return end
    
    isMenuOpen = false
    mainFrame:Destroy()
    mainFrame = nil
    
    if themeDropdown then
        themeDropdown:Destroy()
        themeDropdown = nil
    end
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    -- Разблокируем действия
    toggleActions(false)
    
    showNotification("Menu closed", "📱")
end

-- Функция настройки привязки клавиши
local function setupKeyBind()
    if keyBindConnection then
        keyBindConnection:Disconnect()
    end
    
    keyBindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == menuToggleKey then
            if not isMenuOpen then
                createMainMenu()
                isMenuOpen = true
                showNotification("Menu opened", "📱")
            else
                closeMenu()
            end
        end
    end)
    
    showNotification("Press LControl to open menu", "⌨️")
end

-- ГЛАВНАЯ ФУНКЦИЯ МЕНЮ
local function createMainMenu()
    if mainFrame then
        mainFrame:Destroy()
    end
    
    -- Блокируем действия при открытии меню
    toggleActions(true)
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 420)  -- Увеличенный размер
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -210)
    mainFrame.BackgroundColor3 = themes[currentTheme].bg
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = themes[currentTheme].border
    mainFrame.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Верхняя панель для перетаскивания
    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Size = UDim2.new(1, 0, 0, 45)
    dragBar.BackgroundColor3 = themes[currentTheme].header
    dragBar.BorderSizePixel = 0
    dragBar.Parent = mainFrame
    
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(0, 12)
    dragCorner.Parent = dragBar
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Name = "TitleLabel"
    title.Size = UDim2.new(0, 180, 0, 40)
    title.Position = UDim2.new(0, 20, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "❄️ Snow - Kvizzi"
    title.TextColor3 = themes[currentTheme].accent
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dragBar
    
    -- Информация о времени и пинге
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(0, 100, 0, 20)
    timeLabel.Position = UDim2.new(1, -130, 0, 5)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "🕒 " .. getServerTime()
    timeLabel.TextColor3 = themes[currentTheme].text
    timeLabel.TextSize = 12
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = dragBar
    
    local pingLabel = Instance.new("TextLabel")
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(0, 100, 0, 20)
    pingLabel.Position = UDim2.new(1, -130, 0, 25)
    pingLabel.BackgroundTransparency = 1
    pingLabel.Text = "📶 " .. getPing() .. "ms"
    pingLabel.TextColor3 = themes[currentTheme].text
    pingLabel.TextSize = 12
    pingLabel.Font = Enum.Font.Gotham
    pingLabel.TextXAlignment = Enum.TextXAlignment.Right
    pingLabel.Parent = dragBar
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 32, 0, 32)
    closeButton.Position = UDim2.new(1, -40, 0.5, -16)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "×"
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = dragBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        closeMenu()
    end)
    
    -- Эффект при наведении на кнопку закрытия
    closeButton.MouseEnter:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        tween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
    end)
    
    -- Функция для перетаскивания меню
    local function startDrag()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        menuStart = mainFrame.Position
    end
    
    local function updateDrag()
        if not dragging or not dragStart or not menuStart then return end
        
        local mousePos = UserInputService:GetMouseLocation()
        local delta = Vector2.new(
            mousePos.X - dragStart.X,
            mousePos.Y - dragStart.Y
        )
        
        mainFrame.Position = UDim2.new(
            0, menuStart.X.Offset + delta.X,
            0, menuStart.Y.Offset + delta.Y
        )
    end
    
    local function stopDrag()
        dragging = false
        dragStart = nil
        menuStart = nil
    end
    
    -- Обработчики для перетаскивания
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag()
        end
    end)
    
    dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            stopDrag()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag()
        end
    end)
    
    -- Основное содержимое
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 110, 0, 365)
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.BackgroundColor3 = themes[currentTheme].header
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0, 390, 0, 365)
    contentFrame.Position = UDim2.new(0, 110, 0, 45)
    contentFrame.BackgroundColor3 = themes[currentTheme].bg
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    local sections = {
        main = "🎮 Main",
        tech = "⚙️ Tech",
        extra = "✨ Extra",
        settings = "⚡ Settings"
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
                if btn.Name == section then
                    tween(btn, {BackgroundColor3 = themes[currentTheme].accent}, 0.2)
                else
                    tween(btn, {BackgroundColor3 = themes[currentTheme].button}, 0.2)
                end
            end
        end
    end
    
    -- Создаем красивые кнопки навигации
    local buttonY = 15
    for name, text in pairs(sections) do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 90, 0, 40)
        button.Position = UDim2.new(0, 10, 0, buttonY)
        button.BackgroundColor3 = name == "main" and themes[currentTheme].accent or themes[currentTheme].button
        button.TextColor3 = themes[currentTheme].text
        button.Text = text
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        button.Parent = sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = button
        
        -- Эффект при наведении
        button.MouseEnter:Connect(function()
            if button.Name ~= currentSection then
                tween(button, {BackgroundColor3 = Color3.fromRGB(
                    themes[currentTheme].button.R * 255 * 1.2,
                    themes[currentTheme].button.G * 255 * 1.2,
                    themes[currentTheme].button.B * 255 * 1.2
                )}, 0.2)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button.Name ~= currentSection then
                tween(button, {BackgroundColor3 = themes[currentTheme].button}, 0.2)
            end
        end)
        
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
    
    -- Заголовок раздела
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, -40, 0, 40)
    sectionTitle.Position = UDim2.new(0, 20, 0, 10)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "🎮 Player Settings"
    sectionTitle.TextColor3 = themes[currentTheme].accent
    sectionTitle.TextSize = 18
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = mainSection
    
    -- Speed
    local speedContainer = Instance.new("Frame")
    speedContainer.Size = UDim2.new(1, -40, 0, 70)
    speedContainer.Position = UDim2.new(0, 20, 0, 60)
    speedContainer.BackgroundTransparency = 1
    speedContainer.Parent = mainSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 100, 0, 30)
    speedLabel.Position = UDim2.new(0, 0, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "🏃 Speed"
    speedLabel.TextColor3 = themes[currentTheme].text
    speedLabel.TextSize = 15
    speedLabel.Font = Enum.Font.GothamMedium
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedContainer
    
    local speedValue = Instance.new("TextLabel")
    speedValue.Size = UDim2.new(0, 60, 0, 30)
    speedValue.Position = UDim2.new(1, -60, 0, 0)
    speedValue.BackgroundTransparency = 1
    speedValue.Text = playerSettings.speed
    speedValue.TextColor3 = themes[currentTheme].accent
    speedValue.TextSize = 16
    speedValue.Font = Enum.Font.GothamBold
    speedValue.Parent = speedContainer
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Size = UDim2.new(1, 0, 0, 25)
    speedSlider.Position = UDim2.new(0, 0, 0, 35)
    speedSlider.BackgroundColor3 = themes[currentTheme].button
    speedSlider.Parent = speedContainer
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 6)
    sliderCorner.Parent = speedSlider
    
    local speedFill = Instance.new("Frame")
    speedFill.Size = UDim2.new((playerSettings.speed - 16) / (100 - 16), 0, 1, 0)
    speedFill.BackgroundColor3 = themes[currentTheme].slider
    speedFill.BorderSizePixel = 0
    speedFill.Parent = speedSlider
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = speedFill
    
    -- Jump
    local jumpContainer = Instance.new("Frame")
    jumpContainer.Size = UDim2.new(1, -40, 0, 70)
    jumpContainer.Position = UDim2.new(0, 20, 0, 140)
    jumpContainer.BackgroundTransparency = 1
    jumpContainer.Parent = mainSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 30)
    jumpLabel.Position = UDim2.new(0, 0, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "🦘 Jump"
    jumpLabel.TextColor3 = themes[currentTheme].text
    jumpLabel.TextSize = 15
    jumpLabel.Font = Enum.Font.GothamMedium
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpContainer
    
    local jumpValue = Instance.new("TextLabel")
    jumpValue.Size = UDim2.new(0, 60, 0, 30)
    jumpValue.Position = UDim2.new(1, -60, 0, 0)
    jumpValue.BackgroundTransparency = 1
    jumpValue.Text = playerSettings.jump
    jumpValue.TextColor3 = themes[currentTheme].accent
    jumpValue.TextSize = 16
    jumpValue.Font = Enum.Font.GothamBold
    jumpValue.Parent = jumpContainer
    
    local jumpSlider = Instance.new("Frame")
    jumpSlider.Size = UDim2.new(1, 0, 0, 25)
    jumpSlider.Position = UDim2.new(0, 0, 0, 35)
    jumpSlider.BackgroundColor3 = themes[currentTheme].button
    jumpSlider.Parent = jumpContainer
    
    local jumpSliderCorner = Instance.new("UICorner")
    jumpSliderCorner.CornerRadius = UDim.new(0, 6)
    jumpSliderCorner.Parent = jumpSlider
    
    local jumpFill = Instance.new("Frame")
    jumpFill.Size = UDim2.new((playerSettings.jump - 50) / (200 - 50), 0, 1, 0)
    jumpFill.BackgroundColor3 = themes[currentTheme].slider
    jumpFill.BorderSizePixel = 0
    jumpFill.Parent = jumpSlider
    
    local jumpFillCorner = Instance.new("UICorner")
    jumpFillCorner.CornerRadius = UDim.new(0, 6)
    jumpFillCorner.Parent = jumpFill
    
    -- Noclip
    local noclipContainer = Instance.new("Frame")
    noclipContainer.Size = UDim2.new(1, -40, 0, 70)
    noclipContainer.Position = UDim2.new(0, 20, 0, 220)
    noclipContainer.BackgroundTransparency = 1
    noclipContainer.Parent = mainSection
    
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(0, 100, 0, 30)
    noclipLabel.Position = UDim2.new(0, 0, 0, 0)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "👻 Noclip"
    noclipLabel.TextColor3 = themes[currentTheme].text
    noclipLabel.TextSize = 15
    noclipLabel.Font = Enum.Font.GothamMedium
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.Parent = noclipContainer
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Size = UDim2.new(0, 60, 0, 30)
    noclipToggle.Position = UDim2.new(1, -60, 0, 0)
    noclipToggle.BackgroundColor3 = playerSettings.noclip and themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)
    noclipToggle.Text = playerSettings.noclip and "ON" or "OFF"
    noclipToggle.TextColor3 = themes[currentTheme].text
    noclipToggle.TextSize = 14
    noclipToggle.Font = Enum.Font.GothamMedium
    noclipToggle.AutoButtonColor = false
    noclipToggle.Parent = noclipContainer
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = noclipToggle
    
    noclipToggle.MouseButton1Click:Connect(function()
        playerSettings.noclip = not playerSettings.noclip
        noclipToggle.Text = playerSettings.noclip and "ON" or "OFF"
        noclipToggle.BackgroundColor3 = playerSettings.noclip and themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)
        updateNoclip()
    end)
    
    -- Эффект для переключателя
    noclipToggle.MouseEnter:Connect(function()
        tween(noclipToggle, {BackgroundColor3 = playerSettings.noclip and 
            Color3.fromRGB(themes[currentTheme].accent.R * 255 * 1.2,
                          themes[currentTheme].accent.G * 255 * 1.2,
                          themes[currentTheme].accent.B * 255 * 1.2) or
            Color3.fromRGB(70, 70, 80)}, 0.2)
    end)
    
    noclipToggle.MouseLeave:Connect(function()
        tween(noclipToggle, {BackgroundColor3 = playerSettings.noclip and 
            themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)}, 0.2)
    end)
    
    -- Раздел Tech
    local techSection = Instance.new("Frame")
    techSection.Size = UDim2.new(1, 0, 1, 0)
    techSection.BackgroundTransparency = 1
    techSection.Visible = false
    techSection.Parent = contentFrame
    sectionFrames.tech = techSection
    
    local techIcon = Instance.new("TextLabel")
    techIcon.Size = UDim2.new(0, 120, 0, 120)
    techIcon.Position = UDim2.new(0.5, -60, 0.3, -60)
    techIcon.BackgroundTransparency = 1
    techIcon.Text = "🔧"
    techIcon.TextColor3 = themes[currentTheme].text
    techIcon.TextSize = 72
    techIcon.Font = Enum.Font.GothamBold
    techIcon.Parent = techSection
    
    local techText = Instance.new("TextLabel")
    techText.Size = UDim2.new(0, 250, 0, 50)
    techText.Position = UDim2.new(0.5, -125, 0.6, -25)
    techText.BackgroundTransparency = 1
    techText.Text = "Coming Soon"
    techText.TextColor3 = themes[currentTheme].accent
    techText.TextSize = 24
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
    extraText.Text = "✨ Extra features coming soon..."
    extraText.TextColor3 = themes[currentTheme].text
    extraText.TextSize = 18
    extraText.Font = Enum.Font.GothamMedium
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
    
    -- Theme
    local themeContainer = Instance.new("Frame")
    themeContainer.Size = UDim2.new(1, -40, 0, 40)
    themeContainer.Position = UDim2.new(0, 20, 0, settingsY)
    themeContainer.BackgroundTransparency = 1
    themeContainer.Parent = settingsSection
    
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(0, 120, 0, 40)
    themeLabel.Position = UDim2.new(0, 0, 0, 0)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "🎨 Theme"
    themeLabel.TextColor3 = themes[currentTheme].text
    themeLabel.TextSize = 15
    themeLabel.Font = Enum.Font.GothamMedium
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Parent = themeContainer
    
    local themeButton = Instance.new("TextButton")
    themeButton.Size = UDim2.new(0, 100, 0, 40)
    themeButton.Position = UDim2.new(1, -100, 0, 0)
    themeButton.BackgroundColor3 = themes[currentTheme].button
    themeButton.TextColor3 = themes[currentTheme].text
    themeButton.Text = currentTheme:upper()
    themeButton.TextSize = 13
    themeButton.Font = Enum.Font.GothamMedium
    themeButton.AutoButtonColor = false
    themeButton.Parent = themeContainer
    
    local themeBtnCorner = Instance.new("UICorner")
    themeBtnCorner.CornerRadius = UDim.new(0, 8)
    themeBtnCorner.Parent = themeButton
    
    themeButton.MouseEnter:Connect(function()
        tween(themeButton, {BackgroundColor3 = Color3.fromRGB(
            themes[currentTheme].button.R * 255 * 1.2,
            themes[currentTheme].button.G * 255 * 1.2,
            themes[currentTheme].button.B * 255 * 1.2
        )}, 0.2)
    end)
    
    themeButton.MouseLeave:Connect(function()
        tween(themeButton, {BackgroundColor3 = themes[currentTheme].button}, 0.2)
    end)
    
    themeButton.MouseButton1Click:Connect(function()
        if themeDropdown then
            themeDropdown:Destroy()
            themeDropdown = nil
            return
        end
        
        -- Создаем dropdown справа от меню
        themeDropdown = Instance.new("Frame")
        themeDropdown.Size = UDim2.new(0, 120, 0, 0)
        themeDropdown.Position = UDim2.new(0, mainFrame.AbsoluteSize.X + 10, 0, mainFrame.AbsolutePosition.Y + themeButton.AbsolutePosition.Y)
        themeDropdown.BackgroundColor3 = themes[currentTheme].header
        themeDropdown.BorderSizePixel = 1
        themeDropdown.BorderColor3 = themes[currentTheme].border
        themeDropdown.ClipsDescendants = true
        themeDropdown.ZIndex = 50
        themeDropdown.Parent = ScreenGui
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 8)
        dropdownCorner.Parent = themeDropdown
        
        local themesList = {"dark", "white", "neon", "purple"}
        
        for i, themeName in ipairs(themesList) do
            local themeBtn = Instance.new("TextButton")
            themeBtn.Size = UDim2.new(0, 120, 0, 35)
            themeBtn.Position = UDim2.new(0, 0, 0, (i-1)*40)
            themeBtn.BackgroundColor3 = themes[themeName].button
            themeBtn.TextColor3 = themes[themeName].text
            themeBtn.Text = themeName:upper()
            themeBtn.TextSize = 12
            themeBtn.Font = Enum.Font.GothamMedium
            themeBtn.AutoButtonColor = false
            themeBtn.ZIndex = 51
            themeBtn.Parent = themeDropdown
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = themeBtn
            
            themeBtn.MouseEnter:Connect(function()
                tween(themeBtn, {BackgroundColor3 = Color3.fromRGB(
                    themes[themeName].button.R * 255 * 1.2,
                    themes[themeName].button.G * 255 * 1.2,
                    themes[themeName].button.B * 255 * 1.2
                )}, 0.2)
            end)
            
            themeBtn.MouseLeave:Connect(function()
                tween(themeBtn, {BackgroundColor3 = themes[themeName].button}, 0.2)
            end)
            
            themeBtn.MouseButton1Click:Connect(function()
                currentTheme = themeName
                themeButton.Text = currentTheme:upper()
                
                -- Обновляем тему меню
                mainFrame.BackgroundColor3 = themes[currentTheme].bg
                mainFrame.BorderColor3 = themes[currentTheme].border
                dragBar.BackgroundColor3 = themes[currentTheme].header
                title.TextColor3 = themes[currentTheme].accent
                timeLabel.TextColor3 = themes[currentTheme].text
                pingLabel.TextColor3 = themes[currentTheme].text
                sidebar.BackgroundColor3 = themes[currentTheme].header
                contentFrame.BackgroundColor3 = themes[currentTheme].bg
                
                -- Обновляем кнопки
                for _, btn in ipairs(sidebar:GetChildren()) do
                    if btn:IsA("TextButton") then
                        if btn.Name == currentSection then
                            btn.BackgroundColor3 = themes[currentTheme].accent
                        else
                            btn.BackgroundColor3 = themes[currentTheme].button
                        end
                        btn.TextColor3 = themes[currentTheme].text
                    end
                end
                
                -- Обновляем dropdown
                themeDropdown.BackgroundColor3 = themes[currentTheme].header
                themeDropdown.BorderColor3 = themes[currentTheme].border
                
                for _, dbtn in ipairs(themeDropdown:GetChildren()) do
                    if dbtn:IsA("TextButton") then
                        dbtn.BackgroundColor3 = themes[dbtn.Text:lower()].button
                        dbtn.TextColor3 = themes[dbtn.Text:lower()].text
                    end
                end
                
                themeDropdown:Destroy()
                themeDropdown = nil
                
                showNotification("Theme: " .. themeName, "🎨")
            end)
        end
        
        tween(themeDropdown, {Size = UDim2.new(0, 120, 0, #themesList * 40)}, 0.2)
    end)
    
    settingsY = settingsY + 50
    
    -- Notifications
    local notifContainer = Instance.new("Frame")
    notifContainer.Size = UDim2.new(1, -40, 0, 40)
    notifContainer.Position = UDim2.new(0, 20, 0, settingsY)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = settingsSection
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(0, 120, 0, 40)
    notifLabel.Position = UDim2.new(0, 0, 0, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "🔔 Notifications"
    notifLabel.TextColor3 = themes[currentTheme].text
    notifLabel.TextSize = 15
    notifLabel.Font = Enum.Font.GothamMedium
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = notifContainer
    
    local notifToggle = Instance.new("TextButton")
    notifToggle.Size = UDim2.new(0, 60, 0, 30)
    notifToggle.Position = UDim2.new(1, -60, 0, 5)
    notifToggle.BackgroundColor3 = notificationsEnabled and themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)
    notifToggle.Text = notificationsEnabled and "ON" or "OFF"
    notifToggle.TextColor3 = themes[currentTheme].text
    notifToggle.TextSize = 14
    notifToggle.Font = Enum.Font.GothamMedium
    notifToggle.AutoButtonColor = false
    notifToggle.Parent = notifContainer
    
    local notifToggleCorner = Instance.new("UICorner")
    notifToggleCorner.CornerRadius = UDim.new(0, 8)
    notifToggleCorner.Parent = notifToggle
    
    notifToggle.MouseButton1Click:Connect(function()
        notificationsEnabled = not notificationsEnabled
        notifToggle.Text = notificationsEnabled and "ON" or "OFF"
        notifToggle.BackgroundColor3 = notificationsEnabled and themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)
        showNotification("Notifications: " .. (notificationsEnabled and "ON" or "OFF"), "🔔")
    end)
    
    notifToggle.MouseEnter:Connect(function()
        tween(notifToggle, {BackgroundColor3 = notificationsEnabled and 
            Color3.fromRGB(themes[currentTheme].accent.R * 255 * 1.2,
                          themes[currentTheme].accent.G * 255 * 1.2,
                          themes[currentTheme].accent.B * 255 * 1.2) or
            Color3.fromRGB(70, 70, 80)}, 0.2)
    end)
    
    notifToggle.MouseLeave:Connect(function()
        tween(notifToggle, {BackgroundColor3 = notificationsEnabled and 
            themes[currentTheme].accent or Color3.fromRGB(60, 60, 70)}, 0.2)
    end)
    
    settingsY = settingsY + 50
    
    -- Key Bind
    local bindContainer = Instance.new("Frame")
    bindContainer.Size = UDim2.new(1, -40, 0, 40)
    bindContainer.Position = UDim2.new(0, 20, 0, settingsY)
    bindContainer.BackgroundTransparency = 1
    bindContainer.Parent = settingsSection
    
    local bindLabel = Instance.new("TextLabel")
    bindLabel.Size = UDim2.new(0, 120, 0, 40)
    bindLabel.Position = UDim2.new(0, 0, 0, 0)
    bindLabel.BackgroundTransparency = 1
    bindLabel.Text = "⌨️ Menu Key"
    bindLabel.TextColor3 = themes[currentTheme].text
    bindLabel.TextSize = 15
    bindLabel.Font = Enum.Font.GothamMedium
    bindLabel.TextXAlignment = Enum.TextXAlignment.Left
    bindLabel.Parent = bindContainer
    
    local bindButton = Instance.new("TextButton")
    bindButton.Size = UDim2.new(0, 100, 0, 40)
    bindButton.Position = UDim2.new(1, -100, 0, 0)
    bindButton.BackgroundColor3 = themes[currentTheme].button
    bindButton.TextColor3 = themes[currentTheme].text
    bindButton.Text = "LControl"
    bindButton.TextSize = 13
    bindButton.Font = Enum.Font.GothamMedium
    bindButton.AutoButtonColor = false
    bindButton.Parent = bindContainer
    
    local bindBtnCorner = Instance.new("UICorner")
    bindBtnCorner.CornerRadius = UDim.new(0, 8)
    bindBtnCorner.Parent = bindButton
    
    bindButton.MouseEnter:Connect(function()
        tween(bindButton, {BackgroundColor3 = Color3.fromRGB(
            themes[currentTheme].button.R * 255 * 1.2,
            themes[currentTheme].button.G * 255 * 1.2,
            themes[currentTheme].button.B * 255 * 1.2
        )}, 0.2)
    end)
    
    bindButton.MouseLeave:Connect(function()
        tween(bindButton, {BackgroundColor3 = themes[currentTheme].button}, 0.2)
    end)
    
    local listeningForKey = false
    bindButton.MouseButton1Click:Connect(function()
        if listeningForKey then return end
        
        listeningForKey = true
        bindButton.Text = "Press Key..."
        bindButton.BackgroundColor3 = themes[currentTheme].accent
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                menuToggleKey = input.KeyCode
                local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                bindButton.Text = keyName
                bindButton.BackgroundColor3 = themes[currentTheme].button
                listeningForKey = false
                
                connection:Disconnect()
                setupKeyBind()
                showNotification("Menu key: " .. keyName, "⌨️")
            end
        end)
    end)
    
    settingsY = settingsY + 70
    
    -- Actions Blocked Info
    local actionsInfo = Instance.new("TextLabel")
    actionsInfo.Size = UDim2.new(1, -40, 0, 30)
    actionsInfo.Position = UDim2.new(0, 20, 0, settingsY)
    actionsInfo.BackgroundTransparency = 1
    actionsInfo.Text = "⚠️ Game actions are blocked while menu is open"
    actionsInfo.TextColor3 = Color3.fromRGB(255, 180, 0)
    actionsInfo.TextSize = 12
    actionsInfo.Font = Enum.Font.Gotham
    actionsInfo.TextXAlignment = Enum.TextXAlignment.Center
    actionsInfo.TextWrapped = true
    actionsInfo.Parent = settingsSection
    
    settingsY = settingsY + 40
    
    -- Exit
    local exitButton = Instance.new("TextButton")
    exitButton.Size = UDim2.new(1, -40, 0, 45)
    exitButton.Position = UDim2.new(0, 20, 0, settingsY)
    exitButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    exitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exitButton.Text = "❌ Exit Script"
    exitButton.TextSize = 16
    exitButton.Font = Enum.Font.GothamBold
    exitButton.AutoButtonColor = false
    exitButton.Parent = settingsSection
    
    local exitCorner = Instance.new("UICorner")
    exitCorner.CornerRadius = UDim.new(0, 10)
    exitCorner.Parent = exitButton
    
    exitButton.MouseEnter:Connect(function()
        tween(exitButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    
    exitButton.MouseLeave:Connect(function()
        tween(exitButton, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)}, 0.2)
    end)
    
    exitButton.MouseButton1Click:Connect(function()
        if keyBindConnection then
            keyBindConnection:Disconnect()
        end
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        toggleActions(false)
        ScreenGui:Destroy()
        showNotification("Script ended", "👋")
    end)
    
    -- Логика слайдеров
    local function setupSlider(slider, fill, valueLabel, minVal, maxVal, currentVal, updateFunc)
        local isDragging = false
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
            end
        end)
        
        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation()
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                
                local relativeX = (mousePos.X - sliderPos.X) / sliderSize.X
                relativeX = math.clamp(relativeX, 0, 1)
                
                local newValue = math.floor(minVal + relativeX * (maxVal - minVal))
                fill.Size = UDim2.new(relativeX, 0, 1, 0)
                valueLabel.Text = tostring(newValue)
                
                updateFunc(newValue)
            end
        end)
    end
    
    -- Настраиваем слайдеры
    setupSlider(speedSlider, speedFill, speedValue, 16, 100, playerSettings.speed, function(val)
        playerSettings.speed = val
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = val
            end
        end
    end)
    
    setupSlider(jumpSlider, jumpFill, jumpValue, 50, 200, playerSettings.jump, function(val)
        playerSettings.jump = val
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = val
            end
        end
    end)
    
    -- Обновление времени и пинга
    local timePingConnection
    timePingConnection = RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then
            timePingConnection:Disconnect()
            return
        end
        
        local timeLabel = dragBar:FindFirstChild("TimeLabel")
        local pingLabel = dragBar:FindFirstChild("PingLabel")
        
        if timeLabel then
            timeLabel.Text = "🕒 " .. getServerTime()
        end
        
        if pingLabel then
            pingLabel.Text = "📶 " .. getPing() .. "ms"
        end
        
        -- Обновляем позицию dropdown при перемещении меню
        if themeDropdown and mainFrame then
            themeDropdown.Position = UDim2.new(
                0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 10,
                0, mainFrame.AbsolutePosition.Y + themeButton.AbsolutePosition.Y
            )
        end
    end)
    
    -- Очистка соединений при уничтожении
    mainFrame.Destroying:Connect(function()
        if timePingConnection then
            timePingConnection:Disconnect()
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
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = loadingFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 0, 40)
    title.Position = UDim2.new(0.5, -100, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "❄️ Snow - Kvizzi"
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
    progressBarBack.Size = UDim2.new(0, 300, 0, 25)
    progressBarBack.Position = UDim2.new(0.5, -150, 0.7, -12)
    progressBarBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBarBack.BorderSizePixel = 0
    progressBarBack.Parent = loadingFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 8)
    progressCorner.Parent = progressBarBack
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBarBack
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(0, 8)
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
            progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
            connection:Disconnect()
            
            task.spawn(function()
                task.wait(0.5)
                loadingFrame:Destroy()
                setupKeyBind()
                showNotification("Press LControl to open menu", "✨")
            end)
        end
    end)
end

-- Запускаем скрипт
createLoadingScreen()

print("✅ Snow Menu loaded successfully!")
print("✅ Use LControl to open/close menu")
