local Players = game:GetService("Players") local RunService = game:GetService("RunService") local StarterGui = game:GetService("StarterGui") local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer local GetPlayerFromCharacter = Players.GetPlayerFromCharacter

local DETECTION_RANGE = 10 local DETECTION_RANGE_SQ = DETECTION_RANGE * DETECTION_RANGE local ANCHOR_PITCH_RAD = math.rad(55) local ANCHOR_OFFSET_CFRAME = CFrame.new(0, 0, 0) * CFrame.Angles(ANCHOR_PITCH_RAD, 0, 0) local KEY_W = Enum.KeyCode.W local KEY_Q = Enum.KeyCode.Q

local DashAnimations = { ["10503381238"] = true, ["13379003796"] = true, }

local Character local Humanoid local RootPart local AnimConnection local FollowConnection local CurrentActionId = 0 local SavedAutoRotate = nil local LiveFolder = nil local LiveFolderAddedConnection = nil local LiveFolderRemovedConnection = nil local TrackedModels = {} local TrackedModelList = {} local FollowRig = nil

local function showNotification() task.spawn(function() for _ = 1, 5 do if game:IsLoaded() then StarterGui:SetCore("SendNotification", { Title = "The Strongest Battleground", Text = "Script executed", Duration = 5, }) return end task.wait(0.2) end end) end

showNotification()

local function clearTrackedModels() for i = #TrackedModelList, 1, -1 do local model = TrackedModelList[i] TrackedModelList[i] = nil

local info = TrackedModels[model]
	TrackedModels[model] = nil

	if info and info.connections then
		for j = 1, #info.connections do
			local conn = info.connections[j]
			if conn then
				conn:Disconnect()
			end
		end
	end
end

end

local function stopFollowConnection() local conn = FollowConnection FollowConnection = nil if conn then conn:Disconnect() end end

local function destroyFollowRig() if FollowRig then if FollowRig.AlignPos then FollowRig.AlignPos:Destroy() end if FollowRig.AlignOri then FollowRig.AlignOri:Destroy() end if FollowRig.Att0 then FollowRig.Att0:Destroy() end if FollowRig.Att1 then FollowRig.Att1:Destroy() end if FollowRig.AnchorPart then FollowRig.AnchorPart:Destroy() end FollowRig = nil end end

local function cleanupFollow() stopFollowConnection() destroyFollowRig()

if Humanoid and Humanoid.Parent and SavedAutoRotate ~= nil then
	Humanoid.AutoRotate = SavedAutoRotate
end

SavedAutoRotate = nil

end

local function untrackModel(model) local info = TrackedModels[model] if not info then return end

TrackedModels[model] = nil

if info.connections then
	for i = 1, #info.connections do
		local conn = info.connections[i]
		if conn then
			conn:Disconnect()
		end
	end
end

for i = #TrackedModelList, 1, -1 do
	if TrackedModelList[i] == model then
		table.remove(TrackedModelList, i)
		break
	end
end

end

local function trackModel(model) if not (model and model:IsA("Model")) then return end

if TrackedModels[model] then
	return
end

local info = {
	root = model:FindFirstChild("HumanoidRootPart"),
	humanoid = model:FindFirstChildOfClass("Humanoid"),
	forceFieldPresent = model:FindFirstChildOfClass("ForceField") ~= nil,
	connections = {},
}

