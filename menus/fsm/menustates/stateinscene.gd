extends StateMenus

#This state represents the interface options when inside a zone
#Menu opens a menu with settings and exit to main screen and exit to desktop
#Dialogs can be opened here and they get input priority = show mouse.
#Possible to trigger the Environment selection screen.
#Possible to change to room mode.

@onready var menu_manager : MenuManager = %UI_CanvasLayer
@onready var state_loading : StateMenusLoading = %Loading
@onready var state_settings : StateMenus = %StateMenuSettings
@onready var state_envselect : StateMenus = %StateMenuEnvSelector
@onready var state_inventory : StateMenus = %StateMenuInventory


@onready var debug_task_show : VBoxContainer = %DebugTaskShow

func connect_signals() -> void:	
	for s in signals_fs.keys():
		if not s.is_connected(signals_fs[s]):
			s.connect(signals_fs[s])
	pass
	
func disconnect_signals() -> void:
	for s in signals_fs.keys():
		if s.is_connected(signals_fs[s]):
			s.disconnect(signals_fs[s])
	pass

@onready var signals_fs : Dictionary[Signal, Callable] = {
	#Signals.request_change_room: on_request_change_room,
	Signals.popup_text : menu_manager.on_popup_info,
	Signals.settings: change_to.emit.bind(state_settings),
	Signals.select_env: on_launching_env_selector,
	Signals.inventory_action_open: on_inventory,
	Signals.change_zone: on_loading_new_env,
	menu_manager.launched_env_change: on_loading_new_env,
}
	
func enter():
	super()
	ControllerManager.enable_ctrls(true)
	parent.pause_game(false)
	connect_signals()
	Signals.capture_mouse.emit()
	self.entered.emit()
	
	debug_task_show.visible = true


func exit():
	super()
	disconnect_signals()
	self.exited.emit()
	
	debug_task_show.visible = false

##Resets the fpv mode to what it should be. That is:
##Captured if in a normal environment or room.
func on_request_current_fpv_mode() -> void:
	pass

func on_launching_env_selector(from : ENVIRONMENTS.ID) -> void:
	state_envselect.current_env = from
	change_to.emit(state_envselect)
	
	
func on_loading_new_env(from : ENVIRONMENTS.ID, to : ENVIRONMENTS.ID):
	state_loading.current_env = from
	state_loading.target_env = to		
	ControllerManager.enable_ctrls(false)
	change_to.emit(state_loading)

func on_inventory() -> void:
	change_to.emit(state_inventory)

func on_back() -> void:
	go_back.emit()
	pass


func process_input(_event: InputEvent) -> StateMenus:
	##Menu	
	if Input.is_action_just_pressed("escape"):
		get_viewport().set_input_as_handled()
		return state_settings
	
	##TEMPORARY: Trigger save
	if Input.is_action_just_pressed("system_persistence_save"):
		if Engine.has_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME):
			var manager : SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager = Engine.get_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
			manager.save_all_registries()
	if Input.is_action_just_pressed("system_persistence_delete"):
		if Engine.has_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME):
			var manager : SYSTEMSTATEFULPERSISTENCE_UIDCLASSREF.WorldStateManager = Engine.get_singleton(SYSTEMSTATEFULPERSISTENCE_SETTINGS.MANAGER_AUTOLOAD_NAME)
			manager.delete_all_registries()
	
	return null
	
