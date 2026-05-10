@tool
extends VBoxContainer

const LOCALES: Array[String] = ["en", "de", "es", "fr"]
const BROWSE_ICON: String = "icon"
const BROWSE_WORLD_MODEL: String = "world_model"
const BROWSE_INSPECT_MODEL: String = "inspect_model"

var _tool: Object = null
var _entries: Array = []
var _selected_entry: Dictionary = {}
var _resource: Resource = null
var _resource_path: String = ""
var _translations_path: String = ""

var _item_list: ItemList = null
var _status_label: Label = null
var _path_label: Label = null
var _icon_path: LineEdit = null
var _world_model_path: LineEdit = null
var _inspect_model_path: LineEdit = null
var _hint_text: LineEdit = null
var _stack_max: SpinBox = null
var _class_option: OptionButton = null
var _qty_option: OptionButton = null
var _separable: CheckBox = null
var _disappears_at_zero: CheckBox = null
var _translation_fields: Dictionary = {}
var _preview_pivot: Node3D = null
var _preview_camera: Camera3D = null
var _save_button: Button = null
var _icon_preview: TextureRect = null
var _icon_preview_label: Label = null
var _preview_title: Label = null
var _preview_model_label: Label = null
var _preview_zoom: float = 1.0
var _preview_model_size: float = 1.0
var _is_dirty: bool = false
var _browse_dialog: FileDialog = null
var _browse_target: LineEdit = null
var _browse_kind: String = ""

func setup(tool: Object) -> void:
	_tool = tool
	name = "Inventory DB"
	_build_ui()
	refresh()

func refresh() -> void:
	if _tool == null:
		return
	_entries = _tool.call("get_inventory_database_entries")
	_item_list.clear()
	for entry in _entries:
		var item_name: String = entry["name"]
		var status_text: String = "ok" if entry["exists"] else "missing"
		_item_list.add_item("%s  [%s]" % [item_name, status_text])

func _build_ui() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var toolbar: HBoxContainer = HBoxContainer.new()
	add_child(toolbar)

	var refresh_button: Button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(refresh)
	toolbar.add_child(refresh_button)

	var ensure_button: Button = Button.new()
	ensure_button.text = "Ensure Missing"
	ensure_button.pressed.connect(_on_ensure_missing_pressed)
	toolbar.add_child(ensure_button)

	_save_button = Button.new()
	_save_button.text = "Save"
	_save_button.disabled = true
	_save_button.pressed.connect(_on_save_pressed)
	toolbar.add_child(_save_button)

	_build_browse_dialog()

	_status_label = Label.new()
	_status_label.text = "Select an item."
	add_child(_status_label)

	var split: HSplitContainer = HSplitContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(split)

	_item_list = ItemList.new()
	_item_list.custom_minimum_size = Vector2(220, 320)
	_item_list.item_selected.connect(_on_item_selected)
	split.add_child(_item_list)

	var right_split: HSplitContainer = HSplitContainer.new()
	right_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(right_split)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(560, 320)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_split.add_child(scroll)

	var attributes: GridContainer = GridContainer.new()
	attributes.columns = 2
	attributes.custom_minimum_size = Vector2(540, 0)
	attributes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(attributes)

	_path_label = Label.new()
	_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_add_labeled_control(attributes, "Resource", _path_label)

	_icon_path = _add_browsable_path_line_edit(attributes, "Icon Texture", BROWSE_ICON)
	_world_model_path = _add_browsable_path_line_edit(attributes, "World 3D Model", BROWSE_WORLD_MODEL)
	_inspect_model_path = _add_browsable_path_line_edit(attributes, "Inventory 3D Model", BROWSE_INSPECT_MODEL)
	_hint_text = _add_labeled_line_edit(attributes, "Hint")

	_stack_max = SpinBox.new()
	_stack_max.min_value = 1
	_stack_max.max_value = 999
	_stack_max.step = 1
	_add_labeled_control(attributes, "Stack Max", _stack_max)

	_class_option = OptionButton.new()
	_class_option.add_item("DEFAULT", 0)
	_class_option.add_item("KEY", 1)
	_add_labeled_control(attributes, "Class", _class_option)

	_qty_option = OptionButton.new()
	_qty_option.add_item("NUMBER", 0)
	_qty_option.add_item("NOTHING", 1)
	_qty_option.add_item("DASH", 2)
	_add_labeled_control(attributes, "Quantity Text", _qty_option)

	_separable = CheckBox.new()
	_add_labeled_control(attributes, "Separable", _separable)

	_disappears_at_zero = CheckBox.new()
	_add_labeled_control(attributes, "Disappears At 0", _disappears_at_zero)

	var translations_title: Label = Label.new()
	translations_title.text = "Translations"
	_add_section_label(attributes, translations_title)

	for locale in LOCALES:
		var name_field: LineEdit = _add_labeled_line_edit(attributes, "%s Name" % locale)
		var desc_field: LineEdit = _add_labeled_line_edit(attributes, "%s Description" % locale)
		_translation_fields[locale] = {"name": name_field, "description": desc_field}

	_connect_dirty_signals()
	_build_preview(right_split)

