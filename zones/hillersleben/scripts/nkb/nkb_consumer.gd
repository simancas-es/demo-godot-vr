extends "res://zones/hillersleben/scripts/tasks/sequence_consumer.gd"

signal ice_removed


var locator : SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator

const NKB := preload("uid://cebddgdpbxlsi")
@onready var nkb1 : NKB = $NKB_Unit
@onready var nkb2 : NKB = $NKB_Unit2

func _init() -> void:
	locator = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_NKB_SCHNECKE_EIS)

func _ready() -> void:
	sequencer = $TaskSequencer
	add_child(locator)
	nkb1.updated.connect(check_ice)
	nkb2.updated.connect(check_ice)
	
		
func check_ice() -> void:
	var ice_count = 0
	ice_count += nkb1.count_ice_left()
	ice_count += nkb2.count_ice_left()
	if ice_count == 0:
		ice_removed.emit()
	pass
