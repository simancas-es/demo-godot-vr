extends Node
#class_name InventoryObject

const InventoryObject := INVENTORY_UIDCLASSREF.InventoryObject
#Base class
##Logic for inventory objects.
var id : INVENTORYSETTINGS.ID
var qty : int

func _init(id_ : INVENTORYSETTINGS.ID, qty_ : int) -> void:
	id = id_
	qty = qty_
	
	
func get_duplicate() -> InventoryObject:
	var obj = InventoryObject.new(id, qty)
	return obj



	
