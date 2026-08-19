------------------------------------------------------------------
-- ระบบ Auto Rejoin เมื่อโดนเตะ / หลุดเชื่อมต่อ
------------------------------------------------------------------
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

GuiService.ErrorMessageChanged:Connect(function()
    task.wait(2) -- รอ 2 วินาทีให้หน้าต่างหลุดแสดงขึ้นมา
    pcall(function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end)

------------------------------------------------------------------
-- ป้องกันการโหลดสคริปต์ซ้ำซ้อน
------------------------------------------------------------------
if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

-- ระบบ Anti-AFK แบบปลอดภัย
LocalPlayer.Idled:Connect(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

-- สร้าง UI หลักสำหรับ Delta มือถือ
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleWindowBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "ChickenMobileUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ปุ่ม Menu ลอย
ToggleWindowBtn.Name = "ToggleWindowBtn"
ToggleWindowBtn.Parent = ScreenGui
ToggleWindowBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
ToggleWindowBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleWindowBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleWindowBtn.Text = "Menu"
ToggleWindowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleWindowBtn.Active = true
ToggleWindowBtn.Draggable = true
Instance.new("UICorner", ToggleWindowBtn).CornerRadius = UDim.new(0.5, 0)

-- หน้าต่างหลัก
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -120)
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Grow A Chicken (Auto Rejoin)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

------------------------------------------------------------------
-- ตัวแปรสถานะ (เปิดใช้งานอัตโนมัติเมื่อเข้าเกมใหม่)
------------------------------------------------------------------
local _G = _G or {}
_G.AutoUpgrade = true  -- ตั้งเป็น true เพื่อให้เปิดทำงานทันทีเมื่อ Rejoin
_G.AutoRebirth = true
_G.AutoTower = true

-- ฟังก์ชันสร้างปุ่ม Toggle
local function CreateToggleButton(name, text, defaultState, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = MainFrame
    Btn.BackgroundColor3 = defaultState and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
    Btn.Size = UDim2.new(0, 220, 0, 40)
    Btn.Text = text .. (defaultState and " : ON" or " : OFF")
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local enabled = defaultState
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
        Btn.Text = text .. (enabled and " : ON" or " : OFF")
        callback(enabled)
    end)
    
    -- เรียกใช้ callback ทันทีตามค่าเริ่มต้น
    callback(enabled)
end

-- เว้นระยะ
Instance.new("Frame", MainFrame).Size = UDim2.new(1, 0, 0, 30)

------------------------------------------------------------------
-- ดึง Remotes
------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)

local function SafeFire(remoteName, ...)
    if Remotes and Remotes:FindFirstChild(remoteName) then
        local remote = Remotes[remoteName]
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            task.spawn(function()
                remote:InvokeServer(...)
            end)
        end
    end
end

------------------------------------------------------------------
-- 1. Auto Buy & Upgrade
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", _G.AutoUpgrade, function(state)
    _G.AutoUpgrade = state
    if state then
        task.spawn(function()
            while _G.AutoUpgrade do
                pcall(function()
                    SafeFire("BuyGenerator", 1)
                    task.wait(0.3)
                    SafeFire("BuyGenerator", 2)
                    task.wait(0.3)
                    SafeFire("UpgradeGenerator", 1)
                    task.wait(0.3)
                    SafeFire("UpgradeGenerator", 2)
                end)
                task.wait(2)
            end
        end)
    end
end)

------------------------------------------------------------------
-- 2. Auto Rebirth
------------------------------------------------------------------
CreateToggleButton("AutoRebirthBtn", "Auto Rebirth", _G.AutoRebirth, function(state)
    _G.AutoRebirth = state
    if state then
        task.spawn(function()
            while _G.AutoRebirth do
                pcall(function()
                    SafeFire("Rebirth")
                end)
                task.wait(3)
            end
        end)
    end
end)

------------------------------------------------------------------
-- 3. Auto Start Tower
------------------------------------------------------------------
CreateToggleButton("AutoTowerBtn", "Auto Tower", _G.AutoTower, function(state)
    _G.AutoTower = state
    if state then
        task.spawn(function()
            while _G.AutoTower do
                pcall(function()
                    SafeFire("TowerStart")
                end)
                task.wait(2.5)
            end
        end)
    end
end)
