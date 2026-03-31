extends Label3D

const FlowModel := preload("uid://novqlqgqjj6t")
const Simulation := preload("uid://b6alvcbiyby3g")


@export var flow_model : FlowModel = null
@export var container_id : FlowModel.Simulation.Containers.ID
@export var extraction_units_m3s : float = 100.0 # must be positive

@onready var button : MachineToggleable = $MachineToggleable

var _edge := Simulation.SimEdge.new()
var _empty_void := Simulation.SimContainer.new()

func _ready() -> void:
	_empty_void.infinite_capacity = true
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	_edge.set_throughput(extraction_units_m3s)	
	_edge.source = flow_model.sim.cs.LIST[container_id]
	
	button.toggle(false)
	if flow_model:
		flow_model.sim.controller.register_edge(_edge)
		flow_model.sim.controller.register_container(_empty_void)
	pass

func _on_on(...args) -> void:
	_edge.active = true
	_edge.add_target(_empty_void)
	pass
	
func _on_off(...args) -> void:
	_edge.active = false	
	_edge.remove_targets()
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []    
	if extraction_units_m3s < 0:
		warnings.append("Extraction must be bigger than 0.")
	
	return warnings
