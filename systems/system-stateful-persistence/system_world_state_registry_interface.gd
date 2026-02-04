extends Node
class_name StatefulPersistenceInterface
const WorldStateRegistry := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistry
const WorldStateRegistryInterface := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterface
const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils


var world_state_registry : WorldStateRegistry
@export var world_id: String = "unknown_id"
@export var zone_register : SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES = SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.UNKNOWN

func _init() -> void:
	world_state_registry = WorldStateRegistry.new()
	pass
	
func _ready() -> void:
	add_to_group(SYSTEMSTATEFULPERSISTENCE_SETTINGS.BASE_GROUP_IFACES)
	register_by(zone_register)
		
func bind_registry(registry: WorldStateRegistry) -> void:
	if registry == null : return
	if registry != world_state_registry:
		world_state_registry.delete(self.world_id)
		world_state_registry = registry
	
func get_data() -> Dictionary:
	if world_state_registry == null:
		push_error("Missing world state registry at node %s !!" % self.get_path())
		return {}
	return world_state_registry.states.get(world_id, {})

func save_data(data: Dictionary) -> void:
	if world_state_registry == null:
		push_error("Missing world state registry at node %s !!" % self.get_path())
	world_state_registry.states[world_id] = data

static func get_world_state_component(node: Node, unique_id: String = "") -> WorldStateRegistryInterface:
	for c in node.get_children():
		if c is WorldStateRegistryInterface: #TODO: What happens if there is more than one
			if unique_id != "":
				c.world_id = unique_id #Takes whatever Interface it has and converts it to its own.
			return c

	var instance := WorldStateRegistryInterface.new()
	instance.world_id = unique_id

	node.add_child(instance)
	return instance
	
func register_by(zone_id : SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES) -> void:
	#Get Manager
	var manager : WorldStateManager = null
	if Engine.has_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME):
		manager = Engine.get_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	
	if manager:
		manager.register_interface(self, zone_id)
		##BUG: Allows duplicates, eventhough the Manager only registers one in the dictionary
			
	else:
		push_warning("Missing WorldStatemanager!!")
		#Create a temporary register.
		
	pass

				
func integrate_with_registry(registry: WorldStateRegistry) -> void:
	if registry == null:
		return
	if world_state_registry == null:
		world_state_registry = registry
		return
	if world_state_registry == registry:
		return
	# Merge temporary state
	for key in world_state_registry.states.keys():
		registry.states[key] = world_state_registry.states[key]
	world_state_registry = registry
	
