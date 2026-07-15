extends Node3D

@export var pivot : Node3D
@export var schraube1 : Node3D
@export var schraube2 : Node3D


var active_pivot : bool = false

var speed_nkb_pivot_deg_s = -1
var speed_nkb_schrauben_deg_s = 20

const ICEBREAKER := preload("uid://cmmkdjodihp4u")
@onready var ice_breaker : ICEBREAKER = %ice_breaker

const ICEWEDGE := preload("uid://tkkfmgm7bgqe")
const ICESCHRAUBEN := preload("uid://cxeqgg2dlr831")
@onready var ice_schrauben = $AnimatableBody3D/ice_schrauben
signal updated

func _ready() -> void:
	active_pivot = true
	ice_breaker.found_ice.connect(stop)
	ice_breaker.no_ice.connect(resume)
	
	#HACK
	for c : ICEWEDGE in $ice_surface.get_children():
		c.updated.connect(updated.emit)
	ice_schrauben.updated.connect(updated.emit)
	pass
	
func stop() -> void:
	active_pivot = false

func resume() -> void:
	active_pivot = true
	
func _try_rotate(item : Node3D, speed_deg : float, delta) -> void:
	if item == null : return
	item.rotate(item.basis.y.normalized(), deg_to_rad(speed_deg) * delta) # Remember axis z in blender is y in godot for convenience
	pass
	
func _process(delta: float) -> void:
	if !active_pivot: return
	if ice_schrauben.current_state == ICESCHRAUBEN.STATE.BROKEN:
		_try_rotate(schraube1, -speed_nkb_schrauben_deg_s, delta)
		_try_rotate(schraube2, -speed_nkb_schrauben_deg_s, delta)
	_try_rotate(pivot, speed_nkb_pivot_deg_s, delta)
	
	
func count_ice_left() -> int:
	var count := 0
	if $AnimatableBody3D/ice_schrauben.current_state == ICESCHRAUBEN.STATE.NORMAL:
		count += 1
	for c : ICEWEDGE in $ice_surface.get_children():
		if c.current_state == ICEWEDGE.STATE.NORMAL:
			count += 1
	return count
