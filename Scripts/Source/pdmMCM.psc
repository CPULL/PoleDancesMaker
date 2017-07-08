Scriptname pdmMCM extends SKI_ConfigBase

; ((- Variables & Properties

; ((- Variables
int[] opts
int[] ids
spdfPoleDances spdF
spdfRegistry reg
int numPoses=0
int numDances=0
int numStrips=0
int[] posesIdx
int[] dancesIdx
int[] stripsIdx
spdfPose[] poses
string[] poseNames
spdfDance[] dances
string[] danceNames
spdfStrip[] strips
string[] stripNames
string[] perfModes
int currPerfMode
string thePage = ""
int currentSelectedDance = -1
int currentSelectedPose = -1
int currentSelectedStrip = -1
int numCurrentDances = 0
spdfBase[] currentDances
float[] customTime
string[] stripMn
int[] currentStrips
bool animateStrip
float stripTime
int pickedDance = 0
int pickedPose = 0
int pickedStrip = 0
spdfStrip currentStrip

; -))

; ((- Properties

bool Property selfSpell Auto
bool Property targetSpell Auto
bool Property placePoleSpell Auto
Spell Property pdmDanceSelf Auto
Spell Property pdmDanceTarget Auto
Spell Property pdmPlacePole Auto
float Property performanceTime Auto
ObjectReference Property placedPole Auto

; -))
; -))

; ((- Main init events
event OnConfigInit()
	opts = new int[128]
	ids = new int[128]
	perfModes = new String[3]
	perfModes[0] = "Dances"
	perfModes[1] = "Start Pose"
	perfModes[2] = "Tags"
	numCurrentDances = 0
	currentDances = new spdfBase[16]
	currentSelectedDance=-1
	customTime = new float[16]
	if performanceTime<1.0
		performanceTime=30.0
	endIf
	stripMn = new string[3]
	stripMn[0] = "Ignore"
	stripMn[1] = "Strip"
	stripMn[2] = "Dress"
	currentStrips = new int[32]
	animateStrip = false
	stripTime = 3.0
	
	RegisterForKey(2) ; d+
	RegisterForKey(3) ; d-
	RegisterForKey(4) ; z+
	RegisterForKey(5) ; z-
	RegisterForKey(6) ; t+
	RegisterForKey(7) ; t-
	RegisterForKey(8) ; i+
	RegisterForKey(9) ; i-
	RegisterForKey(10) ; test
	RegisterForKey(11) ; test
	spdF = spdfPoleDances.getInstance()
	reg = spdF.registry
endEvent

event OnConfigOpen()
	spdF = spdfPoleDances.getInstance()
	reg = spdF.registry
	
	reg.findRandomDance() ; This will just sort the items
	
	dances = new spdfDance[16]
	danceNames = new string[16]
	dancesIdx = new int[16]
	strips = new spdfStrip[16]
	stripNames = new string[16]
	stripsIdx = new int[16]
	poses = new spdfPose[16]
	poseNames = new string[16]
	posesIdx = new int[16]
	int i=0
	numPoses=0
	while i<reg.getPosesNum(0)
		spdfPose p = reg._getPoseByIndex(i)
		if p && p.inUse
			poses[numPoses] = p
			poseNames[numPoses] = p.name
			posesIdx[numPoses] = i
			numPoses+=1
		endIf
		i+=1
	endWhile
	i=0
	numDances=0
	while i<reg.getDancesNum(0)
		spdfDance d = reg._getDanceByIndex(i)
		if d && d.inUse
			dances[numDances] = d
			danceNames[numDances] = d.name
			dancesIdx[numDances] = i
			numDances+=1
		endIf
		i+=1
	endWhile
	i=0
	numStrips=0
	while i<reg.getStripsNum(0)
		spdfStrip s = reg._getStripByIndex(i)
		if s && s.inUse && !s.isTemporary
			strips[numStrips] = s
			stripNames[numStrips] = s.name
			stripsIdx[numStrips] = i
			numStrips+=1
		endIf
		i+=1
	endWhile

	; FUTURE tags
endEvent

event OnPageReset(string page)
	if page==""
		AddHeaderOption("Pole Dance Maker Configurator")
		return
	endIf
	if page=="Config"
		generateConfig()
	elseIf page=="Dances"
		generateDances()
	elseIf page=="Poses"
		generatePoses()
	elseIf page=="Tags"
		generateTags()
	endIf
endEvent

; -))


