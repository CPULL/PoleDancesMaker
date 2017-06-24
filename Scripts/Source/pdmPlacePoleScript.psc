Scriptname pdmPlacePoleScript extends ActiveMagicEffect

pdmMCM Property pdm Auto
bool stillActive = false

Event OnEffectStart(Actor akTarget, Actor akCaster)
	spdfPoleDances spdF = spdfPoleDances.getInstance()
	if pdm.placedPole
		pdm.placedPole.delete()
		pdm.placedPole = none
		Debug.notification("Previous pole is removed")
		return
	endIf
	
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
	pdm.placedPole.SetPosition(p.X + Math.sin(zAngle) * 175.0, p.Y + Math.cos(zAngle) * 175.0, p.Z)
	if pdm.placedPole.getAngleZ()!=zAngle
		pdm.placedPole.setAngle(0.0, 0.0, zAngle)
	endIf
	if stillActive
		RegisterForSingleUpdate(0.35)
	endIf
endEvent



Event OnEffectFinish(Actor akTarget, Actor akCaster)
	stillActive = false
endEvent

