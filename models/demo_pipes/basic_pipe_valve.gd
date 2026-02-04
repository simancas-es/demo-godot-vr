extends Node3D
#class_name ValveRotating
#Script purely cosmetic.

##Rotates the wheel left or right on interaction...

@export var rotation_velocity_degs = 180.0
@onready var wheel : MeshInstance3D = %ValveWheel
var tween_rotate : Tween = null

##Rotates the wheel so many degrees to the right
func rotate_wheel(deg : float) -> void:
	if tween_rotate: tween_rotate.kill()
	var time_s = abs(deg/rotation_velocity_degs)
	
	tween_rotate = create_tween()	
	tween_rotate.tween_property(wheel, "rotation:y", wheel.rotation.y + deg_to_rad(deg), time_s)
	##BUG lerp_angle
	await tween_rotate.finished
