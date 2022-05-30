if not game.SinglePlayer() then return end

local Working = false
local Stop = false

local function GrabConvar( name )
	return GetConVar( name ):GetFloat()
end

local function MacroTick( loop )
	if loop < 1 or Stop then 
		LocalPlayer():ChatPrint("MacroThing finished!")
		Stop = false
		Working = false
		return
	end

	LocalPlayer():ConCommand( GetConVar( "macrothing_execute1" ):GetString() )
	timer.Simple( GrabConvar( "macrothing_wait1" ), function()
		LocalPlayer():ConCommand( GetConVar( "macrothing_execute2" ):GetString() )

		timer.Simple( GrabConvar( "macrothing_wait2" ), function()
			MacroTick(loop - 1)
		end )
	end	)
end

CreateClientConVar( "macrothing_loops", 30, true, false, nil, 1, nil )
CreateClientConVar( "macrothing_startwait", 1, true, false, nil, 0, nil )
CreateClientConVar( "macrothing_execute1", "", true, false, nil, nil, nil )
CreateClientConVar( "macrothing_wait1", 1, true, false, nil, 0, nil )
CreateClientConVar( "macrothing_execute2", "", true, false, nil, nil, nil )
CreateClientConVar( "macrothing_wait2", 0.5, true, false, nil, 0, nil )

concommand.Add( "macrothing_start", function()
	if not Working then
		Working = true
		timer.Simple( GrabConvar( "macrothing_startwait" ), function()
			MacroTick( GetConVar( "macrothing_loops" ):GetInt() )
		end )
	else
		Stop = true
	end
end )

function MacroBuild( Panel )
	local function MakeSlider( name, default, min, max, convar, decimals )
		local newslider = vgui.Create( "DNumSlider", Panel )
		newslider:SetDefaultValue( default )
		newslider:SetConVar( convar )
		newslider:SetDecimals( decimals )
		newslider:SetMinMax(min, max)
		newslider:SetText( name )
		newslider:SetDark( true )
		newslider:SetSize( 100, 20 )
		newslider:Dock( TOP )
		newslider:DockMargin( 0, 5, 0, 5 )
		return newslider
	end

	local function MakeTextBox( convar )
		local newtextentry = vgui.Create( "DTextEntry", Panel )
		newtextentry:SetConVar( convar )
		newtextentry:SetText( GetConVar( convar ):GetString() )
		newtextentry:SetSize( 100, 20 )
		newtextentry:Dock( TOP )
		newtextentry:DockMargin( 0, 5, 0, 5 )
		return newtextentry
	end

	MakeSlider( "Number of repeats:", GetConVar( "macrothing_loops" ):GetInt(), 1, 300, "macrothing_loops", 0 )
	MakeSlider( "Wait before starting:", GrabConvar( "macrothing_startwait" ), 0, 10, "macrothing_startwait", 3 )
	MakeTextBox( "macrothing_execute1" )
	MakeSlider( "Wait:", GrabConvar( "macrothing_wait1" ), 0, 10, "macrothing_wait1", 4 )
	MakeTextBox( "macrothing_execute2" )
	MakeSlider( "Wait:", GrabConvar( "macrothing_wait2" ), 0, 10, "macrothing_wait2", 4 )

	local startbutton = vgui.Create( "DButton", Panel )
	startbutton:SetSize( 100, 20 )
	startbutton:SetText( "Start" )

	startbutton.DoClick = function()
		LocalPlayer():ConCommand( "macrothing_start" )
	end
	startbutton:Dock( TOP )
	startbutton:DockMargin( 0, 5, 0, 5 )
end

hook.Add("PopulateToolMenu", "peak_macroreplacer", function ()
	spawnmenu.AddToolMenuOption( "Utilities", "Peak Incompetence", "peak_mr", "Macro Replacer Test", "", "", MacroBuild )
end)
