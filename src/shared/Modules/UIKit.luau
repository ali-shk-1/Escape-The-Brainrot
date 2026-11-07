local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local UIKit = {}

UIKit.Theme = {
	Bg = Color3.fromRGB(22, 18, 45),
	Panel = Color3.fromRGB(36, 30, 72),
	Row = Color3.fromRGB(50, 42, 98),
	Pink = Color3.fromRGB(255, 77, 166),
	Cyan = Color3.fromRGB(56, 224, 255),
	Gold = Color3.fromRGB(255, 200, 60),
	Green = Color3.fromRGB(74, 222, 128),
	Red = Color3.fromRGB(255, 59, 92),
	Text = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(160, 150, 200),
	Dark = Color3.fromRGB(22, 18, 45),
}
UIKit.TitleFont = Enum.Font.FredokaOne
UIKit.BodyFont = Enum.Font.GothamBold

function UIKit.make(className, props, parent)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

function UIKit.round(inst, radius)
	return UIKit.make("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, inst)
end

function UIKit.stroke(inst, color, thickness)
	return UIKit.make("UIStroke", {
		Color = color,
		Thickness = thickness or 2,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

-- number formatting: 1,234 / 12.5K / 3.2M
function UIKit.fmt(n)
	n = math.floor(n)
	if n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e4 then
		return string.format("%.1fK", n / 1e3)
	end
	local s = tostring(n)
	return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

-- seconds -> "2d 5h" / "05:12:09"
function UIKit.formatTime(seconds)
	seconds = math.max(0, math.floor(seconds))
	if seconds >= 86400 then
		return string.format("%dd %dh", seconds // 86400, (seconds % 86400) // 3600)
	end
	return string.format("%02d:%02d:%02d", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
end

-- hover/press "pop" on a button
function UIKit.pop(button)
	local scale = UIKit.make("UIScale", { Scale = 1 }, button)
	local function tweenTo(value)
		TweenService:Create(scale, TweenInfo.new(0.12, Enum.EasingStyle.Quad), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function()
		tweenTo(1.06)
	end)
	button.MouseLeave:Connect(function()
		tweenTo(1)
	end)
	button.MouseButton1Down:Connect(function()
		tweenTo(0.94)
	end)
	button.MouseButton1Up:Connect(function()
		tweenTo(1.06)
	end)
end

function UIKit.screen(name, order)
	local playerGui = player:WaitForChild("PlayerGui")
	local existing = playerGui:FindFirstChild(name)
	if existing then
		return existing
	end
	return UIKit.make("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		DisplayOrder = order or 6,
		IgnoreGuiInset = false,
	}, playerGui)
end

-- round buttons stacked on the right side of the screen. slot = 0, 1, 2...
function UIKit.sideButton(icon, slot, color)
	local gui = UIKit.screen("SideButtons", 6)
	local button = UIKit.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, -90 + slot * 58),
		Size = UDim2.fromOffset(50, 50),
		BackgroundColor3 = UIKit.Theme.Panel,
		Text = icon,
		TextSize = 26,
		Font = UIKit.BodyFont,
		TextColor3 = UIKit.Theme.Text,
		AutoButtonColor = false,
	}, gui)
	UIKit.round(button, 25)
	UIKit.stroke(button, color or UIKit.Theme.Pink, 3)
	UIKit.pop(button)

	local badge = UIKit.make("Frame", {
		Name = "Badge",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 2, 0, -2),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = UIKit.Theme.Red,
		Visible = false,
	}, button)
	UIKit.round(badge, 8)
	UIKit.stroke(badge, Color3.new(1, 1, 1), 2)
	return button
end

function UIKit.setBadge(button, visible)
	local badge = button:FindFirstChild("Badge")
	if badge then
		badge.Visible = visible
	end
end

-- centered pop-up panel. Returns { Frame, Body, Open, Close, Toggle, IsOpen }
local openPanels = {}

function UIKit.panel(name, title, height, accent)
	local gui = UIKit.screen("Panels", 8)
	local frame = UIKit.make("Frame", {
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.9, 0, 0, height),
		BackgroundColor3 = UIKit.Theme.Bg,
		Visible = false,
	}, gui)
	UIKit.make("UISizeConstraint", { MaxSize = Vector2.new(380, height), MinSize = Vector2.new(260, 100) }, frame)
	UIKit.round(frame, 18)
	UIKit.stroke(frame, accent or UIKit.Theme.Pink, 3)
	local scale = UIKit.make("UIScale", { Scale = 1 }, frame)

	UIKit.make("TextLabel", {
		Size = UDim2.new(1, -60, 0, 44),
		Position = UDim2.fromOffset(14, 6),
		BackgroundTransparency = 1,
		Text = title,
		Font = UIKit.TitleFont,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = accent or UIKit.Theme.Pink,
	}, frame)

	local close = UIKit.make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.fromOffset(38, 38),
		BackgroundColor3 = UIKit.Theme.Red,
		Text = "X",
		Font = UIKit.TitleFont,
		TextSize = 22,
		TextColor3 = UIKit.Theme.Text,
		AutoButtonColor = false,
	}, frame)
	UIKit.round(close, 19)
	UIKit.pop(close)

	local body = UIKit.make("Frame", {
		Position = UDim2.fromOffset(12, 54),
		Size = UDim2.new(1, -24, 1, -66),
		BackgroundTransparency = 1,
	}, frame)

	local panel = { Frame = frame, Body = body }

	function panel.Close()
		if not frame.Visible then
			return
		end
		frame.Visible = false
		openPanels[panel] = nil
	end

	function panel.Open()
		for other in pairs(openPanels) do
			other.Close()
		end
		frame.Visible = true
		openPanels[panel] = true
		scale.Scale = 0.85
		TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	end

	function panel.Toggle()
		if frame.Visible then
			panel.Close()
		else
			panel.Open()
		end
	end

	function panel.IsOpen()
		return frame.Visible
	end

	close.Activated:Connect(panel.Close)
	return panel
end

return UIKit
