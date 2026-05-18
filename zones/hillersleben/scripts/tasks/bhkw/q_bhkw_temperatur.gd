extends Node3D

const VALVE := preload("uid://cp2pufctmk3wr")
const TEMPGAUGE := preload("uid://ywpyc23dbiat")
const LIGHT := preload("uid://bjn6ld6vbr26b")

@onready var valve_vorlauf : VALVE = $ValveStructure
@onready var temperature_gauge : TEMPGAUGE = $TemperatureGauge
@onready var info_temp: Label3D = $info_display/sludge_temp
@onready var info_status : Label3D = $info_display/sludge_status
@onready var info_light : LIGHT = $info_light

##Increase or reduce temperature as we move the valve around.
const status_ok : String = "STATUS: OK"
const status_warning : String = "STATUS: WARNING!"
const status_critical : String = "STATUS: CRITICAL!"

func _ready() -> void:
	valve_vorlauf.valve_changed.connect(_on_new_fraction)
	_on_new_fraction(valve_vorlauf.state.valve_fraction)
	set_valve_to_temp(39.7)
	temperature_gauge.set_temperature(39.7)
	
func _on_new_fraction(fraction : float) -> void:
	var new_temp = frac_to_temp(fraction)
	temperature_gauge.set_temperature(new_temp)
	_update_status()


func _update_status() -> void:
	#update text
	info_temp.text = "%.1f°C" % temperature_gauge.current_temp
	var temp = temperature_gauge.current_temp
	if temp > 40.0:
		info_status.text = tr(status_critical) # Add effect?
		info_light.change_color(Color(1, 0.0, 0, 1.0))
	elif temp > 39.7:
		info_status.text = tr(status_warning) # Add effect?
		info_light.change_color(Color(1, 1.0, 0, 1.0))
	elif temp < 37.8:
		info_status.text = tr(status_critical)
		info_light.change_color(Color(1, 0.0, 0, 1.0))
	elif temp < 38.0:
		info_status.text = tr(status_warning)
		info_light.change_color(Color(1, 1.0, 0, 1.0))
	
	else:
		info_status.text = tr(status_ok)
		info_light.change_color(Color(0, 1.0, 0, 1.0))
		
	
		
## Relates Temperature depending on valve fraction opening
func frac_to_temp(fraction : float) -> float:
	#fraction 0(closed) = 30 degrees
	#fraction 1(open) = 43 degrees	
	var _temp = 30.0 + (43.0 - 30.0) * fraction
	return _temp
	
func temp_to_fraction(temp : float) -> float:
	#inverse of function above.
	var _fraction = (temp - 30.0)/ ( 43.0 - 30.0)
	return _fraction

func set_valve_to_temp(temp : float) -> void:
	var _fr = temp_to_fraction(temp)
	valve_vorlauf.state.valve_fraction = _fr
	valve_vorlauf.initialize_from_state() #HACK
	_update_status()
	
	
	
