local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local DETECTION_RANGE = 10

local DashAnimations = {
	["10503381238"] = true,
	["13379003796"] = true,
}

local Character, Humanoid, RootPart
local AnimConnection, FollowConnection
local FollowCache = {}
local CurrentActionId = 0

local function cleanupFollow()
	local conn = FollowConnection
	FollowConnection = nil
	if conn then conn:Disconnect() end

	local snapshot = FollowCache
	FollowCache = {}

	for _, obj in ipairs(snapshot) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end

	if Humanoid and Humanoid.Parent then
		Humanoid.AutoRotate = true
	end
end

local function getNearestTarget()
	if not (RootPart and RootPart.Parent) then return nil end

	local nearestPart = nil
	local shortestDist = DETECTION_RANGE
	local liveFolder = workspace:FindFirstChild("Live")

	if liveFolder then
		local currentPos = RootPart.Position

		for _, model in ipairs(liveFolder:GetChildren()) do
			if model:IsA("Model") and model ~= Character then
				local targetRoot = model:FindFirstChild("HumanoidRootPart")
				local enemyHum = model:FindFirstChildOfClass("Humanoid")

				if targetRoot and enemyHum and enemyHum.Health > 0
					and not model:FindFirstChildOfClass("ForceField") then

					local dist = (targetRoot.Position - currentPos).Magnitude

					if dist <= shortestDist then
						if model.Name == "Weakest Dummy" or Players:GetPlayerFromCharacter(model) then
							shortestDist = dist
							nearestPart = targetRoot
						end
					end
				end
			end
		end
	end

	return nearestPart
end

local function startFollowTarget(targetPart)
	cleanupFollow()

	if not (targetPart and targetPart.Parent
		and RootPart and RootPart.Parent
		and Humanoid and Humanoid.Parent) then
		return
	end

	Humanoid.AutoRotate = false

	local anchorPart = Instance.new("Part")
	anchorPart.Transparency = 1
	anchorPart.Anchored = true
	anchorPart.CanCollide = false
	anchorPart.Parent = workspace

	local att0 = Instance.new("Attachment", RootPart)
	local att1 = Instance.new("Attachment", anchorPart)

	local alignPos = Instance.new("AlignPosition", RootPart)
	alignPos.Attachment0 = att0
	alignPos.Attachment1 = att1
	alignPos.RigidityEnabled = true
	alignPos.MaxForce = math.huge

	local alignOri = Instance.new("AlignOrientation", RootPart)
	alignOri.Attachment0 = att0
	alignOri.Attachment1 = att1
	alignOri.RigidityEnabled = true
	alignOri.MaxTorque = math.huge

	table.insert(FollowCache, alignPos)
	table.insert(FollowCache, alignOri)
	table.insert(FollowCache, att0)
	table.insert(FollowCache, att1)
	table.insert(FollowCache, anchorPart)

	FollowConnection = RunService.RenderStepped:Connect(function()
		if targetPart and targetPart.Parent and RootPart and RootPart.Parent then
			anchorPart.CFrame = targetPart.CFrame * CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(55), 0, 0)
		else
			cleanupFollow()
		end
	end)
end

local function onAnimationPlayed(animTrack)
	if not (animTrack and animTrack.Animation) then return end

	local animId = tostring(string.match(animTrack.Animation.AnimationId or "", "%d+"))

	if DashAnimations[animId] then
		CurrentActionId += 1
		local actionTicket = CurrentActionId

		task.delay(0.32, function()
			if CurrentActionId ~= actionTicket then return end

			pcall(function()
				local communicate = Character:FindFirstChild("Communicate")
				if communicate then
					communicate:FireServer({
						Dash = Enum.KeyCode.W,
						Key = Enum.KeyCode.Q,
						Goal = "KeyPress"
					})
				end
			end)

			local target = getNearestTarget()
			if target then
				startFollowTarget(target)

				task.delay(0.6, function()
					if CurrentActionId == actionTicket then
						cleanupFollow()
					end
				end)
			end
		end)
	end
end

local function onCharacter(char)
	CurrentActionId += 1
	local myId = CurrentActionId

	cleanupFollow()

	if AnimConnection then
		AnimConnection:Disconnect()
		AnimConnection = nil
	end

	Character = char

	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

	if CurrentActionId ~= myId then return end

	Humanoid = hum
	RootPart = root

	AnimConnection = Humanoid.AnimationPlayed:Connect(onAnimationPlayed)
end

local function onCharacterRemoving()
	CurrentActionId += 1
	cleanupFollow()
end

LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)
LocalPlayer.CharacterAdded:Connect(onCharacter)

if LocalPlayer.Character then
	onCharacter(LocalPlayer.Character)
end