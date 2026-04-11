local l=loadstring;l([=[local D=_G.__DeltaCmds or{};_G.__DeltaCmds=D
D.plrs=game:GetService("Players")
D.plr=game:GetService("Players").LocalPlayer
D._active={}
local function isA(id)return D._active[id]==true end
local function setA(id)D._active[id]=true end
local function clrA(id)D._active[id]=nil end
local p=D.plr
local plrs=D.plrs
local rs=game:GetService("RunService")
local tps=game:GetService("TeleportService")
local uis=game:GetService("UserInputService")
local lt=game:GetService("Lighting")
local cam=workspace.CurrentCamera
local _ctrls
local function gCtl()
if not _ctrls then _ctrls=require(p.PlayerScripts:WaitForChild("PlayerModule")):GetControls()end
return _ctrls
end
local flyOn=false
local fHum
local flyCC,flyC,ncC,ncCC,ijC
local lwsC,ljpC,lpC,lpCC
local bv,bg,sB,sC,sSp
local hbC,hbS={},{}
local hbF,gC,godHealthConn
local oAmb,origOutdoor,origBright,origShadows,fbActive
local espF,espGlobalConn,espRemoveConn
local espD={}
local ctpT,clickTpConns=nil,{}
local gIdx,godHookNewIndex
local function getEspFolder()
if not espF or not espF.Parent then
espF=Instance.new("Folder",game.CoreGui)
espF.Name="DeltaESP"
end
return espF
end
SpeedSettings={Locked=false,Value=16,Original=16}
JumpSettings={Locked=false,Value=50,Original=50}
local oIdx,hookActive=nil,false
local function ensureHook()
if hookActive then return end
hookActive=true
oIdx=hookmetamethod(game,"__newindex",newcclosure(function(t,k,v)
if not checkcaller()and typeof(t)=="Instance"and t:IsA("Humanoid")then
if k=="WalkSpeed"and SpeedSettings.Locked then return oIdx(t,k,SpeedSettings.Value)end
if k=="JumpPower"and JumpSettings.Locked then return oIdx(t,k,JumpSettings.Value)end
end
return oIdx(t,k,v)
end))
end
local function tryRemoveHook()
if not SpeedSettings.Locked and not JumpSettings.Locked and hookActive and oIdx then
hookmetamethod(game,"__newindex",oIdx)
oIdx,hookActive=nil,false
end
end
local function resolveTargets(name)
local others={}
for _,v in ipairs(plrs:GetPlayers())do
if v~=p then others[#others+1]=v end
end
if name=="all"then return others end
if name=="random"then return#others>0 and{others[math.random(#others)]}or{}end
local ln,nl=string.lower(name),#name
for _,v in ipairs(others)do
if string.sub(string.lower(v.Name),1,nl)==ln or string.sub(string.lower(v.DisplayName),1,nl)==ln then
return{v}
end
end
return{}
end
local function stopFly()
clrA("fly");flyOn=false
if flyC then flyC:Disconnect();flyC=nil end
if flyCC then flyCC:Disconnect();flyCC=nil end
if bv then bv:Destroy();bv=nil end
if bg then bg:Destroy();bg=nil end
local hum=p.chr and p.chr:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand=false end
end
local function setupFlyChar(char)
if bv then bv:Destroy();bv=nil end
if bg then bg:Destroy();bg=nil end
local root=char:WaitForChild("HumanoidRootPart",10)
local hum=char:WaitForChild("Humanoid",10)
if not(root and hum)then return end
fHum=hum
bv=Instance.new("BodyVelocity",root);bv.MaxForce=Vector3.new(1e6,1e6,1e6)
bg=Instance.new("BodyGyro",root);bg.MaxTorque=Vector3.new(1e6,1e6,1e6);bg.P=1e4
end
local function startFly(spd)
if isA("fly")then return end;setA("fly")
stopFly();flyOn=true
local fSpd=spd
D.fSpd=fSpd
local char=p.chr or p.CharacterAdded:Wait()
setupFlyChar(char)
flyCC=p.CharacterAdded:Connect(function(c)setupFlyChar(c);fSpd=D.fSpd or 50 end)
flyC=rs.RenderStepped:Connect(function()
if not flyOn or not bv or not bv.Parent or not fHum or not fHum.Parent then return end
local mv=gCtl():GetMoveVector()
local cf=cam.CFrame
local vel=cf.RightVector*mv.X+cf.LookVector*-mv.Z
bv.Velocity=vel.Magnitude>0 and vel.Unit*fSpd or Vector3.zero
bg.CFrame=cf;fHum.PlatformStand=true
end)
end
local function applyNoclip(char)
if ncC then ncC:Disconnect()end
for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end
ncC=char.DescendantAdded:Connect(function(v)if v:IsA("BasePart")then v.CanCollide=false end end)
end
local function startNoclip()
if isA("noclip")then return end;setA("noclip")
if ncCC then ncCC:Disconnect()end
if p.chr then applyNoclip(p.chr)end
ncCC=p.CharacterAdded:Connect(applyNoclip)
end
local function stopNoclip()
clrA("noclip")
if ncC then ncC:Disconnect();ncC=nil end
if ncCC then ncCC:Disconnect();ncCC=nil end
local char=p.chr
if char then for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=true end end end
end
local function getHum(char)return char and char:FindFirstChildOfClass("Humanoid")end
local function startLws(spd)
if isA("lws")then return end;setA("lws")
ensureHook()
SpeedSettings.Value,SpeedSettings.Locked=spd,true
local function apply(char)
local hum=getHum(char)
if hum then
if not SpeedSettings.Original or SpeedSettings.Original==spd then SpeedSettings.Original=16 end
hum.WalkSpeed=spd
end
end
if p.chr then apply(p.chr)end
if lwsC then lwsC:Disconnect()end
lwsC=p.CharacterAdded:Connect(apply)
end
local function stopLws()
clrA("lws")
SpeedSettings.Locked=false
if lwsC then lwsC:Disconnect();lwsC=nil end
tryRemoveHook()
end
local function startLoopws(spd)
if isA("loopws")then return end;setA("loopws")
SpeedSettings.Locked=false
if lwsC then lwsC:Disconnect();lwsC=nil end
if lpC then lpC:Disconnect();lpC=nil end
if lpCC then lpCC:Disconnect();lpCC=nil end
local _lC,_lwsHum
lpCC=p.CharacterAdded:Connect(function(c)_lC=c;_lwsHum=nil end)
lpC=rs.Heartbeat:Connect(function()
local char=p.chr
if char~=_lC then _lC=char;_lwsHum=nil end
if not _lwsHum or not _lwsHum.Parent then _lwsHum=char and char:FindFirstChildOfClass("Humanoid")end
if _lwsHum and _lwsHum.WalkSpeed~=spd then _lwsHum.WalkSpeed=spd end
end)
end
local function stopLoopws()
clrA("loopws")
if lpC then lpC:Disconnect();lpC=nil end
if lpCC then lpCC:Disconnect();lpCC=nil end
end
local function setWs(spd)local hum=getHum(p.chr);if hum then hum.WalkSpeed=spd end end
local function startLjp(pw)
if isA("ljp")then return end;setA("ljp")
ensureHook()
JumpSettings.Value,JumpSettings.Locked,JumpSettings.OriginalUseJumpPower=pw,true,false
local function apply(char)
local hum=getHum(char)
if hum then hum.UseJumpPower=true;hum.JumpPower=pw end
end
if p.chr then apply(p.chr)end
if ljpC then ljpC:Disconnect()end
ljpC=p.CharacterAdded:Connect(apply)
end
local function stopLjp()
clrA("ljp")
JumpSettings.Locked=false
if ljpC then ljpC:Disconnect();ljpC=nil end
tryRemoveHook()
local hum=getHum(p.chr)
if hum then hum.UseJumpPower=JumpSettings.OriginalUseJumpPower or false end
end
local function setJp(pw)local hum=getHum(p.chr);if hum then hum.UseJumpPower=true;hum.JumpPower=pw end end
local function gotoPlayer(name,y,z)
local root=p.chr and p.chr:FindFirstChild("HumanoidRootPart")
if not root then return end
if tonumber(name)and tonumber(y)and tonumber(z)then root.CFrame=CFrame.new(tonumber(name),tonumber(y),tonumber(z));return end
local tgt=resolveTargets(name)[1]
local tRoot=tgt and tgt.chr and tgt.chr:FindFirstChild("HumanoidRootPart")
if tRoot then root.CFrame=tRoot.CFrame end
end
local function applySpinToChar(char)
if sB then sB:Destroy();sB=nil end
local root=char:FindFirstChild("HumanoidRootPart")
if root then
sB=Instance.new("BodyAngularVelocity",root)
sB.MaxTorque=Vector3.new(0,math.huge,0);sB.AngularVelocity=Vector3.new(0,sSp,0)
end
end
local function startSpin(spd)
if isA("spin")then return end;setA("spin")
sSp=spd
if sC then sC:Disconnect()end
if p.chr then applySpinToChar(p.chr)end
sC=p.CharacterAdded:Connect(applySpinToChar)
end
local function stopSpin()
clrA("spin")
if sB then sB:Destroy();sB=nil end
if sC then sC:Disconnect();sC=nil end
end
local function startInfJump()
if isA("infjump")then return end;setA("infjump")
if ijC then ijC:Disconnect()end
ijC=uis.JumpRequest:Connect(function()
local hum=getHum(p.chr)
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping)end
end)
end
local function stopInfJump()clrA("infjump");if ijC then ijC:Disconnect();ijC=nil end end
local function startFullbright()
if isA("fullbright")then return end;setA("fullbright")
if not fbActive then
oAmb,origOutdoor,origBright,origShadows=lt.Ambient,lt.OutdoorAmbient,lt.Brightness,lt.GlobalShadows
fbActive=true
end
lt.Ambient=Color3.new(1,1,1);lt.OutdoorAmbient=Color3.new(1,1,1)
lt.Brightness=2;lt.GlobalShadows=false;lt.FogEnd=100000
end
local function stopFullbright()
clrA("fullbright")
if not fbActive then return end
fbActive=false
lt.Ambient,lt.OutdoorAmbient,lt.Brightness,lt.GlobalShadows=oAmb,origOutdoor,origBright,origShadows
end
local function detachEspPlayer(tgt)
local dat=espD[tgt]
if not dat then return end
for _,c in ipairs(dat.conns)do c:Disconnect()end
for _,obj in ipairs(dat.items)do if obj and obj.Parent then obj:Destroy()end end
espD[tgt]=nil
end
local function stopEsp()
clrA("esp")
if espGlobalConn then espGlobalConn:Disconnect();espGlobalConn=nil end
if espRemoveConn then espRemoveConn:Disconnect();espRemoveConn=nil end
for tgt in pairs(espD)do detachEspPlayer(tgt)end
getEspFolder():ClearAllChildren()
end
local function attachEsp(tgt)
detachEspPlayer(tgt)
local dat={conns={},items={}}
espD[tgt]=dat
local function getLabel()
return tgt.DisplayName~=tgt.Name and tgt.DisplayName.."\n@"..tgt.Name or tgt.Name
end
local function clearItems()
for _,obj in ipairs(dat.items)do if obj and obj.Parent then obj:Destroy()end end
dat.items={}
end
local function createESP(char)
if not char then return end
clearItems()
local hrp=char:FindFirstChild("HumanoidRootPart")
if hrp then
local bgUI=Instance.new("BillboardGui",getEspFolder())
bgUI.Size=UDim2.new(0,200,0,44);bgUI.StudsOffset=Vector3.new(0,3,0)
bgUI.AlwaysOnTop=true;bgUI.Adornee=hrp
dat.items[#dat.items+1]=bgUI
local txt=Instance.new("TextLabel",bgUI)
txt.Size=UDim2.new(1,0,1,0);txt.BackgroundTransparency=1
txt.TextColor3=Color3.fromRGB(0,255,255);txt.TextStrokeTransparency=0
txt.Font=Enum.Font.GothamBold;txt.TextSize=13;txt.Text=getLabel()
dat.conns[#dat.conns+1]=tgt:GetPropertyChangedSignal("DisplayName"):Connect(function()txt.Text=getLabel()end)
else
local hrpConn
hrpConn=char.DescendantAdded:Connect(function(d)
if d.Name=="HumanoidRootPart"and d:IsA("BasePart")then hrpConn:Disconnect();createESP(char)end
end)
dat.conns[#dat.conns+1]=hrpConn
end
end
if tgt.chr then createESP(tgt.chr)end
dat.conns[#dat.conns+1]=tgt.CharacterAdded:Connect(createESP)
end
local function startEsp(name)
if isA("esp")then stopEsp()else setA("esp")end
stopEsp()
for _,v in ipairs(resolveTargets(name))do attachEsp(v)end
if name=="all"then espGlobalConn=plrs.PlayerAdded:Connect(attachEsp)end
espRemoveConn=plrs.PlayerRemoving:Connect(detachEspPlayer)
end
local function startFling(name)
if not name then return end
local tgs=resolveTargets(name)
if#tgs==0 then return end
local tPlr=tgs[math.random(#tgs)]
local chr=p.chr
local hum=chr and chr:FindFirstChildOfClass("Humanoid")
local rPt=hum and hum.rPt
local tChr=tPlr.chr
local tHum=tChr and tChr:FindFirstChildOfClass("Humanoid")
local tRt=tHum and tHum.rPt
local THead=tChr and tChr:FindFirstChild("Head")
local acc=tChr and tChr:FindFirstChildOfClass("Accessory")
local Handle=acc and acc:FindFirstChild("Handle")
if not(chr and hum and rPt)then return end
if rPt.Velocity.Magnitude<50 then OldPos=rPt.CFrame end
if tHum and tHum.Sit then return end
if THead then cam.CameraSubject=THead
elseif Handle then cam.CameraSubject=Handle
else cam.CameraSubject=tHum end
if not tChr:FindFirstChildWhichIsA("BasePart")then return end
local function FPos(BasePart,Pos,Ang)
rPt.CFrame=CFrame.new(BasePart.Position)*Pos*Ang
chr:SetPrimaryPartCFrame(CFrame.new(BasePart.Position)*Pos*Ang)
rPt.Velocity=Vector3.new(9e7,9e7*10,9e7)
rPt.RotVelocity=Vector3.new(9e8,9e8,9e8)
end
local function SFBasePart(BasePart)
local tW=2
local Time=tick()
local Angle=0
repeat
if rPt and tHum then
if BasePart.Velocity.Magnitude<50 then
Angle=Angle+100
FPos(BasePart,CFrame.new(0,1.5,0)+tHum.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0)+tHum.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
FPos(BasePart,CFrame.new(2.25,1.5,-2.25)+tHum.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
FPos(BasePart,CFrame.new(-2.25,-1.5,2.25)+tHum.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0));task.wait()
FPos(BasePart,CFrame.new(0,1.5,0)+tHum.MoveDirection,CFrame.Angles(math.rad(Angle),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0)+tHum.MoveDirection,CFrame.Angles(math.rad(Angle),0,0));task.wait()
else
FPos(BasePart,CFrame.new(0,1.5,tHum.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,-tHum.WalkSpeed),CFrame.Angles(0,0,0));task.wait()
FPos(BasePart,CFrame.new(0,1.5,tHum.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,1.5,tRt.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,-tRt.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0));task.wait()
FPos(BasePart,CFrame.new(0,1.5,tRt.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0));task.wait()
FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0));task.wait()
end
else break end
until BasePart.Velocity.Magnitude>500 or BasePart.Parent~=tPlr.chr or tPlr.Parent~=plrs or not tPlr.chr==tChr or tHum.Sit or hum.Health<=0 or tick()>Time+tW
end
local BV=Instance.new("BodyVelocity",rPt)
BV.Name="EpixVel";BV.Velocity=Vector3.new(9e8,9e8,9e8);BV.MaxForce=Vector3.new(1/0,1/0,1/0)
hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
if tRt and THead then
if(tRt.CFrame.p-THead.CFrame.p).Magnitude>5 then SFBasePart(THead)else SFBasePart(tRt)end
elseif tRt and not THead then SFBasePart(tRt)
elseif not tRt and THead then SFBasePart(THead)
elseif not tRt and not THead and acc and Handle then SFBasePart(Handle)
else BV:Destroy();hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true);cam.CameraSubject=hum;return end
BV:Destroy()
hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
cam.CameraSubject=hum
if OldPos then
repeat
rPt.CFrame=OldPos*CFrame.new(0,0.5,0)
chr:SetPrimaryPartCFrame(OldPos*CFrame.new(0,0.5,0))
hum:ChangeState("GettingUp")
for _,x in ipairs(chr:GetChildren())do
if x:IsA("BasePart")then x.Velocity=Vector3.new();x.RotVelocity=Vector3.new()end
end
task.wait()
until(rPt.Position-OldPos.p).Magnitude<25
end
end
local function copyPos()
local root=p.chr and p.chr:FindFirstChild("HumanoidRootPart")
if not root then return end
local pos=root.Position
setclipboard(math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z))
end
local function respawn()local hum=getHum(p.chr);if hum then hum.Health=0 end end
local function stopClickTp()
clrA("clicktp")
if ctpT then ctpT:Destroy();ctpT=nil end
for _,c in ipairs(clickTpConns)do c:Disconnect()end
clickTpConns={}
end
local function startClickTp()
if isA("clicktp")then return end;setA("clicktp")
stopClickTp()
local tool=Instance.new("Tool",p.Backpack)
tool.Name="ClickTP";tool.RequiresHandle=false;tool.ToolTip="Click/Tap to teleport"
ctpT=tool
local function doRaycastTp(screenPos)
local char=p.chr
local root=char and char:FindFirstChild("HumanoidRootPart")
if not root then return end
local ray=cam:ScreenPointToRay(screenPos.X,screenPos.Y)
local params=RaycastParams.new()
params.FilterDescendantsInstances={char};params.FilterType=Enum.RaycastFilterType.Exclude
local result=workspace:Raycast(ray.Origin,ray.Direction*1000,params)
if result then root.CFrame=CFrame.new(result.Position+result.Normal*2.5)end
end
local eqd,lastTouchPos=false,nil
local mbl=uis.TouchEnabled and not uis.KeyboardEnabled
clickTpConns[#clickTpConns+1]=tool.Equipped:Connect(function()eqd=true end)
clickTpConns[#clickTpConns+1]=tool.Unequipped:Connect(function()eqd=false;lastTouchPos=nil end)
if mbl then
clickTpConns[#clickTpConns+1]=uis.TouchStarted:Connect(function(inp)
if eqd then lastTouchPos=Vector2.new(inp.Position.X,inp.Position.Y)end
end)
clickTpConns[#clickTpConns+1]=tool.Activated:Connect(function()
if lastTouchPos then doRaycastTp(lastTouchPos);lastTouchPos=nil end
end)
else
clickTpConns[#clickTpConns+1]=tool.Activated:Connect(function()doRaycastTp(uis:GetMouseLocation())end)
end
clickTpConns[#clickTpConns+1]=tool.AncestryChanged:Connect(function()if not tool.Parent then stopClickTp()end end)
end
local function stopGodAll()
clrA("god")
if gC then gC:Disconnect();gC=nil end
if godHealthConn then godHealthConn:Disconnect();godHealthConn=nil end
if GodSettings then GodSettings.hookActive=false end
if gIdx then hookmetamethod(game,"__index",gIdx);gIdx=nil end
if godHookNewIndex then hookmetamethod(game,"__newindex",godHookNewIndex);godHookNewIndex=nil end
end
local function activateGod(mode)
if isA("god")then return end;setA("god")
stopGodAll()
if mode=="nohook"then
local function applyGod(char)
local hum=char:WaitForChild("Humanoid",5)
if not hum then return end
hum.MaxHealth,hum.Health=math.huge,math.huge
if godHealthConn then godHealthConn:Disconnect()end
godHealthConn=hum.HealthChanged:Connect(function()hum.Health=math.huge end)
end
if p.chr then applyGod(p.chr)end
gC=p.CharacterAdded:Connect(applyGod)
else
gIdx=hookmetamethod(game,"__index",newcclosure(function(self,key)
if not checkcaller()and self:IsA("Humanoid")and(key=="Health"or key=="MaxHealth")then
if p.chr and self:IsDescendantOf(p.chr)then return math.huge end
end
return gIdx(self,key)
end))
godHookNewIndex=hookmetamethod(game,"__newindex",newcclosure(function(self,key,val)
if not checkcaller()and self:IsA("Humanoid")and key=="Health"then
if p.chr and self:IsDescendantOf(p.chr)then return godHookNewIndex(self,key,math.huge)end
end
return godHookNewIndex(self,key,val)
end))
end
end
D.Pickers=D.Pickers or{}
table.insert(D.Pickers,{
cmdAlias="godmode",stopAlias="ungodmode",title="GODMODE",subtitle="Select godmode method",
buttons={
{lbl="NO HOOK",sub="HealthChanged-based",accent=Color3.fromRGB(0,170,255),val="nohook"},
{lbl="WITH HOOK",sub="hookmetamethod-based",accent=Color3.fromRGB(160,80,255),val="hook"},
},
onPick=activateGod,stopFn=stopGodAll,
hookOnValue="hook",
})
local DC=D
DC.resolveTargets=resolveTargets
DC.startFly,DC.stopFly=startFly,stopFly
DC.lockws,DC.unlockws=startLws,stopLws
DC.loopws,DC.unloopws=startLoopws,stopLoopws
DC.gCtl=gCtl
DC.Cmds={
{aliases={"fly"},args="[speed]",fn=function(v)startFly(tonumber(v)or 50)end,
hud="speed",hudDefault=50,hudStart="startFly",hudStop="stopFly",hudOn={"fly"},hudOff={"unfly"}},
{aliases={"unfly"},fn=stopFly},
{aliases={"noclip","nc"},fn=startNoclip},
{aliases={"unnoclip","unnc","clip"},fn=stopNoclip},
{aliases={"lockwalkspeed","lockws"},args="[speed]",fn=function(v)startLws(tonumber(v)or 16)end,hook=true},
{aliases={"unlockwalkspeed","unlockws"},fn=stopLws},
{aliases={"loopwalkspeed","loopws","lws"},args="[speed]",fn=function(v)startLoopws(tonumber(v)or 16)end},
{aliases={"unloopwalkspeed","unloopws","unlws"},fn=stopLoopws},
{aliases={"walkspeed","speed","ws"},args="[speed]",fn=function(v)setWs(tonumber(v)or 16)end},
{aliases={"lockjumppower","lockjp","ljp"},args="[power]",fn=function(v)startLjp(tonumber(v)or 50)end,hook=true},
{aliases={"unlockjumppower","unlockjp","unljp"},fn=stopLjp},
{aliases={"jumppower","jp"},args="[power]",fn=function(v)setJp(tonumber(v)or 50)end},
{aliases={"goto","tp"},args="[player/x] [y] [z]",fn=function(v,v2,v3)if v then gotoPlayer(v,v2,v3)end end},
{aliases={"fov"},args="[value]",fn=function(v)cam.FieldOfView=tonumber(v)or 70 end},
{aliases={"maxzoom"},args="[value]",fn=function(v)p.CameraMaxZoomDistance=tonumber(v)or 400 end},
{aliases={"rejoin","rj"},fn=function()tps:TeleportToPlaceInstance(game.PlaceId,game.JobId,p)end},
{aliases={"respawn","reset"},fn=respawn},
{aliases={"spin"},args="[speed]",fn=function(v)startSpin(tonumber(v)or 50)end},
{aliases={"unspin"},fn=stopSpin},
{aliases={"infjump","infinitejump"},fn=startInfJump},
{aliases={"uninfjump"},fn=stopInfJump},
{aliases={"fullbright","fb"},fn=startFullbright},
{aliases={"unfullbright","unfb"},fn=stopFullbright},
{aliases={"fling"},args="[player]",fn=function(v)if v then startFling(v)end end},
{aliases={"esp"},args="[player/all]",fn=function(v)if v then startEsp(v)end end},
{aliases={"unesp"},fn=stopEsp},
{aliases={"copypos","cpos"},fn=copyPos},
{aliases={"clicktp","ctp"},fn=startClickTp},
{aliases={"unclicktp","uctp"},fn=stopClickTp},
{aliases={"commands","cmds"},fn=nil},
{aliases={"antiafk","aafk"},fn=function()
if DC._aafkConn then return end
local vu=game:GetService("VirtualUser")
DC._aafkConn=p.Idled:Connect(function()
vu:Button2Down(Vector2.new(),cam.CFrame);task.wait(1);vu:Button2Up(Vector2.new(),cam.CFrame)
end)
end},
{aliases={"unantiafk","uaafk"},fn=function()
if DC._aafkConn then DC._aafkConn:Disconnect();DC._aafkConn=nil end
end},
{aliases={"fixcam"},fn=function()
local ch=p.chr or p.CharacterAdded:Wait()
local f=cam.FieldOfView
cam.CameraType=Enum.CameraType.Custom;cam.CameraSubject=ch:FindFirstChildOfClass("Humanoid");cam.FieldOfView=f
end},
{aliases={"hitbox","hb"},args="[size] [transparency]",fn=function(v,v2)
for _,c in ipairs(hbC)do c:Disconnect()end
hbC={}
if hbF then hbF:Destroy()end
hbF=Instance.new("Folder",workspace);hbF.Name="DeltaHitboxNCC"
local size=tonumber(v)or 30
local transp=tonumber(v2)or 0.9
local ps=plrs
local myHrp=p.chr and p.chr:FindFirstChild("HumanoidRootPart")
local function applyNcc(hrp)
if not myHrp then myHrp=p.chr and p.chr:FindFirstChild("HumanoidRootPart")end
if myHrp then
local ncc=Instance.new("NoCollisionConstraint",hbF)
ncc.Part0,ncc.Part1=myHrp,hrp
end
end
local function monitor(hrp)
local sz=Vector3.new(size,size,size)
if not hbS[hrp]then hbS[hrp]=hrp.Size end
local function apply()
if hrp.Size.X~=size then hrp.Size=sz;hrp.Transparency=transp end
end
apply();applyNcc(hrp)
hbC[#hbC+1]=hrp:GetPropertyChangedSignal("Size"):Connect(apply)
end
local function onChar(char)
local hrp=char:WaitForChild("HumanoidRootPart",5)
if hrp then monitor(hrp)end
end
local function onPlayer(pl)
if pl==p then return end
if p.Team and pl.Team and pl.Team==p.Team then return end
if pl.chr then onChar(pl.chr)end
hbC[#hbC+1]=pl.CharacterAdded:Connect(onChar)
end
for _,pl in ipairs(ps:GetPlayers())do onPlayer(pl)end
hbC[#hbC+1]=ps.PlayerAdded:Connect(onPlayer)
hbC[#hbC+1]=p.CharacterAdded:Connect(function(char)
myHrp=char:WaitForChild("HumanoidRootPart",5)
if not myHrp then return end
for _,pl in ipairs(ps:GetPlayers())do
if pl~=p and pl.chr then
local hrp=pl.chr:FindFirstChild("HumanoidRootPart")
if hrp then applyNcc(hrp)end
end
end
end)
end},
{aliases={"unhitbox","unhb"},fn=function()
for _,c in ipairs(hbC)do c:Disconnect()end
hbC={}
for hrp,origSize in pairs(hbS)do
if hrp and hrp.Parent then hrp.Size=origSize;hrp.Transparency=0 end
end
hbS={}
if hbF then hbF:Destroy();hbF=nil end
end},
{aliases={"godmode","god"},fn=function()end},
{aliases={"ungodmode","ungod"},fn=function()end},
}]=])();l([=[local D=_G.__DeltaCmds
repeat task.wait()until D and D.Cmds
local p=D.plr
local plrs=D.plrs
local function isA(id)return D._active and D._active[id]end
local function setA(id)if D._active then D._active[id]=true end end
local function clrA(id)if D._active then D._active[id]=nil end end
local rs=game:GetService("RunService")
local lt=game:GetService("Lighting")
local cam=workspace.CurrentCamera
local vwConn,vwRemoveConn,vwCharConn,vwPart
local fcConn,fcCharConn,fcPart
local afC,nfConn,frzConn
local afCs,aflOrig={},{}
local nfA,origFog
local neC,avisConns={},{}
local nHO=nil
local alGui,alHB,alPac,alPrc
local akA,akOrig
local function stopVw()
clrA("vw")
if vwConn then vwConn:Disconnect();vwConn=nil end
if vwRemoveConn then vwRemoveConn:Disconnect();vwRemoveConn=nil end
if vwCharConn then vwCharConn:Disconnect();vwCharConn=nil end
if vwPart then vwPart:Destroy();vwPart=nil end
cam.CameraType=Enum.CameraType.Custom
local char=p.chr
local hum=char and char:FindFirstChildOfClass("Humanoid")
if hum then cam.CameraSubject=hum end
local root=char and char:FindFirstChild("HumanoidRootPart")
if root then root.Anchored=false end
end
local function startVw(name)
if isA("vw")then return end;setA("vw")
stopVw()
local tgt=D.resolveTargets(name)[1]
if not tgt then return end
local pt=Instance.new("Part")
pt.Anchored,pt.CanCollide,pt.Transparency,pt.Size=true,false,1,Vector3.new(1,1,1)
pt.Parent=workspace;vwPart=pt
cam.CameraSubject,cam.CameraType=pt,Enum.CameraType.Custom
local char=p.chr
local root=char and char:FindFirstChild("HumanoidRootPart")
if root then root.Anchored=true end
vwCharConn=p.CharacterAdded:Connect(function(c)
local r=c:WaitForChild("HumanoidRootPart",5)
if r then r.Anchored=true end
end)
vwConn=rs.Heartbeat:Connect(function()
if not vwPart or not vwPart.Parent then return end
local tr=tgt.chr and tgt.chr:FindFirstChild("HumanoidRootPart")
if tr then vwPart.CFrame=tr.CFrame end
end)
vwRemoveConn=plrs.PlayerRemoving:Connect(function(pl)if pl==tgt then stopVw()end end)
end
local function stopFc()
clrA("fc")
if fcConn then fcConn:Disconnect();fcConn=nil end
if fcCharConn then fcCharConn:Disconnect();fcCharConn=nil end
if fcPart then fcPart:Destroy();fcPart=nil end
cam.CameraType=Enum.CameraType.Custom
local char=p.chr
local hum=char and char:FindFirstChildOfClass("Humanoid")
if hum then cam.CameraSubject=hum end
local root=char and char:FindFirstChild("HumanoidRootPart")
if root then root.Anchored=false end
end
local function startFc(spd)
if isA("fc")then return end;setA("fc")
stopFc()
local spd=spd or 50
local pt=Instance.new("Part")
pt.Anchored,pt.CanCollide,pt.Transparency,pt.CFrame=true,false,1,cam.CFrame
pt.Parent=workspace;fcPart=pt
cam.CameraSubject=pt
local root=p.chr and p.chr:FindFirstChild("HumanoidRootPart")
if root then root.Anchored=true end
local ctrls=D.gCtl()
fcConn=rs.RenderStepped:Connect(function()
local mv=ctrls:GetMoveVector()
local move=(cam.CFrame.LookVector*-mv.Z)+(cam.CFrame.RightVector*mv.X)
if move.Magnitude>0 then pt.CFrame=pt.CFrame+(move*(spd*0.06))end
end)
fcCharConn=p.CharacterAdded:Connect(function(c)
local r=c:WaitForChild("HumanoidRootPart",5)
if r then r.Anchored=true end
end)
end
local function startNf()
if isA("nf")then return end;setA("nf")
if not nfA then origFog,nfA=lt.FogEnd,true end
lt.FogEnd=1e9
if nfConn then nfConn:Disconnect()end
nfConn=lt:GetPropertyChangedSignal("FogEnd"):Connect(function()
if nfA and lt.FogEnd<1e9 then lt.FogEnd=1e9 end
end)
end
local function stopNf()
clrA("nf")
if not nfA then return end
nfA=false
if nfConn then nfConn:Disconnect();nfConn=nil end
lt.FogEnd=origFog
end
local function stopAfl()
clrA("afl")
for _,conn in ipairs(afCs)do conn:Disconnect()end
afCs={}
if afC then afC:Disconnect();afC=nil end
for pt,orig in pairs(aflOrig)do if pt and pt.Parent then pt.CanCollide=orig end end
aflOrig={}
end
local function startAfl()
if isA("afl")then return end;setA("afl")
stopAfl()
local function applyPart(pt)
if not aflOrig[pt]then
aflOrig[pt]=pt.CanCollide
afCs[#afCs+1]=pt.AncestryChanged:Connect(function()if not pt.Parent then aflOrig[pt]=nil end end)
end
pt.CanCollide=false
end
local function applyChar(char)
for _,pt in ipairs(char:GetDescendants())do if pt:IsA("BasePart")then applyPart(pt)end end
afCs[#afCs+1]=char.DescendantAdded:Connect(function(pt)if pt:IsA("BasePart")then applyPart(pt)end end)
end
local function onPlayer(pl)
if pl==p then return end
if pl.chr then applyChar(pl.chr)end
afCs[#afCs+1]=pl.CharacterAdded:Connect(applyChar)
end
for _,pl in ipairs(plrs:GetPlayers())do onPlayer(pl)end
afC=plrs.PlayerAdded:Connect(onPlayer)
end
local function stopFrz()
clrA("frz")
if frzConn then frzConn:Disconnect();frzConn=nil end
local char=p.chr
if char then for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then v.Anchored=false end end end
end
local function startFrz()
if isA("frz")then return end;setA("frz")
stopFrz()
local function applyFreeze(char)
for _,v in ipairs(char:GetDescendants())do if v:IsA("BasePart")then v.Anchored=true end end
end
local char=p.chr or p.CharacterAdded:Wait()
applyFreeze(char)
frzConn=p.CharacterAdded:Connect(applyFreeze)
end
D.startFc=startFc
D.stopFc=stopFc
D.startFrz=startFrz
D.stopFrz=stopFrz
local tps=game:GetService("TeleportService")
local hs=game:GetService("HttpService")
local function startAk()
if akA then return end
akA=true
local m=getrawmetatable(game);setreadonly(m,false)
akOrig=m.__namecall
m.__namecall=newcclosure(function(s,...)
if tostring(getnamecallmethod())=="Kick"then task.wait(9e9);return end
return akOrig(s,...)
end)
setreadonly(m,true)
end
local function stopAk()
if not akA then return end
local m=getrawmetatable(game);setreadonly(m,false)
m.__namecall=akOrig;setreadonly(m,true)
akOrig,akA=nil,false
end
local function serverhop()
local pid,curJob,servers,cursor=game.PlaceId,game.JobId,{},""
repeat
local url="https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"
if cursor~=""then url=url.."&cursor="..cursor end
local ok,res=pcall(function()return game:HttpGet(url)end)
if not ok then break end
local dat=hs:JSONDecode(res)
if not dat or not dat.dat then break end
for _,s in ipairs(dat.dat)do
if s.id~=curJob and s.playing<s.maxPlayers then servers[#servers+1]=s end
end
cursor=dat.nextPageCursor or""
until cursor==""
if#servers==0 then return end
tps:TeleportToPlaceInstance(pid,servers[math.random(#servers)].id,p)
end
local function sshop_fn()
local pid,curJob,cursor,best=game.PlaceId,game.JobId,"",nil
repeat
local url="https://games.roblox.com/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"
if cursor~=""then url=url.."&cursor="..cursor end
local ok,res=pcall(function()return game:HttpGet(url)end)
if not ok then break end
local dat=hs:JSONDecode(res)
if not dat or not dat.dat then break end
for _,s in ipairs(dat.dat)do
if s.id~=curJob and s.playing<s.maxPlayers then
if not best or s.playing<best.playing then best=s end
end
end
cursor=dat.nextPageCursor or""
until cursor==""or best and best.playing<=1
if not best then return end
tps:TeleportToPlaceInstance(pid,best.id,p)
end
local function stopAl()
clrA("al")
rs:UnbindFromRenderStep("DeltaAimlock")
if alHB then alHB:Disconnect();alHB=nil end
if alGui then alGui:Destroy();alGui=nil end
if alPac then alPac:Disconnect();alPac=nil end
if alPrc then alPrc:Disconnect();alPrc=nil end
end
local function startAl(fov)
if isA("al")then return end;setA("al")
stopAl()
local F=fov or 120;local F2=F*F;local A=0.4;local S=0.015;local M=1000;local PR=0.08
local L=p;local C=cam
local G=L:WaitForChild("PlayerGui")
local g=Instance.new("ScreenGui");g.IgnoreGuiInset=true;g.ResetOnSpawn=false;g.Parent=G;alGui=g
local c=Instance.new("Frame");c.AnchorPoint=Vector2.new(.5,.5);c.Position=UDim2.new(.5,0,.5,0)
c.Size=UDim2.fromOffset(F*2,F*2);c.BackgroundTransparency=1;c.Parent=g
local u=Instance.new("UICorner");u.CornerRadius=UDim.new(1,0);u.Parent=c
local s=Instance.new("UIStroke");s.Thickness=2;s.Color=Color3.fromRGB(255,255,255);s.Parent=c
local t,d,cp=nil,0,{}
for _,pl in ipairs(plrs:GetPlayers())do if pl~=L then cp[#cp+1]=pl end end
alPac=plrs.PlayerAdded:Connect(function(pl)if pl~=L then cp[#cp+1]=pl end end)
alPrc=plrs.PlayerRemoving:Connect(function(pl)
for i=#cp,1,-1 do if cp[i]==pl then table.remove(cp,i);break end end
end)
local rp=RaycastParams.new();rp.FilterType=Enum.RaycastFilterType.Exclude
local function v(h)
local o=C.CFrame.Position;local dir=h.Position-o
rp.FilterDescendantsInstances={L.chr,h.Parent}
return not workspace:Raycast(o,dir,rp)
end
local function ok(h)
if not h or not h.Parent then return false end
local ch=h.Parent;local hu=ch:FindFirstChild("Humanoid");local ro=ch:FindFirstChild("HumanoidRootPart")
if not hu or hu.Health<=0 or not ro then return false end
local mr=L.chr and L.chr:FindFirstChild("HumanoidRootPart")
if not mr then return false end
if(ro.Position-mr.Position).Magnitude>M then return false end
local vp=C.ViewportSize;local cx,cy=vp.X*.5,vp.Y*.5
local pos,vis=C:WorldToViewportPoint(h.Position)
if not vis then return false end
local dx,dy=pos.X-cx,pos.Y-cy
if dx*dx+dy*dy>F2 then return false end
return v(h)
end
local function gcl()
local cl,cd=nil,F2;local vp=C.ViewportSize;local cx,cy=vp.X*.5,vp.Y*.5
local mr=L.chr and L.chr:FindFirstChild("HumanoidRootPart")
if not mr then return nil end
for i=1,#cp do
local pl=cp[i];local ch=pl.chr
if ch then
local h=ch:FindFirstChild("Head");local hu=ch:FindFirstChild("Humanoid");local ro=ch:FindFirstChild("HumanoidRootPart")
if h and hu and hu.Health>0 and ro and(ro.Position-mr.Position).Magnitude<=M then
local pos,vis=C:WorldToViewportPoint(h.Position)
if vis then
local dx,dy=pos.X-cx,pos.Y-cy;local dist=dx*dx+dy*dy
if dist<cd and v(h)then cd=dist;cl=h end
end
end
end
end
return cl
end
alHB=rs.Heartbeat:Connect(function(dt)d+=dt;if d>S then d=0;if not ok(t)then t=gcl()end end end)
rs:BindToRenderStep("DeltaAimlock",10000,function()
if t and t.Parent then
local ro=t.Parent:FindFirstChild("HumanoidRootPart");local pos=t.Position
if ro then local vv=ro.AssemblyLinearVelocity;pos=pos+Vector3.new(vv.X,0,vv.Z)*PR end
C.CFrame=C.CFrame:Lerp(CFrame.new(C.CFrame.Position,pos),A)
end
end)
end
local function stopNoEffect()
clrA("ne")
for _,c in ipairs(neC)do c:Disconnect()end;neC={}
if nHO then
local m=getrawmetatable(game);setreadonly(m,false)
m.__newindex=nHO;setreadonly(m,true)
nHO=nil
end
end
local proc=setmetatable({},{__mode="k"})
local function activateNoEffect(mode)
if isA("ne")then return end;setA("ne")
stopNoEffect()
task.spawn(function()
repeat task.wait()until game:IsLoaded()
local w,l=workspace,game:GetService("Lighting")
pcall(function()
l.GlobalShadows=false;l.FogEnd=1e9
l.EnvironmentDiffuseScale=0;l.EnvironmentSpecularScale=0
l.Technology=Enum.Technology.Compatibility
end)
local function k(o)
if o:IsA("Sky")then pcall(function()o.SkyboxBk=""o.SkyboxDn=""o.SkyboxFt=""o.SkyboxLf=""o.SkyboxRt=""o.SkyboxUp=""end)end
if o:IsA("Decal")then pcall(function()o.Transparency=1;o.Texture=""end)end
if o:IsA("Texture")then pcall(function()o.Transparency=1;o.Texture=""o.StudsPerTileU=0;o.StudsPerTileV=0 end)end
pcall(function()
if o:IsA("MeshPart")then o.TextureID=""
elseif o:IsA("SpecialMesh")then o.TextureId=""
elseif o:IsA("SurfaceAppearance")then o.ColorMap=""o.MetalnessMap=""o.RoughnessMap=""o.NormalMap=""
elseif o:IsA("Highlight")then o.Enabled=false end
end)
if o:IsA("ParticleEmitter")then pcall(function()o.Enabled=false;o.Rate=0;o.Speed=NumberRange.new(0);o.Lifetime=NumberRange.new(0);o.Size=NumberSequence.new(0);o.Transparency=NumberSequence.new(1);o:Clear()end)end
if o:IsA("Trail")or o:IsA("Beam")then pcall(function()o.Enabled=false;o.Width0=0;o.Width1=0;o.Transparency=NumberSequence.new(1);o.TextureLength=0 end)end
if o:IsA("Fire")or o:IsA("Smoke")or o:IsA("Sparkles")then pcall(function()o.Enabled=false;o.Size=0 end)end
if o:IsA("Explosion")then pcall(function()o.BlastRadius=0;o.BlastPressure=0 end)end
if o:IsA("PointLight")or o:IsA("SpotLight")or o:IsA("SurfaceLight")then pcall(function()o.Enabled=false;o.Brightness=0;o.Range=0 end)end
if o:IsA("BlurEffect")or o:IsA("BloomEffect")or o:IsA("ColorCorrectionEffect")or o:IsA("SunRaysEffect")or o:IsA("DepthOfFieldEffect")then pcall(function()o.Enabled=false;pcall(function()o.Size=0 end);pcall(function()o.Intensity=0 end)end)end
if o:IsA("Clouds")then pcall(function()o.Cover=0;o.Density=0 end)end
if o:IsA("Atmosphere")then pcall(function()o.Density=0;o.Haze=0;o.Glare=0 end)end
if o:IsA("BasePart")then pcall(function()o.CastShadow=false;o.Reflectance=0;o.Material=Enum.Material.Plastic end)end
end
for _,x in ipairs(w:GetDescendants())do k(x)end
for _,x in ipairs(l:GetDescendants())do k(x)end
neC[#neC+1]=w.DescendantAdded:Connect(function(o)pcall(k,o)end)
neC[#neC+1]=l.DescendantAdded:Connect(function(o)pcall(k,o)end)
if mode=="hook"then
local m=getrawmetatable(game);setreadonly(m,false)
nHO=m.__newindex
m.__newindex=newcclosure(function(s,k2,vv)
if typeof(s)=="Instance"then
if proc[s]then return nHO(s,k2,vv)end
if k2=="Parent"then
proc[s]=true
if s:IsA("ParticleEmitter")then
nHO(s,"Enabled",false);nHO(s,"Rate",0)
nHO(s,"Lifetime",NumberRange.new(0));nHO(s,"Speed",NumberRange.new(0))
nHO(s,"Size",NumberSequence.new(0));nHO(s,"Transparency",NumberSequence.new(1))
elseif s:IsA("Trail")or s:IsA("Beam")then
nHO(s,"Enabled",false);nHO(s,"Width0",0);nHO(s,"Width1",0)
nHO(s,"Transparency",NumberSequence.new(1))
elseif s:IsA("Explosion")then
nHO(s,"BlastRadius",0);nHO(s,"BlastPressure",0)
elseif s:IsA("Fire")or s:IsA("Smoke")or s:IsA("Sparkles")then
nHO(s,"Enabled",false)
elseif s:IsA("PointLight")or s:IsA("SpotLight")or s:IsA("SurfaceLight")then
nHO(s,"Enabled",false);nHO(s,"Range",0)
end
return nHO(s,k2,vv)
end
if s:IsA("ParticleEmitter")then
if k2=="Enabled"then return nHO(s,k2,false)
elseif k2=="Rate"then return nHO(s,k2,0)
elseif k2=="Speed"or k2=="Lifetime"then return nHO(s,k2,NumberRange.new(0))
elseif k2=="Size"then return nHO(s,k2,NumberSequence.new(0))
elseif k2=="Transparency"then return nHO(s,k2,NumberSequence.new(1))end
elseif s:IsA("Trail")or s:IsA("Beam")then
if k2=="Enabled"then return nHO(s,k2,false)
elseif k2=="Width0"or k2=="Width1"then return nHO(s,k2,0)
elseif k2=="Transparency"then return nHO(s,k2,NumberSequence.new(1))end
elseif s:IsA("PointLight")or s:IsA("SpotLight")or s:IsA("SurfaceLight")then
if k2=="Enabled"then return nHO(s,k2,false)
elseif k2=="Range"then return nHO(s,k2,0)end
end
end
return nHO(s,k2,vv)
end)
setreadonly(m,true)
end
end)
end
local function stopAvis()
clrA("avis")
for _,c in ipairs(avisConns)do c:Disconnect()end;avisConns={}
end
local function startAvis()
if isA("avis")then return end;setA("avis")
stopAvis()
local pl=plrs
local b={Head=1,Torso=1,["Left Arm"]=1,["Right Arm"]=1,["Left Leg"]=1,["Right Leg"]=1,UpperTorso=1,LowerTorso=1,RightUpperArm=1,RightLowerArm=1,RightHand=1,LeftUpperArm=1,LeftLowerArm=1,LeftHand=1,RightUpperLeg=1,RightLowerLeg=1,RightFoot=1,LeftUpperLeg=1,LeftLowerLeg=1,LeftFoot=1}
local function v(o)
if o.Name=="HumanoidRootPart"then return end
if(o:IsA("BasePart")and(b[o.Name]or(o.Parent and o.Parent:IsA("Accessory"))))or o:IsA("Decal")then
pcall(function()
o.Transparency=0;o.LocalTransparencyModifier=0
o:GetPropertyChangedSignal("Transparency"):Connect(function()o.Transparency=0 end)
o:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()o.LocalTransparencyModifier=0 end)
end)
end
end
local function c(h)
for _,o in ipairs(h:GetDescendants())do v(o)end
avisConns[#avisConns+1]=h.DescendantAdded:Connect(v)
end
for _,player in ipairs(pl:GetPlayers())do
if player.chr then c(player.chr)end
avisConns[#avisConns+1]=player.CharacterAdded:Connect(c)
end
avisConns[#avisConns+1]=pl.PlayerAdded:Connect(function(player)
avisConns[#avisConns+1]=player.CharacterAdded:Connect(c)
end)
end
local function startAutoClick()
if isA("ac")then return end;setA("ac")
local VIM=game:GetService("VirtualInputManager")
local ac=D.AC
if not ac then return end
ac.active=true
task.spawn(function()
while ac.active do
pcall(function()
local t,m,d=ac.tgt,ac.mode,ac.delay
if m=="Mobile"then
VIM:SendTouchEvent(999,0,t.X,t.Y)
if d>0 then task.wait(d/2)end
VIM:SendTouchEvent(999,2,t.X,t.Y)
elseif m=="PC"then
VIM:SendMouseButtonEvent(t.X,t.Y,0,true,game,1)
if d>0 then task.wait(d/2)end
VIM:SendMouseButtonEvent(t.X,t.Y,0,false,game,1)
end
end)
if ac.delay>0 then task.wait(ac.delay/2)else task.wait()end
end
end)
end
local function stopAutoClick()clrA("ac");local ac=D.AC;if ac then ac.active=false end end
D.AC={active=false,tgt=Vector2.new(0,0),mode="Mobile",delay=0.3}
local nCs={
{aliases={"view","watch"},args="[player]",fn=function(v)if v then startVw(v)else stopVw()end end},
{aliases={"unview","unwatch"},fn=stopVw},
{aliases={"freecam","fc"},args="[speed]",fn=function(v)startFc(tonumber(v))end,
hud="speed",hudDefault=50,hudStart="startFc",hudStop="stopFc",hudOn={"freecam","fc"},hudOff={"unfreecam","unfc"}},
{aliases={"unfreecam","unfc"},fn=stopFc},
{aliases={"nofog"},fn=startNf},
{aliases={"unnofog"},fn=stopNf},
{aliases={"antifling"},fn=startAfl},
{aliases={"unantifling"},fn=stopAfl},
{aliases={"freeze"},fn=startFrz,
hud="toggle",hudStart="startFrz",hudStop="stopFrz",hudOn={"freeze"},hudOff={"unfreeze"}},
{aliases={"unfreeze"},fn=stopFrz},
{aliases={"antikick"},fn=startAk,hook=true},
{aliases={"unantikick"},fn=stopAk},
{aliases={"serverhop","shop"},fn=function()task.spawn(serverhop)end},
{aliases={"smallserverhop","sshop"},fn=function()task.spawn(sshop_fn)end},
{aliases={"aimlock"},args="[fov]",fn=function(v)startAl(tonumber(v))end},
{aliases={"unaimlock"},fn=stopAl},
{aliases={"noeffect"},fn=function()end},
{aliases={"unnoeffect"},fn=stopNoEffect},
{aliases={"antiinvisible","antiinvis","avis"},fn=startAvis},
{aliases={"unantiinvisible","unantiinvis","unavis"},fn=stopAvis},
{aliases={"autoclicker","autoclick"},fn=startAutoClick},
{aliases={"unautoclicker","unautoclick"},fn=stopAutoClick},
{aliases={"selfkick","sk"},fn=function()p:Kick("You have been banned.\n\nReason: Exploiting\n\nAppeal at: www.roblox.com/appeal")end},
{aliases={"addbutton","ab"},args="[command]",fn=function(v)if v and D.addButton then D.addButton(v)end end},
{aliases={"removebutton","rb"},args="[command]",fn=function(v)if v and D.removeButton then D.removeButton(v)end end},
}
local cmds=D.Cmds
local iAt=#cmds
for i,ent in ipairs(cmds)do if ent.aliases[1]=="commands"then iAt=i;break end end
for i,ent in ipairs(nCs)do table.insert(cmds,iAt+i-1,ent)end
D.Pickers=D.Pickers or{}
table.insert(D.Pickers,{
cmdAlias="noeffect",stopAlias="unnoeffect",title="NOEFFECT",subtitle="Select method",
buttons={
{lbl="NO HOOK",sub="Safe, client-side only",accent=Color3.fromRGB(0,170,255),val="nohook"},
{lbl="WITH HOOK",sub="hookmetamethod-based",accent=Color3.fromRGB(160,80,255),val="hook"},
},
onPick=activateNoEffect,stopFn=stopNoEffect,
hookOnValue="hook",
})]=])();l([=[local D=_G.__DeltaCmds
repeat task.wait()until D and D.Cmds
local p=D.plr
local plrs=D.plrs
local function isA(id)return D._active and D._active[id]end
local function setA(id)if D._active then D._active[id]=true end end
local function clrA(id)if D._active then D._active[id]=nil end end
local rs=game:GetService("RunService")
local cam=workspace.CurrentCamera
local wfConn
local function startWf()
if wfConn then return end
local function getRoot(char)
return char and(char:FindFirstChild("HumanoidRootPart")or char:FindFirstChild("Torso")or char:FindFirstChild("UpperTorso"))
end
wfConn=rs.Heartbeat:Connect(function()
local root=getRoot(p.chr)
if not root then return end
local v=root.Velocity
root.Velocity=v*100000
rs.RenderStepped:Wait()
root.Velocity=v
end)
end
local function stopWf()if wfConn then wfConn:Disconnect();wfConn=nil end end
local saOld,saGui
local saS={Enabled=false,FOV=300,TargetPart="Head",Mode="fov"}
local function saDrawCircle(fov)
if saGui then saGui:Destroy();saGui=nil end
local G=p:WaitForChild("PlayerGui")
local sg=Instance.new("ScreenGui",G);sg.Name="DeltaSAFov";sg.IgnoreGuiInset=true;sg.ResetOnSpawn=false;saGui=sg
local c=Instance.new("Frame",sg);c.AnchorPoint=Vector2.new(.5,.5);c.Position=UDim2.new(.5,0,.5,0)
c.Size=UDim2.fromOffset(fov*2,fov*2);c.BackgroundTransparency=1
local u=Instance.new("UICorner",c);u.CornerRadius=UDim.new(1,0)
local s=Instance.new("UIStroke",c);s.Thickness=2;s.Color=Color3.fromRGB(255,255,255)
end
local function stopSa()
saS.Enabled=false
if saGui then saGui:Destroy();saGui=nil end
if not saOld then return end
hookmetamethod(game,"__index",saOld);saOld=nil
end
local function startSa(targetPart,arg)
stopSa()
saS.Enabled=true
saS.TargetPart=targetPart or saS.TargetPart
local isNear=(arg=="near")
saS.Mode=isNear and"near"or"fov"
saS.FOV=tonumber(arg)or saS.FOV
if not isNear then saDrawCircle(saS.FOV)end
local mouse=p:GetMouse()
local function GetTarget()
local myChar=p.chr
local myRoot=myChar and myChar:FindFirstChild("HumanoidRootPart")
if saS.Mode=="near"then
local clst,bestDist=nil,math.huge
for _,pl in ipairs(plrs:GetPlayers())do
local ch=pl.chr
if pl~=p and ch and myRoot then
local pt=ch:FindFirstChild(saS.TargetPart)
local hum=ch:FindFirstChildOfClass("Humanoid")
local root=ch:FindFirstChild("HumanoidRootPart")
if pt and hum and hum.Health>0 and root then
local d=(myRoot.Position-root.Position).Magnitude
if d<bestDist then bestDist=d;clst=pt end
end
end
end
return clst
else
local c=workspace.CurrentCamera
if not c then return end
local center=c.ViewportSize/2
local clst,dist=nil,saS.FOV
for _,pl in ipairs(plrs:GetPlayers())do
local ch=pl.chr
if pl~=p and ch then
local pt=ch:FindFirstChild(saS.TargetPart)
local hum=ch:FindFirstChildOfClass("Humanoid")
if pt and hum and hum.Health>0 then
local pos,on=c:WorldToScreenPoint(pt.Position)
if on then
local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
if d<dist then dist=d;clst=pt end
end
end
end
end
return clst
end
end
saOld=hookmetamethod(game,"__index",newcclosure(function(self,key)
if not checkcaller()and self==mouse and saS.Enabled and(key=="Hit"or key=="Target"or key=="UnitRay")then
local tgt=GetTarget()
local c=workspace.CurrentCamera
if tgt and tgt:IsDescendantOf(workspace)and c then
local dir=tgt.Position-c.CFrame.Position
dir=dir.Magnitude>0 and dir.Unit or c.CFrame.LookVector
if key=="Target"then return tgt end
if key=="Hit"then return CFrame.new(tgt.Position,tgt.Position+dir)end
if key=="UnitRay"then return Ray.new(c.CFrame.Position,dir)end
end
end
return saOld(self,key)
end))
end
local tpwC,tpwCharConn
local function startTpw(spd)
if isA("tpw")then return end;setA("tpw")
if tpwC then tpwC:Disconnect()end
if tpwCharConn then tpwCharConn:Disconnect()end
local s=spd or 0.5
local _tH
tpwCharConn=p.CharacterAdded:Connect(function()_tH=nil end)
tpwC=rs.Stepped:Connect(function()
if not _tH or not _tH.Parent then _tH=p.chr and p.chr:FindFirstChildOfClass("Humanoid")end
if _tH and _tH.MoveDirection.Magnitude>0 then _tH.Parent:TranslateBy(_tH.MoveDirection*s)end
end)
end
local function stopTpw()
clrA("tpw")
if tpwC then tpwC:Disconnect();tpwC=nil end
if tpwCharConn then tpwCharConn:Disconnect();tpwCharConn=nil end
end
local vfConn,vfCharConn
local function stopVf()
clrA("vf")
if vfConn then vfConn:Disconnect();vfConn=nil end
if vfCharConn then vfCharConn:Disconnect();vfCharConn=nil end
local char=p.chr
if char then
local root=char:FindFirstChild("HumanoidRootPart")
if root then
local bg=root:FindFirstChild("NA_Gyro");local bv=root:FindFirstChild("NA_Velocity")
if bg then bg:Destroy()end;if bv then bv:Destroy()end
end
end
end
D.startVf=function(spd)
if isA("vf")then return end;setA("vf")
stopVf()
local spd=spd or 50
local function doFly(char)
local root=char:WaitForChild("HumanoidRootPart",5)
if not root then return end
local bg=Instance.new("BodyGyro",root);bg.Name="NA_Gyro";bg.MaxTorque=Vector3.new(9e9,9e9,9e9);bg.P=9e4
local bv=Instance.new("BodyVelocity",root);bv.Name="NA_Velocity";bv.MaxForce=Vector3.new(9e9,9e9,9e9);bv.Velocity=Vector3.zero
vfConn=rs.Heartbeat:Connect(function()
if not char:IsDescendantOf(workspace)or not bg.Parent or not bv.Parent then
vfConn:Disconnect();vfConn=nil;bg:Destroy();bv:Destroy();return
end
local mv=D.gCtl():GetMoveVector()
bv.Velocity=mv.Magnitude>0 and cam.CFrame:VectorToWorldSpace(Vector3.new(mv.X,0,mv.Z))*spd or Vector3.zero
bg.CFrame=cam.CFrame
end)
end
if p.chr then doFly(p.chr)end
vfCharConn=p.CharacterAdded:Connect(doFly)
end
D.stopVf=stopVf
local function startReach(sz)
local size=tonumber(sz)or 25
local char=p.chr
local tool=char and char:FindFirstChildOfClass("Tool")or p.Backpack:FindFirstChildOfClass("Tool")
if not tool then return end
local val=Instance.new("Vector3Value",tool);val.Name="OGSize3";val.Value=tool.Handle.Size
local sb=Instance.new("SelectionBox");sb.Adornee=tool.Handle;sb.Name="FunTIMES";sb.Transparency=1;sb.Parent=tool.Handle
tool.Handle.Massless=true;tool.Handle.Size=Vector3.new(size,size,size)
end
local function startStats()D._showStats=true end
local invC,invisCharConn
local invA,invisVisibleParts=false,{}
local function setupInvisChar(char)
char=char or p.chr
if not char then return end
invisVisibleParts={}
for _,pt in pairs(char:GetDescendants())do
if pt:IsA("BasePart")and pt.Transparency==0 then invisVisibleParts[#invisVisibleParts+1]=pt end
end
for _,pt in pairs(invisVisibleParts)do pt.Transparency=0.5 end
end
local function startInvis()
if invA then return end
invA=true
local char=p.chr or p.CharacterAdded:Wait()
local hum=char:WaitForChild("Humanoid",5)
local root=char:WaitForChild("HumanoidRootPart",5)
if not hum or not root then invA=false;return end
setupInvisChar(char)
if invisCharConn then invisCharConn:Disconnect()end
invisCharConn=p.CharacterAdded:Connect(function(newChar)
if not invA then return end
hum=newChar:WaitForChild("Humanoid",5);root=newChar:WaitForChild("HumanoidRootPart",5)
if hum and root then setupInvisChar(newChar)end
end)
if invC then invC:Disconnect()end
invC=rs.Heartbeat:Connect(function()
if not invA or not root or not root.Parent or not hum or not hum.Parent then return end
local origCF=root.CFrame;local origCO=hum.CameraOffset
local hCF=origCF-origCF.Position+Vector3.new(origCF.X,origCF.Y-200000,origCF.Z)
root.CFrame=hCF;hum.CameraOffset=origCF.Position-hCF.Position
rs.RenderStepped:Wait()
root.CFrame=origCF;hum.CameraOffset=origCO
end)
end
local function stopInvis()
clrA("invis");invA=false
if invC then invC:Disconnect();invC=nil end
if invisCharConn then invisCharConn:Disconnect();invisCharConn=nil end
for _,pt in pairs(invisVisibleParts)do if pt and pt.Parent then pt.Transparency=0 end end
invisVisibleParts={}
end
local nCs={
{aliases={"walkfling","wf"},fn=startWf},
{aliases={"unwalkfling","unwf"},fn=stopWf},
{aliases={"silentaim"},args="[fov/near]",fn=function(v)startSa(saS.TargetPart,v or"near")end,hook=true},
{aliases={"unsilentaim"},fn=stopSa},
{aliases={"tpwalkspeed","tpwalk"},args="[speed]",fn=function(v)startTpw(tonumber(v))end},
{aliases={"untpwalkspeed","untpwalk"},fn=stopTpw},
{aliases={"vehiclefly","vfly"},args="[speed]",fn=function(v)D.startVf(tonumber(v))end,
hud="speed",hudDefault=50,hudStart="startVf",hudStop="stopVf",hudOn={"vehiclefly","vfly"},hudOff={"unvehiclefly","unvfly"}},
{aliases={"unvehiclefly","unvfly"},fn=stopVf},
{aliases={"reach"},args="[size]",fn=function(v)startReach(v)end},
{aliases={"stats"},fn=startStats},
{aliases={"invisible","invis"},fn=startInvis},
{aliases={"uninvisible","uninvis"},fn=stopInvis},
}
local cmds=D.Cmds
local iAt=#cmds
for i,ent in ipairs(cmds)do if ent.aliases[1]=="commands"then iAt=i;break end end
for i,ent in ipairs(nCs)do table.insert(cmds,iAt+i-1,ent)end
local admA,adminChatConn
local function startAdmin()
if admA then return end
admA=true
adminChatConn=p.Chatted:Connect(function(msg)
if msg:sub(1,1)~="/"then return end
if D.runCmd then D.runCmd(msg:sub(2))end
end)
end
local admI=#cmds
for i,e in ipairs(cmds)do if e.aliases[1]=="commands"then admI=i;break end end
table.insert(cmds,admI,{aliases={"admin"},fn=startAdmin})
D.Pickers=D.Pickers or{}
table.insert(D.Pickers,{
cmdAlias="silentaim",stopAlias="unsilentaim",title="SILENT AIM",subtitle="Select target part",
buttons={
{lbl="HEAD",sub="Aim at head",accent=Color3.fromRGB(0,170,255),val="Head"},
{lbl="HRP",sub="Aim at HumanoidRootPart",accent=Color3.fromRGB(160,80,255),val="HumanoidRootPart"},
},
onPick=function(pt)startSa(pt,"near")end,
stopFn=stopSa,
})]=])();l([=[local D=_G.__DeltaCmds
repeat task.wait()until D and D.Cmds
local p=D.plr
local ts=game:GetService("TweenService")
local uis=game:GetService("UserInputService")
local _C=Color3.fromRGB;local _U=UDim2.new;local _N=Instance.new;local _GB=Enum.Font.GothamBold;local _GS=Enum.Font.GothamSemibold;local _G=Enum.Font.Gotham;local _TX=Enum.TextXAlignment;local _UI=Enum.UserInputType
local MS=6;local ITEM_H=36;local IP=3
local sg=_N("ScreenGui",game.CoreGui)
sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local function makeDraggable(fr,handle)
handle=handle or fr
local dIn,dragStart,startPos
handle.InputBegan:Connect(function(inp)
if inp.UserInputType==_UI.MouseButton1 or inp.UserInputType==_UI.Touch then
dIn=inp;dragStart=inp.Position;startPos=fr.Position
inp.Changed:Connect(function()
if inp.UserInputState==Enum.UserInputState.End then
if dIn==inp then dIn=nil end
end
end)
end
end)
handle.InputChanged:Connect(function(inp)
if dIn and inp==dIn then
local delta=inp.Position-dragStart
fr.Position=_U(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
end
end)
end
local btnC=_N("Frame",sg)
btnC.Name="Container";btnC.Size=_U(0,50,0,50);btnC.Position=_U(0,20,0,20)
btnC.BackgroundTransparency=1;btnC.BorderSizePixel=0;btnC.ZIndex=10
local btn=_N("ImageButton",btnC)
btn.Name="Button";btn.Size=_U(1,0,1,0);btn.BackgroundTransparency=1;btn.BorderSizePixel=0
btn.Image="rbxassetid://115634411771134";btn.ImageTransparency=0
btn.ScaleType=Enum.ScaleType.Fit;btn.AutoButtonColor=false;btn.Active=true;btn.ZIndex=10
btn.MouseEnter:Connect(function()ts:Create(btn,TweenInfo.new(0.15),{ImageTransparency=0.2}):Play()end)
btn.MouseLeave:Connect(function()ts:Create(btn,TweenInfo.new(0.15),{ImageTransparency=0}):Play()end)
makeDraggable(btnC,btn)
local cF=_N("Frame",sg)
cF.Size=_U(0,0,0,48);cF.Position=_U(0.5,0,0.5,0);cF.AnchorPoint=Vector2.new(0.5,0.5)
cF.BackgroundColor3=_C(13,13,18);cF.ClipsDescendants=true;cF.Visible=false
_N("UICorner",cF).CornerRadius=UDim.new(0,24)
local s2=_N("UIStroke",cF);s2.Color=_C(0,120,200);s2.Thickness=1.5
local cG=_N("UIGradient",cF)
cG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,_C(20,20,30)),ColorSequenceKeypoint.new(1,_C(10,10,18))}
cG.Rotation=90
local cI=_N("TextLabel",cF)
cI.Size=_U(0,36,1,0);cI.Position=_U(0,8,0,0);cI.BackgroundTransparency=1
cI.Text="⌘";cI.TextColor3=_C(0,170,255);cI.Font=_GB;cI.TextSize=18
local box=_N("TextBox",cF)
box.Size=_U(1,-50,1,0);box.Position=_U(0,40,0,0);box.BackgroundTransparency=1
box.TextColor3=_C(220,220,220);box.PlaceholderText="ketik command...";box.PlaceholderColor3=_C(80,80,100)
box.Font=_GS;box.TextSize=15;box.TextXAlignment=_TX.Left
local sF=_N("Frame",sg)
sF.Size=_U(0,320,0,0);sF.Position=_U(0.5,0,0.5,-26);sF.AnchorPoint=Vector2.new(0.5,1)
sF.BackgroundColor3=_C(15,15,20);sF.ClipsDescendants=true;sF.Visible=false
_N("UICorner",sF).CornerRadius=UDim.new(0,12)
local sSugg=_N("UIStroke",sF);sSugg.Color=_C(0,100,180);sSugg.Thickness=1
_N("UIListLayout",sF).Padding=UDim.new(0,IP)
local cS=false
local sI={}
for i=1,MS do
local itm=_N("TextButton",sF)
itm.Size=_U(1,0,0,ITEM_H);itm.BackgroundTransparency=1;itm.TextColor3=_C(0,170,255)
itm.Font=_GS;itm.TextSize=15;itm.TextXAlignment=_TX.Left;itm.AutoButtonColor=false
itm.Text="";itm.Visible=false;itm.LayoutOrder=i
_N("UIPadding",itm).PaddingLeft=UDim.new(0,14)
itm.MouseEnter:Connect(function()itm.BackgroundTransparency=0.75;itm.BackgroundColor3=_C(0,80,180)end)
itm.MouseLeave:Connect(function()itm.BackgroundTransparency=1 end)
itm.MouseButton1Down:Connect(function()cS=true end)
itm.MouseButton1Click:Connect(function()
local first=string.match(itm.Text,"^([^/]+)")
box.Text=first.." ";cS=false;box:CaptureFocus()
end)
sI[i]=itm
end
local pL
local cLF,scroll,searchBox
local function ensureCmdList()
if cLF then return end
cLF=_N("Frame",sg)
cLF.Size=_U(0,300,0,380);cLF.Position=_U(0.5,0,0.5,0)
cLF.AnchorPoint=Vector2.new(0.5,0.5);cLF.BackgroundColor3=_C(25,25,25)
cLF.Visible=false;cLF.Active=true
_N("UICorner",cLF).CornerRadius=UDim.new(0,8)
local sL=_N("UIStroke",cLF);sL.Color=_C(0,170,255);sL.Thickness=2
local tB=_N("Frame",cLF)
tB.Size=_U(1,0,0,40);tB.BackgroundColor3=_C(20,20,20)
_N("UICorner",tB).CornerRadius=UDim.new(0,8)
local tFix=_N("Frame",tB)
tFix.Size=_U(1,0,0.5,0);tFix.Position=_U(0,0,0.5,0);tFix.BackgroundColor3=_C(20,20,20);tFix.BorderSizePixel=0
makeDraggable(cLF,tB)
local titleText=_N("TextLabel",tB)
titleText.Size=_U(1,-40,1,0);titleText.Position=_U(0,15,0,0);titleText.BackgroundTransparency=1
titleText.Text="Command List";titleText.TextColor3=_C(0,170,255);titleText.Font=_GB
titleText.TextSize=16;titleText.TextXAlignment=_TX.Left
local cBtn=_N("TextButton",tB)
cBtn.Size=_U(0,30,0,30);cBtn.Position=_U(1,-35,0,5);cBtn.BackgroundTransparency=1
cBtn.Text="❌";cBtn.TextSize=14;cBtn.Font=_G
searchBox=_N("TextBox",cLF)
searchBox.Size=_U(1,-20,0,28);searchBox.Position=_U(0,10,0,44);searchBox.BackgroundColor3=_C(35,35,35)
searchBox.BorderSizePixel=0;searchBox.PlaceholderText="🔍 cari command...";searchBox.PlaceholderColor3=_C(100,100,100)
searchBox.Text="";searchBox.TextColor3=_C(220,220,220);searchBox.Font=_GS;searchBox.TextSize=13;searchBox.ClearTextOnFocus=false
_N("UICorner",searchBox).CornerRadius=UDim.new(0,6)
_N("UIPadding",searchBox).PaddingLeft=UDim.new(0,8)
scroll=_N("ScrollingFrame",cLF)
scroll.Size=_U(1,-20,1,-82);scroll.Position=_U(0,10,0,78);scroll.BackgroundTransparency=1
scroll.ScrollBarThickness=4;scroll.CanvasSize=_U(0,0,0,0);scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.ScrollBarImageColor3=_C(0,170,255)
local listLayout=_N("UIListLayout",scroll);listLayout.Padding=UDim.new(0,5);listLayout.SortOrder=Enum.SortOrder.LayoutOrder
cBtn.MouseButton1Click:Connect(function()cLF.Visible=false end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()pL(string.lower(searchBox.Text))end)
end
local COLOR_ON=_C(80,220,120);local COLOR_OFF=_C(220,70,70)
local function makeHUD(lbl,defaultSpd,startFn,stopFn,yOff)
local active,spd,expanded=false,defaultSpd,false
local tw=TweenInfo.new(0.15,Enum.EasingStyle.Quad)
local fr,stroke,nameLabel,speedLabel,toggleBtn,inputRow,inputBox
local built=false
local applySpeed,setExpanded,setA
local function build()
if built then return end;built=true
fr=_N("Frame",sg);fr.Size=_U(0,130,0,44);fr.Position=_U(1,-146,0,20+yOff)
fr.BackgroundColor3=_C(22,22,22);fr.BorderSizePixel=0;fr.Active=true
fr.Visible=false;fr.ClipsDescendants=true
_N("UICorner",fr).CornerRadius=UDim.new(0,12)
stroke=_N("UIStroke",fr);stroke.Color=COLOR_ON;stroke.Thickness=2
nameLabel=_N("TextLabel",fr);nameLabel.Size=_U(1,-64,0,44);nameLabel.Position=_U(0,10,0,0)
nameLabel.BackgroundTransparency=1;nameLabel.Text=lbl;nameLabel.TextColor3=COLOR_ON
nameLabel.Font=_GB;nameLabel.TextSize=16;nameLabel.TextXAlignment=_TX.Left;nameLabel.TextYAlignment=Enum.TextYAlignment.Center
speedLabel=_N("TextLabel",fr);speedLabel.Size=_U(0,36,0,44);speedLabel.Position=_U(1,-60,0,0)
speedLabel.BackgroundTransparency=1;speedLabel.Text=tostring(spd);speedLabel.TextColor3=_C(140,140,140)
speedLabel.Font=_GB;speedLabel.TextSize=11;speedLabel.TextXAlignment=_TX.Center;speedLabel.TextYAlignment=Enum.TextYAlignment.Center
toggleBtn=_N("TextButton",fr);toggleBtn.Size=_U(0,22,0,22);toggleBtn.Position=_U(1,-26,0,11)
toggleBtn.BackgroundColor3=_C(45,45,45);toggleBtn.BorderSizePixel=0;toggleBtn.Text="+"
toggleBtn.TextColor3=_C(200,200,200);toggleBtn.Font=_GB;toggleBtn.TextSize=13;toggleBtn.ZIndex=5
_N("UICorner",toggleBtn).CornerRadius=UDim.new(0,6)
inputRow=_N("Frame",fr);inputRow.Size=_U(1,-16,0,38);inputRow.Position=_U(0,8,0,50)
inputRow.BackgroundColor3=_C(32,32,32);inputRow.BorderSizePixel=0;inputRow.Visible=false
_N("UICorner",inputRow).CornerRadius=UDim.new(0,8);_N("UIStroke",inputRow).Color=_C(60,60,80)
inputBox=_N("TextBox",inputRow);inputBox.Size=_U(1,-16,1,-8);inputBox.Position=_U(0,8,0,4)
inputBox.BackgroundTransparency=1;inputBox.Text=tostring(spd);inputBox.TextColor3=_C(230,230,230)
inputBox.Font=_GB;inputBox.TextSize=15;inputBox.TextXAlignment=_TX.Center;inputBox.PlaceholderText="speed"
local cA=_N("TextButton",fr);cA.Size=_U(1,-36,0,44);cA.Position=_U(0,0,0,0)
cA.BackgroundTransparency=1;cA.Text="";cA.ZIndex=2
makeDraggable(fr,cA)
local _th=false
toggleBtn.MouseButton1Click:Connect(function()_th=true;setExpanded(not expanded)end)
cA.MouseButton1Click:Connect(function()
if _th then _th=false;return end
active=not active
local col=active and COLOR_ON or COLOR_OFF
ts:Create(stroke,tw,{Color=col}):Play();ts:Create(nameLabel,tw,{TextColor3=col}):Play()
if active then startFn(spd)else stopFn()end
if not active and expanded then setExpanded(false)end
end)
inputBox.FocusLost:Connect(function()
applySpeed(inputBox.Text)
if tonumber(inputBox.Text)==nil or tonumber(inputBox.Text)<1 then inputBox.Text=tostring(spd)end
end)
end
applySpeed=function(val)
local n=tonumber(val);if not n or n<1 then return end
spd=n;speedLabel.Text=tostring(spd);inputBox.Text=tostring(spd)
if active then startFn(spd)end
end
setExpanded=function(state)
expanded=state;toggleBtn.Text=state and"-"or"+"
if state then
ts:Create(fr,tw,{Size=_U(0,130,0,98)}):Play()
task.delay(0.15,function()inputRow.Visible=true end)
else
inputRow.Visible=false;ts:Create(fr,tw,{Size=_U(0,130,0,44)}):Play()
end
end
setA=function(state,doShow)
active=state
if doShow then fr.Visible=true end
if not state then
fr.Visible=false;if expanded then setExpanded(false)end;stopFn();return
end
startFn(spd)
end
return{
show=function(spd)
build()
if spd then spd=math.max(1,spd);speedLabel.Text=tostring(spd);inputBox.Text=tostring(spd)end
setA(true,true)
end,
hide=function()if not built then return end;setA(false,false)end,
}
end
local function makeToggleHUD(lbl,startFn,stopFn,yOff)
local active=false
local tw=TweenInfo.new(0.15,Enum.EasingStyle.Quad)
local fr,stroke,nameLabel
local built=false
local function build()
if built then return end;built=true
fr=_N("Frame",sg);fr.Size=_U(0,100,0,40);fr.Position=_U(1,-120,0,20+yOff)
fr.BackgroundColor3=_C(22,22,22);fr.BorderSizePixel=0;fr.Active=true;fr.Visible=false
_N("UICorner",fr).CornerRadius=UDim.new(0,12)
stroke=_N("UIStroke",fr);stroke.Color=COLOR_ON;stroke.Thickness=2
nameLabel=_N("TextLabel",fr);nameLabel.Size=_U(1,0,1,0);nameLabel.BackgroundTransparency=1
nameLabel.Text=lbl;nameLabel.TextColor3=COLOR_ON;nameLabel.Font=_GB;nameLabel.TextSize=16;nameLabel.TextXAlignment=_TX.Center
local E=14
for _,ed in ipairs({{_U(1,0,0,E),_U(0,0,0,0)},{_U(1,0,0,E),_U(0,0,1,-E)},{_U(0,E,1,0),_U(0,0,0,0)},{_U(0,E,1,0),_U(1,-E,0,0)}})do
local strip=_N("TextButton",fr);strip.Size=ed[1];strip.Position=ed[2]
strip.BackgroundTransparency=1;strip.Text="";strip.AutoButtonColor=false;strip.ZIndex=3
makeDraggable(fr,strip)
end
local cA=_N("TextButton",fr);cA.Size=_U(1,-8,1,-8);cA.Position=_U(0,4,0,4)
cA.BackgroundTransparency=1;cA.Text="";cA.ZIndex=2
makeDraggable(fr,cA)
local _th=false
cA.MouseButton1Click:Connect(function()
if _th then _th=false;return end
active=not active
local col=active and COLOR_ON or COLOR_OFF
ts:Create(stroke,tw,{Color=col}):Play();ts:Create(nameLabel,tw,{TextColor3=col}):Play()
if active then startFn()else stopFn()end
end)
end
return{
show=function()
build();active=true;fr.Visible=true
stroke.Color=COLOR_ON;nameLabel.TextColor3=COLOR_ON;startFn()
end,
hide=function()
if not built then return end
active=false;fr.Visible=false;stopFn()
end,
showOff=function()
build();active=false;fr.Visible=true
stroke.Color=COLOR_OFF;nameLabel.TextColor3=COLOR_OFF
end,
destroy=function()
if fr then fr:Destroy();fr=nil end;built=false
end,
}
end
local DC=D
local cmds=D.Cmds
local hudMap={}
local hudYOffset=0
for _,ent in ipairs(cmds)do
if ent.hud then
local alias0=ent.aliases[1]
local lbl=ent.hudLabel or(alias0:sub(1,1):upper()..alias0:sub(2))
local hud
if ent.hud=="speed"then
hud=makeHUD(lbl,ent.hudDefault or 50,
function(spd)if DC[ent.hudStart]then DC[ent.hudStart](spd)end end,
function()if DC[ent.hudStop]then DC[ent.hudStop]()end end,
hudYOffset)
hudYOffset+=80
elseif ent.hud=="toggle"then
hud=makeToggleHUD(lbl,
function()if DC[ent.hudStart]then DC[ent.hudStart]()end end,
function()if DC[ent.hudStop]then DC[ent.hudStop]()end end,
hudYOffset)
hudYOffset+=50
end
if hud then
if ent.hudOn then
local ons=type(ent.hudOn)=="table"and ent.hudOn or{ent.hudOn}
for _,a in ipairs(ons)do hudMap[a]={hud=hud,action="show",isSpeed=ent.hud=="speed"}end
end
if ent.hudOff then
local offs=type(ent.hudOff)=="table"and ent.hudOff or{ent.hudOff}
for _,a in ipairs(offs)do hudMap[a]={hud=hud,action="hide"}end
end
end
end
end
local aliasLookup={}
for _,ent in ipairs(cmds)do
local lbl=table.concat(ent.aliases,"/")
for _,alias in ipairs(ent.aliases)do aliasLookup[alias]=ent end
end
local function updateSugg(txt)
if txt==""then sF.Visible=false;return end
local count=0;local tl=#txt;local seen={}
for _,ent in ipairs(cmds)do
for _,alias in ipairs(ent.aliases)do
if string.sub(alias,1,tl)==txt then
local lbl=table.concat(ent.aliases,"/")
if not seen[lbl]then
seen[lbl]=true;count+=1
sI[count].Text=ent.args and(lbl.." "..ent.args)or lbl
sI[count].Visible=true
if count>=MS then break end
end
break
end
end
if count>=MS then break end
end
if count==0 then sF.Visible=false;return end
for i=count+1,MS do sI[i].Text="";sI[i].Visible=false end
sF.Size=_U(0,320,0,count*ITEM_H+(count-1)*IP);sF.Visible=true
end
pL=function(filter)
for _,child in ipairs(scroll:GetChildren())do if child:IsA("TextLabel")then child:Destroy()end end
local i=1;local seen={}
for _,ent in ipairs(cmds)do
local lbl=table.concat(ent.aliases,"/")
if not seen[lbl]then
seen[lbl]=true
local show=filter==nil or filter==""or string.find(lbl,filter,1,true)
if show then
local itm=_N("TextLabel",scroll);itm.Size=_U(1,-10,0,25);itm.BackgroundTransparency=1
itm.Text=i..". "..(ent.args and(lbl.." "..ent.args)or lbl)
itm.TextColor3=_C(255,255,255);itm.Font=_GS;itm.TextSize=14;itm.TextXAlignment=_TX.Left;itm.LayoutOrder=i
i+=1
end
end
end
end
local function runCommand(inp)
local args={}
for word in string.gmatch(inp,"%S+")do args[#args+1]=word:gsub(",","")end
if#args==0 then return end
local c=args[1]
if c=="commands"or c=="cmds"then
ensureCmdList();searchBox.Text="";pL(nil);cLF.Visible=true;return
end
local h=hudMap[c]
if h then
if h.action=="show"then h.hud.show(h.isSpeed and tonumber(args[2])or nil)
else h.hud.hide()end
return
end
local ent=aliasLookup[c]
if ent and ent.fn then ent.fn(args[2],args[3],args[4])end
end
local cmdOpen=false
local function closeCmd(inp)
if not cmdOpen then return end
cmdOpen=false;box.Text="";sF.Visible=false
ts:Create(cF,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=_U(0,0,0,48)}):Play()
task.delay(0.25,function()cF.Visible=false;btnC.Visible=true end)
if inp and inp~=""then runCommand(inp)end
end
btn.MouseButton1Click:Connect(function()
if cmdOpen then return end
cmdOpen=true;btnC.Visible=false;cF.Visible=true;cF.Size=_U(0,0,0,48)
ts:Create(cF,TweenInfo.new(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=_U(0,260,0,38)}):Play()
task.delay(0.1,function()box:CaptureFocus()end)
end)
box:GetPropertyChangedSignal("Text"):Connect(function()
local txt=string.lower(box.Text)
if string.find(txt," ")then sF.Visible=false else updateSugg(txt)end
end)
box.FocusLost:Connect(function(enter)
if cS then return end
local inp=string.lower(box.Text)
if not enter and inp==""then closeCmd(nil);return end
closeCmd(inp)
end)
D.runCmd=runCommand
local dynamicHuds={}
D.addButton=function(alias)
if dynamicHuds[alias]then return end
local ent=aliasLookup[alias];if not ent or not ent.fn then return end
local lbl=alias:sub(1,1):upper()..alias:sub(2)
local stopFn=function()end
local unEntry=aliasLookup["un"..alias];if unEntry and unEntry.fn then stopFn=unEntry.fn end
local hud=makeToggleHUD(lbl,function()ent.fn()end,stopFn,hudYOffset)
hudYOffset+=50;hud.showOff();dynamicHuds[alias]=hud
end
D.removeButton=function(alias)
local hud=dynamicHuds[alias];if not hud then return end
hud.destroy();dynamicHuds[alias]=nil
end]=])();l([=[local D=_G.__DeltaCmds
repeat task.wait()until D and D.Cmds and D.Pickers
local ts=game:GetService("TweenService")
local _C=Color3.fromRGB
local _U=UDim2.new
local _N=Instance.new
local _GB=Enum.Font.GothamBold
local _GS=Enum.Font.GothamSemibold
local sg=_N("ScreenGui",game.CoreGui)
sg.Name="DeltaGui2";sg.ResetOnSpawn=false;sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;sg.IgnoreGuiInset=true
local pickerOpen=false
local warnOpen=false
local overlay,pickerFrame,titleLabel,subtitleLabel,cBtn,btnC
local pickerBuilt=false
local function buildPicker()
if pickerBuilt then return end;pickerBuilt=true
overlay=_N("Frame",sg)
overlay.Size=_U(1,0,1,0);overlay.BackgroundTransparency=1;overlay.BackgroundColor3=_C(0,0,0)
overlay.ZIndex=20;overlay.Visible=false
pickerFrame=_N("Frame",overlay)
pickerFrame.Size=_U(0,0,0,0);pickerFrame.Position=_U(0.5,0,0.42,0);pickerFrame.AnchorPoint=Vector2.new(0.5,0.5)
pickerFrame.BackgroundColor3=_C(13,13,18);pickerFrame.ClipsDescendants=true;pickerFrame.ZIndex=21
_N("UICorner",pickerFrame).CornerRadius=UDim.new(0,16)
local pfStroke=_N("UIStroke",pickerFrame);pfStroke.Color=_C(0,170,255);pfStroke.Thickness=1.5
local pfGrad=_N("UIGradient",pickerFrame)
pfGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,_C(20,20,30)),ColorSequenceKeypoint.new(1,_C(13,13,18))}
pfGrad.Rotation=90
titleLabel=_N("TextLabel",pickerFrame);titleLabel.Size=_U(1,-40,0,36);titleLabel.BackgroundTransparency=1
titleLabel.Text="";titleLabel.TextColor3=_C(255,255,255);titleLabel.Font=_GB;titleLabel.TextSize=13;titleLabel.ZIndex=22
local titleGrad=_N("UIGradient",titleLabel)
titleGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,_C(255,255,255)),ColorSequenceKeypoint.new(1,_C(0,170,255))}
cBtn=_N("TextButton",pickerFrame);cBtn.Size=_U(0,26,0,26);cBtn.Position=_U(1,-32,0,5)
cBtn.AnchorPoint=Vector2.new(1,0);cBtn.BackgroundColor3=_C(50,15,15);cBtn.Text="✕"
cBtn.TextColor3=_C(255,80,80);cBtn.Font=_GB;cBtn.TextSize=13;cBtn.AutoButtonColor=false;cBtn.ZIndex=26
_N("UICorner",cBtn).CornerRadius=UDim.new(0,8)
local cTw=TweenInfo.new(0.12)
cBtn.MouseEnter:Connect(function()ts:Create(cBtn,cTw,{BackgroundColor3=_C(90,20,20)}):Play()end)
cBtn.MouseLeave:Connect(function()ts:Create(cBtn,cTw,{BackgroundColor3=_C(50,15,15)}):Play()end)
local divider=_N("Frame",pickerFrame);divider.Size=_U(1,-32,0,1);divider.Position=_U(0,16,0,36)
divider.BackgroundColor3=_C(40,40,55);divider.BorderSizePixel=0;divider.ZIndex=22
btnC=_N("Frame",pickerFrame);btnC.Size=_U(1,-32,0,70);btnC.Position=_U(0,16,0,45)
btnC.BackgroundTransparency=1;btnC.ZIndex=22
local btnLayout=_N("UIListLayout",btnC)
btnLayout.FillDirection=Enum.FillDirection.Horizontal;btnLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment=Enum.VerticalAlignment.Center;btnLayout.Padding=UDim.new(0,14)
subtitleLabel=_N("TextLabel",pickerFrame);subtitleLabel.Size=_U(1,0,0,20);subtitleLabel.Position=_U(0,0,1,-22)
subtitleLabel.BackgroundTransparency=1;subtitleLabel.Text="";subtitleLabel.TextColor3=_C(60,60,80)
subtitleLabel.Font=_GS;subtitleLabel.TextSize=10;subtitleLabel.ZIndex=22
end
local function makePickerBtn(parent,lbl,sub,accent)
local btn=_N("TextButton",parent);btn.Size=_U(0,148,0,62);btn.BackgroundColor3=_C(18,18,26)
btn.AutoButtonColor=false;btn.Text="";btn.ZIndex=23
_N("UICorner",btn).CornerRadius=UDim.new(0,12)
local bs=_N("UIStroke",btn);bs.Color=accent;bs.Thickness=1.2
local icon=_N("TextLabel",btn);icon.Size=_U(1,0,0,28);icon.Position=_U(0,0,0,8)
icon.BackgroundTransparency=1;icon.Text=lbl;icon.TextColor3=_C(255,255,255);icon.Font=_GB;icon.TextSize=12;icon.ZIndex=24
local subL=_N("TextLabel",btn);subL.Size=_U(1,-16,0,18);subL.Position=_U(0,8,0,34)
subL.BackgroundTransparency=1;subL.Text=sub;subL.TextColor3=_C(120,120,140);subL.Font=_GS;subL.TextSize=10;subL.ZIndex=24
local bar=_N("Frame",btn);bar.Size=_U(1,-24,0,2);bar.Position=_U(0,12,1,-10)
bar.BackgroundColor3=accent;bar.BorderSizePixel=0;bar.ZIndex=24
_N("UICorner",bar).CornerRadius=UDim.new(1,0)
local tw=TweenInfo.new(0.15)
btn.MouseEnter:Connect(function()ts:Create(btn,tw,{BackgroundColor3=_C(24,24,36)}):Play();ts:Create(bs,tw,{Thickness=2}):Play()end)
btn.MouseLeave:Connect(function()ts:Create(btn,tw,{BackgroundColor3=_C(18,18,26)}):Play();ts:Create(bs,tw,{Thickness=1.2}):Play()end)
return btn
end
local BTN_W,BTN_GAP,SIDE_PAD=148,14,32
local function calcWidth(n)return n*BTN_W+(n-1)*BTN_GAP+SIDE_PAD end
local function showPicker(pickerDef,callback)
if pickerOpen then return end
pickerOpen=true
buildPicker()
titleLabel.Text=pickerDef.title or"";subtitleLabel.Text=pickerDef.subtitle or""
for _,c in ipairs(btnC:GetChildren())do if c:IsA("TextButton")then c:Destroy()end end
local items={}
for _,def in ipairs(pickerDef.buttons)do
local b=makePickerBtn(btnC,def.lbl,def.sub,def.accent)
items[#items+1]={btn=b,val=def.val}
end
local TARGET=_U(0,calcWidth(#pickerDef.buttons),0,140)
overlay.Visible=true;pickerFrame.Size=_U(0,0,0,0)
ts:Create(overlay,TweenInfo.new(0.2),{BackgroundTransparency=0.6}):Play()
ts:Create(pickerFrame,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=TARGET}):Play()
local conns={}
local function pick(val)
if not pickerOpen then return end;pickerOpen=false
for _,c in ipairs(conns)do c:Disconnect()end
ts:Create(overlay,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
ts:Create(pickerFrame,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=_U(0,0,0,0)}):Play()
task.delay(0.28,function()overlay.Visible=false;callback(val)end)
end
conns[#conns+1]=cBtn.MouseButton1Click:Connect(function()pick(nil)end)
for _,itm in ipairs(items)do
local v=itm.val
conns[#conns+1]=itm.btn.MouseButton1Click:Connect(function()pick(v)end)
end
end
local warnOverlay,warnFrame,cancelBtn,continueBtn
local warnBuilt=false
local function buildWarn()
if warnBuilt then return end;warnBuilt=true
warnOverlay=_N("Frame",sg);warnOverlay.Size=_U(1,0,1,0);warnOverlay.BackgroundTransparency=1
warnOverlay.BackgroundColor3=_C(0,0,0);warnOverlay.ZIndex=30;warnOverlay.Visible=false
warnFrame=_N("Frame",warnOverlay);warnFrame.Size=_U(0,0,0,0);warnFrame.Position=_U(0.5,0,0.42,0)
warnFrame.AnchorPoint=Vector2.new(0.5,0.5);warnFrame.BackgroundColor3=_C(13,13,18)
warnFrame.ClipsDescendants=true;warnFrame.ZIndex=31
_N("UICorner",warnFrame).CornerRadius=UDim.new(0,16)
local wfStroke=_N("UIStroke",warnFrame);wfStroke.Color=_C(220,80,80);wfStroke.Thickness=1.5
local wfGrad=_N("UIGradient",warnFrame)
wfGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,_C(25,15,15)),ColorSequenceKeypoint.new(1,_C(13,13,18))}
wfGrad.Rotation=90
local warnIcon=_N("TextLabel",warnFrame);warnIcon.Size=_U(1,0,0,40);warnIcon.Position=_U(0,0,0,16)
warnIcon.BackgroundTransparency=1;warnIcon.Text="⚠";warnIcon.TextColor3=_C(255,180,0)
warnIcon.Font=_GB;warnIcon.TextSize=28;warnIcon.ZIndex=32
local warnTitle=_N("TextLabel",warnFrame);warnTitle.Size=_U(1,-32,0,22);warnTitle.Position=_U(0,16,0,58)
warnTitle.BackgroundTransparency=1;warnTitle.Text="HOOK WARNING";warnTitle.TextColor3=_C(255,80,80)
warnTitle.Font=_GB;warnTitle.TextSize=13;warnTitle.TextXAlignment=Enum.TextXAlignment.Center;warnTitle.ZIndex=32
local wfTitleGrad=_N("UIGradient",warnTitle)
wfTitleGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,_C(255,100,100)),ColorSequenceKeypoint.new(1,_C(255,60,60))}
local warnDivider=_N("Frame",warnFrame);warnDivider.Size=_U(1,-32,0,1);warnDivider.Position=_U(0,16,0,86)
warnDivider.BackgroundColor3=_C(80,30,30);warnDivider.BorderSizePixel=0;warnDivider.ZIndex=32
local warnBody=_N("TextLabel",warnFrame);warnBody.Size=_U(1,-32,0,80);warnBody.Position=_U(0,16,0,96)
warnBody.BackgroundTransparency=1
warnBody.Text="This script uses hooking methods that may\nbe detected by some games.\n\nYour account could be at risk. It is\nrecommended to test this using an\nalternate account first."
warnBody.TextColor3=_C(200,180,180);warnBody.Font=_GS;warnBody.TextSize=12
warnBody.TextXAlignment=Enum.TextXAlignment.Center;warnBody.TextWrapped=true;warnBody.ZIndex=32
local warnBtnRow=_N("Frame",warnFrame);warnBtnRow.Size=_U(1,-32,0,42);warnBtnRow.Position=_U(0,16,0,184)
warnBtnRow.BackgroundTransparency=1;warnBtnRow.ZIndex=32
local wbLayout=_N("UIListLayout",warnBtnRow)
wbLayout.FillDirection=Enum.FillDirection.Horizontal;wbLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
wbLayout.VerticalAlignment=Enum.VerticalAlignment.Center;wbLayout.Padding=UDim.new(0,12)
local function makeWarnBtn(lbl,bg,fg)
local btn=_N("TextButton",warnBtnRow);btn.Size=_U(0,130,0,36);btn.BackgroundColor3=bg
btn.AutoButtonColor=false;btn.Text=lbl;btn.TextColor3=fg;btn.Font=_GB;btn.TextSize=13;btn.ZIndex=33
_N("UICorner",btn).CornerRadius=UDim.new(0,10)
local tw=TweenInfo.new(0.12)
local darken=_C(bg.R*200,bg.G*200,bg.B*200)
btn.MouseEnter:Connect(function()ts:Create(btn,tw,{BackgroundColor3=darken}):Play()end)
btn.MouseLeave:Connect(function()ts:Create(btn,tw,{BackgroundColor3=bg}):Play()end)
return btn
end
cancelBtn=makeWarnBtn("Cancel",_C(35,35,45),_C(180,180,200))
continueBtn=makeWarnBtn("Continue",_C(180,40,40),_C(255,255,255))
end
local function showHookWarn(callback)
if warnOpen then return end;warnOpen=true
buildWarn()
warnOverlay.Visible=true;warnFrame.Size=_U(0,0,0,0)
ts:Create(warnOverlay,TweenInfo.new(0.2),{BackgroundTransparency=0.55}):Play()
ts:Create(warnFrame,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=_U(0,320,0,240)}):Play()
local conns={}
local function close(proceed)
if not warnOpen then return end;warnOpen=false
for _,c in ipairs(conns)do c:Disconnect()end
ts:Create(warnOverlay,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
ts:Create(warnFrame,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=_U(0,0,0,0)}):Play()
task.delay(0.25,function()warnOverlay.Visible=false;if proceed then callback()end end)
end
conns[#conns+1]=continueBtn.MouseButton1Click:Connect(function()close(true)end)
conns[#conns+1]=cancelBtn.MouseButton1Click:Connect(function()close(false)end)
end
local _startAutoClick
local function makeACGui()
local UIS,GS=game:GetService("UserInputService"),game:GetService("GuiService")
local pl=D and D.plr or game:GetService("Players").LocalPlayer
if pl.PlayerGui:FindFirstChild("AC_Panel")then pl.PlayerGui.AC_Panel:Destroy()end
local ac=D.AC;if not ac then return end
local function mk(c,pa,r)local o=_N(c,pa)for k,v in pairs(r or{})do o[k]=v end return o end
local function cor(p,r)mk("UICorner",p,{CornerRadius=UDim.new(0,r or 6)})end
local function str(p,c,t)mk("UIStroke",p,{Color=c,Thickness=t or 1})end
local SG=mk("ScreenGui",pl.PlayerGui,{Name="AC_Panel",ResetOnSpawn=false})
local F=mk("Frame",SG,{Size=_U(0,180,0,195),Position=_U(0.5,-90,0.5,-97),BackgroundColor3=_C(25,25,25),Active=true,Draggable=true})
cor(F,8);str(F,_C(0,170,255),2)
mk("TextLabel",F,{Size=_U(1,0,0,30),BackgroundTransparency=1,Text="AUTO CLICKER",TextColor3=_C(0,170,255),Font=_GB,TextSize=14})
local X=mk("TextButton",F,{Size=_U(0,30,0,30),Position=_U(1,-30,0,0),BackgroundTransparency=1,Text="❌",TextSize=11,TextColor3=_C(200,200,200)})
mk("Frame",F,{Size=_U(1,0,0,1),Position=_U(0,0,0,30),BackgroundColor3=_C(0,170,255),BorderSizePixel=0})
local GS2=Enum.Font.GothamSemibold
local MB=mk("TextButton",F,{Size=_U(0.9,0,0,25),Position=_U(0.05,0,0,40),BackgroundColor3=_C(35,35,35),Text="Mode: Mobile",TextColor3=_C(255,255,255),Font=GS2,TextSize=13})
cor(MB);local mS=mk("UIStroke",MB,{Color=_C(100,100,100),Thickness=1})
local SB=mk("TextBox",F,{Size=_U(0.9,0,0,25),Position=_U(0.05,0,0,72),BackgroundColor3=_C(20,20,20),Text="0.3",PlaceholderText="Delay (0.3)",TextColor3=_C(220,220,220),Font=GS2,TextSize=13})
cor(SB);str(SB,_C(60,60,80))
local PB=mk("TextButton",F,{Size=_U(0.9,0,0,32),Position=_U(0.05,0,0,105),BackgroundColor3=_C(35,35,35),Text="Set Target",TextColor3=_C(220,220,220),Font=GS2,TextSize=13})
cor(PB)
local S=mk("TextButton",F,{Size=_U(0.9,0,0,36),Position=_U(0.05,0,0,145),BackgroundColor3=_C(220,70,70),Text="OFF",TextColor3=_C(255,255,255),Font=_GB,TextSize=18})
cor(S);local bS=mk("UIStroke",S,{Color=_C(220,70,70),Thickness=1.5})
local M=mk("Frame",SG,{Size=_U(0,14,0,14),BackgroundColor3=_C(80,220,120),Visible=false,AnchorPoint=Vector2.new(0.5,0.5)})
cor(M,99);str(M,_C(0,0,0))
local picking=false
X.MouseButton1Click:Connect(function()ac.active=false;SG:Destroy()end)
MB.MouseButton1Click:Connect(function()ac.mode=ac.mode=="Mobile"and"PC"or"Mobile";MB.Text="Mode: "..ac.mode;mS.Color=ac.mode=="PC"and _C(0,170,255)or _C(100,100,100)end)
SB.FocusLost:Connect(function()local v=tonumber(SB.Text);ac.delay=(v and v>=0)and v or ac.delay;SB.Text=tostring(ac.delay)end)
PB.MouseButton1Click:Connect(function()picking=true;PB.Text="Tap/Click Target...";PB.TextColor3=_C(0,170,255)end)
UIS.InputBegan:Connect(function(i,g)
if picking and not g and(i.UserInputType.Name=="Touch"or i.UserInputType.Name=="MouseButton1")then
ac.tgt=Vector2.new(i.Position.X,i.Position.Y+GS:GetGuiInset().Y)
M.Position=_U(0,i.Position.X,0,i.Position.Y);M.Visible=true;picking=false
PB.Text="Target Locked";PB.TextColor3=_C(220,220,220)
end
end)
S.MouseButton1Click:Connect(function()
ac.active=not ac.active
S.Text=ac.active and"ON"or"OFF"
S.BackgroundColor3=ac.active and _C(80,220,120)or _C(220,70,70)
bS.Color=ac.active and _C(80,220,120)or _C(220,70,70)
if ac.active and _startAutoClick then _startAutoClick()end
end)
end
local function _hookAC()
for _,e in ipairs(D.Cmds)do for _,a in ipairs(e.aliases)do
if a=="autoclicker"then _startAutoClick=e.fn;local o=e.fn;e.fn=function()makeACGui();o()end;return end
end end
end
_hookAC()
local function makeStatsGui()
local ST=game:GetService("Stats")
local pl=D and D.plr or game:GetService("Players").LocalPlayer
if pl.PlayerGui:FindFirstChild("HUD_All")then pl.PlayerGui.HUD_All:Destroy()end
local function mk(c,pa,r)local o=_N(c,pa)for k,v in pairs(r or{})do o[k]=v end return o end
local SG=mk("ScreenGui",pl.PlayerGui,{Name="HUD_All",ResetOnSpawn=false})
local F=mk("Frame",SG,{Size=_U(0,150,0,24),Position=_U(0.5,-75,0,20),BackgroundColor3=_C(15,15,20),Active=true,Draggable=true})
mk("UICorner",F,{CornerRadius=UDim.new(0,6)});mk("UIStroke",F,{Color=_C(0,170,255),Thickness=1.5})
local T=mk("TextLabel",F,{Size=_U(1,-24,1,0),Position=_U(0,8,0,0),BackgroundTransparency=1,TextColor3=_C(0,170,255),Font=_GB,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
local X=mk("TextButton",F,{Size=_U(0,24,1,0),Position=_U(1,-24,0,0),BackgroundTransparency=1,Text="❌",TextSize=9,TextColor3=_C(200,200,200)})
X.MouseButton1Click:Connect(function()SG:Destroy()end)
local c;c=game:GetService("RunService").RenderStepped:Connect(function(d)
if not T.Parent then c:Disconnect();return end
local ping="0"
pcall(function()ping=string.match(ST.Network.ServerStatsItem["Data Ping"]:GetValueString(),"%d+")or"0"end)
T.Text="FPS: "..math.round(1/d).." | Ping: "..ping.."ms"
end)
end
local function _hookStats()
for _,e in ipairs(D.Cmds)do for _,a in ipairs(e.aliases)do
if a=="stats"then local o=e.fn;e.fn=function()makeStatsGui();o()end;return end
end end
end
_hookStats()
D.showHookWarn=showHookWarn
local aliasMap={}
for _,ent in ipairs(D.Cmds)do
for _,alias in ipairs(ent.aliases)do aliasMap[alias]=ent end
end
for _,pickerDef in ipairs(D.Pickers)do
local cmdEntry=aliasMap[pickerDef.cmdAlias]
if cmdEntry then
local origFn=cmdEntry.fn
if pickerDef.hookOnValue then
cmdEntry.fn=function(...)
task.delay(0.32,function()
showPicker(pickerDef,function(val)
if val==nil then return end
if val==pickerDef.hookOnValue then showHookWarn(function()pickerDef.onPick(val)end)
else pickerDef.onPick(val)end
end)
end)
end
elseif cmdEntry.hook then
cmdEntry.fn=function(...)
local args={...}
showHookWarn(function()
if args[1]then origFn(table.unpack(args))
else
task.delay(0.32,function()
showPicker(pickerDef,function(val)
if val~=nil then pickerDef.onPick(val)end
end)
end)
end
end)
end
else
cmdEntry.fn=function()
task.delay(0.32,function()
showPicker(pickerDef,function(val)
if val~=nil then pickerDef.onPick(val)end
end)
end)
end
end
end
if pickerDef.stopAlias and pickerDef.stopFn then
local stopEntry=aliasMap[pickerDef.stopAlias]
if stopEntry then stopEntry.fn=pickerDef.stopFn end
end
end
local pickerAliases={}
for _,pickerDef in ipairs(D.Pickers)do pickerAliases[pickerDef.cmdAlias]=true end
for _,ent in ipairs(D.Cmds)do
if ent.hook and ent.fn and not pickerAliases[ent.aliases[1]]then
local orig=ent.fn
ent.fn=function(...)local args={...};showHookWarn(function()orig(table.unpack(args))end)end
end
end]=])();