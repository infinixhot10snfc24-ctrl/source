local neConns = {}
local neHookOrig
local processed = setmetatable({}, {__mode = "k"})

local function activateNoEffect()
task.spawn(function()
repeat task.wait() until game:IsLoaded()

local w = workspace  
	local l = game:GetService("Lighting")  

	l.GlobalShadows = false  
	l.FogEnd = 1e9  
	l.EnvironmentDiffuseScale = 0  
	l.EnvironmentSpecularScale = 0  
	l.Technology = Enum.Technology.Compatibility  

	local function k(o)  
		if not o or not o.Parent then return end  

		if o:IsA("ParticleEmitter") then  
			o.Enabled=false  
			o.Rate=0  
			o.TimeScale=0  
			o.Speed=NumberRange.new(0)  
			o.Lifetime=NumberRange.new(0)  
			o.Size=NumberSequence.new(0)  
			o.Transparency=NumberSequence.new(1)  
			o.Rotation=NumberRange.new(0)  
			o.RotSpeed=NumberRange.new(0)  
			o.Acceleration=Vector3.new(0,0,0)  
			o.LockedToPart=false  
			o:Clear()  

		elseif o:IsA("Trail") then  
			o.Enabled=false  
			o.Transparency=NumberSequence.new(1)  

		elseif o:IsA("Beam") then  
			o.Enabled=false  
			o.Width0=0  
			o.Width1=0  
			o.Transparency=NumberSequence.new(1)  

		elseif o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then  
			o.Enabled=false  
			o.Size=0  

		elseif o:IsA("Explosion") then  
			o.BlastRadius=0  
			o.BlastPressure=0  

		elseif o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then  
			o.Enabled=false  
			o.Range=0  
			o.Brightness=0  

		elseif o:IsA("Sky") then  
			o.SkyboxBk=""  
			o.SkyboxDn=""  
			o.SkyboxFt=""  
			o.SkyboxLf=""  
			o.SkyboxRt=""  
			o.SkyboxUp=""  

		elseif o:IsA("Atmosphere") then  
			o.Density=0  
			o.Haze=0  
			o.Glare=0  

		elseif o:IsA("Clouds") then  
			o.Cover=0  
			o.Density=0  

		elseif o:IsA("BlurEffect") then  
			o.Enabled=false  
			o.Size=0  

		elseif o:IsA("BloomEffect") then  
			o.Enabled=false  
			o.Intensity=0  

		elseif o:IsA("SunRaysEffect") then  
			o.Enabled=false  
			o.Intensity=0  

		elseif o:IsA("DepthOfFieldEffect") then  
			o.Enabled=false  

		elseif o:IsA("ColorCorrectionEffect") then  
			o.Enabled=false  

		elseif o:IsA("BasePart") then  
			o.CastShadow=false  
			o.Reflectance=0  
			o.Material=Enum.Material.Plastic  
		end  
	end  

	for _, x in ipairs(w:GetDescendants()) do k(x) end  
	for _, x in ipairs(l:GetDescendants()) do k(x) end  

	neConns[#neConns+1] = w.DescendantAdded:Connect(function(o)  
		if o and o.Parent then k(o) end  
	end)  

	neConns[#neConns+1] = l.DescendantAdded:Connect(function(o)  
		if o and o.Parent then k(o) end  
	end)  

	local m = getrawmetatable(game)  
	setreadonly(m,false)  
	neHookOrig = m.__newindex  

	m.__newindex = newcclosure(function(s,k2,vv)  
		if typeof(s) == "Instance" then  
			if not s or not s.Parent then  
				return neHookOrig(s,k2,vv)  
			end  

			if processed[s] then  
				return neHookOrig(s,k2,vv)  
			end  

			if k2 == "Parent" then  
				processed[s] = true  

				if s:IsA("ParticleEmitter") then  
					neHookOrig(s,"Enabled",false)  
					neHookOrig(s,"Rate",0)  
					neHookOrig(s,"TimeScale",0)  
					neHookOrig(s,"Lifetime",NumberRange.new(0))  
					neHookOrig(s,"Speed",NumberRange.new(0))  
					neHookOrig(s,"Size",NumberSequence.new(0))  
					neHookOrig(s,"Transparency",NumberSequence.new(1))  
					neHookOrig(s,"Rotation",NumberRange.new(0))  
					neHookOrig(s,"RotSpeed",NumberRange.new(0))  
					neHookOrig(s,"Acceleration",Vector3.new(0,0,0))  
					neHookOrig(s,"LockedToPart",false)  

				elseif s:IsA("Trail") then  
					neHookOrig(s,"Enabled",false)  
					neHookOrig(s,"Transparency",NumberSequence.new(1))  

				elseif s:IsA("Beam") then  
					neHookOrig(s,"Enabled",false)  
					neHookOrig(s,"Width0",0)  
					neHookOrig(s,"Width1",0)  
					neHookOrig(s,"Transparency",NumberSequence.new(1))  

				elseif s:IsA("Explosion") then  
					neHookOrig(s,"BlastRadius",0)  
					neHookOrig(s,"BlastPressure",0)  

				elseif s:IsA("PointLight") or s:IsA("SpotLight") or s:IsA("SurfaceLight") then  
					neHookOrig(s,"Enabled",false)  
					neHookOrig(s,"Range",0)  
				end  

				return neHookOrig(s,k2,vv)  
			end  
		end  

		return neHookOrig(s,k2,vv)  
	end)  

	setreadonly(m,true)  
end)

end

activateNoEffect()