--[[This is the most important part]]
local DataBuild = [[
[{"Color":[163,162,165],"Mesh":{"MeshType":"Sphere","TextureId":"rbxassetid://1002700043","MeshId":"rbxassetid://1002732277","Scale":[0.3572930693626404,0.3583422005176544,0.35763266682624819]},"CreateMesh":[],"Size":{"CFrame":[-10.408689498901368,64.46949768066406,141.0092315673828,1,8.387733174686218e-8,-8.493734640069306e-7,-7.752147723749658e-8,1,-8.569735143737489e-8,8.493734640069306e-7,8.586988542447216e-8,1],"Size":[1.9539999961853028,7.939000129699707,2.3989999294281008]},"Surfaces":{"Top":"Studs"},"PartId":1}]
]]
local BuildDelay = 0.05 --[[delay on block (fast wifi = 0.05, slow wifi = 0.3)]]















local Player = game:GetService("Players").LocalPlayer
local Http = game:GetService("HttpService")
local DefaultParent = workspace
local RunService = game:GetService("RunService")
if Player == nil then
	error("[ERROR] Couldn't find Player. Please try again.")
end
local Character = Player.Character or Player.CharacterAdded:Wait()
local Library = {
	m = setmetatable({},{__index = function(self,name) 
		local ex,func = pcall(function(...) return math[...] end,name)
		if ex then
			self[name] = func
			return func
		end
	end}),
	DecodedData = Http:JSONDecode(DataBuild),
	MainInstance = DefaultParent,
	Log = {
		Do=true,
		Building = true,
		Count=0,
		Every=1/100, --[[in percentages]]
		Amount=0,
		Time=0.1,
		Timer = 0,
	},
	Decoding = {
		Color = "Color",
		Size = "Size",
		Material = "Material",
		Mesh = "Mesh",
		Lighting = "Lighting",
		Decoration = "Decorate",
		Surfaces = "Surfaces",
	},
	SyncName = {
		Size = "SyncResize",
		Color = "SyncColor",
		Material = "SyncMaterial",
		Anchor = "SyncAnchor",
		Collision = "SyncCollision",
		CreateMesh = "CreateMeshes",
		Mesh = "SyncMesh",
		Lights = "CreateLights",
		Lighting = "SyncLighting",
		Decorate = "CreateDecorations",
		Decoration = "SyncDecorate",
		Surfaces = "SyncSurface",
	},
	PartID = {"Normal", "Truss", "Wedge", "Corner", "Cylinder", "Ball", "Seat", "Vehicle Seat", "Spawn"},
	RDls = {CreateMesh=true,Lights=true,Decorate=true,Anchor=true,Collision=true},
	SendLimit = 1000, --[[Important! Do Not Modify Unless You Know What You Are Doing]]
	FTick = tick(),
	MainCheck = function()
		if _G.MainEvent == nil then
			_G.MainEvent = ReturnEvent()
		end
	end,
	BuildData = {},
}



function ReturnEvent()
	local Warner = 0
	local R2 = nil
	repeat 
		wait(Warner)
		Warner = 0.5+Warner
		if Warner > 0.5 then
			print("[AutoBuild] Stuck waiting for tool instance. Please insert Build Tool or main event instance.")
			Warner = 0.5
		end
		local function Search(tabl)
			for _,u1 in pairs(tabl:GetDescendants()) do
				if u1.Name == "SyncAPI" and u1:IsA("BindableFunction") then
					return u1
				end
			end
		end
		R2 = (
			Search(Character) or 
				Search(Player.Backpack)
		)
	until R2 ~= nil
	return R2:WaitForChild("ServerEndpoint")
end
_G.MainEvent = ReturnEvent()

function IndexlessReturn(Data)
	local Dat = {}
	for x,v in pairs(Data) do
		if type(x) ~= "number" then
			Dat[x] = v
		end
	end
	return Dat
