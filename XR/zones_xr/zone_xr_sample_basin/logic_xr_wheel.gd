extends Node

@onready var wheel : XRToolsInteractableWheelGeneral = $".."
@onready var basinsystem : Node3D = $"../../ZoneObservatorio"

const ValveControllerStateful = preload("uid://smn8uss4al4c")
@onready var valve_controller : ValveControllerStateful = basinsystem.get_node("DemoConcreteBasin/ValveController")

func _ready() -> void:
	
	wheel.ready.connect(initialize)

func initialize() -> void:
	var valve_init_deg = valve_controller.state.valve_fraction*360*valve_controller.rotations_to_max
	wheel.hinge_position =  valve_init_deg #HACK
	#TODO: This breaks with persistence.
	wheel.hinge_moved.connect(on_valve_moved)
	
	pass

func on_valve_moved(angle : float) -> void:
	valve_controller.spin_to_target_deg(angle, true)
	pass
