TOOL.Category		= "Construction"
TOOL.Name			= "Ragdoll Weight"
TOOL.Command		= nil
TOOL.ConfigName		= nil

TOOL.ClientConVar["weight"] = 10
TOOL.ClientConVar["allbones"] = 0

if SERVER then

util.AddNetworkString( "RagWeight_RequestWeight" )
util.AddNetworkString( "RagWeight_RequestWeightResponse" )

net.Receive( "RagWeight_RequestWeight", function( len, ply )

	local tr = ply:GetEyeTrace()
	local ent = tr.Entity
	local physID = tr.PhysicsBone

	if IsValid( ent ) and ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_ragdoll" ) then
		net.Start( "RagWeight_RequestWeightResponse" )
		net.WriteFloat( ent:GetPhysicsObjectNum( physID ):GetMass() )
		net.Send( ply )
	end

end )

end

local function RagdollWeight(ply, ent, weightdata)

	if not IsValid( ent ) or not ent:GetClass() == "prop_physics" or not ent:GetClass() == "prop_ragdoll" then return false end

	if not ent.RagdollWeightData then ent.RagdollWeightData = {} end

	for boneid, weight in pairs(weightdata) do
		ent.RagdollWeightData[boneid] = weight
		ent:GetPhysicsObjectNum( boneid ):SetMass( weight )
	end

	if SERVER then
		duplicator.ClearEntityModifier( ent, "ragdoll_weight_stuff" )
		duplicator.StoreEntityModifier( ent, "ragdoll_weight_stuff", weightdata )
	end

end
duplicator.RegisterEntityModifier( "ragdoll_weight_stuff", RagdollWeight )

function TOOL:LeftClick( tr )
	local ent = tr.Entity

	if not IsValid( ent ) or not ent:GetClass() == "prop_physics" or not ent:GetClass() == "prop_ragdoll" then return false end
	if CLIENT then return true end

	ent.RagdollWeightData = ent.RagdollWeightData or {}
	local physID = tr.PhysicsBone

	if self:GetClientNumber("allbones", 0) ~= 0 then
		for i = 0, ent:GetPhysicsObjectCount() - 1 do
			ent.RagdollWeightData[i] = self:GetClientNumber( "weight", 10 )
		end
	else
		ent.RagdollWeightData[physID] = self:GetClientNumber( "weight", 10 )
	end
	

	RagdollWeight( self.Owner, ent, ent.RagdollWeightData )

	net.Start( "RagWeight_RequestWeightResponse" )
	net.WriteFloat( ent:GetPhysicsObjectNum( physID ):GetMass() )
	net.Send( self:GetOwner() )

	return true
end


if CLIENT then

local lastent = nil
local lastbone = nil
local weight = nil

net.Receive( "RagWeight_RequestWeightResponse", function(len)
	weight = math.Round( net.ReadFloat(), 2 )
end )


function TOOL.BuildCPanel(CPanel)

	local item = vgui.Create( "DNumSlider", CPanel )
	item:SetText( "Weight" )
	item:SetDecimals( 2 )
	item:SetMinMax( 0.01, 50000 )
	item:SetConVar( "ragdollweight_weight" )
	item:SetDark( true )
	CPanel:AddItem( item )

	item = vgui.Create( "DCheckBoxLabel", CPanel )
	item:SetText( "Apply weight to all bones" )
	item:SetConVar( "ragdollweight_allbones" )
	item:SetDark( true )
	CPanel:AddItem( item )

end

function TOOL:DrawHUD()

	local tr = LocalPlayer():GetEyeTrace()
	local ent = tr.Entity
	local physID = tr.PhysicsBone

	if IsValid( ent ) and ( ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_ragdoll" ) then
		local bone = ent:TranslatePhysBoneToBone( physID )

		local name = ent:GetBoneName( bone )
		if not weight or lastbone ~= name or lastent ~= ent then
			weight = "Not initialized"
			lastbone = name

			net.Start( "RagWeight_RequestWeight" )
			net.SendToServer()
		end

		local _pos, _ang = ent:GetBonePosition( bone )

		if not _pos or not _ang then
			_pos, _ang = ent:GetPos(), ent:GetAngles()
		end

		_pos = _pos:ToScreen()
		local textpos = { x = _pos.x + 5, y = _pos.y - 5 }
		surface.DrawCircle( _pos.x, _pos.y, 2.5, Color( 0, 200, 0, 255 ) )

		local infostring =  "Weight: " .. weight .. (ent:GetClass() == "prop_ragdoll" and (" Bone: " .. name) or "")
		draw.SimpleText( infostring, "GModToolSubtitle", textpos.x, textpos.y, Color( 0, 200, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
	end

	lastent = ent

end

language.Add("tool.ragdollweight.name","Ragdoll Weight")
language.Add("tool.ragdollweight.desc","Set weight of ragdolls' bones")
language.Add("tool.ragdollweight.0", "Left click on a bone to set its weight")

end
