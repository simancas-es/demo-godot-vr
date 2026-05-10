@tool
extends EditorPlugin

const InventoryObjectInformationScript := preload("res://systems/system-inventory/inventory-backend/inventory_object_information.gd")
const InventoryDatabaseDockScript := preload("res://addons/inventory_database_tool/inventory_database_dock.gd")

const MENU_ITEM_NAME: String = "Inventory: Ensure Item Database Resources"
const SHOW_PANEL_MENU_ITEM_NAME: String = "Inventory: Show Database Panel"
const SETTINGS_PATH: String = "res://systems/system-inventory/inventory_settings.gd"
const GENERATED_ROOT: String = "res://content/inv_objects"
const DEFAULT_ICON_PATH: String = "res://content/inv_objects/default_icon.png"
const DEFAULT_MODEL_PATH: String = "res://content/inv_objects/default_model.tscn"

var _dock: Control = null
var _bottom_panel_button: Button = null

func _enter_tree() -> void:
	add_tool_menu_item(MENU_ITEM_NAME, ensure_inventory_database)
	add_tool_menu_item(SHOW_PANEL_MENU_ITEM_NAME, show_inventory_database_panel)
	_dock = InventoryDatabaseDockScript.new()
	_dock.setup(self)
	_bottom_panel_button = add_control_to_bottom_panel(_dock, "Inventory DB")

func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM_NAME)
	remove_tool_menu_item(SHOW_PANEL_MENU_ITEM_NAME)
	if _dock != null:
		remove_control_from_bottom_panel(_dock)
		_dock.queue_free()
		_dock = null
	_bottom_panel_button = null

func show_inventory_database_panel() -> void:
	if _dock == null:
		return
	make_bottom_panel_item_visible(_dock)

func ensure_inventory_database() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		push_error("Inventory settings file is missing: %s" % SETTINGS_PATH)
		return

	var settings_text: String = FileAccess.get_file_as_string(SETTINGS_PATH)
	var entries: Array = _parse_inventory_id_entries(settings_text)
	var resource_map: Dictionary = _parse_information_resources(settings_text)
	var updated_settings_text: String = settings_text
	var changed_settings: bool = false
	var generated_count: int = 0
	var repaired_count: int = 0

	for entry in entries:
		var item_name: String = entry["name"]
		var item_id: int = entry["value"]
		if item_name == "INVALID":
			continue

		var resource_path: String = ""
		if resource_map.has(item_name):
			resource_path = resource_map[item_name]
		else:
			resource_path = _get_default_resource_path(item_name)
			updated_settings_text = _ensure_information_resource_registration(updated_settings_text, item_name, resource_path)
			resource_map[item_name] = resource_path
			changed_settings = true

		var result: Dictionary = _ensure_item_resource(item_name, item_id, resource_path)
		if result.get("generated", false):
			generated_count += 1
		if result.get("repaired", false):
			repaired_count += 1

	if changed_settings:
		_write_text(SETTINGS_PATH, updated_settings_text)

	EditorInterface.get_resource_filesystem().scan()
	print("Inventory database check complete. Generated: %s, repaired: %s, settings updated: %s." % [generated_count, repaired_count, changed_settings])
	if _dock != null and _dock.has_method("refresh"):
		_dock.call("refresh")

func get_inventory_database_entries() -> Array:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return []
	var settings_text: String = FileAccess.get_file_as_string(SETTINGS_PATH)
	var entries: Array = _parse_inventory_id_entries(settings_text)
	var resource_map: Dictionary = _parse_information_resources(settings_text)
	var result: Array = []

	for entry in entries:
		var item_name: String = entry["name"]
		if item_name == "INVALID":
			continue
		var registered_path: String = ""
		if resource_map.has(item_name):
			registered_path = resource_map[item_name]
		var resource_path: String = registered_path
		var exists: bool = false
		if not registered_path.is_empty() and ResourceLoader.exists(registered_path):
			exists = true
			var resource: Resource = load(registered_path)
			if resource != null and not resource.resource_path.is_empty():
				resource_path = resource.resource_path
		result.append({
			"name": item_name,
			"value": entry["value"],
			"registered_path": registered_path,
			"resource_path": resource_path,
			"exists": exists
		})

	return result

func _parse_inventory_id_entries(settings_text: String) -> Array:
	var entries: Array = []
	var lines: PackedStringArray = settings_text.split("\n")
	var in_id_enum: bool = false
	var current_value: int = -1

	for raw_line in lines:
		var line: String = _strip_inline_comment(raw_line).strip_edges()
		if not in_id_enum:
			if line.begins_with("enum ID"):
				in_id_enum = true
			continue

		if line.contains("}"):
			break

		line = line.trim_suffix(",").strip_edges()
		if line.is_empty():
			continue

		var item_name: String = ""
		var item_value: int = 0
		if line.contains("="):
			var parts: PackedStringArray = line.split("=", true, 1)
			item_name = parts[0].strip_edges()
			item_value = parts[1].strip_edges().to_int()
			current_value = item_value
		else:
			current_value += 1
			item_name = line
			item_value = current_value

		if not item_name.is_empty():
			entries.append({"name": item_name, "value": item_value})

	return entries

