extends Node
#Module testing
const SystemTasksUnit := SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksResult := SYSTEMTASKS_UIDCLASSREF.SystemTasksResult
const SystemTasksManager := SYSTEMTASKS_UIDCLASSREF.SystemTasksManager
const SystemTasksLocator := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator
const SystemTasksStarter := SYSTEMTASKS_UIDCLASSREF.SystemTasksStarter

const SystemTasksConditionExisting := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionExisting
const SystemTasksConditionSignal := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionSignal
const SystemTasksConditionLocation := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionLocation
const SystemTasksConditionFinishedTask := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionFinishedTask

const SystemTasksResultGiveItem := SYSTEMTASKS_UIDCLASSREF.SystemTasksResultGiveItem
const SystemTasksResultPrint := SYSTEMTASKS_UIDCLASSREF.SystemTasksResultPrint

class SignalObject extends Node3D:
	signal test_signal
	var signal_emitted := false
	func _init():
		test_signal.connect(func(): signal_emitted=true)

func test_task_existing() -> SystemTasksUnit:
	var t = SystemTasksManager.generate_task_empty_json_v01()
	t["id"] = "TESTID_0"

	const s_all = []
	const s_any = [{
			  "type": "SystemTasksConditionExisting",
			  "number": 2,
			  "group_name": "SYSTEMTASKS_DEFAULT1"
			}]
	
	const f_all = [{  "type": "SystemTasksConditionSignal", "signal_name": "test_signal", "locator_id":"DEFAULT1"	} ]
	
	const r_s = [ {"type": "SystemTasksResultPrint","text": "Success at task default0" },
				 {"type": "SystemTasksResultGiveItem","item_id": "key_gold","amount": 1  }]
	const r_f = [ {
					"type": "SystemTasksResultPrint",
					"text": "You failed to open the valve in time!"
		 		 }	]
	t["conditions"]["success"]["all"] = s_all
	t["conditions"]["success"]["any"] = s_any
	t["conditions"]["fail"]["all"] = f_all
	t["results"]["success"] = r_s
	t["results"]["fail"] = r_f
	
	#Reading
	var read_task : SystemTasksUnit = SystemTasksManager.generate_task_v01(t, {"TESTID_0":0})
	
	assert(read_task.success_conditions_any[0] is SystemTasksConditionExisting)
	assert(read_task.fail_conditions_all[0] is SystemTasksConditionSignal)
	assert (read_task.fail_conditions_all[0].is_in_group(SYSTEMTASKSSETTINGS.BASE_COND_SIGNAL_GROUP))

	
	assert(read_task.success_results[0] is SystemTasksResultPrint)
	assert(read_task.fail_results[0] is SystemTasksResultPrint)

	
	var cond_existing : SystemTasksConditionExisting = read_task.success_conditions_any[0]
	assert(cond_existing.number == 2)
	assert(cond_existing.locator_group == SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_DEFAULT1)


	return read_task

func test_task_signal() -> SystemTasksUnit:
	var t = SystemTasksManager.generate_task_empty_json_v01()
	t["id"] = "TESTID_1"
	const s_all = [{  "type": "SystemTasksConditionSignal", "signal_name": "test_signal", "locator_id":"DEFAULT1"	} ]
	t["conditions"]["success"]["all"] = s_all
	var task_unit : SystemTasksUnit = SystemTasksManager.generate_task_v01(t,{"TESTID_1":5})
	
	assert (task_unit.unit_id == 5)
	assert (task_unit.success_conditions_all[0] is SystemTasksConditionSignal)
	assert (task_unit.success_conditions_all[0].signal_name == "test_signal")
	assert (task_unit.success_conditions_all[0].locator_id == SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1)
	assert (task_unit.success_conditions_all[0].is_in_group(SYSTEMTASKSSETTINGS.BASE_COND_SIGNAL_GROUP))

	return task_unit
	
	
func test_task_location() -> SystemTasksUnit:
	var t = SystemTasksManager.generate_task_empty_json_v01()
	t["id"] = "TESTID_2"
	const s_all = [{ "type": "SystemTasksConditionLocation", "locator_id_who": "PLAYER", "locator_id_where":"DEFAULT1"}]
	
	t["conditions"]["success"]["all"] = s_all
	var task_unit : SystemTasksUnit = SystemTasksManager.generate_task_v01(t, {"TESTID_2":6})
	
	assert (task_unit.unit_id == 6)
	assert (task_unit.success_conditions_all[0] is SystemTasksConditionLocation)
	assert (task_unit.success_conditions_all[0].locator_id_who == SYSTEMTASKSSETTINGS.LOCATOR_ID.PLAYER)
	assert (task_unit.success_conditions_all[0].locator_id == SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1)

	return task_unit
	
