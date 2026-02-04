extends SystemTasksCondition
#class_name SystemTasksConditionFinishedTask
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksUnit := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit
const SystemTasksManager := SYSTEMTASKS_UIDCLASSREF.SystemTasksManager

#Export variable so should be readable
@export var units_id_completed : Array[SYSTEMTASKSSETTINGS.UNIT_ID] = []
@export var units_id_failed : Array[SYSTEMTASKSSETTINGS.UNIT_ID] = []
var manager : SystemTasksManager = null


func setup() -> void:
	fulfill_fun = is_completed
	oneshot = true

#Sets the parameters
func set_parameters(dict : Dictionary) -> ERROR:
	for v in dict:
		var val : Variant = dict.get(v, [])
		if typeof(val) == TYPE_ARRAY:
			for uid in val:
				if not uid in UNIT_IDS:
					push_warning("Task %s not found in UNIT_IDS list: %s! Check SYSTEMTASKSSETTINGS.UNIT_IDS!: %s." % [uid, UNIT_IDS, SYSTEMTASKSSETTINGS.UNIT_ID])
					return ERROR.ERROR
				match v:
					"units_id_completed":
						units_id_completed.append(UNIT_IDS[uid])
					
					"units_id_failed":
						units_id_failed.append(UNIT_IDS[uid])
		
	return ERROR.NO_ERROR

#Condition Functions
#There is an Object of type T, status S in the world
func is_completed(world : Node, oneshot : bool) -> bool:
	for task_id in units_id_completed:
		var status = manager.check_task_status(task_id)
		if status != SystemTasksUnit.STATUS.COMPLETED:
			return false
	for task_id in units_id_failed:
		var status = manager.check_task_status(task_id)
		if status != SystemTasksUnit.STATUS.FAILED:
			return false
	return true
	

func _ready() -> void:
	var parent_task = get_parent()
	var parent_manager = parent_task.get_parent()
	if parent_manager is SystemTasksManager: #Dependency injection without having to modify the manager...
		manager = parent_manager
	
