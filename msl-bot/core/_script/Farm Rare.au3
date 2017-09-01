#cs
	Function: farmRare
	Calls farmRareMain function with config settings

	Author: GkevinOD (2017)
#ce
Func farmRare()
	Local $scriptName = "Farm Astromon"
	
	Local $map 			= "map-" & StringReplace(IniRead($botConfigDir, "Farm Rare", "map", "phantom forest"), " ", "-")
	Local $difficulty 	= IniRead($botConfigDir, "Farm Rare", "difficulty", "normal")
	Local $stage 		= IniRead($botConfigDir, "Farm Rare", "stage", "gold")
	
		
	Local $buySale 			= IniRead($botConfigDir, $scriptName, "buy-sale", 0)
	Local $buyEggs 			= IniRead($botConfigDir, $scriptName, "buy-eggs", 0)
	Local $buySoulstones 	= IniRead($botConfigDir, $scriptName, "buy-soulstones", 0)
	Local $maxGoldSpend 	= IniRead($botConfigDir, $scriptName, "max-gold-spend", 1000000)
	Local $maxGemRefill = IniRead($botConfigDir, $scriptName, "max-spend-gem", 0)
	
	Local $shoppingList = [$buySale, $buySoulstones, $buyEggs]
	$maxGemRefill = Int($maxGemRefill)
	
	Local $quest 	= IniRead($botConfigDir, $scriptName, "collect-quest", 1)
	Local $hourly 	= IniRead($botConfigDir, $scriptName, "collect-hourly", 1)
	Local $guardian = IniRead($botConfigDir, $scriptName, "guardian-dungeon", 0)
	Local $league 	= IniRead($botConfigDir, $scriptName, "astromon-league", 0)
	
	Local $sellGems = IniRead($botConfigDir, $scriptName, "sell-gems-grade", "1,2,3")
	$sellGems = StringSplit($sellGems, ",", 2)
	
	Local $rawCapture = IniRead($botConfigDir, "Farm Rare", "capture", "legendary,super rare,rare,exotic,variant")
	$rawCapture = StringSplit($rawCapture, ",", 2)

	setLog("~~~Starting 'Farm Rare' script~~~", 2)
		Local $monster = [null, null, $map, $stage, $difficulty]
		_farmAstromonMain($monster, 0, $rawCapture, 1, 0, $maxGemRefill, $quest, $hourly, $shoppingList, 0, $maxGoldSpend, $guardian, $league, $sellGems)
	setLog("~~~Finished 'Farm Rare' script~~~", 2)
EndFunc   ;==>farmRare