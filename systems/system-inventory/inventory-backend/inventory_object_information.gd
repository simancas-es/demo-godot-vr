extends Resource
#class_name InventoryObjectInformation

@export var ID : INVENTORYSETTINGS.ID ##Unique identifier
@export var CLASS : INVENTORYSETTINGS.CLASS = INVENTORYSETTINGS.CLASS.DEFAULT
@export var STACK_MAX : int = 1 ##Maximum number of items in stack
@export var SEPARABLE : bool = false ##Whether it can be separated into stacks
@export var DISAPPEARS_AT_0 : bool = false #Whether it disappears if count is 0
@export var INTERACT_DISTANCE : float = 1.5 #Usable at X or less raycast meters 
#TODO combinations
@export var texture : Texture2D = null ##TODO Tool to just take picture from 3D
@export var world_model : PackedScene = null ##Model used when generating or previewing the world pickup.
@export var inspect_model : PackedScene = null ##Model for the Item Inspector. GLTF or Node3D scene.
@export var hint_text : String = "" ##Editor-authored default hint text for generated pickups or UI.

const inspect_translations_default = INVENTORYSETTINGS.INSPECT_TRANSLATIONS_TEMPLATE
@export_file("*.json") var inspect_translations_path = "" ##File with item inspect desc in format "xx":...
var inspect_translations : Dictionary = {} #"en":{"name":...,"description":...}

enum MODE_QTY {
	NUMBER,
	NOTHING,
	DASH
}
@export var qty_string : MODE_QTY = MODE_QTY.NUMBER

func init_values() -> void:
	#If inspect_translations_path is empty, check if there is a file with this same name but ending in .json
	if not FileAccess.file_exists(self.inspect_translations_path):
		var tres_path = get_path()  
		var json_path = tres_path.get_base_dir() + "/" + tres_path.get_file().get_basename() + ".json"
		if FileAccess.file_exists(json_path):
			self.inspect_translations_path = json_path
			push_warning("Auto-assigned inspect_translations_path:", self.inspect_translations_path)
		else:
			push_error("No JSON found matching path: %s for resource: %s" % [self.inspect_translations_path, tres_path])

##Returns the qty String which may be 1, empty, or -
func get_qty_str(qty : int) -> String:
	match qty_string:
		MODE_QTY.NUMBER: return str(qty)
		MODE_QTY.NOTHING: return ""
		MODE_QTY.DASH : return "-"
	return str(qty)
	
func get_translated_name(locale : String) -> String:
	if locale in inspect_translations:
		return inspect_translations[locale]["name"]
	return "???"
