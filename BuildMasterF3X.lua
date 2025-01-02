local Garbage = true
local PrintLog = false --[[ For Debugging ]]

local Workspace = game:GetService("Workspace")
local Http = game:GetService("HttpService")
local Build = Workspace.Build
local Debris = game:GetService("Debris")
local Defaults = game.ServerStorage:FindFirstChild("Default") or Instance.new("Folder",game.ServerStorage)
Defaults.Name = "Default"
-- Editd this for github.
local DDefaults = {"SpotLight","Fire","PointLight","Seat","Smoke","Sparkles","SpawnLocation","SpecialMesh","SpotLight","SurfaceLight","VehicleSeat","Part","CornerWedgePart","TrussPart","WedgePart"}
for i = 1, #DDefaults do
	local newInstance = Defaults:FindFirstChild(DDefaults[i]) or Instance.new(DDefaults[i],Defaults)
	if i==1 then
		newInstance.Name = "DefaultLight"
	end
end
local MeshPartToPartConversion = true --[[ Might not work all the time ]]
local fl = math.floor
local PartIds = {Block=1, TrussPart=2, WedgePart=3, CornerWedgePart=4, Cylinder=5, Ball=6, Seat=7, VehicleSeat=8, SpawnLocation=9}
local DataBuild = nil
local Blacklist = {MeshPart=true,UnionOperation=true}
local Whitelist = {TrussPart=true,Part=true,WedgePart=true,CornerWedgePart=true,Seat=true,VehicleSeat=true,SpawnLocation=true}
local FinishedTable = {}
local PartCount = 0
function IsNotDefault(In)
	local R1 = In[3][In[2]]
	if type(R1) == "boolean" and R1 == false then
		local R2 = (Defaults[In[1]][In[2]] == false)
		if R2 == true then
			return nil
		else
			return false
		end
	end
	return (Defaults[In[1]][In[2]] ~= In[3][In[2]] and R1) or nil
end
function RemoveItem(I)
	if Garbage then
		Debris:AddItem(I,0)
	else
		I.Parent = Build.G
	end
end
function SaveInst(MI,NE)
	local Ch = MI:GetChildren()
	for _,v1 in pairs(Ch) do
		v1.Parent = NE
	end
end
function FindChildren(I,IL)
	for _,v1 in pairs(IL) do
		local v2 = I:FindFirstChildOfClass(v1)
		if v2 then
			return v2
		end
	end
end
function MeshPartReplace(MP)
	if (MP:IsA("CylinderMesh") or MP:IsA("BlockMesh") or MP:IsA("SpecialMesh")) then
		local MDRDat = {
			P = MP.Parent,
			O = MP.Offset,
			S = MP.Scale,
			T = (MP.ClassName ~= "SpecialMesh" and string.find(MP.ClassName,"Mesh") and 
				Enum.PartType[string.gsub(MP.ClassName,"Mesh","")]) or
				Enum.PartType["Block"]
		}
		RemoveItem(MP)
		repeat wait() until MP == nil
		local NewMesh = MDRDat:Clone()
		NewMesh.Reflectance = MDRDat.P.Reflectance
		NewMesh.Transparency = MDRDat.P.Transparency
		NewMesh.Name = MDRDat.P.Name
		NewMesh.CanCollide = MDRDat.P.CanCollide
		NewMesh.Color = MDRDat.P.Color
		NewMesh.Anchored = MDRDat.P.Anchored
		NewMesh.Size = MDRDat.P.Size * MDRDat.S
		NewMesh.CFrame = MDRDat.P.CFrame
		NewMesh.Position = NewMesh.Position + MDRDat.O
		NewMesh.Parent = MDRDat.P.Parent
		NewMesh.Shape = MDRDat.T
		SaveInst(MDRDat.P,NewMesh)
		RemoveItem(MDRDat.P)
		return 
	end
	local MDt = {
		CF = MP.CFrame,
		S = MP.Size,
		A = MP.Anchored,
		C = MP.Color,
		C2 = MP.CanCollide,
		Mid = MP.MeshId,
		Tid = MP.TextureID,
		T = MP.Transparency,
		R = MP.Reflectance,
		N = MP.Name,
		P = MP.Parent,
		G = MP.MeshSize,
	}
	local NewMesh = Instance.new("Part",MDt.P)
	NewMesh.Reflectance = MDt.R
	NewMesh.Transparency = MDt.T
	NewMesh.Name = MDt.N
	NewMesh.Parent = MDt.P
	NewMesh.CanCollide = MDt.C2
	NewMesh.Color = MDt.C
	NewMesh.Anchored = MDt.A
	NewMesh.Size = MDt.S
	NewMesh.CFrame = MDt.CF
	SaveInst(MP,NewMesh)
	RemoveItem(MP)
	local ChildMesh = Instance.new("SpecialMesh",NewMesh)
	ChildMesh.TextureId = MDt.Tid
	ChildMesh.MeshId = MDt.Mid
	ChildMesh.Scale = MDt.S / MDt.G
	return NewMesh
end
function GetPT(p1)
	return p1.ClassName
end
function GetRegisteredID(p1)
	if GetPT(p1) == "Part" then
		return PartIds[p1.Shape.Name]
	elseif PartIds[tostring(GetPT(p1))] then
		return PartIds[tostring(GetPT(p1))]
	end
end
function AddToBuild(IT)
	table.insert(FinishedTable,IT)
end
if MeshPartToPartConversion then
	Blacklist["MeshPart"] = false
	Whitelist["MeshPart"] = true
