local topScreen
local course
local song
local group
local wheel

local function doUpdate()
	return getTabIndex() == 1
end


local t = Def.ActorFrame{
	BeginCommand = cmd(queuecommand,"Set");
	InitCommand = function(self) self:xy(0,-100):diffusealpha(0) end;
	OffCommand = function(self) self:finishtweening() self:bouncy(0.3) self:xy(0,-100):diffusealpha(0) end;
	OnCommand = function(self) 
		self:bouncy(0.3)
		self:xy(0,0):diffusealpha(1)
		topScreen = SCREENMAN:GetTopScreen()
		song = GAMESTATE:GetCurrentSong()
		course = GAMESTATE:GetCurrentCourse()
		if topScreen then
			wheel = topScreen:GetMusicWheel()
		end
	end;
	SetCommand = function(self)
		if doUpdate() then
			song = GAMESTATE:GetCurrentSong()
			course = GAMESTATE:GetCurrentCourse()
			group = topScreen:GetMusicWheel():GetSelectedSection()

			self:GetChild("Banner"):queuecommand("Set")
			self:GetChild("CDTitle"):queuecommand("Set")
			self:GetChild("songTitle"):queuecommand("Set")
			self:GetChild("songLength"):queuecommand("Set")

		end
	end;
	TabChangedMessageCommand = function(self) 
		if doUpdate() then
			self:queuecommand("Set")
			self:playcommand("On")
		else
			self:playcommand("Off")
		end
	end;
	PlayerJoinedMessageCommand = function(self) self:queuecommand("Set") end;
	CurrentSongChangedMessageCommand = function(self) self:queuecommand("Set") end;
};

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2,120)
		self:zoomto(capWideScale(get43size(384),384)+10,capWideScale(get43size(120),120)+50)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)		
	end
}

-- Song banner
t[#t+1] = Def.Banner{
	Name = "Banner";
	InitCommand = cmd(xy,SCREEN_CENTER_X/2,120;);
	SetCommand = function(self)
		self:stoptweening()
		self:sleep(0.5)
		if topScreen:GetName() == "ScreenSelectMusic" or topScreen:GetName() == "ScreenNetSelectMusic" then
			if song then
				self:LoadFromSong(song)
			elseif course then
				self:LoadFromCourse(song)
			elseif group then
				self:LoadFromSongGroup(group)
			end
			self:scaletoclipped(capWideScale(get43size(384),384),capWideScale(get43size(120),120))
		end
	end
}

t[#t+1] = Def.Sprite {
	Name = "CDTitle";
	InitCommand = function(self)
		self:x(SCREEN_CENTER_X/2+(capWideScale(get43size(384),384)/2)-40)
		self:y(120-(capWideScale(get43size(120),120)/2)+30)
		self:wag():effectmagnitude(0,0,5)
		self:diffusealpha(0.8)
	end;
	SetCommand = function(self)
		self:finishtweening()
		if song then
			if song:HasCDTitle() then
				self:visible(true)
				self:Load(song:GetCDTitlePath())
			else
				self:visible(false)
			end
		else
			self:visible(false)
		end;
		self:playcommand("AdjustSize")
		self:smooth(0.5)
		self:diffusealpha(1)
	end;
	AdjustSizeCommand = function(self)
		local height = self:GetHeight()
		local width = self:GetWidth()
		if height >= 60 and width >= 80 then
			if height*(80/60) >= width then
				self:zoom(60/height)
			else
				self:zoom(80/width)
			end
		elseif height >= 60 then
			self:zoom(60/height)
		elseif width >= 80 then
			self:zoom(80/width)
		else
			self:zoom(1)
		end
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:finishtweening()
		self:smooth(0.5)
		self:diffusealpha(0)
	end
};

-- Song title // Artist on top of the banner
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songTitle";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2-capWideScale(get43size(384),384)/2+5,132+capWideScale(get43size(60),60))
		self:halign(0)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)
		self:diffuse(color(colorConfig:get_data().selectMusic.BannerText))
	end;
	SetCommand = function(self)

		if song then
			self:settext(song:GetDisplayMainTitle().." // "..song:GetDisplayArtist())
		else
			if wheel then
				self:settext(wheel:GetSelectedSection())
			end
		end
	end
};

-- Song length (todo: take rates into account..?)
t[#t+1] = LoadFont("Common Normal") .. {
	Name="songLength";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X/2+capWideScale(get43size(384),384)/2-5,132+capWideScale(get43size(60),60))
		self:halign(1)
		self:zoom(0.45)
		self:maxwidth(capWideScale(get43size(340),340)/0.45)	
	end;	
	SetCommand = function(self)
		local seconds = 0
		if song ~= nil then
			seconds = song:GetStepsSeconds()
			self:settext(SecondsToMSS(seconds))
			self:diffuse(getSongLengthColor(seconds))
		else
			self:settext(SecondsToMSS(0))
		end
	end
};


return t