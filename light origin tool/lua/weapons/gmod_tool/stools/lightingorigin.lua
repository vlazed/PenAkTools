TOOL.Category		= "Render"
TOOL.Name			= "Set Lighting Origin"
TOOL.Command		= nil
TOOL.ConfigName		= nil

if SERVER then

duplicator.RegisterEntityModifier("peak Set Lighting Origin", function(pl, ent, data)

	ent.setlightingoriginPostEntityPaste = ent.PostEntityPaste

	ent.PostEntityPaste = function(self, pl, ent, newents)
		if ent.setlightingoriginPostEntityPaste then
			ent:setlightingoriginPostEntityPaste(pl, ent, newents)
		end

		local parent = newents[data.origin]

		if parent then
			parent:SetName("lightingparent")

			local newdata = {}
			newdata.origin = parent:EntIndex()
			newdata.children = {}

			for k, id in ipairs(data.children) do
				if not newents[id] then continue end

				if newents[id]:GetClass() == "prop_effect" and newents[id].AttachedEntity then
					newents[id].AttachedEntity:Fire("setlightingorigin", parent:GetName())
				else
					newents[id]:Fire("setlightingorigin", parent:GetName())
				end
				table.insert(newdata.children, newents[id]:EntIndex())
			end

			duplicator.ClearEntityModifier(self, "peak Set Lighting Origin")
			duplicator.StoreEntityModifier(self, "peak Set Lighting Origin", newdata)

			timer.Simple(0.01, function()
				parent:SetName("")
			end)

		end
	end
end)

end

function TOOL:LeftClick(tr)
	if not self.Children then self.Children = {} end

	if self:GetStage() == 0 then
		if !IsValid(tr.Entity) then return false end

		if CLIENT then return true end

		self.SelectedEnt = tr.Entity

		self.Children[1] = self.SelectedEnt

		for k, ent in pairs(self.SelectedEnt:GetChildren()) do
			if not IsValid(ent) then continue end
			table.insert(self.Children, ent)
		end

		self:SetStage(1)
		return true

	else
		if !IsValid(tr.Entity) then return false end

		if CLIENT then return true end

		local parent = tr.Entity

		parent:SetName("lightingparent")
		local data = {}
		data.origin = parent:EntIndex()
		data.children = {}

		for k, ent in ipairs(self.Children) do
			if not IsValid(ent) then continue end

			if ent:GetClass() == "prop_effect" and IsValid(ent.AttachedEntity) then
				ent.AttachedEntity:Fire("setlightingorigin", parent:GetName())
			else
				ent:Fire("setlightingorigin", parent:GetName())
			end
			table.insert(data.children, ent:EntIndex())
		end

		duplicator.ClearEntityModifier(self.SelectedEnt, "peak Set Lighting Origin")
		duplicator.StoreEntityModifier(self.SelectedEnt, "peak Set Lighting Origin", data)

		timer.Simple(0.01, function()
			parent:SetName("")
		end)

		self:SetStage(0)
		self.Children = {}
		return true
	end
end

function TOOL:Reload(tr)
	if self:GetStage() == 1 then
		self:SetStage(0)
		self.Children = {}
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