; ((- Generate Config

Function generateConfig()
	cleanOptions()

	thePage = "Config"
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddMenuOptionST("DanceModeMN", "Performance Mode", perfModes[currPerfMode])
	AddSliderOptionST("PerfTimeSL", "Time for the Performance", performanceTime)
	AddEmptyOption()
	opts[0] = AddToggleOption("Enable self spell", selfSpell)
	opts[1] = AddToggleOption("Enable target spell", targetSpell)
	opts[2] = AddToggleOption("Enable place pole spell", placePoleSpell)
	
endFunction

; -))



; ((- Generate Dances

Function generateDances()
	cleanOptions()
	if thePage==""
		thePage="Dances"
	elseIf thePage=="EditDance"
		generateEditDance()
		return
	elseIf thePage=="PickingPose"
		generatePickingPose()
		return
	elseIf thePage=="EditStrip"
		generateEditStrip()
		return
	elseIf thePage=="PickingStrip"
		generatePickingStrip()
		return
	elseIf thePage=="PreviewDance"
		generatePreviewDance()
		return
	else
		thePage="Dances"
	endIf

	SetCursorFillMode(TOP_TO_BOTTOM)
	SetTitleText("Define Performance by Dances")
	int i=0
	while i<numCurrentDances
		; Show dance name and timing, or strip and timing
		if currentDances[i].isStrip
			if customTime[i]
				opts[20 + i] = AddToggleOption(currentDances[i].name + " (" + trimFloat(customTime[i]) + ")", i==currentSelectedDance)
			else
				opts[20 + i] = AddToggleOption(currentDances[i].name + " (" + trimFloat(currentDances[i].duration) + ")", i==currentSelectedDance)
			endIf
		else
			if customTime[i]
				opts[20 + i] = AddToggleOption(currentDances[i].name + " (" + trimFloat(customTime[i]) + ")", i==currentSelectedDance)
			else
				opts[20 + i] = AddToggleOption(currentDances[i].name + " (" + trimFloat(currentDances[i].duration) + ")", i==currentSelectedDance)
			endIf
		endIf
		i+=1
	endWhile
	if numCurrentDances<currentDances.length
		opts[0] = AddTextOption("", "Add Dance")
	else
		opts[0] = AddTextOption("", "Add Dance", OPTION_FLAG_DISABLED)
	endIf
	SetCursorPosition(1)
	if numCurrentDances<currentDances.length
		opts[1] = AddTextOption("", "Add dance")
		opts[2] = AddTextOption("", "Add pose")
		opts[3] = AddTextOption("", "Add strip")
		opts[4] = AddTextOption("", "Add custom strip")
	else
		opts[1] = AddTextOption("", "Add dance", OPTION_FLAG_DISABLED)
		opts[2] = AddTextOption("", "Add pose", OPTION_FLAG_DISABLED)
		opts[3] = AddTextOption("", "Add strip", OPTION_FLAG_DISABLED)
		opts[4] = AddTextOption("", "Add custom strip", OPTION_FLAG_DISABLED)
	endIf
	if currentSelectedDance!=-1
		opts[5] = AddTextOption("", "Change Selected")
		opts[6] = AddTextOption("", "Remove Selected")
	else
		opts[5] = AddTextOption("", "Change Selected", OPTION_FLAG_DISABLED)
		opts[6] = AddTextOption("", "Remove Selected", OPTION_FLAG_DISABLED)
	endIf
	AddEmptyOption()
	if currentSelectedDance>0
		opts[7] = AddTextOption("", "Move Up")
	else
		opts[7] = AddTextOption("", "Move Up", OPTION_FLAG_DISABLED)
	endIf
	if currentSelectedDance!=-1 && currentSelectedDance<numCurrentDances - 1
		opts[8] = AddTextOption("", "Move Down")
	else
		opts[8] = AddTextOption("", "Move Down", OPTION_FLAG_DISABLED)
	endIf
	AddEmptyOption()
	if currentSelectedDance!=-1 && currentDances[currentSelectedDance] && !currentDances[currentSelectedDance].isStrip
		opts[9] = AddTextOption("", "Preview")
	else
		opts[9] = AddTextOption("", "Preview", OPTION_FLAG_DISABLED)
	endIf
	
endFunction


Function generateEditDance()
	thePage="EditDance"
	SetTitleText("Edit Dance")
	SetCursorFillMode(TOP_TO_BOTTOM)
	; Drop down with all the possible dances
	AddMenuOptionST("PickDanceMN", "Dance", danceNames[pickedDance])
	; Texts with sPose and ePose, Expeced pre and post poses, and Warning if poses are not matching
	if dances[pickedDance].startPose
		AddTextOption("Start Pose", dances[pickedDance].startPose.name, OPTION_FLAG_DISABLED)
	else
		AddTextOption("Start Pose", "not defined", OPTION_FLAG_DISABLED)
	endIf
	if currentSelectedDance>0
		if currentDances[currentSelectedDance - 1].isDance && (currentDances[currentSelectedDance - 1] as spdfDance).endPose
			AddTextOption("Expected Start Pose", (currentDances[currentSelectedDance - 1] as spdfDance).endPose.name, OPTION_FLAG_DISABLED)
		else
			AddEmptyOption()
		endIf
	else
		AddEmptyOption()
	endIf
	if dances[pickedDance].startPose && currentSelectedDance>0 && currentDances[currentSelectedDance - 1].isDance && (currentDances[currentSelectedDance - 1] as spdfDance).endPose && dances[pickedDance].startPose!=(currentDances[currentSelectedDance - 1] as spdfDance).endPose
		AddTextOption("WARNING: poses do not match!", "", OPTION_FLAG_DISABLED)
	else
		AddEmptyOption()
	endIf


	if dances[pickedDance].endPose
		AddTextOption("End Pose", dances[pickedDance].endPose.name, OPTION_FLAG_DISABLED)
	else
		AddTextOption("End Pose", "not defined", OPTION_FLAG_DISABLED)
	endIf
	if currentSelectedDance<numCurrentDances - 1
		if currentDances[currentSelectedDance + 1].isDance && (currentDances[currentSelectedDance + 1] as spdfDance).startPose
			AddTextOption("Expected End Pose", (currentDances[currentSelectedDance + 1] as spdfDance).startPose.name, OPTION_FLAG_DISABLED)
		else
			AddEmptyOption()
		endIf
	else
		AddEmptyOption()
	endIf
	if dances[pickedDance].endPose && currentSelectedDance<numCurrentDances - 1 && currentDances[currentSelectedDance + 1].isDance && (currentDances[currentSelectedDance + 1] as spdfDance).startPose && dances[pickedDance].endPose!=(currentDances[currentSelectedDance + 1] as spdfDance).startPose
		AddTextOption("WARNING: poses do not match!", "", OPTION_FLAG_DISABLED)
	else
		AddEmptyOption()
	endIf
	
	AddEmptyOption()
	
	; TimingSlider pre-filled with the dance time
	if customTime[currentSelectedDance]==0.0
		customTime[currentSelectedDance]=dances[pickedDance].duration
	endIf
	
	AddSliderOptionST("DanceTimeSL", "Time for dance", customTime[currentSelectedDance] , "{2} secs")
	
	SetCursorPosition(23)
	opts[0] = AddTextOption("", "Save")
endFunction

function generatePreviewDance()
	SetTitleText("Preview")
	spdfBase d = currentDances[currentSelectedDance]
	if d && d.isDance
		LoadCustomContent("Skyrim Pole Dances/DancesPreview/" + d.previewFile, 0.0, 0.0)
		Utility.waitMenuMode(3.0)
	endIf
	UnloadCustomContent()
	thePage=""
	ForcePageReset()
endFunction


Function generateEditStrip()
	SetTitleText("Edit Strip")
	thePage="EditStrip"

	SetCursorFillMode(LEFT_TO_RIGHT)
	opts[40] = AddTextOption("", "Save")
	AddMenuOptionST("SetAllToMN", "Set All to", "")
	opts[41] = AddToggleOption("Animate strips", animateStrip)
	if animateStrip
		AddSliderOptionST("StripTimeST", "Strip time", stripTime, "{2} secs")
	else
		AddSliderOptionST("StripTimeST", "Strip time", stripTime, "{2} secs", OPTION_FLAG_DISABLED)
	endIf
	AddHeaderOption("")
	AddHeaderOption("")
	int i=0
	while i<32
		opts[i] = AddMenuOption(reg.bodyParts[i], stripMn[currentStrips[i]])
		i+=1
	endWhile
	
endFunction

Function generatePickingStrip()
	SetTitleText("Select the Strip")
	thePage="PickingStrip"

	SetCursorFillMode(LEFT_TO_RIGHT)
	AddMenuOptionST("PickStripMN", "Strip", stripNames[pickedStrip])
	opts[0] = AddTextOption("", "Save")
	SetCursorPosition(2)
	AddHeaderOption("")
	AddHeaderOption("")
	
	; Pich the strip and show its preview
	spdfStrip s = strips[pickedStrip]
	
	AddToggleOption("Animated strips", s.animatedStrip, OPTION_FLAG_DISABLED)
	AddToggleOption("OFA Animation", s.isOFA, OPTION_FLAG_DISABLED)
	AddTextOption("Duration",  trimFloat(s.duration), OPTION_FLAG_DISABLED)
	AddTextOption("Pre Duration", trimFloat(s.preStripDuration), OPTION_FLAG_DISABLED)
	AddHeaderOption("")
	AddHeaderOption("")
	; List of all the slots (dress/strip do not list the "ignore")
	int i=0
	int[] parts = s.stripSlots()
	while i<32
		if parts[i]==1
			AddTextOption(reg.bodyParts[i], "Strip", OPTION_FLAG_DISABLED)
		elseIf parts[i]==-1
			AddTextOption(reg.bodyParts[i], "Dress", OPTION_FLAG_DISABLED)
		endIf
		i+=1
	endWhile
	
endFunction

Function generatePickingPose()
	SetTitleText("Select the Pose")
	thePage="PickingPose"

	SetCursorFillMode(LEFT_TO_RIGHT)
	AddMenuOptionST("PickPoseMN", "Pose", poseNames[pickedPose])
	opts[0] = AddTextOption("", "Save")
	SetCursorPosition(2)
	AddHeaderOption("")
	AddHeaderOption("")
	
	; Pich the strip and show its preview
	spdfPose p = poses[pickedPose]
	
	AddTextOption("Duration",  trimFloat(p.duration), OPTION_FLAG_DISABLED)
endFunction


; -))

