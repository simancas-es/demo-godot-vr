extends Node

const GROUP_NAME: StringName = &"minimap_tracker"

@export var tracker_id: StringName = &""
@export var display_name: String = ""
@export var tags: Array[StringName] = []
@export var visible_on_minimap: bool = true
@export var centers_minimap: bool = false
@export var center_priority: int = 0
@export var marker_texture: Texture2D = null
@export var marker_color: Color = Color(0.0, 0.85, 1.0, 1.0)

func _enter_tree() -> void:
	add_to_group(GROUP_NAME)

func _exit_tree() -> void:
	remove_from_group(GROUP_NAME)

func is_minimap_tracker() -> bool:
	return true

func has_valid_tracker_id() -> bool:
	return not String(tracker_id).is_empty()

func get_tracked_node() -> Node3D:
	var parent_node: Node = get_parent()
	return parent_node as Node3D

func is_coordinate_available() -> bool:
	return get_tracked_node() != null

func get_world_position() -> Vector3:
	var tracked_node: Node3D = get_tracked_node()
	if tracked_node == null:
		return Vector3.ZERO
	return tracked_node.global_position if tracked_node.is_inside_tree() else tracked_node.position
