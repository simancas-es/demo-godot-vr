extends RefCounted

const MinimapMarkerState := preload("res://systems/system-minimap/minimap_marker_state.gd")
const MinimapTracker := preload("res://systems/system-minimap/minimap_tracker.gd")

const DEFAULT_TRACKER_DISCOVERY_INTERVAL_SECONDS: float = 1.0

var tracker_discovery_interval_seconds: float = DEFAULT_TRACKER_DISCOVERY_INTERVAL_SECONDS

var _projection_source: Node = null
var _tracker_root: Node = null
var _trackers: Array[MinimapTracker] = []
var _tracker_discovery_elapsed_seconds: float = 0.0
var _marker_states: Array[MinimapMarkerState] = []
var _center_tracker_id: StringName = &""
var _center_map_position: Vector2 = Vector2.ZERO
var _is_available: bool = false
var _unavailable_reason: String = "not bound"

func bind(projection_source: Node, tracker_root: Node) -> void:
	_projection_source = projection_source
	_tracker_root = tracker_root
	rediscover_trackers()
	_clear_state("not refreshed")

func tick(delta: float) -> bool:
	_tracker_discovery_elapsed_seconds += maxf(delta, 0.0)
	var discovery_interval_seconds: float = maxf(tracker_discovery_interval_seconds, DEFAULT_TRACKER_DISCOVERY_INTERVAL_SECONDS)
	if _tracker_discovery_elapsed_seconds >= discovery_interval_seconds:
		rediscover_trackers()
	return refresh()

func rediscover_trackers() -> void:
	_trackers.clear()
	_tracker_discovery_elapsed_seconds = 0.0
	if _tracker_root == null:
		return
	_collect_trackers(_tracker_root, _trackers)

func refresh() -> bool:
	_clear_state("")
	if _projection_source == null:
		return _set_unavailable("missing minimap projection source")
	if _tracker_root == null:
		return _set_unavailable("missing minimap tracker root")
	if not _projection_source.has_method("is_projection_available"):
		return _set_unavailable("projection source has no availability method")
	if not _projection_source.has_method("world_to_map_position"):
		return _set_unavailable("projection source has no world-to-map method")
	if not bool(_projection_source.call("is_projection_available")):
		return _set_unavailable(_get_projection_unavailable_reason())

	if _trackers.is_empty():
		return _set_unavailable("no minimap trackers")

	for tracker: MinimapTracker in _trackers:
		if tracker == null or not is_instance_valid(tracker):
			continue
		if not tracker.visible_on_minimap:
			continue
		if not tracker.has_valid_tracker_id():
			return _set_unavailable("invalid empty minimap tracker id")
		if not tracker.is_coordinate_available():
			return _set_unavailable("tracker %s has no Node3D coordinate source" % String(tracker.tracker_id))
		var projected_position: Vector2 = _projection_source.call("world_to_map_position", tracker.get_world_position()) as Vector2
		_marker_states.append(MinimapMarkerState.from_tracker(tracker, projected_position))

	if _marker_states.is_empty():
		return _set_unavailable("no visible minimap trackers")

	var center_state: MinimapMarkerState = _select_center_state()
	if center_state == null:
		return _set_unavailable("no minimap center tracker")

	_center_tracker_id = center_state.tracker_id
	_center_map_position = center_state.map_position
	_is_available = true
	_unavailable_reason = ""
	return true

func is_available() -> bool:
	return _is_available

func get_unavailable_reason() -> String:
	return _unavailable_reason

func get_map_texture() -> Texture2D:
	if _projection_source == null:
		return null
	return _projection_source.get("map_texture") as Texture2D

func get_center_tracker_id() -> StringName:
	return _center_tracker_id

func get_center_map_position() -> Vector2:
	return _center_map_position

func get_visible_marker_states() -> Array[MinimapMarkerState]:
	return _marker_states.duplicate()

func _clear_state(reason: String) -> void:
	_marker_states.clear()
	_center_tracker_id = &""
	_center_map_position = Vector2.ZERO
	_is_available = false
	_unavailable_reason = reason

func _set_unavailable(reason: String) -> bool:
	_unavailable_reason = reason
	_is_available = false
	_center_tracker_id = &""
	_center_map_position = Vector2.ZERO
	_marker_states.clear()
	return false

func _collect_trackers(node: Node, trackers: Array[MinimapTracker]) -> void:
	var tracker: MinimapTracker = node as MinimapTracker
	if tracker != null:
		trackers.append(tracker)
	for child: Node in node.get_children():
		_collect_trackers(child, trackers)

func _select_center_state() -> MinimapMarkerState:
	var selected_state: MinimapMarkerState = null
	for state: MinimapMarkerState in _marker_states:
		if not state.centers_minimap:
			continue
		if selected_state == null:
			selected_state = state
			continue
		if state.center_priority > selected_state.center_priority:
			selected_state = state
			continue
		if state.center_priority == selected_state.center_priority and String(state.tracker_id) < String(selected_state.tracker_id):
			selected_state = state
	return selected_state

func _get_projection_unavailable_reason() -> String:
	if _projection_source != null and _projection_source.has_method("get_projection_unavailable_reason"):
		var reason: String = String(_projection_source.call("get_projection_unavailable_reason"))
		if not reason.is_empty():
			return reason
	return "projection source unavailable"
