extends PanelContainer
#class_name InspectPanel
const ItemInspect := INVENTORY_UIDCLASSREF.ItemInspect
const Inventory := INVENTORY_UIDCLASSREF.Inventory
const InventoryGrid := INVENTORY_UIDCLASSREF.InventoryGrid


@onready var iteminspect : ItemInspect = %ItemInspect
@onready var inspecttext = %InspectText
var inventory : Inventory = null

@onready var grid : InventoryGrid = %InventoryGrid


func _ready() -> void:
	if not grid.focused.is_connected(on_grid_focus_change):
		grid.focused.connect(on_grid_focus_change)
	pass


func init_inspect(inventory_ : Inventory) -> void:
	inventory = inventory_
	pass
func clear_inspect() -> void:
	iteminspect.init(null)
	
##Shows inventory object at index idx.
func show_object_at_idx(idx : int) -> void:
	var info = inventory.get_obj_info_from(idx)
	iteminspect.show_object(info)
	inspecttext.init(info)
	pass

##Detects the change in grid focus and updates the current item inspect model
func on_grid_focus_change(idx : int) -> void:
	show_object_at_idx(idx)

func process_physics(delta : float) -> void:
	iteminspect.process_physics(delta)
	
func process_frame(delta : float) -> void:
	iteminspect.process_frame(delta)


##TODO
#func _notification(what: int) -> void:
	#match what:
		#NOTIFICATION_TRANSLATION_CHANGED:
			#pass
