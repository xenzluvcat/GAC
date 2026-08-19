-- โหลด UI และป้องกันการรันซ้ำ
if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

-- ระบบ Anti-AFK (กันหลุดเวลาเปิดทิ้งไว้)
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

-- ปุ่ม Menu ลอย (ลากย้ายได้)
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
Title.Text = "Grow A Chicken (Safe)"
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
-- ระบบ Auto Decline Safe Mode (ไม่รัว ไม่โดน Kick)
------------------------------------------------------------------
local isProcessingDecline = false

task.spawn(function()
    local player = game:GetService("Players").LocalPlayer
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

    while true do
        task.wait(1) -- ตรวจสอบทุกๆ 1 วินาที
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui and not isProcessingDecline then
                -- ค้นหาว่าปุ่ม NO THANKS ปรากฏบนหน้าจอหรือเปล่า
                for _, obj in pairs(playerGui:GetDescendants()) do
                    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                        if string.find(string.upper(obj.Text), "NO THANKS") and obj.Visible then
                            isProcessingDecline = true
                            
                            -- ส่ง Remote เพียงครั้งเดียวหลังพบ UI
                            task.wait(0.5) -- หน่วงเวลาสมจริงเหมือนคนกด
                            remotes.TowerContinueDecline:FireServer()
                            
                            task.wait(2) -- รอ 2 วินาทีก่อนให้ทำงานครั้งถัดไป
                            isProcessingDecline = false
                            break
                        end
                    end
                end
            end
        end)
    end
end)

------------------------------------------------------------------
-- 1. Auto Buy & Upgrade
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state)
    _G.AutoUpgrade = state
    task.spawn(function()
        while _G.AutoUpgrade do
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage").Remotes
                remotes.BuyGenerator:InvokeServer(1)
                remotes.BuyGenerator:InvokeServer(2)
                task.wait(0.3)
                remotes.UpgradeGenerator:InvokeServer(1)
                remotes.UpgradeGenerator:InvokeServer(2)
            end)
            task.wait(0.8) -- ปรับคูลดาวน์ให้ปลอดภัยยิ่งขึ้น
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
                game:GetService("ReplicatedStorage").Remotes.Rebirth:InvokeServer()
            end)
            task.wait(1.5)
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
                -- สั่งเริ่ม Tower ก็ต่อเมื่อไม่ได้อยู่ในขั้นตอนการกด Decline
                if not isProcessingDecline then
                    game:GetService("ReplicatedStorage").Remotes.TowerStart:InvokeServer()
                end
            end)
            task.wait(2.5) -- หน่วงเวลาเพื่อป้องกัน Anti-Cheat
        end
    end)
end)
