extends Node

@onready var wheel : XRToolsInteractableWheelGeneral = $".." #parent
@export var base_root : Node3D 

const VALVECONTROLLER = preload("uid://cp2pufctmk3wr")
@export var unique_name_valve : String 
@onready var _valve_controller : VALVECONTROLLER = base_root.find_child(unique_name_valve)

@onready var _debug_label : Label3D = $"../debug-wheel"
@export var debug : bool = false

func _ready() -> void:	
	wheel.ready.connect(initialize)
	wheel.hinge_moved.connect(on_wheel_moved)

func initialize() -> void:
	var vc : Array[Node] = base_root.find_children(unique_name_valve, "", true)
	if vc.size() > 1:
		push_error("More than one valve with the same name!!")
		return
	if vc.size() == 1:
		_valve_controller = vc[0]
	if vc == null:
		push_error("Missing valve or valve name!!")
		return
	
	_match_wheel_to_valve()
	_valve_controller.valve_changed.connect(on_valve_changed)
	
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
	_valve_controller.state.valve_fraction = (1 - fraction)
	_valve_controller.initialize_from_state(true, true)
	pass

func _match_wheel_to_valve() -> void:
	#match wheel to valve
	if not _valve_controller: return
	var _fr = _valve_controller.state.valve_fraction
	var angle = lerp(wheel.hinge_limit_min, wheel.hinge_limit_max, 1 - _fr)
	wheel.wheel.hinge_position = angle
	pass
	
