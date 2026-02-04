

static func enum_to_string(enum_dict: Dictionary, value: int) -> String:
	for key in enum_dict.keys():
		if enum_dict[key] == value:
			return key
	push_error("Coudlnt turn enum to string? %s at %s" % [enum_dict, value])
	return ""
	
static func string_to_enum(enum_class, value : String) -> int:
	# Convert string enum back to integer value
	if typeof(value) == TYPE_STRING:
		return enum_class[value]
	push_error("Enum class %s is missing the string value %s. Or value is an int." % [enum_class, value])
	var int_value = value as int
	return int_value #TODO Handling this error


static func string_to_vector3(s: String) -> Vector3:
	# Remove parentheses and whitespace
	s = s.strip_edges()
	s = s.lstrip("(").rstrip(")")
	
	# Split by commas
	var parts = s.split(",")
	if parts.size() != 3:
		push_error("Invalid Vector3 string: %s" % s)
		return Vector3.ZERO
	
	# Convert to floats
	var x = float(parts[0].strip_edges())
	var y = float(parts[1].strip_edges())
	var z = float(parts[2].strip_edges())
	
	return Vector3(x, y, z)


static func make_json_safe(value):
	if value == null:
		return null

	if value is bool or value is int or value is float or value is String:
		return value

	if value is Dictionary:
		var safe_dict := {}
		for k in value.keys():
			safe_dict[k] = make_json_safe(value[k])
		return safe_dict

	if value is Array:
		var safe_array := []
		for v in value:
			safe_array.append(make_json_safe(v))
		return safe_array

	# Fallback
	return str(value)
	
static func ensure_directory_for_file(path: String) -> void:
	var dir_path := path.get_base_dir()
	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("Failed to open user://")
		return
	await dir.make_dir_recursive(dir_path)
	
	
