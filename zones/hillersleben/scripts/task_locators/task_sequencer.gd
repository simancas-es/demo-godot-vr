extends Node

## Sequences the tasks -> One finishes, another one gets activated.

@export var is_autoloaded_taskmanager : bool = true #If global then it will try to find a singleton for it
@export var activate_on_enter_tree : bool = true

@onready var sec_checks : Node3D = %SECURITY_CHECKS
const SECAREA := preload("uid://vojndhlaetth")

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
	
	
	return

func _ready() -> void:
	sec_checks.ready.connect(sequencing)
	manager.updated.connect(sequencing)
	sequencing()
	pass
	
func sequencing(...args) -> void:
	if sec_checks == null : return
	var task_id_1 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK1
	var task_id_2 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK2
	var task_id_3 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK3
	var task_id_4 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK4
	var task_id_5 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK5
	var task_id_6 : SYSTEMTASKSSETTINGS.UNIT_ID = SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK6
	
	var a1 : SECAREA = sec_checks.get_node_or_null("Area3D1"); if a1: a1.activate()
	if manager.check_task_status(task_id_1) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED:return
	
	manager.activate_task(task_id_2)
	var a2 : SECAREA = sec_checks.get_node_or_null("Area3D2"); if a2: a2.activate()

	if manager.check_task_status(task_id_2) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED: return
	
	manager.activate_task(task_id_3)	
	var a3 : SECAREA = sec_checks.get_node_or_null("Area3D3"); if a3: a3.activate()

	if manager.check_task_status(task_id_3) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED: return
	
	manager.activate_task(task_id_4)	
	var a4 : SECAREA = sec_checks.get_node_or_null("Area3D4"); if a4: a4.activate()

	if manager.check_task_status(task_id_4) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED: return
	
	manager.activate_task(task_id_5)	
	var a5 : SECAREA = sec_checks.get_node_or_null("Area3D5"); if a5: a5.activate()

	if manager.check_task_status(task_id_5) != SYSTEMTASKS_UIDCLASSREF.SystemTasksUnit.STATUS.COMPLETED: return
	
	manager.activate_task(task_id_6)
	var a6 : SECAREA = sec_checks.get_node_or_null("Area3D6"); if a6: a6.activate()

	pass