#HACK
func _parse_information_resources(settings_text: String) -> Dictionary:
	var resource_map: Dictionary = {}
	var lines: PackedStringArray = settings_text.split("\n")
	var in_resources: bool = false
	var brace_depth: int = 0

	for raw_line in lines:
		var line: String = _strip_inline_comment(raw_line).strip_edges()
		if not in_resources:
			if line.contains("const INFORMATION_RESOURCES"):
				in_resources = true
			else:
				continue

		brace_depth += line.count("{")
		brace_depth -= line.count("}")
		if brace_depth <= 0 and line.contains("}"):
			break

		if not line.contains("ID.") or not line.contains(":"):
			continue

		var colon_idx: int = line.find(":")
		var left_side: String = line.substr(0, colon_idx).strip_edges()
		var enum_idx: int = left_side.find("ID.")
		if enum_idx < 0:
			continue

		var item_name: String = left_side.substr(enum_idx + 3).strip_edges()
		var item_path: String = _extract_first_quoted_string(line.substr(colon_idx + 1))
		if not item_name.is_empty() and not item_path.is_empty():
			resource_map[item_name] = item_path

	return resource_map

func _ensure_item_resource(item_name: String, item_id: int, registered_path: String) -> Dictionary:
	var resource_path: String = registered_path
	var generated: bool = false
	var repaired: bool = false
	var resource: Resource = null

	if ResourceLoader.exists(resource_path):
		resource = load(resource_path)
		if resource != null and not resource.resource_path.is_empty():
			resource_path = resource.resource_path
	elif resource_path.begins_with("res://"):
		resource = _create_item_resource(item_name, item_id, resource_path)
		generated = true
	else:
		push_warning("Inventory item %s points to missing non-file resource %s. Register a res:// path or repair the UID target." % [item_name, registered_path])
		return {"generated": false, "repaired": false}

	if resource == null:
		push_error("Unable to load or create inventory resource for %s at %s." % [item_name, resource_path])
		return {"generated": generated, "repaired": repaired}

	if _repair_resource_properties(resource, item_name, item_id, resource_path):
		repaired = true

	if generated or repaired:
		var save_error: int = ResourceSaver.save(resource, resource_path)
		if save_error != OK:
			push_error("Could not save inventory resource %s. Error: %s" % [resource_path, save_error])

	return {"generated": generated, "repaired": repaired}


func _create_item_resource(item_name: String, item_id: int, resource_path: String) -> Resource:
	_ensure_parent_dir(resource_path)
	var resource: Resource = InventoryObjectInformationScript.new()
	resource.set("ID", item_id)
	resource.set("CLASS", INVENTORYSETTINGS.CLASS.DEFAULT)
	resource.set("STACK_MAX", 1)
	resource.set("SEPARABLE", false)
	resource.set("DISAPPEARS_AT_0", true)
	resource.set("qty_string", 0)
	var json_path: String = _get_translation_path_for_resource(resource_path)
	_ensure_translation_file(item_name, json_path)
	resource.set("inspect_translations_path", json_path)
	_assign_default_assets(resource)
	return resource

#HACK
func _repair_resource_properties(resource: Resource, item_name: String, item_id: int, resource_path: String) -> bool:
	var changed: bool = false

	if resource.get("ID") != item_id:
		resource.set("ID", item_id)
		changed = true

	var translation_path: String = str(resource.get("inspect_translations_path"))
	if translation_path.is_empty() or not FileAccess.file_exists(translation_path):
		translation_path = _get_translation_path_for_resource(resource_path)
		if _ensure_translation_file(item_name, translation_path):
			changed = true
		resource.set("inspect_translations_path", translation_path)
		changed = true

	if resource.get("texture") == null and ResourceLoader.exists(DEFAULT_ICON_PATH):
		resource.set("texture", load(DEFAULT_ICON_PATH))
		changed = true

	if resource.get("world_model") == null and ResourceLoader.exists(DEFAULT_MODEL_PATH):
		resource.set("world_model", load(DEFAULT_MODEL_PATH))
		changed = true

	if resource.get("inspect_model") == null and ResourceLoader.exists(DEFAULT_MODEL_PATH):
		resource.set("inspect_model", load(DEFAULT_MODEL_PATH))
		changed = true

	return changed

