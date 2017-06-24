Scriptname pdmDanceTargetScript extends ActiveMagicEffect

Event OnEffectStartTest(Actor t, Actor akCaster)
	spdfPoleDances spdF = spdfPoleDances.getInstance()

	; Just try to put a pole and a marker in front of the actor
	
	if !t
		return
	endIf
	debug.trace("FIXME Target Position = " + (t.X as int) + "," + (t.Y as int) + " Z=" + (t.getAngleZ() as int))
	
	ObjectReference p = spdF.placePole(t, 100.0, 0.0)
	debug.trace("FIXME Pole Position = " + (p.X as int) + "," + (p.Y as int) + " Z=" + (p.getAngleZ() as int))
	
	ObjectReference m = p.placeAtMe(spdF.spdfMarker, 1, false, false)
	m.moveTo(p, Math.sin(p.GetAngleZ() - 18.237) * -30.0, Math.cos(p.GetAngleZ() - 18.237) * -30.0, 0.0, true)
	m.setAngle(0.0, 0.0, p.getAngleZ())

	debug.trace("FIXME Marker Position = " + (m.X as int) + "," + (m.Y as int) + " Z=" + (m.getAngleZ() as int))
	Utility.wait(5.0)
	m.delete()
	p.delete()
endEvent




Event OnEffectStart(Actor akTarget, Actor akCaster)
	spdfPoleDances spdF = spdfPoleDances.getInstance()
	
	if akTarget
		spdF.quickStart(akTarget, None, 26.0, "Pose 1")
	else
		Debug.notification("You hit nobody for a pole dance.")
	endIf
endEvent
