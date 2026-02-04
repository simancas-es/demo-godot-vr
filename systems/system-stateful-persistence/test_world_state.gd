extends Node

const WorldStateRegistry := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistry
const WorldStateRegistryInterface := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterface
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils

func clear_registry(ws : WorldStateRegistry):
	ws.states.clear()


class TestPickableAutoID extends Node3D:
	var picked_internal := false
	const world_state_id := "TestPickableAutoID" #This shouldnt work
	@onready var state := WorldStateRegistryInterface.get_world_state_component(self, world_state_id)
	func _ready():
		var data = state.get_data()
		picked_internal = data.get("picked", false)
		
	func pick():
		if picked_internal:
			return
		picked_internal = true
		state.save_data({"picked": true})
		queue_free()
		
class TestPickableManualID extends Node3D:
	var picked_internal := false
	@onready var state := WorldStateRegistryInterface.get_world_state_component(self)
	func _ready():
		var data = state.get_data()
		picked_internal = data.get("picked", false)
		
	func pick():
		if picked_internal:
			return
		picked_internal = true
		state.save_data({"picked": true})
		queue_free()		
		
func test_state_load_simple_bool_auto_id() -> bool:
	var obj := TestPickableAutoID.new()
	add_child(obj)

	obj._ready()
	obj.pick()
	var ws = obj.state.world_state_registry
	
	assert(ws.states[obj.world_state_id]["picked"] == true)
	assert(obj.picked_internal == true)
	assert(obj.world_state_id == obj.state.world_id)
	obj.queue_free()
	return true

func test_state_load_simple_bool_manual_id() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	ws.states["ITEM_1"] = { "picked": true }

	var obj := TestPickableManualID.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "ITEM_1"
	comp.world_state_registry = ws

	obj.add_child(comp)
	add_child(obj)
	obj.pick()
	assert(obj.picked_internal == true)
	assert(obj.state.world_id == "ITEM_1")
	obj.queue_free()
	return true

func test_state_save_simple_bool() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "ITEM_2"
	comp.world_state_registry = ws


	comp.save_data({ "picked": true })

	assert(ws.states.has("ITEM_2"))
	assert(ws.states["ITEM_2"]["picked"] == true)

	return true


enum TEST_ENUM { FIRST, SECOND, THIRD }
func test_create_json_v01() -> bool:
	var registry := WorldStateRegistry.new()
	
	# Set metadata
	registry.meta["zone_id"] = 1
	
	# Fill states with mixed types
	registry.states["ITEM_1"] = {
		"count": 5,                  # int
		"active": true,              # bool
		"name": "TestItem",           # string
		"state": TEST_ENUM.SECOND     # enum
	}
	
	registry.states["ITEM_2"] = {
		"enabled": false,
		"value": 42,
		"type": TEST_ENUM.THIRD,
		"slots": [0, 1, 2, 4, 5, 6],
	}
	
	# Serialize
	var json_string = registry.create_json_v01()
	
	# Parse back to dictionary
	var json = JSON.new()
	var error = json.parse(json_string, false)
	assert(error == Error.OK)
	var data = json.data
	
	# Check metadata
	assert(data.has("meta"))
	assert(data["meta"]["version"] == "v01")
	assert(data["meta"]["zone_id"] == 1)
	
	# Check states
	assert(data.has("states"))
	assert(data["states"]["ITEM_1"]["count"] == 5) # ints converted to strings?
	assert(data["states"]["ITEM_1"]["active"] == true)
	assert(data["states"]["ITEM_1"]["name"] == "TestItem")
	assert(data["states"]["ITEM_1"]["state"] == Utils.string_to_enum(TEST_ENUM, "SECOND") ) # enum converted to string
	
	assert(data["states"]["ITEM_2"]["enabled"] == false)
	assert(data["states"]["ITEM_2"]["value"] == 42)
	assert(data["states"]["ITEM_2"]["type"] == Utils.string_to_enum(TEST_ENUM,  "THIRD") )
	assert(data["states"]["ITEM_2"]["slots"] == [0.0, 1.0, 2.0, 4.0, 5.0, 6.0] ) #TODO: int/floats

	
	return true




