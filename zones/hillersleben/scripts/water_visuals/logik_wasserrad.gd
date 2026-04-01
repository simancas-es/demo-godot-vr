extends Node

@export var wasserrad_drehen : Node3D = null

var is_on : bool = true
var _speed_deg_s : float = 90

@export var speed_deg_set: float = 90:
	get: return _speed_deg_s
	set(value):
		_speed_deg_s = value
		
var _tween : Tween


func _process(delta: float) -> void:
	if wasserrad_drehen == null:
		return
	wasserrad_drehen.rotate(wasserrad_drehen.transform.basis.y.normalized(), deg_to_rad(-_speed_deg_s) * delta)