func test_task_finished_task() -> SystemTasksUnit:
	var t = SystemTasksManager.generate_task_empty_json_v01()
	t["id"] = "TESTID_3"
	
	const s_all = [{
			  "type": "SystemTasksConditionFinishedTask",
			  "units_id_completed": ["TESTID_1"],
			}]

	t["conditions"]["success"]["all"] = s_all
	
	var task_unit : SystemTasksUnit = SystemTasksManager.generate_task_v01(t, {"TESTID_1":5, "TESTID_3":7})
	
	assert (task_unit.unit_id == 7)
	assert (task_unit.success_conditions_all[0] is SystemTasksConditionFinishedTask)
	assert (task_unit.success_conditions_all[0].units_id_completed[0] == 5)
	return task_unit

func test_task_starters() -> bool:
	var task : SystemTasksUnit = test_task_existing()
	assert (task) 
	
	var sm := SystemTasksManager.new({"TESTID_0":1}, true) #Global manager
	#Automatically registered
	add_child(sm)
	assert (Engine.has_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER))
	sm.add_task(task)


	var starter1 : SystemTasksStarter = SystemTasksStarter.new() #Ignore Error of init without manager.
	starter1.task_id = task.unit_id
	starter1.is_autoloaded_taskmanager = false	
	#Try injecting task manager into the starter object
	add_child(starter1)
	assert (starter1.manager == null)
	
	remove_child(starter1)
	#Try autodetecting the manager
	starter1.is_autoloaded_taskmanager = true
	add_child(starter1)
	assert (starter1.manager == sm)
	
	
	return true




	
func test_task_condition_existing_locatorgroup_success() -> bool:
	var number = 2
	var group_name = "SYSTEMTASKS_DEFAULT1" #From test_task_existing
	
	var sm : SystemTasksManager = SystemTasksManager.new({"TESTID_0":2})	
	var user = %User
	user.add_child(sm)
	
	var task : SystemTasksUnit = test_task_existing()
	assert (task) 
	sm.add_task(task)
	


	
	var tasks = sm.tasks.values()
	assert (tasks[0].status == SystemTasksUnit.STATUS.UNINITIATED)	
	sm.activate_task(task.unit_id)
	assert (tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)	
	
		
	var test_object = Node3D.new()
	add_child(test_object)
	test_object.add_to_group(group_name)
	
	sm.update_tick_tasks()#
	assert(tasks[0].success_results[0].status == SystemTasksResult.STATUS.PENDING)
	assert (tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)	
	#Add an object to this group, check that the system does not react, then add a second one, and see that it does
	
	var test_object2 = Node3D.new()
	add_child(test_object2)
	test_object2.add_to_group(group_name)
	
	sm.update_tick_tasks()
	assert (tasks[0].status == SystemTasksUnit.STATUS.COMPLETED)	
	assert(tasks[0].success_results[0].status == SystemTasksResult.STATUS.EXECUTED)
	
	remove_child(test_object)
	remove_child(test_object2)
	test_object.queue_free()
	test_object2.queue_free()
	return true

func test_locator_init() -> bool:
	var loc_id = SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1)
	loc_id = SystemTasksLocator.new("DEFAULT1")
	return true
	
func test_task_condition_signal_locatorid_fail() -> bool:
	var number = 2
	var group_name = "SYSTEMTASKS_DEFAULT1" #From test_task_existing
	
	var sm : SystemTasksManager = SystemTasksManager.new({"TESTID_0":5})	
	var user = %User
	user.add_child(sm)
	
	var task : SystemTasksUnit = test_task_existing()
	assert (task) 
	sm.add_task(task)
	
	var tasks = sm.tasks.values()
	assert (tasks[0].status == SystemTasksUnit.STATUS.UNINITIATED)	
	sm.activate_task(task.unit_id)
	assert (tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)	
	
	sm.update_tick_tasks()#
	assert(tasks[0].fail_results[0].status == SystemTasksResult.STATUS.PENDING)
	assert (tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)	

	var signal_body = SignalObject.new()
	var loc_id = SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1)
	assert (not loc_id.is_in_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP))
	signal_body.add_child(loc_id)
	#get_tree().get_root().add_child(signal_body) #TODO This doesn't work for some reason...
	user.add_child(signal_body)
	assert (signal_body.is_inside_tree())
	assert (loc_id.is_in_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP))


	assert (signal_body.signal_emitted == false)
	signal_body.test_signal.emit() #Defined in the gdscript of the object. Cant do Signal.new()	
	assert (signal_body.signal_emitted == true)
	
	sm.update_tick_tasks()
	assert (tasks[0].status == SystemTasksUnit.STATUS.FAILED)	
	assert(tasks[0].fail_results[0].status == SystemTasksResult.STATUS.EXECUTED)
	
	signal_body.queue_free()
	return true
	
	