func test_pickable_save_before_queue_free() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Create pickable object and state component
	var obj := TestPickableAutoID.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_state_registry = ws

	assert (comp.world_state_registry == ws)
	obj.add_child(comp)
	add_child(obj)
	assert (comp.world_state_registry == ws)
	
	assert(obj.picked_internal == false)
	# Pick the object
	obj.pick()

	assert (comp.world_state_registry == ws)
	# After pick, the state should be saved even though the object is queued for free
	assert(ws.states.has(TestPickableAutoID.world_state_id))
	assert(ws.states[TestPickableAutoID.world_state_id]["picked"] == true)

	return true




class TestDoor:
	extends Node3D

	enum LOCK { LOCKED, UNLOCKED }
	enum STATUS { CLOSED, OPENED }

	@export var _status: STATUS = STATUS.CLOSED
	@export var _lock: LOCK = LOCK.LOCKED

	@onready var state : WorldStateRegistryInterface = WorldStateRegistryInterface.get_world_state_component(self)

	func _ready():
		var data := state.get_data()
		@warning_ignore("int_as_enum_without_cast")
		_status = Utils.string_to_enum(STATUS, data.get("status", Utils.enum_to_string(STATUS, _status)))
		@warning_ignore("int_as_enum_without_cast")
		_lock = Utils.string_to_enum(LOCK, data.get("lock", Utils.enum_to_string(LOCK, _lock)))

	func save_state():
		state.save_data({"status": Utils.enum_to_string(STATUS, _status),"lock": Utils.enum_to_string(LOCK, _lock)})
		
		

func test_door_state_load() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Prepopulate registry with a door state
	ws.states["DOOR_1"] = {"status": Utils.enum_to_string(TestDoor.STATUS, TestDoor.STATUS.OPENED),
	"lock": Utils.enum_to_string(TestDoor.LOCK, TestDoor.LOCK.UNLOCKED)}

	# Create door node and component
	var door := TestDoor.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "DOOR_1"
	comp.world_state_registry = ws

	door.add_child(comp)
	add_child(door)

	# Call ready manually since we're instancing nodes
	door._ready()

	# Check that state loaded correctly
	assert(door._status == TestDoor.STATUS.OPENED)
	assert(door._lock == TestDoor.LOCK.UNLOCKED)

	door.queue_free()
	return true


# Test saving door state to registry
func test_door_state_save() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var door := TestDoor.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "DOOR_2"
	comp.world_state_registry = ws

	door.add_child(comp)
	add_child(door)

	# Set door state
	door._status = TestDoor.STATUS.OPENED
	door._lock = TestDoor.LOCK.UNLOCKED

	# Save state
	door.save_state()

	# Check registry
	assert(ws.states.has("DOOR_2"))
	assert(ws.states["DOOR_2"]["status"] == Utils.enum_to_string(TestDoor.STATUS, TestDoor.STATUS.OPENED))
	assert(ws.states["DOOR_2"]["lock"] == Utils.enum_to_string(TestDoor.LOCK, TestDoor.LOCK.UNLOCKED))

	door.queue_free()
	return true


# Optional: Test default values when no registry entry exists
func test_door_state_default() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var door := TestDoor.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "DOOR_3"
	comp.world_state_registry = ws

	door.add_child(comp)
	add_child(door)

	door._ready()

	# Defaults should remain since registry is empty
	assert(door._status == TestDoor.STATUS.CLOSED)
	assert(door._lock == TestDoor.LOCK.LOCKED)

	door.queue_free()
	return true
		
		

#Saving to disk
func test_save_to_disk() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Add a door with enum values
	ws.states["DOOR_1"] = {"status": TestDoor.STATUS.OPENED, "lock": TestDoor.LOCK.UNLOCKED}

	var path = "user://test_state.json"
	ws.save_to_disk(path)

	assert(FileAccess.file_exists(path))

	# Optionally check content contains string of integers (simple check)
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	assert(content.find("1") != -1)  # Enum values stored
	return true


