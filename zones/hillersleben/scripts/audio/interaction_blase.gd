extends Area3D

signal detected_rc(position, event)
func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		detected_rc.emit(position, event)
		
