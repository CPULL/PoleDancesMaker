Scriptname pdmPlacePoleScript extends ActiveMagicEffect

pdmMCM Property pdm Auto
bool stillActive = false
float prevX = -1.0
float prevY = -1.0

Event OnEffectStart(Actor akTarget, Actor akCaster)
	spdfPoleDances spdF = spdfPoleDances.getInstance()
	if pdm.placedPole
		pdm.placedPole.delete()
		pdm.placedPole = none
		Debug.notification("Previous pole is removed")
		return
	endIf
	
	prevX = -1.0
	prevY = -1.0
	pdm.placedPole = spdF.placePole(None, 175.0, 0.0, -1)
	stillActive = true
	RegisterForSingleUpdate(0.35)
endEvent



Event OnUpdate()
	if !pdm.placedPole || !stillActive
		return
	endIf

	Actor p = Game.getPlayer()
	float zAngle = p.getAngleZ()
	float newX = p.X + Math.sin(zAngle) * 175.0
	float newY = p.Y + Math.cos(zAngle) * 175.0
	if newX!=prevX || newY!=prevY
		pdm.placedPole.SetPosition(newX, newY, p.Z)
		if pdm.placedPole.getAngleZ()!=zAngle
			pdm.placedPole.setAngle(0.0, 0.0, zAngle)
		endIf
		prevX=newX
		prevY=newY
	endIf
	if stillActive
		RegisterForSingleUpdate(0.35)
	endIf
endEvent



Event OnEffectFinish(Actor akTarget, Actor akCaster)
	stillActive = false
endEvent

