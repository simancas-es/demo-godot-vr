extends Node3D
@onready var valve : ENTITY_CATALOG.ValveRotating = $basic_pipe_valve

func _ready() -> void:
	
	
	await get_tree().create_timer(0.5).timeout
	valve.rotate_wheel(-150.0)
	await get_tree().create_timer(0.5).timeout
	valve.rotate_wheel(+370.0)
	
	
