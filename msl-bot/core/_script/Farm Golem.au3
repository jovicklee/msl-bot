#cs
	Function: farmGolem
	Calls farmGolemMain with config settings

	Author: GkevinOD (2017)
#ce
Func farmGolem()
	Local $scriptName = "Farm Golem"

	Local $strGolem 	 = IniRead($botConfigDir, $scriptName, "dungeon", 7)
	Local $buyEggs 		 = IniRead($botConfigDir, $scriptName, "buy-eggs", 0)
	Local $buySoulstones = IniRead($botConfigDir, $scriptName, "buy-soulstones", 1)
	Local $maxGoldSpend  = IniRead($botConfigDir, $scriptName, "max-gold-spend", 100000)
	Local $maxGemRefill  = IniRead($botConfigDir, $scriptName, "max-spend-gem", 0)
	Local $selectBoss 	 = IniRead($botConfigDir, $scriptName, "select-boss", 1)
	Local $keepAllGrade  = IniRead($botConfigDir, $scriptName, "keep-all-grade", 6)
	
	Local $quest 		 = IniRead($botConfigDir, $scriptName, "collect-quest", "1")
	Local $hourly 		 = IniRead($botConfigDir, $scriptName, "collect-hourly", "1")
	Local $guardian 	 = IniRead($botConfigDir, $scriptName, "farm-guardian", 0)
	Local $league	 	 = IniRead($botConfigDir, $scriptName, "astromon-league", 0)

	setLog("~~~Starting 'Farm Golem' script~~~", 2)
	farmGolemMain($strGolem, $selectBoss, $maxGemRefill, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend, $league)
	setLog("~~~Finished 'Farm Golem' script~~~", 2)
EndFunc   ;==>farmGolem

#cs
	Function: farmGolemMain
	Farms golems while collecting hourly and quests, and selling and collecting gems.

	Parameters:
	strGolem: (Int) The golem stage.
	selectBoss: (Int) 1=True; 0=False
	sellGems: (Int) 1=True; 0=False
	sellGrades: (String) Sell gems with grades specified
	filterGrades: (String) Grades you want to go through the filter system
	sellTypes: (String) Sell gems with types specified
	sellFlat: (Int) 1=True; 0=False
	sellStats: (String) Sell gems with stats specified
	sellSubstats = (String) Sell gems with substats specified
	maxGemRefill: (Int) Maximum number of gems the bot can spend for refill.
	guardian: (Int) 1=True; 0=False
	quest: (Int) 1=True; 0=False
	hourly: (Int) 1=True; 0=False
	league: (Int) 1=True; 0=False

	Author: GkevinOD (2017)
