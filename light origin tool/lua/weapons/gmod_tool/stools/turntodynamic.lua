TOOL.Category		= "Construction"
TOOL.Name			= "Turn Into Dynamic Prop"
TOOL.Command		= nil
TOOL.ConfigName		= nil


function TOOL:LeftClick(tr)

	if !IsValid(tr.Entity) then return false end
	
	if CLIENT then return true end
	local ent
	
	if tr.Entity:GetClass() == "prop_effect" and IsValid(tr.Entity.AttachedEntity) then
		ent = tr.Entity.AttachedEntity
	else
		ent = tr.Entity
	end
	
	local newent = ents.Create("prop_dynamic")
	newent:SetModel(ent:GetModel())
	newent:SetPos(ent:GetPos())
	newent:SetAngles(ent:GetAngles())
	newent:SetSolid(3)
	newent:Spawn()
	ent:Remove()
	
	undo.Create("entitytodynamic")
		undo.AddEntity(newent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish("Entity to Dynamic Prop (" .. newent:GetModel() .. ")")
	
	return true		
end

if CLIENT then

language.Add("tool.turntodynamic.name","Turn Into Dynamic Prop")
language.Add("tool.turntodynamic.desc","Turn entities into prop_dynamic")
language.Add("tool.turntodynamic.0","Left Click on an entity to turn it into prop_dynamic.")

end