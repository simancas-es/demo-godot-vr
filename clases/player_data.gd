extends Node
class_name PlayerData
const Inventory := INVENTORY_UIDCLASSREF.Inventory

var gc : ControllerBase
var inventory : Inventory

func _init(gc_ : ControllerBase, inventory_ : Inventory) -> void:
	gc = gc_
	inventory = inventory_

func get_inventory() -> Inventory:
	return inventory
	
func get_controller() -> ControllerBase:
	return gc
	
	