func test_load_from_disk() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var path = "user://test_state.json"

	# Manually write test JSON
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"states":{"DOOR_1":{"status":1,"lock":1}}}')
	file.close()

	ws.load_from_disk(path)

	assert(ws.states.has("DOOR_1"))
	assert(ws.states["DOOR_1"]["status"] == 1)
	assert(ws.states["DOOR_1"]["lock"] == 1)
	return true



class TestComplexObject extends Node3D:
	enum STATUS { IDLE, ACTIVE }

	var _status: STATUS = STATUS.IDLE
	var param: int = 0
	var nested_data: Dictionary = {"sub1": 0, "sub2": ""}

	@onready var state: WorldStateRegistryInterface = WorldStateRegistryInterface.get_world_state_component(self)

	func _ready():
		var data: Dictionary = state.get_data()
		# Load top-level values with defaults if missing
		@warning_ignore("int_as_enum_without_cast")
		_status = Utils.string_to_enum(STATUS, data.get("status", Utils.enum_to_string(STATUS, _status)))
		param = data.get("param", param)

		# Load nested dictionary partially
		var nested: Dictionary = data.get("nested_data", {})
		for key in nested_data.keys():
			nested_data[key] = nested.get(key, nested_data[key])

	func save_state():
		state.save_data({
			"status": _status,
			"param": param,
			"nested_data": nested_data
		})
		
func test_complex_object_partial_load() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Only provide partial nested data in registry
	ws.states["OBJ_1"] = {
		"param": 42,
		"nested_data": {"sub1": 99}  # sub2 is missing
	}

	var obj := TestComplexObject.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "OBJ_1"
	comp.world_state_registry = ws

	obj.add_child(comp)
	add_child(obj)

	obj._ready()

	# Top-level param should load
	assert(obj.param == 42)
	# Status should remain default (IDLE)
	assert(obj._status == TestComplexObject.STATUS.IDLE)
	# Nested dictionary partially loaded
	assert(obj.nested_data["sub1"] == 99)
	assert(obj.nested_data["sub2"] == "")  # default value preserved

	obj.queue_free()
	return true
	
	
	
func test_complex_object_save() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var obj := TestComplexObject.new()
	var comp := WorldStateRegistryInterface.new()
	comp.world_id = "OBJ_2"
	comp.world_state_registry = ws

	obj.add_child(comp)
	add_child(obj)

	# Set state
	obj._status = TestComplexObject.STATUS.ACTIVE
	obj.param = 7
	obj.nested_data = {"sub1": 123, "sub2": "hello"}

	obj.save_state()

	assert(ws.states.has("OBJ_2"))
	assert(ws.states["OBJ_2"]["status"] == TestComplexObject.STATUS.ACTIVE)
	assert(ws.states["OBJ_2"]["param"] == 7)
	assert(ws.states["OBJ_2"]["nested_data"]["sub1"] == 123)
	assert(ws.states["OBJ_2"]["nested_data"]["sub2"] == "hello")

	obj.queue_free()
	return true



class TestSimpleAttributes extends Node:
	var bool_attr: bool = false
	var int_attr: int = 0
	var float_attr: float = 0.0
	var string_attr: String = ""
	var bool_array: Array = []
	var int_array: Array = []
	
	signal updated

class TestSimpleAttributesResource extends Resource:
	var bool_attr : bool = false
	signal updated


