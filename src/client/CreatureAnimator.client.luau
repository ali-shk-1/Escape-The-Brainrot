local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local tracked = {} -- [model] = { base = CFrame, mode = tag, phase = number, pos = Vector3 }

local MAX_ANIM_DIST = 135 -- studs beyond which creatures skip animation to save CPU/GPU
local MAX_ANIM_DIST_SQ = MAX_ANIM_DIST * MAX_ANIM_DIST

local function track(model, tag)
	if not model:IsA("Model") then
		return
	end
	task.defer(function()
		if model.Parent then
			local pivot = model:GetPivot()
			tracked[model] = {
				base = pivot,
				mode = tag,
				phase = math.random() * math.pi * 2,
				pos = pivot.Position,
			}
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

-- Ultra-smooth animation loop with distance culling
RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local camPos = camera.CFrame.Position

	for model, info in pairs(tracked) do
		if model.Parent then
			local dx = info.pos.X - camPos.X
			local dz = info.pos.Z - camPos.Z
			local distSq = dx * dx + dz * dz

			-- Only animate if player is within visible range
			if distSq <= MAX_ANIM_DIST_SQ then
				if info.mode == "FloatingCreature" then
					model:PivotTo(
						info.base
							* CFrame.new(0, math.sin(t * 2.2 + info.phase) * 0.45, 0)
							* CFrame.Angles(0, t * 1.1 + info.phase, 0)
					)
				else
					-- Display creature sway in stall
					model:PivotTo(
						info.base
							* CFrame.new(0, math.sin(t * 1.6 + info.phase) * 0.12, 0)
							* CFrame.Angles(0, math.sin(t * 1.1 + info.phase) * 0.35, 0)
					)
				end
			end
		else
			tracked[model] = nil
		end
	end
end)
