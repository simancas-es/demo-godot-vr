@tool
extends VBoxContainer

const CALIBRATION_INSTRUCTIONS: String = "Manual workflow: select Anchor A or Anchor B, then click the matching point on the displayed map texture. Pixel fields are for exact adjustment after clicking."

var _tool: Object = null
var _minimap: Node = null
var _is_refreshing: bool = false

var _content: VBoxContainer = null
var _instruction_label: Label = null
var _status_label: Label = null
var _active_anchor: OptionButton = null
var _anchor_x: SpinBox = null
var _anchor_y: SpinBox = null
var _scale_label: Label = null
var _preview_placeholder: Label = null
var _texture_preview: TextureRect = null
var _anchor_a_marker: ColorRect = null
var _anchor_b_marker: ColorRect = null
var _anchor_a_label: Label = null
var _anchor_b_label: Label = null

func setup(tool: Object) -> void:
	_tool = tool
	name = "Zone Minimap"
	_build_ui()
	refresh()

func set_minimap(minimap: Node) -> void:
	_minimap = minimap
	refresh()

func refresh() -> void:
	if _is_refreshing:
		return
	_is_refreshing = true
	if _tool != null and _tool.has_method("get_selected_zone_minimap"):
		var selected_minimap: Node = _tool.call("get_selected_zone_minimap") as Node
		_minimap = selected_minimap

	if _minimap == null:
		_status_label.text = "Select a ZoneMinimap node to calibrate."
		_scale_label.text = "Derived scale: none"
		_texture_preview.texture = null
		_texture_preview.custom_minimum_size = Vector2(320, 240)
		_preview_placeholder.text = "No ZoneMinimap selected.\nSelect the ZoneMinimap node in the scene tree."
		_preview_placeholder.visible = true
		_set_anchor_visual_visible(false)
		_anchor_x.editable = false
		_anchor_y.editable = false
		_anchor_x.value = 0.0
		_anchor_y.value = 0.0
		_is_refreshing = false
		return

	_anchor_x.editable = true
	_anchor_y.editable = true
	var active_anchor_pixels: Vector2 = _get_active_anchor_pixels()
	_anchor_x.value = active_anchor_pixels.x
	_anchor_y.value = active_anchor_pixels.y
	var derived_scale: float = _get_derived_map_scale()
	_scale_label.text = "Derived scale: %s" % derived_scale if derived_scale > 0.0 else "Derived scale: unavailable"
	_update_texture_preview()
	_update_status()
	_update_anchor_markers()
	_is_refreshing = false

