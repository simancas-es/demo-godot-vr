extends Label3D


const FlowModel := preload("uid://novqlqgqjj6t")
const Simulation := preload("uid://b6alvcbiyby3g")

@export var flow_model : FlowModel = null
@export var flow_id : FlowModel.Simulation.Edges.ID
@onready var button : MachineToggleable = $MachineToggleable

func _ready() -> void:
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	button.toggle(true)
	pass

func _on_on(...args) -> void:
	flow_model.sim.remove_manual_throughput(flow_id)
	pass
	
func _on_off(...args) -> void:
	flow_model.sim.set_manual_throughput(flow_id, 0.0)
	pass
