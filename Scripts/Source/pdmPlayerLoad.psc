Scriptname pdmPlayerLoad extends ReferenceAlias

Event OnInit()
	notShown = true
	init()
endEvent

Event OnPlayerLoadGame()
	Utility.wait(2.0)
	if !notShown
		notShown = true
		init()
	endIf
endEvent

bool notShown = true

Function init()
	spdfPoleDances spdF = spdfPoleDances.getInstance()
	if !spdF
		if notShown
			notShown = false
			Debug.Messagebox("Pole Dance Maker\nrequires the mod\nSkyrim Pole Dances Framework\nto run.")
		endIf
		return
	endIf
endFunction

Spell Property pdmDanceSelf Auto
Spell Property pdmDanceTarget Auto

