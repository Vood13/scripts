local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Настройки
local settings = {
    notifications = true
}

-- Создание основного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptInjectorMenu"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Создаем размытый фон
local BackgroundBlur = Instance.new("BlurEffect")
BackgroundBlur.Size = 10
BackgroundBlur.Parent = game:GetService("Lighting")

-- Основной фрейм с стеклянным эффектом
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Стеклянный эффект
local GlassFrame = Instance.new("Frame")
GlassFrame.Size = UDim2.new(1, 0, 1, 0)
GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassFrame.BackgroundTransparency = 0.95
GlassFrame.BorderSizePixel = 0
GlassFrame.Parent = MainFrame

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

-- Тень
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(100, 100, 120)
UIStroke.Thickness = 1
UIStroke.Transparency = 0.7
UIStroke.Parent = MainFrame

-- Боковая панель
local SidePanel = Instance.new("Frame")
SidePanel.Name = "SidePanel"
SidePanel.Size = UDim2.new(0, 120, 1, 0)
SidePanel.Position = UDim2.new(0, 0, 0, 0)
SidePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SidePanel.BackgroundTransparency = 0.3
SidePanel.BorderSizePixel = 0
SidePanel.Parent = MainFrame

local SidePanelCorner = Instance.new("UICorner")
SidePanelCorner.CornerRadius = UDim.new(0, 15)
SidePanelCorner.Parent = SidePanel

-- Заголовок боковой панели
local SidePanelTitle = Instance.new("TextLabel")
SidePanelTitle.Name = "SidePanelTitle"
SidePanelTitle.Size = UDim2.new(1, 0, 0, 60)
SidePanelTitle.Position = UDim2.new(0, 0, 0, 0)
SidePanelTitle.BackgroundTransparency = 1
SidePanelTitle.Text = "MENU"
SidePanelTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
SidePanelTitle.TextSize = 16
SidePanelTitle.Font = Enum.Font.GothamBold
SidePanelTitle.Parent = SidePanel

-- Контейнер для кнопок боковой панели
local SideButtonsContainer = Instance.new("Frame")
SideButtonsContainer.Name = "SideButtonsContainer"
SideButtonsContainer.Size = UDim2.new(1, 0, 1, -60)
SideButtonsContainer.Position = UDim2.new(0, 0, 0, 60)
SideButtonsContainer.BackgroundTransparency = 1
SideButtonsContainer.Parent = SidePanel

local SideButtonsLayout = Instance.new("UIListLayout")
SideButtonsLayout.Padding = UDim.new(0, 5)
SideButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideButtonsLayout.Parent = SideButtonsContainer

-- Основной контент
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -120, 1, 0)
ContentFrame.Position = UDim2.new(0, 120, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 70)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SCRIPT INJECTOR"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = ContentFrame

-- Контейнер для скриптов
local ScriptsContainer = Instance.new("ScrollingFrame")
ScriptsContainer.Name = "ScriptsContainer"
ScriptsContainer.Size = UDim2.new(1, -20, 1, -80)
ScriptsContainer.Position = UDim2.new(0, 10, 0, 70)
ScriptsContainer.BackgroundTransparency = 1
ScriptsContainer.ScrollBarThickness = 4
ScriptsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScriptsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScriptsContainer.Visible = true
ScriptsContainer.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ScriptsContainer

-- Контейнер для настроек
local SettingsContainer = Instance.new("ScrollingFrame")
SettingsContainer.Name = "SettingsContainer"
SettingsContainer.Size = UDim2.new(1, -20, 1, -80)
SettingsContainer.Position = UDim2.new(0, 10, 0, 70)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.ScrollBarThickness = 4
SettingsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
SettingsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
SettingsContainer.Visible = false
SettingsContainer.Parent = ContentFrame

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 12)
SettingsLayout.Parent = SettingsContainer

-- Кнопка закрытия скрипта
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseButtonCorner = Instance.new("UICorner")
CloseButtonCorner.CornerRadius = UDim.new(0, 8)
CloseButtonCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    showNotification("Скрипт выключен", "info")
    wait(0.5)
    deactivateAllScripts()
    ScreenGui:Destroy()
    BackgroundBlur:Destroy()
end)

-- Контейнер для уведомлений
local NotificationsContainer = Instance.new("Frame")
NotificationsContainer.Name = "NotificationsContainer"
NotificationsContainer.Size = UDim2.new(0, 300, 0.5, 0)
NotificationsContainer.Position = UDim2.new(1, -320, 0.5, -100)
NotificationsContainer.BackgroundTransparency = 1
NotificationsContainer.Parent = ScreenGui

