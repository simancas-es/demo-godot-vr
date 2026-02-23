extends Node

@export_group("Buttons")
@export var out_button : MachineToggleable
@export var in_button : MachineToggleable
@export var halt_button : Interaction

@export_group("Rails")
@export var path: Path3D
@export var target_node: Node3D
@export var duration: float = 10.0  # seconds from start to end
@export var rotate_with_path: bool = true  # should the node rotate along the path?

# Internal
var _path_follow: PathFollow3D
var _progress: float = 0.0
var _goal: float = 1.0
var _speed: float = 0.0
var _moving: bool = false

func _ready() -> void:
	if path == null or target_node == null:
		push_error("Path or target_node not assigned!")
		return

	# Create PathFollow3D if not already existing
	_path_follow = PathFollow3D.new()
	path.add_child(_path_follow)
	_path_follow.progress_ratio = 0.0
	# Set rotation mode
	if rotate_with_path:
		_path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	else:
		_path_follow.rotation_mode = PathFollow3D.ROTATION_NONE


	# Reparent the target node under PathFollow3D
	target_node.get_parent().remove_child(target_node)
	_path_follow.add_child(target_node)
	target_node.transform.origin = Vector3.ZERO  # position relative to PathFollow3D

	# Connect buttons
	if out_button and in_button:
		out_button.turned_on.connect(bring_out)
		in_button.turned_on.connect(bring_in)
	if halt_button:
		halt_button.activated.connect(on_halt_pressed)

	set_process(false)

func bring_out(..._args):
	_goal = 1.0
	_speed = 1.0 / duration
	_moving = true
	set_process(true)
	
func bring_in(..._args):
	_goal = 0.0
	_speed = 1.0 / duration
	_moving = true
	set_process(true)
	
func on_halt_pressed(..._args):
	_moving = false
	set_process(false)

func _process(delta: float) -> void:
	if not _moving:
		return
		
	var _dir = _goal - _progress
	var dir_sign = 1

	if _dir > 0:
		dir_sign = 1
	elif _dir < 0:
		dir_sign = -1

	_progress += _speed * delta * dir_sign
	if (dir_sign>0) and _progress >= _goal:
		_progress = _goal
		_moving = false
		set_process(false)
	elif (dir_sign<0) and _progress <= _goal:
		_progress = _goal
		_moving = false
		set_process(false)
	# Update PathFollow3D offset
	_path_follow.progress_ratio = _progress
