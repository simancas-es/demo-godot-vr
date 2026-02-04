extends Node
##Controls a ValveRotating and a FillableTankController
##So that when we touch the valve, an animation happens (opening of circuit)
##and then the tank fills by using the controller.
##The valve has a left and a right side. Right side is local +X

#Stateful because the animation has to sync with the actual fraction

@export var valve : ENTITY_CATALOG.ValveRotating# = $FillingValve
@export var leftinter : Interaction# = $ValveLeftDirection
@export var rightinter : Interaction# = $ValveRightDirection

signal valve_changed(new_fraction: float)
@export var state: DEMO_BASIN.BasinState

@export var rotations_to_max : float = 2.0 #How many turnings of the wheel from min to max

@export_category("Poll Approach")
@export var min_throughput_m3s = -1.0 #Minimum means that it can suction
@export var max_throughput_m3s = 1.0

var current_throughput: float:
	get: 
		return min_throughput_m3s + state.valve_fraction * ( max_throughput_m3s - min_throughput_m3s)



var _min : float = 0.0
var _max : float = 1.0
var deg_per_fraction : float

enum STATE {AVAILABLE, SPINNING}
var current_state = STATE.AVAILABLE

enum ERROR { UNKNOWN, SUCCESS, FAIL}

func _ready() -> void:
	deg_per_fraction = 360 * rotations_to_max/ ( _max - _min)	
	#TODO: Checks and Errors
	leftinter.activated.connect(spin_to_left.bind()) #Ignore player
	rightinter.activated.connect(spin_to_right.bind())
	

func initialize_from_state() -> void:
	if state == null:
		push_error("ValveController initialized without state")
		return

	var init_turn_deg = (state.valve_fraction - 0.5) * rotations_to_max * 360
	await valve.rotate_wheel(init_turn_deg)

	
##Drain
func spin_to_left(...args) -> bool:
	if current_state == STATE.SPINNING:	return false
	current_state = STATE.SPINNING

	var new_fraction = min(_max, state.valve_fraction + +180.0/(rotations_to_max*360) )
	var degree_diff = (new_fraction - state.valve_fraction) * rotations_to_max*360
	
	await valve.rotate_wheel(degree_diff) #Cosmetic
	
	state.valve_fraction = clamp(new_fraction, _min, _max)
	valve_changed.emit(state.valve_fraction)
	
	current_state = STATE.AVAILABLE
	return true
	
#Fill
func spin_to_right(...args) -> bool:
	if current_state == STATE.SPINNING:	return false
	current_state = STATE.SPINNING
	
	var new_fraction = max(_min, state.valve_fraction + -180.0/(rotations_to_max*360) ) 
	var degree_diff = (new_fraction - state.valve_fraction) * rotations_to_max*360

	await valve.rotate_wheel(degree_diff) #Cosmetic
	
	state.valve_fraction = clamp(new_fraction, _min, _max)
	valve_changed.emit(state.valve_fraction)
	
	current_state = STATE.AVAILABLE
	return true

func spin_to_target(fraction : float) -> void:
	fraction = clamp(fraction, _min, _max)
	var diff = fraction - state.valve_fraction
	var diffdeg = diff * rotations_to_max * 360
	await valve.rotate_wheel(diffdeg)
	state.valve_fraction = fraction
	
