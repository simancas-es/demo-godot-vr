@tool
extends Node3D

@onready var probe : SystemSpatialConcentrationDetector = $ConcentrationDetector

var last_position: Vector3
signal probe_position_changed(new_position: Vector3)

@onready var debug_label : Label3D = %DebugLabel

#Test by moving the probe
func _ready() -> void:	
	probe_position_changed.connect(on_probe_moved)
	last_position = probe.global_transform.origin
	
	if Engine.is_editor_hint():		
		child_entered_tree.connect(on_new_child)
	
func on_new_child(node : Node) -> void:
	if node is SystemSpatialConcentrationDetector:
		probe = node
		
func on_probe_moved(new_pos : Vector3):
	probe.scan_concentration()
	var text = "Concentration: %0.2f" % probe.current_concentration
	debug_label.text = text
	print(text)
	pass
	
func _process(delta):
	if not Engine.is_editor_hint():
		return

	var current_position = probe.global_transform.origin
	if current_position != last_position:
		last_position = current_position
		probe_position_changed.emit(current_position)
