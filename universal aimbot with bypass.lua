--== SERVICES ==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--== SETTINGS ==--
local AimEnabled = false
local AimbotMode = "Smooth"
local Smoothness = 0.08
local MaxFOV = 200
local ESPEnabled = true
local LockPart = "Head" -- Default lock target (Head)

--== DEVICE CHECK ==--
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--== FOV CIRCLE ==--
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.fromRGB(0, 255, 0)
FOVCircle.Filled = false
FOVCircle.Visible = true

--== BASIC GUI ==--
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "SimpleAimbotGui"
screenGui.ResetOnSpawn = false

local function createButton(text, pos, size, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, size.X, 0, size.Y)
	btn.Position = UDim2.new(0, pos.X, 1, -pos.Y - size.Y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.Parent = screenGui
	btn.MouseButton1Click:Connect(callback)
	return btn
end

--== GUI BUTTONS ==--
createButton("Toggle Aimbot", Vector2.new(10, 10), Vector2.new(140, 30), function()
	AimEnabled = not AimEnabled
end)

createButton("Mode: Instant/Smooth", Vector2.new(10, 50), Vector2.new(160, 30), function()
	AimbotMode = AimbotMode == "Smooth" and "Instant" or "Smooth"
end)

createButton("Toggle ESP", Vector2.new(10, 90), Vector2.new(140, 30), function()
	ESPEnabled = not ESPEnabled
end)

createButton("FOV +", Vector2.new(10, 130), Vector2.new(60, 30), function()
	MaxFOV = MaxFOV + 10
end)

createButton("FOV -", Vector2.new(80, 130), Vector2.new(60, 30), function()
	MaxFOV = math.max(10, MaxFOV - 10)
end)

--== UTILS ==--
local function getAimCenter()
	local view = Camera.ViewportSize
	return Vector2.new(view.X / 2, view.Y / 2)
end

local function getBody(char)
	return char:FindFirstChild("Neck") or char:FindFirstChild("Head")
end

local function getClosestTarget()
	local closest, shortest = nil, MaxFOV
	local center = getAimCenter()

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local part = getBody(player.Character)
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if part and hum and hum.Health > 0 then
				local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if dist < shortest then
						shortest = dist
						closest = part
					end
				end
			end
		end
	end
	return closest
end

local function aimAtTarget()
	local target = getClosestTarget()
	if target then
		local camPos = Camera.CFrame.Position
		local aimCF = CFrame.new(camPos, target.Position)
		if AimbotMode == "Instant" then
			Camera.CFrame = aimCF
		else
			Camera.CFrame = Camera.CFrame:Lerp(aimCF, Smoothness)
		end
	end
end

--== INPUT TOGGLE ==--
if not isMobile then
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.UserInputType == Enum.UserInputType.MouseButton2 then
			AimEnabled = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			AimEnabled = false
		end
	end)
end

--== AIMLOCK SCOOP DETECTION (MOBILE) ==--
local lastFOV = Camera.FieldOfView
RunService.RenderStepped:Connect(function()
	if isMobile then
		local currentFOV = Camera.FieldOfView
		if currentFOV < lastFOV then
			AimEnabled = true
		elseif currentFOV > lastFOV then
			AimEnabled = false
		end
		lastFOV = currentFOV
	end
end)

--== AIM LOOP ==--
RunService.RenderStepped:Connect(function()
	FOVCircle.Position = getAimCenter()
	FOVCircle.Radius = MaxFOV
	FOVCircle.Visible = AimEnabled

	if AimEnabled then
		aimAtTarget()
	end
end)

--== SIMPLE ESP ==--
local ESPs = {}

local function removeESP(player)
	if ESPs[player] then
		ESPs[player].Box:Remove()
		ESPs[player].Name:Remove()
		ESPs[player] = nil
	end
end

local function createESP(player)
	if player == LocalPlayer then return end
	removeESP(player)

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Color = Color3.fromRGB(0, 0, 255)
	box.Transparency = 1

	local nameTag = Drawing.new("Text")
	nameTag.Size = 14
	nameTag.Center = true
	nameTag.Outline = true
	nameTag.Color = Color3.fromRGB(0, 0, 255)
	nameTag.Text = player.Name

	ESPs[player] = {Box = box, Name = nameTag}
end

for _, p in ipairs(Players:GetPlayers()) do
	createESP(p)
end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
	for player, esp in pairs(ESPs) do
		local char = player.Character
		if ESPEnabled and char and char:FindFirstChild("HumanoidRootPart") then
			local hrp = char.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local size = math.clamp(1000 / (hrp.Position - Camera.CFrame.Position).Magnitude, 50, 200)
				esp.Box.Size = Vector2.new(size, size * 1.5)
				esp.Box.Position = Vector2.new(pos.X - size / 2, pos.Y - size * 1.5 / 2)
				esp.Box.Visible = true

				esp.Name.Position = Vector2.new(pos.X, pos.Y - size)
				esp.Name.Text = player.Name
				esp.Name.Visible = true
			else
				esp.Box.Visible = false
				esp.Name.Visible = false
			end
		else
			if esp.Box then esp.Box.Visible = false end
			if esp.Name then esp.Name.Visible = false end
		end
	end
end)
