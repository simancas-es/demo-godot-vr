extends GutTest

const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapMarkerState := preload("res://systems/system-minimap/minimap_marker_state.gd")
const MinimapTracker := preload("res://systems/system-minimap/minimap_tracker.gd")

class ProjectionSource extends Node:
	var map_texture: Texture2D = null
	var available: bool = true

	func is_projection_available() -> bool:
		return available

	func get_projection_unavailable_reason() -> String:
		return "test projection unavailable"

	func world_to_map_position(world_position: Vector3) -> Vector2:
		return Vector2(world_position.x * 10.0, world_position.z * 10.0)

var _controller: MinimapController = null
var _projection_source: ProjectionSource = null
var _root: Node3D = null

func before_each() -> void:
	_controller = MinimapController.new()
	_projection_source = add_child_autoqfree(ProjectionSource.new())
	_projection_source.map_texture = _make_texture()
	_root = add_child_autoqfree(Node3D.new())

func after_each() -> void:
	_controller = null
	_projection_source = null
	_root = null

func test_controller_discovers_multiple_trackers_below_root() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_add_tracker("other", Vector3(3.0, 0.0, 4.0), false)
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 2)
	assert_eq(_controller.get_center_tracker_id(), &"center")
	assert_eq(_controller.get_center_map_position(), Vector2(10.0, 20.0))

func test_controller_ignores_invisible_trackers_for_marker_output() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	var hidden_tracker: MinimapTracker = _add_tracker("hidden", Vector3(5.0, 0.0, 6.0), false)
	hidden_tracker.visible_on_minimap = false
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 1)

func test_controller_selects_center_by_priority_then_tracker_id() -> void:
	var tracker_b: MinimapTracker = _add_tracker("b_center", Vector3(2.0, 0.0, 0.0), true)
	var tracker_a: MinimapTracker = _add_tracker("a_center", Vector3(1.0, 0.0, 0.0), true)
	tracker_b.center_priority = 1
	tracker_a.center_priority = 1
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_center_tracker_id(), &"a_center")
	tracker_b.center_priority = 2
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_center_tracker_id(), &"b_center")

func test_controller_reports_unavailable_without_center_tracker() -> void:
	_add_tracker("visible", Vector3(1.0, 0.0, 2.0), false)
	_controller.bind(_projection_source, _root)
	assert_false(_controller.refresh())
	assert_eq(_controller.get_unavailable_reason(), "no minimap center tracker")

func test_controller_reports_unavailable_for_empty_tracker_id() -> void:
	_add_tracker("", Vector3(1.0, 0.0, 2.0), true)
	_controller.bind(_projection_source, _root)
	assert_false(_controller.refresh())
	assert_eq(_controller.get_unavailable_reason(), "invalid empty minimap tracker id")

func test_controller_marker_state_has_no_source_gameplay_object() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	var marker_states: Array[MinimapMarkerState] = _controller.get_visible_marker_states()
	assert_eq(marker_states[0].tracker_id, &"center")
	assert_eq(marker_states[0].map_position, Vector2(10.0, 20.0))
	assert_false(marker_states[0].has_method("get_source_node"))

func test_controller_reports_projection_unavailable_reason() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_projection_source.available = false
	_controller.bind(_projection_source, _root)
	assert_false(_controller.refresh())
	assert_eq(_controller.get_unavailable_reason(), "test projection unavailable")

func test_controller_refresh_updates_cached_tracker_positions_without_rediscovery() -> void:
	var tracker: MinimapTracker = _add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_center_map_position(), Vector2(10.0, 20.0))
	var tracked_node: Node3D = tracker.get_parent() as Node3D
	tracked_node.position = Vector3(7.0, 0.0, 8.0)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_center_map_position(), Vector2(70.0, 80.0))

func test_controller_discovers_new_trackers_only_after_discovery_tick() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 1)
	_add_tracker("new_marker", Vector3(3.0, 0.0, 4.0), false)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 1)
	assert_true(_controller.tick(0.99), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 1)
	assert_true(_controller.tick(0.01), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 2)

func test_controller_discovery_tick_has_one_second_minimum() -> void:
	_add_tracker("center", Vector3(1.0, 0.0, 2.0), true)
	_controller.tracker_discovery_interval_seconds = 0.1
	_controller.bind(_projection_source, _root)
	assert_true(_controller.refresh(), _controller.get_unavailable_reason())
	_add_tracker("new_marker", Vector3(3.0, 0.0, 4.0), false)
	assert_true(_controller.tick(0.5), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 1)
	assert_true(_controller.tick(0.5), _controller.get_unavailable_reason())
	assert_eq(_controller.get_visible_marker_states().size(), 2)

func _add_tracker(tracker_id: StringName, position: Vector3, centers_minimap: bool) -> MinimapTracker:
	var tracked_node: Node3D = Node3D.new()
	tracked_node.position = position
	_root.add_child(tracked_node)
	var tracker: MinimapTracker = MinimapTracker.new()
	tracker.tracker_id = tracker_id
	tracker.display_name = String(tracker_id)
	tracker.centers_minimap = centers_minimap
	tracked_node.add_child(tracker)
	return tracker

func _make_texture() -> Texture2D:
	var image: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
