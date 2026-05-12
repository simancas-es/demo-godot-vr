extends Node3D

const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapControl := preload("res://menus/minimap/minimap_control.gd")

@export var projection_source_path: NodePath
@export var tracker_root_path: NodePath
@export var screen_size: Vector2 = Vector2(2.0, 2.0)
@export var viewport_size: Vector2i = Vector2i(1024, 1024)
@export var update_fps: float = 15.0
@export var bind_retry_interval_seconds: float = 1.0
@export var visible_when_unavailable: bool = false

@onready var _viewport_2d_in_3d: Node = %Viewport2Din3D

var _controller: MinimapController = MinimapController.new()
var _minimap_control: MinimapControl = null
var _bind_retry_elapsed_seconds: float = 0.0

func _ready() -> void:
	_configure_viewport()
	bind_from_paths()
	set_process(true)

func _process(delta: float) -> void:
	if _controller.is_available():
		return
	_bind_retry_elapsed_seconds += maxf(delta, 0.0)
	var retry_interval_seconds: float = maxf(bind_retry_interval_seconds, 1.0)
	if _bind_retry_elapsed_seconds < retry_interval_seconds:
		return
	_bind_retry_elapsed_seconds = 0.0
	bind_from_paths()

func bind_from_paths() -> bool:
	var projection_source: Node = null
	if not String(projection_source_path).is_empty():
		projection_source = get_node_or_null(projection_source_path)
	var tracker_root: Node = null
	if not String(tracker_root_path).is_empty():
		tracker_root = get_node_or_null(tracker_root_path)
	return bind(projection_source, tracker_root)

func bind(projection_source: Node, tracker_root: Node) -> bool:
	_controller.bind(projection_source, tracker_root)
	_bind_retry_elapsed_seconds = 0.0
	return refresh()

func refresh() -> bool:
	_resolve_minimap_control()
	var is_available: bool = _controller.refresh()
	visible = is_available or visible_when_unavailable
	if _minimap_control == null:
		return is_available
	if is_available:
		_minimap_control.show_for(_controller)
	else:
		_minimap_control.clear()
	return is_available

func get_controller() -> MinimapController:
	return _controller

func get_minimap_control() -> MinimapControl:
	_resolve_minimap_control()
	return _minimap_control

func get_unavailable_reason() -> String:
	return _controller.get_unavailable_reason()

func _configure_viewport() -> void:
	if _viewport_2d_in_3d == null:
		return
	_viewport_2d_in_3d.set("screen_size", screen_size)
	_viewport_2d_in_3d.set("viewport_size", Vector2(float(viewport_size.x), float(viewport_size.y)))
	_viewport_2d_in_3d.set("update_mode", 2)
	_viewport_2d_in_3d.set("throttle_fps", maxf(update_fps, 1.0))
	_viewport_2d_in_3d.set("enabled", false)
	_viewport_2d_in_3d.set("input_keyboard", false)
	_viewport_2d_in_3d.set("input_gamepad", false)

func _resolve_minimap_control() -> void:
	if _minimap_control != null and is_instance_valid(_minimap_control):
		return
	if _viewport_2d_in_3d == null or not _viewport_2d_in_3d.has_method("get_scene_instance"):
		return
	_minimap_control = _viewport_2d_in_3d.call("get_scene_instance") as MinimapControl