; ((- Generate Poses

Function generatePoses()
	SetTitleText("Edit Performance by Pose")
	
	AddTextOption("This is not yet done...", "", OPTION_FLAG_DISABLED)
	return
	
	AddSliderOptionST("PerfTimeSL", "Time for the Performance", performanceTime)
	if pickedPose>-1 && pickedPose<poseNames.length
		AddMenuOptionST("PickPoseMNold", "Start Pose", poseNames[pickedPose])
	else
		AddMenuOptionST("PickPoseMNold", "Start Pose", "???")
	endIf
endFunction

; -))



; ((- Generate Tags

Function generateTags()
	SetTitleText("Edit Performance by Tags")
	AddTextOption("This mode is not yet available", "", OPTION_FLAG_DISABLED)
endFunction

; -))


; ((- Events management

Event OnOptionHighlight(int opt)

endEvent

Event OnOptionSelect(int option)
	if thePage=="Config"
		Actor p = Game.getPlayer()
		if option==opts[0]
			selfSpell = !selfSpell
			if selfSpell 
				if !p.hasSpell(pdmDanceSelf)
					p.addSpell(pdmDanceSelf)
					p.equipSpell(pdmDanceSelf, 1)
				endIf
			else
				if p.hasSpell(pdmDanceSelf)
					p.removeSpell(pdmDanceSelf)
				endIf
			endIf
			SetToggleOptionValue(option, selfSpell)
		elseIf option==opts[1]
			targetSpell = !targetSpell
			if targetSpell
				if !p.hasSpell(pdmDanceTarget)
					p.addSpell(pdmDanceTarget)
					p.equipSpell(pdmDanceTarget, 1)
				endIf
			else
				if p.hasSpell(pdmDanceTarget)
					p.removeSpell(pdmDanceTarget)
				endIf
			endIf
			SetToggleOptionValue(option, targetSpell)
		elseIf option==opts[2]
			placePoleSpell = !placePoleSpell
			if placePoleSpell
				if !p.hasSpell(pdmPlacePole)
					p.addSpell(pdmPlacePole)
					p.equipSpell(pdmPlacePole, 1)
				endIf
			else
				if p.hasSpell(pdmPlacePole)
					p.removeSpell(pdmPlacePole)
				endIf
			endIf
			SetToggleOptionValue(option, placePoleSpell)
		endIf
	
	elseIf thePage=="Dances"
		if option==opts[0] || option==opts[1] ; Add Dance
			if numCurrentDances<currentDances.length
				currentDances[numCurrentDances] = reg._getDanceByIndex(dancesIdx[0])
				currentSelectedDance = numCurrentDances
				pickedDance = 0
				numCurrentDances+=1
				thePage="EditDance"
				ForcePageReset()
			endIf
		
		elseIf option==opts[2] ; Add Pose
			if numCurrentDances<currentDances.length
				currentDances[numCurrentDances] = reg._getPoseByIndex(posesIdx[0])
				currentSelectedPose = numCurrentDances
				pickedPose = 0
				numCurrentDances+=1
				thePage="PickingPose"
				ForcePageReset()
			endIf
		
		elseIf option==opts[3] ; Add Strip
			if numCurrentDances<currentDances.length
				currentDances[numCurrentDances] = reg._getStripByIndex(stripsIdx[0])
				currentSelectedStrip = numCurrentDances
				pickedStrip = 0
				numCurrentDances+=1
				thePage="PickingStrip"
				ForcePageReset()
			endIf
		
		elseIf option==opts[4] ; Add custom Strip
			if numCurrentDances<currentDances.length
				; Open a Strip creation page, when closing set the strip as current dance
				int i = currentStrips.length
				while i
					i-=1
					currentStrips[i]=0
				endWhile
				stripTime=3.0
				animateStrip=false
				currentStrip = reg.allocateStrip()
				if !currentStrip
					Debug.MessageBox("No more Strip Slots available")
				else
					thePage="EditStrip"
				endIf
				currentDances[numCurrentDances] = currentStrip
				numCurrentDances+=1
				ForcePageReset()
			endIf
		
		elseIf option==opts[5] ; Change Selected
			if currentDances[currentSelectedDance] 
				if currentDances[currentSelectedDance].isStrip
					thePage="EditStrip"
					spdfStrip s =  currentDances[currentSelectedDance] as spdfStrip
					; get back the old strip values
					s.getStrips(currentStrips)
					animateStrip = s.animatedStrip
					stripTime = s.duration
				else
					thePage="EditDance"
				endIf
				ForcePageReset()
			endIf
			
		elseIf option==opts[6] ; Remove Selected
			; Ask for confirmation and then remove it, move back all next items
			if currentDances[currentSelectedDance]
				if currentDances[currentSelectedDance].isStrip
					if ShowMessage("Are you sure to remove the Strip " + currentDances[currentSelectedDance].name + "?", true, "Yes", "No")
						(currentDances[currentSelectedDance] as spdfStrip)._releaseStrip()
						int i = currentSelectedDance
						while i<currentDances.length - 1
							currentDances[i] = currentDances[i + 1]
							customTime[i] = customTime[i + 1]
							i+=1
						endWhile
						currentDances[currentDances.length - 1] = none
						customTime[currentDances.length - 1] = 0.0
						numCurrentDances-=1
						ForcePageReset()
					endIf
				else
					if ShowMessage("Are you sure to remove the Dance " + currentDances[currentSelectedDance].name + "?", true, "Yes", "No")
						int i = currentSelectedDance
						while i<currentDances.length - 1
							currentDances[i] = currentDances[i + 1]
							customTime[i] = customTime[i + 1]
							i+=1
						endWhile
						currentDances[currentDances.length - 1] = none
						customTime[currentDances.length - 1] = 0.0
						numCurrentDances-=1
						ForcePageReset()
					endIf
				endIf
			endIf
			
		elseIf option==opts[7] ; Move Up
			if currentSelectedDance>0
				spdfBase tmp = currentDances[currentSelectedDance - 1]
				currentDances[currentSelectedDance - 1] = currentDances[currentSelectedDance]
				currentDances[currentSelectedDance] = tmp
				float ct = customTime[currentSelectedDance - 1]
				customTime[currentSelectedDance - 1] = customTime[currentSelectedDance]
				customTime[currentSelectedDance] = ct
				currentSelectedDance-=1
				ForcePageReset()
			endIf
			
		elseIf option==opts[8] ; Move Down
			if currentSelectedDance<numCurrentDances - 1
				spdfBase tmp = currentDances[currentSelectedDance]
				currentDances[currentSelectedDance] = currentDances[currentSelectedDance + 1]
				currentDances[currentSelectedDance + 1] = tmp
				float ct = customTime[currentSelectedDance]
				customTime[currentSelectedDance] = customTime[currentSelectedDance + 1]
				customTime[currentSelectedDance + 1] = ct
				currentSelectedDance+=1
				ForcePageReset()
			endIf
			
		elseIf option==opts[9] ; Move Down
			if -1<currentSelectedDance && currentSelectedDance<numCurrentDances
				thePage="PreviewDance"
				ForcePageReset()
			endIf
			
		else
			int pos = opts.find(option)
			if pos>19
				currentSelectedDance = pos - 20
				ForcePageReset()
			endIf
		endIf

	elseIf thePage=="EditDance"
debug.trace("EDITDANCE option=" + option + " optsNum=" + opts.find(option))
		if option==opts[0]
			if currentDances[currentSelectedDance].duration==customTime[currentSelectedDance]
				customTime[currentSelectedDance]=0.0
			endIf
			thePage=""
			ForcePageReset()
		endIf
		
	elseIf thePage=="PickingStrip"
		if option==opts[0]
			thePage = ""
			ForcePageReset()
		endIf
	
	elseIf thePage=="PickingPose"
		if option==opts[0]
			thePage = ""
			ForcePageReset()
		endIf
	
	elseIf thePage=="EditStrip"
debug.trace("EDITSTRIP option=" + option + " optsNum=" + opts.find(option))
		if option==opts[40] ; Save
			currentStrip.setStripValues(currentStrips, animateStrip, stripTime)
			thePage = ""
			ForcePageReset()
		elseIf option==opts[41] ; Change animated toggle
			animateStrip = !animateStrip
			SetToggleOptionValue(option, animateStrip)
			ForcePageReset()
		endIf
	
	endIf
endEvent

Event OnOptionMenuOpen(int option)
	if thePage=="EditStrip"
		int pos = opts.find(option)
		if pos<32
			SetMenuDialogStartIndex(currentStrips[pos])
			SetMenuDialogDefaultIndex(0)
			SetMenuDialogOptions(stripMn)
		endIf
	endIf
endEvent

Event OnOptionMenuAccept(int option, int value)
	if thePage=="EditStrip"
		int pos = opts.find(option)
		if pos<32
			currentStrips[pos] = value
			SetMenuOptionValue(option, stripMn[currentStrips[pos]])
		endIf
	endIf
endEvent


; -))

