TOOL.Category		= "Render"
TOOL.Name			= "AdvCam Manipulator"
TOOL.Command		= nil
TOOL.ConfigName		= nil
local SelectedEntity = {}
local ChosenEntity = {}
local OnlyProperties = {}

concommand.Add("peak_cam_control", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then

		ChosenEntity[ply] = ent
		ChosenEntity[ply].IsLamp = ent:GetClass() == "gmod_softlamp"

		ChosenEntity[ply]:SetPos(ply:EyePos())
		ChosenEntity[ply]:SetAngles(ply:EyeAngles())
		if not ChosenEntity[ply].IsLamp then
			ChosenEntity[ply]:SetParent(ply, 0)
		end

		OnlyProperties[ply] = false
		ply:SelectWeapon("gmod_camera")
	end
end)

concommand.Add("peak_cam_properties", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then
		ChosenEntity[ply] = ent
		ChosenEntity[ply].IsLamp = ent:GetClass() == "gmod_softlamp"
		OnlyProperties[ply] = true
		ply:SelectWeapon("gmod_camera")
	end
end)

concommand.Add("peak_cam_offset", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then
		if ent:GetClass() == "gmod_softlamp" then
			ent:SetLightOffset(ent:WorldToLocal(ply:EyePos()))
		else
			ent:SetViewOffset(ent:WorldToLocal(ply:EyePos()))
		end
	end
end)

concommand.Add("peak_cam_toentity", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then
		ply:SetPos(ent:GetPos() - Vector(0, 0, 63))
		ply:SetEyeAngles(ent:GetAngles() - Angle(0, 0, ent:GetAngles().Roll))
	end
end)

concommand.Add("peak_cam_tooffset", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then
		local offset

		if ent:GetClass() == "gmod_softlamp" then
			offset = ent:GetLightOffset()
		else
			offset = ent:GetViewOffset()
		end
		ply:SetPos(ent:LocalToWorld(offset) - Vector(0, 0, 63))
		ply:SetEyeAngles(ent:GetAngles() - Angle(0, 0, ent:GetAngles().Roll))
	end
end)

concommand.Add("peak_cam_rotate", function(ply, cmd, args)
	if CLIENT then return end
	local ent = SelectedEntity[ply]

	if IsValid(ent) then
		ply:SetEyeAngles(ent:GetAngles() - Angle(0, 0, ent:GetAngles().Roll))
	end
end)

function TOOL:LeftClick(tr)
	if CLIENT then return false end

	if tr.Entity:GetClass() == "hl_camera" or tr.Entity:GetClass() == "gmod_softlamp" then -- It only works with advanced cameras, and their entity class is hl_camera
		SelectedEntity[self:GetOwner()] = tr.Entity

		return true
	end
	return false
end

hook.Add("Think", "peak_AdvCameraAttach", function()
	if CLIENT then return end

	for _, ply in ipairs(player.GetHumans()) do
		local ent = ChosenEntity[ply]
		if IsValid(ent) then

			if ply:GetActiveWeapon():GetClass() == "gmod_camera" then
				if not OnlyProperties[ply] then
					if not ent.IsLamp then
						ent:SetPos(ply:WorldToLocal(ply:EyePos()))
					else
						ent:SetPos(ply:EyePos())
					end
					ent:SetAngles(ply:EyeAngles())
				end

				if ent.IsLamp then
					ent:SetLightFOV(ply:GetActiveWeapon():GetZoom())
					local NewAngle = ent:GetAngles()
					NewAngle.Roll = ply:GetActiveWeapon():GetRoll()
					ent:SetAngles(NewAngle)
				else
					ent:SetRoll(ply:GetActiveWeapon():GetRoll())
					ent:SetFOV(ply:GetActiveWeapon():GetZoom())
				end
			else
				ent:SetParent(nil)
				if not OnlyProperties[ply] then
					ent:SetPos(ply:EyePos()) -- Positioning camera to player's view after unparenting it, just in case.
					if not ent.IsLamp then
						ent:SetAngles(ply:EyeAngles())
					end
				end
				ChosenEntity[ply] = nil
			end

		end
	end
end)

if CLIENT then

language.Add("tool.peak_cam.name","AdvCam Manipulator")
language.Add("tool.peak_cam.desc","Move Advanced Cameras/Soft Lamps with your view!")
language.Add("tool.peak_cam.0","Left Click to select an Advanced Camera/Soft Lamp")

local function CCol(cpanel,text)
	local cat = vgui.Create("DCollapsibleCategory",cpanel)
	cat:SetExpanded(1)
	cat:SetLabel(text)
	cpanel:AddItem(cat)
	local col = vgui.Create("DPanelList")
	col:SetAutoSize(true)
	col:SetSpacing(5)
	col:EnableHorizontal(false)
	col:EnableVerticalScrollbar(true)
	col.Paint = function()
		surface.DrawRect(0, 0, 500, 500)
	end
	cat:SetContents(col)
	return col, cat
end

local function CButton(cpanel, text, arg)
	local butt = vgui.Create("DButton", cpanel)
	butt:SetText(text)
	function butt:DoClick()
		RunConsoleCommand(arg)
	end
	cpanel:AddItem(butt)
	return butt
end

function TOOL.BuildCPanel(CPanel)
	local ManipCol = CCol(CPanel, "Entity Manipulation")
	CButton(ManipCol, "Move entity with your view", "peak_cam_control")
	CButton(ManipCol, "Manipulate entity's roll and zoom parameters", "peak_cam_properties")
	CButton(ManipCol, "Move Entity's offset to your view", "peak_cam_offset")

	local PlyCol = CCol(CPanel, "Player Movement")
	CButton(PlyCol, "Move yourself to Entity", "peak_cam_toentity")
	CButton(PlyCol, "Move yourself to Entity's Offset", "peak_cam_tooffset")
	CButton(PlyCol, "Rotate your view to match Entity's", "peak_cam_rotate")
end

end