func _build_preview(parent: Control) -> void:
	var preview_panel: VBoxContainer = VBoxContainer.new()
	preview_panel.custom_minimum_size = Vector2(320, 320)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(preview_panel)

	var icon_title: Label = Label.new()
	icon_title.text = "Icon"
	preview_panel.add_child(icon_title)

	_icon_preview = TextureRect.new()
	_icon_preview.custom_minimum_size = Vector2(96, 96)
	_icon_preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_panel.add_child(_icon_preview)

	_icon_preview_label = Label.new()
	_icon_preview_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_panel.add_child(_icon_preview_label)

	_preview_title = Label.new()
	_preview_title.text = "3D Preview"
	preview_panel.add_child(_preview_title)

	_preview_model_label = Label.new()
	_preview_model_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_panel.add_child(_preview_model_label)

	var model_buttons: HBoxContainer = HBoxContainer.new()
	preview_panel.add_child(model_buttons)

	var show_world: Button = Button.new()
	show_world.text = "World"
	show_world.pressed.connect(_show_world_model)
	model_buttons.add_child(show_world)

	var show_inventory: Button = Button.new()
	show_inventory.text = "Inventory"
	show_inventory.pressed.connect(_show_inventory_model)
	model_buttons.add_child(show_inventory)

	var rotate_buttons: HBoxContainer = HBoxContainer.new()
	preview_panel.add_child(rotate_buttons)
	_add_rotation_button(rotate_buttons, "Left", Vector3.UP, deg_to_rad(15.0))
	_add_rotation_button(rotate_buttons, "Right", Vector3.UP, deg_to_rad(-15.0))
	_add_rotation_button(rotate_buttons, "Up", Vector3.RIGHT, deg_to_rad(15.0))
	_add_rotation_button(rotate_buttons, "Down", Vector3.RIGHT, deg_to_rad(-15.0))

	var zoom_in_button: Button = Button.new()
	zoom_in_button.text = "Zoom +"
	zoom_in_button.pressed.connect(_zoom_preview.bind(0.8))
	rotate_buttons.add_child(zoom_in_button)

	var zoom_out_button: Button = Button.new()
	zoom_out_button.text = "Zoom -"
	zoom_out_button.pressed.connect(_zoom_preview.bind(1.25))
	rotate_buttons.add_child(zoom_out_button)

	var reset_button: Button = Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(_reset_preview_rotation)
	rotate_buttons.add_child(reset_button)

	var viewport_container: SubViewportContainer = SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(320, 240)
	viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	viewport_container.stretch = true
	preview_panel.add_child(viewport_container)

	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(320, 240)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(viewport)

	_preview_pivot = Node3D.new()
	viewport.add_child(_preview_pivot)

	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation = Vector3(deg_to_rad(-45.0), deg_to_rad(-45.0), 0.0)
	viewport.add_child(light)

	_preview_camera = Camera3D.new()
	_preview_camera.position = Vector3(0.0, 1.0, 4.0)
	_preview_camera.look_at(Vector3.ZERO, Vector3.UP)
	_preview_camera.current = true
	viewport.add_child(_preview_camera)

func _build_browse_dialog() -> void:
	_browse_dialog = FileDialog.new()
	_browse_dialog.mode = Window.MODE_WINDOWED
	_browse_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_browse_dialog.access = FileDialog.ACCESS_RESOURCES
	_browse_dialog.min_size = Vector2(720, 480)
	_browse_dialog.set_size(Vector2(720, 480))
	_browse_dialog.file_selected.connect(_on_browse_file_selected)
	add_child(_browse_dialog)

