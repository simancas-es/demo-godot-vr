extends Area3D

signal touched_water(type)

func _ready() -> void:
	self.area_entered.connect(_on_area_enter)
	
func _on_area_enter(area : Area3D) -> void:
	if	area.is_in_group("water_vkb"): #HACK
		touched_water.emit("vkb")
	elif	area.is_in_group("water_bb"):
		touched_water.emit("bb")
	elif	area.is_in_group("water_nkb"):
		touched_water.emit("nkb")
	elif	area.is_in_group("water_msb"):
		touched_water.emit("msb")
	
	pass
