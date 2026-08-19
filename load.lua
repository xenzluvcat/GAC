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
Title.Text = "Grow A Chicken (Bypass BAC)"
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

local isProcessing = false

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

-- ฟังก์ชันเซฟยิง Remote (รองรับทั้ง Invoke และ Fire แบบไม่ค้าง)
local function SafeCall(remote, method, ...)
    if not remote then return end
    local args = {...}
    task.spawn(function()
        pcall(function()
            if method == "Invoke" and remote:IsA("RemoteFunction") then
                remote:InvokeServer(unpack(args))
            elseif remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(unpack(args))
            end
        end)
    end)
end

------------------------------------------------------------------
-- ระบบ Queue + Random Delay หลบการตรวจจับ
------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(math.random(15, 25) / 10) -- สุ่มเวลารอ 1.5 - 2.5 วินาที
        
        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if remotes and not isProcessing then
            
            -- 1. Auto Rebirth
            if _G.AutoRebirth then
                isProcessing = true
                SafeCall(remotes:FindFirstChild("Rebirth"), "Invoke")
                task.wait(math.random(30, 45) / 10) -- หน่วงหลัง Rebirth 3.0 - 4.5 วินาที
                isProcessing = false
            end

            -- 2. Auto Start Tower
            if _G.AutoTower and not isProcessing then
                isProcessing = true
                SafeCall(remotes:FindFirstChild("TowerStart"), "Invoke")
                task.wait(math.random(35, 50) / 10) -- หน่วงหลัง Tower 3.5 - 5.0 วินาที
                isProcessing = false
            end

            -- 3. Auto Upgrade
            if _G.AutoUpgrade and not isProcessing then
                isProcessing = true
                SafeCall(remotes:FindFirstChild("BuyGenerator"), "Invoke", 1)
                task.wait(0.8)
                SafeCall(remotes:FindFirstChild("BuyGenerator"), "Invoke", 2)
                task.wait(0.8)
                SafeCall(remotes:FindFirstChild("UpgradeGenerator"), "Invoke", 1)
                task.wait(0.8)
                SafeCall(remotes:FindFirstChild("UpgradeGenerator"), "Invoke", 2)
                task.wait(2.0)
                isProcessing = false
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
