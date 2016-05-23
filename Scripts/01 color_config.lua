local defaultConfig = {

	main = {
		frame = "#000000",
		highlight = "#00AEEF",
		background = "#FFFFFF",
		enabled = "#4CBB17",
		disabled = "#666666",
		negative = "#FF9999",
		positive = "#66ccff",
		headerText = "#FFFFFF",
	},

	clearType = {
		MFC		= "#66ccff",
		WF		= "#dddddd",
		SDP 	= "#cc8800",
		PFC 	= "#eeaa00",
		BF		= "#999999",
		SDG		= "#448844",
		FC		= "#66cc66",
		MF		= "#cc6666",
		SDCB	= "#666666",
		Clear	= "#33aaff",
		Failed	= "#e61e25",
		Invalid	= "#e61e25",
		NoPlay	= "#666666",
		None	= "#666666",
	},

	difficulty = {
		Difficulty_Beginner	= "#66ccff",		-- light blue
		Difficulty_Easy		= "#099948",		-- green
		Difficulty_Medium	= "#ddaa00",		-- yellow
		Difficulty_Hard		= "#ff6666",		-- red
		Difficulty_Challenge= "#c97bff",	-- light blue
		Difficulty_Edit 	= "#666666",	-- gray
		Difficulty_Couple	= "#ed0972",			-- hot pink
		Difficulty_Routine	= "#ff9a00",			-- orange
		Beginner	= "#66ccff",		
		Easy		= "#099948",		-- green
		Medium		= "#ddaa00",		-- yellow
		Hard		= "#ff6666",		-- red
		Challenge 		= "#c97bff",	-- Purple
		Edit 		= "#666666",	-- gray
		Couple		= "#ed0972",			-- hot pink
		Routine		= "#ff9a00",			-- orange
		Crazy 		= "#ff6666",		-- red
		Nightmare	= "#c97bff",	-- Purple
		HalfDouble 	= "#666666",	-- gray
		HalfDouble 	= "#666666",	-- gray
		Freestyle 	= "#666666",	-- gray
	},

	grade = {
		Grade_Tier01	= "#66ccff", -- AAAA
		Grade_Tier02	= "#eebb00", -- AAA
		Grade_Tier03	= "#66cc66", -- AA
		Grade_Tier04	= "#da5757", -- A
		Grade_Tier05	= "#5b78bb", -- B
		Grade_Tier06	= "#c97bff", -- C
		Grade_Tier07	= "#8c6239", -- D
		Grade_Tier08	= "#000000", -- ITG PLS
		Grade_Tier09	= "#000000", -- ITG PLS
		Grade_Tier10	= "#000000", -- ITG PLS
		Grade_Tier11	= "#000000", -- ITG PLS
		Grade_Tier12	= "#000000", -- ITG PLS
		Grade_Tier13	= "#000000", -- ITG PLS
		Grade_Tier14	= "#000000", -- ITG PLS
		Grade_Tier15	= "#000000", -- ITG PLS
		Grade_Tier16	= "#000000", -- ITG PLS
		Grade_Tier17	= "#000000", -- ITG PLS
		Grade_Failed	= "#cdcdcd", -- F
		Grade_None		= "#666666", -- no play
	},

	judgment = { -- Colors of each Judgment types
		TapNoteScore_W1 = "#99ccff",
		TapNoteScore_W2	= "#f2cb30",
		TapNoteScore_W3	 = "#14cc8f",
		TapNoteScore_W4	= "#1ab2ff",
		TapNoteScore_W5	= "#ff1ab3",
		TapNoteScore_Miss = "#cc2929",			
		HoldNoteScore_Held = "#f2cb30",	
		HoldNoteScore_LetGo = "#cc2929"
	},

	pacemaker = {
		current = "#0099ff",
		target = "#ff9999",
		best = "#00ff00" -- unused,
	},

	songLength = {
		normal = "#FFFFFF", -- normal
		long = "#ff9a00", --orange
		marathon = "#da5757" -- red
	},

	gameplay = {
		ScreenFilter = "#000000",
		LaneCover = "#111111",
		PacemakerBest = "#00FF00",
		PacemakerTarget = "#FF9999",
		PacemakerCurrent = "#0099FF",
	},

	evaluation = {
		BackgroundText = "#000000",
		ScoreCardText = "#FFFFFF",
		ScoreCardDivider = "#FFFFFF",
		ScoreCardCategoryText = "#FFFFFF",
		ScoreBoardText = "#FFFFFF",
	},

	selectMusic = {
		MusicWheelTitleText = "#FFFFFF",
		MusicWheelSubtitleText = "#FFFFFF",
		MusicWheelArtistText = "#FFFFFF",
		MusicWheelDivider = "#FFFFFF",
		ProfileCardText = "#FFFFFF",
		TabContentText = "#FFFFFF",
		BannerText = "#FFFFFF",
		StepsDisplayListText = "#FFFFFF"
	}

}

colorConfig = create_lua_config({name = "colorConfig", file = "colorConfig.lua", default = defaultConfig, match_depth = -1})
colorConfig:load()

--keys to current table. Assumes a depth of 2.
local curColor = {"",""}

function getTableKeys()
	return curColor
end

function setTableKeys(table)
	curColor = table 
end

function getMainColor(type)
	return color(colorConfig:get_data().main[type])
end

function getGradeColor (grade)
	return color(colorConfig:get_data().grade[grade]) or color(colorConfig:get_data().grade['Grade_None']);
end

function getDifficultyColor(diff)
	return color(colorConfig:get_data().difficulty[diff]) or color("#ffffff");
end

function getPaceMakerColor(type)
	return color(colorConfig:get_data().pacemaker[type]) or color("#ffffff");
end

function getSongLengthColor(s)
	if s < 1 then
		return color(colorConfig:get_data().main['disabled'])
	elseif s < PREFSMAN:GetPreference("LongVerSongSeconds") then
		return color(colorConfig:get_data().songLength["normal"])
	elseif s < PREFSMAN:GetPreference("MarathonVerSongSeconds") then
		return color(colorConfig:get_data().songLength["long"])
	else
		return color(colorConfig:get_data().songLength["marathon"])
	end
end

function offsetToJudgeColor(offset)
	local offset = math.abs(offset)
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	if offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW5") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

function TapNoteScoreToColor(tns) return color(colorConfig:get_data().judgment[tns]) or color("#ffffff"); end;