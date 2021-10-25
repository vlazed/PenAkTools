TOOL.Category		= "Render"
TOOL.Name			= "Set Lighting Origin"
TOOL.Command		= nil
TOOL.ConfigName		= nil
local FunnyNumber = 0
local children = {}

function TOOL:LeftClick(tr)
	if self:GetStage() == 0 then
		if !IsValid(tr.Entity) then return false end

		if CLIENT then return true end

		if tr.Entity:GetClass() == "prop_effect" and IsValid(tr.Entity.AttachedEntity) then
			self.SelectedEnt = tr.Entity.AttachedEntity
		else
			self.SelectedEnt = tr.Entity
		end

		children[1] = self.SelectedEnt

		for k, ent in pairs(self.SelectedEnt:GetChildren()) do
			if !IsValid(ent) then continue end
			table.insert(children, ent)
		end

		self:SetStage(1)
		return true

	else
		if !IsValid(tr.Entity) then return false end

		if CLIENT then return true end

		local parent = tr.Entity

		parent:SetName("lightingparent" .. FunnyNumber)

		for k, ent in ipairs(children) do
			local child = ent
			child:Fire("setlightingorigin", parent:GetName())
		end

		FunnyNumber = FunnyNumber + 1
		self:SetStage(0)
		children = {}
		return true
	end
end

function TOOL:Reload(tr)
	if self:GetStage() == 1 then
		self:SetStage(0)
		children = {}
		return true
	end
	return false
end

if CLIENT then

language.Add("tool.lightingorigin.name","Set Lighting Origin")
language.Add("tool.lightingorigin.desc","Set lighting origin of a prop")
language.Add("tool.lightingorigin.0","Left Click to select a prop to change lighting origin of.")
language.Add("tool.lightingorigin.1","Now click on a prop to set it as lighting origin or press reload to cancel.")

end
