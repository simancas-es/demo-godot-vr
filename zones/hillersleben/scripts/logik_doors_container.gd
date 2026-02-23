extends Node
#Logic for the garage door of the room that has the container for the washed sand and garbage.
#Normal door opens as usual. Garage door opens from a button inside.

@export_group("Garage Door")
@export var button_garage_door : MachineToggleable
@export var garage_door_time_open_s : float = 3.0
@export var garage_door_body : Node3D   # Contains MeshInstance3D + StaticBody3D
@export var lift_height := 2.0
enum STATE { ON, OFF }
var current_state : STATE
var _mesh : Node3D
var _static_body : StaticBody3D
var _closed_position : Vector3
var _open_position : Vector3


func _ready() -> void:
	if garage_door_body == null:
		push_error("Missing garage_door_body!")
		return

	_mesh = garage_door_body.get_node("MeshInstance3D")
	_static_body = garage_door_body.get_node("StaticBody3D")

	# Cache absolute positions
	_closed_position = _mesh.position
	_open_position = _closed_position + Vector3.UP * lift_height

	# Connect signals
	if button_garage_door != null:
		button_garage_door.turned_on.connect(_on_door_open_requested)
		button_garage_door.turned_off.connect(_on_door_close_requested)
	else:
		push_error("Missing garage door button!")

	# Initialize state (default = OFF / closed)
	current_state = STATE.OFF
	_apply_state_immediately(current_state)

func _apply_state_immediately(state: STATE) -> void:
	current_state = state
	
	if state == STATE.ON:
		_mesh.position = _open_position
		_static_body.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		_mesh.position = _closed_position
		_static_body.process_mode = Node.PROCESS_MODE_INHERIT

func _animate_to_state(state: STATE) -> void:
	current_state = state
	
	var target_position : Vector3
	
	if state == STATE.ON:
		target_position = _open_position
		_static_body.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		target_position = _closed_position
		_static_body.process_mode = Node.PROCESS_MODE_INHERIT

	var tween := create_tween()
	tween.tween_property(_mesh, "position", target_position, garage_door_time_open_s)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


func _on_door_open_requested() -> void:
	if current_state == STATE.ON:
		return
	_animate_to_state(STATE.ON)


func _on_door_close_requested() -> void:
	if current_state == STATE.OFF:
		return
	_animate_to_state(STATE.OFF)
