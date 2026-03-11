extends Node
#Vorübergehend
const SimulationMain := preload("uid://novqlqgqjj6t")

@export var simulationmain : SimulationMain = null
@export var subviewport : SubViewport


func _ready() -> void:
	init()	
	pass

func init() -> void:
	for c in subviewport.get_children():
		c.queue_free()
	subviewport.add_child(simulationmain.overview)
	simulationmain.overview.start() #This is shakey and fails for some obscure reason sometimes.
