CreateConVar("penak_iris_size", "0.78", FCVAR_NONE, "Control iris size of special materials.", 0.0, nil)

matproxy.Add({
	name = "MagicGay",
	
	bind = function(self, mat, ent)
		if!IsValid(ent) then return end
		ThingVar = GetConVar("penak_iris_size")
		mat:SetFloat("$Dilation", ThingVar:GetFloat())
	end
})