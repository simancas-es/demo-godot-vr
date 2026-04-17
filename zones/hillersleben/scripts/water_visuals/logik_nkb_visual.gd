extends Node

@export var nkb1_pivot : Node3D = null
@export var nkb2_pivot : Node3D = null
@export var nkb1_schrauben1 : Node3D = null
@export var nkb1_schrauben2 : Node3D = null
@export var nkb2_schrauben1 : Node3D = null
@export var nkb2_schrauben2 : Node3D = null

#TODO: Control with the simulation

var speed_nkb1_pivot_deg_s = 1
var speed_nkb2_pivot_deg_s = 1
var speed_nkb1_schrauben1_deg_s = 20
var speed_nkb1_schrauben2_deg_s = 20
var speed_nkb2_schrauben1_deg_s = 20
var speed_nkb2_schrauben2_deg_s = 20

func try_rotate(item : Node3D, speed_deg : float, delta) -> void:
	if item == null : return
	item.rotate(item.basis.y.normalized(), deg_to_rad(speed_deg) * delta) # Remember axis z in blender is y in godot for convenience
	pass
func _process(delta: float) -> void:
	try_rotate(nkb1_pivot, speed_nkb1_pivot_deg_s, delta)
	try_rotate(nkb2_pivot, speed_nkb2_pivot_deg_s, delta)
	try_rotate(nkb1_schrauben1, speed_nkb1_schrauben1_deg_s, delta)
	try_rotate(nkb1_schrauben2, speed_nkb1_schrauben2_deg_s, delta)
	try_rotate(nkb2_schrauben1, speed_nkb2_schrauben1_deg_s, delta)
	try_rotate(nkb2_schrauben2, speed_nkb2_schrauben2_deg_s, delta)
