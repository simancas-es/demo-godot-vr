extends RefCounted

const ThisClass := preload("res://systems/system-minimap/minimap_marker_state.gd")
const MinimapTracker := preload("res://systems/system-minimap/minimap_tracker.gd")

var tracker_id: StringName = &""
var display_name: String = ""
var tags: Array[StringName] = []
var map_position: Vector2 = Vector2.ZERO
var centers_minimap: bool = false
var visible_on_minimap: bool = true
var center_priority: int = 0
var marker_texture: Texture2D = null
var marker_color: Color = Color(0.0, 0.85, 1.0, 1.0)

static func from_tracker(tracker: MinimapTracker, projected_position: Vector2) -> ThisClass:
	var state: ThisClass = ThisClass.new()
	state.tracker_id = tracker.tracker_id
	state.display_name = tracker.display_name
	state.tags = tracker.tags.duplicate()
	state.map_position = projected_position
	state.centers_minimap = tracker.centers_minimap
	state.visible_on_minimap = tracker.visible_on_minimap
	state.center_priority = tracker.center_priority
	state.marker_texture = tracker.marker_texture
	state.marker_color = tracker.marker_color
	return state