local NotificationsLayout = Instance.new("UIListLayout")
NotificationsLayout.Padding = UDim.new(0, 10)
NotificationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationsLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationsLayout.Parent = NotificationsContainer

-- Переменные состояния
local currentActiveScript = nil
local currentSection = "scripts"
local notifications = {}

local scripts = {
    {
        name = "FLY",
        description = "WASD - движение, Space - вверх, Shift - вниз",
        enabled = false,
        button = nil,
        icon = "✈️",
        toggleFunction = function(enabled)
            if enabled then
                activateFly()
                showNotification("Fly активирован", "success")
            else
                deactivateFly()
                showNotification("Fly деактивирован", "warning")
            end
        end
    },
    {
        name = "INFINITY JUMP",
        description = "Бесконечные прыжки в воздухе",
        enabled = false,
        button = nil,
        icon = "🦘",
        toggleFunction = function(enabled)
            if enabled then
                activateInfinityJump()
                showNotification("Infinity Jump активирован", "success")
            else
                deactivateInfinityJump()
                showNotification("Infinity Jump деактивирован", "warning")
            end
        end
    }
}

-- Функция показа уведомлений
function showNotification(message, type)
    if not settings.notifications then return end
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(1, 0, 0, 70)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    notificationFrame.BackgroundTransparency = 0.2
    notificationFrame.BorderSizePixel = 0
    
    local glassFrame = Instance.new("Frame")
    glassFrame.Size = UDim2.new(1, 0, 1, 0)
    glassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glassFrame.BackgroundTransparency = 0.95
    glassFrame.BorderSizePixel = 0
    glassFrame.Parent = notificationFrame
    
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 10)
    notificationCorner.Parent = notificationFrame
    
    local notificationStroke = Instance.new("UIStroke")
    notificationStroke.Color = Color3.fromRGB(100, 100, 120)
    notificationStroke.Thickness = 1
    notificationStroke.Transparency = 0.7
    notificationStroke.Parent = notificationFrame
    
    -- Иконка уведомления
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = getIconByType(type)
    iconLabel.TextColor3 = getColorByType(type)
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = notificationFrame
    
    -- Текст уведомления
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -60, 1, -20)
    textLabel.Position = UDim2.new(0, 50, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message
    textLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = notificationFrame
    
    -- Прогресс бар
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = getColorByType(type)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notificationFrame
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar
    
    notificationFrame.Parent = NotificationsContainer
    table.insert(notifications, notificationFrame)
    
    -- Анимация появления
    notificationFrame.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Анимация прогресс бара
    TweenService:Create(progressBar, TweenInfo.new(3, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Удаление через 3 секунды
    delay(3, function()
        if notificationFrame and notificationFrame.Parent then
            TweenService:Create(notificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 0, 0, 0)
            }):Play()
            wait(0.3)
            notificationFrame:Destroy()
            
            for i, notif in ipairs(notifications) do
                if notif == notificationFrame then
                    table.remove(notifications, i)
                    break
                end
            end
        end
    end)
end

function getIconByType(type)
    local icons = {
        success = "✅",
        warning = "⚠️",
        error = "❌",
        info = "ℹ️"
    }
    return icons[type] or "💡"
end

function getColorByType(type)
    local colors = {
        success = Color3.fromRGB(0, 255, 127),
        warning = Color3.fromRGB(255, 255, 0),
        error = Color3.fromRGB(255, 50, 50),
        info = Color3.fromRGB(0, 170, 255)
    }
    return colors[type] or Color3.fromRGB(200, 200, 220)
end

-- Функция создания кнопки боковой панели
local function createSideButton(name, icon, section)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(0.8, 0, 0, 50)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    button.BackgroundTransparency = 0.3
    button.Text = icon .. "\n" .. name
    button.TextColor3 = Color3.fromRGB(200, 200, 220)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if currentSection == section then
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextColor3 = Color3.fromRGB(200, 200, 220)
            }):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(function()
        switchSection(section)
        
        -- Сбрасываем все кнопки
        for _, child in ipairs(SideButtonsContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.3,
                    TextColor3 = Color3.fromRGB(200, 200, 220)
                }):Play()
            end
        end
        
        -- Подсвечиваем активную кнопку
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.1,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    if section == currentSection then
        button.BackgroundTransparency = 0.1
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    return button
end

