extends Node3D
##NOTE: Exact same class as the stateful valve script. HACK. TODO: Harmonize demo valve for use with XR.
##Controls a ValveRotating and a FillableTankController
##So that when we touch the valve, an animation happens (opening of circuit)
##and then the tank fills by using the controller.
##The valve has a left and a right side. Right side is local +X

#Stateful because the animation has to sync with the actual fraction
class VALVESTATE: #HACK. Should be a global state that contains all valves.
	var valve_fraction: float = 0.5 # 0..1
	
	
@export var valve : ENTITY_CATALOG.ValveRotating# = $FillingValve
@export var leftinter : Interaction# = $ValveLeftDirection
@export var rightinter : Interaction# = $ValveRightDirection
@export var rotation_velocity_degs = 180.0 #Degrees per second for left and right interactions
@export var deg_rotation_per_interaction = 90.0 #Degrees per interaction

signal valve_changed(new_fraction: float)
var state: VALVESTATE = VALVESTATE.new()

@export var rotations_to_max : float = 2.0 #How many turnings of the wheel from min to max

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

func initialize_from_state(is_instant : bool = false, signal_change : bool = true) -> void:
	if state == null:
		push_error("ValveController initialized without state")
		return
	
	var init_turn_deg = (state.valve_fraction - 0.5) * rotations_to_max * 360
	if not is_instant:
		await valve.rotate_wheel_target(init_turn_deg, rotation_velocity_degs)
	else:
		await valve.rotate_wheel_target(init_turn_deg, -1)
	if signal_change: valve_changed.emit(state.valve_fraction)
		
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

func apply_rotation_absolute(target_radians: float, is_instant: bool = false) -> void:
	if current_state == STATE.SPINNING:
		return
	
	# Convert input to degrees
	var target_degrees = rad_to_deg(target_radians)
	
	# Convert to fraction of full range
	var target_fraction = target_degrees / (rotations_to_max * 360.0)
	
	# Clamp target fraction
	var new_fraction = clamp(
		target_fraction,
		_min,
		_max
	)
	
	# Convert clamped fraction back to absolute degrees
	var final_degrees = new_fraction * rotations_to_max * 360.0
	
	var deg_per_s: float
	if is_instant:
		deg_per_s = rotation_velocity_degs
	else:
		deg_per_s = -1.0
	
	current_state = STATE.SPINNING
	
	await valve.rotate_wheel_target(final_degrees, deg_per_s)
	
	state.valve_fraction = new_fraction
	valve_changed.emit(state.valve_fraction)
	
	current_state = STATE.AVAILABLE

##Drain
func spin_to_left(...args) -> bool:
	apply_rotation_delta(deg_to_rad(deg_rotation_per_interaction), rotation_velocity_degs)
	return true
	
#Fill
func spin_to_right(...args) -> bool:
	apply_rotation_delta(deg_to_rad(-deg_rotation_per_interaction), rotation_velocity_degs)
	return true

func spin_to_target_deg(target_deg: float, is_instant : bool = false) -> void:
	# Total mechanical range in degrees
	var total_deg = rotations_to_max * 360.0
	
	# Clamp requested angle to physical limits
	target_deg = clamp(target_deg, 0.0, total_deg)
	
	# Current angle derived from fraction
	#var current_deg = state.valve_fraction * total_deg
	apply_rotation_absolute(deg_to_rad(target_deg), is_instant)
