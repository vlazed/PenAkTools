if not game.SinglePlayer() then return end

local Working, Stop = false, false
local Stop = false
local MacroTable, Loops = {}, {}
local Step, CurLoop = 0, 0
local Owner = Owner or LocalPlayer()

local ConFile  = CreateClientConVar("peak_concommac_file", "default", true, false, "Name of the currently selected file with Macro instructions")
local SuppressMessages  = CreateClientConVar("peak_concommac_messageoff", 0, true, false, "Turn off chat messages from Console Command Macro")
local SuppressSounds  = CreateClientConVar("peak_concommac_soundoff", 0, true, false, "Turn off sounds from Console Command Macro")

local WAIT = 1
local CONCOMMAND = 2
local LOOPSTART = 3
local LOOPEND = 4

local Action = {
	function(var, step) -- Wait
		var = tonumber(var)
		if not var then var = 0 end

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
		var = tonumber(var)
		if not var then var = 1 end

		CurLoop = CurLoop + 1
		Loops[CurLoop] = {
			Repeats = var - 1,
			Jump = step
		}
--		print("Setting loop " .. CurLoop .. ", set to repeat for " .. var)
		return step
	end,


	function(var, step) -- Loop end
		local Repeats = Loops[CurLoop].Repeats
--		print("Loop end, repeats left: " .. Repeats)
		if Repeats > 0 then
			step = Loops[CurLoop].Jump
			Loops[CurLoop].Repeats = Repeats - 1
		else
			Loops[CurLoop] = nil
--			print("Loop " .. CurLoop .. " done")
			if CurLoop > 0 then
				CurLoop = CurLoop - 1
			end
		end

		return step
	end
}

-- Default Macro Setup
local DefaultMacro = {
	{
		Type = WAIT,
		Var = 1
	},

	{
		Type = LOOPSTART,
		Var = 100
	},

	{
		Type = CONCOMMAND,
		Var = ""
	},

	{
		Type = WAIT,
		Var = 0.01
	},

	{
		Type = CONCOMMAND,
		Var = ""
	},

	{
		Type = WAIT,
		Var = 0.01
	},

	{
		Type = LOOPEND
	}
}

local function macro(step)
	while true do
		step = coroutine.yield(step)
--		print("Cor enter, step: " .. step)
		if step and not Stop then
			local a = MacroTable[step]
			if a then
				step = Action[a.Type](a.Var, step) + 1
--				print("Step valid, step now: " .. step)
			else
				if not SuppressMessages:GetBool() then Owner:ChatPrint("Console Macro finished!") end
				if not SuppressSounds:GetBool() then surface.PlaySound("buttons/button1.wav") end
				Working = false
				Stop = false
				CurLoop = 0
				Loops = {}
			end
		else
			if not SuppressMessages:GetBool() then Owner:ChatPrint("Console Macro stopped!") end
			if not SuppressSounds:GetBool() then surface.PlaySound("buttons/button6.wav") end
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
		assert(b, step)
		if step then
			Step = step
		end
	end
end

hook.Add("Think", "PEAKConCommandMacro", MacroTick)

concommand.Add( "peak_mac_start", function()
	if not Owner or not IsValid(Owner) then Owner = LocalPlayer() end

	if not Working then
		if not SuppressMessages:GetBool() then Owner:ChatPrint("Console Macro starting!") end
		if not SuppressSounds:GetBool() then surface.PlaySound("buttons/blip1.wav") end
		Working = true
		Stop = false
		Step = 1
--		print("start")
	else
		Stop = true
--		print("manual stop")
	end
end )

-------- UI Related functions --------

local CYAN = Color(0, 230, 230)
local ORANGE = Color(230, 200, 0)
local WHITE = Color(230, 230, 230)
local RED = Color(255, 0, 0)
local GRAY = Color(230, 230, 230)
local COLORADD_HOVER = Color(13, 13, 13)
local DnDTag = "PEAKCONCOMMANDMACRO"
local MacroPanel

