Scriptname pdmDanceSelfScript extends ActiveMagicEffect

pdmMCM Property pdm Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	spdfPoleDances spdF = spdfPoleDances.getInstance()
	
	pdm.playDance(Game.getPlayer());
;	p.setDancesString("Strip:body|Head|Hair,Dance CPU,Dance Kom 1,Dance CPU,Dance Kom 1,Strip:!body")
endEvent
