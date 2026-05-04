extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase

##Whenever the player enters the inventory state
var gc : ControllerBase
var fpv : FPV

func connect_signals() -> void:
	Signals.lock_fpv.connect(_on_lock_fpv)
	Signals.request_current_fpvmode.connect(set_current_fpv_mode)
	pass
	
func disconnect_signals() -> void:
	Signals.lock_fpv.disconnect(_on_lock_fpv)
	Signals.request_current_fpvmode.disconnect(set_current_fpv_mode)

	pass
	
func exit() -> void:
	disconnect_signals()
	
func enter() -> void:
	connect_signals()
	fpv.get_view_mode_controller().apply_inventory()


func set_current_fpv_mode() -> void:
	fpv.get_view_mode_controller().apply_current_mouse_policy()


func _on_lock_fpv(set_lock : bool) -> void:
	fpv.get_view_mode_controller().apply_lock_request(set_lock)
		