end
function UnparseMethod(p1,p2)
	local function Return(...)
		return ..., IndexlessReturn(p2)
	end
	local Unparsers = {
		Color = function()
			return Return(Color3.new(p2[1]/255,p2[2]/255,p2[3]/255))
		end,
		Material = function()
			p2["Transparency"] = p2[2]
			p2["Reflectance"] = p2[3]
			return Return(p2[1] and Enum.Material[p2[1]] or Return(nil))
		end,
		Size = function()
			p2["CFrame"] = CFrame.new(unpack(p2["CFrame"]))
			return Return(Vector3.new(unpack(p2["Size"])))
		end,
		Mesh = function()
			p2["MeshType"] = (p2["MeshType"] and Enum.MeshType[p2["MeshType"]])
			p2["Scale"] = p2["Scale"] and Vector3.new(unpack(p2["Scale"]))
			p2["Offset"] = p2["Offset"] and Vector3.new(unpack(p2["Offset"]))
			p2["VertexColor"] = p2["VertexColor"] and Vector3.new(unpack(p2["VertexColor"]))
			return Return(nil)
		end,
		Surfaces = function()
			local p3 = {
				Back=p2["Back"] and Enum.SurfaceType[p2["Back"]],
				Bottom=p2["Bottom"] and Enum.SurfaceType[p2["Bottom"]],
				Front=p2["Front"] and Enum.SurfaceType[p2["Front"]],
				Left=p2["Left"] and Enum.SurfaceType[p2["Left"]],
				Right=p2["Right"] and Enum.SurfaceType[p2["Right"]],
				Top=p2["Top"] and Enum.SurfaceType[p2["Top"]],
			}
			p2["Back"] = nil;p2["Bottom"] = nil;p2["Front"] = nil;p2["Left"] = nil;p2["Right"] = nil;p2["Top"] = nil
			return Return(p3)
		end,
		Lighting = function()
			p2["Color"] = p2["Color"] and Color3.new(p2["Color"][1]/255,p2["Color"][2]/255,p2["Color"][3]/255)
			p2["Face"] = p2["Face"] and Enum.NormalId[p2["Face"]]
			return Return(nil)
		end,
		Decorate = function()
			p2["Color"] = p2["Color"] and Color3.new(p2["Color"][1]/255,p2["Color"][2]/255,p2["Color"][3]/255)
			p2["SecondaryColor"] = p2["SecondaryColor"] and Color3.new(p2["SecondaryColor"][1]/255,p2["SecondaryColor"][2]/255,p2["SecondaryColor"][3]/255)
			return Return(nil)
		end,
	}
	return Unparsers[p1]()
end
function FireServer(Arguments)
	local function SendEvent(...)
		_G.MainEvent:InvokeServer(...)
	end
	Library.MainCheck()
	if Arguments[1] == "CreatePart" then
		SendEvent(unpack(Arguments))
		return			
	end
	local function MultipleExecute(SyncEvent,List)
		SendEvent(
			SyncEvent,
			List
		)
		return
	end
	local function CatchAll(LN)
		local v1 = Library.BuildData[LN]
		if v1 == nil then
			return
		end
		local ct = #v1
		local Mul = 1000
		local vc = {}
		local lRn = Library.SyncName[LN]
		local sl = Library.SendLimit
		if ct > sl then
			for v2=1,ct do
				Library.MainCheck()
				table.insert(vc,v1[v2])
				if v2 >= Mul then
					MultipleExecute(lRn,vc)
					vc = {}
					Mul = Library.m.clamp(Mul + sl,0,ct)
					wait(BuildDelay+(sl*0.001))
				end
			end
			return
		end
		MultipleExecute(lRn,v1)
	end
	CatchAll(Arguments[1])
	return
end
function UnparseData(Data,DataName)
	local Decoded = Library.Decoding
	if Decoded[DataName] then
		local Unparsed,Up2 = UnparseMethod(Decoded[DataName],Data)
		Up2["Part"] = Data["Part"]
		Up2[DataName] = Unparsed
		return Up2
	else
		return IndexlessReturn(Data)
	end
end
function CollectTo(DataBase,DataPart)
	local B_D = Library.BuildData
	if not B_D[DataBase] then
		B_D[DataBase] = {}
	end
	table.insert(B_D[DataBase],DataPart)
end
function CollectPairPart(PartNum, DataValue, DataName)
	local UData = UnparseData(DataValue,DataName)
	CollectTo(DataName,UData)
end
function WatchForNewParts(NewPart)
	RunService.Heartbeat:Wait()
	if (NewPart:IsA("Part") or NewPart:IsA("WedgePart") or NewPart:IsA("CornerWedgePart") or NewPart:IsA("TrussPart") or NewPart:IsA("VehicleSeat") or NewPart:IsA("Seat")) and NewPart.CFrame == CFrame.new(0,0,0,1,0,0,0,1,0,0,0,1) then
		return NewPart
	end
