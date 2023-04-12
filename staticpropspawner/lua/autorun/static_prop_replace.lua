require("niknaks")

if not NikNaks then
	error("Static Prop Replacer: NikNaks library is required! https://steamcommunity.com/sharedfiles/filedetails/?id=2861839844")
	return
end

local CurMap = NikNaks.CurrentMap
local CurMapName = CurMap:GetMapName()
local StaticProps = NikNaks.CurrentMap:GetStaticProps()

local BigemsBinted = false
local PropReplacers = {}
local DataDir = "propreplace/"

concommand.Add("peak_replace_st_props_fromfile", function(ply, cmd, args)
	if not game.SinglePlayer() then return end
	if CLIENT then return end

	if not file.Exists(DataDir, "DATA") then
		file.CreateDir(DataDir)
	end

	if not BigemsBinted then
		local path = args[1]
		if not path then return end
		if not file.Exists(DataDir .. path, "DATA") then return end
		print("Spawning props from " .. path)
		local json = file.Read(DataDir .. path, "DATA")
		local Reading = util.JSONToTable(json)
		if Reading.PropTable then
			Reading = Reading.PropTable
		end

		for k, v in pairs(Reading) do
			local prop = ents.Create("prop_dynamic")
			prop:SetPos(v.Pos)
			prop:SetAngles(v.Ang)
			prop:SetModel(v.Model)
			prop:SetSkin(v.Skin)
			prop:Spawn()
			
			table.insert(PropReplacers, prop)
		end

		BigemsBinted = true
		ply:ConCommand("r_drawstaticprops 0")
	else
		print("Clearing props!")
		for k, v in pairs(PropReplacers) do
			v:Remove()
		end
		PropReplacers = {}
		BigemsBinted = false
		ply:ConCommand("r_drawstaticprops 1")
	end
end,

function(cmd, stringargs)
	stringargs = string.Trim(stringargs)
	stringargs = string.lower(stringargs)
	
	local result = {}
	local files = file.Find(DataDir .. "*.txt","DATA")
	for k, v in ipairs(files) do
		local fileresult
		if string.find(string.lower(v), stringargs) then
			fileresult = cmd .. " " .. v
			
			table.insert(result, fileresult)
		end
	end
	
	return result
end)

concommand.Add("peak_replace_st_props", function(ply, cmd, args)
	if not game.SinglePlayer() then return end
	if CLIENT then return end

	if not BigemsBinted then
		if not CurMap then return end
		print("Spawning props from " .. CurMapName)
		

		for k, v in pairs(StaticProps) do
			local prop = ents.Create("prop_dynamic")
			prop:SetPos(v:GetPos())
			prop:SetAngles(v:GetAngles())
			prop:SetModel(v:GetModel())
			prop:SetSkin(v:GetSkin())
			prop:Spawn()

			table.insert(PropReplacers, prop)
		end

		BigemsBinted = true
		ply:ConCommand("r_drawstaticprops 0")
	else
		print("Clearing props!")
		for k, v in pairs(PropReplacers) do
			v:Remove()
		end
		PropReplacers = {}
		BigemsBinted = false
		ply:ConCommand("r_drawstaticprops 1")
	end
end)

concommand.Add("peak_create_static_prop_data", function(ply, cmd, args)
	if not game.SinglePlayer() then return end
	if CLIENT then return end

	if not file.Exists(DataDir, "DATA") then
		file.CreateDir(DataDir)
	end

	if not CurMap then return end
	print("Creating static props data from " .. CurMapName)

	local datatable = {}

	for k, v in pairs(StaticProps) do
		datatable[k] = {}
		datatable[k].Pos = v:GetPos()
		datatable[k].Ang = v:GetAngles()
		datatable[k].Model = v:GetModel()
		datatable[k].Skin = v:GetSkin()
	end

	local json = util.TableToJSON(datatable, true)
	file.Write(DataDir .. CurMapName .. ".txt", json)
end)
