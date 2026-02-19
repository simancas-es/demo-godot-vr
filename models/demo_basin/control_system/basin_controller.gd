extends Node

var state: DEMO_BASIN.BasinState = DEMO_BASIN.BasinState.new()
var system: DEMO_BASIN.BasinSystem = DEMO_BASIN.BasinSystem.new()
@export var valve_controller: DEMO_BASIN.ValveController
@export var blower1_controller: DEMO_BASIN.BlowerController
@export var blower2_controller: DEMO_BASIN.BlowerController
@export var tank_controller: DEMO_BASIN.TankController

@onready var aeratorquest : DEMO_BASIN.AeratorQuest = $AeratorQuestController
@onready var basindeath : DEMO_BASIN.BasinDeath = $BasinDeath

var persistence := StatefulPersistenceInterfaceSimpleAttributes.new()

signal updated

func _init() -> void:
	# Inject state
	system.state = state

	pass
	
func _ready() -> void:
	valve_controller.state = state
	blower1_controller.state = state
	blower2_controller.state = state
	tank_controller.state = state
	
	system.register_inflow_controller(valve_controller)
	
	aeratorquest.state = state
	basindeath.state = state
	
	
	
	#Persistence
	persistence.saved_attributes = ["water_volume", "max_volume", "valve_fraction", "blower_target_on", "safety_blower_volume_fraction", "aerator_ok"]
	persistence.target = state
	add_child(persistence)
	
	
	valve_controller.initialize_from_state()
	
	pass

#Poll Approach to filling
var step_time_s : float = 0.3
var _time_s : float = step_time_s
func _process(delta: float) -> void:
	_time_s -= delta
	if _time_s <= 0.0:
		process(step_time_s)		
		_time_s = step_time_s
		
func process(delta: float) -> void:
	# Step system first
	system.step(delta)

	# Sync actuators
	blower1_controller.sync_with_state()
	blower2_controller.sync_with_state()
	tank_controller.sync_fill()
	tank_controller.sync_aeration()

	updated.emit()
	persistence.poll_data()
	
	