-- Функция переключения разделов
function switchSection(section)
    currentSection = section
    
    if section == "scripts" then
        ScriptsContainer.Visible = true
        SettingsContainer.Visible = false
        TitleLabel.Text = "СКРИПТЫ"
    elseif section == "settings" then
        ScriptsContainer.Visible = false
        SettingsContainer.Visible = true
        TitleLabel.Text = "НАСТРОЙКИ"
    end
end

-- Функция создания настройки
local function createSetting(name, description, currentValue, callback)
    local settingFrame = Instance.new("Frame")
    settingFrame.Name = name .. "Setting"
    settingFrame.Size = UDim2.new(1, 0, 0, 80)
    settingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    settingFrame.BackgroundTransparency = 0.3
    settingFrame.BorderSizePixel = 0
    
    local settingCorner = Instance.new("UICorner")
    settingCorner.CornerRadius = UDim.new(0, 10)
    settingCorner.Parent = settingFrame
    
    -- Название настройки
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.7, 0, 0, 30)
    nameLabel.Position = UDim2.new(0, 15, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = settingFrame
    
    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(0.7, -15, 0, 40)
    descLabel.Position = UDim2.new(0, 15, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = settingFrame
    
    -- Переключатель
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(0.85, -50, 0.5, -12.5)
    toggleButton.BackgroundColor3 = currentValue and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 90)
    toggleButton.Text = ""
    toggleButton.AutoButtonColor = false
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton
    
    -- Кружок внутри переключателя
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 19, 0, 19)
    toggleCircle.Position = currentValue and UDim2.new(1, -21, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleButton
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(0, 9)
    circleCorner.Parent = toggleCircle
    
    toggleButton.MouseButton1Click:Connect(function()
        local newValue = not currentValue
        currentValue = newValue
        
        -- Анимация переключения
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = newValue and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 90)
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
            Position = newValue and UDim2.new(1, -21, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
        }):Play()
        
        callback(newValue)
        
        if settings.notifications then
            showNotification(name .. " " .. (newValue and "включена" or "выключена"), newValue and "success" or "warning")
        end
    end)
    
    toggleButton.Parent = settingFrame
    settingFrame.Parent = SettingsContainer
    
    return settingFrame
end

