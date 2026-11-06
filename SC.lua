-- // Say Cheese Script
-- // By Entropy Code
-- // Executor: Delta

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Clipboard = setclipboard or toclipboard

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Cek Remote & Modul Save game dari decompiler awal
local remotes = ReplicatedStorage:FindFirstChild("WBWWBRemotes")
local unlockEvent = remotes and remotes:FindFirstChild("Unlock")

local wbwPath = ReplicatedStorage:FindFirstChild("WBWWB")
local SaveModule = wbwPath and wbwPath:FindFirstChild("Save") or ReplicatedStorage:FindFirstChild("Save")
local Save = SaveModule and require(SaveModule) or nil

if not unlockEvent then
    warn("Remote Event 'Unlock' not found!")
    return
end

-- Hapus GUI lama jika ada
if CoreGui:FindFirstChild("EntropyEndingsGui") then
    CoreGui.EntropyEndingsGui:Destroy()
end

-- Buat ScreenGui di CoreGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EntropyEndingsGui"
screenGui.Parent = CoreGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 480)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(120, 80, 255)
uiStroke.Thickness = 2
uiStroke.Parent = mainFrame

-- Auto-Scale Responsive agar pas di berbagai perangkat
local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function updateAutoScaling()
    local screenSize = camera.ViewportSize
    local scale = math.clamp(screenSize.X / 1200, 0.8, 1.2)
    uiScale.Scale = scale
end

updateAutoScaling()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateAutoScaling)

-- Top Bar (Judul & Tombol Minimize/Maximize)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 50)
topBar.BackgroundTransparency = 1
topBar.Parent = mainFrame

-- Sistem Drag Manual yang Mulus, Responsif, dan Bebas (Tanpa Pembatas Kaku)
local dragging, dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.AbsolutePosition
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local absSize = mainFrame.AbsoluteSize
        
        -- Perhitungan posisi bebas tanpa batas layar agar tidak ngebug/getar
        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y
        
        mainFrame.Position = UDim2.new(
            0, newX + (absSize.X * mainFrame.AnchorPoint.X), 
            0, newY + (absSize.Y * mainFrame.AnchorPoint.Y)
        )
    end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "📸Say Cheese Unlock Endings{BETA}"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- ScrollingFrame untuk daftar tombol ending
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.92, 0, 0.58, 0)
scrollFrame.Position = UDim2.new(0.04, 0, 0, 52)
scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 10)

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Padding = UDim.new(0, 6)
uiListLayout.Parent = scrollFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingTop = UDim.new(0, 8)
uiPadding.PaddingBottom = UDim.new(0, 8)
uiPadding.PaddingLeft = UDim.new(0, 8)
uiPadding.PaddingRight = UDim.new(0, 8)
uiPadding.Parent = scrollFrame

-- Footer (Note, Kredit, & Tombol Discord)
local footerFrame = Instance.new("Frame")
footerFrame.Size = UDim2.new(0.92, 0, 0, 110)
footerFrame.Position = UDim2.new(0.04, 0, 0.74, 0)
footerFrame.BackgroundTransparency = 1
footerFrame.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 0, 2)
divider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
divider.BorderSizePixel = 0
divider.Parent = footerFrame

-- Tulisan Note Interaktif (Tahan 0.7 detik untuk REJOIN)
local noteLabel = Instance.new("TextButton")
noteLabel.Size = UDim2.new(1, 0, 0, 24)
noteLabel.Position = UDim2.new(0, 0, 0, 8)
noteLabel.BackgroundTransparency = 1
noteLabel.Text = "Note: If not unlocked, hold here to REJOIN!"
noteLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
noteLabel.TextSize = 12
noteLabel.Font = Enum.Font.SourceSansItalic
noteLabel.TextXAlignment = Enum.TextXAlignment.Left
noteLabel.Parent = footerFrame

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(1, 0, 0, 18)
creditLabel.Position = UDim2.new(0, 0, 0, 34)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "By Entropy Code"
creditLabel.TextColor3 = Color3.fromRGB(170, 150, 255)
creditLabel.TextSize = 12
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextXAlignment = Enum.TextXAlignment.Left
creditLabel.Parent = footerFrame

local discordLabel = Instance.new("TextButton")
discordLabel.Size = UDim2.new(1, 0, 0, 32)
discordLabel.Position = UDim2.new(0, 0, 0, 56)
discordLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
discordLabel.Text = "discord.gg/tAd4tYUE"
discordLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
discordLabel.TextSize = 12
discordLabel.Font = Enum.Font.GothamMedium
discordLabel.Parent = footerFrame

