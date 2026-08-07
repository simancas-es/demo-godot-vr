extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"

#Tasks associated>
#Q_HL_NH4_HIGH_BELUEFTET:
#	Im Belebungsbecken die Nh4 Konzentration ist zu hoch, wir müssen es erniedrigen.
#	Erniedrigung durch regulierung von knopfen. Target Setting zu hoch.

var locator := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_NH4_HIGH_BELUEFTET)
signal target_concentration_fixed

var task_nh4_active : bool = false

func _ready() -> void:
	sequencer = $TaskSequencer
	add_child(locator)
	init_task_logic()
	
	
func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_NH4_HIGH_BELUEFTET:
			nh4_controller.set_target_nh4(15.0)
			task_nh4_active = true
			pass
			



## LOGIC FOR TASKS
#@export var blender_nh4_label_np : NodePath # $"Visuals/Referenz/B1-Steuerung-1/Text_012"
#@onready var blender_nh4_label : MeshInstance3D = get_node(blender_nh4_label_np)

const COORDINATOR := preload("uid://dbb00gqpvldte")
@onready var nh4_controller : COORDINATOR = $"../PID_NH4_bb1"

	
func init_task_logic() -> void:
	#blender_nh4_label.visible = false
	pass

var timer := 0.0
func _process(delta: float) -> void:
	timer += delta
	if timer >= 2.0:
		timer = 0.0
		if task_nh4_active == true and nh4_controller.get_target_nh4() < 2.1:
			task_nh4_active = false
			target_concentration_fixed.emit()
