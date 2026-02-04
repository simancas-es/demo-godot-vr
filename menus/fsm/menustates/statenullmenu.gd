extends StateMenus

@export var state_escape : StateMenus
#@export var state_inventory : StateMenus
#@export var state_pickup : StateMenus

var active : bool = false

func connect_signals():
	#Connect global signals to the different menus
	Signals.menu.connect(on_menu_signal)
	#Signals.inventory.connect(on_inventory_signal)
	#Signals.pick_up_item_menu.connect(on_pickup_menu)
	#print(Signals.menu.get_connections())
	pass
	
func disconnect_signals():
	Signals.menu.disconnect(on_menu_signal)
	#Signals.inventory.disconnect(on_inventory_signal)
	#Signals.pick_up_item_menu.disconnect(on_pickup_menu)
	#print(Signals.menu.get_connections())
	pass
	
func enter():
	super()
	parent.pause_game(false)
	connect_signals()
	active = true	
	Signals.activate_world_controllers.emit()

func exit():
	super()
	disconnect_signals()
	active = false
	Signals.stop_world_controllers.emit() #TODO PATTERN DOCUMENTATION : SIGNAL CONTROLLER FOR WORLD
	#
#func on_pickup_menu(item : PickUpItem, quantity : int, inventory_id : PLAYERS.ID) -> void:
	#if !active: return
	#change_to.emit(state_pickup)
	#
	#
func on_menu_signal() -> void:
	if !active: return
	change_to.emit(state_escape)
	#
#func on_inventory_signal(player : PLAYERS.ID) -> void:
	#if !active: return
	#change_to.emit(state_inventory)
	#
	
	
