--[[
    Snow - Kvizzi Menu
    Связь: @Kvizzi
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
local keyBindConnection = nil
local playerSettings = {
    speed = 16,
    jump = 50,
    noclip = false
}
local noclipConnection = nil

-- Функция для анимаций
local function tween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenObj = TweenService:Create(obj, tweenInfo, props)
    tweenObj:Play()
    return tweenObj
end

-- Уведомления (минималистичный дизайн)
local function showNotification(text, icon)
    if not notificationsEnabled then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(1, -320, 1, -70)
    notification.BackgroundColor3 = themes[currentTheme].header
    notification.BorderSizePixel = 1
    notification.BorderColor3 = themes[currentTheme].accent
    notification.ZIndex = 100
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 4, 1, -10)
    leftBar.Position = UDim2.new(0, 8, 0, 5)
    leftBar.BackgroundColor3 = themes[currentTheme].accent
    leftBar.BorderSizePixel = 0
    leftBar.Parent = notification
    
    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 2)
    leftCorner.Parent = leftBar
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 20, 0.5, -15)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "⚡"
    iconLabel.TextColor3 = themes[currentTheme].accent
    iconLabel.TextSize = 18
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notification
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 220, 1, 0)
    textLabel.Position = UDim2.new(0, 60, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = themes[currentTheme].text
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.TextWrapped = true
    textLabel.Parent = notification
    
    notification.Parent = ScreenGui
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 300, 1, -70)
    tween(notification, {Position = UDim2.new(1, -320, 1, -70)}, 0.3)
    
    -- Автоматическое скрытие через 3 секунды
    task.spawn(function()
        task.wait(3)
        tween(notification, {Position = UDim2.new(1, 300, 1, -70)}, 0.3)
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
    tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3)
    task.wait(0.3)
    mainFrame:Destroy()
    mainFrame = nil
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    showNotification("Menu closed", "📱")
end

