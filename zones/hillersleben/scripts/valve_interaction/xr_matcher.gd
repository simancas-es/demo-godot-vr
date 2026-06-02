extends Node

#Generalized copy of the bhkw control valve.

@onready var wheel : XRToolsInteractableWheelGeneral = $"../WheelGeneral"
@export var base_root : Node3D 

const VALVECONTROLLER = preload("uid://cp2pufctmk3wr")
@onready var _valve_controller : VALVECONTROLLER = $".."  #parent

var _root : GameRoot

func _ready() -> void:	
	wheel.hinge_limit_min = rad_to_deg(_valve_controller.rotations_to_max/2 * (-TAU) )
	wheel.hinge_limit_max = rad_to_deg(_valve_controller.rotations_to_max/2 * (+TAU) )
	
	_root = get_tree().current_scene
	_root.updated.connect(apply_xr_check)
	
	wheel.ready.connect(initialize)
	wheel.hinge_moved.connect(on_wheel_moved)

func initialize() -> void:
	if _valve_controller == null:
		push_error("Missing valve!")
		return
	
	_match_wheel_to_valve()
	_valve_controller.valve_changed.connect(on_valve_changed)
	
	pass
	
func apply_xr_check() -> void:
	if _root is GameRoot:
		if not _root.is_xr():
			wheel.queue_free();
			self.queue_free()
			return
	pass
	
#If valve moves for some reason, wheel has to react
func on_valve_changed(new_fraction : float) -> void:
	if wheel.wheel.is_processing():
		return #HACK
	_match_wheel_to_valve()
	pass
	
func on_wheel_moved(angle : float) -> void:
	if not _valve_controller: return
	var fraction = inverse_lerp(wheel.hinge_limit_min, wheel.hinge_limit_max, angle) 
	_valve_controller.state.valve_fraction = fraction
	_valve_controller.initialize_from_state(true, true)
	pass

func _match_wheel_to_valve() -> void:
	#match wheel to valve
	if not _valve_controller: return
	var _fr = _valve_controller.state.valve_fraction
	var angle = lerp(wheel.hinge_limit_min, wheel.hinge_limit_max, _fr)
	wheel.wheel.hinge_position = angle
	pass
	
