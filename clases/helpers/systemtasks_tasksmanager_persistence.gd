extends StatefulPersistenceInterface
#Class that helps the inventory class keep its persistence across sessions
const TasksManager := SYSTEMTASKS_UIDCLASSREF.SystemTasksManager
const Task := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit
const PersistenceUtils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils
var parent : TasksManager = null
var UNIT_IDS : Dictionary[String, int]

func _ready() -> void:
	super()
	parent = get_parent()
	if not (parent is TasksManager):
		push_error("Parent %s is not Inventory!!" % parent)
	UNIT_IDS = parent.UNIT_IDS
	var data = get_data()
	if data.has("tasks_active_status"):
		var tasks_status : Dictionary = data["tasks_active_status"] as Dictionary
		for key in tasks_status:
			var status = tasks_status[key]
			var enum_key = UNIT_IDS[key]
			var enumval = PersistenceUtils.string_to_enum(Task.STATUS, status)
			if enum_key in parent.tasks.keys():
				if (enumval == Task.STATUS.COMPLETED) or (enumval == Task.STATUS.COMPLETED):
					parent.history[enum_key] = enumval
					parent.tasks.erase(enum_key)
				else:
					var task = parent.tasks[enum_key]				
					task.status = enumval
				
	if data.has("tasks_history_status"):
		var tasks_status : Dictionary = data["tasks_history_status"] as Dictionary
		for key in tasks_status:
			var status = tasks_status[key]
			var enum_key =  UNIT_IDS[key]
			var enumval = PersistenceUtils.string_to_enum(Task.STATUS, status)
			parent.history[enum_key] = enumval
			if enum_key in parent.tasks: parent.tasks.erase(enum_key)
	
	parent.updated.connect(on_manager_update)

func on_manager_update(...args) -> void:
	var tasks_active : Dictionary = {}
	var tasks_history : Dictionary = {}
	for key in parent.tasks:
		var task : Task = parent.tasks[key]
		var str_id = PersistenceUtils.enum_to_string(SYSTEMTASKSSETTINGS.UNIT_ID, task.unit_id)
		var str_status = PersistenceUtils.enum_to_string(Task.STATUS, task.status)
		tasks_active[str_id] = str_status
	for key in parent.history:
		var status : Task.STATUS = parent.history[key]
		var enum_key = PersistenceUtils.enum_to_string(SYSTEMTASKSSETTINGS.UNIT_ID, key)
		tasks_history[enum_key] = PersistenceUtils.enum_to_string(Task.STATUS, status)
	
	save_data({"tasks_active_status": tasks_active, "tasks_history_status":tasks_history})
	pass
