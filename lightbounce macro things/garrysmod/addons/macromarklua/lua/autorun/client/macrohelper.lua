local FunnyImage = Material( "hud/dummy" )
local CommandEnable = 0


concommand.Add("penak_macro_mark", function()

	if (CommandEnable == 0) then
		CommandEnable = 1
		
		hook.Add( "HUDPaint", "ImagePaint", function()

			surface.SetMaterial( FunnyImage )
			surface.SetDrawColor( 255, 255, 255 )
			surface.DrawTexturedRect( ScrW() - 74, 10, 64, 64 )

		end )
		
		print("Macro mark enabled")
		
	else
		CommandEnable = 0
		hook.Remove( "HUDPaint", "ImagePaint")
		print("Macro mark disabled")
	end
end)