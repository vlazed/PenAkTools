local matScreen = Material( "models/weapons/v_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )
local toolmode = GetConVar( "gmod_toolmode" )
local TEX_SIZE = 256
local FunNum = 1

CreateConVar("penak_scroll_frame", FunNum, FCVAR_NONE, "Set frame for scrolling textures", 1, nil)
CreateConVar("penak_scroll_framerate", 30, FCVAR_NONE, "Set framerate for scrolling textures", 1, nil)
CreateConVar("penak_special", 0.0, FCVAR_NONE, "Set a value for special textures (Like Uber)", 0, nil)

concommand.Add("penak_scroll_next", function()
	local ThingVar = GetConVar("penak_scroll_frame")
	FunNum = ThingVar:GetInt()
	ThingVar:SetInt(FunNum + 1)
	FunNum = ThingVar:GetInt()
	print("Frame: " .. FunNum)
end)

concommand.Add("penak_scroll_previous", function()
	local ThingVar = GetConVar("penak_scroll_frame")
	FunNum = ThingVar:GetInt()
	ThingVar:SetInt(FunNum - 1)
	FunNum = ThingVar:GetInt()
	print("Frame: " .. FunNum)
end)

matproxy.Add({
	name = "ScrollMagic",
	
	init = function(self, mat, values)
		self.textureScroll = values.texturescrollvar
		self.scrollRate = values.texturescrollrate
		self.scrollAngle = values.texturescrollangle
	end,
	
	bind = function(self, mat, ent)

		local FrameThing = GetConVar("penak_scroll_framerate")
		local ThingVar = GetConVar("penak_scroll_frame")
		
		local yvar = math.sin( math.rad( self.scrollAngle ) ) * ( self.scrollRate / FrameThing:GetFloat() * ThingVar:GetFloat() )
		local xvar = math.cos( math.rad( self.scrollAngle ) ) * ( self.scrollRate / FrameThing:GetFloat() * ThingVar:GetFloat() )
		
		mat:SetVector(self.textureScroll, Vector(xvar, yvar))
	end
})

matproxy.Add({
	name = "AnimeMagic",
	
	init = function(self, mat, values)
		self.framerate = values.animatedtextureframerate
		self.texture = values.animatedtextureframenumvar
		self.framecount = values.frametotal
		self.startframe = values.startframe
	end,
	
	bind = function(self, mat, ent)

		local VideoRate = GetConVar("penak_scroll_framerate"):GetInt()
		local Frame = GetConVar("penak_scroll_frame"):GetInt()
		
		local FrameCount = Frame * ( self.framerate / VideoRate ) + self.startframe 
		if(FrameCount >= self.framecount) then
			FrameCount = FrameCount - math.floor(FrameCount/self.framecount)*self.framecount
		end
		mat:SetInt(self.texture, FrameCount)
	end
})


for i = 1, 10 do -- Apparently you can't just use 1 proxy multiple times in .vmt. So I've made 10 of Sines since those things can be used multiple times in one vmt.
	matproxy.Add({
		name = "SMSine" .. i,
		
		init = function(self, mat, values)
			self.period = values.sineperiod
			self.min = values.sinemin
			self.max = values.sinemax
			self.result = values.resultvar
			if values.timeoffset then
				self.phase = values.timeoffset
			else
				self.phase = 0
			end
		end,
		
		bind = function(self, mat, ent)
		
			local VideoRate = GetConVar("penak_scroll_framerate"):GetInt()
			local Frame = GetConVar("penak_scroll_frame"):GetInt()
			
			local minstuff = isstring(self.min) and mat:GetFloat(self.min) or self.min
			local maxstuff = isstring(self.max) and mat:GetFloat(self.max) or self.max
			local Value = minstuff + (maxstuff - minstuff) / 2 * ( 1 + math.sin( 2 * math.pi * (1 / self.period) * (Frame / VideoRate) + self.phase ) )
			mat:SetFloat(self.result, Value)
		end
	})
end

matproxy.Add({
	name = "SpecialScript",
	
	init = function(self, mat, values)
		self.num = values.resultvar
	end,
	
	bind = function(self, mat, ent)
		local ConsoleGet = GetConVar("penak_special"):GetFloat()
		
		mat:SetFloat(self.num, ConsoleGet)
	end
})

-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local RTTexture = GetRenderTarget( "GModToolgunScreen", TEX_SIZE, TEX_SIZE )

surface.CreateFont( "GModToolScreen", {
	font	= "Helvetica",
	size	= 60,
	weight	= 900
} )

local function DrawScrollingText( text, y, texwide )

	local FrameThing = GetConVar("penak_scroll_framerate")
	local ThingVar = GetConVar("penak_scroll_frame")
	
	local w, h = surface.GetTextSize( text )
	w = w + 64

	y = y - h / 2 -- Center text to y position

	local x = (ThingVar:GetFloat() / FrameThing:GetFloat()) * 250 % w * -1

	 while ( x < texwide ) do
		
		surface.SetTextColor( 0, 0, 0, 255 )
		surface.SetTextPos( x + 3, y + 3 )
		surface.DrawText( text )

		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		x = x + w
	end
	
	
end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
function SWEP:RenderScreen()

	-- Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	-- Set up our view for drawing to the texture
	render.PushRenderTarget( RTTexture )
	cam.Start2D()

		-- Background
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetTexture( txBackground )
		surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

		-- Give our toolmode the opportunity to override the drawing
		if ( self:GetToolObject() && self:GetToolObject().DrawToolScreen ) then

			self:GetToolObject():DrawToolScreen( TEX_SIZE, TEX_SIZE )

		else

			surface.SetFont( "GModToolScreen" )
			DrawScrollingText( "#tool." .. toolmode:GetString() .. ".name", 104, TEX_SIZE )

		end

	cam.End2D()
	render.PopRenderTarget()

end