func _assign_default_assets(resource: Resource) -> void:
	if ResourceLoader.exists(DEFAULT_ICON_PATH):
		resource.set("texture", load(DEFAULT_ICON_PATH))
	if ResourceLoader.exists(DEFAULT_MODEL_PATH):
		resource.set("world_model", load(DEFAULT_MODEL_PATH))
		resource.set("inspect_model", load(DEFAULT_MODEL_PATH))

func _ensure_translation_file(item_name: String, json_path: String) -> bool:
	if FileAccess.file_exists(json_path):
		return false

	_ensure_parent_dir(json_path)
	var display_name: String = _to_title_name(item_name)
	var json_text: String = _build_translation_json(display_name)
	_write_text(json_path, json_text)
	return true

#HACK
func _build_translation_json(display_name: String) -> String:
	var lines: Array[String] = [
		"{",
		"\t\"en\": {",
		"\t\t\"name\": \"%s\"," % display_name,
		"\t\t\"description\": \"TODO: Describe %s.\"" % display_name,
		"\t},",
		"\t\"de\": {",
		"\t\t\"name\": \"%s\"," % display_name,
		"\t\t\"description\": \"TODO: Describe %s.\"" % display_name,
		"\t},",
		"\t\"es\": {",
		"\t\t\"name\": \"%s\"," % display_name,
		"\t\t\"description\": \"TODO: Describe %s.\"" % display_name,
		"\t},",
		"\t\"fr\": {",
		"\t\t\"name\": \"%s\"," % display_name,
		"\t\t\"description\": \"TODO: Describe %s.\"" % display_name,
		"\t}",
		"}",
		""
	]
	return _join_lines(lines)

func _ensure_information_resource_registration(settings_text: String, item_name: String, resource_path: String) -> String:
	if settings_text.contains("ID.%s" % item_name):
		return settings_text

	var lines: Array = Array(settings_text.split("\n"))
	var in_resources: bool = false
	var brace_depth: int = 0
	var closing_idx: int = -1

	for i in range(lines.size()):
		var line: String = str(lines[i])
		if not in_resources:
			if line.contains("const INFORMATION_RESOURCES"):
				in_resources = true
			else:
				continue

		brace_depth += line.count("{")
		brace_depth -= line.count("}")
		if brace_depth == 0 and line.strip_edges().begins_with("}"):
			closing_idx = i
			break

	if closing_idx < 0:
		push_error("Could not find INFORMATION_RESOURCES closing brace.")
		return settings_text

	var previous_idx: int = closing_idx - 1
	while previous_idx >= 0 and str(lines[previous_idx]).strip_edges().is_empty():
		previous_idx -= 1

	if previous_idx >= 0:
		var previous_line: String = str(lines[previous_idx]).rstrip(" \t")
		if not previous_line.ends_with(",") and previous_line.contains("ID."):
			lines[previous_idx] = previous_line + ","

	lines.insert(closing_idx, "\tID.%s : \"%s\"," % [item_name, resource_path])
	return _join_lines(lines)

func _get_default_resource_path(item_name: String) -> String:
	var snake_name: String = item_name.to_lower()
	return "%s/%s/%s.tres" % [GENERATED_ROOT, snake_name, snake_name]

func _get_translation_path_for_resource(resource_path: String) -> String:
	return "%s/%s.json" % [resource_path.get_base_dir(), resource_path.get_file().get_basename()]

func _ensure_parent_dir(path: String) -> void:
	var dir_path: String = path.get_base_dir()
	var absolute_dir: String = ProjectSettings.globalize_path(dir_path)
	var error: int = DirAccess.make_dir_recursive_absolute(absolute_dir)
	if error != OK:
		push_error("Could not create directory %s. Error: %s" % [dir_path, error])

func _write_text(path: String, text: String) -> void:
	_ensure_parent_dir(path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write file: %s" % path)
		return
	file.store_string(text)
	file.close()

func _strip_inline_comment(line: String) -> String:
	var comment_idx: int = line.find("#")
	if comment_idx < 0:
		return line
	return line.substr(0, comment_idx)

func _extract_first_quoted_string(text: String) -> String:
	var first_quote: int = text.find("\"")
	if first_quote < 0:
		return ""
	var second_quote: int = text.find("\"", first_quote + 1)
	if second_quote < 0:
		return ""
	return text.substr(first_quote + 1, second_quote - first_quote - 1)

func _to_title_name(item_name: String) -> String:
	var parts: PackedStringArray = item_name.to_lower().split("_")
	var words: Array[String] = []
	for part in parts:
		if part.is_empty():
			continue
		words.append(part.substr(0, 1).to_upper() + part.substr(1))
	return " ".join(words)

func _join_lines(lines: Array) -> String:
	var text: String = ""
	for i in range(lines.size()):
		if i > 0:
			text += "\n"
		text += str(lines[i])
	return text
