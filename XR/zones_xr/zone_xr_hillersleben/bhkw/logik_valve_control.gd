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
	_valve_controller.valve_changed.connect(on_valve_changed)

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
	
	#HACK to make this work properly. TODO: create a coupled item for VR and KBM
	var valve_init_deg = (1 - _valve_controller.state.valve_fraction)*360*_valve_controller.rotations_to_max
	wheel.wheel.move_hinge(deg_to_rad(valve_init_deg), false)
	#TODO: This breaks with persistence.
	wheel.hinge_moved.connect(on_wheel_moved)
	
	pass

#If valve moves for some reason, wheel has to react
func on_valve_changed(new_fraction : float) -> void:
	if wheel.wheel.is_processing():
		return #HACK
	var angle = lerp(wheel.hinge_limit_min, wheel.hinge_limit_max, new_fraction)
	wheel.wheel.move_hinge(deg_to_rad(angle), false)
	pass
	
func on_wheel_moved(angle : float) -> void:
	if not _valve_controller: return
	var fraction = angle/(wheel.hinge_limit_max - wheel.hinge_limit_min + 0.0001) 
	_valve_controller.state.valve_fraction = (1 - fraction)
	_valve_controller.initialize_from_state(true, true)
	pass
	
func _process(delta: float) -> void:
	_debug_label.visible = debug
	if debug:
		_debug_label.text = "W_rot: %0.2f, V_rot: %0.2f, W_pos : %0.2f" % [wheel.get_hinge_rotation().x, _valve_controller.valve.wheel.rotation.y, deg_to_rad(wheel.wheel._hinge_position_rad)]