#ce
Func farmGolemMain($strGolem, $selectBoss, $maxGemRefill, $guardian, $quest, $hourly, $buyEggs, $buySoulstones, $maxGoldSpend, $league)
	Local $avgGoldPerRound = 0
	Switch ($strGolem)
		Case 7
			$avgGoldPerRound = 1500
		Case 8
			$avgGoldPerRound = 1500
		Case 9
			$avgGoldPerRound = 1100
		Case 10
			$avgGoldPerRound = 1200
	EndSwitch

	Local $intGolem = 7
	Switch ($strGolem)
		Case 1 To 3
			$intGolem = 5
		Case 4 To 6
			$intGolem = 6
		Case 7 To 9
			$intGolem = 7
		Case 10
			$intGolem = 8
	EndSwitch

	Local $gemsUsed = 0

	Local $intStartTime = TimerInit()
	Local $intGoldPrediction = 0
	Local $intRunCount = 0
	Local $intTimeElapse = 0
	Local $numGuardian = 0
	
	Local $doHourly = False
	Local $doGuardian = False
	Local $doLeague = False

	Local $numEggs = 0 ;keeps count of number of eggs found
	Local $numGemsKept = 0; keeps count of number of eggs kept
	
	Local $roundNumber = [0,0]
	Local $autoMode = $AUTO_BATTLE

	Local $goldSpent = 0
	While True
		If _Sleep(50) Then ExitLoop
		$intTimeElapse = Int(TimerDiff($intStartTime) / 1000)

		checkTimeTasks($doHourly, $doGuardian, $doLeague, $hourly, $guardian, $league)

		Local $strData = "Runs: " & $intRunCount & " (Guardian:" & $numGuardian & ")|Profit: " & StringRegExpReplace(String($intGoldPrediction), "(\d)(?=(\d{3})+$)", "$1,") & "|Gems Used: " & ($gemsUsed & "/" & $maxGemRefill) & "|Avg. Time: " & getTimeString(Int($intTimeElapse / $intRunCount)) & "|Eggs: " & $numEggs & "|Gems Kept: " & $numGemsKept
		setList($strData)

		Local $currLocation = getLocation()

		antiStuck("map")
		Switch $currLocation
			Case "battle-auto"
				If Not doAutoBattle($roundNumber, $autoMode, $selectBoss) Then
					If setLog("Unknown error in Auto-Battle!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "battle"
				If Not doBattle($autoMode) Then
					If setLog("Unknown error in Battle!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "refill"
				; If the number of used gems will not exceed the limit, purchase additional energy
				If Not refilGems($gemsUsed, $maxGemRefill) Then 
					If setLog("Unknown error in Gem-Refill!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "battle-end"
				Local $itemsToBuy = [1, $buySoulstones, $buyEggs]
				If Not doBattleEnd($quest, $doHourly, $itemsToBuy, $goldSpent, $maxGoldSpend, $doGuardian, $numGuardian, $intRunCount, $doLeague) Then
					If setLog("Unknown error in Battle-End!", 1, $LOG_ERROR) Then ExitLoop
					ExitLoop
				EndIf
				
			Case "map", "village", "manage", "astroleague", "map-stage", "map-battle", "toc", "association", "clan", "starstone-dungeons", "golem-dungeons", "elemental-dungeons", "gold-dungeons", "quests"
				If navigate("map", "golem-dungeons") = True Then
					Local $tempCurrLocation = getLocation()
					While Not ($tempCurrLocation = "map-battle")
						If $tempCurrLocation = "autobattle-prompt" Then
							clickPoint($map_coorCancelAutoBattle, 1, 500)
						EndIf

						clickPoint(Eval("map_coorB" & $strGolem), 1, 500)
						$tempCurrLocation = getLocation()
					WEnd

					clickUntil($map_coorBattle, "battle")

					$intRunCount += 1
				EndIf
				
			Case "battle-end-exp", "battle-sell", "battle-sell-item"
				clickUntil("193,255", "battle-sell-item", 500, 100)
				If _Sleep(10) Then ExitLoop

				Local $gemInfo = sellGemGolemFilter($strGolem)
				If IsArray($gemInfo) Then
					If Not($gemInfo[0] = "EGG") And StringInStr($gemInfo[5], "!") Then
						$intGoldPrediction += getGemPrice($gemInfo) + $avgGoldPerRound
					Else
						If $gemInfo[0] = "EGG" Then
							$numEggs += 1
						Else
							$numGemsKept += 1
						EndIf
					EndIf
				EndIf
				
			Case "map-gem-full", "battle-gem-full"
				If setLogReplace("Gem is full, going to sell gems...", 1) Then ExitLoop
				If navigate("village", "manage") = 1 Then
					Local $sellGems = "1,2,3,4"
					sellGems($sellGems)
					If setLogReplace("Gem is full, going to sell gems... Done!", 1) Then ExitLoop
				EndIf
				
			Case "defeat"
				clickPoint(findImage("battle-give-up", 30))
				clickUntil($game_coorTap, "battle-end", 20, 1000)
				
			Case "pause"
				clickPoint($battle_coorContinue)
				
			Case "lost-connection"
				clickPoint($game_coorConnectionRetry)
				
		EndSwitch
	WEnd
EndFunc   ;==>farmGolemMain
