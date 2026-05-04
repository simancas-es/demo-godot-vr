extends RefCounted

const FPV_SCENE := preload("res://clases/fpv/fpv.tscn")

var _zone: Node3D = null
var _active_fpv: FPV = null

func _init(zone: Node3D) -> void:
	_zone = zone

func get_active_fpv() -> FPV:
	if is_instance_valid(_active_fpv) and _active_fpv.get_parent() == _zone:
		return _active_fpv
	_active_fpv = _find_child_fpv()
	return _active_fpv

func replace_active_fpv(spawn_position: Vector3, look_target: Vector3) -> FPV:
	_free_child_fpvs()
	var fpv: FPV = FPV_SCENE.instantiate() as FPV
	if fpv == null:
		push_error("ZoneFPVRuntime expected FPV scene to instantiate as FPV.")
		return null
	_zone.add_child(fpv)
	_active_fpv = fpv
	_apply_spawn(fpv, spawn_position, look_target)
	fpv.set_mode_environment()
	return fpv

func _find_child_fpv() -> FPV:
	for child: Node in _zone.get_children():
		if child is FPV:
			return child as FPV
	return null

func _free_child_fpvs() -> void:
	for child: Node in _zone.get_children():
		if child is FPV:
			_zone.remove_child(child)
			child.queue_free()
	_active_fpv = null

func _apply_spawn(fpv: FPV, position: Vector3, look_target: Vector3) -> void:
	fpv.position = position
	if position != look_target and look_target != Vector3.UP:
		fpv.look_at(look_target)
