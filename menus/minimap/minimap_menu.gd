extends Control

const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapControl := preload("res://menus/minimap/minimap_control.gd")

@onready var _minimap_control: MinimapControl = %MinimapControl

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	visible = false

func show_for(controller: MinimapController) -> void:
	visible = true
	_minimap_control.show_for(controller)

func close() -> void:
	visible = false
	_minimap_control.clear()

func is_open() -> bool:
	return visible

func update_map_offset() -> bool:
	return _minimap_control.update_map_offset()

func get_last_map_offset() -> Vector2:
	return _minimap_control.get_last_map_offset()

func get_active_controller() -> MinimapController:
	return _minimap_control.get_active_controller()
