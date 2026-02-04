extends Node
#const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager
const WorldStateRegistry := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistry
const WorldStateRegistryInterface := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterface
const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager
const Utils := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.Utils


class TestPickableAutoID extends Node3D:
	var picked_internal := false
	const world_state_id := "TestPickableID" #This shouldnt work
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


func test_interface_creates_own_registry() -> bool:
	# No autoload manager yet
	var iface := WorldStateRegistryInterface.new()
	iface.world_id = "ITEM_OWN"
	iface.zone_register = SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.DEFAULT
	add_child(iface) # This should attempt to register but fail, then create its own registry

	assert(iface.world_state_registry != null) # Own registry created
	assert(iface.get_data() == {}) # Starts empty
	iface.save_data({"picked": true})
	assert(iface.get_data()["picked"] == true)
	iface.queue_free()
	return true


func test_interface_autosubscribes_to_manager() -> bool:
	# Create autoload manager manually
	var manager := WorldStateManager.new()
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	# Create interface
	var iface := WorldStateRegistryInterface.new()
	iface.world_id = "ITEM_AUTO"
	iface.zone_register = SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.DEFAULT
	add_child(iface)
	
	var registry := manager.get_zone_registry(SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.DEFAULT)
	assert(iface.world_state_registry == registry)
	
	# Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	return true



func test_registry_delete_and_reload() -> bool:
	var manager := WorldStateManager.new()
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	var iface := WorldStateRegistryInterface.new()
	iface.world_id = "ITEM_TEMP"
	iface.zone_register = SYSTEMSTATEFULPERSISTENCE_SETTINGS.PERSISTENTZONES.DEFAULT
	iface._ready() # registers to manager
	
	var registry := iface.world_state_registry
	registry.states["ITEM_TEMP"] = {"picked": true}
	
	# Delete registry from manager
	manager.zone_registries[iface.zone_register] = null
	
	# The interface still has a reference, so get_data still works
	assert(iface.get_data()["picked"] == true)
	
	# Reload registry into manager
	manager.zone_registries[iface.zone_register] = registry
	assert(iface.world_state_registry == registry)
	assert(iface.get_data()["picked"] == true)
	
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	return true


func test_save_and_load_all_registries() -> bool:
	var manager := WorldStateManager.new("/TEST_SAVE/")
	
	manager.zone_registries[1] = WorldStateRegistry.new()
	manager.zone_registries[2] = WorldStateRegistry.new()
	
	manager.zone_savepaths[1] = "user://zone_1_test.dat"
	manager.zone_savepaths[2] = "user://zone_2_test.dat"
	
	manager.zone_registries[1].states["ITEM_A"] = {"picked": true}
	manager.zone_registries[2].states["ITEM_B"] = {"opened": false}
	
	manager.save_all_registries()
	
	manager.zone_registries[1] = null
	manager.zone_registries[2] = null
	
	var err1 = manager.load_registry_from_path(1, manager.zone_savepaths[1])
	var err2 = manager.load_registry_from_path(2, manager.zone_savepaths[2])
	
	assert(err1 == WorldStateManager.ERROR.SUCCESS)
	assert(err2 == WorldStateManager.ERROR.SUCCESS)
	
	assert(manager.zone_registries[1].states["ITEM_A"]["picked"] == true)
	assert(manager.zone_registries[2].states["ITEM_B"]["opened"] == false)
	
	
	var deleted1 = manager.zone_registries[1].delete_from_disk(manager.zone_savepaths[1])
	var deleted2 = manager.zone_registries[2].delete_from_disk(manager.zone_savepaths[2])

	assert(deleted1)
	assert(deleted2)

	#Verify deletion
	assert(not FileAccess.file_exists(manager.zone_savepaths[1]))
	assert(not FileAccess.file_exists(manager.zone_savepaths[2]))


	return true


func test_load_registry_nonexistent_file() -> bool:
	var manager := WorldStateManager.new("/TEST_SAVE/")
	
	manager.zone_savepaths[1] = "user://nonexistent_file.dat"
	
	var err = manager.load_registry_from_path(1, manager.zone_savepaths[1])
	assert(err == WorldStateManager.ERROR.EXISTS_NOT)
	
	# Ensure registry object was still created
	assert(manager.zone_registries[1] != null)
	assert(manager.zone_registries[1].states.is_empty())
	
	return true


func test_ensure_directory_for_file() -> bool:
	# Generate a temporary directory path inside user://
	var tmp_dir := "user://test_dir/subdir"
	var tmp_file := tmp_dir + "/file.txt"

	# Make sure the directory doesn't exist before
	var dir := DirAccess.open("user://")
	if dir.dir_exists(tmp_dir):
		dir.remove(tmp_dir) # Optional cleanup

	# Call the function
	await Utils.ensure_directory_for_file(tmp_file)

	# Check that the directory now exists
	assert(dir.dir_exists(tmp_dir))

	# Cleanup
	dir.remove(tmp_dir)

	return true



func _ready():
	
	var funcs = [
		test_interface_creates_own_registry,
		test_interface_autosubscribes_to_manager,
		test_registry_delete_and_reload,
		test_save_and_load_all_registries,
		test_load_registry_nonexistent_file,
		test_ensure_directory_for_file
		
	]
	for f in funcs:
		assert(f.call())
		
	print("system-stateful-persistence seems to work...")