local function AddColors(col1, col2)
	return Color(col1.r + col2.r, col1.g + col2.g, col1.b + col2.b)
end

local draw_SimpleTextOutlined = draw.SimpleTextOutlined

local RebuildMacroSteps, UIBuild

local function labelMacroPanel(panel, text)
	local textColor = panel:GetSkin().Colours.Label.Dark
	local outlineColor = Color(255 - textColor.r, 255 - textColor.g, 255 - textColor.b)
	panel.PaintOver = function(self, w, h)
		draw_SimpleTextOutlined(text, "DermaDefault", 30, 5, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 0.75, outlineColor)
	end
end

local function closeButton(panel, callback)
	local close = vgui.Create("DImageButton", panel)
	close:SetImage("icon16/cross.png")
	close.DoClick = function(self)
		local menu = DermaMenu()
		menu:AddOption("Confirm delete?", callback)
		menu:Open()
	end
	close:SetSize(14, 14)
	return close
end

-----------------------
--MACRO PANEL CREATION
-----------------------
local CreateStep = {
	function( cpanel, tab, id ) -- Wait
		local base = vgui.Create("DPanel", cpanel)
		base:SetBackgroundColor(WHITE)
		cpanel:AddItem(base)

		base.image = vgui.Create("DImage", base)
		base.image:SetImage("icon16/clock.png")
		base.image:SizeToContents()

		labelMacroPanel(base, "Step " .. id .. ": Wait (seconds)")

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

		base.close = closeButton(base, function()
			table.remove(MacroTable, id)
			RebuildMacroSteps(cpanel)
		end)

		base.PerformLayout = function(self)
			self:SetHeight(48)

			self.image:SetPos(10, 7)

			self.entry:SetSize(self:GetWide() - 40, 15)
			self.entry:SetPos(5, 28)

			self.close:SetPos(self:GetWide() - self.close:GetWide(), 0)
		end

		base.OnCursorEntered = function(self)
			self:SetBackgroundColor(AddColors(WHITE, COLORADD_HOVER))
		end

		base.OnCursorExited = function(self)
			self:SetBackgroundColor(WHITE)
		end

		return base
	end,


	function( cpanel, tab, id ) -- Concommand
		local base = vgui.Create("DPanel", cpanel)
		base:SetBackgroundColor(CYAN)
		cpanel:AddItem(base)

		base.image = vgui.Create("DImage", base)
		base.image:SetImage("icon16/application_xp_terminal.png")
		base.image:SizeToContents()

		labelMacroPanel(base, "Step " .. id .. ": Console Command")

		base.entry = vgui.Create("DTextEntry", base)
		base.entry:SetValue(tab.Var)
		base.entry:SetUpdateOnType(true)

		base.entry.OnValueChange = function(self, val)
			val = tostring(val)
			if val then
				tab.Var = val
			end

			local boom = string.Explode("[ ;]+", val, true)

			local restricted = {}
			for k, str in ipairs(boom) do
				if IsConCommandBlocked(str) then restricted[#restricted+1] = str end
			end

			if #restricted > 0 then
				base.entry:SetTextColor(RED)
				base.entry:SetTooltip("Following commands can't be executed by Lua: " .. table.concat(restricted, ", "))
			else
				base.entry:SetTextColor(nil)
				base.entry:SetTooltip(nil)
			end
		end

		base.close = closeButton(base, function()
			table.remove(MacroTable, id)
			RebuildMacroSteps(cpanel)
		end)

		base.PerformLayout = function(self)
			self:SetHeight(48)

			self.image:SetPos(10, 7)

			self.entry:SetSize(self:GetWide() - 40, 15)
			self.entry:SetPos(5, 28)

			self.close:SetPos(self:GetWide() - self.close:GetWide(), 0)
		end

		base.OnCursorEntered = function(self)
			self:SetBackgroundColor(AddColors(CYAN, COLORADD_HOVER))
		end

		base.OnCursorExited = function(self)
			self:SetBackgroundColor(CYAN)
		end

		return base
	end,


	function( cpanel, tab, id ) -- Loop Start
		local base = vgui.Create("DPanel", cpanel)
		base:SetBackgroundColor(ORANGE)
		cpanel:AddItem(base)

		base.image = vgui.Create("DImage", base)
		base.image:SetImage("icon16/arrow_refresh.png")
		base.image:SizeToContents()

		labelMacroPanel(base, "Step " .. id .. ": Loop Start (Repeat amount)")

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
		
		base.close = closeButton(base, function()
			table.remove(MacroTable, id)
			RebuildMacroSteps(cpanel)
		end)

		base.PerformLayout = function(self)
			self:SetHeight(48)

			self.image:SetPos(10, 7)

			self.entry:SetSize(self:GetWide() - 40, 15)
			self.entry:SetPos(5, 28)

			self.close:SetPos(self:GetWide() - self.close:GetWide(), 0)
		end

		base.OnCursorEntered = function(self)
			self:SetBackgroundColor(AddColors(ORANGE, COLORADD_HOVER))
		end

		base.OnCursorExited = function(self)
			self:SetBackgroundColor(ORANGE)
		end

		base.Paint = function(self)
			local width, tall = self:GetSize()
			local frac = width/6
			local half1, half2 = tall/4, tall/1.3333
			surface.SetDrawColor(GRAY:Unpack())
			surface.DrawRect(0, half2, width, half1)
			surface.SetDrawColor(self:GetBackgroundColor():Unpack())
			surface.DrawRect(0, 0, frac, tall)
			surface.DrawRect(0, 0, width, half2)
			surface.DrawRect(frac*5, 0, frac, tall)
		end

		return base
	end,



	function( cpanel, tab, id ) -- Loop end
		local base = vgui.Create("DPanel", cpanel)
		base:SetBackgroundColor(ORANGE)
		cpanel:AddItem(base)

		base.image = vgui.Create("DImage", base)
		base.image:SetImage("icon16/arrow_redo.png")
		base.image:SizeToContents()

		labelMacroPanel(base, "Step " .. id ..": Loop End")

		base.close = closeButton(base, function()
			table.remove(MacroTable, id)
			RebuildMacroSteps(cpanel)
		end)

		base.PerformLayout = function(self)
			self:SetHeight(28)

			self.image:SetPos(10, 8)

			self.close:SetPos(self:GetWide() - self.close:GetWide(), 0)
		end

		base.OnCursorEntered = function(self)
			self:SetBackgroundColor(AddColors(ORANGE, COLORADD_HOVER))
		end

		base.OnCursorExited = function(self)
			self:SetBackgroundColor(ORANGE)
		end

		base.Paint = function(self)
			local width, tall = self:GetSize()
			local frac = width/6
			local half1, half2 = tall/4, tall/1.3333
			surface.SetDrawColor(GRAY:Unpack())
			surface.DrawRect(0, 0, width, half1)
			surface.SetDrawColor(self:GetBackgroundColor():Unpack())
			surface.DrawRect(0, 0, frac, tall)
			surface.DrawRect(0, half1, width, half2)
			surface.DrawRect(frac*5, 0, frac, tall)
		end

		return base
	end
}

UIBuild = function(cpanel, tab, id)
	local panel = CreateStep[tab.Type](cpanel, tab, id)
	panel.id = id
	panel.tab = tab
	panel:Droppable(DnDTag)

	return panel
end

RebuildMacroSteps = function(macropanel) -- Rebuilds steps without clearing the MacroTable
	if not IsValid(macropanel) then return end
	macropanel:Clear()
	macropanel.items = {}

	for id, tab in ipairs(MacroTable) do
		local panel = UIBuild(macropanel, tab, id)
		table.insert( macropanel.items, panel )
	end
end

local savepath = "cocomacro/"
local savefolder = "cocomacro"

do -- initialize the table


local var = ConFile:GetString()

if var == "default" then
	MacroTable = table.Copy(DefaultMacro)
else
	local dname = var .. ".txt"

	if not file.Exists(savepath .. dname, "DATA") then
		MacroTable = table.Copy(DefaultMacro)
	else
		local rdata = file.Read(savepath .. dname, "DATA")
		rdata = util.JSONToTable(rdata)

		MacroTable = rdata
	end
end


end

cvars.AddChangeCallback( "peak_concommac_file", function(name, old, new)
	if new == "default" then
		MacroTable = table.Copy(DefaultMacro)
	else
		local dname = new .. ".txt"

		if not file.Exists(savepath .. dname, "DATA") then
			return
		end

		local rdata = file.Read(savepath .. dname, "DATA")
		rdata = util.JSONToTable(rdata)

		MacroTable = rdata
	end

	if MacroPanel then
		RebuildMacroSteps(MacroPanel)
	end
end )

local function RefreshMacroList() end

local function CreateSavePanel( cpanel )
	local base = vgui.Create( "DPanel" )
	base:SetTall(70)
	base:SetDrawBackground(false)
	cpanel:AddItem(base)

	base.box = vgui.Create("DComboBox", base)
	base.box:SetPos(0, 5)

	function RefreshMacroList()
		base.box:Clear()

		base.box:AddChoice("Default", "default")
		local files = file.Find(savepath .. "*.txt", "DATA")
		for k, file in ipairs(files) do
			file = string.sub(file, 1, -5)
			if string.lower(file) == "default" then continue end

			base.box:AddChoice(file, file)
		end
	end

	RefreshMacroList()

	base.box.OnSelect = function(self, id, val, data)
		if data == "default" then
			Owner:ConCommand("peak_concommac_file " .. data)
			return
		end

		local dname = data .. ".txt"

		if not file.Exists(savepath .. dname, "DATA") then
			self:RemoveChoice(id)
			notification.AddLegacy("ERROR: Macro does not exist!", NOTIFY_ERROR, 5)
			surface.PlaySound("buttons/button10.wav")
			return
		end

		Owner:ConCommand("peak_concommac_file " .. data)
	end

	base.butt = vgui.Create("DImageButton", base)
	base.butt:SetSize(18, 18)
	base.butt:SetImage("icon16/disk.png")
	base.butt:SetTooltip("Save")

	base.butt.DoClick = function(self)
		local savew = vgui.Create("DFrame")
		savew:SetSize(200, 105)
		savew:Center()
		savew:MakePopup()
		savew:DoModal()
		savew:SetTitle("Save Macro")
		savew:SetBackgroundBlur(true)

		local wx, wy = savew:GetSize()

		savew.label = vgui.Create("DLabel", savew)
		savew.label:SetText("Enter Macro name to be saved:")
		savew.label:SizeToContents()
		savew.label:SetPos(wx/2 - savew.label:GetWide()/2, 30)

		savew.entry = vgui.Create("DTextEntry", savew)
		savew.entry:SetSize(190, 20)
		savew.entry:SetPos(5, 50)

		savew.sbutt = vgui.Create("DButton", savew)
		savew.sbutt:SetText("Save")
		savew.sbutt:SetSize(60, 20)
		savew.sbutt:SetPos(5, 76)
		savew.sbutt.DoClick = function(self)
			local name = string.Trim(savew.entry:GetText())
			if name == "" or string.lower(name) == "default" then return end

			if not file.IsDir( savefolder, "DATA" ) then
				file.CreateDir( savefolder )
			end

			local json = util.TableToJSON( MacroTable )
			file.Write( savepath .. name .. ".txt", json )

			notification.AddLegacy("Macro saved!", NOTIFY_GENERIC, 5)
			surface.PlaySound("buttons/button14.wav")

			RefreshMacroList()
			savew:Close()
		end

		savew.cbutt = vgui.Create("DButton", savew)
		savew.cbutt:SetText("Cancel")
		savew.cbutt:SetSize(60, 20)
		savew.cbutt:SetPos(wx - 65, 76)
		savew.cbutt.DoClick = function()
			savew:Close()
		end

	end

	base.editb = vgui.Create("DImageButton", base)
	base.editb:SetSize(18, 18)
	base.editb:SetImage("icon16/cross.png")
	base.editb:SetTooltip("Delete Macros")

	base.editb.DoClick = function()
		local frame = vgui.Create("DFrame")
		frame:SetSize(300, 200)
		frame:Center()
		frame:MakePopup()
		frame:DoModal()
		frame:SetTitle("Macro Organizer")
		frame:SetBackgroundBlur(true)

		frame.OnClose = function()
			RefreshMacroList()
		end

		local wx, wy = frame:GetSize()

		frame.list = vgui.Create("DListView", frame)
		frame.list:SetSize(150, wy - 25)
		frame.list:SetPos(0, 25)
		frame.list:AddColumn("Macro")
		frame.list:SetMultiSelect(false)

		local files = file.Find(savepath .. "*.txt", "DATA")
		for k, file in ipairs(files) do
			file = string.sub(file, 1, -5)
			if string.lower(file) == "default" then continue end

			frame.list:AddLine(file)
		end

		frame.delete = vgui.Create("DButton", frame)
		frame.delete:SetSize(70, 30)
		frame.delete:SetText("Delete")
		frame.delete:SetPos(190, 60)

		frame.delete.DoClick = function()
			local selected, pnl = frame.list:GetSelectedLine()
			if not selected then return end

			local name = savepath .. pnl:GetValue(1) .. ".txt"

			if file.Exists(name, "DATA") then
				file.Delete(name)
			end
			frame.list:RemoveLine(selected)
		end

		frame.exit = vgui.Create("DButton", frame)
		frame.exit:SetSize(70, 30)
		frame.exit:SetText("Close")
		frame.exit:SetPos(190, 120)

		frame.exit.DoClick = function()
			frame:Close()
		end
	end

	base.supchat = vgui.Create("DCheckBoxLabel", base)
	base.supchat:SetDark(true)
	base.supchat:SetText("Suppress chat messages")
	base.supchat:SetConVar("peak_concommac_messageoff")
	base.supchat:SetPos(0, 30)

	base.supsnd = vgui.Create("DCheckBoxLabel", base)
	base.supsnd:SetDark(true)
	base.supsnd:SetText("Suppress sounds")
	base.supsnd:SetConVar("peak_concommac_soundoff")
	base.supsnd:SetPos(0, 50)

	base.PerformLayout = function()

		base.box:SetSize(base:GetWide() - 55, 20)

		base.butt:SetPos(base:GetWide() - 45, 5)
		base.editb:SetPos(base:GetWide() - 20, 5)

	end
end

local function CreateExpansionButtons(cpanel, macrobase)
	local buttonbase = vgui.Create("Panel", cpanel)
	cpanel:AddItem(buttonbase)
	buttonbase.buttpanel = vgui.Create("DPanel", buttonbase)
	buttonbase.buttpanel:SetPaintBackgroundEnabled(true)
	buttonbase.buttpanel:SetBackgroundColor(GRAY)

	buttonbase.addbutton = vgui.Create("DImageButton", buttonbase.buttpanel)
	buttonbase.addbutton:SetSize(18, 18)
	buttonbase.addbutton:SetImage("icon16/add.png")

	buttonbase.addbutton.DoClick = function()
		local function ExpandMacro(typeid)
			if Working then return end

			local tab
			if typeid ~= 4 then
				tab = { Type = typeid, Var = "" }
			else
				tab = { Type = typeid }
			end

			table.insert( MacroTable, tab )
			table.insert( macrobase.items, UIBuild(macrobase, tab, #MacroTable) )
		end

		local dmenu = DermaMenu()
		local option = dmenu:AddOption( "Add Wait", function() ExpandMacro(1) end )
		option:SetIcon("icon16/clock.png")
		option = dmenu:AddOption( "Add Console Command", function() ExpandMacro(2) end )
		option:SetIcon("icon16/application_xp_terminal.png")
		option = dmenu:AddOption( "Add Loop Start", function() ExpandMacro(3) end )
		option:SetIcon("icon16/arrow_refresh.png")
		option = dmenu:AddOption( "Add Loop End", function() ExpandMacro(4) end )
		option:SetIcon("icon16/arrow_redo.png")
		dmenu:Open()
	end

	buttonbase.removebutton = vgui.Create("DImageButton", buttonbase.buttpanel)
	buttonbase.removebutton:SetSize(18, 18)
	buttonbase.removebutton:SetImage("icon16/delete.png")


	buttonbase.removebutton.DoClick = function()
		if Working then return end

		local id = #MacroTable
		if id < 1 then return end

		MacroTable[id] = nil

		macrobase.items[id]:Remove()
		macrobase.items[id] = nil
	end

	buttonbase.removebutton.DoRightClick = function()
		local dmenu = DermaMenu()
		dmenu:AddOption( "Delete every step", function()
			if Working then return end

			for id, panel in ipairs(macrobase.items) do
				panel:Remove()
			end

			macrobase.items = {}
			MacroTable = {}
		end )
		dmenu:Open()
	end

	buttonbase.PerformLayout = function(self)
		self:SetHeight(22)

		buttonbase.buttpanel:SetPos(self:GetWide()/2 - 30)
		buttonbase.buttpanel:SetSize(60, 22)

		self.addbutton:SetPos(5, 2)

		self.removebutton:SetPos(37, 2)
	end

	return buttonbase
end

local function DragDrop(self, panel, drop, _, x, y)
	if drop and not Working then
		local items = self.items
		local maxitem = #items

		for k, p in ipairs(panel) do
			local newid = 1
			local ymin = 0

			for k, cp in ipairs(items) do
				if k == p.id then continue end
				local ythis = cp:GetY() + 10
				if (ythis >= ymin) and (y >= ythis) then
					ymin = ythis
					newid = k + 1
				end
			end
			if p.id < newid then newid = newid - 1 end
			if newid > maxitem then newid = maxitem end

			table.remove(MacroTable, p.id)
			table.insert(MacroTable, newid, p.tab)
			RebuildMacroSteps(self)
		end
	end
end

local function MacroMenu( cpanel )
	local macrobase = vgui.Create("DPanelList", cpanel)
	macrobase:SetPaintBackgroundEnabled(false)
	macrobase:SetSpacing(6)
	cpanel:AddItem(macrobase)

	macrobase.items = {}
	macrobase:Receiver(DnDTag, DragDrop)

	for id, tab in ipairs(MacroTable) do
		local panel = UIBuild(macrobase, tab, id)
		table.insert( macrobase.items, panel )
	end

	macrobase.OldPerform = macrobase.PerformLayout

	macrobase.PerformLayout = function(self)
		self:OldPerform()
		self:SizeToChildren(false, true)
	end



	buttonbase = CreateExpansionButtons(cpanel, macrobase)

	return macrobase, buttonbase
end

local function MacroBuild( Panel )
	if not Owner or not IsValid(Owner) then Owner = LocalPlayer() end

	CreateSavePanel(Panel)

	local startbutton = vgui.Create( "DButton", Panel )
	startbutton:SetSize( 100, 20 )
	startbutton:SetText( "Start" )

	startbutton.DoClick = function()
		Owner:ConCommand( "peak_mac_start" )
	end
	Panel:AddItem(startbutton)

	MacroPanel = MacroMenu( Panel )
end

hook.Add("PopulateToolMenu", "peak_macroconcommand", function ()
	spawnmenu.AddToolMenuOption( "Utilities", "PEAK Incompetence", "peak_mcc", "Concommand Macro", "", "", MacroBuild )
end)
