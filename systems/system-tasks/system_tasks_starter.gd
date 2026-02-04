extends Node
#Note: Onlz works if the task manager is global, else it needs to write its own logic to find it.

@export var task_id : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.UNKNOWN
@export var is_autoloaded_taskmanager : bool = true #If global then it will try to find a singleton for it
@export var activate_on_enter_tree : bool = true

var manager : SYSTEMTASKS_UIDCLASSREF.SystemTasksManager = null

func _enter_tree() -> void:
	if is_autoloaded_taskmanager: #try to find it
		if not Engine.has_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER):
			push_error("Couldnt find Task Manager under %s!!" % SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER)
			return
		var sg = Engine.get_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER)
		if sg == null:
			push_error("Task Manager Autoload is null")
			return
		if not (sg is SYSTEMTASKS_UIDCLASSREF.SystemTasksManager):
			push_error("Task Manager under name %s is not of correct class!!")
			return
		manager = sg
	
	#Convenience function
	if activate_on_enter_tree:
		activate()
	return

#Multiple activations do nothing.
func activate() -> void:
	if manager:
		manager.activate_task(task_id)
	else:
		push_error("Activating tasks starter without manager!!")

			
			
			