; ((- Events by state

state DanceModeMN
	event OnMenuOpenST()
		SetMenuDialogStartIndex(currPerfMode)
		SetMenuDialogDefaultIndex(1)
		SetMenuDialogOptions(perfModes)
	endEvent

	event OnMenuAcceptST(int index)
		if index>-1 && index<perfModes.length
			currPerfMode = index
			SetMenuOptionValueST(perfModes[index])
		endIf
	endEvent

	event OnDefaultST()
		currPerfMode = 1
		SetMenuOptionValueST(perfModes[1])
	endEvent

	event OnHighlightST()
		SetInfoText("Select how to define the performance. Dances will allow to set a list of dances, Pose will give you the ability to define the time and a start pose, Tags will allow you to define the tags to run a performance.")
	endEvent
endState

state PickDanceMN
	event OnMenuOpenST()
		SetMenuDialogStartIndex(pickedDance)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(danceNames)
	endEvent

	event OnMenuAcceptST(int index)
		if index>-1 && index<danceNames.length
			bool update = (pickedDance != index)
			pickedDance = index
			SetMenuOptionValueST(danceNames[pickedDance])
			currentDances[currentSelectedDance] = reg._getDanceByIndex(dancesIdx[pickedDance])
			customTime[currentSelectedDance] = 0.0
			if update
				ForcePageReset()
			endIf
		endIf
	endEvent

	event OnDefaultST()
		bool update = (pickedDance != 0)
		pickedDance = 0
		SetMenuOptionValueST(danceNames[0])
		currentDances[currentSelectedDance] = reg._getDanceByIndex(dancesIdx[0])
		if update
			ForcePageReset()
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("Select the dance from the available ones.")
	endEvent
endState

state PickPoseMN
	event OnMenuOpenST()
		SetMenuDialogStartIndex(pickedPose)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(poseNames)
	endEvent

	event OnMenuAcceptST(int index)
		if index>-1 && index<poseNames.length
			bool update = (pickedPose != index)
			pickedPose = index
			SetMenuOptionValueST(poseNames[pickedPose])
			currentDances[currentSelectedPose] = reg._getPoseByIndex(posesIdx[pickedPose])
			customTime[currentSelectedPose] = 0.0
			if update
				ForcePageReset()
			endIf
		endIf
	endEvent

	event OnDefaultST()
		bool update = (pickedPose != 0)
		pickedPose = 0
		SetMenuOptionValueST(poseNames[0])
		currentDances[currentSelectedPose] = reg._getPoseByIndex(posesIdx[0])
		if update
			ForcePageReset()
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("Select the pose from the available ones.")
	endEvent
endState

state PickPoseMNold
	event OnMenuOpenST()
		SetMenuDialogStartIndex(pickedPose)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(poseNames)
	endEvent

	event OnMenuAcceptST(int index)
		if index>-1 && index<poseNames.length
			bool update = (pickedPose != index)
			pickedPose = index
			SetMenuOptionValueST(poseNames[pickedPose])
			if update
				ForcePageReset()
			endIf
		endIf
	endEvent

	event OnDefaultST()
		bool update = (pickedPose != 0)
		pickedPose = 0
		SetMenuOptionValueST(poseNames[0])
		if update
			ForcePageReset()
		endIf
	endEvent

	event OnHighlightST()
		SetInfoText("Select the pose from the available ones. The performance will start with this pose and then continue with dances using matching the poses.")
	endEvent
endState

state SetAllToMN
	event OnMenuOpenST()
		SetMenuDialogStartIndex(0)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(stripMn)
	endEvent

	event OnMenuAcceptST(int index)
		if index==0 || index==1 || index==2
			int i = currentStrips.length
			while i
				i-=1
				currentStrips[i] = index
			endWhile
		endIf
		if index==0
			animateStrip=false
		endIf
		ForcePageReset()
	endEvent

	event OnDefaultST()
		int i = currentStrips.length
		while i
			i-=1
			currentStrips[i] = 0
		endWhile
		animateStrip=false
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("Set all the values of the strip slots to the value selected here")
	endEvent
endState

state DanceTimeSL
	Event OnSliderOpenST()
		SetSliderDialogStartValue(customTime[currentSelectedDance])
		SetSliderDialogDefaultValue(currentDances[currentSelectedDance].duration)
		SetSliderDialogRange(0.0, 30.0)
		SetSliderDialogInterval(0.05)
	endEvent

	event OnSliderAcceptST(float a_value)
		if a_value==0.0
			a_value = currentDances[currentSelectedDance].duration
		endIf
		customTime[currentSelectedDance]=a_value
		SetSliderOptionValueST(a_value, "{2} secs")
	endEvent

	event OnDefaultST()
		customTime[currentSelectedDance]=currentDances[currentSelectedDance].duration
		SetSliderOptionValueST(currentDances[currentSelectedDance].duration, "{2} secs")
	endEvent

	event OnHighlightST()
		SetInfoText("Define how long the Dance will last, set it to zero (0) or click on Default to reset it to the normal dance time.")
	endEvent
endState

state PerfTimeSL
	Event OnSliderOpenST()
		SetSliderDialogStartValue(customTime[currentSelectedDance])
		SetSliderDialogDefaultValue(30.0)
		SetSliderDialogRange(5, 240)
		SetSliderDialogInterval(1)
	endEvent

	event OnSliderAcceptST(float a_value)
		performanceTime=a_value
		SetSliderOptionValueST(performanceTime, "{2} secs")
	endEvent

	event OnDefaultST()
		customTime[currentSelectedDance]=30.0
		SetSliderOptionValueST(30.0, "{2} secs")
	endEvent

	event OnHighlightST()
		SetInfoText("Define how long the Performance will last")
	endEvent
endState

state StripTimeST
	Event OnSliderOpenST()
		SetSliderDialogStartValue(stripTime)
		SetSliderDialogDefaultValue(3.0)
		SetSliderDialogRange(0.0, 12.0)
		SetSliderDialogInterval(0.1)
	endEvent

	event OnSliderAcceptST(float a_value)
		stripTime=a_value
		SetSliderOptionValueST(stripTime, "{2} secs")
	endEvent

	event OnDefaultST()
		stripTime=3.0
		SetSliderOptionValueST(3.0, "{2} secs")
	endEvent

	event OnHighlightST()
		SetInfoText("Define how long the Strip will last, in case it is animated")
	endEvent
endState


; -))


