extends Node
const Simulation = preload("uid://bwr2uo7j6tybd")
const Overview = preload("uid://0pdeiee3huqx")

var sim : Simulation
@export var overview_scene : PackedScene
var overview : Overview

func _init() -> void:
	sim = Simulation.new()	
	
func _ready() -> void:	
	add_child(sim)	
	sim.set_speed(5.0)
	sim.start()
	
	if overview_scene:
		overview = overview_scene.instantiate()
		#add_child(c)
		overview.init(sim.cs, sim.es)
