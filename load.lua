-- โหลด UI และป้องกันการรันซ้ำ
if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

-- ระบบ Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleWindowBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "ChickenMobileUI"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

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
Title.Text = "Grow A Chicken (Queue Fix)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

------------------------------------------------------------------
-- ตัวแปรสถานะ & ระบบ Queue ป้องกันคำสั่งชนกัน
------------------------------------------------------------------
local _G = _G or {}
_G.AutoUpgrade = false
_G.AutoRebirth = false
_G.AutoTower = false

local isBusy = false -- ตัวแปรเช็คว่ามี Remote อื่นกำลังทำงานอยู่ไหม

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

Instance.new("Frame", MainFrame).Size = UDim2.new(1, 0, 0, 30)

------------------------------------------------------------------
-- Loop หลัก: จัดคิวทำงานทีละอย่าง สลับกันนุ่มนวล
------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1.2) -- เว้นระยะรอบใหญ่ ไม่ให้เซิร์ฟเวอร์สงสัย
        
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes and not isBusy then
            
            -- 1. ลำดับ Rebirth (สำคัญสุด)
            if _G.AutoRebirth then
                isBusy = true
                pcall(function()
                    if remotes:FindFirstChild("Rebirth") then
                        remotes.Rebirth:InvokeServer()
                    end
                end)
                task.wait(2.0) -- พักหลัง Rebirth
                isBusy = false
            end

            -- 2. ลำดับ Start Tower
            if _G.AutoTower and not isBusy then
                isBusy = true
                pcall(function()
                    if remotes:FindFirstChild("TowerStart") then
                        remotes.TowerStart:InvokeServer()
                    end
                end)
                task.wait(2.0) -- พักหลัง Tower
                isBusy = false
            end

            -- 3. ลำดับ Upgrade
            if _G.AutoUpgrade and not isBusy then
                isBusy = true
                pcall(function()
                    if remotes:FindFirstChild("BuyGenerator") then
                        remotes.BuyGenerator:InvokeServer(1)
                        task.wait(0.5)
                        remotes.BuyGenerator:InvokeServer(2)
                    end
                    task.wait(0.5)
                    if remotes:FindFirstChild("UpgradeGenerator") then
                        remotes.UpgradeGenerator:InvokeServer(1)
                        task.wait(0.5)
                        remotes.UpgradeGenerator:InvokeServer(2)
                    end
                end)
                task.wait(1.5)
                isBusy = false
            end
            
        end
    end
end)

------------------------------------------------------------------
-- ปุ่มกด Toggle สวิตช์
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state) _G.AutoUpgrade = state end)
CreateToggleButton("AutoRebirthBtn", "Auto Rebirth", function(state) _G.AutoRebirth = state end)
CreateToggleButton("AutoTowerBtn", "Auto Tower", function(state) _G.AutoTower = state end)
