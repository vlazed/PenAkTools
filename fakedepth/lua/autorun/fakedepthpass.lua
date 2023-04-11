if SERVER then
	util.AddNetworkString("fakedepth_sendcamera")

	hook.Add("InitPostEntity", "fakedepth_sendcamera", function()
		local SkyCamera = ents.FindByClass("sky_camera")[1]
		if SkyCamera then
			local SkyPos = SkyCamera:GetPos()
			local SkyScale = SkyCamera:GetInternalVariable("scale")

			hook.Add("PlayerInitialSpawn","fakedepth_sendcamera", function(ply)

				hook.Add("SetupMove", "fakedepth_sendcamera" .. ply:UserID(), function(player)
					if ply == player then
						net.Start("fakedepth_sendcamera")
							net.WriteVector(SkyPos)
							net.WriteUInt(SkyScale, 32)
						net.Send(ply)

						hook.Remove("SetupMove", "fakedepth_sendcamera" .. ply:UserID())
					end
				end)
			end)
		end
	end)

	concommand.Add("fakedepth_updateskyboxinfo", function()
		local SkyCamera = ents.FindByClass("sky_camera")[1]

		if SkyCamera then
			local SkyPos = SkyCamera:GetPos()
			local SkyScale = SkyCamera:GetInternalVariable("scale")

			net.Start("fakedepth_sendcamera")
				net.WriteVector(SkyPos)
				net.WriteUInt(SkyScale, 32)
			net.Send(Entity(1))
		end
	end)

	return
end

local pp_fakedepth = CreateClientConVar( "pp_fakedepth", "0", false, false )
local Active = false
local ConVarDefaults = {}
local ConVars = {}
local DepthData = {}
local Status = "Preview"
local SkyPos = nil
local SkyScale = nil
local MAXDETAIL = 5000
local PosterSize, PosterSplit, CallsLeft = 1, 0, 0
local RenderStart, Rendering = false, false

ConVars.col1_r = 255
ConVars.col1_g = 0
ConVars.col1_b = 0
ConVars.col2_r = 0
ConVars.col2_g = 255
ConVars.col2_b = 255
ConVars.col3_r = 255
ConVars.col3_g = 255
ConVars.col3_b = 0
ConVars.farz = 28000
ConVars.drawskybox = 1
ConVars.maxdist = 2000
ConVars.middist = 1000
ConVars.mindist = 0
ConVars.detail = 18
ConVars.alpha = 0
ConVars.threeplane = 0

for k,v in pairs( ConVars ) do
	ConVarDefaults["fakedepth_"..k] = v
	local convar = CreateClientConVar( "fakedepth_" .. k, tostring( v ), true )
	DepthData[k] = convar:GetFloat()

	cvars.AddChangeCallback("fakedepth_" .. k, function(name, oldval, newval)
		DepthData[k] = tonumber(newval)

		if Status == "ViewRender" then
			Status = "Render"
		end
	end)
end

cvars.AddChangeCallback("pp_fakedepth", function(name, oldval, newval)
	Active = tobool(newval)
end)

concommand.Add("fakedepth_render", function()
	Status = "Render"
end)

concommand.Add("fakedepth_backtogame", function()
	Status = "Preview"
end)

concommand.Add("poster_fakedepth", function(ply, cmd, args)
	if not args[1] then
		print("poster_fakedepth <poster size> <poster split [optional]>")
		return
	end
	PosterSize = args[1]
	PosterSplit = args[2]
	CallsLeft = PosterSize * PosterSize
	RenderStart = true
	Rendering = true

	Status = "RenderScreenshot"
end)

