local t = Def.ActorFrame{}

setLastSecond(0)

if GAMESTATE:GetNumPlayersEnabled() == 1 and themeConfig:get_data().eval.ScoreBoardEnabled then
	t[#t+1] = LoadActor("scoreboard")
end;

if themeConfig:get_data().eval.CurrentTimeEnabled then
	t[#t+1] = LoadActor("currenttime")
end;

if themeConfig:get_data().eval.JudgmentBarEnabled then
	t[#t+1] = LoadActor("adefaultmoreripoff")
end;

--t[#t+1] = LoadActor("mousetest")
--t[#t+1] = LoadActor("soundtest")

t[#t+1] = Def.ActorFrame{
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,20,140;zoom,0.4;maxwidth,100/0.4;halign,0;);
		BeginCommand=function(self)
			self:settextf("Timing Difficulty: %d",GetTimingDifficulty())
		end;
	};
	LoadFont("Common Normal")..{
		InitCommand=cmd(xy,20,155;zoom,0.4;maxwidth,100/0.4;halign,0;);
		BeginCommand=function(self)
			self:settextf("Life Difficulty: %d",GetLifeDifficulty())
		end;
	};
};

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=cmd(xy,SCREEN_CENTER_X,135;zoom,0.4;maxwidth,400/0.4);
	BeginCommand=cmd(queuecommand,"Set");
	SetCommand=function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext(GAMESTATE:GetCurrentCourse():GetDisplayFullTitle().." // "..GAMESTATE:GetCurrentCourse():GetScripter())
		else
			self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle().." // "..GAMESTATE:GetCurrentSong():GetDisplayArtist()) 
		end;
	end;
};


-- Life graph and the stuff that goes with it
local function GraphDisplay( pn )
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	local t = Def.ActorFrame {
		Def.GraphDisplay {
			InitCommand=cmd(Load,"GraphDisplay");
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set( ss, ss:GetPlayerStageStats(pn))
				self:diffusealpha(0.7);
				self:GetChild("Line"):diffusealpha(0)
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35))
				end
			end
		};

		LoadFont("Common Large")..{
			Name = "Grade";
			InitCommand=cmd(xy,-SCREEN_CENTER_X*0.30,15;zoom,0.7;maxwidth,70/0.8;halign,0;);
			BeginCommand=function(self) 
				self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetGrade()))) 
			end;
		};

		LoadFont("Common Normal")..{
			InitCommand=cmd(y,15;zoom,0.6;);
			BeginCommand=function(self) 
				local score = getCurScoreST(pn,0)
				local maxScore = getMaxScoreST(pn,0)
				local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
				self:halign(0)
				self:settext(percentText)
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth(),70/0.8)*0.8))
				else
					self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth(),70/0.8)*0.8))
				end
			end;
		};

		LoadFont("Common Normal")..{
			InitCommand=cmd(xy,WideScale(get43size(140),140)-5,-35;zoom,0.4;halign,1;valign,0;diffusealpha,0.7;);
			BeginCommand=function(self)
				local text = ""
				text = string.format("Life: %.0f%%",pss:GetCurrentLife()*100)
				if pss:GetCurrentLife() == 0 then
					text = string.format("%s\n%.2fs Survived",text,pss:GetAliveSeconds())
				end
				if gameplay_pause_count > 0 then
					text = string.format("%s\nPaused %d Time(s)",text,gameplay_pause_count)
				end
				self:settext(text)
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35)+WideScale(get43size(140),140)-5)
				end
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(SCREEN_CENTER_X*0.30)
					self:halign(1)
				end;
			end;
		};
		LoadFont("Common Normal")..{
			InitCommand=cmd(xy,WideScale(get43size(140),140)-5,30;zoom,0.4;halign,1;valign,0;diffusealpha,0.7;);
			BeginCommand=function(self) 
				local steps = GAMESTATE:GetCurrentSteps(pn);
				local notes = 0
				if steps ~= nil then
					notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
				end
				self:settextf("%d Notes",notes)
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2)then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35)+WideScale(get43size(140),140)-5)
				end
				if GAMESTATE:GetNumPlayersEnabled() == 2 and pn == PLAYER_2 then
					self:x(SCREEN_CENTER_X*0.30)
					self:halign(1)
				end
			end;
		};

	};
	return t;
end

