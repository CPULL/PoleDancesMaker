Scriptname pdmDanceTargetScript extends ActiveMagicEffect

pdmMCM Property pdm Auto

Event OnEffectStart(Actor t, Actor akCaster)
	pdm.playDance(akTarget)
endEvent

