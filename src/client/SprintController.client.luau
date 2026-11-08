local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local MAX_STAMINA = 100
local STAMINA_DRAIN = 28 -- points per second while sprinting
local STAMINA_RECOVERY = 22 -- points per second while resting
local SPRINT_SPEED_BOOST = 12 -- flat speed addition while sprinting

local stamina = MAX_STAMINA
local isSprinting = false
local exhausted = false

---------------------------------------------------------------------
-- Stamina Bar UI
---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "StaminaGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 4
gui.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "StaminaContainer"
container.AnchorPoint = Vector2.new(0.5, 1)
container.Position = UDim2.new(0.5, 0, 1, -22)
container.Size = UDim2.fromOffset(210, 16)
container.BackgroundColor3 = Color3.fromRGB(26, 20, 48)
container.BackgroundTransparency = 0.2
container.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(56, 224, 255)
stroke.Thickness = 2
stroke.Parent = container

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(1, 1)
fill.BackgroundColor3 = Color3.fromRGB(56, 224, 255)
fill.Parent = container

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "⚡ STAMINA"
label.Font = Enum.Font.FredokaOne
label.TextSize = 11
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextStrokeTransparency = 0
label.TextStrokeColor3 = Color3.fromRGB(15, 10, 25)
label.Parent = container

---------------------------------------------------------------------
-- Mobile Sprint Button (Visible on Touch devices)
---------------------------------------------------------------------
local mobileButton
if UserInputService.TouchEnabled then
	mobileButton = Instance.new("TextButton")
	mobileButton.Name = "MobileSprint"
	mobileButton.AnchorPoint = Vector2.new(1, 1)
	mobileButton.Position = UDim2.new(1, -20, 1, -85)
	mobileButton.Size = UDim2.fromOffset(68, 68)
	mobileButton.BackgroundColor3 = Color3.fromRGB(36, 30, 72)
	mobileButton.Text = "⚡\nSPRINT"
	mobileButton.Font = Enum.Font.FredokaOne
	mobileButton.TextSize = 14
	mobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	mobileButton.AutoButtonColor = false
	mobileButton.Parent = gui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = mobileButton

	local btnStroke = Instance.new("UIStroke")
	btnStroke.Color = Color3.fromRGB(56, 224, 255)
	btnStroke.Thickness = 3
	btnStroke.Parent = mobileButton

	mobileButton.MouseButton1Down:Connect(function()
		isSprinting = true
	end)
	mobileButton.MouseButton1Up:Connect(function()
		isSprinting = false
	end)
end

---------------------------------------------------------------------
-- PC Keybinds (Left Shift)
---------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
	end
end)

---------------------------------------------------------------------
-- Stamina & Speed Loop
---------------------------------------------------------------------
local baseWalkSpeed = Config.Player.WalkSpeed

local function getBaseSpeed()
	local speedLevel = player:GetAttribute("SpeedLevel") or 0
	local speed = Config.Player.WalkSpeed + speedLevel * 2
	if player:GetAttribute("SuperSpeed") then
		speed += 8
	end
	return speed
end

RunService.RenderStepped:Connect(function(dt)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end

	local moveDir = hum.MoveDirection.Magnitude
	local isMoving = moveDir > 0.1

	if isSprinting and isMoving and not exhausted then
		stamina = math.max(0, stamina - STAMINA_DRAIN * dt)
		if stamina <= 0 then
			exhausted = true
			fill.BackgroundColor3 = Color3.fromRGB(255, 59, 92)
		end
	else
		stamina = math.min(MAX_STAMINA, stamina + STAMINA_RECOVERY * dt)
		if stamina > 25 then
			exhausted = false
			fill.BackgroundColor3 = Color3.fromRGB(56, 224, 255)
		end
	end

	-- Apply walk speed
	local baseSpeed = getBaseSpeed()
	if isSprinting and isMoving and not exhausted then
		hum.WalkSpeed = baseSpeed + SPRINT_SPEED_BOOST
	else
		hum.WalkSpeed = baseSpeed
	end

	-- Update UI bar
	local ratio = stamina / MAX_STAMINA
	fill.Size = UDim2.fromScale(ratio, 1)

	-- Fade UI when full and not sprinting
	if stamina >= MAX_STAMINA and not isSprinting then
		container.BackgroundTransparency = math.min(0.7, container.BackgroundTransparency + dt * 2)
		fill.BackgroundTransparency = container.BackgroundTransparency
		label.TextTransparency = container.BackgroundTransparency
		stroke.Transparency = container.BackgroundTransparency
	else
		container.BackgroundTransparency = 0.2
		fill.BackgroundTransparency = 0.1
		label.TextTransparency = 0
		stroke.Transparency = 0
	end
end)