-- ГЛАВНАЯ ФУНКЦИЯ МЕНЮ (ОБЪЯВЛЕНА ДО ТОГО, КАК ЕЕ ИСПОЛЬЗУЮТ)
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
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = themes[currentTheme].header
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 8)
    topCorner.Parent = topBar
    
    local title = Instance.new("TextLabel")
    title.Name = "TitleLabel"
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
    sidebar.Name = "Sidebar"
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
    
    -- Speed
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 100, 0, 30)
    speedLabel.Position = UDim2.new(0, 20, 0, 20)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed: " .. playerSettings.speed
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
    speedFill.Size = UDim2.new((playerSettings.speed - 16) / (100 - 16), 0, 1, 0)
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
    speedInput.Text = tostring(playerSettings.speed)
    speedInput.TextSize = 14
    speedInput.Font = Enum.Font.Gotham
    speedInput.Parent = mainSection
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = speedInput
    
    -- Speed slider logic
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local relativeX = (pos.X - speedSlider.AbsolutePosition.X) / speedSlider.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            playerSettings.speed = math.floor(16 + relativeX * (100 - 16))
            speedFill.Size = UDim2.new(relativeX, 0, 1, 0)
            speedLabel.Text = "Speed: " .. playerSettings.speed
            speedInput.Text = tostring(playerSettings.speed)
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = playerSettings.speed
                end
            end
        end
    end)
    
    speedInput.FocusLost:Connect(function()
        local num = tonumber(speedInput.Text)
        if num then
            num = math.clamp(num, 16, 100)
            playerSettings.speed = num
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
            speedInput.Text = tostring(playerSettings.speed)
        end
    end)
    
    -- Jump
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(0, 100, 0, 30)
    jumpLabel.Position = UDim2.new(0, 20, 0, 70)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Jump: " .. playerSettings.jump
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
    jumpFill.Size = UDim2.new((playerSettings.jump - 50) / (200 - 50), 0, 1, 0)
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
    jumpInput.Text = tostring(playerSettings.jump)
    jumpInput.TextSize = 14
    jumpInput.Font = Enum.Font.Gotham
    jumpInput.Parent = mainSection
    
    local jumpInputCorner = Instance.new("UICorner")
    jumpInputCorner.CornerRadius = UDim.new(0, 4)
    jumpInputCorner.Parent = jumpInput
    
    -- Jump slider logic
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
    
    UserInputService.InputChanged:Connect(function(input)
        if jumpDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X, input.Position.Y)
            local relativeX = (pos.X - jumpSlider.AbsolutePosition.X) / jumpSlider.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            playerSettings.jump = math.floor(50 + relativeX * (200 - 50))
            jumpFill.Size = UDim2.new(relativeX, 0, 1, 0)
            jumpLabel.Text = "Jump: " .. playerSettings.jump
            jumpInput.Text = tostring(playerSettings.jump)
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.JumpPower = playerSettings.jump
                end
            end
        end
    end)
    
    jumpInput.FocusLost:Connect(function()
        local num = tonumber(jumpInput.Text)
        if num then
            num = math.clamp(num, 50, 200)
            playerSettings.jump = num
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
            jumpInput.Text = tostring(playerSettings.jump)
        end
    end)
    
    -- Noclip
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(0, 100, 0, 30)
    noclipLabel.Position = UDim2.new(0, 20, 0, 120)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "Noclip: " .. (playerSettings.noclip and "ON" or "OFF")
    noclipLabel.TextColor3 = themes[currentTheme].text
    noclipLabel.TextSize = 16
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.Parent = mainSection
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Size = UDim2.new(0, 50, 0, 25)
    noclipToggle.Position = UDim2.new(0, 130, 0, 125)
    noclipToggle.BackgroundColor3 = playerSettings.noclip and themes[currentTheme].accent or Color3.fromRGB(80, 80, 80)
    noclipToggle.Text = ""
    noclipToggle.Parent = mainSection
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = noclipToggle
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 21, 0, 21)
    toggleCircle.Position = UDim2.new(0, playerSettings.noclip and 27 or 2, 0, 2)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = noclipToggle
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0.5, 0)
    circleCorner.Parent = toggleCircle
    
    noclipToggle.MouseButton1Click:Connect(function()
        playerSettings.noclip = not playerSettings.noclip
        noclipLabel.Text = "Noclip: " .. (playerSettings.noclip and "ON" or "OFF")
        
        if playerSettings.noclip then
            tween(toggleCircle, {Position = UDim2.new(0, 27, 0, 2)}, 0.2)
            noclipToggle.BackgroundColor3 = themes[currentTheme].accent
        else
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
            noclipToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
        
        updateNoclip()
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
    
    -- Theme
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
    
    themeButton.MouseButton1Click:Connect(function()
        -- Простая смена темы без dropdown
        local themesList = {"dark", "white", "green", "red"}
        local currentIndex = 1
        for i, theme in ipairs(themesList) do
            if theme == currentTheme then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex + 1
        if currentIndex > #themesList then
            currentIndex = 1
        end
        
        currentTheme = themesList[currentIndex]
        themeLabel.Text = "🎨 Theme: " .. currentTheme
        
        -- Update menu theme
        mainFrame.BackgroundColor3 = themes[currentTheme].bg
        topBar.BackgroundColor3 = themes[currentTheme].header
        title.TextColor3 = themes[currentTheme].accent
        sidebar.BackgroundColor3 = themes[currentTheme].header
        contentFrame.BackgroundColor3 = themes[currentTheme].bg
        
        -- Update buttons
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn.Name == currentSection and themes[currentTheme].accent or themes[currentTheme].button
                btn.TextColor3 = themes[currentTheme].text
            end
        end
        
        showNotification("Theme changed to " .. currentTheme, "🎨")
    end)
    
    settingsY = settingsY + 40
    
    -- Notifications
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(0, 120, 0, 30)
    notifLabel.Position = UDim2.new(0, 20, 0, settingsY)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "🔔 Notifications: " .. (notificationsEnabled and "ON" or "OFF")
    notifLabel.TextColor3 = themes[currentTheme].text
    notifLabel.TextSize = 16
    notifLabel.Font = Enum.Font.Gotham
    notifLabel.TextXAlignment = Enum.TextXAlignment.Left
    notifLabel.Parent = settingsSection
    
    local notifToggle = Instance.new("TextButton")
    notifToggle.Size = UDim2.new(0, 50, 0, 25)
    notifToggle.Position = UDim2.new(0, 150, 0, settingsY + 2)
    notifToggle.BackgroundColor3 = notificationsEnabled and themes[currentTheme].accent or Color3.fromRGB(80, 80, 80)
    notifToggle.Text = ""
    notifToggle.Parent = settingsSection
    
    local notifToggleCorner = Instance.new("UICorner")
    notifToggleCorner.CornerRadius = UDim.new(0, 12)
    notifToggleCorner.Parent = notifToggle
    
    local notifCircle = Instance.new("Frame")
    notifCircle.Size = UDim2.new(0, 21, 0, 21)
    notifCircle.Position = UDim2.new(0, notificationsEnabled and 27 or 2, 0, 2)
    notifCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notifCircle.Parent = notifToggle
    
    local notifCircleCorner = Instance.new("UICorner")
    notifCircleCorner.CornerRadius = UDim.new(0.5, 0)
    notifCircleCorner.Parent = notifCircle
    
    notifToggle.MouseButton1Click:Connect(function()
        notificationsEnabled = not notificationsEnabled
        notifLabel.Text = "🔔 Notifications: " .. (notificationsEnabled and "ON" or "OFF")
        
        if notificationsEnabled then
            tween(notifCircle, {Position = UDim2.new(0, 27, 0, 2)}, 0.2)
            notifToggle.BackgroundColor3 = themes[currentTheme].accent
            showNotification("Notifications enabled", "🔔")
        else
            tween(notifCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2)
            notifToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
    
    settingsY = settingsY + 40
    
    -- Key Bind
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
                local keyName = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                bindLabel.Text = "⌨️ Open Key: " .. keyName
                bindButton.Text = "Change"
                bindButton.BackgroundColor3 = themes[currentTheme].button
                
                connection:Disconnect()
                setupKeyBind()
                showNotification("Menu key changed to " .. keyName, "⌨️")
            end
        end)
    end)
    
    settingsY = settingsY + 50
    
    -- Exit
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
        if keyBindConnection then
            keyBindConnection:Disconnect()
        end
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        
        ScreenGui:Destroy()
        showNotification("Script ended", "👋")
    end)
    
    -- Анимация открытия
    tween(mainFrame, {Size = UDim2.new(0, 450, 0, 350), Position = UDim2.new(0.5, -225, 0.5, -175)}, 0.3)
end

-- Функция настройки привязки клавиши (ТЕПЕРЬ ПОСЛЕ createMainMenu)
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

-- Прогресс бар загрузки (В САМОМ КОНЦЕ)
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
                setupKeyBind()
                showNotification("Menu ready! Press LControl", "✅")
            end)
        end
    end)
end

-- Запускаем скрипт
createLoadingScreen()

print("✅ Snow Menu loaded successfully!")
print("✅ Use LControl to open/close menu")