Instance.new("UICorner", discordLabel).CornerRadius = UDim.new(0, 6)

-- Logika Tombol Minimize (-) dan Maximize (+)
local isMinimized = false

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 32, 0, 32)
toggleBtn.Position = UDim2.new(0.85, 0, 0.18, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
toggleBtn.Text = "-"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = topBar
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        toggleBtn.Text = "+"
        scrollFrame.Visible = false
        footerFrame.Visible = false
        titleLabel.Text = "📸Say Cheese Unlock Endings"
        mainFrame.Size = UDim2.new(0, 260, 0, 50)
    else
        toggleBtn.Text = "-"
        scrollFrame.Visible = true
        footerFrame.Visible = true
        titleLabel.Text = "📸Say Cheese Unlock Endings"
        mainFrame.Size = UDim2.new(0, 400, 0, 480)
    end
end)

-- Fungsi Pembuatan Tombol Ending
local function createButton(endingName, endingId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Parent = scrollFrame
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local alreadyUnlocked = false
    if Save and Save.has then
        alreadyUnlocked = Save.has(endingId)
    end
    
    if alreadyUnlocked then
        btn.Text = "Done " .. endingName
        btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        btn.Text = "Unlock: " .. endingName
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            unlockEvent:FireServer(endingId)
        end)
        btn.Text = "Done " .. endingName
        btn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    end)
end

-- List semua ending game
local endingsList = {
    {Name = "Viral Ending", Id = "viral"},
    {Name = "Cricket Ending", Id = "cricky"},
    {Name = "TV Ending", Id = "infinite"},
    {Name = "Breaking News Ending", Id = "breaking"},
    {Name = "Reverse Ending", Id = "watched"},
    {Name = "Scared Ending", Id = "afraid"},
    {Name = "Good Ending", Id = "goodnews"},
    {Name = "Peace Ending", Id = "peace"},
    {Name = "Hat Ending", Id = "hattrick"},
    {Name = "Eyes Closed Ending", Id = "lookaway"},
    {Name = "Say Cheese Ending", Id = "cheese"},
    {Name = "Follow The Money Ending", Id = "money"},
    {Name = "Off Air Ending", Id = "offair"},
    {Name = "Star Ending", Id = "star"}
}

for _, ending in ipairs(endingsList) do
    createButton(ending.Name, ending.Id)
end

-- Logika Hold 0.7 Detik pada Tulisan NOTE untuk REJOIN
local rejoinHoldTime = 0.7
local isRejoinHolding = false
local rejoinThread = nil

noteLabel.MouseButton1Down:Connect(function()
    isRejoinHolding = true
    noteLabel.Text = "Rejoining..."
    rejoinThread = task.spawn(function()
        task.wait(rejoinHoldTime)
        if isRejoinHolding then
            pcall(function()
                TeleportService:Teleport(game.PlaceId, player)
            end)
        end
    end)
end)

noteLabel.MouseButton1Up:Connect(function()
    isRejoinHolding = false
    if rejoinThread then task.cancel(rejoinThread) end
    noteLabel.Text = "Note: If not unlocked, hold here to REJOIN!"
end)

noteLabel.MouseLeave:Connect(function()
    isRejoinHolding = false
    if rejoinThread then task.cancel(rejoinThread) end
    noteLabel.Text = "Note: If not unlocked, hold here to REJOIN!"
end)

-- Logika Hold 0.7 Detik pada Tombol Discord untuk Salin Link
local dcHoldTime = 0.7
local isDcHolding = false
local dcThread = nil

discordLabel.MouseButton1Down:Connect(function()
    isDcHolding = true
    discordLabel.Text = "Copying..."
    dcThread = task.spawn(function()
        task.wait(dcHoldTime)
        if isDcHolding then
            if Clipboard then
                pcall(function()
                    Clipboard("discord.gg/tAd4tYUE")
                end)
            end
            discordLabel.Text = "Copied!"
            discordLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
            task.wait(1.2)
            discordLabel.Text = "discord.gg/tAd4tYUE"
            discordLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        end
    end)
end)

discordLabel.MouseButton1Up:Connect(function()
    isDcHolding = false
    if dcThread then task.cancel(dcThread) end
    discordLabel.Text = "discord.gg/tAd4tYUE"
    discordLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
end)

discordLabel.MouseLeave:Connect(function()
    isDcHolding = false
    if dcThread then task.cancel(dcThread) end
    discordLabel.Text = "discord.gg/tAd4tYUE"
    discordLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
end)