; ((- Utility functions

Function cleanOptions()
	int i = opts.length
	while i
		i-=1
		opts[i]=-1
		ids[i]=-1
	endWhile
endFunction


string function trimFloat(float f)
	if f==0.0
		return "0.00"
	endIf
	
	bool neg = f<0.0
	if neg
		f = -f
	endIf
	
	int v = (f * 100) as int
	string r = ""+(v / 100) as int
	r += "." + ((v % 100) / 10) as int
	r += (v % 10) as int
	if neg
		return "-" + r
	endIf
	return r
endFunction

; -))




function playDance(Actor a)
	; Find how we have to play, create the parformance, assign the actor, find if we have a pole, and play it
	if currPerfMode==0
		if numCurrentDances==0
			Debug.Messagebox("No dances are defined\nOpen the MCM of PoleDance Maker and define the sequence of dances for the performance.")
			return
		endIf
	
		spdfPerformance p = spdF.newPerformance(a, placedPole, performanceTime)
		p.setDancesObject(currentDances)
		p.setTimersArray(customTime)
		p.start()
	elseIf currPerfMode==1
		if pickedPose<0
			Debug.Messagebox("No pose has been selected\nOpen the MCM of PoleDance Maker and set the starting pose for the performance.")
			return
		endIf
		spdfPerformance p = spdF.newPerformance(a, placedPole, performanceTime)
		p.setStartPose(poseNames[pickedPose])
		p.start()
		
	elseIf currPerfMode==2
		; TODO tags
	else
		spdF.quickStart(a, placedPole, performanceTime, reg.findRandomStartPose())
	endIf
