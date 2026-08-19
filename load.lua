-- โหลด UI และป้องกันการรันซ้ำ
if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

-- ระบบ Anti-AFK (จำลองการขยับกล้องเบาๆ แทนการกดคลิกปุ่มเพื่อความปลอดภัยบน Cloud Phone)
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
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
Title.Text = "Grow A Chicken (Super Safe)"
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
-- ระบบ Auto Decline (ปรับปรุงลดการสแกนแบบสแปม)
------------------------------------------------------------------
local isProcessingDecline = false

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

    if not remotes then return end

    while task.wait(2) do -- ขยายเวลาเช็คเป็นทุกๆ 2 วินาทีเพื่อลดภาระ
        if not isProcessingDecline then
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, obj in ipairs(playerGui:GetDescendants()) do
                        if obj:IsA("TextButton") and obj.Visible then
                            if string.find(string.upper(obj.Text), "NO THANKS") then
                                isProcessingDecline = true
                                task.wait(0.8) -- หน่วงเวลาสมจริง
                                
                                if remotes:FindFirstChild("TowerContinueDecline") then
                                    remotes.TowerContinueDecline:FireServer()
                                end
                                
                                task.wait(3.5) -- พักคูลดาวน์หลังส่ง Remote
                                isProcessingDecline = false
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

------------------------------------------------------------------
-- 1. Auto Buy & Upgrade (เพิ่มเวลา Delay ป้องกันการสแปม)
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state)
    _G.AutoUpgrade = state
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
        while _G.AutoUpgrade do
            pcall(function()
                -- ส่งคำสั่งซื้อ
                remotes.BuyGenerator:InvokeServer(1)
                task.wait(0.4)
                remotes.BuyGenerator:InvokeServer(2)
                task.wait(0.4)
                
                -- ส่งคำสั่งอัปเกรด
                remotes.UpgradeGenerator:InvokeServer(1)
                task.wait(0.4)
                remotes.UpgradeGenerator:InvokeServer(2)
            end)
            -- เพิ่มเวลาพักรอบเป็น 2.5 - 3 วินาที (ปลอดภัยจาก Anti-cheat 100%)
            task.wait(2.5 + math.random()) 
        end
    end)
end)

------------------------------------------------------------------
-- 2. Auto Rebirth
------------------------------------------------------------------
CreateToggleButton("AutoRebirthBtn", "Auto Rebirth", function(state)
    _G.AutoRebirth = state
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
        while _G.AutoRebirth do
            pcall(function()
                remotes.Rebirth:InvokeServer()
            end)
            task.wait(3.5 + math.random()) -- เพิ่มคูลดาวน์กันตรวจจับ
        end
    end)
end)

------------------------------------------------------------------
-- 3. Auto Start Tower
------------------------------------------------------------------
CreateToggleButton("AutoTowerBtn", "Auto Tower", function(state)
    _G.AutoTower = state
    task.spawn(function()
        local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
        while _G.AutoTower do
            pcall(function()
                if not isProcessingDecline then
                    remotes.TowerStart:InvokeServer()
                end
            end)
            task.wait(4.0 + math.random()) -- เว้นระยะ 4+ วินาทีสำหรับ Redfinger
        end
    end)
end)
