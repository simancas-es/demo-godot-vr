extends Node

@export var raumer : MeshInstance3D
@onready var pathf : PathFollow3D = $"../Path3D/PathFollow3D" 

@export var full_cycle_s : float = 60.0

func _ready() -> void:
	raumer.reparent(pathf)
	pass
	
var _time_delta_s : float = 0.0
func _process(delta: float) -> void:
	if raumer:
		_time_delta_s += delta
		pathf.progress_ratio = clampf(_time_delta_s/full_cycle_s, 0.0, 1.0)
		_time_delta_s = fmod(_time_delta_s, full_cycle_s)
		pass
	
	pass
