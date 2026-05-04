extends StateBase
const StateBase := FSM_UIDCLASSREF.StateBase

var gc : ControllerBase

@onready var camera : FPVCamera = %Camera3D
@onready var raycast_center = %RayCast3D
@onready var raycast_fixed = (%Camera3D).raycast_fixed
@onready var center_aim_x = (%Camera3D).center_aim_x
@onready var area_check = (%AreaCheck)

@onready var il : FPVInteractionLogic = %InteractionLogic
var fpv : FPV
#var room_id : ROOMS.ID = ROOMS.ID.NONE
var room360 : Room360 = null


func connect_signals() -> void:
	Signals.lock_fpv.connect(_on_lock_fpv)
	Signals.request_current_fpvmode.connect(set_current_fpv_mode)

func disconnect_signals() -> void:
	Signals.lock_fpv.disconnect(_on_lock_fpv)
	Signals.request_current_fpvmode.disconnect(set_current_fpv_mode)

func exit() -> void:
	disconnect_signals()

	
func enter() -> void:
	connect_signals()
	if room360 == null:
		go_back.emit()
		return
	fpv.get_view_mode_controller().apply_deprecated_panorama(room360)
	#room360.visible = true
	
	#fpv.entered_mode_room.emit(room360.id)
	#
#func set_room_camera() -> void:
	#fpv.set_mode_panorama(null)
	#pass
		#
		
func set_current_fpv_mode() -> void:
	fpv.get_view_mode_controller().apply_current_mouse_policy()
	
	
func _on_lock_fpv(set_lock : bool) -> void:
	fpv.get_view_mode_controller().apply_lock_request(set_lock)
		
func process_frame(_delta : float) -> StateBase:
	fpv.rotate_body_and_camera_to_lookdir(gc.consume_look_delta())
	return null
	
func process_input(_event : InputEvent) -> StateBase:
	if gc.is_panorama_exit_requested():
		fpv.set_mode_environment() #HACK
		get_viewport().set_input_as_handled()
	return null