endFunction






; FIXME DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG 

float dd = -100.0
float za = 12.26
float tt = 0.5
float incr=0.5
ObjectReference marker = none
ObjectReference pole = none

Event onKeyUp(Int KeyCode, Float HoldTime)
	if keyCode==2
		dd+=incr
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==3
		dd-=incr
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==4
		za+=incr
		if za>360.0
			za-=360.0
		endIf
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==5
		za-=incr
		if za<0.0
			za+=360.0
		endIf
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==6
		tt+=incr
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==7
		tt-=incr
		debug.trace("DD=" + trimFloat(dd) + " A="+trimFloat(za) + " t="+trimFloat(tt))
		placeM()
	elseIf keyCode==8
		incr*=2.0
		debug.trace("incr=" + incr)
	elseIf keyCode==9
		incr/=2.0
		debug.trace("incr=" + incr)
		
	elseIf keyCode==10 ; test
		doTest(saadiaClone)
;		doTest(Game.getPlayer())
	elseIf keyCode==11 ; test
		doTest(saadiaClone)
	endIf
endEvent

Actor Property saadiaClone Auto

Function doTest(Actor p)
		placeM()
		float prepx=p.x
		float prepy=p.y
		float prepz=p.getAngleZ()
		if p==game.getplayer()
			Game.SetPlayerAIDriven(true)
			Game.forceThirdPerson()
		endIf
		p.setPosition(marker.x, marker.y, marker.z)
		p.setAngle(0,0,marker.getAngleZ())
		Utility.waitMenuMode(1.0)
		debug.sendAnimationEvent(p, "spdfPose1_Start")
		p.setPosition(pole.X, pole.Y, pole.Z)
		p.setAngle(0.0, 0.0, pole.GetAngleZ())
		p.SetVehicle(pole)
		Utility.waitMenuMode(4.0)
		debug.sendAnimationEvent(p, "spdfPose1_End")
		Utility.waitMenuMode(5.0)
		p.setPosition(marker.X, marker.Y, marker.Z)
		p.setAngle(0.0, 0.0, marker.GetAngleZ())
		p.SetVehicle(marker)
		p.StopTranslation()
		debug.sendAnimationEvent(p, "IdleForceDefaultState")
		if p==game.getplayer()
			Game.SetPlayerAIDriven(false)
		endIf
		Utility.waitMenuMode(0.1)
		p.SetVehicle(None)
endFunction


Function placeM()
	Actor p = saadiaClone ;game.getPlayer()
	if !pole
		pole = spdF.placePole(p, 190, 0)
		p.unequipall()
		saadiaClone.unequipall()
	endIf
	if !marker
		marker = p.placeAtMe(spdF.spdfMarker, 1, false, false)
	endIf
	float newAngle = pole.GetAngleZ() + za
	if newAngle<0.0
		newAngle+=360.0
	endIf
	if newAngle>360.0
		newAngle-=360.0
	endIf
	marker.moveTo(pole, Math.sin(newAngle) * dd, Math.cos(newAngle) * dd, 0.0, true)
	marker.setAngle(0.0, 0.0, pole.getAngleZ())
endFunction

