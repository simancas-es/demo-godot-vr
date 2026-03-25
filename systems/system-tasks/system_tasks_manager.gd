extends Node
#class_name SystemTasksManager
const SystemTasksUnit := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult

var tasks : Dictionary[int, SystemTasksUnit] = {}
var history : Dictionary[int, SystemTasksUnit.STATUS] = {}

var UNIT_IDS : Dictionary[String, int] #Passed from outside.

enum ERROR {NO_ERROR, ERROR}

signal updated(task_id : int, new_status : int)

#JSONS of tasks with the format:
#version
#tasks [] - 
#			{id:str,
			#conditions: {success: {all:[{type:SystemTasksCondition, var:value...}], any:[{type:SystemTasksCondition, var:value...}]},
						 #fail: {all:[{type:SystemTasksCondition, var:value...}], any:[{{type:SystemTasksCondition, var:value...}}]}
						#},
			#results: {success:[{type:SystemTasksResult, var:value}], fail:[{type:SystemTasksResult, var:value}]}
			#}
#The SystemTasksCondition and Result have to be a subclass of it, indicated by (type:).
# The var:values are specific to the subclasses, except oneshot which belongs to all conditions.


func _init(unit_ids : Dictionary[String, int], is_global : bool = false) -> void:
	if is_global:
		if Engine.has_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER): 
			push_error("TasksManager already autoloaded!")
			return
		Engine.register_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER, self)
	
	UNIT_IDS = unit_ids
	pass

func add_task(task : SystemTasksUnit) -> ERROR:
	if task.unit_id in tasks: return ERROR.ERROR
	tasks[task.unit_id] = task
	
	task.initialize_conditions()
	add_child(task)
	if task.finished.is_connected(on_finished_task) :
		push_warning("Task %s already connected to task manager")
		return ERROR.NO_ERROR
	else: task.finished.connect(on_finished_task)
	
	updated.emit(task.unit_id, task.status)
	return ERROR.NO_ERROR
	
func activate_task(task_id : int) -> ERROR:
	if task_id == SYSTEMTASKSSETTINGS.UNIT_ID.UNKNOWN : return ERROR.ERROR
	if task_id in tasks:
		tasks[task_id].start()
		updated.emit(task_id, tasks[task_id].status)
		return ERROR.NO_ERROR
	else:
		return ERROR.ERROR

func on_finished_task(task : SystemTasksUnit) -> ERROR:
	var id = task.unit_id
	var status = task.status
	history[task.unit_id] = status #Failed or completed...
	remove_child(task) #TODO Self destruction on removed from tree.		
	
	tasks.erase(task.unit_id)
	updated.emit(id, status)
	return ERROR.NO_ERROR	
	
func check_task_status(task_id : int) -> SystemTasksUnit.STATUS:
	if task_id in history:
		return history[task_id]
	elif task_id in tasks:
		return tasks[task_id].status
	return SystemTasksUnit.STATUS.UNINITIATED
	
func update_tick_tasks() -> ERROR:
	for task in tasks.values():
		task.update_status()
	return ERROR.NO_ERROR
	
#Loads jsons of tasks
func load_json(path : String) -> void:
	print("Reading path...", path)
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not open JSON file: %s" % path)
		return

	var text := file.get_as_text()
	file.close()

	var data : Variant = JSON.parse_string(text)
	if typeof(data) == TYPE_DICTIONARY:
		#Check version
		if not "version" in data: push_error("Missing version!!"); return
		var version = data["version"]
		if version == "0.1":
			parse_json_task_v01(data)
		else:
			pass
		
		pass
	else:
		push_warning("JSON did not parse into a Dictionary")
		pass
	pass

#Parses a json with task data using the 0.1 version.
func parse_json_task_v01(data : Dictionary) -> void:
	var version = data["version"]
	if version != "0.1": push_error("Wrong version!! Should be 0.1, is %s" % version); return
	
	var _task_list = data["tasks"]
	for t in _task_list:
		var task_unit : SystemTasksUnit = generate_task_v01(t, UNIT_IDS)
		if task_unit: add_task(task_unit)
		
	return

static func generate_task_empty_json_v01() -> Dictionary:
	var base_task = {"id":null, "conditions":[], "results":[]}
	base_task["conditions"] = {"success":{"all":[], "any":[]}, "fail":{"all":[], "any":[]}}
	base_task["fail"] = {"success":{"all":[], "any":[]}, "fail":{"all":[], "any":[]}}
	base_task["results"] = {"success":[], "fail":[]}
	return base_task
	