-- Функция для создания кнопки скрипта
local function createScriptButton(scriptData, index)
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = scriptData.name .. "Button"
    buttonFrame.Size = UDim2.new(1, 0, 0, 90)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    buttonFrame.BackgroundTransparency = 0.3
    buttonFrame.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = buttonFrame
    
    -- Иконка скрипта
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "IconLabel"
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 15, 0, 10)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = scriptData.icon
    iconLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = buttonFrame
    
    -- Название скрипта
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.6, -50, 0, 30)
    nameLabel.Position = UDim2.new(0, 65, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = buttonFrame
    
    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(0.6, -50, 0, 40)
    descLabel.Position = UDim2.new(0, 65, 0, 40)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptData.description
    descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Parent = buttonFrame
    
    -- Кнопка активации
    local activateButton = Instance.new("TextButton")
    activateButton.Name = "ActivateButton"
    activateButton.Size = UDim2.new(0.25, 0, 0, 35)
    activateButton.Position = UDim2.new(0.75, -10, 0.5, -17.5)
    activateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    activateButton.BackgroundTransparency = 0.3
    activateButton.Text = "ВКЛ"
    activateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    activateButton.TextSize = 14
    activateButton.Font = Enum.Font.GothamBold
    activateButton.AutoButtonColor = false
    
    local activateCorner = Instance.new("UICorner")
    activateCorner.CornerRadius = UDim.new(0, 8)
    activateCorner.Parent = activateButton
    
    -- Анимация при наведении
    activateButton.MouseEnter:Connect(function()
        if not scriptData.enabled then
            TweenService:Create(activateButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end
    end)
    
    activateButton.MouseLeave:Connect(function()
        if not scriptData.enabled then
            TweenService:Create(activateButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
    
    -- Обработчик клика
    activateButton.MouseButton1Click:Connect(function()
        if currentActiveScript and currentActiveScript ~= scriptData then
            currentActiveScript.enabled = false
            currentActiveScript.toggleFunction(false)
            if currentActiveScript.button then
                currentActiveScript.button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                currentActiveScript.button.BackgroundTransparency = 0.3
                currentActiveScript.button.Text = "ВКЛ"
            end
        end
        
        scriptData.enabled = not scriptData.enabled
        scriptData.toggleFunction(scriptData.enabled)
        
        if scriptData.enabled then
            activateButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            activateButton.BackgroundTransparency = 0.1
            activateButton.Text = "ВЫКЛ"
            currentActiveScript = scriptData
        else
            activateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            activateButton.BackgroundTransparency = 0.3
            activateButton.Text = "ВКЛ"
            currentActiveScript = nil
        end
    end)
    
    activateButton.Parent = buttonFrame
    scriptData.button = activateButton
    buttonFrame.Parent = ScriptsContainer
    
    return buttonFrame
end

-- Функции скриптов (остаются без изменений)
local flyConnection
local bodyVelocity
local bodyGyro

function activateFly()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    
    deactivateFly()
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(40000, 40000, 40000)
    bodyGyro.P = 1250
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    local flySpeed = 50
    local verticalSpeed = 50
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not character or not rootPart or not bodyVelocity or not bodyGyro then
            deactivateFly()
            return
        end
        
        bodyGyro.CFrame = rootPart.CFrame
        
        local velocity = Vector3.new(0, 0, 0)
        local moving = false
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + rootPart.CFrame.LookVector * flySpeed
            moving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity + rootPart.CFrame.LookVector * -flySpeed
            moving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity + rootPart.CFrame.RightVector * -flySpeed
            moving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + rootPart.CFrame.RightVector * flySpeed
            moving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, verticalSpeed, 0)
            moving = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            velocity = velocity + Vector3.new(0, -verticalSpeed, 0)
            moving = true
        end
        
        bodyVelocity.Velocity = velocity
        
        if character:FindFirstChild("BodyForce") then
            character.BodyForce:Destroy()
        end
        
        local bodyForce = Instance.new("BodyForce")
        bodyForce.Force = Vector3.new(0, character:GetMass() * workspace.Gravity, 0)
        bodyForce.Parent = rootPart
    end)
    
    local characterAddedConnection
    characterAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
        deactivateFly()
        characterAddedConnection:Disconnect()
        if scripts[1].enabled then
            wait(1)
            activateFly()
        end
    end)
end

function deactivateFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    local character = player.Character
    if character then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local bodyForce = rootPart:FindFirstChild("BodyForce")
            if bodyForce then
                bodyForce:Destroy()
            end
        end
    end
end

local jumpConnection

function activateInfinityJump()
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

function deactivateInfinityJump()
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end
end

function deactivateAllScripts()
    for _, scriptData in ipairs(scripts) do
        if scriptData.enabled then
            scriptData.toggleFunction(false)
            scriptData.enabled = false
            if scriptData.button then
                scriptData.button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                scriptData.button.BackgroundTransparency = 0.3
                scriptData.button.Text = "ВКЛ"
            end
        end
    end
    currentActiveScript = nil
end

-- Создание интерфейса
local scriptsButton = createSideButton("Скрипты", "🎮", "scripts")
scriptsButton.Parent = SideButtonsContainer

local settingsButton = createSideButton("Настройки", "⚙️", "settings")
settingsButton.Parent = SideButtonsContainer

-- Создание кнопок скриптов
for i, scriptData in ipairs(scripts) do
    createScriptButton(scriptData, i)
end

-- Создание настроек
createSetting("Уведомления", "Включить/выключить системные уведомления", settings.notifications, function(value)
    settings.notifications = value
    if value then
        showNotification("Уведомления включены", "success")
    end
end)

-- Обновление размера контейнеров
local function updateContainerSize(container, layout)
    if container and layout then
        container.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end
end

updateContainerSize(ScriptsContainer, UIListLayout)
updateContainerSize(SettingsContainer, SettingsLayout)

ScriptsContainer.ChildAdded:Connect(function()
    updateContainerSize(ScriptsContainer, UIListLayout)
end)
SettingsContainer.ChildAdded:Connect(function()
    updateContainerSize(SettingsContainer, SettingsLayout)
end)

-- Перетаскивание окна
local dragging = false
local dragInput, dragStart, startPos

TitleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Закрытие по ESC
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Escape then
            deactivateAllScripts()
            ScreenGui:Destroy()
            BackgroundBlur:Destroy()
        end
    end
end)

-- Показываем приветственное уведомление
showNotification("Script Injector загружен!", "success")

print("Script Injector Menu loaded! Press ESC to close.")
