if game:GetService("CoreGui"):FindFirstChild("ChickenMobileUI") then
    game:GetService("CoreGui").ChickenMobileUI:Destroy()
end

local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleWindowBtn = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")

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
Title.Text = "Grow A Chicken"
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

Instance.new("Frame", MainFrame).Size = UDim2.new(1, 0, 0, 30)

task.spawn(function()
    while true do
        task.wait(0.3) 
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.TowerContinueDecline:FireServer()
        end)
    end
end)

CreateToggleButton("AutoUpgradeBtn", "Auto Upgrade", function(state)
    _G.AutoUpgrade = state
    task.spawn(function()
        while _G.AutoUpgrade do
            pcall(function()
                local remotes = game:GetService("ReplicatedStorage").Remotes
                remotes.BuyGenerator:InvokeServer(1)
                remotes.BuyGenerator:InvokeServer(2)
                task.wait(0.2)
                remotes.UpgradeGenerator:InvokeServer(1)
                remotes.UpgradeGenerator:InvokeServer(2)
            end)
            task.wait(0.5)
        end
    end)
end)

CreateToggleButton("AutoRebirthBtn", "Auto Rebirth", function(state)
    _G.AutoRebirth = state
    task.spawn(function()
        while _G.AutoRebirth do
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.Rebirth:InvokeServer()
            end)
            task.wait(1)
        end
    end)
end)

CreateToggleButton("AutoTowerBtn", "Auto Tower", function(state)
    _G.AutoTower = state
    task.spawn(function()
        while _G.AutoTower do
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.TowerStart:InvokeServer()
            end)
            task.wait(2)
        end
    end)
end)
