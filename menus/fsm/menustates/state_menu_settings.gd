extends StateMenus

@onready var menu_settings : MenuSettings = %MenuSettings

@onready var signals_fs : Dictionary[Signal, Callable] = {
	Signals.settings: closed_settings,
	#menu_settings.requested_lock : opened_settings, #Entered Menu
	#menu_settings.released_lock : closed_settings #Closed Menu
	menu_settings.closed_dialog : closed_settings
}
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
	
func enter() -> void:
	connect_signals()
	ControllerManager.enable_ctrls(false)
	parent.pause_game(true)
	opened_settings()
	
func exit() -> void:
	disconnect_signals()
	parent.pause_game(false)
	
func opened_settings() -> void:	
	menu_settings.enter()
	Signals.release_mouse.emit()
	Signals.set_fixed_camera.emit(true)
	pass
	
func closed_settings() -> void:
	go_back.emit()
	pass
