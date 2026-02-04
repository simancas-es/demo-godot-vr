extends Node
#Autoload class that has to be named InventoryResources
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation
const InventoryUtils := INVENTORY_UIDCLASSREF.InventoryUtils

var INFORMATION : Dictionary [INVENTORYSETTINGS.ID, InventoryObjectInformation] = {
}

func _init() -> void:
	#Initializes the INFORMATION database.
	for id in INVENTORYSETTINGS.ID.values():
		if id == INVENTORYSETTINGS.ID.INVALID: continue
		if not id in INVENTORYSETTINGS.INFORMATION_RESOURCES:
			push_error("Couldnt find %s in INVENTORYSETTINGS.INFORMATION_RESOURCES. Maybe you forgot to add a path?" % id)
			continue
		var path = INVENTORYSETTINGS.INFORMATION_RESOURCES[id]
		if not ResourceLoader.exists(path):
			if path.ends_with(".remap"): ##REMEMBER: Web export adds .remap to .tres files
				if not ResourceLoader.exists(path.trim(".remap")):
					push_error("Missing file %s for Inventory object %s!!" % [path, INVENTORYSETTINGS.ID.keys()[id]])
			else:
				push_error("Missing file %s for Inventory object %s!!" % [path, INVENTORYSETTINGS.ID.keys()[id]])
			continue
		var info : InventoryObjectInformation = load(path)
		info.init_values()
		INFORMATION[id] = info
		if not ResourceLoader.exists(info.inspect_translations_path):
			push_error("inspect_translations_path for %s is wrong: %s ." % [id, info.inspect_translations_path])
			continue
		info.inspect_translations = InventoryUtils.read_json(info.inspect_translations_path, info.inspect_translations_default)
	return

func get_info(id : INVENTORYSETTINGS.ID) -> InventoryObjectInformation:
	if not id in INFORMATION:
		push_error("Missing object id: %s !!!" % id)
		return null #Or default?
	return INFORMATION[id]

##Returns the INFORMATON dictionary to be used somewhere else. Not a copy.
func get_dictionary() -> Dictionary [INVENTORYSETTINGS.ID, InventoryObjectInformation]:
	return INFORMATION	
