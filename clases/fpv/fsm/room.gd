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
	if room360 == null: go_back.emit()
		
	set_current_fpv_mode()
	raycast_center.enabled = true
	raycast_fixed.enabled = false

	center_aim_x.visible = true #TODO:Tween
	raycast_center.collision_mask = ENUMS.COLLISION_LAYER.ROOM
	area_check.monitoring = false
	
	#Camera Reset
	camera.position = Vector3.ZERO
	camera.cull_mask = ENUMS.VISIBILITY.ROOM
	
	assert (camera.get_cull_mask_value(ENUMS.VISIBILITY.ROOM))
	
	camera.update_actionhints()
	camera.set_background(room360.get_texture())
	fpv.rotate_sky(PI, true)
	
	room360.global_position = camera.global_position
	#room360.visible = true
	
	#fpv.entered_mode_room.emit(room360.id)
	#
#func set_room_camera() -> void:
	#fpv.set_mode_panorama(null)
	#pass
		#
		
func set_current_fpv_mode() -> void:
	Signals.capture_mouse.emit()
	
	
func _on_lock_fpv(set_lock : bool) -> void:
	if !set_lock:
		Signals.release_mouse.emit()
	else:
		Signals.capture_mouse.emit()
		
func process_frame(_delta : float) -> StateBase:
	fpv.rotate_body_and_camera_to_lookdir(gc.lookdir)
	gc.lookdir = Vector2.ZERO
	return null
	
func process_input(_event : InputEvent) -> StateBase:
	if Input.is_action_just_pressed("exit_panorama"):
		fpv.set_mode_environment() #HACK
		get_viewport().set_input_as_handled()
	return null
