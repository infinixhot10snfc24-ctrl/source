getgenv().Config = getgenv().Config or {
	LockSpeed = 35,
	TpWalkSpeed = 0.6
}

if _G._tpwalk_loaded then
	return
end
_G._tpwalk_loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Character, Humanoid
local StateChangedConn

local tpwConn
local tpwActive = false

local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNewIndex = mt.__newindex
local oldIndex = mt.__index

mt.__newindex = newcclosure(function(self, key, value)
	if self ~= Humanoid then
		return oldNewIndex(self, key, value)
	end

	if not checkcaller() and key == "WalkSpeed" then
		return oldNewIndex(self, key, getgenv().Config.LockSpeed)
	end

	return oldNewIndex(self, key, value)
end)

mt.__index = newcclosure(function(self, key)
	if self ~= Humanoid then
		return oldIndex(self, key)
	end

	if key == "WalkSpeed" then
		return getgenv().Config.LockSpeed
	end

	return oldIndex(self, key)
end)

setreadonly(mt, true)

local function isRagdollLike(state)
	return state == Enum.HumanoidStateType.Physics
		or state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.PlatformStanding
		or state == Enum.HumanoidStateType.GettingUp
end

local function stopTpw()
	if not tpwActive then return end
	tpwActive = false

	if tpwConn then
		tpwConn:Disconnect()
		tpwConn = nil
	end
end

local function startTpw()
	if tpwActive or not Humanoid then return end
	tpwActive = true

	tpwConn = RunService.Stepped:Connect(function()
		local hum = Humanoid
		if not hum or not hum.Parent then return end

		if hum.MoveDirection.Magnitude > 0 then
			hum.Parent:TranslateBy(hum.MoveDirection * getgenv().Config.TpWalkSpeed)
		end
	end)
end

local function onCharacter(char)
	stopTpw()

	if StateChangedConn then
		StateChangedConn:Disconnect()
	end

	Character = char
	Humanoid = char:WaitForChild("Humanoid")

	StateChangedConn = Humanoid.StateChanged:Connect(function(_, new)
		if isRagdollLike(new) then
			startTpw()
		else
			stopTpw()
		end
	end)
end

local function onCharacterRemoving()
	stopTpw()

	if StateChangedConn then
		StateChangedConn:Disconnect()
		StateChangedConn = nil
	end
end

LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving)
LocalPlayer.CharacterAdded:Connect(onCharacter)

if LocalPlayer.Character then
	onCharacter(LocalPlayer.Character)
end