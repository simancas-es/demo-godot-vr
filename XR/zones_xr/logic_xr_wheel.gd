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
	print("Wheel pos: gen %s real %s. min max: (%s, %s). ValveInitDeg %s. ValveFraction %s" % [
		 wheel.hinge_position, wheel.wheel.hinge_position, wheel.wheel.hinge_limit_min, wheel.wheel.hinge_limit_max,
		 valve_init_deg, valve_controller.state.valve_fraction])
	wheel.hinge_moved.connect(on_valve_moved)
	
	pass

func on_valve_moved(angle : float) -> void:
	valve_controller.spin_to_target_deg(angle, true)
	print("Hinge angle: %s .ValveControllerFraction %s: " % [angle, valve_controller.state.valve_fraction])
	pass
