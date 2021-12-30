if game.SinglePlayer() then

local ChosenEntity = nil
local OnlyProperties = false

concommand.Add("penak_camera", function(ply, cmd, args)
	if CLIENT then return end

	if ply:GetEyeTrace().Entity:GetClass() == "hl_camera" then
		ChosenEntity = ply:GetEyeTrace().Entity
		OnlyProperties = false
		ply:SelectWeapon("gmod_camera")
	end
end)

concommand.Add("penak_cameracontrols", function(ply, cmd, args)
	if CLIENT then return end

	if ply:GetEyeTrace().Entity:GetClass() == "hl_camera" then
		ChosenEntity = ply:GetEyeTrace().Entity
		OnlyProperties = true
		ply:SelectWeapon("gmod_camera")
	end
end)

hook.Add("Think", "AdvCameraAttach", function()
	if CLIENT then return end

	if IsValid(ChosenEntity) then
		if Entity(1):GetActiveWeapon():GetClass() == "gmod_camera" then
			if not OnlyProperties then
				ChosenEntity:SetPos(Entity(1):EyePos())
				ChosenEntity:SetAngles(Entity(1):EyeAngles())
			end
			ChosenEntity:SetRoll(Entity(1):GetActiveWeapon():GetRoll())
			ChosenEntity:SetFOV(Entity(1):GetActiveWeapon():GetZoom())
		else
			ChosenEntity = nil
		end
	end
end)

end