func _add_labeled_line_edit(parent: GridContainer, label_text: String) -> LineEdit:
	var line_edit: LineEdit = LineEdit.new()
	_add_labeled_control(parent, label_text, line_edit)
	return line_edit

func _add_browsable_path_line_edit(parent: GridContainer, label_text: String, browse_kind: String) -> LineEdit:
	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var line_edit: LineEdit = LineEdit.new()
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(line_edit)

	var browse_button: Button = Button.new()
	browse_button.text = "Browse"
	browse_button.pressed.connect(_open_browse_dialog.bind(line_edit, browse_kind))
	row.add_child(browse_button)

	_add_labeled_control(parent, label_text, row)
	return line_edit

func _add_labeled_control(parent: GridContainer, label_text: String, control: Control) -> void:
	var label: Label = Label.new()
	label.text = label_text
	parent.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(control)

func _add_section_label(parent: GridContainer, label: Label) -> void:
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(spacer)

func _connect_dirty_signals() -> void:
	var line_edits: Array[LineEdit] = [_icon_path, _world_model_path, _inspect_model_path, _hint_text]
	for locale in LOCALES:
		var fields: Dictionary = _translation_fields[locale]
		var name_field: LineEdit = fields["name"]
		var desc_field: LineEdit = fields["description"]
		line_edits.append(name_field)
		line_edits.append(desc_field)
	for line_edit in line_edits:
		line_edit.text_changed.connect(_on_text_changed)
		line_edit.text_submitted.connect(_on_text_submitted)
	_icon_path.text_changed.connect(_on_icon_path_changed)
	_world_model_path.text_changed.connect(_on_model_path_changed)
	_inspect_model_path.text_changed.connect(_on_model_path_changed)
	_stack_max.value_changed.connect(_on_value_changed)
	_class_option.item_selected.connect(_on_option_selected)
	_qty_option.item_selected.connect(_on_option_selected)
	_separable.toggled.connect(_on_toggle_changed)
	_disappears_at_zero.toggled.connect(_on_toggle_changed)

func _add_rotation_button(parent: HBoxContainer, label_text: String, axis: Vector3, radians: float) -> void:
	var button: Button = Button.new()
	button.text = label_text
	button.pressed.connect(_rotate_preview.bind(axis, radians))
	parent.add_child(button)

func _on_ensure_missing_pressed() -> void:
	if _tool != null:
		_tool.call("ensure_inventory_database")
		refresh()

func _open_browse_dialog(target: LineEdit, browse_kind: String) -> void:
	_browse_target = target
	_browse_kind = browse_kind
	if _browse_dialog == null:
		return
	if browse_kind == BROWSE_ICON:
		_browse_dialog.title = "Select inventory icon"
		_browse_dialog.filters = PackedStringArray([
			"*.png, *.jpg, *.jpeg, *.webp, *.svg, *.tga, *.bmp, *.tres, *.res ; Texture resources"
		])
	else:
		_browse_dialog.title = "Select inventory 3D model"
		_browse_dialog.filters = PackedStringArray([
			"*.tscn, *.scn, *.glb, *.gltf, *.blend, *.fbx, *.tres, *.res ; 3D model resources"
		])
	var current_path: String = target.text.strip_edges()
	if current_path.is_empty():
		_browse_dialog.current_dir = "res://"
	else:
		_browse_dialog.current_path = current_path
		_browse_dialog.current_dir = current_path.get_base_dir()
	_browse_dialog.popup_centered_ratio()

func _on_browse_file_selected(path: String) -> void:
	if _browse_target == null:
		return
	_browse_target.text = path
	_mark_dirty()
	if _browse_kind == BROWSE_ICON:
		_refresh_icon_preview()
	elif _browse_kind == BROWSE_WORLD_MODEL:
		_show_world_model()
	elif _browse_kind == BROWSE_INSPECT_MODEL:
		_show_inventory_model()
	_browse_target = null
	_browse_kind = ""

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= _entries.size():
		return
	_selected_entry = _entries[index]
	_load_selected_resource()

func _load_selected_resource() -> void:
	_resource = null
	_resource_path = str(_selected_entry.get("resource_path", ""))
	if _resource_path.is_empty() or not ResourceLoader.exists(_resource_path):
		_status_label.text = "Missing resource for %s. Run Ensure Missing." % _selected_entry.get("name", "")
		_clear_fields()
		return

	_resource = load(_resource_path)
	if _resource == null:
		_status_label.text = "Could not load %s." % _resource_path
		_clear_fields()
		return

	_status_label.text = "Editing %s" % _selected_entry.get("name", "")
	_path_label.text = _resource_path
	_load_resource_fields()
	_load_translation_fields()
	_set_dirty(false)
	_show_inventory_model()

