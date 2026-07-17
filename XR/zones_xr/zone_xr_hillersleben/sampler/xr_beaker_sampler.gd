extends "res://XR/scenes/interactables/objects/item_pickable.gd"

const SAMPLER_AREA := preload("uid://da5ajj1xsgk0e")
@onready var area : Area3D = $Area3D_Beaker

func _ready():
	area.touched_water.connect(_on_water_enter)
	

func _on_water_enter(type : String) -> void:
	match type:
		"vkb":
			pass
		
		"bb":
			pass
		
		"msb":
			pass
		
		"nkb":
			pass
		
	pass