local function ComboGraph( pn )
	local t = Def.ActorFrame {
		Def.ComboGraph {
			InitCommand=cmd(Load,"ComboGraph"..ToEnumShortString(pn););
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set(ss,ss:GetPlayerStageStats(pn))
				if GAMESTATE:GetNumPlayersEnabled() == 1 and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
					self:x(-(SCREEN_CENTER_X*1.65)+(SCREEN_CENTER_X*0.35))
				end
			end
		};
	};
	return t;
end;

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}

local pssP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local pssP2 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_2)

local frameX = 20
local frameY = 170
local frameWidth = SCREEN_CENTER_X-60

function scoreBoard(pn,position)
	local hsTable = getScoreList(pn)
	local t = Def.ActorFrame{
		BeginCommand=function(self)
			if position == 1 then
				self:x(SCREEN_WIDTH-(frameX*2)-frameWidth)
			end;
		end;
	}

	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX-5,frameY;zoomto,frameWidth+10,220;halign,0;valign,0;diffuse,color("#333333CC");)
	}

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY+55;zoomto,frameWidth,2;halign,0;)
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+frameWidth,frameY+0;zoom,0.5;halign,1;valign,1);
		BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,0.05");effectcolor2,color("1,1,1,0");effectperiod,2;queuecommand,"Set");
		SetCommand=function(self) 
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			self:settext(stype.." "..diff.." "..meter)
			self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX,frameY+13;zoom,0.45;halign,0);
		BeginCommand=cmd(settext,"ClearType:")
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.5,frameY+13;zoom,0.45);
		BeginCommand=cmd(settext,">>")
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.25,frameY+13;zoom,0.40;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			if score ~= nil then
				local index
				if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
					index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
				else
					index = pss:GetPersonalHighScoreIndex()+1
				end
				self:settext(getHighestClearType(pn,index,1)); 
				self:diffuse(getHighestClearType(pn,index,2))
				self:diffusealpha(0.7)
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.75,frameY+13;zoom,0.40;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			if score ~= nil then
				self:settext(getClearTypeFromScore(pn,score,1)); 
				self:diffuse(getClearTypeFromScore(pn,score,2))
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)+10,frameY+13;zoom,0.30;maxwidth,20/0.3);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local recCT = getHighestClearType(pn,index,3)
			local curCT = getClearTypeFromScore(pn,score,3)
			if curCT < recCT then
				self:settext("↑")
			elseif curCT > recCT then
				self:settext("↓")
			else
				self:settext("→")
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX,frameY+28;zoom,0.45;halign,0);
		BeginCommand=function(self)
			self:settextf("Score(%s):",getScoreTypeText(0))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.5,frameY+28;zoom,0.45);
		BeginCommand=cmd(settext,">>")
	};


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.25,frameY+28;zoom,0.4;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local score = getBestScore(pn,index,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			if IsUsingWideScreen() then
				self:settextf("%s (%d/%d)",percentText,score,maxScore)
			else
				self:settextf("%s",percentText)
			end
			self:diffusealpha(0.7)
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.75,frameY+28;zoom,0.4;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = getCurScoreST(pn,0)
			local maxScore = getMaxScoreST(pn,0)
			local percentText = string.format("%05.2f%%",math.floor((score/maxScore)*10000)/100)
			if IsUsingWideScreen() then
				self:settextf("%s (%d/%d)",percentText,score,maxScore)
			else
				self:settextf("%s",percentText)
			end
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)+10,frameY+28;zoom,0.30;maxwidth,30/0.3);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local recScore = getBestScore(pn,index,0)
			local curScore = getCurScoreST(pn,0)
			local diff = curScore - recScore
			local extra = ""
			if diff >= 0 then
				extra = "+"
			end;
			self:settextf("%s%d",extra,diff)
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX,frameY+43;zoom,0.45;halign,0);
		BeginCommand=cmd(settext,"MissCount:")
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.5,frameY+43;zoom,0.45);
		BeginCommand=cmd(settext,">>")
	};


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.25,frameY+43;zoom,0.4;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local missCount = getBestMissCount(pn,index)
			if missCount ~= nil then
				self:settext(missCount)
			else
				self:settext("-")
			end;
			self:diffusealpha(0.7)
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)*0.75,frameY+43;zoom,0.4;);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local score = pss:GetHighScore();
			local missCount = getScoreMissCount(score)
			self:settext(missCount)
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+50+(frameWidth-80)+10,frameY+43;zoom,0.30;maxwidth,30/0.3);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			local index
			if  GetPlayerOrMachineProfile(pn) == PROFILEMAN:GetMachineProfile() then
				index = pss:GetMachineHighScoreIndex()+2 -- i have no idea why the indexes are screwed up for this
			else
				index = pss:GetPersonalHighScoreIndex()+1
			end
			local score = pss:GetHighScore();
			
			local recMissCount = (getBestMissCount(pn,index))
			local curMissCount = getScoreMissCount(score)
			local diff = 0
			local extra = ""
			if recMissCount ~= nil then
				diff = curMissCount - recMissCount
				if diff >= 0 then
					extra = "+"
				end;
				self:settext(extra..diff)
			else
				self:settext("+"..curMissCount)
			end;
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+5,frameY+63;zoom,0.40;halign,0;maxwidth,frameWidth/0.4);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settext(pss:GetHighScore():GetModifiers())
		end;
	};

	for k,v in ipairs(judges) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,frameX,frameY+80+((k-1)*22);zoomto,frameWidth,18;halign,0;diffuse,TapNoteScoreToColor(v);diffusealpha,0.5;);
		};
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,frameX,frameY+80+((k-1)*22);zoomto,0,18;halign,0;diffuse,TapNoteScoreToColor(v);diffusealpha,0.5;);
			BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,"..tostring(pss:GetPercentageOfTaps(v)*0.4));effectcolor2,color("1,1,1,0");sleep,0.5;decelerate,2;zoomx,frameWidth*pss:GetPercentageOfTaps(v));
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+10,frameY+80+((k-1)*22);zoom,0.50;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self) 
				self:settext(getJudgeStrings(v))
			end;
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+frameWidth-40,frameY+80+((k-1)*22);zoom,0.50;halign,1);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self) 
				self:settext(pss:GetTapNoteScores(v))
			end;
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=cmd(xy,frameX+frameWidth-38,frameY+80+((k-1)*22);zoom,0.30;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self) 
				local text = pss:GetPercentageOfTaps(v)*100
				if tostring(text) == "-nan(ind)" then
					text = 0
				end
				self:settextf("(%03.2f%%)",text)
			end;
		};
	end;

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+(frameWidth*0.1),frameY+210;zoom,0.35;maxwidth,((frameWidth/5)-5)/0.35);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Holds %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Holds"),pss:GetRadarPossible():GetValue("RadarCategory_Holds"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+(frameWidth*0.3),frameY+210;zoom,0.35;maxwidth,((frameWidth/5)-5)/0.35);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Rolls %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Rolls"),pss:GetRadarPossible():GetValue("RadarCategory_Rolls"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+(frameWidth*0.5),frameY+210;zoom,0.35;maxwidth,((frameWidth/5)-5)/0.35);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Mines %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Mines"),pss:GetRadarPossible():GetValue("RadarCategory_Mines"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+(frameWidth*0.7),frameY+210;zoom,0.35;maxwidth,((frameWidth/5)-5)/0.35);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Lifts %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Lifts"),pss:GetRadarPossible():GetValue("RadarCategory_Lifts"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX+(frameWidth*0.9),frameY+210;zoom,0.35;maxwidth,((frameWidth/5)-5)/0.35);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Fakes %03d/%03d",pss:GetRadarActual():GetValue("RadarCategory_Fakes"),pss:GetRadarPossible():GetValue("RadarCategory_Fakes"))
		end;
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=cmd(xy,frameX,frameY+230;zoom,0.35;halign,0);
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self) 
			self:settextf("Unstable Rate: %0.1f",getUnstableRateST(pn))
		end;
	};


	return t
end;


if GAMESTATE:GetNumPlayersEnabled() >= 1 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		--initScoreList(PLAYER_1)
		t[#t+1] = scoreBoard(PLAYER_1,0)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_1), GraphDisplay(PLAYER_1) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_1),ComboGraph(PLAYER_1) );
		end;
	elseif GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		--initScoreList(PLAYER_2)
		t[#t+1] = scoreBoard(PLAYER_2,0)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_2), GraphDisplay(PLAYER_2) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_2),ComboGraph(PLAYER_2) );
		end;
	end;
end;
if GAMESTATE:GetNumPlayersEnabled() == 2 then
	--initScoreList(PLAYER_2)
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		t[#t+1] = scoreBoard(PLAYER_2,1)
		if ShowStandardDecoration("GraphDisplay") then
			t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_2), GraphDisplay(PLAYER_2) )
		end;
		if ShowStandardDecoration("ComboGraph") then
			t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_2),ComboGraph(PLAYER_2) );
		end;
	end;
end;

return t