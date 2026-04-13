extends Node

const SEQUENCER := preload("uid://coekj8jimafya")
@onready var sequencer : SEQUENCER = $TaskSequencerSecurityCheckpoints
@onready var sec_checks : Node3D = %SECURITY_CHECKS

const SECAREA := preload("uid://vojndhlaetth")

func _ready():
	sequencer.next_in_line.connect(_on_next_task)
	_on_next_task(sequencer.get_current_task())

func _on_next_task(task_id : int) -> void:
	match task_id:
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK1:
			_activate_area("Area3D1")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK2:
			_activate_area("Area3D2")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK3:
			_activate_area("Area3D3")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK4:
			_activate_area("Area3D4")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK5:
			_activate_area("Area3D5")
		SYSTEMTASKSSETTINGS.UNIT_ID.Q_HL_SECURITYCHECK6:
			_activate_area("Area3D6")
		
func _activate_area(name : String):
	var a : SECAREA = sec_checks.get_node_or_null(name)
	if a:
		a.activate()
