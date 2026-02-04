extends Node

const WorldStateRegistryInterfacePosition := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistryInterfacePosition
const WorldStateRegistry := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateRegistry
const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager

func test_polling_interval_respected() -> bool:
	var parent := Node3D.new()
	add_child(parent)
	parent.global_transform.origin = Vector3(1, 2, 3)

	var iface := StatefulPersistenceInterfacePosition.new()
	iface.polling_time_s = 1.0
	iface.world_id = "POS_TEST"

	iface.world_state_registry = WorldStateRegistry.new()

	parent.add_child(iface)


	# Run less than polling time
	await get_tree().process_frame

	assert(!iface.world_state_registry.states.has("POS_TEST"))

	# Advance time past polling interval
	await get_tree().create_timer(1.1).timeout

	assert(iface.world_state_registry.states.has("POS_TEST"))

	parent.queue_free()
	return true
	
	
class Element extends Node3D:
	pass
	
func example_autopolling() -> bool:
	#We must have an autoload for managing the states somewhere
	var manager := WorldStateManager.new("SAVE_AUTOPOLLING_TEST/", [3])
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager)
	
	var element := Element.new()
	var iface := WorldStateRegistryInterfacePosition.new()
	iface.world_id = "ELEMENT_ID"
	iface.zone_register = 3
	iface.polling_time_s = 1.5
	
	element.add_child(iface)
	add_child(element)
	element.global_transform.origin = Vector3(10, 0, 5)
	
	# Advance time past polling interval
	await get_tree().create_timer(1.5).timeout
	
	element.queue_free()
	
	manager.save_all_registries() #Save the information to disk
	manager.queue_free()
	
	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	
	#Simulate loading the application again
	var manager2 := WorldStateManager.new("SAVE_AUTOPOLLING_TEST/", [3])
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, manager2)
	
	var element2 := Element.new()
	var iface2 := WorldStateRegistryInterfacePosition.new()
	iface2.world_id = "ELEMENT_ID"
	iface2.zone_register = 3
	iface2.polling_time_s = 1.5
	
	element2.add_child(iface2)
	add_child(element2) #Retains previous saved position
	assert(element2.global_transform.origin == Vector3(10, 0, 5))

	#Cleanup
	Engine.unregister_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
	for e in [element, iface, element2, iface2]: e.queue_free()
	return true
	




func _ready() -> void:
	assert (await test_polling_interval_respected())
	assert (await example_autopolling())
	pass
