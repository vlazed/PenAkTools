local BigemsBinted = false
local PropReplacers = {}
local DataDir = "propreplace/"

concommand.Add("penak_spawnsr", function(ply, cmd, args)
	if !game.SinglePlayer() then return end
	if CLIENT then return end
	
	if !file.Exists(DataDir, "DATA") then
		file.CreateDir(DataDir)
	end
	
	if !BigemsBinted then
		local path = args[1]
		if !path then return end
		if !file.Exists(DataDir .. path, "DATA") then return end
		print("Spawning props from " .. path)
		local json = file.Read(DataDir .. path, "DATA")
		local Reading = util.JSONToTable(json)
		
		for k, v in pairs(Reading.PropTable) do
			local prop = ents.Create("prop_dynamic")
			prop:SetPos(v.Pos)
			prop:SetAngles(v.Ang)
			prop:SetModel(v.Model)
			prop:SetSkin(v.Skin)
			prop:Spawn()
			
			table.insert(PropReplacers, prop)
		end
		
		BigemsBinted = true
	else
		print("Clearing props!")
		for k, v in pairs(PropReplacers) do
			v:Remove()
		end
		PropReplacers = {}
		BigemsBinted = false
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
