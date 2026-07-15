extends Node

const SIM := preload("uid://novqlqgqjj6t")

@onready var parent : SIM = get_parent()


func _ready() -> void:
	parent.sim.cs.bb1.sc.fill(1.0)
	parent.sim.cs.bb2.sc.fill(1.0)