list.Set( "PostProcess", "fakedepth", {

	icon = "gui/postprocess/fakedepth/fakedepth_icon.png",
	convar = "pp_fakedepth",
	category = "#effects_pp",

	cpanel = function( panel )

		panel:AddControl( "ComboBox", {MenuButton = 1, Folder = "fakedepth_settings", Options = {["default"] = ConVarDefaults}, CVars = table.GetKeys( ConVarDefaults )} )
		panel:AddControl("Header", { Text = "fakedepth", Description = [[Allows to render a "fake depth pass"]] } )

		panel:AddControl( "Checkbox", { Label = "Transparency", Command ="fakedepth_alpha"} )
		panel:AddControl( "Slider", { Label = "Detail",Command = "fakedepth_detail",Type = "int",Min = 1,Max = 100,Help = false} )

		panel:AddControl( "Color", {Label="Near color", Red="fakedepth_col1_r",Green="fakedepth_col1_g",Blue="fakedepth_col1_b",} )
		panel:AddControl( "Slider", { Label = "Near distance",Command = "fakedepth_mindist",Type = "int",Min = 0,Max = 100000,Help = false} )

		panel:AddControl( "Color", {Label="Middle color", Red="fakedepth_col3_r",Green="fakedepth_col3_g",Blue="fakedepth_col3_b",} )
		panel:AddControl( "Slider", { Label = "Middle distance",Command = "fakedepth_middist",Type = "int",Min = 0,Max = 100000,Help = false} )

		panel:AddControl( "Color", {Label="Far color", Red="fakedepth_col2_r",Green="fakedepth_col2_g",Blue="fakedepth_col2_b",} )
		panel:AddControl( "Slider", { Label = "Far distance",Command = "fakedepth_maxdist",Type = "int",Min = 0,Max = 100000,Help = false} )

		panel:AddControl( "Checkbox", { Label = "Use 3 planes", Command ="fakedepth_threeplane"} )

		panel:AddControl( "Button", {Label="Render and Screenshot", Command="poster_fakedepth 1", } )
		panel:AddControl( "Button", {Label="Preview Render", Command="fakedepth_render"} )
		panel:AddControl( "Button", {Label="Back to game", Command="fakedepth_backtogame"} )

		panel:AddControl( "Checkbox", { Label = "Draw skybox", Command ="fakedepth_drawskybox"} )
		panel:AddControl( "Slider", { Label = "FarZ (Skybox clip)",Command = "fakedepth_farz",Type = "int",Min = 0,Max = 100000,Help = false} )
		

	end})

hook.Add( "SetupWorldFog", "fakedepth", function()
	if not Active then return end
	if LocalPlayer():InVehicle() == true then return end
	render.FogMode( MATERIAL_FOG_NONE )
	render.FogStart( 0 )
	render.FogEnd( 0 )
	render.FogMaxDensity( 0 )
	render.FogColor( 0, 0, 0 )
	return true
end)
hook.Add( "SetupSkyboxFog", "fakedepth", function()
	if not Active then return end
	if LocalPlayer():InVehicle() == true then return end
	render.FogMode( MATERIAL_FOG_NONE )
	render.FogStart( 0 )
	render.FogEnd( 0 )
	render.FogMaxDensity( 0 )
	render.FogColor( 0, 0, 0 )
	return true
end)

net.Receive("fakedepth_sendcamera", function(len)
	SkyPos = net.ReadVector()
	SkyScale = net.ReadUInt(32)
end)

local tex_render = render.GetSuperFPTex()
local tex_add = render.GetSuperFPTex2()
local tex_scrfx = render.GetScreenEffectTexture()
local mat_copy = Material("pp/copy")

