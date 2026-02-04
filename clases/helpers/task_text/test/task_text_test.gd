extends Node

#Tests the task_test helpor
const TaskTextManager := preload("uid://qlo5ftrjww7d")

var TASKMAP : Dictionary[String,int] = {"TESTID_0":1, "TESTID_1":2}

static func write_json(path: String, data) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func test_enum_to_dict() -> bool:
	# Simulate how Godot exposes enums internally
	var fake_enum := {
		"UNINITIATED": 0,
		"IN_PROGRESS": 1,
		"FAILED": 2,
		"COMPLETED": 3
	}

	var result := TaskTextManager.enum_to_dict(fake_enum)

	# Size should match
	assert(result.size() == fake_enum.size())

	# Keys should be strings
	for key in result.keys():
		assert(typeof(key) == TYPE_STRING)

	# Values should be ints and equal
	assert(result["UNINITIATED"] == 0)
	assert(result["IN_PROGRESS"] == 1)
	assert(result["FAILED"] == 2)
	assert(result["COMPLETED"] == 3)
	
	return true
	
	
	
func test_valid_json_v01() -> bool:
	var test_path = "user://test_quests.json"
	write_json(test_path, {
		"version":"0.1",
		"tasks":[
		{
			"unit_id": "TESTID_0",
			"title": {
				"en": "defaulttasktitle",
				"es": "titulotareapordefecto",
				"de": "defaultaufgabetitel"
			},
			"text": {
				"en": "description",
				"es": "descripcion",
				"de": "beschreibung"
			}
		}
	]})

	var result = TaskTextManager.json_read_v01(test_path, TASKMAP)

	# Assertions
	assert(result.size() == 1)
	
	var task = result[1]
	assert(task["title"]["en"] == "defaulttasktitle")
	assert(task["text"]["de"] == "beschreibung")

	return true
	
	
func test_invalid_json() -> bool:
	var path = "user://test_invalid.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ this is not valid json ")
	file.close()	

	var result = TaskTextManager.json_read_v01(path, TASKMAP)

	# Assertions
	assert(result.is_empty())
	return true

func test_missing_fields_json() -> bool:
	var path = "user://test_missing.json"
	write_json(path, {
		"version":"0.1",
		"tasks":[
		{
			"unit_id": "TESTID_1"
		}
	]})

	var result = TaskTextManager.json_read_v01(path, TASKMAP)

	assert(result.size() == 1)

	var task = result[2]

	# title substituted
	assert(task.has("title"))
	assert(task["title"]["en"] == "missing title")

	# text substituted
	assert(task.has("text"))
	assert(task["text"]["en"] == "missing text")

	return true
	
	
	

func test_get_texts_for_all_cases() -> bool:

	var valid_path = "user://test_quests.json"
	write_json(valid_path, {
		"version":"0.1",
		"tasks":[
		{
			"unit_id": "TESTID_0",
			"title": {
				"en": "defaulttasktitle",
				"es": "titulotareapordefecto",
				"de": "defaultaufgabetitel"
			},
			"text": {
				"en": "description",
				"es": "descripcion",
				"de": "beschreibung"
			}
		}
	]})
	TaskTextManager.json_read_v01(valid_path, TASKMAP)
	
	print("Testing get_text() with valid JSON:")
	var ttm = TaskTextManager.new(valid_path, TASKMAP)
	var text_en = ttm.get_text(TASKMAP["TESTID_0"], "en")
	var text_de = ttm.get_text(TASKMAP["TESTID_0"], "de")
	var text_es = ttm.get_text(TASKMAP["TESTID_0"], "es")
	var text_fr = ttm.get_text(TASKMAP["TESTID_0"], "fr") # missing locale fallback
	
	assert ( text_en.title == "defaulttasktitle")
	assert ( text_es.title == "titulotareapordefecto")
	assert ( text_fr.title == "defaulttasktitle") #fallback

	
	assert ( text_en.text == "description")
	assert ( text_es.text == "descripcion")
	assert ( text_fr.text == "description") #fallback
	
	return true

func _ready():
	print("Testing the helper for the task texts...")
	
	assert ( test_enum_to_dict() )
	assert ( test_valid_json_v01() )
	assert ( test_invalid_json() )
	assert ( test_missing_fields_json() )
	assert ( test_get_texts_for_all_cases() )
	print("Tests successful...")