end
for p1,p2 in pairs(Build:GetDescendants()) do
	local p3 = GetPT(p2)
	local SpecialMeshList = {
		"Cylinder","Brick","MeshPart","CylinderMesh","BlockMesh"
	}
	if Blacklist[p3] then
		print(p2, "is a blacklisted object, this will not be copied onto the final build.")
	end
	if ((table.find(SpecialMeshList,p3)) or (p2:IsA("SpecialMesh") and table.find(SpecialMeshList,p2.MeshType.Name))) and MeshPartToPartConversion then
		MeshPartReplace(p2)
		wait()
	end
end
for p1,p2 in pairs(Build:GetDescendants()) do
	local p3 = GetPT(p2)	
	if Whitelist[p3] then
		local t1 = GetRegisteredID(p2)
		local aobj = {}
		local function Insert(i1,i2)
			aobj[i1] = i2
		end
		local function Default(p4,p5,p6)
			return IsNotDefault({p6 or p3,p4,p5})
		end
		Insert("PartId",t1)
		Insert("Collision",{CanCollide=Default("CanCollide",p2)})
		Insert("Anchor",{Anchored=Default("Anchored",p2)})
		Insert("Size",{Size={p2.Size.X,p2.Size.Y,p2.Size.Z},CFrame={p2.CFrame:GetComponents()}})
		Insert("Material",{
			(Default("Material",p2) and Default("Material",p2).Name) or nil,
			Default("Transparency",p2),
			Default("Reflectance",p2),
		})
		Insert("Color",{fl(p2.Color.R*255),fl(p2.Color.G*255),fl(p2.Color.B*255)})
		Insert("Surfaces",{
			Back=Default("BackSurface",p2) and Default("BackSurface",p2).Name,
			Bottom=Default("BottomSurface",p2) and Default("BottomSurface",p2).Name,
			Front=Default("FrontSurface",p2) and Default("FrontSurface",p2).Name,
			Left=Default("LeftSurface",p2) and Default("LeftSurface",p2).Name,
			Right=Default("RightSurface",p2) and Default("RightSurface",p2).Name,
			Top=Default("TopSurface",p2) and Default("TopSurface",p2).Name,
		})
		for v1,v2 in pairs(aobj) do
			if type(v2) == "table" and Http:JSONEncode(v2) == "[]" then
				aobj[v1] = nil
			end
		end
		local Mesh = FindChildren(p2,{"SpecialMesh"})
		local Decoration = FindChildren(p2,{"Smoke","Fire","Sparkles"})
		local Lighting = FindChildren(p2,{"SpotLight","PointLight","SurfaceLight"})
		if Mesh then
			Insert("CreateMesh",{})
			Insert("Mesh",{
				MeshType=Default("MeshType",Mesh,"SpecialMesh") and Default("MeshType",Mesh,"SpecialMesh").Name,
				TextureId=Default("TextureId",Mesh,"SpecialMesh"),
				MeshId=Default("MeshId",Mesh,"SpecialMesh"),
				Offset=Default("Offset",Mesh,"SpecialMesh") and {Mesh.Offset.X,Mesh.Offset.Y,Mesh.Offset.Z},
				Scale=Default("Scale",Mesh,"SpecialMesh") and {Mesh.Scale.X,Mesh.Scale.Y,Mesh.Scale.Z},
				VertexColor = Default("VertexColor",Mesh,"SpecialMesh") and {Mesh.VertexColor.X,Mesh.VertexColor.Y,Mesh.VertexColor.Z},
			})
		end
		if Decoration then
			local Dpt = GetPT(Decoration)
			Insert("Decorate",{DecorationType=Dpt})
			Insert("Decoration",{
				Opacity=(Dpt == "Smoke" and Default("Opacity",Decoration,"Smoke") or nil),
				RiseVelocity=(Dpt == "Smoke" and Default("RiseVelocity",Decoration,"Smoke") or nil),
				SecondaryColor=(Dpt == "Fire" and {fl(Decoration.SecondaryColor.R*255),fl(Decoration.SecondaryColor.G*255),fl(Decoration.SecondaryColor.B*255)} or nil),
				Heat=(Dpt == "Fire" and Default("Heat",Decoration,"Fire") or nil),
				Size=(Dpt ~= "Sparkles" and Default("Size",Decoration,"Smoke") or nil),
				Color=(Dpt ~= "Sparkles" and {fl(Decoration.Color.R*255),fl(Decoration.Color.G*255),fl(Decoration.Color.B*255)} or nil),
				SparkleColor=(Dpt == "Sparkles" and {fl(Decoration.SparkleColor.R*255),fl(Decoration.SparkleColor.G*255),fl(Decoration.SparkleColor.B*255)} or nil),
			})
		end
		if Lighting then
			local Dpt = GetPT(Lighting)
			Insert("Lights",{LightType=Dpt})
			Insert("Lighting",{
				Angle=(Dpt ~= "PointLight" and Default("Angle",Lighting,"DefaultLight") or nil),
				Face=(Dpt ~= "PointLight" and (Default("Face",Lighting,"DefaultLight") and Default("Face",Lighting,"DefaultLight").Name) or nil),
				Shadows=Default("Shadows",Lighting,"DefaultLight"),
				Range=Default("Range",Lighting,"DefaultLight"),
				Brightness=Default("Brightness",Lighting,"DefaultLight"),
				Color={fl(Lighting.Color.R*255),fl(Lighting.Color.G*255),fl(Lighting.Color.B*255)},
			})
		end
		AddToBuild(aobj)
	end
end
if PrintLog then
	print(FinishedTable)
else
	DataBuild = Http:JSONEncode(FinishedTable)
	print(DataBuild)
end
