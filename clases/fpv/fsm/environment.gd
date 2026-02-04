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
	
	set_current_fpv_mode()
	raycast_center.enabled = true
	raycast_fixed.enabled = false

	center_aim_x.visible = true #TODO Tween
	raycast_center.collision_mask = ENUMS.COLLISION_LAYER.ENVIRONMENT_EYE
	area_check.monitoring = true
	
	#Camera Reset
	camera.position = Vector3.ZERO
	camera.cull_mask = ENUMS.VISIBILITY.ENV

	camera.update_actionhints()
	fpv.entered_mode_env.emit()

func set_current_fpv_mode() -> void:
	Signals.capture_mouse.emit()

func _on_lock_fpv(set_lock : bool) -> void:
	if !set_lock:
		Signals.release_mouse.emit()
	else:
		Signals.capture_mouse.emit()
		
func process_frame(_delta : float) -> StateBase:
	fpv.rotate_body_and_camera_to_lookdir(gc.lookdir)
	gc.lookdir = Vector2.ZERO ##Interesting effect if we dont do this
	return null
	
