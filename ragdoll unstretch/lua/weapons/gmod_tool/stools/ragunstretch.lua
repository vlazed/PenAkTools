-- this whole thing is based on Winded's standing pose tool.
TOOL.Category		= "Poser"
TOOL.Name			= "Ragdoll Unstretch"
TOOL.Command		= nil
TOOL.ConfigName		= nil

if SERVER then

if game.SinglePlayer() then

	util.AddNetworkString("RagUnstretch_Server1")
	util.AddNetworkString("RagUnstretch_Client1")
	util.AddNetworkString("RagUnstretch_Server2")
	util.AddNetworkString("RagUnstretch_Client2")

	net.Receive("RagUnstretch_Server1", function(len, ply) 
		local rag = net.ReadEntity()
		local ent = net.ReadEntity()
		local PhysObjects = net.ReadInt(8)
		
		for i=0,PhysObjects do
			local phys = ent:GetPhysicsObjectNum(i)
			local pos = net.ReadVector()
			local ang = net.ReadAngle()
			phys:EnableMotion(false)
			phys:Wake()
			if i == 0 then
				phys:SetPos(pos) -- setting position only for the "base" bone, like pelvis. rest of bones should follow base one anyway, as i don't think there are ragdolls that are stretchy by default
			end
			phys:SetAngles(ang)
			phys:Wake()
		end
		timer.Simple(0.1, function()
			net.Start("RagUnstretch_Client2")
				net.WriteEntity(rag)
				net.WriteEntity(ent)
				net.WriteInt(PhysObjects, 8)
			net.Send(ply)
		end)
	end)

	net.Receive("RagUnstretch_Server2", function(len, ply) 
		local rag = net.ReadEntity()
		local ent = net.ReadEntity()
		local PhysObjects = net.ReadInt(8)
		
		for i=0, PhysObjects do
			local pos, ang
			if rag.UnstretchTable.Bones[i] == true then
				pos = net.ReadVector() -- gotta discard this stuff
				ang = net.ReadAngle()
				continue 
			end
			local phys = rag:GetPhysicsObjectNum(i)
			pos = net.ReadVector()
			ang = net.ReadAngle()
			phys:EnableMotion(false)
			phys:Wake()
			phys:SetPos(pos)
			phys:SetAngles(ang)
				
		end
		ent:Remove()
	end)
end

end

function TOOL:LeftClick(tr)
	
	if !IsValid(tr.Entity) then return false end
	if tr.Entity:GetClass() != "prop_ragdoll" then return false end
	
	if CLIENT then return true end

	local rag, ply = tr.Entity, self:GetOwner()
	if !rag.UnstretchTable then
		rag.UnstretchTable = { Bones = {} }
	end
	
	
	local ent = ents.Create("prop_ragdoll")
	ent:SetModel(rag:GetModel())
	ent:SetPos(rag:GetPos())
	ent:SetAngles(rag:GetAngles())
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:Spawn()
	local PhysObjects = rag:GetPhysicsObjectCount()-1
	
	if game.SinglePlayer() then
		net.Start("RagUnstretch_Client1")
			net.WriteEntity(rag)
			net.WriteEntity(ent)
			net.WriteInt(PhysObjects, 8)
		net.Send(ply)
	else
		for i=0,PhysObjects do
			local b = ent:TranslatePhysBoneToBone(i)
			local phys = ent:GetPhysicsObjectNum(i)
			local pos,ang = rag:GetBonePosition(b)
			if pos == rag:GetPos() then
				local matrix = rag:GetBoneMatrix(b)
				if matrix then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
				end
			end
		
			phys:EnableMotion(false)
			phys:Wake()
			if i == 0 then
				phys:SetPos(pos) -- setting position only for the "base" bone, like pelvis. rest of bones should follow base one anyway, as i don't think there are ragdolls that are stretchy by default
			end
			phys:SetAngles(ang)
			phys:Wake()
		end

		for i=0,PhysObjects do
			local b = ent:TranslatePhysBoneToBone(i)
			local phys = rag:GetPhysicsObjectNum(i)
			local pos,ang = ent:GetBonePosition(b)
			if pos == ent:GetPos() then
				local matrix = ent:GetBoneMatrix(b)
				if matrix then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
				end
			end
		
			if rag.UnstretchTable.Bones[i] == true then
				continue 
			end
			phys:EnableMotion(false)
			phys:Wake()
			phys:SetPos(pos)
			phys:SetAngles(ang)
		end
		ent:Remove()
	end
	return true
