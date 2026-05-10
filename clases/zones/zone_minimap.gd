extends Node3D

const ANCHOR_DELTA_EPSILON: float = 0.001

@export var map_texture: Texture2D = null
@export var world_anchor_a: Node3D = null
@export var world_anchor_b: Node3D = null
@export var map_anchor_a_pixels: Vector2 = Vector2.ZERO
@export var map_anchor_b_pixels: Vector2 = Vector2.ZERO

func is_projection_available() -> bool:
	return map_texture != null and world_anchor_a != null and world_anchor_b != null and is_map_anchor_valid(map_anchor_a_pixels) and is_map_anchor_valid(map_anchor_b_pixels) and get_derived_map_scale() > 0.0

func is_map_anchor_valid(map_anchor_pixels: Vector2) -> bool:
	return not is_nan(map_anchor_pixels.x) and not is_nan(map_anchor_pixels.y) and not is_inf(map_anchor_pixels.x) and not is_inf(map_anchor_pixels.y)

func get_projection_unavailable_reason() -> String:
	if map_texture == null:
		return "missing map texture"
	if world_anchor_a == null:
		return "missing world anchor A"
	if world_anchor_b == null:
		return "missing world anchor B"
	if not is_map_anchor_valid(map_anchor_a_pixels):
		return "invalid map anchor A pixels"
	if not is_map_anchor_valid(map_anchor_b_pixels):
		return "invalid map anchor B pixels"
	if get_derived_map_scale() <= 0.0:
		return "invalid anchor calibration"
	return ""

func get_derived_map_scale() -> float:
	if world_anchor_a == null or world_anchor_b == null:
		return 0.0

	var world_delta: Vector2 = _get_anchor_world_xz(world_anchor_b) - _get_anchor_world_xz(world_anchor_a)
	var map_delta: Vector2 = map_anchor_b_pixels - map_anchor_a_pixels
	var world_delta_length: float = world_delta.length()
	if world_delta_length <= ANCHOR_DELTA_EPSILON or map_delta.length() <= ANCHOR_DELTA_EPSILON:
		return 0.0
	return map_delta.length() / world_delta_length

func world_to_map_position(world_position: Vector3) -> Vector2:
	if not is_projection_available():
		return Vector2.ZERO
	var world_delta: Vector2 = Vector2(world_position.x, world_position.z) - _get_anchor_world_xz(world_anchor_a)
	return map_anchor_a_pixels + _world_delta_to_map_delta(world_delta)

func _get_anchor_world_xz(anchor: Node3D) -> Vector2:
	var anchor_position: Vector3 = anchor.global_position if anchor.is_inside_tree() else anchor.position
	return Vector2(anchor_position.x, anchor_position.z)

func _world_delta_to_map_delta(world_delta: Vector2) -> Vector2:
	var world_anchor_delta: Vector2 = _get_anchor_world_xz(world_anchor_b) - _get_anchor_world_xz(world_anchor_a)
	var map_anchor_delta: Vector2 = map_anchor_b_pixels - map_anchor_a_pixels
	var denominator: float = world_anchor_delta.length_squared()
	if denominator <= ANCHOR_DELTA_EPSILON:
		return Vector2.ZERO
	var along_axis: float = world_delta.dot(world_anchor_delta) / denominator
	var across_axis: float = world_anchor_delta.cross(world_delta) / denominator
	var map_perpendicular: Vector2 = Vector2(-map_anchor_delta.y, map_anchor_delta.x)
	return (map_anchor_delta * along_axis) + (map_perpendicular * across_axis)
