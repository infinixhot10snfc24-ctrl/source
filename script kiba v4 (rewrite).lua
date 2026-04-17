if getgenv().kiba_tech_loaded then return end
getgenv().kiba_tech_loaded = true

getgenv().binding_lethal_kiba = getgenv().binding_lethal_kiba or "off"

local Players = game:GetService("Players") local RunService = game:GetService("RunService") local StarterGui = game:GetService("StarterGui") local Workspace = game:GetService("Workspace") local UserInputService = game:GetService("UserInputService") local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait() local GetPlayerFromCharacter = Players.GetPlayerFromCharacter

local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "KibaTechToggleGui" ScreenGui.Parent = game.CoreGui

local ToggleFrame = Instance.new("Frame") ToggleFrame.Size = UDim2.new(0,135,0,40) ToggleFrame.Position = UDim2.new(0,20,0,200) ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) ToggleFrame.BackgroundTransparency = 0.2 ToggleFrame.BorderSizePixel = 0 ToggleFrame.Active = true ToggleFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner") UICorner.CornerRadius = UDim.new(0,10) UICorner.Parent = ToggleFrame

local UIStroke = Instance.new("UIStroke") UIStroke.Color = Color3.fromRGB(80, 80, 90) UIStroke.Thickness = 1.5 UIStroke.Transparency = 0.3 UIStroke.Parent = ToggleFrame

local Indicator = Instance.new("TextLabel") Indicator.Size = UDim2.new(0,24,0,24) Indicator.Position = UDim2.new(0,10,0.5,-14) Indicator.Text = "•" Indicator.TextScaled = false Indicator.TextSize = 45 Indicator.BackgroundTransparency = 1 Indicator.TextColor3 = Color3.fromRGB(255,90,90) Indicator.Font = Enum.Font.GothamBlack Indicator.Parent = ToggleFrame

local Label = Instance.new("TextLabel") Label.Size = UDim2.new(1,-44,1,0) Label.Position = UDim2.new(0,38,0,0) Label.Text = "kiba tech" Label.TextScaled = false Label.TextSize = 14 Label.BackgroundTransparency = 1 Label.TextColor3 = Color3.fromRGB(230, 230, 235) Label.Font = Enum.Font.GothamBold Label.TextXAlignment = Enum.TextXAlignment.Left Label.Parent = ToggleFrame

local Enabled = false local colorTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out) local ActiveColorTween = nil

local DETECTION_RANGE = 15 local DETECTION_RANGE_SQ = DETECTION_RANGE * DETECTION_RANGE local ANCHOR_PITCH_RAD = math.rad(55) local ANCHOR_OFFSET_CFRAME = CFrame.new(0, 0, 0) * CFrame.Angles(ANCHOR_PITCH_RAD, 0, 0) local KEY_W = Enum.KeyCode.W local KEY_Q = Enum.KeyCode.Q

local DashAnimations = { ["10503381238"] = true, ["13379003796"] = true, ["12296113986"] = true, ["95034083206292"] = true, }

local SpecialDurations = { ["12296113986"] = 1.7, ["95034083206292"] = 2.55 }

local function isBindingLethalKibaEnabled() return tostring(getgenv().binding_lethal_kiba):lower() == "on" end

local Character local Humanoid local RootPart local AnimConnection local FollowConnection local CurrentActionId = 0 local FollowActionId = 0 local SavedAutoRotate = nil local LiveFolder = nil local LiveFolderAddedConnection = nil local LiveFolderRemovedConnection = nil local TrackedModels = {} local TrackedModelList = {} local FollowRig = nil

local function stopFollowConnection() local conn = FollowConnection FollowConnection = nil if conn then conn:Disconnect() end end

local function destroyFollowRig() if FollowRig then if FollowRig.AlignPos then FollowRig.AlignPos:Destroy() end if FollowRig.AlignOri then FollowRig.AlignOri:Destroy() end if FollowRig.Att0 then FollowRig.Att0:Destroy() end if FollowRig.Att1 then FollowRig.Att1:Destroy() end if FollowRig.AnchorPart then FollowRig.AnchorPart:Destroy() end FollowRig = nil end end

local function cleanupFollow() stopFollowConnection() destroyFollowRig()

if Humanoid and Humanoid.Parent and SavedAutoRotate ~= nil then 
	Humanoid.AutoRotate = SavedAutoRotate 
end

SavedAutoRotate = nil

end

local function updateUI() local targetColor = Enabled and Color3.fromRGB(120,255,160) or Color3.fromRGB(255,90,90) if ActiveColorTween then ActiveColorTween:Cancel() end local colorTween = TweenService:Create(Indicator, colorTweenInfo, {TextColor3 = targetColor}) ActiveColorTween = colorTween colorTween:Play() end

local dragging = false local dragInput local dragStart local startPos local dragThreshold = 5 local hasMoved = false

ToggleFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true hasMoved = false dragStart = input.Position startPos = ToggleFrame.Position

local connection
	connection = input.Changed:Connect(function() 
		if input.UserInputState == Enum.UserInputState.End then 
			dragging = false 
			if not hasMoved then 
				Enabled = not Enabled 
				updateUI() 
				if not Enabled then 
					cleanupFollow() 
				end 
			end 
			connection:Disconnect() 
		end 
	end) 