TrackedModels[model] = info
TrackedModelList[#TrackedModelList + 1] = model

info.connections[1] = model.ChildAdded:Connect(function(child)
	if child.Name == "HumanoidRootPart" then
		info.root = child
	elseif child:IsA("Humanoid") then
		info.humanoid = child
	elseif child:IsA("ForceField") then
		info.forceFieldPresent = true
	end
end)

info.connections[2] = model.ChildRemoved:Connect(function(child)
	if child == info.root then
		info.root = nil
	elseif child == info.humanoid then
		info.humanoid = nil
	elseif child:IsA("ForceField") then
		info.forceFieldPresent = model:FindFirstChildOfClass("ForceField") ~= nil
	end
end)

end

local function bindLiveFolder(folder) if LiveFolderAddedConnection then LiveFolderAddedConnection:Disconnect() LiveFolderAddedConnection = nil end

if LiveFolderRemovedConnection then
	LiveFolderRemovedConnection:Disconnect()
	LiveFolderRemovedConnection = nil
end

clearTrackedModels()

if not folder then
	return
end

for _, child in ipairs(folder:GetChildren()) do
	trackModel(child)
end

LiveFolderAddedConnection = folder.ChildAdded:Connect(function(child)
	trackModel(child)
end)

LiveFolderRemovedConnection = folder.ChildRemoved:Connect(function(child)
	untrackModel(child)
end)

end

local function getLiveFolder() local folder = LiveFolder if folder and folder.Parent then return folder end

folder = Workspace:FindFirstChild("Live")
if folder ~= LiveFolder then
	LiveFolder = folder
	bindLiveFolder(folder)
end

return folder

end

local function getNearestTarget() local rootPart = RootPart if not (rootPart and rootPart.Parent) then return nil end

local liveFolder = getLiveFolder()
if not liveFolder then
	return nil
end

local currentPos = rootPart.Position
local nearestPart = nil
local shortestDistSq = DETECTION_RANGE_SQ
local models = TrackedModelList

for i = 1, #models do
	local model = models[i]
	if model and model.Parent == liveFolder and model ~= Character then
		local info = TrackedModels[model]
		if info then
			local targetRoot = info.root
			local enemyHum = info.humanoid
			if targetRoot and targetRoot.Parent and enemyHum and enemyHum.Parent and enemyHum.Health > 0 and not info.forceFieldPresent then
				local offset = targetRoot.Position - currentPos
				local distSq = offset.X * offset.X + offset.Y * offset.Y + offset.Z * offset.Z

				if distSq <= shortestDistSq and (model.Name == "Weakest Dummy" or GetPlayerFromCharacter(Players, model)) then
					shortestDistSq = distSq
					nearestPart = targetRoot
				end
			end
		end
	end
end

return nearestPart

end

local function ensureFollowRig(rootPart) if FollowRig then local existingRoot = FollowRig.RootPart if existingRoot == rootPart and existingRoot and existingRoot.Parent then return FollowRig end destroyFollowRig() end

local anchorPart = Instance.new("Part")
anchorPart.Transparency = 1
anchorPart.Anchored = true
anchorPart.CanCollide = false
anchorPart.Parent = Workspace

local att0 = Instance.new("Attachment")
att0.Parent = rootPart

local att1 = Instance.new("Attachment")
att1.Parent = anchorPart

local alignPos = Instance.new("AlignPosition")
alignPos.Attachment0 = att0
alignPos.Attachment1 = att1
alignPos.RigidityEnabled = true
alignPos.MaxForce = math.huge
alignPos.Parent = rootPart

local alignOri = Instance.new("AlignOrientation")
alignOri.Attachment0 = att0
alignOri.Attachment1 = att1
alignOri.RigidityEnabled = true
alignOri.MaxTorque = math.huge
alignOri.Parent = rootPart

FollowRig = {
	RootPart = rootPart,
	AnchorPart = anchorPart,
	Att0 = att0,
	Att1 = att1,
	AlignPos = alignPos,
	AlignOri = alignOri,
}

return FollowRig

end

local function startFollowTarget(targetPart) cleanupFollow()

local rootPart = RootPart
local humanoid = Humanoid
if not (targetPart and targetPart.Parent and rootPart and rootPart.Parent and humanoid and humanoid.Parent) then
	return
end

SavedAutoRotate = humanoid.AutoRotate
humanoid.AutoRotate = false

local rig = ensureFollowRig(rootPart)
if not rig then
	return
end

FollowConnection = RunService.RenderStepped:Connect(function()
	local currentTarget = targetPart
	local currentRoot = RootPart
	if currentTarget and currentTarget.Parent and currentRoot and currentRoot.Parent then
		local currentRig = FollowRig
		if currentRig and currentRig.AnchorPart then
			currentRig.AnchorPart.CFrame = currentTarget.CFrame * ANCHOR_OFFSET_CFRAME
		end
	else
		cleanupFollow()
	end
end)

end

local function onAnimationPlayed(animTrack) if not (animTrack and animTrack.Animation) then return end

local animationId = animTrack.Animation.AnimationId
if not animationId then
	return
end

local animId = string.match(animationId, "%d+")
if not animId or not DashAnimations[animId] then
	return
end

CurrentActionId += 1
local actionTicket = CurrentActionId
local character = Character

task.delay(0.32, function()
	if CurrentActionId ~= actionTicket then
		return
	end

	if character then
		local communicate = character:FindFirstChild("Communicate")
		if communicate and communicate:IsA("RemoteEvent") then
			communicate:FireServer({
				Dash = KEY_W,
				Key = KEY_Q,
				Goal = "KeyPress",
			})
		end
	end

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

local function onCharacter(char) CurrentActionId += 1 local myId = CurrentActionId

cleanupFollow()
destroyFollowRig()

if AnimConnection then
	AnimConnection:Disconnect()
	AnimConnection = nil
end

Character = char

local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

if CurrentActionId ~= myId then
	return
end

Humanoid = hum
RootPart = root

AnimConnection = hum.AnimationPlayed:Connect(onAnimationPlayed)

end

local function onCharacterRemoving() CurrentActionId += 1 cleanupFollow() destroyFollowRig()

if AnimConnection then
	AnimConnection:Disconnect()
	AnimConnection = nil
end

Character = nil
Humanoid = nil
RootPart = nil

end

LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving) LocalPlayer.CharacterAdded:Connect(onCharacter)

if LocalPlayer.Character then onCharacter(LocalPlayer.Character) end
