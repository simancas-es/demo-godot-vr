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
	
func enter():
	connect_signals()
	#Movement locked, camera fixed, can't rotate.
	#Hits determined by mouse position
	set_current_fpv_mode()	
	raycast_center.enabled = false
	if not raycast_fixed.enabled : raycast_fixed.enabled = true
	
	center_aim_x.visible = false #TODO Tween
	
	raycast_center.collision_mask = ENUMS.COLLISION_LAYER.FIXCAM
	raycast_fixed.collision_mask = ENUMS.COLLISION_LAYER.FIXCAM
	
	raycast_fixed.collide_with_areas = true #!!
	#Camera reset
	camera.position = Vector3.ZERO
	area_check.monitoring = false
	camera.update_actionhints()

func set_current_fpv_mode() -> void:
	Signals.release_mouse.emit()

	
func _on_lock_fpv(set_lock : bool) -> void:
	if !set_lock:
		Signals.release_mouse.emit()
	else:
		Signals.capture_mouse.emit()
		
func process_frame(_delta) -> StateBase:
	camera.cast_ray(gc.mousepos)
	return null
	
func process_physics(_delta) -> StateBase:
	return null
