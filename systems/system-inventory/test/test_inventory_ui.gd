extends Control
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation
const Inventory := INVENTORY_UIDCLASSREF.Inventory
const InventoryUI := INVENTORY_UIDCLASSREF.InventoryUI

const path_main_ui : String = "../inventory-ui/inventory_ui.tscn"

func generate_autoload_dict() -> Dictionary[INVENTORYSETTINGS.ID, InventoryObjectInformation]:
	return InventoryResources.get_dictionary() #Global

func generate_info_1() -> Dictionary[INVENTORYSETTINGS.ID, InventoryObjectInformation]:
	var inf : Dictionary[INVENTORYSETTINGS.ID, InventoryObjectInformation] = {}
	var type1 = InventoryObjectInformation.new()
	type1.ID = 2
	type1.STACK_MAX = 3
	type1.qty_string = InventoryObjectInformation.MODE_QTY.NUMBER
	
	var type2 = InventoryObjectInformation.new()
	type2.ID = 3
	type2.STACK_MAX = 10
	type2.qty_string = InventoryObjectInformation.MODE_QTY.NOTHING
	
	inf[2] = type1
	inf[3] = type2
	
	return inf
	

func _ready() -> void:
	
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_OPEN))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_SLOT_LEFT))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_SLOT_RIGHT))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_DESELECT))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_ESCAPE))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_LEFT))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_RIGHT))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_DOWN))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_UP))
	assert( InputMap.has_action(INVENTORYUISETTINGS.ACTION_INTERACT))
	
	
	#Manual checks
	#ui()
	#grid()
	item_inspect()
	pass


func ui():
	var info = generate_info_1()
	var iv = Inventory.new(5, info)
	
	var invui = preload(path_main_ui). instantiate().with_inventory(iv)
	
	iv.add_item(2, 3)	
	add_child(invui)
	
func grid():
	var info = generate_info_1()
	var iv = Inventory.new(5, info)
	var err : Inventory.ERROR
	
	var invui = preload(path_main_ui).instantiate().with_inventory(iv)
	add_child(invui)

	#assert( invui.bottombar != null)
	#assert( invui.gridinv != null)
	
	#iv.updated.connect(print.bind("<- Updated Inventory idx"))
	
	iv.add_item(2,3)
	iv.add_item(3,1)
		
	err = iv.remove_at_index(1,999)
	assert( err == Inventory.ERROR.UNAVAILABLE_QTY)
	
	err = iv.remove_at_index(1,1)
	assert (err == Inventory.ERROR.SUCCESS)
	
	assert(iv.add_at_index(3, 3, 1) == Inventory.ERROR.SUCCESS)
	assert(iv.add_at_index(4, 2, 2) == Inventory.ERROR.SUCCESS)


func item_inspect():
	var info = generate_autoload_dict()
	var iv = Inventory.new(5, info)
	var invui : InventoryUI = preload(path_main_ui). instantiate().with_inventory(iv)
	
	#ControllerManager.enable_ctrls(true)
	add_child(invui)
	iv.add_at_index(0, INVENTORYSETTINGS.ID.BEAKER, 4)
	iv.add_at_index(1, INVENTORYSETTINGS.ID.DUNGEON_KEYS, 1)

	invui.activate(true)

	invui.inventory_action_open.connect(invui.open_full)
