extends RefCounted

enum MousePolicy { CAPTURE, RELEASE }

var _fpv: FPV = null
var _camera: FPVCamera = null
var _raycast_center: RayCast3D = null
var _raycast_fixed: RayCast3D = null
var _area_check: FPVAreaController = null
var _center_aim_x: Label = null
var _current_mouse_policy: int = MousePolicy.CAPTURE
var _fixed_keep_background: bool = true

func _init(
		fpv: FPV,
		camera: FPVCamera,
		raycast_center: RayCast3D,
		raycast_fixed: RayCast3D,
		area_check: FPVAreaController,
		center_aim_x: Label) -> void:
	_fpv = fpv
	_camera = camera
	_raycast_center = raycast_center
	_raycast_fixed = raycast_fixed
	_area_check = area_check
	_center_aim_x = center_aim_x

func set_fixed_keep_background(keep_background: bool) -> void:
	_fixed_keep_background = keep_background

func apply_environment() -> void:
	_current_mouse_policy = MousePolicy.CAPTURE
	_camera.environment = null
	_apply_center_raycast(ENUMS.COLLISION_LAYER.ENVIRONMENT_EYE)
	_center_aim_x.visible = true
	_area_check.monitoring = true
	_reset_camera_offset()
	_camera.cull_mask = ENUMS.VISIBILITY.ENV
	_camera.update_actionhints()
	_fpv.entered_mode_env.emit()
	apply_current_mouse_policy()

func apply_fixed() -> void:
	_current_mouse_policy = MousePolicy.RELEASE
	if not _fixed_keep_background:
		_camera.environment = load(RESOURCES.CAMERA_NORMAL_SKY)
	_apply_fixed_raycast(ENUMS.COLLISION_LAYER.FIXCAM)
	_center_aim_x.visible = false
	_area_check.monitoring = false
	_reset_camera_offset()
	_camera.update_actionhints()
	apply_current_mouse_policy()

func apply_falcon() -> void:
	_current_mouse_policy = MousePolicy.RELEASE
	_apply_fixed_raycast(ENUMS.COLLISION_LAYER.FALCON)
	_center_aim_x.visible = false
	_area_check.monitoring = false
	_reset_camera_offset()
	_camera.cull_mask = ENUMS.VISIBILITY.ENV
	_camera.update_actionhints()
	_fpv.entered_mode_falcon.emit()
	apply_current_mouse_policy()

func apply_inventory() -> void:
	_current_mouse_policy = MousePolicy.RELEASE
	apply_current_mouse_policy()

func apply_deprecated_panorama(room360: Room360) -> void:
	_current_mouse_policy = MousePolicy.CAPTURE
	_apply_center_raycast(ENUMS.COLLISION_LAYER.ROOM)
	_center_aim_x.visible = true
	_area_check.monitoring = false
	_reset_camera_offset()
	_camera.cull_mask = ENUMS.VISIBILITY.ROOM
	assert(_camera.get_cull_mask_value(ENUMS.VISIBILITY.ROOM))
	_camera.update_actionhints()
	_camera.set_background(room360.get_texture())
	_fpv.rotate_sky(PI, true)
	room360.global_position = _camera.global_position
	apply_current_mouse_policy()

func apply_current_mouse_policy() -> void:
	if _current_mouse_policy == MousePolicy.CAPTURE:
		Signals.capture_mouse.emit()
	else:
		Signals.release_mouse.emit()

func apply_lock_request(set_lock: bool) -> void:
	if not set_lock:
		Signals.release_mouse.emit()
	else:
		Signals.capture_mouse.emit()

func _apply_center_raycast(collision_mask: int) -> void:
	_raycast_center.enabled = true
	_raycast_fixed.enabled = false
	_raycast_center.collision_mask = collision_mask

func _apply_fixed_raycast(collision_mask: int) -> void:
	_raycast_center.enabled = false
	if not _raycast_fixed.enabled:
		_raycast_fixed.enabled = true
	_raycast_center.collision_mask = collision_mask
	_raycast_fixed.collision_mask = collision_mask
	_raycast_fixed.collide_with_areas = true

func _reset_camera_offset() -> void:
	_camera.position = Vector3.ZERO