end

function TOOL:RightClick(tr)
	if !IsValid(tr.Entity) then return false end
	if tr.Entity:GetClass() != "prop_ragdoll" then return false end
	
	if CLIENT then return true end
	
	local rag, ply = tr.Entity, self:GetOwner()
	
	if !rag.UnstretchTable then
		rag.UnstretchTable = { Bones = {} }
	end
	
	local bone = tr.PhysicsBone
	local b = rag:TranslatePhysBoneToBone(bone)

	if !rag.UnstretchTable.Bones[bone] then
		rag.UnstretchTable.Bones[bone] = true
		ply:ChatPrint("Phys ID: " .. bone .. " is now ignored.")
		return true
	elseif rag.UnstretchTable.Bones[bone] == true then
		rag.UnstretchTable.Bones[bone] = false
		ply:ChatPrint("Phys ID: " .. bone .. " is now set to be unstretched.")
	else
		rag.UnstretchTable.Bones[bone] = true
		ply:ChatPrint("Phys ID: " .. bone .. " is now ignored.")
	end
	return true
end

function TOOL:Reload(tr)
	if !IsValid(tr.Entity) then return false end
	if tr.Entity:GetClass() != "prop_ragdoll" then return false end
	
	if CLIENT then return true end
	
	tr.Entity.UnstretchTable = { Bones = {} }
	self:GetOwner():ChatPrint("Physics filters reset.")
	
	return true
end

if CLIENT then

if game.SinglePlayer() then

	net.Receive("RagUnstretch_Client1", function(len)
		local rag = net.ReadEntity()
		local ent = net.ReadEntity()
		local PhysObjects = net.ReadInt(8)
		
		net.Start("RagUnstretch_Server1")
		net.WriteEntity(rag)
		net.WriteEntity(ent)
		net.WriteInt(PhysObjects, 8)
		for i=0,PhysObjects do
			local b = ent:TranslatePhysBoneToBone(i)
			local pos,ang = rag:GetBonePosition(b)
			if pos == rag:GetPos() then
				local matrix = rag:GetBoneMatrix(b)
				if matrix then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
				end
			end
			net.WriteVector(pos)
			net.WriteAngle(ang)
		end
		net.SendToServer()
	end)

	net.Receive("RagUnstretch_Client2", function(len)
		local rag = net.ReadEntity()
		local ent = net.ReadEntity()
		local PhysObjects = net.ReadInt(8)
		
		net.Start("RagUnstretch_Server2")
		net.WriteEntity(rag)
		net.WriteEntity(ent)
		net.WriteInt(PhysObjects, 8)

		for i=0,PhysObjects do
			local b = ent:TranslatePhysBoneToBone(i)
			local pos,ang = ent:GetBonePosition(b)
			if pos == ent:GetPos() then
				local matrix = ent:GetBoneMatrix(b)
				if matrix then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
				end
			end
			net.WriteVector(pos)
			net.WriteAngle(ang)
		end
		net.SendToServer()
	end)

end

language.Add("tool.ragunstretch.name","Ragdoll Unstretch")
language.Add("tool.ragunstretch.desc","Returns stretched ragdolls to normal shape.")
language.Add("tool.ragunstretch.0","Left click to unstretch a ragdoll. Right click on a bone to make tool ignore it. Reload to clear ignored bones.")
language.Add("Hint_ragunstretch_filteron","Ragdoll unstretch will ignore this bone")
language.Add("Hint_ragunstretch_filteroff","Ragdoll unstretch will unstretch this bone")

end