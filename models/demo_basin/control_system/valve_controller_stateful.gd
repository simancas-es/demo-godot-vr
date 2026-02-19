extends Node
##Controls a ValveRotating and a FillableTankController
##So that when we touch the valve, an animation happens (opening of circuit)
##and then the tank fills by using the controller.
##The valve has a left and a right side. Right side is local +X

#Stateful because the animation has to sync with the actual fraction

@export var valve : ENTITY_CATALOG.ValveRotating# = $FillingValve
@export var leftinter : Interaction# = $ValveLeftDirection
@export var rightinter : Interaction# = $ValveRightDirection
@export var rotation_velocity_degs = 180.0 #Degrees per second for left and right interactions

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
	#initialize_from_state()

func initialize_from_state() -> void:
	if state == null:
		push_error("ValveController initialized without state")
		return

	var init_turn_deg = (state.valve_fraction - 0.5) * rotations_to_max * 360
	await valve.rotate_wheel(init_turn_deg, rotation_velocity_degs)

func apply_rotation_delta(delta_radians: float, is_instant : bool = false) -> void:
	if current_state == STATE.SPINNING:
		return
	
	var delta_degrees = rad_to_deg(delta_radians)
	var delta_fraction = delta_degrees / (rotations_to_max * 360.0)
	
	var new_fraction = clamp(
		state.valve_fraction + delta_fraction,
		_min,
		_max
	)
	
	var clamped_delta_fraction = new_fraction - state.valve_fraction
	var clamped_delta_degrees = clamped_delta_fraction * rotations_to_max * 360.0
	
	var deg_per_s : float
	if is_instant: deg_per_s = rotation_velocity_degs
	else: deg_per_s = -1.0
	
	current_state = STATE.SPINNING
	await valve.rotate_wheel(clamped_delta_degrees, deg_per_s)
	
	state.valve_fraction = new_fraction
	valve_changed.emit(state.valve_fraction)
	current_state = STATE.AVAILABLE
	
##Drain
func spin_to_left(...args) -> bool:
	apply_rotation_delta(deg_to_rad(180.0), rotation_velocity_degs)
	return true
	
#Fill
func spin_to_right(...args) -> bool:
	apply_rotation_delta(deg_to_rad(-180.0), rotation_velocity_degs)
	return true

func spin_to_target_deg(target_deg: float, is_instant : bool = false) -> void:
	# Total mechanical range in degrees
	var total_deg = rotations_to_max * 360.0
	
	# Clamp requested angle to physical limits
	target_deg = clamp(target_deg, 0.0, total_deg)
	
	# Current angle derived from fraction
	var current_deg = state.valve_fraction * total_deg
	
	# Compute delta
	var delta_deg = target_deg - current_deg
	
	# Convert to radians and apply
	apply_rotation_delta(deg_to_rad(delta_deg), is_instant)
