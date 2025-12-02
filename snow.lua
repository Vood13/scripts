--[[
    Snow - Kvizzi Menu (Fixed 2025)
    Связь: @Kvizzi
    Открытие: LeftControl
    Меню можно двигать мышкой
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SnowMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- === Настройки ===
local themes = {
    dark = { bg = Color3.fromRGB(20,20,30), header = Color3.fromRGB(30,30,40), text = Color3.fromRGB(240,240,245), accent = Color3.fromRGB(0,170,255), button = Color3.fromRGB(40,40,50), border = Color3.fromRGB(50,50,60) },
    white = { bg = Color3.fromRGB(250,250,250), header = Color3.fromRGB(235,235,235), text = Color3.fromRGB(30,30,30), accent = Color3.fromRGB(0,120,215), button = Color3.fromRGB(225,225,225), border = Color3.fromRGB(210,210,210) },
    neon = { bg = Color3.fromRGB(10,10,20), header = Color3.fromRGB(20,20,30), text = Color3.fromRGB(220,255,220), accent = Color3.fromRGB(0,255,170), button = Color3.fromRGB(30,40,40), border = Color3.fromRGB(0,100,80) },
    purple = { bg = Color3.fromRGB(25,15,35), header = Color3.fromRGB(35,25,45), text = Color3.fromRGB(240,220,255), accent = Color3.fromRGB(170,100,255), button = Color3.fromRGB(45,35,55), border = Color3.fromRGB(80,50,100) }
}

local currentTheme = "dark"
local notificationsEnabled = true
local isMenuOpen = false
local menuToggleKey = Enum.KeyCode.LeftControl
local playerSettings = { speed = 16, jump = 50, noclip = false }
local mainFrame = nil
local themeDropdown = nil
local dragging = false
local dragStart, menuStart = nil, nil

-- === Утилиты ===
local function tween(obj, props, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function getPing()
    local success, ping = pcall(function()
        local pingItem = Stats.Network.ServerStatsItem
        if pingItem then
            local dataPing = pingItem:FindFirstChild("Data Ping")
            if dataPing then return math.floor(dataPing.Value) end
        end
        return 0
    end)
    return success and ping or 0
end

local function showNotification(text, icon)
    if not notificationsEnabled then return end
    local noti = Instance.new("Frame")
    noti.Size = UDim2.new(0, 320, 0, 60)
    noti.Position = UDim2.new(1, 320, 1, -80)
    noti.BackgroundColor3 = themes[currentTheme].header
    noti.BorderColor3 = themes[currentTheme].border
    noti.ZIndex = 100
    noti.Parent = ScreenGui

    local corner = Instance.new("UICorner", noti); corner.CornerRadius = UDim.new(0,8)
    local bar = Instance.new("Frame", noti)
    bar.Size = UDim2.new(0,5,1,0)
    bar.BackgroundColor3 = themes[currentTheme].accent
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

    local ico = Instance.new("TextLabel", noti)
    ico.Size = UDim2.new(0,40,0,40); ico.Position = UDim2.new(0,15,0.5,-20)
    ico.BackgroundTransparency = 1; ico.Text = icon or "✨"; ico.TextColor3 = themes[currentTheme].accent
    ico.Font = Enum.Font.GothamBold; ico.TextSize = 22

    local txt = Instance.new("TextLabel", noti)
    txt.Size = UDim2.new(0,240,1,-20); txt.Position = UDim2.new(0,70,0,10)
    txt.BackgroundTransparency = 1; txt.Text = text; txt.TextColor3 = themes[currentTheme].text
    txt.Font = Enum.Font.GothamMedium; txt.TextSize = 14; txt.TextXAlignment = Enum.TextXAlignment.Left

    tween(noti, {Position = UDim2.new(1,-340,1,-80)}, 0.3)
    task.delay(3, function()
        tween(noti, {Position = UDim2.new(1,320,1,-80)}, 0.3):Completed:Wait()
        noti:Destroy()
    end)
end

-- === Noclip ===
local noclipConnection
local function setNoclip(enabled)
    if noclipConnection then noclipConnection:Disconnect() end
    playerSettings.noclip = enabled
    if not enabled then showNotification("Noclip disabled", "Enabled") return end

    noclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    showNotification("Noclip enabled", "Disabled")
end

-- === Применение скорости и прыжка (включая респавн) ===
local function applyPlayerSettings()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hum = LocalPlayer.Character.Humanoid
    hum.WalkSpeed = playerSettings.speed
    hum.JumpPower = playerSettings.jump
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.1)
    applyPlayerSettings()
    if playerSettings.noclip then setNoclip(true) end
end)

if LocalPlayer.Character then applyPlayerSettings() end

-- === Закрытие меню ===
local function closeMenu()
    if not mainFrame then return end
    isMenuOpen = false
    if themeDropdown then themeDropdown:Destroy(); themeDropdown = nil end
    mainFrame:Destroy()
    mainFrame = nil
    showNotification("Menu closed", "Phone")
end

-- === Создание меню ===
local function createMenu()
    if isMenuOpen then return end
    isMenuOpen = true

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0,500,0,420)
    mainFrame.Position = UDim2.new(0.5,-250,0.5,-210)
    mainFrame.BackgroundColor3 = themes[currentTheme].bg
    mainFrame.BorderColor3 = themes[currentTheme].border
    mainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner", mainFrame); corner.CornerRadius = UDim.new(0,12)

    -- Drag bar
    local dragBar = Instance.new("Frame", mainFrame)
    dragBar.Size = UDim2.new(1,0,0,45)
    dragBar.BackgroundColor3 = themes[currentTheme].header

    local title = Instance.new("TextLabel", dragBar)
    title.Position = UDim2.new(0,20,0,2); title.Size = UDim2.new(0,180,0,40)
    title.BackgroundTransparency = 1; title.Text = "Snow - Kvizzi"; title.TextColor3 = themes[currentTheme].accent
    title.Font = Enum.Font.GothamBold; title.TextSize = 20; title.TextXAlignment = Enum.TextXAlignment.Left

    -- Time & Ping
    local timeLabel = Instance.new("TextLabel", dragBar)
    timeLabel.Position = UDim2.new(1,-130,0,5); timeLabel.Size = UDim2.new(0,100,0,20)
    timeLabel.BackgroundTransparency = 1; timeLabel.TextColor3 = themes[currentTheme].text
    timeLabel.Font = Enum.Font.Gotham; timeLabel.TextSize = 12; timeLabel.TextXAlignment = Enum.TextXAlignment.Right

    local pingLabel = Instance.new("TextLabel", dragBar)
    pingLabel.Position = UDim2.new(1,-130,0,25); pingLabel.Size = UDim2.new(0,100,0,20)
    pingLabel.BackgroundTransparency = 1; pingLabel.TextColor3 = themes[currentTheme].text
    pingLabel.Font = Enum.Font.Gotham; pingLabel.TextSize = 12; pingLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Close button
    local closeBtn = Instance.new("TextButton", dragBar)
    closeBtn.Size = UDim2.new(0,32,0,32); closeBtn.Position = UDim2.new(1,-40,0.5,-16)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255,60,60); closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 24
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
    closeBtn.MouseButton1Click:Connect(closeMenu)

    -- Drag logic
    dragBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; menuStart = mainFrame.Position end end)
    dragBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(menuStart.X.Scale, menuStart.X.Offset + delta.X, menuStart.Y.Scale, menuStart.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar & Content
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Size = UDim2.new(0,110,0,365); sidebar.Position = UDim2.new(0,0,0,45)
    sidebar.BackgroundColor3 = themes[currentTheme].header

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(0,390,0,365); content.Position = UDim2.new(0,110,0,45)
    content.BackgroundColor3 = themes[currentTheme].bg; content.ClipsDescendants = true

    -- Sections
    local sections = { main = "Player", tech = "Tech", extra = "Extra", settings = "Settings" }
    local currentSection = "main"
    local sectionFrames = {}

    local function switchSection(name)
        currentSection = name
        for sec, frame in pairs(sectionFrames) do frame.Visible = (sec == name) end
        for _, btn in ipairs(sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Name == name) and themes[currentTheme].accent or themes[currentTheme].button
            end
        end
    end

    local y = 15
    for name, label in pairs(sections) do
        local btn = Instance.new("TextButton", sidebar)
        btn.Name = name; btn.Size = UDim2.new(0,90,0,40); btn.Position = UDim2.new(0,10,0,y)
        btn.BackgroundColor3 = (name == "main") and themes[currentTheme].accent or themes[currentTheme].button
        btn.TextColor3 = themes[currentTheme].text; btn.Text = label; btn.Font = Enum.Font.GothamMedium; btn.TextSize = 13
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
        btn.MouseButton1Click:Connect(function() switchSection(name) end)
        y += 50
    end

    -- === Main Section ===
    local mainSec = Instance.new("Frame", content); mainSec.Size = UDim2.new(1,0,1,0); mainSec.BackgroundTransparency = 1
    sectionFrames.main = mainSec

    -- Speed Slider
    local function createSlider(parent, labelText, yPos, min, max, default, callback)
        local container = Instance.new("Frame", parent)
        container.Size = UDim2.new(1,-40,0,70); container.Position = UDim2.new(0,20,0,yPos); container.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", container); label.Size = UDim2.new(0,100,0,30); label.Text = labelText
        label.TextColor3 = themes[currentTheme].text; label.Font = Enum.Font.GothamMedium; label.TextSize = 15; label.TextXAlignment = Enum.TextXAlignment.Left

        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0,60,0,30); valueLabel.Position = UDim2.new(1,-60,0,0)
        valueLabel.BackgroundTransparency = 1; valueLabel.Text = tostring(default); valueLabel.TextColor3 = themes[currentTheme].accent
        valueLabel.Font = Enum.Font.GothamBold; valueLabel.TextSize = 16

        local track = Instance.new("Frame", container)
        track.Size = UDim2.new(1,0,0,25); track.Position = UDim2.new(0,0,0,35)
        track.BackgroundColor3 = themes[currentTheme].button
        Instance.new("UICorner", track).CornerRadius = UDim.new(0,6)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((default - min)/(max - min),0,1,0)
        fill.BackgroundColor3 = themes[currentTheme].accent
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

        local dragging = false
        track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
        track.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + rel * (max - min))
                fill.Size = UDim2.new(rel,0,1,0)
                valueLabel.Text = val
                callback(val)
            end
        end)
    end

    createSlider(mainSec, "Speed", 60, 16, 100, playerSettings.speed, function(v)
        playerSettings.speed = v
        applyPlayerSettings()
    end)

    createSlider(mainSec, "Jump", 140, 50, 200, playerSettings.jump, function(v)
        playerSettings.jump = v
        applyPlayerSettings()
    end)

    -- Noclip Toggle
    local noclipCont = Instance.new("Frame", mainSec)
    noclipCont.Size = UDim2.new(1,-40,0,70); noclipCont.Position = UDim2.new(0,20,0,220); noclipCont.BackgroundTransparency = 1

    local noclipLabel = Instance.new("TextLabel", noclipCont)
    noclipLabel.Size = UDim2.new(0,100,0,30); noclipLabel.Text = "Noclip"
    noclipLabel.TextColor3 = themes[currentTheme].text; noclipLabel.Font = Enum.Font.GothamMedium; noclipLabel.TextSize = 15

    local noclipToggle = Instance.new("TextButton", noclipCont)
    noclipToggle.Size = UDim2.new(0,60,0,30); noclipToggle.Position = UDim2.new(1,-60,0,0)
    noclipToggle.BackgroundColor3 = playerSettings.noclip and themes[currentTheme].accent or Color3.fromRGB(60,60,70)
    noclipToggle.Text = playerSettings.noclip and "ON" or "OFF"
    noclipToggle.TextColor3 = themes[currentTheme].text; noclipToggle.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", noclipToggle).CornerRadius = UDim.new(0,8)
    noclipToggle.MouseButton1Click:Connect(function()
        setNoclip(not playerSettings.noclip)
        noclipToggle.BackgroundColor3 = playerSettings.noclip and themes[currentTheme].accent or Color3.fromRGB(60,60,70)
        noclipToggle.Text = playerSettings.noclip and "ON" or "OFF"
    end)

    -- === Settings Section ===
    local settingsSec = Instance.new("Frame", content); settingsSec.Size = UDim2.new(1,0,1,0); settingsSec.BackgroundTransparency = 1; settingsSec.Visible = false
    sectionFrames.settings = settingsSec

    -- Theme selector
    local themeCont = Instance.new("Frame", settingsSec)
    themeCont.Size = UDim2.new(1,-40,0,40); themeCont.Position = UDim2.new(0,20,0,20); themeCont.BackgroundTransparency = 1

    Instance.new("TextLabel", themeCont).Text = "Theme"; -- упрощённо

    local themeBtn = Instance.new("TextButton", themeCont)
    themeBtn.Size = UDim2.new(0,100,0,40); themeBtn.Position = UDim2.new(1,-100,0,0)
    themeBtn.BackgroundColor3 = themes[currentTheme].button; themeBtn.Text = currentTheme:upper()
    themeBtn.TextColor3 = themes[currentTheme].text; Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0,8)

    themeBtn.MouseButton1Click:Connect(function()
        if themeDropdown and themeDropdown.Parent then themeDropdown:Destroy(); return end
        themeDropdown = Instance.new("Frame", ScreenGui)
        themeDropdown.Size = UDim2.new(0,120,0,160); themeDropdown.Position = UDim2.fromOffset(mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 10, mainFrame.AbsolutePosition.Y + 150)
        themeDropdown.BackgroundColor3 = themes[currentTheme].header; themeDropdown.BorderColor3 = themes[currentTheme].border
        Instance.new("UICorner", themeDropdown).CornerRadius = UDim.new(0,8)

        for i, name in ipairs({"dark","white","neon","purple"}) do
            local btn = Instance.new("TextButton", themeDropdown)
            btn.Size = UDim2.new(1,0,0,40); btn.Position = UDim2.new(0,0,0,(i-1)*40)
            btn.BackgroundColor3 = themes[name].button; btn.Text = name:upper(); btn.TextColor3 = themes[name].text
            btn.MouseButton1Click:Connect(function()
                currentTheme = name
                themeBtn.Text = name:upper()
                -- Перекрашиваем всё (упрощённо)
                for _, obj in ipairs(mainFrame:GetDescendants()) do
                    if obj:IsA("GuiObject") then
                        if obj.Name == "DragBar" or obj.Name == "Sidebar" then obj.BackgroundColor3 = themes[currentTheme].header
                        elseif obj:IsA("Frame") and not obj.Parent:IsA("TextButton") then obj.BackgroundColor3 = themes[currentTheme].bg
                        elseif obj:IsA("TextButton") then obj.BackgroundColor3 = themes[currentTheme].button end
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then obj.TextColor3 = themes[currentTheme].text end
                    end
                end
                themeDropdown:Destroy()
                showNotification("Theme: "..name, "Paintbrush")
            end)
        end
    end)

    -- Exit button
    local exitBtn = Instance.new("TextButton", settingsSec)
    exitBtn.Size = UDim2.new(1,-40,0,45); exitBtn.Position = UDim2.new(0,20,0,300)
    exitBtn.BackgroundColor3 = Color3.fromRGB(255,60,60); exitBtn.Text = "Exit Script"; exitBtn.TextColor3 = Color3.new(1,1,1)
    exitBtn.Font = Enum.Font.GothamBold; exitBtn.TextSize = 16
    Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0,10)
    exitBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        showNotification("Script unloaded", "Wave")
    end)

    -- Tech & Extra — заглушки
    for _, name in ipairs({"tech","extra"}) do
        local sec = Instance.new("Frame", content); sec.Size = UDim2.new(1,0,1,0); sec.BackgroundTransparency = 1; sec.Visible = false
        sectionFrames[name] = sec
        local txt = Instance.new("TextLabel", sec); txt.Size = UDim2.new(1,0,1,0); txt.Text = name.." coming soon..."
        txt.TextColor3 = themes[currentTheme].text; txt.Font = Enum.Font.Gotham; txt.TextSize = 20
    end

    -- Time/Ping update
    RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then return end
        timeLabel.Text = "Time " .. os.date("%H:%M:%S")
        pingLabel.Text = "Ping " .. getPing() .. "ms"
    end)

    showNotification("Menu opened", "Phone")
