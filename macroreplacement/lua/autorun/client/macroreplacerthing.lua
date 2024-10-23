---@class MacroData ConVar table that contains the Macro Replacer ConVars as keys and their values
---@field macrothing_wait1 string
---@field macrothing_wait2 string
---@field macrothing_execute1 string
---@field macrothing_execute2 string

if not game.SinglePlayer() then return end

-- Prevent lookup cost by localizing functions 
local addText = chat.AddText
local conCommand
do 
	---@type Player
	local Player = FindMetaTable("Player")
	conCommand = Player.ConCommand
end

-- CreateClientConVar returns the ConVar itself. Store them here so we can reference them for later 
local loops = CreateClientConVar( "macrothing_loops", "30", true, false, nil, 1, nil )
local startWait = CreateClientConVar( "macrothing_startwait", "1", true, false, nil, 0, nil )
local execute1 = CreateClientConVar( "macrothing_execute1", "", true, false, nil, nil, nil )
local wait1 = CreateClientConVar( "macrothing_wait1", "1", true, false, nil, 0, nil )
local execute2 = CreateClientConVar( "macrothing_execute2", "", true, false, nil, nil, nil )
local wait2 = CreateClientConVar( "macrothing_wait2", "0.5", true, false, nil, 0, nil )

-- Scope the below functions as they don't impact the UI building functions
do
	local Working = false
	local Stop = false

	---@param loop integer
	local function MacroTick( loop )
		if loop < 1 or Stop then 
			addText("MacroThing finished!")
			Stop = false
			Working = false
			return
		end
		---@type Player
		local localPlayer = LocalPlayer()

		conCommand(localPlayer, execute1:GetString() )
		timer.Simple( wait1:GetFloat(), function()
			conCommand(localPlayer, execute2:GetString() )

			timer.Simple( wait2:GetFloat(), function()
				MacroTick(loop - 1)
			end )
		end	)
	end

	concommand.Add( "macrothing_start", function()
		if not Working then
			Working = true
			timer.Simple( startWait:GetFloat(), function()
				MacroTick( loops:GetInt() )
			end )
		else
			Stop = true
		end
	end )
end

---@param wait1 any
---@param wait2 any
---@param execute1 any
---@param execute2 any
---@return MacroData
local function macroOption(wait1, wait2, execute1, execute2)
	return {
		macrothing_wait1 = tostring(wait1),
		macrothing_wait2 = tostring(wait2),
		macrothing_execute1 = tostring(execute1),
		macrothing_execute2 = tostring(execute2)
	}
end

-- Add defaults seen from https://www.youtube.com/watch?v=YQUmgGY1Pds
---@param controlPresets ControlPresets
local function addDefaults(controlPresets)
	controlPresets:AddOption("SMH jpeg", macroOption(
		0.0010, 
		0.0010, 
		"jpeg", 
		"smh_next"
	))

	controlPresets:AddOption("SMH tga", macroOption(
		0.0010, 
		0.0010, 
		"screenshot", 
		"smh_next"
	))

	controlPresets:AddOption("SMH jpeg with material manipulation", macroOption(
		0.0010, 
		0.0010, 
		"jpeg", 
		"smh_next;penak_scroll_next"
	))

	controlPresets:AddOption("SMH jpeg with soft lamps", macroOption(
		0.51, 
		0.51, 
		"jpeg", 
		"smh_next"
	))

	controlPresets:AddOption("SMH jpeg with fake depth", macroOption(
		0.0010, 
		0.0010, 
		"fakedepth_render;jpeg", 
		"fakedepth_backtogame;smh_next"
	))

	controlPresets:AddOption("SMH tga with material manipulation", macroOption(
		0.0010, 
		0.0010, 
		"screenshot", 
		"smh_next;penak_scroll_next"
	))

	controlPresets:AddOption("SMH tga with soft lamps", macroOption(
		0.51, 
		0.51, 
		"screenshot", 
		"smh_next"
	))

	controlPresets:AddOption("SMH tga with fake depth", macroOption(
		0.0010, 
		0.0010, 
		"fakedepth_render;screenshot", 
		"fakedepth_backtogame;smh_next"
	))
end

---@param Panel DForm
local function MacroBuild( Panel )
	---@param name string
	---@param default number
	---@param min number
	---@param max number
	---@param convar string
	---@param decimals number
	---@return DNumSlider
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

	---@param convar string
	---@param convarObj ConVar
	---@return DTextEntry | Panel
	local function MakeTextBox( convar, convarObj )
		---@type DTextEntry | Panel
		local newtextentry = vgui.Create( "DTextEntry", Panel )
		newtextentry:SetConVar( convar )
		newtextentry:SetText( convarObj and convarObj:GetString() or GetConVar( convar ):GetString() )
		newtextentry:SetSize( 100, 20 )
		newtextentry:Dock( TOP )
		newtextentry:DockMargin( 0, 5, 0, 5 )
		return newtextentry
	end

	local function MakeControlPreset()		
		local controlPresets = vgui.Create("ControlPresets", Panel)
		controlPresets:Dock( TOP )
		controlPresets:DockMargin( 0, 5, 0, 5 )
		controlPresets:AddConVar("macrothing_wait1")
		controlPresets:AddConVar("macrothing_wait2")
		controlPresets:AddConVar("macrothing_execute1")
		controlPresets:AddConVar("macrothing_execute2")
		controlPresets:SetPreset("Macro Replacer")
		presets.Add("Macro Replacer", "Last saved preset", {
			macrothing_wait1 = wait1:GetString(),
			macrothing_wait2 = wait2:GetString(),
			macrothing_execute1 = execute1:GetString(),
			macrothing_execute2 = execute2:GetString(),
		})
		return controlPresets
	end

	local controlPresets = MakeControlPreset()

	MakeSlider( "Number of repeats:", loops:GetInt(), 1, 300, "macrothing_loops", 0 )
	MakeSlider( "Wait before starting:", startWait:GetFloat(), 0, 10, "macrothing_startwait", 3 )
	MakeTextBox( "macrothing_execute1", execute1 )
	MakeSlider( "Wait:", wait1:GetFloat(), 0, 10, "macrothing_wait1", 4 )
	MakeTextBox( "macrothing_execute2", execute2 )
	MakeSlider( "Wait:", wait2:GetFloat(), 0, 10, "macrothing_wait2", 4 )

	addDefaults(controlPresets)

	local startbutton = vgui.Create( "DButton", Panel )
	startbutton:SetSize( 100, 20 )
	startbutton:SetText( "Start" )
	
	startbutton.DoClick = function()
		RunConsoleCommand( "macrothing_start" )
	end
	startbutton:Dock( TOP )
	startbutton:DockMargin( 0, 5, 0, 5 )
end

hook.Add("PopulateToolMenu", "peak_macroreplacer", function ()
	spawnmenu.AddToolMenuOption( "Utilities", "Peak Incompetence", "peak_mr", "Macro Replacer Test", "", "", MacroBuild )
end)
