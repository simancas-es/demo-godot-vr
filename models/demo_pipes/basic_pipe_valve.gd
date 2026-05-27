extends Node3D
#class_name ValveRotating
#Script purely cosmetic.

##Rotates the wheel left or right on interaction...

@onready var wheel : MeshInstance3D = %ValveWheel
var tween_rotate : Tween = null

##Rotates the wheel so many degrees to the right
func rotate_wheel(deg : float, degs_per_s : float = 180.0) -> void:
	if degs_per_s < 0.0:
		wheel.rotation.y = wheel.rotation.y + deg_to_rad(deg)
		return
		
	if tween_rotate: tween_rotate.kill()
	var time_s = abs(deg/degs_per_s)
	
	tween_rotate = create_tween()	
	tween_rotate.tween_property(wheel, "rotation:y", wheel.rotation.y + deg_to_rad(deg), time_s)
	##BUG lerp_angle
	await tween_rotate.finished

func rotate_wheel_target(deg: float, degs_per_s: float = 180.0) -> void:
	if degs_per_s < 0.0:
		wheel.rotation.y = deg_to_rad(deg)
		return
		
	if tween_rotate:
		tween_rotate.kill()

	var current_deg = rad_to_deg(wheel.rotation.y)

	var current_mod = fmod(current_deg, 360.0)
	if current_mod < 0:
		current_mod += 360.0
		
	var target_mod = fmod(deg, 360.0)
	if target_mod < 0:
		target_mod += 360.0

	var delta = target_mod - current_mod
	if delta < 0:
		delta += 360.0

	var final_deg = current_deg + delta

	if final_deg < deg:
		var missing = deg - final_deg
		var extra_turns = ceil(missing / 360.0)
		final_deg += extra_turns * 360.0

	var target_rot = deg_to_rad(final_deg)
	var time_s = abs((final_deg - current_deg) / degs_per_s)

	tween_rotate = create_tween()
	tween_rotate.tween_property(wheel, "rotation:y", target_rot, time_s)
	
	await tween_rotate.finished
