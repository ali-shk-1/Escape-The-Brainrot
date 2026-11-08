local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "DangerVignetteGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1
gui.Parent = playerGui

local vignette = Instance.new("ImageLabel")
vignette.Name = "Vignette"
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundTransparency = 1
vignette.Image = "rbxassetid://4576475446" -- Standard Roblox soft vignette texture
vignette.ImageColor3 = Color3.fromRGB(255, 30, 60)
vignette.ImageTransparency = 1
vignette.Parent = gui

local DANGER_DIST = 55

RunService.RenderStepped:Connect(function()
	local guard = workspace:FindFirstChild("Guard")
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local guardHrp = guard and guard:FindFirstChild("HumanoidRootPart")

	if not hrp or not guardHrp or guard:GetAttribute("Chasing") ~= true then
		vignette.ImageTransparency = math.min(1, vignette.ImageTransparency + 0.05)
		return
	end

	local dist = (guardHrp.Position - hrp.Position).Magnitude
	if dist < DANGER_DIST then
		local intensity = 1 - (dist / DANGER_DIST)
		local pulse = (math.sin(os.clock() * 6) + 1) * 0.15
		vignette.ImageTransparency = math.clamp(0.9 - (intensity * 0.6 + pulse), 0.2, 1)
	else
		vignette.ImageTransparency = math.min(1, vignette.ImageTransparency + 0.05)
	end
end)
