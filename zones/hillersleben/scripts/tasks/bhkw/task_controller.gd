extends Node


var locator_id_temp_high : SYSTEMTASKSSETTINGS.LOCATOR_ID = SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_BHKW_HITEMP
var locator_id_temp_low : SYSTEMTASKSSETTINGS.LOCATOR_ID = SYSTEMTASKSSETTINGS.LOCATOR_ID.HL_BHKW_LOTEMP

@onready var loc_hi := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(locator_id_temp_high)
@onready var loc_lo := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(locator_id_temp_low)

const Q_BHKW := preload("uid://codiadaennr2i")
var parent : Q_BHKW

signal done

func _enter_tree() -> void:
	parent = get_parent()	
	parent.updated.connect(update_status)
	
func start_high() -> void:
	parent.set_temp(39.85)
	add_child(loc_hi)
	pass
	

func start_low() -> void:
	parent.set_temp(37.9)
	add_child(loc_lo)
	pass
	

func update_status() -> void:
	var temp = parent.temperature_gauge.current_temp
	if temp > 37.8 and temp < 39.8:
		done.emit()
	pass