func test_task_condition_finished_task_success() -> bool:
	var sm : SystemTasksManager = SystemTasksManager.new({"TESTID_1":5, "TESTID_3":7})	#Same ints because they were initialized like this in the above functions
	var user = %User
	user.add_child(sm)
	
	var task2 : SystemTasksUnit = test_task_signal()
	var task3 : SystemTasksUnit = test_task_finished_task()
	
	sm.add_task(task2)
	sm.add_task(task3)
	
	sm.activate_task(task2.unit_id)
	sm.activate_task(task3.unit_id)
	
	assert (task3.success_conditions_all[0].manager == sm)
	
	sm.update_tick_tasks()#
	assert (task2.status == SystemTasksUnit.STATUS.IN_PROGRESS)
	assert (task3.status == SystemTasksUnit.STATUS.IN_PROGRESS)	

	#Signal emitter for the first task
	var signal_body = SignalObject.new()	
	var loc_id = SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1) #Default1, test_signal
	assert (not loc_id.is_in_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP))
	signal_body.add_child(loc_id)
	#get_tree().root.add_child(signal_body)
	user.add_child(signal_body)

	assert (loc_id.is_in_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP))

	assert (signal_body.signal_emitted == false)
	signal_body.test_signal.emit() #Defined in the gdscript of the object. Cant do Signal.new()	
	assert (signal_body.signal_emitted == true)
	
	sm.update_tick_tasks()
	assert (task2.status == SystemTasksUnit.STATUS.COMPLETED)	
	assert( task3.status == SystemTasksUnit.STATUS.COMPLETED)

	
	
	
	return true

func test_task_condition_location_success() -> bool:
	var sm := SystemTasksManager.new({"TESTID_2":6})
	%User.add_child(sm)

	var task: SystemTasksUnit = test_task_location()
	assert(task)
	sm.add_task(task)

	var tasks = sm.tasks.values()
	assert (tasks[0].status == SystemTasksUnit.STATUS.UNINITIATED)	
	sm.activate_task(task.unit_id)
	assert (tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)	
	
	var cond: SystemTasksConditionLocation = tasks[0].success_conditions_all[0]
	assert(cond is SystemTasksConditionLocation)
	#Who should enter where: Plazer in the locator_id
	assert(cond.locator_id_who == SYSTEMTASKSSETTINGS.LOCATOR_ID.PLAYER)
	assert(cond.locator_id == SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1)

	#Location that the body has to enter
	var detect_area := Area3D.new()
	add_child(detect_area) #Enter the scene tree anywhere
	
	#Body of thing that will enter the area
	var who_body := Node3D.new()
	add_child(who_body) #Enter the scene tree anywhere

	#Locator for the detecting area
	var where_locator := SystemTasksLocator.new(
		SYSTEMTASKSSETTINGS.LOCATOR_ID.DEFAULT1,
		SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_DEFAULT1
	)
	detect_area.add_child(where_locator) #Enter the scene tree anywhere

	# First tick: no locators "PLAYER" have entered = nothing happens
	sm.update_tick_tasks()
	assert(tasks[0].status == SystemTasksUnit.STATUS.IN_PROGRESS)


	#Locator for the to be detected body
	var who_locator := SystemTasksLocator.new(
		SYSTEMTASKSSETTINGS.LOCATOR_ID.PLAYER,
		#SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_PLAYER
	)
	who_body.add_child(who_locator)

	# Fake the signal of entering the area by passing the body
	detect_area.body_entered.emit(who_body)

	# Tick to process
	sm.update_tick_tasks()

	# Now the condition should be satisfied
	assert(tasks[0].status == SystemTasksUnit.STATUS.COMPLETED)

	detect_area.queue_free()
	who_body.queue_free()
	return true


func _ready() -> void:
	
	var script_path: String = get_script().resource_path
	var folder_path: String = script_path.get_base_dir()
	#var json_path: String = folder_path.path_join("task_database.json")
	#sm.load_json(json_path)
	
	
	assert ( test_task_existing() )
	assert ( test_task_signal())
	assert ( test_task_finished_task())
	assert ( test_task_starters())
	
	assert( test_locator_init() )
	assert ( test_task_condition_existing_locatorgroup_success() )
	assert ( test_task_condition_signal_locatorid_fail() )
	
	assert ( test_task_condition_finished_task_success())
	assert ( test_task_condition_location_success())
	
	
