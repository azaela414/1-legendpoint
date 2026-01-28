local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local vim = game:GetService("VirtualInputManager")

-- ==========================================
-- KONFIGURASI & VARIABEL
-- ==========================================
local isFarming = false
local godModeActive = true 
local targetHP = "10" 
local lastAttackTime = 0
local attackInterval = 0.5 

-- ==========================================
-- PEMBUATAN UI MODERN (V7 DRAGGABLE & EXTENDED)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GeminiV7_Premium"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Tombol Buka/Tutup (Besar & Bisa Digeser)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 120, 0, 50) 
openBtn.Position = UDim2.new(0, 20, 0.5, -25)
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
openBtn.Text = "BUKA MENU"
openBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Active = true
openBtn.Draggable = true 
openBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner", openBtn)
btnCorner.CornerRadius = UDim.new(0, 10)
local btnStroke = Instance.new("UIStroke", openBtn)
btnStroke.Color = Color3.fromRGB(0, 255, 150)
btnStroke.Thickness = 2

-- Frame Utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 450) 
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(0, 255, 150)
mainStroke.Thickness = 1.8

-- Judul Header
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "GEMINI PREMIUM V7"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Fungsi Buka/Tutup
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    openBtn.Text = mainFrame.Visible and "TUTUP MENU" or "BUKA MENU"
    openBtn.TextColor3 = mainFrame.Visible and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 255, 150)
    btnStroke.Color = mainFrame.Visible and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(0, 255, 150)
end)

-- Tombol Utama Farm
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 220, 0, 45)
toggleBtn.Position = UDim2.new(0, 20, 0, 60)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toggleBtn.Text = "STATUS: DIAM"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(200, 50, 50)

-- Area Scroll Target
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 0, 310)
scroll.Position = UDim2.new(0, 10, 0, 120)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 750) -- Ditambah agar muat semua target
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fungsi Pembuat Tombol Target
local function createTargetBtn(name, hpValue)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 210, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    btn.Text = name .. " [" .. hpValue .. "]"
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        targetHP = hpValue
        for _, v in pairs(scroll:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                v.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
end

-- DAFTAR TARGET LENGKAP V7
createTargetBtn("Snail", "10")
createTargetBtn("Pig", "800")
createTargetBtn("Target NPC", "2.5K")
createTargetBtn("Caveman", "4.5K")
createTargetBtn("Spider", "12.5K")
createTargetBtn("Mamoth", "75K")
createTargetBtn("Warlock", "100K")
createTargetBtn("Viperbloom", "125K")
createTargetBtn("Spartan", "250K")
createTargetBtn("Reaper", "750K")
createTargetBtn("Angel", "1.5M")
createTargetBtn("Basic NPC", "15M")
createTargetBtn("Ghost", "60M")
createTargetBtn("Orang Utam", "250M")
createTargetBtn("Mummy", "500M")
createTargetBtn("Blighleap", "2.5B")

-- ==========================================
-- LOGIC CORE
-- ==========================================

runService.Stepped:Connect(function()
    if godModeActive and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum.MaxHealth = 9e15 
            hum.Health = 9e15
        end
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    isFarming = not isFarming
    toggleBtn.Text = isFarming and "STATUS: FARMING" or "STATUS: DIAM"
    toggleStroke.Color = isFarming and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(200, 50, 50)
end)

task.spawn(function()
    while true do
        if isFarming and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local foundTarget = nil
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and v.Text:find(targetHP) then
                    if not v.Text:find("^0/") then 
                        local npcModel = v:FindFirstAncestorOfClass("Model") or v.Parent.Parent
                        local root = npcModel and (npcModel:FindFirstChild("HumanoidRootPart") or npcModel:FindFirstChildOfClass("Part"))
                        if root then foundTarget = root break end
                    end
                end
            end
            
            if foundTarget then
                local hrp = player.Character.HumanoidRootPart
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = foundTarget.CFrame * CFrame.new(0, 0, 3.2)
                
                if tick() - lastAttackTime >= attackInterval then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                    vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    lastAttackTime = tick()
                end
            end
        end
        runService.Heartbeat:Wait()
    end
end)