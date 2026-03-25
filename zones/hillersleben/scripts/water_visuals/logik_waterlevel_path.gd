extends Path3D
## The first and last points of the curve represent the positions of the Meshplane
## For vertical movements the curve should be just two points vertically aligned
## The fraction of the curve is calculated from the volume of the container from 0 to max
const FlowModel := preload("uid://novqlqgqjj6t")
const Simulation := preload("uid://b6alvcbiyby3g")

@export var meshplane : Node3D =  null
@export var flow_model : FlowModel = null
@export var container_id : FlowModel.Simulation.Containers.ID
@export var fraction_to_disappear : float = 0.02 ## make the mesh invisible at fraction height

@onready var pathfollow3d : PathFollow3D = get_children()[0]


var container : Simulation.SimContainer

func _ready() -> void:
	container = flow_model.sim.cs.LIST[container_id]
	on_update()
	flow_model.sim.controller.updated.connect(on_update)
	pass
	
func on_update() -> void:
	var vol = container.get_volume("water")
	var fraction = (vol/container.max_volume_m3)
	pathfollow3d.progress_ratio = fraction
	meshplane.global_position = pathfollow3d.global_position
	if fraction < fraction_to_disappear : meshplane.visible = false
	else: meshplane.visible = true
	
	pass

	

	
	
	