func _load_resource_fields() -> void:
	_icon_path.text = _get_resource_property_path("texture")
	_world_model_path.text = _get_resource_property_path("world_model")
	_inspect_model_path.text = _get_resource_property_path("inspect_model")
	_hint_text.text = str(_resource.get("hint_text"))
	_stack_max.value = int(_resource.get("STACK_MAX"))
	_class_option.select(int(_resource.get("CLASS")))
	_qty_option.select(int(_resource.get("qty_string")))
	_separable.button_pressed = bool(_resource.get("SEPARABLE"))
	_disappears_at_zero.button_pressed = bool(_resource.get("DISAPPEARS_AT_0"))
	_translations_path = str(_resource.get("inspect_translations_path"))
	_refresh_icon_preview()

func _load_translation_fields() -> void:
	var translations: Dictionary = _read_translations(_translations_path)
	for locale in LOCALES:
		var locale_data: Dictionary = {}
		if translations.has(locale) and translations[locale] is Dictionary:
			locale_data = translations[locale]
		var fields: Dictionary = _translation_fields[locale]
		var name_field: LineEdit = fields["name"]
		var desc_field: LineEdit = fields["description"]
		name_field.text = str(locale_data.get("name", ""))
		desc_field.text = str(locale_data.get("description", ""))

func _clear_fields() -> void:
	_path_label.text = ""
	_icon_path.text = ""
	_world_model_path.text = ""
	_inspect_model_path.text = ""
	_hint_text.text = ""
	for locale in LOCALES:
		var fields: Dictionary = _translation_fields[locale]
		var name_field: LineEdit = fields["name"]
		var desc_field: LineEdit = fields["description"]
		name_field.text = ""
		desc_field.text = ""
	_clear_preview()
	_set_dirty(false)

func _on_save_pressed() -> void:
	if _resource == null:
		_status_label.text = "No resource selected."
		return

	_resource.set("texture", _load_resource_or_null(_icon_path.text))
	_resource.set("world_model", _load_resource_or_null(_world_model_path.text))
	_resource.set("inspect_model", _load_resource_or_null(_inspect_model_path.text))
	_resource.set("hint_text", _hint_text.text)
	_resource.set("STACK_MAX", int(_stack_max.value))
	_resource.set("CLASS", _class_option.get_selected_id())
	_resource.set("qty_string", _qty_option.get_selected_id())
	_resource.set("SEPARABLE", _separable.button_pressed)
	_resource.set("DISAPPEARS_AT_0", _disappears_at_zero.button_pressed)

	if _translations_path.is_empty():
		_translations_path = "%s/%s.json" % [_resource_path.get_base_dir(), _resource_path.get_file().get_basename()]
		_resource.set("inspect_translations_path", _translations_path)

	_write_translations(_translations_path)
	var save_error: int = ResourceSaver.save(_resource, _resource_path)
	if save_error != OK:
		_status_label.text = "Save failed: %s" % save_error
		return

	EditorInterface.get_resource_filesystem().scan()
	_status_label.text = "Saved %s." % _selected_entry.get("name", "")
	_set_dirty(false)
	refresh()

func _get_resource_property_path(property_name: String) -> String:
	var value: Variant = _resource.get(property_name)
	if value is Resource:
		var resource: Resource = value
		return resource.resource_path
	return ""

func _load_resource_or_null(path: String) -> Resource:
	var trimmed_path: String = path.strip_edges()
	if trimmed_path.is_empty():
		return null
	if not ResourceLoader.exists(trimmed_path):
		push_warning("Missing resource path: %s" % trimmed_path)
		return null
	return load(trimmed_path)

func _read_translations(path: String) -> Dictionary:
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var file_text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(file_text)
	if parsed is Dictionary:
		return parsed
	return {}

func _write_translations(path: String) -> void:
	var translations: Dictionary = {}
	for locale in LOCALES:
		var fields: Dictionary = _translation_fields[locale]
		var name_field: LineEdit = fields["name"]
		var desc_field: LineEdit = fields["description"]
		translations[locale] = {
			"name": name_field.text,
			"description": desc_field.text
		}
	var json_text: String = JSON.stringify(translations, "\t")
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_status_label.text = "Could not write translations: %s" % path
		return
	file.store_string(json_text)
	file.close()