end

end)

ToggleFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)

UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart if delta.Magnitude > dragThreshold then hasMoved = true end if hasMoved then ToggleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end end)

local function showNotification() task.spawn(function() for _ = 1, 5 do if game:IsLoaded() then local ok = pcall(function() StarterGui:SetCore("SendNotification", { Title = "The Strongest Battleground", Text = "Script executed", Duration = 5, }) end) if ok then return end end task.wait(0.2) end end) end

showNotification()

local function clearTrackedModels() for i = #TrackedModelList, 1, -1 do local model = TrackedModelList[i] TrackedModelList[i] = nil local info = TrackedModels[model] TrackedModels[model] = nil

if info and info.connections then 
		for j = 1, #info.connections do 
			local conn = info.connections[j] 
			if conn then conn:Disconnect() end 
		end 
	end
end

end

local function untrackModel(model) local info = TrackedModels[model] if not info then return end

TrackedModels[model] = nil

if info.connections then 
	for i = 1, #info.connections do 
		local conn = info.connections[i] 
		if conn then conn:Disconnect() end 
	end 
end

for i = #TrackedModelList, 1, -1 do 
	if TrackedModelList[i] == model then 
		table.remove(TrackedModelList, i) 
		break 
	end 
end

end

local function trackModel(model) if not (model and model:IsA("Model")) then return end if TrackedModels[model] then return end

local root = model:FindFirstChild("HumanoidRootPart") if root and not root:IsA("BasePart") then root = nil end
local info = { 
	root = root, 
	humanoid = model:FindFirstChildOfClass("Humanoid"), 
	forceFieldPresent = model:FindFirstChildOfClass("ForceField") ~= nil, 
	connections = {}, 
}

TrackedModels[model] = info 
TrackedModelList[#TrackedModelList + 1] = model

info.connections[1] = model.ChildAdded:Connect(function(child) 
	if child.Name == "HumanoidRootPart" and child:IsA("BasePart") then 
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
if not folder then return end

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

local function getNearestTarget() if not Enabled then return nil end local rootPart = RootPart if not (rootPart and rootPart.Parent) then return nil end

local liveFolder = getLiveFolder() 
if not liveFolder then return nil end

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
			if targetRoot and targetRoot:IsA("BasePart") and targetRoot.Parent and enemyHum and enemyHum.Parent and enemyHum.Health > 0 and not info.forceFieldPresent then 
				local offset = targetRoot.Position - currentPos 
				local distSq = offset.X * offset.X + offset.Y * offset.Y + offset.Z * offset.Z

				if distSq <= shortestDistSq then 
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

local function startFollowTarget(targetPart, duration) if not Enabled then return end cleanupFollow()

local rootPart = RootPart 
local humanoid = Humanoid 
if not (targetPart and targetPart.Parent and rootPart and rootPart.Parent and humanoid and humanoid.Parent) then return end

SavedAutoRotate = humanoid.AutoRotate 
humanoid.AutoRotate = false

local rig = ensureFollowRig(rootPart) 
if not rig then return end

FollowActionId += 1
local myFollowId = FollowActionId

FollowConnection = RunService.RenderStepped:Connect(function() 
	local currentTarget = targetPart 
	local currentRoot = RootPart 
	if currentTarget and currentTarget.Parent and currentRoot and currentRoot.Parent then 
		local currentRig = FollowRig 
		if currentRig and currentRig.AnchorPart and currentRig.AnchorPart.Parent then 
			currentRig.AnchorPart.CFrame = currentTarget.CFrame * ANCHOR_OFFSET_CFRAME 
		end 
	else 
		cleanupFollow() 
	end 
end)

task.delay(duration, function()
	if FollowActionId == myFollowId then
		cleanupFollow()
	end
end)

end

local function onAnimationPlayed(animTrack) if not Enabled then return end if not (animTrack and animTrack.Animation) then return end

local animationId = animTrack.Animation.AnimationId 
if not animationId then return end

local animId = string.match(animationId, "%d+") 
if not animId or not DashAnimations[animId] then return end

local isSpecial = SpecialDurations[animId] ~= nil
if isSpecial and not isBindingLethalKibaEnabled() then return end

CurrentActionId += 1 
local actionTicket = CurrentActionId 
local character = Character

local initialDelay = isSpecial and SpecialDurations[animId] or 0.32 
local duration = 0.6

task.delay(initialDelay, function() 
	if CurrentActionId ~= actionTicket or not Enabled then return end

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
		startFollowTarget(target, duration) 
	end 
end)

end

local function onCharacter(char) CurrentActionId += 1 FollowActionId += 1 local myId = CurrentActionId

cleanupFollow() 
destroyFollowRig()

if AnimConnection then 
	AnimConnection:Disconnect() 
	AnimConnection = nil 
end

Character = char

local hum = char:WaitForChild("Humanoid", 10) 
local root = char:WaitForChild("HumanoidRootPart", 10)

if not hum or not root then Humanoid = nil RootPart = nil return end
if CurrentActionId ~= myId then return end

Humanoid = hum 
RootPart = root

AnimConnection = hum.AnimationPlayed:Connect(onAnimationPlayed)

end

local function onCharacterRemoving() CurrentActionId += 1 FollowActionId += 1 cleanupFollow() destroyFollowRig()

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
