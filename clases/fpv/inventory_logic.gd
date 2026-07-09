extends Node

#Depending on selected object

var inventory : INVENTORY_UIDCLASSREF.Inventory
var interaction_logic : FPVInteractionLogic

var parent : FPV

func _ready() -> void:
	parent = get_parent()
	parent.ready.connect(init)
	

func init() -> void:
	inventory = parent.inventory
	interaction_logic = parent.interaction_logic 
	
	inventory.changed_currently_selected.connect(_on_new_selected)
	

func _on_new_selected() -> void:
	var obj : INVENTORY_UIDCLASSREF.InventoryObjectInformation = inventory.get_selected_obj_info()
	if obj != null:
		#Effects...
		interaction_logic.raycast_center.target_position = Vector3(0, 0, -obj.INTERACT_DISTANCE)
	else:
		interaction_logic.raycast_center.target_position = Vector3(0, 0, -1.5) #TODO: better defaults
			
	pass
