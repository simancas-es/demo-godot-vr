extends Node3D

@export var pivot : Node3D
@export var schraube1 : Node3D
@export var schraube2 : Node3D


var active_schraube : bool = false

var speed_nkb_pivot_deg_s = -1
var speed_nkb_schrauben_deg_s = 20

signal ice_broken

const ICEBREAKER := preload("uid://cmmkdjodihp4u")
@onready var ice_breaker : ICEBREAKER = %ice_breaker

func _ready() -> void:
	active_schraube = true
	ice_breaker.found_ice.connect(stop)
	ice_breaker.no_ice.connect(resume)
	pass
	
func stop() -> void:
	active_schraube = false

func resume() -> void:
	active_schraube = true
	
func _try_rotate(item : Node3D, speed_deg : float, delta) -> void:
	if item == null : return
	item.rotate(item.basis.y.normalized(), deg_to_rad(speed_deg) * delta) # Remember axis z in blender is y in godot for convenience
	pass
	
func _process(delta: float) -> void:
	if !active_schraube: return
	_try_rotate(schraube1, -speed_nkb_schrauben_deg_s, delta)
	_try_rotate(schraube2, -speed_nkb_schrauben_deg_s, delta)
	_try_rotate(pivot, speed_nkb_pivot_deg_s, delta)
	
	
