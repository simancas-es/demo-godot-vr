extends CanvasLayer

const TaskManager = SYSTEMTASKS_UIDCLASSREF.SystemTasksManager
const TaskTextManager = HELPREF.TaskTextManager
const SystemTasksUnit = SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit

const TaskTextUIList := preload("uid://dkevqhb4nu1qi")
const task_list_scene := preload("uid://cx1wgq0gx0mxe")


static func write_json(path: String, data) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

static func valid_json() -> Dictionary:
	var dic := {
		"version":"0.1",
		"tasks":[
		{
			"unit_id": "TESTID_0",
			"title": {
				"en": "defaulttasktitle_task0",
				"es": "titulotareapordefecto_task0",
				"de": "defaultaufgabetitel_task0"
			},
			"text": {
				"en": "description_task0",
				"es": "descripcion_task0",
				"de": "beschreibung_task0"
			}
		},
		{
			"unit_id": "TESTID_1",
			"title": {
				"en": "defaulttasktitle_task1",
				"es": "titulotareapordefecto_task1",
				"de": "defaultaufgabetitel_task1"
			},
			"text": {
				"en": "description_task1",
				"es": "descripcion_task1",
				"de": "beschreibung_task1"
			}
		}
	]}
	
	return dic
static func valid_map() -> Dictionary:
	var TASKMAP : Dictionary[String,int] = {"TESTID_0":4, "TESTID_1":5}
	return TASKMAP
	
func _ready() -> void:
	
	var json_texts = valid_json()
	var path = "user://debug_task_list_test_json"
	write_json(path, json_texts)
	var tm = TaskManager.new(valid_map())
	var ttm = TaskTextManager.new(path, valid_map())
	
	add_child(tm)
	add_child(ttm)
	
	
	var task0 = SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.new()
	task0.unit_id = 4
	task0.status = SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.UNINITIATED

	var task1 = SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.new()
	task1.unit_id = 5
	task1.status = SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED

	tm.add_task(task0)
	tm.add_task(task1)


	#init
	var list : TaskTextUIList = task_list_scene.instantiate()
	list.world_task_manager = tm
	list.task_text_manager = ttm
	
	add_child(list)
	
	

	var task_panels = list.task_panels
	assert(task_panels.size() == 2)

	var scroll := list.get_child(0) as ScrollContainer
	assert(scroll != null)

	var list_vbox := scroll.get_child(0) as VBoxContainer
	assert(list_vbox != null)

	#There should be 2 task panels
	assert(list_vbox.get_child_count() == 2)
	
	#First panel uninitiated
	var panel0 := list_vbox.get_child(0) as PanelContainer
	assert(panel0 != null)

	var vbox0 := panel0.get_child(0) as VBoxContainer
	assert(vbox0.get_child_count() == 3)

	var title0 := vbox0.get_child(0) as Label
	var desc0 := vbox0.get_child(1) as Label
	var status0 := vbox0.get_child(2) as Label

	assert(title0.text == "defaulttasktitle_task0")
	assert(desc0.text == "description_task0")
	assert(status0.text == list._text_uninitiated)
	assert(status0.get_theme_color("font_color") == Color.GRAY)


	#Second panel completed
	var panel1 := list_vbox.get_child(1) as PanelContainer
	assert(panel1 != null)

	var vbox1 := panel1.get_child(0) as VBoxContainer
	var status1 := vbox1.get_child(2) as Label

	assert(status1.text == list._text_completed)
	assert(status1.get_theme_color("font_color") == Color.GREEN)


	list.filter_only = [SystemTasksUnit.STATUS.FAILED, SystemTasksUnit.STATUS.IN_PROGRESS, SystemTasksUnit.STATUS.COMPLETED] 

	#Status change
	tm.tasks[4].status = SystemTasksUnit.STATUS.IN_PROGRESS
	tm.updated.emit(4, SystemTasksUnit.STATUS.IN_PROGRESS)

	await get_tree().process_frame
	
	
	assert(status0.text == list._text_inprogress)
	assert(status0.get_theme_color("font_color") == Color.YELLOW)


	pass	
