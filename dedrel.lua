-- Script lengkap Dead Rails dengan Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Variabel global untuk fitur
local Aimlock = {
    Enabled = false,
    Target = nil,
    Hitpart = "Head",
    Prediction = 0.14,
    Smoothing = 0.1,
    FOV = 60
}

local SilentAim = {
    Enabled = false,
    HitChance = 100,
    Hitpart = "Head"
}

local Noclip = false
local InfiniteStamina = false
local AutoClicker = false
local AntiAFK = false
local ESPEnabled = false
local ShowFOVCircle = false
local FOVCircle = nil

-- Membuat window utama
local Window = Rayfield:CreateWindow({
    Name = "Dead Rails Ultimate",
    LoadingTitle = "Dead Rails Cheat Suite",
    LoadingSubtitle = "Loading all features...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DeadRailsConfig",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- ========== TAB COMBAT ==========
local CombatTab = Window:CreateTab("Combat", 7742056047) -- Icon gun
local CombatSection = CombatTab:CreateSection("Aim Assist")

-- Aimlock
CombatTab:CreateToggle({
    Name = "Aimlock",
    CurrentValue = false,
    Flag = "AimlockToggle",
    Callback = function(Value)
        Aimlock.Enabled = Value
        if Value then
            RunAimlock()
        end
    end,
})

CombatTab:CreateDropdown({
    Name = "Aimlock Hitpart",
    Options = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
    CurrentOption = "Head",
    Flag = "AimlockHitpart",
    Callback = function(Option)
        Aimlock.Hitpart = Option
    end,
})

CombatTab:CreateSlider({
    Name = "Aimlock Prediction",
    Range = {0, 0.5},
    Increment = 0.01,
    Suffix = "sec",
    CurrentValue = 0.14,
    Flag = "AimlockPrediction",
    Callback = function(Value)
        Aimlock.Prediction = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Aimlock Smoothing",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "smooth",
    CurrentValue = 0.1,
    Flag = "AimlockSmoothing",
    Callback = function(Value)
        Aimlock.Smoothing = Value
    end,
})

CombatTab:CreateSlider({
    Name = "Aimlock FOV",
    Range = {0, 360},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 60,
    Flag = "AimlockFOV",
    Callback = function(Value)
        Aimlock.FOV = Value
        if FOVCircle then
            FOVCircle.Radius = Aimlock.FOV
        end
    end,
})

-- Silent Aim
CombatTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Callback = function(Value)
        SilentAim.Enabled = Value
    end,
})

CombatTab:CreateDropdown({
    Name = "Silent Aim Hitpart",
    Options = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
    CurrentOption = "Head",
    Flag = "SilentAimHitpart",
    Callback = function(Option)
        SilentAim.Hitpart = Option
    end,
})

CombatTab:CreateSlider({
    Name = "Silent Aim Hit Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 100,
    Flag = "SilentAimHitChance",
    Callback = function(Value)
        SilentAim.HitChance = Value
    end,
})

CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "FOVCircleToggle",
    Callback = function(Value)
        ShowFOVCircle = Value
        if Value then
            CreateFOVCircle()
        else
            if FOVCircle then
                FOVCircle:Destroy()
                FOVCircle = nil
            end
        end
    end,
})

-- ========== TAB PLAYER ==========
local PlayerTab = Window:CreateTab("Player", 4483362458) -- Icon player
local PlayerSection = PlayerTab:CreateSection("Player Modifications")

PlayerTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        if Value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "High Jump",
    CurrentValue = false,
    Flag = "JumpHack",
    Callback = function(Value)
        if Value then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
        else
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Noclip = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfStamina",
    Callback = function(Value)
        InfiniteStamina = Value
    end,
})

-- ========== TAB TRAIN ==========
local TrainTab = Window:CreateTab("Train", 473788923) -- Icon train
local TrainSection = TrainTab:CreateSection("Train Controls")

TrainTab:CreateSlider({
    Name = "Train Speed Multiplier",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "TrainSpeed",
    Callback = function(Value)
        for _, train in pairs(workspace:FindFirstChild("Trains"):GetChildren()) do
            if train:FindFirstChild("Configuration") and train.Configuration:FindFirstChild("Speed") then
                train.Configuration.Speed.Value = Value * 10
            end
        end
    end,
})

TrainTab:CreateButton({
    Name = "Instant Brake",
    Callback = function()
        for _, train in pairs(workspace:FindFirstChild("Trains"):GetChildren()) do
            if train:FindFirstChild("Configuration") and train.Configuration:FindFirstChild("Speed") then
                train.Configuration.Speed.Value = 0
            end
        end
    end,
})

-- ========== TAB VISUAL ==========
local VisualTab = Window:CreateTab("Visual", 6034287533) -- Icon eye
local VisualSection = VisualTab:CreateSection("Visual Modifications")

VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        if Value then
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Brightness = 2
        else
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").Brightness = 1
        end
    end,
})

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        ESPEnabled = Value
        if ESPEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    CreateESP(player)
                end
            end
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    RemoveESP(player)
                end
            end
        end
    end,
})

-- ========== TAB TELEPORT ==========
local TeleportTab = Window:CreateTab("Teleport", 4777778860) -- Icon teleport
local TeleportSection = TeleportTab:CreateSection("Location Teleport")

local Locations = {
    "Spawn Point",
    "Train Station",
    "Power Plant",
    "Mine Entrance",
    "Tunnel Center"
}

TeleportTab:CreateDropdown({
    Name = "Select Location",
    Options = Locations,
    CurrentOption = "Spawn Point",
    Flag = "TeleportLoc",
    Callback = function(Option)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Option == "Spawn Point" then
                    hrp.CFrame = game:GetService("Workspace").SpawnLocation.CFrame
                elseif Option == "Train Station" then
                    hrp.CFrame = CFrame.new(100, 50, -200)
                -- Tambahkan lokasi lainnya
                end
            end
        end
    end,
})

-- ========== TAB MISC ==========
local MiscTab = Window:CreateTab("Misc", 6031302931) -- Icon settings
local MiscSection = MiscTab:CreateSection("Miscellaneous")

MiscTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClicker",
    Callback = function(Value)
        AutoClicker = Value
    end,
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        AntiAFK = Value
        if AntiAFK then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:connect(function()
                vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame
                wait(1)
                vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame
            end)
        end
    end,
})

MiscTab:CreateKeybind({
    Name = "Toggle UI Keybind",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "UIKeybind",
    Callback = function(Keybind)
        Rayfield:Toggle()
    end,
})

-- ========== FUNGSI UTAMA ==========
-- Fungsi Aimlock
function RunAimlock()
    coroutine.wrap(function()
        while Aimlock.Enabled do
            wait()
            
            local closestPlayer, closestDistance = FindClosestPlayer()
            
            if closestPlayer and closestDistance <= Aimlock.FOV then
                Aimlock.Target = closestPlayer
                local targetPart = closestPlayer.Character:FindFirstChild(Aimlock.Hitpart)
                if targetPart then
                    local predictedPosition = targetPart.Position + (targetPart.Velocity * Aimlock.Prediction)
                    local camera = workspace.CurrentCamera
                    local smoothedPosition = camera.CFrame.Position:Lerp(predictedPosition, Aimlock.Smoothing)
                    
                    camera.CFrame = CFrame.new(camera.CFrame.Position, smoothedPosition)
                end
            else
                Aimlock.Target = nil
            end
        end
    end)()
end

-- Fungsi Silent Aim Hook
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if SilentAim.Enabled and method == "FindPartOnRayWithIgnoreList" and math.random(1, 100) <= SilentAim.HitChance then
        local closestPlayer = FindClosestPlayer()
        if closestPlayer then
            local targetPart = closestPlayer.Character:FindFirstChild(SilentAim.Hitpart)
            if targetPart then
                args[1] = Ray.new(args[1].Origin, (targetPart.Position - args[1].Origin).Unit * 1000)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Fungsi untuk mencari player terdekat
function FindClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localPosition = localCharacter and localCharacter:FindFirstChild("Head") and localCharacter.Head.Position
    
    if localPosition then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local distance = (player.Character.Head.Position - localPosition).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Fungsi untuk membuat FOV Circle
function CreateFOVCircle()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = true
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Radius = Aimlock.FOV
    FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        FOVCircle.Radius = Aimlock.FOV
        FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
    end)
end

-- Fungsi ESP
function CreateESP(player)
    -- Implementasi ESP disini
    -- Contoh: membuat highlight atau box sekitar player
end

function RemoveESP(player)
    -- Implementasi penghapusan ESP
end

-- Loop untuk No Clip dan Infinite Stamina
game:GetService('RunService').Stepped:Connect(function()
    if Noclip and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if InfiniteStamina and game.Players.LocalPlayer.Character:FindFirstChild("Stamina") then
        game.Players.LocalPlayer.Character.Stamina.Value = 100
    end
end)

-- Loop untuk Auto Clicker
game:GetService('RunService').RenderStepped:Connect(function()
    if AutoClicker then
        mouse1click()
    end
end)

-- Memuat konfigurasi
Rayfield:LoadConfiguration()

-- Notifikasi saat load
Rayfield:Notify({
    Title = "Dead Rails Ultimate Loaded",
    Content = "All features activated successfully!",
    Duration = 6.5,
    Image = 7742056047,
    Actions = {
        Ignore = {
            Name = "Okay",
            Callback = function()
                print("User acknowledged notification")
            end
        },
    },
})
