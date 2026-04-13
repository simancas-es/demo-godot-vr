extends Node

signal next_in_line(task_id : SYSTEMTASKSSETTINGS.UNIT_ID)

@export var is_autoloaded_taskmanager : bool = true

var manager : SYSTEMTASKS_UIDCLASSREF.SystemTasksManager = null

@export var task_sequence : Array[SYSTEMTASKSSETTINGS.UNIT_ID]

func _enter_tree() -> void:
	if is_autoloaded_taskmanager:
		if not Engine.has_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER):
			push_error("Couldnt find Task Manager")
			return
		manager = Engine.get_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER)

func _ready() -> void:
	if manager:
		manager.updated.connect(sequencing)
	sequencing()

func sequencing(...args) -> void:
	if manager == null:
		return

	for i in task_sequence.size():
		var task_id = task_sequence[i]
		if manager.check_task_status(task_id) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED:
			manager.activate_task(task_id)
			next_in_line.emit(task_id)
			return

func get_current_task() -> SYSTEMTASKSSETTINGS.UNIT_ID:
	for i in task_sequence.size():
		var task_id = task_sequence[i]
		if manager.check_task_status(task_id) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED:
			return task_id
	return -1
