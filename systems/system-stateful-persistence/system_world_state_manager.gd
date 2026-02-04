extends Node
#This manager should be created as either an Autoload or from a GameStateManager


#class_name WorldStateManager
const WorldStateRegistry := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistry
const WorldStateRegistryInterface := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterface
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils


var _zone_ids : Array[int] = []
var zone_registries: Dictionary[int, WorldStateRegistry] = {}
var zone_savepaths : Dictionary[int, String] = {}

var _registrants: Dictionary[WorldStateRegistryInterface, bool] = {} # In case someone registers before this is initialized


var savefolder : String

enum ERROR {EXISTS_NOT, SUCCESS}

#savefolder_name is the name of the save.
func _init(savefolder_name : String = "DEFAULT_TEST/", zone_ids : Array[int] = []) -> void:
	#Loads the registry from disk if possible.
	savefolder = SYSTEMSTATEFULPERSISTENCE_SETTINGS.SAVE_PATH.path_join(savefolder_name )
	Utils.ensure_directory_for_file(savefolder)
	
	#Debugging
	if zone_ids.is_empty() : 
		for i in SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.values():
			_zone_ids.append(i)
	else: _zone_ids = zone_ids
	
	for zone_id in _zone_ids:
		zone_registries[zone_id] = null
		zone_savepaths[zone_id] = get_savepath_id(zone_id)
		var _error := load_registry_from_path(zone_id, zone_savepaths[zone_id])
		#We dont care because a new register will get instantiated.
		

func _ready() -> void:
	var interfaces = get_tree().get_nodes_in_group(SYSTEMSTATEFULPERSISTENCE_SETTINGS.BASE_GROUP_IFACES)
	for interface in interfaces:
		if interface is WorldStateRegistryInterface:
			var iface : WorldStateRegistryInterface = interface
			_registrants[iface] = true #For some reason this is bugged
	initialize()

func get_savepath_id(zone_id : int) -> String:
	return  savefolder.path_join("%s.dat" % zone_id)

func initialize() -> void:
	for r : WorldStateRegistryInterface in _registrants.keys():
		register_interface(r, r.zone_register)
	
func register_interface(iface: WorldStateRegistryInterface, zone_id : int) -> void:
	assert(iface != null)
	_registrants[iface] = true
	var registry = zone_registries.get(zone_id, null)
	if registry == null:
		registry = WorldStateRegistry.new()
		zone_registries[zone_id] = registry #Hack
		zone_savepaths[zone_id] = get_savepath_id(zone_id)
	iface.bind_registry(registry) #Danger of changing zones and registers?
	iface.zone_register = zone_id

func get_zone_registry(zone_id: int) -> WorldStateRegistry:
	if not zone_registries.has(zone_id):		
		var ws := WorldStateRegistry.new()
		ws.meta["zone_id"] = zone_id
		zone_registries[zone_id] = ws
		
		for iface in _registrants:
			if iface.zone_register == zone_id:
				iface.integrate_with_registry(ws)
		
	return zone_registries[zone_id]

func save_all_registries() -> void:
	for zone_id in zone_registries.keys():
		var registry := zone_registries[zone_id]
		if registry == null:
			continue # Skip zones that haven’t been initialized
		
		var path : String = zone_savepaths.get(zone_id, null)
		if (path == null) or (path == ""):
			push_warning("No save path for zone %s" % zone_id)
			continue
		# Delegate saving to the registry itself
		await registry.save_to_disk(path)
		
		
func delete_all_registries() -> void:
	for zone_id in zone_registries.keys():
		var registry := zone_registries[zone_id]
		if registry == null:
			continue # Skip zones that haven’t been initialized
		
		var path : String = zone_savepaths.get(zone_id, null)
		if (path == null) or (path == ""):
			push_warning("No save path for zone %s" % zone_id)
			continue
		# Delegate saving to the registry itself
		await registry.delete_from_disk(path)


func load_registry_from_path(zone_id: int, path: String) -> ERROR:
	var registry : WorldStateRegistry = zone_registries.get(zone_id, null)
	if registry == null:
		registry = WorldStateRegistry.new()
		zone_registries[zone_id] = registry
	
	if FileAccess.file_exists(path):
		registry.load_from_disk(path)
	else:
		push_warning("Save file not found for zone %s: %s" % [zone_id, path])
		return ERROR.EXISTS_NOT
	return ERROR.SUCCESS
