extends Node
class_name INVENTORYSETTINGS

const INSPECT_TRANSLATIONS_TEMPLATE = "res://systems/system-inventory/inventory-backend/inspect_translations_template.json"


enum CLASS {
	DEFAULT,
	KEY, ##Acts as a key. Main interaction is to lock
}
#Manual definition for each item
enum ID {
	INVALID = -1,
	BEAKER = 0,
	DUNGEON_KEYS = 1,
	BUBBLE_DIFFUSER,
	
	
	#Hillersleben
	WIRE,
	BEAKER_FILLED,
	
}

##ID, InventoryObjectInformation path. #Check inventory_test.gd
const INFORMATION_RESOURCES : Dictionary[ID, String] = {
	ID.BEAKER : "uid://ciatc0fbcj3tq",
	ID.DUNGEON_KEYS : "uid://232qnmcsix10",	
	ID.BUBBLE_DIFFUSER : "res://models/inventory_objects/demo_aerator/aerator_head.tres",
	ID.WIRE : "uid://df31vkqjk6b40",
	ID.BEAKER_FILLED : "res://content/inv_objects/beaker_filled/beaker_filled.tres",
}
