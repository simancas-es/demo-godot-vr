extends Node3D

@onready var hand: MeshInstance3D = $hand

var _current_minutes: float = 0.0
var _tween: Tween = null

func minutes_to_rotation(mins: float) -> float:
	# linear time -> rotation
	# negative = clockwise
	return -TAU * (mins / 60.0)


func _apply_minutes(mins: float) -> void:
	var angle = minutes_to_rotation(mins)
	hand.rotation.y = angle


func set_immediate_minutes(mins: float) -> void:
	_current_minutes = mins
	_apply_minutes(mins)


func set_minutes(target_minutes: float, duration := 0.5) -> void:
	var start = _current_minutes

	# update logical state ONCE
	_current_minutes = target_minutes
	tween_minutes(start, target_minutes, duration)
	update_sectors(target_minutes)
	cleanup_sectors(target_minutes)

func tween_minutes(from_m: float, to_m: float, duration_s: float) -> void:
	# kill previous tween
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_method(_apply_minutes, from_m, to_m, duration_s).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	
	
func advance_minutes(delta_min: float, duration_s := 1.0) -> void:
	set_minutes(_current_minutes + delta_min, duration_s)

func set_time_from_linear_source(time_s: float) -> void:
	# direct mapping from simulation time
	_current_minutes = time_s
	_apply_minutes(time_s)
	
	
	
## DRAWING SECTORS
var _last_sector := -1
const SEGMENT_SIZE := 5.0
var sectors : Dictionary[int, MeshInstance3D]= {}

func get_sector(mins: float) -> int:
	return int(floor(mins / SEGMENT_SIZE)) -1 #-1 is nothing
	
func update_sectors(current_min: float):
	var current_segment = get_sector(current_min)

	# create missing sectors up to current
	for i in range(current_segment + 1):
		if not sectors.has(i):
			_create_sector(i)

func _create_sector(segment: int):
	var from_min = segment * SEGMENT_SIZE
	var to_min = (segment + 1) * SEGMENT_SIZE

	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = create_sector_mesh(from_min, to_min)

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.0, 0.886, 0.004, 0.655)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	mesh_instance.material_override = mat

	add_child(mesh_instance)
	sectors[segment] = mesh_instance
	

func cleanup_sectors(current_min: float):
	var current_segment = get_sector(current_min)

	for key in sectors.keys():
		if key > current_segment:
			sectors[key].queue_free()
			sectors.erase(key)
			
func create_sector_mesh(from_min: float, to_min: float, radius: float = 0.5, steps := 10) -> ArrayMesh:
	var mesh = ArrayMesh.new()

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	var start_angle = -TAU * (from_min / 60.0)
	var end_angle = -TAU * (to_min / 60.0)

	vertices.append(Vector3.ZERO) # center

	for i in range(steps + 1):
		var t = float(i) / steps
		var angle = lerp(start_angle, end_angle, t)

		var x = cos(angle) * radius
		var z = -sin(angle) * radius

		vertices.append(Vector3(x, 0, z))

	# triangle fan
	for i in range(1, steps):
		indices.append(0)
		indices.append(i)
		indices.append(i + 1)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	return mesh
