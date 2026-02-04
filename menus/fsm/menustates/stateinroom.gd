extends StateMenus
#extends StateMenus
##This state represents the 
##
#
#@onready var menu_manager : MenuManager = %UI_CanvasLayer
#
#@export var state_inscene : StateMenus
#
#var current_topic : TOPICS.LAYER = TOPICS.LAYER.ABWASSER
#
#func connect_signals() -> void:	
	#for s in signals_fs.keys():
		#if not s.is_connected(signals_fs[s]):
			#s.connect(signals_fs[s])
	#pass
	#
#func disconnect_signals() -> void:
	#for s in signals_fs.keys():
		#if not s.is_connected(signals_fs[s]):
			#s.disconnect(signals_fs[s])
	#pass
#
#@onready var signals_fs : Dictionary[Signal, Callable] = {
	#Signals.request_change_room : on_request_change_room,
	#Signals.request_exit_roomspace : on_request_exit_roomspace,
	#Signals.popup_text : menu_manager.on_popup_info,
	#Signals.inventory: menu_manager.on_inventory,
	##Signals.change_zone: on_launched_env,
	#menu_manager.request_current_fpvmode: on_set_fpvmode,
#}
#
	#
#func enter():
	#super()
	#parent.pause_game(false)
	#connect_signals()
	#on_set_fpvmode()
#
#func exit():
	#super()
	#disconnect_signals()
##
##func on_back() -> void:
	##change_to.emit(state_inscene)
	##pass
#
#func on_set_fpvmode() -> void:
	#Signals.set_room_camera.emit()
	#pass
#
#func on_request_change_room(id : ROOMS.ID):
	#Signals.change_room.emit(id)
	#pass
	#
#func on_request_exit_roomspace():
	#Signals.exit_room.emit()
	##change_to.emit(state_inscene)
	#back()
#
#
#func _input(_event: InputEvent) -> void:
	###Menu	
	#if Input.is_action_just_pressed("escape"):
		#Signals.settings.emit()
		#get_viewport().set_input_as_handled()
		#print("Escape pressed while in room...")