local function RenderPreview(ViewPos, ViewAngle)

	render.RenderView()

	cam.Start3D()

		local cam_normal = ViewAngle:Forward()
		local distance = DepthData["maxdist"]
		local mindist = DepthData["mindist"]
		local middist = DepthData["middist"]
		local drawsky = DepthData["drawskybox"]

		if distance < mindist then distance = mindist end
		if middist < mindist then middist = mindist end
		if middist > distance then middist = distance end

		local fade2_R = math.floor( DepthData["col2_r"] + 0.50 )
		local fade2_G = math.floor( DepthData["col2_g"] + 0.50 )
		local fade2_B = math.floor( DepthData["col2_b"] + 0.50 )

		local fade1_R = math.floor( DepthData["col1_r"] + 0.50 )
		local fade1_G = math.floor( DepthData["col1_g"] + 0.50 )
		local fade1_B = math.floor( DepthData["col1_b"] + 0.50 )

		local PrevColor1 = Color( fade1_R, fade1_G, fade1_B, 61 )
		local PrevColor2 = Color( fade2_R, fade2_G, fade2_B, 127 )

		render.SetColorMaterial()
		render.DrawQuadEasy( ViewPos + ( cam_normal *(1 + distance) ), -cam_normal, distance *3, distance *3, PrevColor2, -ViewAngle.roll )

		if DepthData["threeplane"] > 0 then 
			local fade3_R = math.floor( DepthData["col3_r"] + 0.50 )
			local fade3_G = math.floor( DepthData["col3_g"] + 0.50 )
			local fade3_B = math.floor( DepthData["col3_b"] + 0.50 )

			local PrevColor3 = Color( fade3_R, fade3_G, fade3_B, 94 )

			render.DrawQuadEasy( ViewPos + ( cam_normal *(1 + middist) ), -cam_normal, middist *3, middist *3, PrevColor3, -ViewAngle.roll )
		end

		render.DrawQuadEasy( ViewPos + ( cam_normal *(1 + mindist) ), -cam_normal, mindist *3, mindist *3, PrevColor1, -ViewAngle.roll )

	cam.End3D()

	if not SkyPos or drawsky < 1 then return end

	hook.Add("PostDrawSkyBox", "fakedepth_sky", function()

		render.SetColorMaterial()
		render.DrawQuadEasy( ViewPos + ( cam_normal *((1 + distance)/SkyScale) ), -cam_normal, distance *3, distance *3, PrevColor2, -ViewAngle.roll )

		if DepthData["threeplane"] > 0 then 
			local fade3_R = math.floor( DepthData["col3_r"] + 0.50 )
			local fade3_G = math.floor( DepthData["col3_g"] + 0.50 )
			local fade3_B = math.floor( DepthData["col3_b"] + 0.50 )

			local PrevColor3 = Color( fade3_R, fade3_G, fade3_B, 94 )

			render.DrawQuadEasy( ViewPos + ( cam_normal *(1 + middist/SkyScale) ), -cam_normal, middist *3, middist *3, PrevColor3, -ViewAngle.roll )
		end

		render.DrawQuadEasy( ViewPos + ( cam_normal *((1 + mindist)/SkyScale) ), -cam_normal, mindist *3, mindist *3, PrevColor1, -ViewAngle.roll )

		hook.Remove("PostDrawSkyBox", "fakedepth_sky")
	end)

end

