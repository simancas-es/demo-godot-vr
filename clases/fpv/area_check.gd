extends Area3D
class_name FPVAreaController
#What generally touches the player
#And what the player generally touches

signal killed_by(bywhat : String)
##TODO refactor this death with a bit more information for statistics
func kill(bywhat : String) -> void:
	killed_by.emit(bywhat)
	pass
