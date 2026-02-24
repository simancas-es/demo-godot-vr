extends Node
const GarageState = preload("uid://d2x1a26haj0vt")
const GarageSystem = preload("uid://b6e83lkv2jy1t")
@export var path: Path3D
@export var target_node: Node3D
@export var speed: float = 1/5.0 #Time to fraction
@export var rotate_with_path: bool = true

@export var state : GarageState
@export var system : GarageSystem
@export var container_index : int = 0  # supports multiple containers

# Internal
var _path_follow: PathFollow3D
var _progress: float = 0.0
var _goal: float = 0.0
var _moving: bool = false
var _current_visual_state : GarageState.ContainerState

func _ready() -> void:
	if path == null or target_node == null:
		push_error("Path or target_node not assigned!")
		return
	

	_path_follow = PathFollow3D.new()
	path.add_child(_path_follow)
	_path_follow.progress_ratio = 0.0
	
	if rotate_with_path:
		_path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	else: _path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
	
	target_node.get_parent().remove_child(target_node)
	_path_follow.add_child(target_node)
	target_node.transform.origin = Vector3.ZERO

	

func init() -> void:
	if state == null or system == null:
		push_error("ContainerController missing state or system injection!")
		return
	system.state_changed.connect(_sync_with_state)

	_apply_state_immediately(state.container_states[container_index])
	set_process(true)
	
	
func _sync_with_state() -> void:
	var desired_state = state.container_states[container_index]
	if desired_state == _current_visual_state:
		return
		
	match desired_state:
		GarageState.ContainerState.MOVING_OUT:
			_start_move(1.0)
		GarageState.ContainerState.MOVING_IN:
			_start_move(0.0)
			


func _apply_state_immediately(container_state):
	_current_visual_state = container_state
	if container_state  in [GarageState.ContainerState.INSIDE, GarageState.ContainerState.MOVING_IN]:
		_progress = 0.0
	else:
		_progress = 1.0
	_path_follow.progress_ratio = _progress

func _start_move(goal: float) -> void:
	_goal = goal
	_moving = true
	_current_visual_state = GarageState.ContainerState.INBETWEEN

func _process(delta: float) -> void:
	if not _moving:
		return

	var dir_sign = sign(_goal - _progress)
	_progress += speed * delta * dir_sign

	#Excess control
	if (dir_sign >= 0 and _progress >= _goal) or (dir_sign <= 0 and _progress <= _goal):
		_progress = _goal
		_moving = false
		_on_reached_goal()

	_path_follow.progress_ratio = _progress

func _on_reached_goal() -> void:
	if _goal >= 1.0:
		state.container_states[container_index] = GarageState.ContainerState.OUTSIDE
		_current_visual_state = GarageState.ContainerState.OUTSIDE
	elif _goal <= 0.01:
		state.container_states[container_index] = GarageState.ContainerState.INSIDE
		_current_visual_state = GarageState.ContainerState.INSIDE
	else:
		state.container_states[container_index] = GarageState.ContainerState.INBETWEEN
		_current_visual_state = GarageState.ContainerState.INBETWEEN
