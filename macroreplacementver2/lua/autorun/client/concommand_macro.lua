if not game.SinglePlayer() then return end

local Working, Stop = false, false
local Stop = false
local MacroTable, Loops = {}, {}
local Step, CurLoop = 0, 0
local Owner = Owner or LocalPlayer()

local Action = {
	function(var, step) -- Wait
		local time = CurTime()

		while ( CurTime() - time < var ) and not Stop do
			step = coroutine.yield(step)
		end

		return step
	end,

	function(var, step) -- Concommand
		Owner:ConCommand( var )

		return step
	end,

	function(var, step) -- Loop start
		CurLoop = CurLoop + 1
		Loops[CurLoop] = {
			Repeats = var - 1,
			Jump = step
		}
print("Setting loop " .. CurLoop .. ", set to repeat for " .. var)
		return step
	end,

	function(var, step) -- Loop end
		local Repeats = Loops[CurLoop].Repeats print("Loop end, repeats left: " .. Repeats)
		if Repeats > 0 then
			step = Loops[CurLoop].Jump
			Loops[CurLoop].Repeats = Repeats - 1
		else
			Loops[CurLoop] = nil print("Loop " .. CurLoop .. " done")
		end

		return step
	end
}

-- test
MacroTable = {
	{
		Type = 1,
		Var = 1
	},

	{
		Type = 3,
		Var = 100
	},

	{
		Type = 2,
		Var = "+attack"
	},

	{
		Type = 1,
		Var = 0.01
	},

	{
		Type = 2,
		Var = "-attack"
	},

	{
		Type = 1,
		Var = 0.01
	},

	{
		Type = 4
	}
}


local function GrabConvar( name )
	return GetConVar( name ):GetFloat()
end

local function macro(step)
	while true do
		step = coroutine.yield(step) print("Cor enter, step: " .. step)
		if step and not Stop then
			if MacroTable[step] then
				local a = MacroTable[step]
				step = Action[a.Type](a.Var, step) + 1
				print("Step valid, step now: " .. step)
			else
				Owner:ChatPrint("Console Macro finished!")
				Working = false
				Stop = false
				CurLoop = 0
				Loops = {}
			end
		else
			Owner:ChatPrint("Console Macro stopped!")
			Working = false
			Stop = false
			CurLoop = 0
			Loops = {}
		end
	end
end

local cor = coroutine.create(macro)

local function MacroTick()
	if Working then
		local b, step = coroutine.resume(cor, Step)
		if b and step then
			Step = step
		end
	end
end

hook.Add("Think", "PEAKConCommandMacro", MacroTick)

concommand.Add( "peak_mac_start", function()
	if not Owner or not IsValid(Owner) then Owner = LocalPlayer() end

	if not Working then
		Owner:ChatPrint("Console Macro starting!")
		Working = true
		Stop = false
		Step = 1
		print("start")
	else
		Stop = true
		print("manual stop")
	end
end )

local function MacroBuild( Panel )
	if not Owner or not IsValid(Owner) then Owner = LocalPlayer() end

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

	local UIBuild = {
		function( cpanel, tab ) -- Wait
			local base = vgui.Create("DPanel", cpanel)
			cpanel:AddItem(base)

			base.text = vgui.Create("DLabel", base)
			base.text:SetDark(true)
			base.text:SetText("Wait (seconds)")

			base.entry = vgui.Create("DTextEntry", base)
			base.entry:SetNumeric(true)
			base.entry:SetValue(tab.Var)
			base.entry:SetUpdateOnType(true)

			base.entry.OnValueChange = function(self, val)
				val = tonumber(val)
				if val then
					tab.Var = val
				end
			end

			base.PerformLayout = function()
				base:SetHeight(48)

				base.text:SetPos(10, 5)
				base.text:SetWide(base:GetWide())

				base.entry:SetSize(base:GetWide() - 10, 15)
				base.entry:SetPos(5, 28)
			end

			return base
		end,
		
		function( cpanel, tab ) -- Concommand
			local base = vgui.Create("DPanel", cpanel)
			cpanel:AddItem(base)

			base.text = vgui.Create("DLabel", base)
			base.text:SetDark(true)
			base.text:SetText("Console Command")

			base.entry = vgui.Create("DTextEntry", base)
			base.entry:SetValue(tab.Var)
			base.entry:SetUpdateOnType(true)

			base.entry.OnValueChange = function(self, val)
				val = tostring(val)
				if val then
					tab.Var = val
				end
			end

			base.PerformLayout = function()
				base:SetHeight(48)

				base.text:SetPos(10, 5)
				base.text:SetWide(base:GetWide())

				base.entry:SetSize(base:GetWide() - 10, 15)
				base.entry:SetPos(5, 28)
			end

			return base
		end,
		
		function( cpanel, tab ) -- Loop Start
			local base = vgui.Create("DPanel", cpanel)
			cpanel:AddItem(base)

			base.text = vgui.Create("DLabel", base)
			base.text:SetDark(true)
			base.text:SetText("Loop Start (Repeat amount)")

			base.entry = vgui.Create("DTextEntry", base)
			base.entry:SetNumeric(true)
			base.entry:SetValue(tab.Var)
			base.entry:SetUpdateOnType(true)

			base.entry.OnValueChange = function(self, val)
				val = tonumber(val)
				if val then
					val = math.floor(val)
					tab.Var = val
				end
			end

			base.PerformLayout = function()
				base:SetHeight(48)

				base.text:SetPos(10, 5)
				base.text:SetWide(base:GetWide())

				base.entry:SetSize(base:GetWide() - 10, 15)
				base.entry:SetPos(5, 28)
			end

			return base
		end,
		
		function( cpanel, tab ) -- Loop end
			local base = vgui.Create("DPanel", cpanel)
			cpanel:AddItem(base)

			base.text = vgui.Create("DLabel", base)
			base.text:SetDark(true)
			base.text:SetText("Loop End")

			base.PerformLayout = function()
				base:SetHeight(28)

				base.text:SetPos(10, 5)
				base.text:SetWide(base:GetWide())
			end

			return base
		end
	}

	local startbutton = vgui.Create( "DButton", Panel )
	startbutton:SetSize( 100, 20 )
	startbutton:SetText( "Start" )

	startbutton.DoClick = function()
		Owner:ConCommand( "peak_mac_start" )
	end
	startbutton:Dock( TOP )
	startbutton:DockMargin( 0, 5, 0, 5 )

	for id, tab in ipairs(MacroTable) do
		UIBuild[tab.Type](Panel, tab)
	end
end

hook.Add("PopulateToolMenu", "peak_macroconcommand", function ()
	spawnmenu.AddToolMenuOption( "Utilities", "PEAK Incompetence", "peak_mcc", "Concommand Macro", "", "", MacroBuild )
end)
