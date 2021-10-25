for k, entity in pairs(ents.GetAll()) do 
	if entity:GetClass() == "gmod_softlamp" then 
		local DPanel = vgui.Create("DFrame") 
		DPanel:SetSize(300, 400) 
		DPanel:Center()
		DPanel:MakePopup()  
		local DEnt = vgui.Create("DEntityProperties", DPanel) 
		DEnt:Dock(FILL) 
		DEnt:SetEntity(entity)
		function DEnt:OnEntityLost()
			DPanel:Remove()
		end
	end 
end
