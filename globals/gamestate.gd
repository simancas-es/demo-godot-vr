extends Node
const Inventory := INVENTORY_UIDCLASSREF.Inventory
const WorldStateManager := SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager
const InventoryPersistence := HELPREF.InventoryPersistence

const TaskManager := SYSTEMTASKS_UIDCLASSREF.SystemTasksManager
const TaskTextManager := HELPREF.TaskTextManager

var _current_topic : TOPICS.LAYER = TOPICS.LAYER.ABWASSER

var players : Array[PlayerData] = []
var player_inventory : Inventory ##Simple inventory system, only the player has it.

var world_state_manager = WorldStateManager.new("/DEFAULT_SAVE/")

var world_task_manager = TaskManager.new(UTILS.enum_to_dict(SYSTEMTASKSSETTINGS.UNIT_ID))
var task_text_manager : HELPREF.TaskTextManager


func _ready() -> void:
	Signals.request_change_topic.connect(on_request_change_topic)
	#Save Manager
	Engine.register_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME, world_state_manager)
	#Loads inventory
	var info = InventoryResources.get_dictionary()
	player_inventory = Inventory.new(6, info)
	
	#Persistence of inventory
	var inventory_persistence := InventoryPersistence.new()
	inventory_persistence.world_id = "INVENTORY"
	player_inventory.add_child(inventory_persistence)
	add_child(player_inventory) #TODO: Hack for the _ready
		

	
	#TODO: Detect if VR is connected when launching the app and substituting the control scheme.
	#Loads controllers
	var controller = ControllerManager.get_next_controller()	
	#Appends controller to playerdata
	players.append(PlayerData.new(controller, player_inventory))
	
	init_task_manager()
	
	var preferred_language = OS.get_locale_language()
	TranslationServer.set_locale(preferred_language)

func init_task_manager() -> void:
	Engine.register_singleton(SYSTEMTASKSSETTINGS.AUTOLOAD_TASKMANAGER, world_task_manager)
	world_task_manager.load_json(RESOURCES.SystemTasksDatabase) #Load the tasks first
	var world_task_persistence = HELPREF.SystemTasksTasksManagerPersistence.new()
	world_task_persistence.world_id = "TASKS" # Hopefully there are no collisions but this is shakey
	world_task_manager.add_child(world_task_persistence)
	add_child(world_task_manager) #Required because of the conditions that use _process
	
	var task_text_map := TaskTextManager.enum_to_dict(SYSTEMTASKSSETTINGS.UNIT_ID)
	task_text_manager = TaskTextManager.new(RESOURCES.SystemTasksText, task_text_map)
	pass	

func on_request_change_topic(topic : TOPICS.LAYER) -> void:
	_current_topic = topic
	Signals.topic_changed.emit(_current_topic)
	#print("Topic changed to %s" % _current_topic)

func get_player(idx : int = 0) -> PlayerData:
	if idx >= players.size():
		push_error("Invalid player index!")
		return null
	return players[idx]
