extends Node
#class_name WorldStateRegistry
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils

var states : Dictionary = {} #States will be saved in the form of a dictionary [String, Dictionary]
var meta : Dictionary = {}

const meta_default := {"zone_id": SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.UNKNOWN}

func delete(key : String) -> void:
	states.erase(key)
	

func create_json_v01() -> String:
	var json_ready := {
		"meta": {"version": "v01"},
		"states": {} # will hold the per-object state
	}
	# Merge the metadata dictionary
	for key in meta.keys():
		json_ready["meta"][key] = meta[key]
		
	for worldid in states.keys(): #world_id of subcomponent
		json_ready["states"][worldid] = {}
		for subkey in states[worldid].keys():
			var value = states[worldid][subkey] #Only one level. Might break
			# Convert enum to string if it has the 'name' method
			# Convert enum to string if it has a 'name' method
			match typeof(value):
				TYPE_OBJECT:
					if value.has_method("name"): #saving enums as their string
						json_ready["states"][worldid][subkey] = str(value.name())
					else:
						json_ready["states"][worldid][subkey] = str(value)	
				TYPE_INT:
					json_ready["states"][worldid][subkey] = Utils.make_json_safe(value)
				TYPE_FLOAT, TYPE_BOOL, TYPE_STRING:
					json_ready["states"][worldid][subkey] = Utils.make_json_safe(value)
				TYPE_ARRAY:
					json_ready["states"][worldid][subkey] = Utils.make_json_safe(value)
				TYPE_DICTIONARY:
					json_ready["states"][worldid][subkey] = Utils.make_json_safe(value)
				_:
					json_ready["states"][worldid][subkey] = str(value)
	var json = JSON.stringify(json_ready)
	return json

func save_to_disk(path : String) -> String:
	Utils.ensure_directory_for_file(path)
	var json = create_json_v01()
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Couldnt save to disk!! %s." % FileAccess.get_open_error())

	await file.store_line(json)
	file.close()
	return json
	
static func delete_from_disk(path : String) -> bool:
	if not FileAccess.file_exists(path):
		push_warning("Save file does not exist: " + path)
		return false

	var dir = DirAccess.open("user://")
	if dir == null:
		push_error("Could not open user:// directory")
		return false

	var err = dir.remove(path)
	if err != OK:
		push_error("Failed to delete save file: " + path)
		return false

	return true

func load_json_v01(file : FileAccess) -> void:
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(content)
	if not parse_result == OK:
		push_warning("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
		return 
	var loaded_data = json.data
	if typeof(loaded_data) == TYPE_DICTIONARY:
		if "states" in loaded_data:
			states = loaded_data["states"]
		if "meta" in loaded_data:
			meta = loaded_data["meta"]
		else:
			push_warning("Missing meta information! at %s." % file.get_path() )
			meta = {}
	return 

# Load from disk
func load_from_disk(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not FileAccess.file_exists(path):
		push_warning("Couldn't find world state in disk at %s." % path)
		return
	load_json_v01(file)
	
