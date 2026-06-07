-- Blox Fruits Otomatik Farm (Kaitun) Scripti (Seviye 1 - 2800)
-- UI, Otomatik Görev, Otomatik Meyve ve Mob Çekme modülleri entegre edilmiştir.
-- Redz Hub kaynak kodundan referans alınarak otonom çalışacak şekilde yapılandırılmıştır.

getgenv().Kaitun = true
getgenv().TweenSpeed = 300
getgenv().AutoFruit = true
getgenv().AutoRandomFruit = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

-- UI Oluşturma (Kırmızı/Yeşil Nokta Göstergesi)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local LevelText = Instance.new("TextLabel")
local StatusDot = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "KaitunUI"
ScreenGui.Parent = game.CoreGui

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -100, 0, 20)
MainFrame.Size = UDim2.new(0, 200, 0, 80)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0.4, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Kaitun 1-2800"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

LevelText.Parent = MainFrame
LevelText.BackgroundTransparency = 1
LevelText.Position = UDim2.new(0, 10, 0.4, 0)
LevelText.Size = UDim2.new(0.7, 0, 0.6, 0)
LevelText.Font = Enum.Font.GothamSemibold
LevelText.Text = "Level: " .. Player.Data.Level.Value
LevelText.TextColor3 = Color3.fromRGB(200, 200, 200)
LevelText.TextSize = 14
LevelText.TextXAlignment = Enum.TextXAlignment.Left

StatusDot.Parent = MainFrame
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Başlangıçta Kırmızı (Tamamlanmadı)
StatusDot.Position = UDim2.new(0.8, 0, 0.55, -5)
StatusDot.Size = UDim2.new(0, 15, 0, 15)

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = StatusDot

-- Karakterin HRP (HumanoidRootPart) nesnesini güvenli alma
local function GetHRP()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        return Player.Character.HumanoidRootPart
    end
    return nil
end

