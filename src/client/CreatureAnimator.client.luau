local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local tracked = {} -- [model] = { base = CFrame, mode = tag, phase = number }

local function track(model, tag)
	if not model:IsA("Model") then
		return
	end
	task.defer(function()
		if model.Parent then
			tracked[model] = { base = model:GetPivot(), mode = tag, phase = math.random() * math.pi * 2 }
		end
	end)
end

for _, tag in ipairs({ "FloatingCreature", "DisplayCreature" }) do
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(model)
		track(model, tag)
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(model)
		tracked[model] = nil
	end)
	for _, model in ipairs(CollectionService:GetTagged(tag)) do
		track(model, tag)
	end
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for model, info in pairs(tracked) do
		if model.Parent then
			if info.mode == "FloatingCreature" then
				model:PivotTo(
					info.base
						* CFrame.new(0, math.sin(t * 2 + info.phase) * 0.5, 0)
						* CFrame.Angles(0, t + info.phase, 0)
				)
			else
				model:PivotTo(
					info.base
						* CFrame.new(0, math.sin(t * 1.5 + info.phase) * 0.15, 0)
						* CFrame.Angles(0, math.sin(t + info.phase) * 0.4, 0)
				)
			end
		else
			tracked[model] = nil
		end
	end
end)