#if any of the id, conditions, results or attributes of any of them is wrong, it will return null
static func generate_task_v01(task_data : Dictionary, unit_ids : Dictionary[String, int] = SYSTEMTASKSSETTINGS.UNIT_ID) -> SystemTasksUnit:
	var id = task_data["id"]
	if not (id in unit_ids): 
		push_error("id: %s > Not found in the UNIT_ID register" % id)
		return null
	var task_id = unit_ids[id]

	
	
	var conditions = task_data["conditions"]
	var results = task_data["results"]
	
	var s_all : Array = [] #Array[Dictionary]...
	var s_any : Array = []
	var f_all : Array = []
	var f_any : Array = []
	
	var r_s : Array = []
	var r_f : Array = []
	
	if "success" in conditions:
		if "all" in conditions["success"]: s_all = conditions["success"]["all"]
		if "any" in conditions["success"]: s_any = conditions["success"]["any"]
	
	if "fail" in conditions:
		if "all" in conditions["fail"]: f_all = conditions["fail"]["all"]
		if "any" in conditions["fail"]: f_any = conditions["fail"]["any"]
	
	if "success" in results: r_s = results["success"]
	if "fail" in results: r_f = results["fail"]
	
	var new_task = SystemTasksUnit.new()
	#Conditions have to be filled in this order:
	#var success_conditions_all : Array[SystemTasksCondition] = []
	#var success_conditions_any : Array[SystemTasksCondition] = []
	#var success_results : Array[SystemTasksResult] = []
	#
	#var fail_conditions_all : Array[SystemTasksCondition] = []
	#var fail_conditions_any : Array[SystemTasksCondition] = []
	#var fail_results : Array[SystemTasksResult] = []
	
	new_task.unit_id = task_id
	#Create the conditions
	#All conditions must be valid when returning the task #TODO: Code is here pratically duplicated 6 times...
	for c : Dictionary in s_all:
		if not "type" in c: continue
		var type = c["type"]
		#check which class
		var cond_class  = SYSTEMTASKSSETTINGS.get_conditions_class(type)
		var cond_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition = cond_class.new(unit_ids, SYSTEMTASKSSETTINGS.TICK_FREQUENCY_S)
		#update parameters for each p in c
		#c.erase("type")				
		var err = cond_object.set_parameters(c) #Sets all paramters except type, as its been used already and is just the class.
		if err == SystemTasksCondition.ERROR.ERROR:
			push_error("Couldnt load task because of condition: %s" % [c])
			return null
		elif err == SystemTasksCondition.ERROR.NO_ERROR:
			pass
		new_task.success_conditions_all.append(cond_object)
	
	for c : Dictionary in s_any:
		if not "type" in c: continue
		var type = c["type"]
		#check which class
		var cond_class  = SYSTEMTASKSSETTINGS.get_conditions_class(type)
		var cond_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition = cond_class.new(unit_ids, SYSTEMTASKSSETTINGS.TICK_FREQUENCY_S)
		#update parameters for each p in c
		#c.erase("type")				
		var err = cond_object.set_parameters(c)
		if err == SystemTasksCondition.ERROR.ERROR:
			push_error("Couldnt load task because of condition: %s" % [c])
			return null
		elif err == SystemTasksCondition.ERROR.NO_ERROR:
			pass
		new_task.success_conditions_any.append(cond_object)
	
	for f : Dictionary in f_all:
		if not "type" in f: continue
		var type = f["type"]
		#check which class
		var cond_class  = SYSTEMTASKSSETTINGS.get_conditions_class(type)
		var cond_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition = cond_class.new(unit_ids, SYSTEMTASKSSETTINGS.TICK_FREQUENCY_S)
		#update parameters for each p in c
		#f.erase("type")				
		var err = cond_object.set_parameters(f)
		if err == SystemTasksCondition.ERROR.ERROR:
			push_error("Couldnt load task because of condition: %s" % [f])
			return null
		elif err == SystemTasksCondition.ERROR.NO_ERROR:
			pass
		new_task.fail_conditions_all.append(cond_object)
	
	for f : Dictionary in f_any:
		if not "type" in f: continue
		var type = f["type"]
		#check which class
		var cond_class  = SYSTEMTASKSSETTINGS.get_conditions_class(type)
		var cond_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition = cond_class.new(unit_ids, SYSTEMTASKSSETTINGS.TICK_FREQUENCY_S)
		#update parameters for each p in c
		#f.erase("type")				
		var err = cond_object.set_parameters(f)
		if err == SystemTasksCondition.ERROR.ERROR:
			push_error("Couldnt load task because of condition: %s" % [f])
			return null
		elif err == SystemTasksCondition.ERROR.NO_ERROR:
			pass
		new_task.fail_conditions_any.append(cond_object)
			
	for rs : Dictionary in r_s:
		if not "type" in rs: continue
		var type = rs["type"]
		var res_class = SYSTEMTASKSSETTINGS.get_results_class(type)
		var res_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksResult = res_class.new()
		var err = res_object.set_parameters(rs)
		if err == SystemTasksResult.ERROR.ERROR:
			push_error("Couldnt load task because of result success: %s" % [rs])
			return null
		elif err == SystemTasksResult.ERROR.NO_ERROR:
			pass
		new_task.success_results.append(res_object)
		pass
	
	for rf : Dictionary in r_f:
		if not "type" in rf: continue
		var type = rf["type"]
		var res_class = SYSTEMTASKSSETTINGS.get_results_class(type)
		var res_object : SYSTEMTASKS_UIDCLASSREF.SystemTasksResult = res_class.new()
		var err = res_object.set_parameters(rf)
		if err == SystemTasksResult.ERROR.ERROR:
			push_error("Couldnt load task because of result fail: %s" % [rf])
			return null
		elif err == SystemTasksResult.ERROR.NO_ERROR:
			pass
		new_task.fail_results.append(res_object)
		pass
	
	return new_task