local function RenderFakeDepth(ViewPos, ViewAngle)

	local cam_normal = ViewAngle:Forward()
	local distance = DepthData["maxdist"]
	local distmin = DepthData["mindist"]
	local distmid = DepthData["middist"]
	local drawsky = DepthData["drawskybox"]
	local farz = DepthData["farz"]
	local maxlayers = ( DepthData["detail"] /100 ) * MAXDETAIL

	if distance < distmin then distance = distmin end
	if distmid < distmin then distmid = distmin end
	if distmid > distance then distmid = distance end

	if SkyPos and drawsky > 0 then

		local skypos = SkyPos + ViewPos/SkyScale

		render.PushRenderTarget(tex_add)

		render.RenderView({ origin = skypos })
		render.UpdateScreenEffectTexture()

		mat_copy:SetTexture("$basetexture", tex_scrfx) -- using antialias trick from soft lamps
		render.SetMaterial(mat_copy)
		render.DrawScreenQuad()

		cam.Start3D()

			local cmax, cmin, cmid = 0, 0, 0

			for z = 1, maxlayers do

				local thisdist = (distance / maxlayers) / SkyScale *z

				if thisdist < distmin/SkyScale then
					cmin = cmin + 1
				elseif thisdist < distmid/SkyScale and DepthData["threeplane"] > 0 then
					cmid = cmid + 1
				elseif DepthData["threeplane"] > 0 then
					cmax = cmax + 1
				else
					cmax = cmax + 1
				end
			end

			local zmax, zmid = 0, 0

			render.SetColorMaterial()
			for z = 1, maxlayers do

				local thisdist = (distance / maxlayers) / SkyScale *z

				local fade_R
				local fade_G
				local fade_B

				if thisdist < distmin/SkyScale then

					fade_R = math.floor( DepthData["col1_r"] + 0.5 )
					fade_G = math.floor( DepthData["col1_g"] + 0.5 )
					fade_B = math.floor( DepthData["col1_b"] + 0.5 )

				elseif thisdist < distmid/SkyScale and DepthData["threeplane"] > 0 then

					zmid = zmid + 1
					fade_R = math.floor( ( DepthData["col1_r"] +( zmid/ ( maxlayers - cmin - cmax ) ) *( DepthData["col3_r"] - DepthData["col1_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col1_g"] +( zmid/ ( maxlayers - cmin - cmax ) ) *( DepthData["col3_g"] - DepthData["col1_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col1_b"] +( zmid/ ( maxlayers - cmin - cmax ) ) *( DepthData["col3_b"] - DepthData["col1_b"] ) ) +0.50 )

				elseif DepthData["threeplane"] > 0 then

					zmax = zmax + 1
					fade_R = math.floor( ( DepthData["col3_r"] +( zmax/ ( maxlayers - cmin - cmid ) ) *( DepthData["col2_r"] - DepthData["col3_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col3_g"] +( zmax/ ( maxlayers - cmin - cmid ) ) *( DepthData["col2_g"] - DepthData["col3_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col3_b"] +( zmax/ ( maxlayers - cmin - cmid ) ) *( DepthData["col2_b"] - DepthData["col3_b"] ) ) +0.50 )

				else

					zmax = zmax + 1
					fade_R = math.floor( ( DepthData["col1_r"] +( zmax/ ( maxlayers - cmin ) ) *( DepthData["col2_r"] - DepthData["col1_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col1_g"] +( zmax/ ( maxlayers - cmin ) ) *( DepthData["col2_g"] - DepthData["col1_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col1_b"] +( zmax/ ( maxlayers - cmin ) ) *( DepthData["col2_b"] - DepthData["col1_b"] ) ) +0.50 )

				end

				local fade_A = math.floor( ( 0 +( z/ maxlayers ) *( 255 - 0 ) ) +0.50 )

				if DepthData["alpha"] <= 0 then fade_A = 255 end
				render.DrawQuadEasy( skypos + ( cam_normal *( 1 + thisdist ) ), -cam_normal, distance *3, distance *3, Color( fade_R, fade_G, fade_B, fade_A ), -ViewAngle.roll )

			end

		cam.End3D()

		render.PopRenderTarget()

	end

	render.PushRenderTarget(tex_render)

		render.RenderView({origin = ViewPos})
		render.UpdateScreenEffectTexture()

		mat_copy:SetTexture("$basetexture", tex_scrfx)
		render.SetMaterial(mat_copy)
		render.DrawScreenQuad()

		cam.Start2D()
			surface.SetDrawColor( DepthData["col1_r"], DepthData["col1_g"], DepthData["col1_b"], 255 )
			surface.DrawRect(0, 0, ScrW(), ScrH())
		cam.End2D()

		cam.Start3D()

			local cmax, cmin, cmid = 0, 0, 0

			for z = 1, maxlayers do

				local thisdist = (distance / maxlayers) *z

				if thisdist < distmin then
					cmin = cmin + 1
				elseif thisdist < distmid and DepthData["threeplane"] > 0 then
					cmid = cmid + 1
				elseif DepthData["threeplane"] > 0 then
					cmax = cmax + 1
				else
					cmax = cmax + 1
				end
			end

			local zmax, zmid = 0, 0

			render.SetColorMaterial()
			for z = 1, maxlayers do

				local thisdist = (distance / maxlayers) *z

				local fade_R
				local fade_G
				local fade_B

				if thisdist < distmin then

					fade_R = math.floor( DepthData["col1_r"] + 0.5 )
					fade_G = math.floor( DepthData["col1_g"] + 0.5 )
					fade_B = math.floor( DepthData["col1_b"] + 0.5 )
				
				elseif thisdist < distmid and DepthData["threeplane"] > 0 then

					zmid = zmid + 1
					fade_R = math.floor( ( DepthData["col1_r"] +( zmid/ (maxlayers - cmin - cmax) ) *( DepthData["col3_r"] - DepthData["col1_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col1_g"] +( zmid/ (maxlayers - cmin - cmax) ) *( DepthData["col3_g"] - DepthData["col1_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col1_b"] +( zmid/ (maxlayers - cmin - cmax) ) *( DepthData["col3_b"] - DepthData["col1_b"] ) ) +0.50 )

				elseif DepthData["threeplane"] > 0 then

					zmax = zmax + 1
					fade_R = math.floor( ( DepthData["col3_r"] +( zmax/ (maxlayers - cmin - cmid) ) *( DepthData["col2_r"] - DepthData["col3_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col3_g"] +( zmax/ (maxlayers - cmin - cmid) ) *( DepthData["col2_g"] - DepthData["col3_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col3_b"] +( zmax/ (maxlayers - cmin - cmid) ) *( DepthData["col2_b"] - DepthData["col3_b"] ) ) +0.50 )

				else

					zmax = zmax + 1
					fade_R = math.floor( ( DepthData["col1_r"] +( zmax/ (maxlayers - cmin) ) *( DepthData["col2_r"] - DepthData["col1_r"] ) ) +0.50 )
					fade_G = math.floor( ( DepthData["col1_g"] +( zmax/ (maxlayers - cmin) ) *( DepthData["col2_g"] - DepthData["col1_g"] ) ) +0.50 )
					fade_B = math.floor( ( DepthData["col1_b"] +( zmax/ (maxlayers - cmin) ) *( DepthData["col2_b"] - DepthData["col1_b"] ) ) +0.50 )

				end

				local fade_A = math.floor( ( 0 +( z/ maxlayers ) *( 255 - 0 ) ) +0.50 )

				if DepthData["alpha"] <= 0 then fade_A = 255 end
				render.DrawQuadEasy( ViewPos + ( cam_normal *( 1 + thisdist ) ), -cam_normal, distance *3, distance *3, Color( fade_R, fade_G, fade_B, fade_A ), -ViewAngle.roll )

			end

			if SkyPos and drawsky > 0 then

				-- Reset everything to known good
				render.SetStencilWriteMask( 0xFF )
				render.SetStencilTestMask( 0xFF )
				render.SetStencilReferenceValue( 0 )
				-- render.SetStencilCompareFunction( STENCIL_ALWAYS )
				render.SetStencilPassOperation( STENCIL_KEEP )
				-- render.SetStencilFailOperation( STENCIL_KEEP )
				render.SetStencilZFailOperation( STENCIL_KEEP )
				render.ClearStencil()

				-- Enable stencils
				render.SetStencilEnable( true )
				-- Set the reference value to 1. This is what the compare function tests against
				render.SetStencilReferenceValue( 1 )
				-- Only draw things if their pixels are currently 1. Currently this is nothing.
				render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
				-- If something fails to draw to the screen, set the pixels it would have drawn to 1
				-- This includes if it's behind something.
				render.SetStencilZFailOperation( STENCIL_REPLACE )

				render.DrawQuadEasy( ViewPos + ( cam_normal *(farz) ), -cam_normal, farz *3, farz *3, Color( 0, 0, 0, 255 ), -ViewAngle.roll )

				render.SetStencilZFailOperation( STENCIL_KEEP )

				mat_copy:SetTexture("$basetexture", tex_add)
				render.SetMaterial(mat_copy)
				render.DrawScreenQuad()

				-- Let everything render normally again
				render.SetStencilEnable( false )

			end

		cam.End3D()

	render.PopRenderTarget()

	mat_copy:SetTexture("$basetexture", tex_render)

	render.SetMaterial(mat_copy)
	render.DrawScreenQuad()
end

local function FakeDepth(origin, angles, fov)
	if Active or Rendering then
		local lp = LocalPlayer()
		if lp:InVehicle() == true then return end

		if Status == "Preview" then
			RenderPreview(origin, angles)
		elseif Status == "Render" then
			RenderFakeDepth(origin, angles)
			Status = "ViewRender"
		elseif Status == "RenderScreenshot" then

			if RenderStart then
				RunConsoleCommand("poster", PosterSize, PosterSplit)
				RenderStart = false
			end

			RenderFakeDepth(origin, angles)

			CallsLeft = CallsLeft - 1
			if CallsLeft < 0 then
				Status = "RenderScreenshot2"
			end

		elseif Status == "RenderScreenshot2" then -- console command gets executed on next tick after getting called, so we'll hold the rendered thing
			render.SetMaterial(mat_copy)
			render.DrawScreenQuad()
			Status = "Preview"
			Rendering = false
		elseif Status == "ViewRender" then
			render.SetMaterial(mat_copy)
			render.DrawScreenQuad()
		end

		return true
	end
end

hook.Add( "RenderScene", "fakedepth", FakeDepth )