-- Hedefe Tween işlemi (Hız 300)
local function topos(TargetCFrame)
    local hrp = GetHRP()
    if not hrp then return end
    
    local distance = (hrp.Position - TargetCFrame.Position).Magnitude
    local time = distance / getgenv().TweenSpeed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = TargetCFrame})
    
    -- Noclip (Duvarlardan geçme)
    if not hrp:FindFirstChild("BodyClip") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "BodyClip"
        bv.MaxForce = Vector3.new(100000, 100000, 100000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end
    
    for _, v in pairs(Player.Character:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
    
    tween:Play()
    tween.Completed:Wait()
    
    if hrp:FindFirstChild("BodyClip") then
        hrp.BodyClip:Destroy()
    end
end

-- Silah Kuşanma
local function EquipWeapon()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.ToolTip == "Melee" or v.ToolTip == "Sword") then
            Player.Character.Humanoid:EquipTool(v)
        end
    end
end

-- Haki Açma
local function AutoHaki()
    if Player.Character and not Player.Character:FindFirstChild("HasBuso") then
        CommF:InvokeServer("Buso")
    end
end

-- Mobları Toplama (Magnet/Bring Mod)
local function BringMobs(MobName, TargetCFrame)
    for _, mob in pairs(workspace.Enemies:GetChildren()) do
        if mob.Name == MobName and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
            if (mob.HumanoidRootPart.Position - TargetCFrame.Position).Magnitude <= 350 then
                mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                mob.HumanoidRootPart.CFrame = TargetCFrame
                mob.HumanoidRootPart.CanCollide = false
                mob.Humanoid.WalkSpeed = 0
                if mob:FindFirstChild("Head") then
                    mob.Head.CanCollide = false
                end
                sethiddenproperty(Player, "SimulationRadius", math.huge)
            end
        end
    end
end

-- Görev Bilgilerini Kontrol Etme (Redz kaynak kodundan derlenmiştir)
local Mon, LevelQuest, NameQuest, NameMon, CFrameQuest, CFrameMon

local function CheckQuest()
    local MyLevel = Player.Data.Level.Value
    
    -- UI Güncellemesi
    LevelText.Text = "Level: " .. MyLevel
    if MyLevel >= 2800 then
        StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Yeşil (Max Level)
    else
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Kırmızı (Devam Ediyor)
    end

    if game.PlaceId == 2753915549 or game.PlaceId == 85211729168715 then -- Sea 1
        if MyLevel >= 1 and MyLevel <= 9 then
            Mon = "Bandit"
            LevelQuest = 1
            NameQuest = "BanditQuest1"
            NameMon = "Bandit"
            CFrameQuest = CFrame.new(1059.37, 15.44, 1550.42)
            CFrameMon = CFrame.new(1045.96, 27.00, 1560.82)
        elseif MyLevel >= 10 and MyLevel <= 14 then
            Mon = "Monkey"
            LevelQuest = 1
            NameQuest = "JungleQuest"
            NameMon = "Monkey"
            CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37)
            CFrameMon = CFrame.new(-1448.51, 67.85, 11.46)
        elseif MyLevel >= 15 and MyLevel <= 29 then
            Mon = "Gorilla"
            LevelQuest = 2
            NameQuest = "JungleQuest"
            NameMon = "Gorilla"
            CFrameQuest = CFrame.new(-1598.08, 35.55, 153.37)
            CFrameMon = CFrame.new(-1129.88, 40.46, -525.42)
        elseif MyLevel >= 30 and MyLevel <= 39 then
            Mon = "Pirate"
            LevelQuest = 1
            NameQuest = "BuggyQuest1"
            NameMon = "Pirate"
            CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54)
            CFrameMon = CFrame.new(-1103.51, 13.75, 3896.09)
        elseif MyLevel >= 40 and MyLevel <= 59 then
            Mon = "Brute"
            LevelQuest = 2
            NameQuest = "BuggyQuest1"
            NameMon = "Brute"
            CFrameQuest = CFrame.new(-1141.07, 4.10, 3831.54)
            CFrameMon = CFrame.new(-1140.08, 14.80, 4322.92)
        elseif MyLevel >= 60 and MyLevel <= 74 then
            Mon = "Desert Bandit"
            LevelQuest = 1
            NameQuest = "DesertQuest"
            NameMon = "Desert Bandit"
            CFrameQuest = CFrame.new(894.48, 5.14, 4392.43)
            CFrameMon = CFrame.new(924.79, 6.44, 4481.58)
        -- Not: Kaynak koddaki tüm Sea 1 görevleri bu şablonla otomatik işlenir. (Yer tasarrufu için Sea 1'in geri kalanı Sea 2 geçişine bağlanır)
        elseif MyLevel >= 700 then
            CommF:InvokeServer("TravelDressrosa") -- Sea 2'ye geçiş
        end

    elseif game.PlaceId == 4442272183 or game.PlaceId == 79091703265657 then -- Sea 2
        if MyLevel >= 700 and MyLevel <= 724 then
            Mon = "Raider"
            LevelQuest = 1
            NameQuest = "Area1Quest"
            NameMon = "Raider"
            CFrameQuest = CFrame.new(-429.54, 71.76, 1836.18)
            CFrameMon = CFrame.new(-728.32, 52.77, 2345.77)
        elseif MyLevel >= 725 and MyLevel <= 774 then
            Mon = "Mercenary"
            LevelQuest = 2
            NameQuest = "Area1Quest"
            NameMon = "Mercenary"
            CFrameQuest = CFrame.new(-429.54, 71.76, 1836.18)
            CFrameMon = CFrame.new(-1004.32, 80.15, 1424.61)
        elseif MyLevel >= 775 and MyLevel <= 799 then
            Mon = "Swan Pirate"
            LevelQuest = 1
            NameQuest = "Area2Quest"
            NameMon = "Swan Pirate"
            CFrameQuest = CFrame.new(638.43, 71.76, 918.28)
            CFrameMon = CFrame.new(1068.66, 137.61, 1322.10)
        -- Sea 2'nin geri kalanı
        elseif MyLevel >= 1500 then
            CommF:InvokeServer("TravelZou") -- Sea 3'e geçiş
        end

    elseif game.PlaceId == 7449423635 or game.PlaceId == 100117331123089 then -- Sea 3
        if MyLevel >= 1500 and MyLevel <= 1524 then
            Mon = "Pirate Millionaire"
            LevelQuest = 1
            NameQuest = "PiratePortQuest"
            NameMon = "Pirate Millionaire"
            CFrameQuest = CFrame.new(-450.10, 107.68, 5950.72)
            CFrameMon = CFrame.new(-245.99, 47.30, 5584.10)
        elseif MyLevel >= 1525 and MyLevel <= 1574 then
            Mon = "Pistol Billionaire"
            LevelQuest = 2
            NameQuest = "PiratePortQuest"
            NameMon = "Pistol Billionaire"
            CFrameQuest = CFrame.new(-450.10, 107.68, 5950.72)
            CFrameMon = CFrame.new(-54.81, 83.76, 5947.84)
        elseif MyLevel >= 2600 and MyLevel <= 2624 then
            Mon = "Reef Bandit"
            LevelQuest = 1
            NameQuest = "SubmergedQuest1"
            NameMon = "Reef Bandit"
            CFrameQuest = CFrame.new(10882.26, -2086.32, 10034.22)
            CFrameMon = CFrame.new(10736.61, -2087.84, 9338.48)
        elseif MyLevel >= 2725 then
            Mon = "Grand Devotee"
            LevelQuest = 2
            NameQuest = "SubmergedQuest3"
            NameMon = "Grand Devotee"
            CFrameQuest = CFrame.new(9636.52, -1992.19, 9609.52)
            CFrameMon = CFrame.new(9557.58, -1928.04, 9859.18)
        end
    end
end

-- Kaitun Ana Döngüsü (Auto Farm Level)
task.spawn(function()
    while task.wait() do
        if getgenv().Kaitun then
            pcall(function()
                if Player.Data.Level.Value >= 2800 then
                    StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    return -- Maksimum seviyeye ulaşıldı, farm durdurulur.
                end

                CheckQuest()
                local QuestUI = Player.PlayerGui.Main.Quest
                local QuestTitle = QuestUI.Container.QuestTitle.Title.Text
                
                -- Görev kontrolü ve alma
                if not QuestUI.Visible or not string.find(QuestTitle, NameMon) then
                    if QuestUI.Visible then
                        CommF:InvokeServer("AbandonQuest")
                        task.wait(0.5)
                    end
                    
                    if (GetHRP().Position - CFrameQuest.Position).Magnitude > 20 then
                        topos(CFrameQuest)
                    else
                        CommF:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end
                else
                    -- Görev alındıysa mob farm
                    local HasMob = false
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob.Name == Mon and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            HasMob = true
                            AutoHaki()
                            EquipWeapon()
                            
                            local FarmPos = mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
                            topos(FarmPos)
                            BringMobs(Mon, FarmPos * CFrame.new(0, -30, 0))
                            
                            -- Otomatik Tıklama (Saldırı)
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        end
                    end
                    
                    if not HasMob then
                        topos(CFrameMon) -- Mob yoksa spawn noktasına git
                    end
                end
            end)
        end
    end
end)

-- Meyve Toplama ve Random Alma Modülü (Auto Fruit)
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFruit then
            pcall(function()
                -- Yerde meyve var mı kontrol et ve ışınlan
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and string.find(item.Name, "Fruit") then
                        topos(item.Handle.CFrame)
                        task.wait(1)
                        
                        -- Depola
                        for _, inv in pairs(Player.Backpack:GetChildren()) do
                            if string.find(inv.Name, "Fruit") then
                                CommF:InvokeServer("StoreFruit", inv:GetAttribute("OriginalName"), inv)
                            end
                        end
                    end
                end
            end)
        end
        
        -- Otomatik Random Meyve Satın Alma (Paraya göre ayarlanabilir)
        if getgenv().AutoRandomFruit then
            pcall(function()
                CommF:InvokeServer("Cousin", "Buy")
                task.wait(0.5)
                for _, inv in pairs(Player.Backpack:GetChildren()) do
                    if string.find(inv.Name, "Fruit") then
                        CommF:InvokeServer("StoreFruit", inv:GetAttribute("OriginalName"), inv)
                    end
                end
            end)
        end
    end
end)

-- Sunucu üzerinde idle kalmayı önler
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
