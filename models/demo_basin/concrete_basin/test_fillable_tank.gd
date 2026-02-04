extends Node3D

@onready var cb : FillableTank = %concrete_basin

func _ready() -> void:
	cb.fill_level(0.2, 0.5)
	##
	await get_tree().create_timer(1.0).timeout
	cb.fill_level(0.9, 1)
	
	cb.set_water_bubbles_strength([0.0, 2.0, 0.0], 0.5)
	await get_tree().create_timer(5.0).timeout
	cb.set_water_bubbles_strength([2.0, 0.0, 0.0], 0.5)
	await get_tree().create_timer(5.0).timeout
	
	cb.set_water_bubbles_strength([0.0, 1.0, 0.0], 2.0)
	await get_tree().create_timer(1.0).timeout
	await get_tree().create_timer(6.0).timeout
	
	cb.add_water_bubbles_strength([1.0, 1.0], 1.0)
	await get_tree().create_timer(1.0).timeout
	cb.add_water_bubbles_strength([-1.0, 0.0], 1.0)
	await get_tree().create_timer(1.0).timeout
	cb.add_water_bubbles_strength([0.0, -1.0], 1.0)
	await get_tree().create_timer(1.0).timeout
	cb.add_water_bubbles_strength([1.0, 0.1], 2.0)
	
	
	pass
