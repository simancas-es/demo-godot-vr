@tool
extends EditorPlugin

const ZoneMinimapEditorDock := preload("res://addons/zone_minimap_editor/zone_minimap_editor_dock.gd")

const SHOW_DOCK_MENU_ITEM_NAME: String = "Minimap: Show Calibration Dock"
const ZONE_MINIMAP_SCRIPT_PATH: String = "res://clases/zones/zone_minimap.gd"

var _dock: Control = null

func _enter_tree() -> void:
	add_tool_menu_item(SHOW_DOCK_MENU_ITEM_NAME, show_minimap_calibration_dock)
	_dock = ZoneMinimapEditorDock.new()
	_dock.setup(self)
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock)
	var selection: EditorSelection = get_editor_interface().get_selection()
	if not selection.selection_changed.is_connected(_on_selection_changed):
		selection.selection_changed.connect(_on_selection_changed)
	_on_selection_changed()

func _exit_tree() -> void:
	remove_tool_menu_item(SHOW_DOCK_MENU_ITEM_NAME)
	var selection: EditorSelection = get_editor_interface().get_selection()
	if selection.selection_changed.is_connected(_on_selection_changed):
		selection.selection_changed.disconnect(_on_selection_changed)
	if _dock != null:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null

func show_minimap_calibration_dock() -> void:
	if _dock == null:
		return
	_dock.show()
	_on_selection_changed()

func get_selected_zone_minimap() -> Node:
	var selection: EditorSelection = get_editor_interface().get_selection()
	for node in selection.get_selected_nodes():
		if _is_zone_minimap_node(node):
			return node
		var exported_minimap: Node = _get_exported_zone_minimap(node)
		if exported_minimap != null:
			return exported_minimap
		var child_minimap: Node = node.get_node_or_null("ZoneMinimap")
		if child_minimap != null and _is_zone_minimap_node(child_minimap):
			return child_minimap
	return null

func _get_exported_zone_minimap(node: Node) -> Node:
	var property_value: Variant = node.get("zone_minimap")
	if not property_value is NodePath:
		return null
	var minimap_path: NodePath = property_value
	if minimap_path.is_empty():
		return null
	var minimap: Node = node.get_node_or_null(minimap_path)
	if minimap == null or not _is_zone_minimap_node(minimap):
		return null
	return minimap

func _is_zone_minimap_node(node: Node) -> bool:
	if node == null:
		return false
	var script: Script = node.get_script() as Script
	if script != null and script.resource_path == ZONE_MINIMAP_SCRIPT_PATH:
		return true
	return _has_property(node, "map_texture") and _has_property(node, "world_anchor_a") and _has_property(node, "map_anchor_a_pixels")

func _has_property(node: Node, property_name: String) -> bool:
	for property in node.get_property_list():
		if property.get("name") == property_name:
			return true
	return false

func apply_map_anchor_pixels(zone_minimap: Node, property_name: String, map_anchor_pixels: Vector2) -> void:
	if zone_minimap == null:
		return
	if property_name != "map_anchor_a_pixels" and property_name != "map_anchor_b_pixels":
		return
	var undo_redo: EditorUndoRedoManager = get_undo_redo()
	undo_redo.create_action("Set Zone Minimap Anchor")
	undo_redo.add_do_property(zone_minimap, property_name, map_anchor_pixels)
	undo_redo.add_undo_property(zone_minimap, property_name, zone_minimap.get(property_name))
	if _dock != null:
		undo_redo.add_do_method(_dock, "refresh")
		undo_redo.add_undo_method(_dock, "refresh")
	undo_redo.commit_action()

func _on_selection_changed() -> void:
	if _dock == null:
		return
	_dock.call("set_minimap", get_selected_zone_minimap())
