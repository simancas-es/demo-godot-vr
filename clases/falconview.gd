extends Path3D
class_name FalconView
##Class that has a flying camera that focuses on a look_at point
##while the camera circles the environment following a Path3D

var camera : Camera3D = null
var follow_pos : PathFollow3D
var node_ref : Node3D = null
@export var lookatnode : Node3D = null

@export var speed : float = 1

func _init() -> void:
	tree_entered.connect(_on_tree_enter)
	set_process(false)

func _ready() -> void:
	set_process(false)


func _on_tree_enter() -> void:
	follow_pos = PathFollow3D.new()
	follow_pos.rotation_mode = PathFollow3D.ROTATION_NONE
	follow_pos.tilt_enabled = false
	add_child(follow_pos)
	
	set_process(false)

##Copies the position of the progress to the node_position_ref.
##Forces the camera to look
func activate_view(node_ref_ : Node3D, camera_ref : Camera3D) -> void:
	camera = camera_ref
	node_ref = node_ref_
	camera.current = true
	set_process(true)

func deactivate_view() -> Camera3D:
	set_process(false)
	var _camera = camera
	camera = null
	return _camera

func _process(delta: float) -> void:
	if lookatnode != null: #just deactivate _process on a setget...
		follow_pos.progress += speed * delta
		#node_ref.global_position = follow_pos.global_position
		camera.global_position = follow_pos.global_position
		camera.look_at(lookatnode.position)

	pass

static func create_falcondrop(start : Vector3, end : Vector3) -> Path3D:
	const fr_drop = 0.05
	const fr_glide = 0.15
	
	var path = Path3D.new()
	path.curve = Curve3D.new()
	
	var hdiff = start.y - end.y
	var dir : Vector3 = start - end
	dir.y = 0
	
	#var dist_len = dir.length()
	var p_drop = dir * fr_drop + start
	p_drop.y = start.y
	var p_glide = dir * fr_glide + start
	p_glide.y = hdiff * 0.3
	
	path.curve.add_point(start)
	path.curve.add_point(p_drop)
	path.curve.add_point(p_glide)
	path.curve.add_point(end)
	
	path.curve.bake_interval = 30
	
	return path

static func set_camera_pos_falcondrop_pos(dist : float, camera_ : Camera3D, followp : PathFollow3D, lookat_ : Node3D = null) -> void:
	followp.progress = dist
	camera_.global_position = followp.global_position
	if lookat_: camera_.look_at(lookat_.position)
	pass	
##Makes the camera follow a Path3D from start to end by tweening the PathFollow3D
static func make_follow(camera_ : Camera3D, falcondrop : Path3D, time_s : float, lookat_ : Node3D = null) -> void:
	var follow = PathFollow3D.new()
	follow.loop = false
	
	
	falcondrop.add_child(follow)
	var f : Callable = set_camera_pos_falcondrop_pos.bind(camera_, follow, lookat_)	
	var tween = camera_.create_tween()
	tween.tween_method(f, 0.0, falcondrop.curve.get_baked_length()*0.98, time_s)
	await tween.finished
	
	pass
	
static func generate_follow_falcondrop(fixed_node : Node3D, camera_ : Camera3D, time_s : float, end_target_ : Node3D, look_target_ : Node3D = null) -> void:
	var path3d = create_falcondrop(camera_.global_position, end_target_.global_position)
	fixed_node.add_child(path3d)	
	await make_follow(camera_, path3d, time_s,look_target_)
	fixed_node.remove_child(path3d)
	if fixed_node is FPV:
		fixed_node.set_mode_environment()
	return
	
	
	
