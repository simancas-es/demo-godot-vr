extends Node
const WorldStateRegistryInterface := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterface
const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils


class PersistentDoor extends Node3D:
	@export var world_state_id: String = "DOOR_1"
	@export var zone_id: int = 1

	enum STATUS { CLOSED, OPEN }

	var status: STATUS = STATUS.CLOSED
	@onready var state: WorldStateRegistryInterface = WorldStateRegistryInterface.get_world_state_component(self, world_state_id)
	func _ready():
		_load_state()
		
	func _load_state():
		state.register_by(zone_id)
		var data := state.get_data()
		var data_status = data.get("status", "CLOSED")
		status = Utils.string_to_enum(STATUS, data_status)
		
	func _save_state():
		state.save_data({"status": Utils.enum_to_string(STATUS, status)})
		
	func open():
		status = STATUS.OPEN
		_save_state()
	func close():
		status = STATUS.CLOSED
		_save_state()
		
func example_door() -> bool:
	#We must have an autoload for managing the states somewhere
	var manager := WorldStateManager.new("SAVE_DOOR_TEST/")
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	var door := PersistentDoor.new()
	add_child(door)	
	door.open()
	remove_child(door)
	door.queue_free()
	
	#Reloading the door doesnt change its status
	door = PersistentDoor.new()
	add_child(door)
	assert(door.status == PersistentDoor.STATUS.OPEN)
	
	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	return true
	
class PickableObjectDynamic extends Node3D:
	@export var world_id: String = "unknown_id"
	@export var zone_register: int = 3

	var picked_internal := false
	@onready var state: WorldStateRegistryInterface

	func _ready():
		# Create & attach interface child dynamically
		if not has_node("WorldStateRegistryInterface"):
			state = WorldStateRegistryInterface.new()
			state.name = "WorldStateRegistryInterface"
			state.world_id = world_id
			state.register_by(zone_register)
			add_child(state)
		else:
			state = $WorldStateInterface
			
		# Load previous state
		var data := state.get_data()
		picked_internal = data.get("picked", false)

		if picked_internal:
			queue_free()

	func pick():
		if picked_internal:
			return
		picked_internal = true
		state.save_data({"picked": true})
		queue_free()
	
		
func example_pickup() -> bool:
	#We must have an autoload for managing the states somewhere
	var manager := WorldStateManager.new("SAVE_PICKUP_TEST/")
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	#The pickup will still be picked after reinitialization, as the IDs are unique
	var pickup := PickableObjectDynamic.new()
	add_child(pickup)
	assert(pickup.picked_internal == false)
	pickup.pick()
	assert(pickup.is_queued_for_deletion() or pickup==null)
	
	var pickup2 := PickableObjectDynamic.new() #Next time the same Object is instantiated, it gets deleted on _ready
	add_child(pickup2) # Will trigger _ready and delete it
	assert(pickup2.is_queued_for_deletion() or pickup2==null)
	
	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	
	return true


class DroppedItem extends Node3D:
	@export var zone_id: int = 1
	var world_state_id: String
	@onready var state: WorldStateRegistryInterface

	func _init():
		# Generate unique ID for each instance
		world_state_id = "STH_ON_THE_FLOOR"# + str(randi())
		pass
		
	func _ready():
		state = WorldStateRegistryInterface.get_world_state_component(self, world_state_id)
		state.register_by(zone_id)
		# Load previous position
		var data := state.get_data()
		if data.has("position"):
			global_transform.origin = Utils.string_to_vector3(data["position"])

	func leave_item():
		# Save current position when dropped
		state.save_data({"position": global_transform.origin})

func example_body() -> bool:
	#We must have an autoload for managing the states somewhere
	var manager := WorldStateManager.new("SAVE_DROP_TEST/", [1,50,60])
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	var corpse := DroppedItem.new()
	
	add_child(corpse)
	corpse.global_transform.origin = Vector3(10, 0, 5)
	corpse.leave_item()  # saves its position
	corpse.queue_free()
	
	manager.save_all_registries() #Save the information to disk
	manager.queue_free()
	
	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	
	#Simulate loading the application again
	var manager2 := WorldStateManager.new("SAVE_DROP_TEST/")
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager2)
	
	var corpse2 := DroppedItem.new()
	add_child(corpse2) #Retains previous saved position
	assert(corpse2.global_transform.origin == Vector3(10, 0, 5))

	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	
	return true
	

func _ready() -> void:
	var fs = [example_door, example_pickup, example_body]
	for f in fs:
		assert(f.call())
	
