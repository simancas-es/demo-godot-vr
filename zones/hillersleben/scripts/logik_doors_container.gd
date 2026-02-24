extends Node
const GarageState = preload("uid://d2x1a26haj0vt")
const GarageSystem = preload("uid://b6e83lkv2jy1t")

@export var garage_door_body : Node3D
@export var garage_door_time_open_s : float = 3.0
@export var lift_height : float = 2.0

@export var state : GarageState
@export var system : GarageSystem

# Internal
var _mesh : Node3D
var _static_body : StaticBody3D
var _closed_position : Vector3
var _open_position : Vector3

var _current_visual_state : GarageState.DoorState

func _ready() -> void:
	if garage_door_body == null:
		push_error("Missing garage_door_body!")
		return

	_mesh = garage_door_body.get_node("MeshInstance3D")
	_static_body = garage_door_body.get_node("StaticBody3D")

	_closed_position = _mesh.position
	_open_position = _closed_position + Vector3.UP * lift_height

	

func init() -> void:
	if state == null or system == null:
		push_error("DoorController missing state or system injection!")
		return
	system.state_changed.connect(_sync_with_state)
	_apply_state_immediately(state.door_state)
	
	
func _sync_with_state() -> void:
	if state.door_state == _current_visual_state:
		return

	match state.door_state:
		GarageState.DoorState.OPEN, GarageState.DoorState.OPENING:
			_animate_open()
		GarageState.DoorState.CLOSED, GarageState.DoorState.CLOSING:
			_animate_close()

func _apply_state_immediately(door_state : GarageState.DoorState) -> void:
	_current_visual_state = door_state
	if door_state in [GarageState.DoorState.OPEN, GarageState.DoorState.OPENING]:
		_mesh.position = _open_position
		_static_body.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		_mesh.position = _closed_position
		_static_body.process_mode = Node.PROCESS_MODE_INHERIT

func _animate_open() -> void:
	_current_visual_state = GarageState.DoorState.OPENING
	_static_body.process_mode = Node.PROCESS_MODE_DISABLED

	var tween := create_tween()
	tween.tween_property(_mesh, "position", _open_position, garage_door_time_open_s)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		_current_visual_state = GarageState.DoorState.OPEN
		state.door_state = GarageState.DoorState.OPEN
	)

func _animate_close() -> void:
	_current_visual_state = GarageState.DoorState.CLOSING
	var tween := create_tween()
	tween.tween_property(_mesh, "position", _closed_position, garage_door_time_open_s)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		_current_visual_state = GarageState.DoorState.CLOSED
		state.door_state = GarageState.DoorState.CLOSED
		_static_body.process_mode = Node.PROCESS_MODE_INHERIT
	)