func _show_world_model() -> void:
	if _preview_title != null:
		_preview_title.text = "World 3D Model"
	_show_preview_model(_world_model_path.text)

func _show_inventory_model() -> void:
	if _preview_title != null:
		_preview_title.text = "Inventory 3D Model"
	_show_preview_model(_inspect_model_path.text)

func _show_preview_model(path: String) -> void:
	_clear_preview()
	if _preview_model_label != null:
		_preview_model_label.text = path
	var packed_scene: Resource = _load_resource_or_null(path)
	if not (packed_scene is PackedScene):
		return
	var scene: PackedScene = packed_scene
	var model: Node = scene.instantiate()
	if model is Node3D:
		_preview_pivot.add_child(model)
		_center_preview_model(model)
		return

	var wrapper: Node3D = Node3D.new()
	_preview_pivot.add_child(wrapper)
	wrapper.add_child(model)
	_center_preview_model(wrapper)

func _clear_preview() -> void:
	if _preview_pivot == null:
		return
	for child in _preview_pivot.get_children():
		_preview_pivot.remove_child(child)
		child.queue_free()

func _center_preview_model(model: Node3D) -> void:
	var aabb: AABB = _get_node_aabb(model)
	model.position = -aabb.get_center()
	_preview_model_size = max(0.5, sqrt(aabb.size.length_squared()))
	_preview_zoom = 1.0
	_apply_preview_zoom()

func _apply_preview_zoom() -> void:
	var distance: float = _preview_model_size * 1.8 * _preview_zoom
	_preview_camera.position = Vector3(0.0, _preview_model_size * 0.4 * _preview_zoom, distance)
	_preview_camera.look_at(Vector3.ZERO, Vector3.UP)

func _get_node_aabb(node: Node3D) -> AABB:
	var merged: AABB = AABB(Vector3(-0.25, -0.25, -0.25), Vector3(0.5, 0.5, 0.5))
	var found: bool = false
	var stack: Array[Node] = [node]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current is VisualInstance3D:
			var visual: VisualInstance3D = current
			var box: AABB = visual.get_aabb()
			var local_transform: Transform3D = node.global_transform.affine_inverse() * visual.global_transform
			box = local_transform * box
			if found:
				merged = merged.merge(box)
			else:
				merged = box
				found = true
		for child in current.get_children():
			stack.append(child)
	return merged

func _rotate_preview(axis: Vector3, radians: float) -> void:
	if _preview_pivot == null:
		return
	_preview_pivot.rotate(axis, radians)

func _reset_preview_rotation() -> void:
	if _preview_pivot != null:
		_preview_pivot.rotation = Vector3.ZERO

func _zoom_preview(factor: float) -> void:
	_preview_zoom = clampf(_preview_zoom * factor, 0.2, 5.0)
	_apply_preview_zoom()

func _on_text_changed(_new_text: String) -> void:
	_mark_dirty()

func _on_text_submitted(_new_text: String) -> void:
	_save_if_dirty()

func _on_icon_path_changed(_new_text: String) -> void:
	_refresh_icon_preview()

func _on_model_path_changed(_new_text: String) -> void:
	_refresh_preview_from_current_mode()

func _on_value_changed(_new_value: float) -> void:
	_mark_dirty()

func _on_option_selected(_index: int) -> void:
	_mark_dirty()

func _on_toggle_changed(_enabled: bool) -> void:
	_mark_dirty()

func _refresh_icon_preview() -> void:
	if _icon_preview == null:
		return
	var texture: Resource = _load_resource_or_null(_icon_path.text)
	if texture is Texture2D:
		_icon_preview.texture = texture
	else:
		_icon_preview.texture = null
	if _icon_preview_label != null:
		_icon_preview_label.text = _icon_path.text

func _refresh_preview_from_current_mode() -> void:
	if _preview_title == null:
		return
	if _preview_title.text == "World 3D Model":
		_show_world_model()
	else:
		_show_inventory_model()

func _mark_dirty() -> void:
	_set_dirty(true)

func _set_dirty(is_dirty: bool) -> void:
	_is_dirty = is_dirty
	if _save_button != null:
		_save_button.disabled = not is_dirty
		if is_dirty:
			_save_button.text = "Save *"
		else:
			_save_button.text = "Save"

func _save_if_dirty() -> void:
	if _is_dirty:
		_on_save_pressed()
