extends Node
#class_name InventoryUtils

const zerodir2 : Vector2 = Vector2(0,0)
const zerodir3 : Vector3 = Vector3(0,0,0)

	
static func array1_in_array2(array1 : Array, array2 : Array) -> bool:
	"""Checks if any array in item 1 is in array2"""
	for item in array1:
		if array2.has(item): return false
	return true
	
##For the inspection window
static func ray_intersects_at(origin : Vector3, direction : Vector3, height : float) -> Vector3:
	"""Returns at what point a ray intersects a certain height"""
	var f = (height - origin.y)/direction.y #(b - f·y) = altitude
	var intersection = Vector3(origin.x + f*direction.x,
								origin.y + f*direction.y,
								origin.z + f*direction.z)
	return intersection
#
#static func angle_difference(a1, a2) -> float:
	#return 180 - abs(abs(a1 - a2) - 180); 
	
static func pause_node(node : Node, pause : bool):
	if pause:
		node.process_mode = node.PROCESS_MODE_DISABLED
	else:
		node.process_mode = node.PROCESS_MODE_INHERIT
	
static func create_timer(parent : Node, time_s : float, oneshot : bool, function : Callable, autostart : bool = false) -> Timer:
	"""Returns a recurring or not timer that
	has to be .start()ed
	"""
	var timer = Timer.new()
	parent.add_child(timer)
	timer.autostart = autostart
	timer.wait_time = time_s
	timer.one_shot = oneshot
	timer.timeout.connect(function)
	return timer


static func rect_to_3d(x : float, z : float, L, W) -> Vector3:
	#Transforms a +x (horizontal right), +z(vertical down) coordinate
	#into 3D. Center is L/2 and W/2
	var cx = 2*(x)/W -1 # from 0 to 1 -> from -1 to +1
	var cy = 2*(1 - z/L) -1   # from 0 (bottom) to 1(top) -> from -1 to +1
	
	#var phi = PI/2.0 - cy * PI/2.0 #colatitude
	var phi = cy * PI/2.0 #colatitude
	var lon = cx * PI - PI/2.0	
	
	var sx = cos(phi) * cos(lon) * 1
	var sy = sin(phi) * 1	
	var sz = cos(phi) * sin(lon) * 1
	
	var vect = Vector3(sx,sy,sz)
	return vect

	

static func get_node_aabb(node : Node3D = null, ignore_top_level : bool = true, bounds_transform : Transform3D = Transform3D()) -> AABB:
	var box : AABB
	var transform : Transform3D

	# we are going down the child chain, we want the aabb of each subsequent node to be on the same axis as the parent
	if bounds_transform.is_equal_approx(Transform3D()):
		transform = node.global_transform
	else:
		transform = bounds_transform
	
	# no more nodes. return default aabb
	if node == null:
		return AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	# makes sure the transform we get isn't distorted
	var top_xform : Transform3D = transform.affine_inverse() * node.global_transform

	# convert the node into visualinstance3D to access get_aabb() function.
	var visual_result : VisualInstance3D = node as VisualInstance3D
	if visual_result != null:
		box = visual_result.get_aabb()
	else:
		box = AABB()
	
	# xforms the transform with the box aabb for proper alignment I believe?
	box = top_xform * box
	# recursion
	for i : int in node.get_child_count():
		var child : Node3D = node.get_child(i) as Node3D
		if child && !(ignore_top_level && child.top_level):
			var child_box : AABB = get_node_aabb(child, ignore_top_level, transform)
			box = box.merge(child_box)
	
	return box

##Reads a json file, if path is invalid, it returns a default json
static func read_json(path : String, default_path : String) -> Dictionary:
	if (path == "") or not FileAccess.file_exists(path):
		path = default_path
		push_warning("Missing file at %s ." % path)
	
	if FileAccess.file_exists(path):
		var data = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(data.get_as_text())
		if not (parsed is Dictionary): push_error("Bad JSON! %s" % path)
		return parsed
	else:
		push_error("Missing file at %s ." % path)
		return {}