end

-- === Кейбинд ===
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == menuToggleKey then
        if isMenuOpen then closeMenu() else createMenu() end
    end
end)

-- === Загрузочный экран ===
local loading = Instance.new("Frame", ScreenGui)
loading.Size = UDim2.new(0,400,0,250); loading.Position = UDim2.new(0.5,-200,0.5,-125)
loading.BackgroundColor3 = Color3.fromRGB(15,15,20); Instance.new("UICorner", loading).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", loading); title.Position = UDim2.new(0.5,-100,0,30); title.Size = UDim2.new(0,200,0,40)
title.BackgroundTransparency = 1; title.Text = "Snow - Kvizzi"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 28

local desc = Instance.new("TextLabel", loading); desc.Position = UDim2.new(0.5,-175,0,80); desc.Size = UDim2.new(0,350,0,40)
desc.BackgroundTransparency = 1; desc.Text = "contact: @Kvizzi"; desc.TextColor3 = Color3.fromRGB(200,200,200); desc.Font = Enum.Font.Gotham; desc.TextSize = 14

local barBack = Instance.new("Frame", loading); barBack.Size = UDim2.new(0,300,0,25); barBack.Position = UDim2.new(0.5,-150,0.7,0)
barBack.BackgroundColor3 = Color3.fromRGB(40,40,50); Instance.new("UICorner", barBack).CornerRadius = UDim.new(0,8)

local bar = Instance.new("Frame", barBack); bar.Size = UDim2.new(0,0,1,0); bar.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

local percent = Instance.new("TextLabel", barBack); percent.Size = UDim2.new(1,0,1,0); percent.BackgroundTransparency = 1
percent.Text = "0%"; percent.TextColor3 = Color3.new(1,1,1); percent.Font = Enum.Font.GothamBold

local progress = 0
local conn = RunService.RenderStepped:Connect(function()
    progress = math.min(progress + 2, 100)
    bar.Size = UDim2.new(progress/100,0,1,0)
    percent.Text = math.floor(progress).." %"
    if progress >= 100 then
        conn:Disconnect()
        tween(loading, {BackgroundTransparency = 1}, 0.5)
        task.delay(0.5, function() loading:Destroy() end)
        showNotification("Snow Menu loaded! Press LControl", "Sparkles")
    end
end)

print("Snow Menu (Fixed 2025) loaded!")
