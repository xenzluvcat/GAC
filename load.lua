-- โหลด UI และป้องกันการรันซ้ำ
if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

-- ระบบ Anti-AFK แบบปลอดภัย (ไม่ใช้ VirtualUser ที่โดนตรวจจับง่าย)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Grow A Chicken (Anti-BAC)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

------------------------------------------------------------------
-- ตัวแปรสถานะ
------------------------------------------------------------------
local _G = _G or {}
_G.AutoUpgrade = false
_G.AutoRebirth = false
_G.AutoTower = false

-- ฟังก์ชันสร้างปุ่ม Toggle
local function CreateToggleButton(name, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = MainFrame
    Btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    Btn.Size = UDim2.new(0, 220, 0, 40)
    Btn.Text = text .. " : OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
        Btn.Text = text .. (enabled and " : ON" or " : OFF")
        callback(enabled)
    end)
end

-- เว้นระยะ
Instance.new("Frame", MainFrame).Size = UDim2.new(1, 0, 0, 30)

------------------------------------------------------------------
-- ระบบ Auto Decline (ใช้วิธีดักจับ ChildAdded ปลอดภัย ไม่โดน BAC ตรวจ)
------------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

if LocalPlayer:FindFirstChild("PlayerGui") then
    LocalPlayer.PlayerGui.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextButton") or descendant:IsA("TextLabel") then
            if string.find(string.upper(descendant.Text or ""), "NO THANKS") then
                task.wait(1.2) -- หน่วงเวลาเหมือนคนกดจริง
                if Remotes and Remotes:FindFirstChild("TowerContinueDecline") then
                    Remotes.TowerContinueDecline:FireServer()
                end
            end
        end
    end)
end

------------------------------------------------------------------
-- 1. Auto Buy & Upgrade
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state)
    _G.AutoUpgrade = state
    task.spawn(function()
        while _G.AutoUpgrade do
            pcall(function()
                if Remotes then
                    Remotes.BuyGenerator:InvokeServer(1)
                    task.wait(0.8)
                    Remotes.BuyGenerator:InvokeServer(2)
                    task.wait(0.8)
                    Remotes.UpgradeGenerator:InvokeServer(1)
                    task.wait(0.8)
                    Remotes.UpgradeGenerator:InvokeServer(2)
                end
            end)
            task.wait(3 + math.random()) -- ระยะเวลาหน่วงสุ่ม ป้องกันการจับลายเซ็น Loop
        end
    end)
end)

------------------------------------------------------------------
-- 2. Auto Rebirth
------------------------------------------------------------------
CreateToggleButton("AutoRebirthBtn", "Auto Rebirth", function(state)
    _G.AutoRebirth = state
    task.spawn(function()
        while _G.AutoRebirth do
            pcall(function()
                if Remotes then
                    Remotes.Rebirth:InvokeServer()
                end
            end)
            task.wait(4 + math.random())
        end
    end)
end)

------------------------------------------------------------------
-- 3. Auto Start Tower
------------------------------------------------------------------
CreateToggleButton("AutoTowerBtn", "Auto Tower", function(state)
    _G.AutoTower = state
    task.spawn(function()
        while _G.AutoTower do
            pcall(function()
                if Remotes then
                    Remotes.TowerStart:InvokeServer()
                end
            end)
            task.wait(5 + math.random())
        end
    end)
end)
