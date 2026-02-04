extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase

##Whenever the player enters the inventory state

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
	set_current_fpv_mode()


func set_current_fpv_mode() -> void:
	Signals.release_mouse.emit()


func _on_lock_fpv(set_lock : bool) -> void:
	if !set_lock:
		Signals.release_mouse.emit()
	else:
		Signals.capture_mouse.emit()
		
