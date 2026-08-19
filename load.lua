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

-- สร้าง UI สำหรับ Redfinger
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
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Redfinger Fix Mode"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 8)

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local _G = _G or {}
_G.AutoUpgrade = false
_G.AutoRebirth = false
_G.AutoTower = false

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
-- 1. Auto Buy & Upgrade (ขยายเวลาเว้นช่วงสำหรับ Redfinger)
------------------------------------------------------------------
CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state)
    _G.AutoUpgrade = state
    task.spawn(function()
        while _G.AutoUpgrade do
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if remotes then
                    remotes.BuyGenerator:InvokeServer(1)
                    task.wait(1.5) -- เว้นช่วง 1.5 วินาที เพื่อไม่ให้เน็ต Redfinger ส่งแพ็กเกจชนกัน
                    remotes.UpgradeGenerator:InvokeServer(1)
                    task.wait(1.5)
                    remotes.BuyGenerator:InvokeServer(2)
                    task.wait(1.5)
                    remotes.UpgradeGenerator:InvokeServer(2)
                end
            end)
            task.wait(4)
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
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if remotes then
                    remotes.Rebirth:InvokeServer()
                end
            end)
            task.wait(5)
        end
    end)
end)

------------------------------------------------------------------
-- 3. Auto Start Tower
------------------------------------------------------------------
CreateToggleButton("AutoTowerBtn", "Auto Start Tower", function(state)
    _G.AutoTower = state
    task.spawn(function()
        while _G.AutoTower do
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if remotes then
                    remotes.TowerStart:InvokeServer()
                end
            end)
            task.wait(8) -- ตั้งไว้ 8 วินาที เพื่อให้มั่นใจว่าตัวละครใน Redfinger โหลดเข้า Tower เสร็จแล้วจริงๆ
        end
    end)
end)