func test_simple_attributes_node_load() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Prepopulate registry
	ws.states["MIXED_1"] = {
		"bool_attr": true,
		"int_attr": 42,
		"float_attr": 3.14,
		"string_attr": "Hello",
		"bool_array": [true, false, true],
		"int_array": [1,2,3,5]
	}

	var obj := TestSimpleAttributes.new()
	var comp := StatefulPersistenceInterfaceSimpleAttributes.new()
	comp.world_id = "MIXED_1"
	comp.world_state_registry = ws
	comp.target = obj
	comp.saved_attributes = ["bool_attr", "int_attr", "float_attr", "string_attr", "bool_array", "int_array"]
	comp.signalname = "updated"
	
	add_child(obj)
	add_child(comp)
	

	assert(obj.bool_attr == true)
	assert(obj.int_attr == 42)
	assert(abs(obj.float_attr - 3.14) < 0.001)
	assert(obj.string_attr == "Hello")
	assert(obj.bool_array == [true,false,true])
	assert(obj.int_array == [1,2,3,5])

	obj.queue_free()
	
	
	return true


func test_simple_attributes_resource_load() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	# Prepopulate registry
	ws.states["MIXED_2"] = {
		"bool_attr": true,
	}

	var obj := TestSimpleAttributes.new()
	var comp := StatefulPersistenceInterfaceSimpleAttributes.new()
	comp.world_id = "MIXED_2"
	comp.world_state_registry = ws
	comp.target = obj
	comp.saved_attributes = ["bool_attr"]
	comp.signalname = "updated"
	
	add_child(comp)
	

	assert(obj.bool_attr == true)
	
	return true

func test_simple_attributes_node_save() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var obj := TestSimpleAttributes.new()
	var comp := StatefulPersistenceInterfaceSimpleAttributes.new()
	comp.world_id = "MIXED_3"
	comp.world_state_registry = ws
	comp.signalname = "updated"
	comp.saved_attributes = ["bool_attr", "int_attr", "float_attr", "string_attr", "bool_array", "int_array"]


	obj.add_child(comp)
	
	add_child(obj)

	# Set attributes
	obj.bool_attr = false
	obj.int_attr = 99
	obj.float_attr = 2.71
	obj.string_attr = "World"
	obj.bool_array = [false, false, true]
	obj.int_array = [10,20,30]
	
	obj.updated.emit()

	assert(ws.states.has("MIXED_3"))
	assert(ws.states["MIXED_3"]["bool_attr"] == false)
	assert(ws.states["MIXED_3"]["int_attr"] == 99)
	assert(abs(ws.states["MIXED_3"]["float_attr"] - 2.71) < 0.001)
	assert(ws.states["MIXED_3"]["string_attr"] == "World")
	assert(ws.states["MIXED_3"]["bool_array"] == [false,false,true])
	assert(ws.states["MIXED_3"]["int_array"] == [10,20,30])

	obj.queue_free()
	return true



func test_simple_attributes_resource_save() -> bool:
	var ws = WorldStateRegistry.new()
	clear_registry(ws)

	var obj := TestSimpleAttributesResource.new()
	var comp := StatefulPersistenceInterfaceSimpleAttributes.new()
	comp.world_id = "MIXED_4"
	comp.world_state_registry = ws
	comp.target = obj
	comp.signalname = "updated"
	comp.saved_attributes = ["bool_attr"]
	

	add_child(comp)
	

	# Set attributes
	obj.bool_attr = false
	
	obj.updated.emit()

	assert(ws.states.has("MIXED_4"))
	assert(ws.states["MIXED_4"]["bool_attr"] == false)

	return true



func _ready() -> void:
	assert (test_state_load_simple_bool_auto_id())
	assert (test_state_load_simple_bool_manual_id() )
	assert (test_state_save_simple_bool())
	assert (test_create_json_v01())
	assert (test_pickable_save_before_queue_free())
	
	assert (test_door_state_load())
	assert (test_door_state_save())
	assert (test_door_state_default())
	
	assert(test_save_to_disk())
	assert(test_load_from_disk())
	
	#Complex objects with nested parameters
	assert (test_complex_object_partial_load())
	assert (test_complex_object_save())
	
	#Simpleattributes
	assert ( test_simple_attributes_node_load())
	assert ( test_simple_attributes_resource_load())
	assert ( test_simple_attributes_node_save())
	assert ( test_simple_attributes_resource_save())
	
	print("SYSTEM-STATEFUL-PERSISTANCE passed all tests... seems to work...")
