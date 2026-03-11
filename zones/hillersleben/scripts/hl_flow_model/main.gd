extends Node
const Simulation = preload("uid://bwr2uo7j6tybd")
const Overview = preload("uid://0pdeiee3huqx")

var sim : Simulation
@export var overview : PackedScene

func _ready() -> void:
	sim = Simulation.new()	
	add_child(sim)
	
	sim.set_speed(5.0)
	sim.start()
	
	#if overview:
		#var c = overview.instantiate()
		#add_child(c)
		#c.init(sim.cs, sim.es)
