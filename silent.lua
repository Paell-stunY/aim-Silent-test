-- Roblox Silent Aim GUI (Educational Only)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAimGUI"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "SILENT AIM"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "OFF"
ToggleButton.Size = UDim2.new(0.8, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.TextColor3 = Color3.white
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

local FOVSlider = Instance.new("TextLabel")
FOVSlider.Text = "FOV: 50"
FOVSlider.Size = UDim2.new(0.8, 0, 0, 20)
FOVSlider.Position = UDim2.new(0.1, 0, 0.6, 0)
FOVSlider.BackgroundTransparency = 1
FOVSlider.TextColor3 = Color3.white
FOVSlider.Font = Enum.Font.SourceSans
FOVSlider.Parent = Frame

local TargetPartLabel = Instance.new("TextLabel")
TargetPartLabel.Text = "Target: Head"
TargetPartLabel.Size = UDim2.new(0.8, 0, 0, 20)
TargetPartLabel.Position = UDim2.new(0.1, 0, 0.75, 0)
TargetPartLabel.BackgroundTransparency = 1
TargetPartLabel.TextColor3 = Color3.white
TargetPartLabel.Font = Enum.Font.SourceSans
TargetPartLabel.Parent = Frame

-- Silent Aim Variables
local SilentAimEnabled = false
local FOV = 50
local TargetPart = "Head"

-- FOV Circle Visualization
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Thickness = 1
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Transparency = 0.5
Circle.Filled = false
Circle.Radius = FOV

-- Toggle Button Function
ToggleButton.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    Circle.Visible = SilentAimEnabled
    if SilentAimEnabled then
        ToggleButton.Text = "ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        ToggleButton.Text = "OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Adjust FOV with Mouse Wheel
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        FOV = math.clamp(FOV + (input.Position.Z * 5), 10, 200)
        FOVSlider.Text = "FOV: " .. tostring(FOV)
        Circle.Radius = FOV
    end
end)

-- Change Target Part (Example: Head, HumanoidRootPart, etc.)
TargetPartLabel.MouseButton1Click:Connect(function()
    if TargetPart == "Head" then
        TargetPart = "HumanoidRootPart"
    else
        TargetPart = "Head"
    end
    TargetPartLabel.Text = "Target: " .. TargetPart
end)

-- Silent Aim Logic
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if SilentAimEnabled and not checkcaller() then
        if self == UserInputService and key == "GetMouseLocation" then
            local ClosestTarget = nil
            local ClosestDistance = FOV

            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character then
                    local Target = Player.Character:FindFirstChild(TargetPart)
                    if Target then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
                        if OnScreen then
                            local MousePos = UserInputService:GetMouseLocation()
                            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                            if Distance < ClosestDistance then
                                ClosestDistance = Distance
                                ClosestTarget = Target
                            end
                        end
                    end
                end
            end

            if ClosestTarget then
                local ScreenPos = Camera:WorldToViewportPoint(ClosestTarget.Position)
                return Vector2.new(ScreenPos.X, ScreenPos.Y)
            end
        end
    end

    return OldIndex(self, key)
end)

-- Update FOV Circle Position
RunService.RenderStepped:Connect(function()
    Circle.Position = UserInputService:GetMouseLocation()
end)
