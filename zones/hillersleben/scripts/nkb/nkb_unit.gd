extends Node3D

@export var pivot : Node3D
@export var schraube1 : Node3D
@export var schraube2 : Node3D


var active_schraube : bool = false

var speed_nkb_pivot_deg_s = -1
var speed_nkb_schrauben_deg_s = 20

func try_rotate(item : Node3D, speed_deg : float, delta) -> void:
	if item == null : return
	item.rotate(item.basis.y.normalized(), deg_to_rad(speed_deg) * delta) # Remember axis z in blender is y in godot for convenience
	pass
	
func _process(delta: float) -> void:
	try_rotate(schraube1, -speed_nkb_schrauben_deg_s, delta)
	try_rotate(schraube2, -speed_nkb_schrauben_deg_s, delta)
	try_rotate(pivot, speed_nkb_pivot_deg_s, delta)
