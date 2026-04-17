extends Label3D

const FlowModel := preload("uid://novqlqgqjj6t")
const Simulation := preload("uid://b6alvcbiyby3g")


@export var flow_model : FlowModel = null
@export var container_id : FlowModel.Simulation.Containers.ID
@export var flow_units_m3s : float = 100.0

@onready var button : MachineToggleable = $MachineToggleable
@onready var xr_button : XRToolsInteractablePushbuttonGeneral = $PushButton
var _edge := Simulation.SimEdgeSource.new()

func _ready() -> void:
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	xr_button.button_pressed.connect(_on_on)
	xr_button.button_released.connect(_on_off)	
	
	_edge.set_throughput(flow_units_m3s)
	button.toggle(false)
	if flow_model:
		flow_model.sim.controller.register_edge(_edge)
	pass

func _on_on(...args) -> void:
	_edge.active = true	
	_edge.add_target(flow_model.sim.cs.LIST[container_id])
	pass
	
func _on_off(...args) -> void:
	_edge.active = false
	_edge.remove_targets()
	pass


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []    
	if flow_units_m3s < 0:
		warnings.append("Inflow must be bigger than 0.")
	
	return warnings
