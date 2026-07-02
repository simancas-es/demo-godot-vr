extends Node

const VALVE := preload("uid://l02y45ybnafb")
const TEMPGAUGE := preload("uid://bj2qmx7od8tdl")

@export var valve : VALVE 
@export var temperature_gauge : TEMPGAUGE
signal updated

@export var temp_max_c = 50.0
@export var temp_min_c = 20.0


func _ready() -> void:
	valve.valve_changed.connect(_on_new_fraction)
	
func _on_new_fraction(fraction : float) -> void:
	var new_temp = frac_to_temp(fraction)
	temperature_gauge.set_temperature(new_temp)
	_update_status()


func set_temp(temp : float) -> void:
	temperature_gauge.set_temperature(temp)
	set_valve_to_temp(temp)

func _update_status() -> void:
	#update text
	var temp = temperature_gauge.current_temp
	updated.emit()
	
		
## Relates Temperature depending on valve fraction opening
func frac_to_temp(fraction : float) -> float:
	var _temp = temp_min_c + (temp_max_c - temp_min_c) * fraction
	return _temp
	
func temp_to_fraction(temp : float) -> float:
	#inverse of function above.
	var _fraction = (temp - temp_min_c)/ (temp_max_c - temp_min_c)
	return _fraction

func set_valve_to_temp(temp : float) -> void:
	var _fr = temp_to_fraction(temp)
	valve.state.valve_fraction = _fr
	valve.initialize_from_state() #HACK
	_update_status()