end
function CreateInstancePart(part)
	local NewPart = nil
	local InternalTimer = 0
	local Conex=nil;Conex=Library.MainInstance.ChildAdded:Connect(function(...) 
		NewPart = WatchForNewParts(...)
	end)
	RunService.Heartbeat:Wait()
	FireServer({"CreatePart",Library.PartID[part["PartId"]],CFrame.new(Vector3.new(0,0,0)),Library.MainInstance})
	repeat RunService.Heartbeat:Wait(BuildDelay) InternalTimer=InternalTimer+BuildDelay if InternalTimer >2.5 then break end until NewPart ~= nil or Library.Log["Building"] == false
	Conex:Disconnect()
	if Library.Log["Building"] == false or NewPart == nil then
		error("Could not catch this part.")
	end
	return NewPart
end
if Library.DecodedData["BuildNote"] then
	warn("Started Constructing " .. Library.DecodedData["BuildNote"] .. ".")
	Library.DecodedData["BuildNote"] = nil
end
if Library.Log["Do"] then
	Library.Log["Amount"]=#Library.DecodedData;
	Library.Log["Every"] = (Library.m.floor(Library.Log["Every"]*100)/100)*Library.Log["Amount"];
	(coroutine.wrap((function() 
		while Library.Log["Building"] do
			Library.Log["Timer"] = Library.Log["Timer"] + BuildDelay
			RunService.Heartbeat:Wait(BuildDelay)
			if Library.m.clamp(BuildDelay*300,10,30) < Library.Log["Timer"] and Library.Log["Errored"] == nil then
				Library.Log["Errored"] = true
				warn("Stopped Building at Part Number " .. Library.Log["Count"])
				Library.Log["Building"] = false
			end
		end
	end)))()
end
function AddressDataPoint(Index,SingleData)
	if Library.Log["Building"] == false then
		return
	end
	local pass,MainPart = pcall(CreateInstancePart,SingleData)
	if not pass or type(MainPart) == "string" then
		warn(MainPart)
		AddressDataPoint(Index,SingleData)
		return
	end
	for datsel,collvalue in pairs(SingleData) do
		if type(collvalue) == "table" then
			local B_D = Library.BuildData
			if B_D[datsel] == nil then
				B_D[datsel] = {}
			end
			collvalue["Part"] = MainPart
			CollectPairPart(Index,collvalue,datsel)
		end
	end
	RunService.Heartbeat:Wait(BuildDelay)
	Library.Log["Count"] = Library.Log["Count"] + 1
	if Library.Log["Do"] and Library.m.clamp(Library.m.floor(Library.Log["Count"]%Library.Log["Every"]),0,1) == 0 then
		print("Completed Count: " .. Library.Log["Count"] .. "/" .. Library.Log["Amount"])
		print("Time Remaining Estimate: " .. Library.Log["Time"]*(Library.Log["Amount"]-Library.Log["Count"]))
		print("Took " .. Library.Log["Timer"] .. " to complete 1 task.")
	end
	Library.Log["Timer"] = 0
end
for n,p in pairs(Library.DecodedData) do
	if Library.Log["Building"] == false then
		break
	end
	Library.MainCheck()
	AddressDataPoint(n,p)
end
RunService.Heartbeat:Wait(BuildDelay)
Library.Log["Time"] = (Library.FTick-tick())+0.15
FireServer({"CreateMesh"})
RunService.Heartbeat:Wait(BuildDelay)
FireServer({"Lights"})
RunService.Heartbeat:Wait(BuildDelay)
FireServer({"Decorate"})
RunService.Heartbeat:Wait(BuildDelay)
for Bnum,_ in pairs(Library.BuildData) do
	if Library.RDls[Bnum]~=true then
		FireServer({[1]=Bnum})
		RunService.Heartbeat:Wait(BuildDelay)
	end
end
FireServer({"Collision"})
RunService.Heartbeat:Wait(BuildDelay)
FireServer({"Anchor"})
RunService.Heartbeat:Wait(BuildDelay)
warn("Finished in " .. Library.Log["Time"] .. " seconds.")
