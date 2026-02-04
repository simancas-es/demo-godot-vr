extends Node
#Manages Task Text for titles and descriptions in different languages.
#TaskManager can be accessed through GameState.world_task_manager

var current_texts : Dictionary[int, Dictionary] = {}

var _task_map : Dictionary[String, int]

func _init(tasks_path : String, task_map : Dictionary[String, int]) -> void:
	current_texts = json_read_v01(tasks_path, task_map)
	_task_map = task_map
	
#returns title:str text:str
func get_text(unit_id : int, locale : String) -> Dictionary:
	var dic = {"title":"MISSING UNIT_ID %s" % unit_id, "text":"MISSING UNIT_ID TEXT"}
	if not unit_id in current_texts: 
		push_warning("Missing unit_id %s" % unit_id)
		return dic

	var ud = current_texts[unit_id]
	
	if not locale in ud["title"]: 
		push_warning("Missing locale %s in task %s title" % [locale, ud["unit_id"]])
		dic.title = ud["title"]["en"]
	else: dic.title = ud["title"][locale]
	
	if not locale in ud["text"]:
		push_warning("Missing locale %s in task  %s text" % [locale, ud["unit_id"]])
		dic.text = ud["text"]["en"]
	else: dic.text = ud["text"][locale]
	
	return dic

#Reads the json with the quests in the v01 format
#Task map is a "String, int" relationship for the task enums
static func json_read_v01(path: String, task_map : Dictionary[String, int]) -> Dictionary[int, Dictionary]:
	var dic : Dictionary[int, Dictionary] = {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Cannot open JSON file: %s" % path)
		return dic
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	if parse_result != OK:
		push_warning("JSON Parse Error: %s in %s at line %d" %
			[json.get_error_message(), json_text, json.get_error_line()])
		return dic
	
	var data = json.data
	# Check version
	if not data.has("version"):
		push_warning("JSON missing version key")
	elif data.version != "0.1":
		push_warning("JSON version mismatch: %s" % data.version)

	# Validate tasks array
	if not data.has("tasks") or typeof(data.tasks) != TYPE_ARRAY:
		push_warning("No 'tasks' array in JSON")
		return dic
		
	var tasks = data["tasks"]
	validate(tasks, task_map)
	for task in tasks:
		dic[task["unit_id"]] = task
		#task.erase("unit_id")
	return dic

#Turns unit_id into an enum value, fills missing elements.
#Task map is the relationship between unit_id and enum int
static func validate(task_texts : Array, task_map : Dictionary[String, int]) -> void:
	# Loop all tasks and validate
	for t in task_texts:
		if typeof(t) != TYPE_DICTIONARY:
			push_warning("Skipping non-dictionary task: %s" % str(t))
			continue
		
		# Validate unit_id
		if not t.has("unit_id"):
			push_warning("Missing 'unit_id'. Using 'UNKNOWN'.")
		var t_id = t.get("unit_id", "UNKNOWN")
			
		if not (t_id in task_map): 
			push_error("id: %s > Not found in the UNIT_ID registry" % t_id)
			t["unit_id"] = -1
		else:
			t["unit_id"] = task_map[t_id] #Gets int
		
		# Validate title
		if not t.has("title") or typeof(t["title"]) != TYPE_DICTIONARY or t["title"].size() == 0:
			push_warning("Quest '%s' missing or empty 'title'. Substituting with 'missing title'." % t.get("task_id"))
			t["title"] = {"en": "missing title"}
		
		# Validate text
		if not t.has("text") or typeof(t["text"]) != TYPE_DICTIONARY or t["text"].size() == 0:
			push_warning("Quest '%s' missing or empty 'text'. Substituting with 'missing text'." % t.get("task_id"))
			t["text"] = {"en": "missing text"}
	
	return
	
	
static func enum_to_dict(e: Dictionary) -> Dictionary[String, int]:
	var d: Dictionary[String, int] = {}
	for key in e.keys():
		d[str(key)] = int(e[key])
	return d
	
	
	
	
	
	