func _build_ui() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var outer_scroll: ScrollContainer = ScrollContainer.new()
	outer_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(outer_scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_scroll.add_child(_content)

	var toolbar: HBoxContainer = HBoxContainer.new()
	_content.add_child(toolbar)

	var refresh_button: Button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(refresh)
	toolbar.add_child(refresh_button)

	var center_button: Button = Button.new()
	center_button.text = "Center Active Anchor"
	center_button.pressed.connect(_on_center_active_anchor_pressed)
	toolbar.add_child(center_button)

	_instruction_label = Label.new()
	_instruction_label.text = CALIBRATION_INSTRUCTIONS
	_instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instruction_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(_instruction_label)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_child(_status_label)

	_scale_label = Label.new()
	_content.add_child(_scale_label)

	var anchor_row: HBoxContainer = HBoxContainer.new()
	_content.add_child(anchor_row)

	var active_label: Label = Label.new()
	active_label.text = "Active"
	anchor_row.add_child(active_label)

	_active_anchor = OptionButton.new()
	_active_anchor.add_item("Anchor A", 0)
	_active_anchor.add_item("Anchor B", 1)
	_active_anchor.item_selected.connect(_on_active_anchor_selected)
	anchor_row.add_child(_active_anchor)

	var x_label: Label = Label.new()
	x_label.text = "Pixel X"
	anchor_row.add_child(x_label)

	_anchor_x = _make_anchor_spinbox()
	_anchor_x.value_changed.connect(_on_anchor_spinbox_changed)
	anchor_row.add_child(_anchor_x)

	var y_label: Label = Label.new()
	y_label.text = "Pixel Y"
	anchor_row.add_child(y_label)

	_anchor_y = _make_anchor_spinbox()
	_anchor_y.value_changed.connect(_on_anchor_spinbox_changed)
	anchor_row.add_child(_anchor_y)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(360, 320)
	_content.add_child(scroll)

	_texture_preview = TextureRect.new()
	_texture_preview.mouse_filter = Control.MOUSE_FILTER_STOP
	_texture_preview.stretch_mode = TextureRect.STRETCH_SCALE
	_texture_preview.custom_minimum_size = Vector2(320, 240)
	_texture_preview.gui_input.connect(_on_texture_preview_gui_input)
	scroll.add_child(_texture_preview)

	_preview_placeholder = Label.new()
	_preview_placeholder.text = "No texture preview available."
	_preview_placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_preview_placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_placeholder.custom_minimum_size = Vector2(320, 240)
	_preview_placeholder.size = Vector2(320, 240)
	_texture_preview.add_child(_preview_placeholder)

	_anchor_a_marker = _make_anchor_marker(Color(1.0, 0.1, 0.0, 0.85))
	_texture_preview.add_child(_anchor_a_marker)
	_anchor_a_label = _make_anchor_label("A")
	_texture_preview.add_child(_anchor_a_label)

	_anchor_b_marker = _make_anchor_marker(Color(0.0, 0.7, 1.0, 0.85))
	_texture_preview.add_child(_anchor_b_marker)
	_anchor_b_label = _make_anchor_label("B")
	_texture_preview.add_child(_anchor_b_label)

func _make_anchor_spinbox() -> SpinBox:
	var spinbox: SpinBox = SpinBox.new()
	spinbox.min_value = -100000.0
	spinbox.max_value = 100000.0
	spinbox.step = 1.0
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.custom_minimum_size = Vector2(120, 0)
	return spinbox

func _make_anchor_marker(color: Color) -> ColorRect:
	var marker: ColorRect = ColorRect.new()
	marker.color = color
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.size = Vector2(12.0, 12.0)
	marker.visible = false
	return marker

func _make_anchor_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = Vector2(20.0, 20.0)
	label.visible = false
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label

func _update_texture_preview() -> void:
	var map_texture: Texture2D = _get_map_texture()
	if _minimap == null or map_texture == null:
		_texture_preview.texture = null
		_texture_preview.custom_minimum_size = Vector2(320, 240)
		_preview_placeholder.text = "No map texture loaded on selected ZoneMinimap.\nAssign map_texture in the inspector, then press Refresh."
		_preview_placeholder.visible = true
		_set_anchor_visual_visible(false)
		return

	var texture_size: Vector2 = map_texture.get_size()
	_texture_preview.texture = map_texture
	_texture_preview.custom_minimum_size = texture_size
	_texture_preview.size = texture_size
	_preview_placeholder.visible = false

func _update_status() -> void:
	if _minimap == null:
		return
	var reasons: Array[String] = []
	if _get_map_texture() == null:
		reasons.append("missing texture")
	if _get_node_property("world_anchor_a") == null:
		reasons.append("missing world anchor A")
	if _get_node_property("world_anchor_b") == null:
		reasons.append("missing world anchor B")
	if not _is_map_anchor_valid(_get_anchor_pixels("map_anchor_a_pixels")):
		reasons.append("invalid texture-space anchor A")
	if not _is_map_anchor_valid(_get_anchor_pixels("map_anchor_b_pixels")):
		reasons.append("invalid texture-space anchor B")
	if _get_derived_map_scale() <= 0.0:
		reasons.append("invalid derived scale")

	if reasons.is_empty():
		_status_label.text = "Ready: editing %s" % _minimap.name
	else:
		_status_label.text = "Invalid calibration for %s: %s" % [_minimap.name, ", ".join(reasons)]

func _update_anchor_markers() -> void:
	if _minimap == null or _get_map_texture() == null:
		_set_anchor_visual_visible(false)
		return

	var anchor_a_pixels: Vector2 = _get_anchor_pixels("map_anchor_a_pixels")
	var anchor_b_pixels: Vector2 = _get_anchor_pixels("map_anchor_b_pixels")
	_update_anchor_marker(_anchor_a_marker, _anchor_a_label, anchor_a_pixels, _is_map_anchor_valid(anchor_a_pixels))
	_update_anchor_marker(_anchor_b_marker, _anchor_b_label, anchor_b_pixels, _is_map_anchor_valid(anchor_b_pixels))

func _update_anchor_marker(marker: ColorRect, label: Label, anchor_pixels: Vector2, is_valid: bool) -> void:
	marker.visible = is_valid
	label.visible = is_valid
	if not is_valid:
		return
	marker.position = anchor_pixels - (marker.size * 0.5)
	label.position = anchor_pixels + Vector2(8.0, -20.0)

func _set_anchor_visual_visible(is_visible: bool) -> void:
	_anchor_a_marker.visible = is_visible
	_anchor_b_marker.visible = is_visible
	_anchor_a_label.visible = is_visible
	_anchor_b_label.visible = is_visible

func _apply_active_anchor(anchor_pixels: Vector2) -> void:
	if _minimap == null:
		return
	var property_name: String = "map_anchor_a_pixels" if _get_active_anchor_index() == 0 else "map_anchor_b_pixels"
	if _tool != null and _tool.has_method("apply_map_anchor_pixels"):
		_tool.call("apply_map_anchor_pixels", _minimap, property_name, anchor_pixels)
	else:
		_minimap.set(property_name, anchor_pixels)
		refresh()

func _get_active_anchor_index() -> int:
	if _active_anchor == null:
		return 0
	return _active_anchor.selected

func _get_active_anchor_pixels() -> Vector2:
	if _minimap == null:
		return Vector2.ZERO
	if _get_active_anchor_index() == 0:
		return _get_anchor_pixels("map_anchor_a_pixels")
	return _get_anchor_pixels("map_anchor_b_pixels")

func _on_active_anchor_selected(_index: int) -> void:
	refresh()

func _on_anchor_spinbox_changed(_value: float) -> void:
	if _is_refreshing or _minimap == null:
		return
	_apply_active_anchor(Vector2(_anchor_x.value, _anchor_y.value))

func _on_texture_preview_gui_input(event: InputEvent) -> void:
	var mouse_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button == null or not mouse_button.pressed or mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return
	if _minimap == null or _get_map_texture() == null:
		return
	_apply_active_anchor(mouse_button.position.round())

func _on_center_active_anchor_pressed() -> void:
	var map_texture: Texture2D = _get_map_texture()
	if _minimap == null or map_texture == null:
		return
	_apply_active_anchor((map_texture.get_size() * 0.5).round())

func _get_map_texture() -> Texture2D:
	if _minimap == null:
		return null
	return _minimap.get("map_texture") as Texture2D

func _get_node_property(property_name: String) -> Node:
	if _minimap == null:
		return null
	return _minimap.get(property_name) as Node

func _get_anchor_pixels(property_name: String) -> Vector2:
	if _minimap == null:
		return Vector2(INF, INF)
	var property_value: Variant = _minimap.get(property_name)
	if property_value is Vector2:
		return property_value
	return Vector2(INF, INF)

func _is_map_anchor_valid(anchor_pixels: Vector2) -> bool:
	if _minimap != null and _minimap.has_method("is_map_anchor_valid"):
		return _minimap.call("is_map_anchor_valid", anchor_pixels)
	return not is_nan(anchor_pixels.x) and not is_nan(anchor_pixels.y) and not is_inf(anchor_pixels.x) and not is_inf(anchor_pixels.y)

func _get_derived_map_scale() -> float:
	if _minimap == null or not _minimap.has_method("get_derived_map_scale"):
		return 0.0
	return _minimap.call("get_derived_map_scale")
