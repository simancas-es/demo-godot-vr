extends Node
class_name UTILS

const zerodir2 : Vector2 = Vector2(0,0)
const zerodir3 : Vector3 = Vector3(0,0,0)

##Not used...
static func create_cubemap_from_texture(texture : Texture2D) -> Cubemap:
	# Fill in an array of Images with different colors.
	var images = []
	var image = texture.get_image()
	#ResourceSaver.save(image, "res://test_image.res") #saves correctly
	var size = image.get_size()
	var y = size.y
	var x = size.y
	const LAYERS = 6
	
	for i in LAYERS:
		#var sideimg = Image.create_empty(y, y, false, image.get_format())
		var corner = Vector2i(i*y,0)
		var side = image.get_region(Rect2i( corner, Vector2i(x, x) ) )
		#sideimg.blit_rect(image,Rect2i(corner, Vector2i(y,y)),Vector2i.ZERO)
		images.push_back(side)
		#ResourceSaver.save(sideimg, "res://test_side.res") #saves correctly



	# Create and save a cubemap. The array of images must have exactly 6 Images.
	# The cubemap's images are specified in this order: X+, X-, Y+, Y-, Z+, Z-
	# (in Godot's coordinate system, so Y+ is "up" and Z- is "forward").
	var cubemap = Cubemap.new()
	var error = cubemap.create_from_images(images)
	print(error)
	ResourceSaver.save(cubemap, "res://test_cubemap.res", ResourceSaver.FLAG_COMPRESS)
	return cubemap




#@onready var outline_shader = preload("res://shaders/outline.gdshader")
##Returns a MeshInstance3D with an ORMMaterial3d 
static func draw_surface(pos_array_triangles : Array[Vector3], color = Color.RED) -> MeshInstance3D:
	#Each 3 points has to be a triangle
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
	var p = 0
	var n = pos_array_triangles.size()
	while p < n:
		immediate_mesh.surface_add_vertex(pos_array_triangles[p])
		p += 1
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mesh_instance
	
	
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

	
static func make_node3d_interactable(mesh : MeshInstance3D) -> InteractivePanel:
	#Makes a node interactable by adding an Area3D with
	#a collision shape using its own mesh
	#and calling a function whenever an interacting camera interacts with it
	#by activating communicate_interact
	var faces = mesh.mesh.get_faces()
	var ip = InteractivePanel.new(faces, Color(0.8, 0.2, 0.2, 1), true)
	mesh.add_child(ip)
	return ip


static func get_polygon_points_3d(polygon : PackedVector2Array, L : int, W : int) -> Array[Vector3]:
	#param W, L width, height of panorama
	#for a polygon on the panorama
	var array : Array[Vector3] = []
	for point in polygon:
		var p3 = UTILS.rect_to_3d(point.x, point.y, L, W)
		array.append(p3)
	return array
	
##TODO: Optimize by caching the results
static func get_keys_from_action(action_name: String) -> PackedStringArray:
	var keys = PackedStringArray([])
	var events = InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			keys.append(OS.get_keycode_string(event.physical_keycode))
	return keys

static func log2_int(n):
	var count = 0
	while n > 1:
		n /= 2
		count += 1
	return count



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

##Returns the angle between two Node3Ds and their forward directions in radians.
static func get_angle_between_forward_vectors(a: Node3D, b: Node3D) -> float:
	var a_forward = a.global_transform.basis.z.normalized()
	var b_forward = -b.global_transform.basis.z.normalized()
	return a_forward.angle_to(b_forward)

static func get_cosine_two_forwards(a : Node3D, b: Node3D) -> float:
	var a_forward = a.global_transform.basis.z.normalized()
	var b_forward = b.global_transform.basis.z.normalized()
	return a_forward.dot(b_forward)

##Gets distance to object along path. -1 if not found
static func get_distance_to_body(from_global : Vector3, to_global : Vector3, object : PhysicsBody3D) -> float:
	var space_state = object.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from_global
	params.to = to_global
	params.collide_with_areas = true
	params.hit_back_faces = true
	params.hit_from_inside = true
	params.collide_with_bodies = true
	var excluded_objects = [] #Will be excluding everything until we reach either our object or nothing.
	params.exclude = excluded_objects
	params.collision_mask = object.collision_layer
	
	var result = space_state.intersect_ray(params)
	while result != {} :
		if result.collider == object:
			return from_global.distance_to(result.position)
		else:
			excluded_objects.append(result.collider)
			params.exclude = excluded_objects
			result = space_state.intersect_ray(params)
	return -1
		
			

static func wrap_angle(angle_rad: float) -> float:
	while angle_rad > PI:
		angle_rad -= 2.0 * PI
	while angle_rad < -PI:
		angle_rad += 2.0 * PI
	return angle_rad

## 9 (8 + 1) returns [0, 3]
static func get_set_bit_positions(bitmask: int) -> Array[int]:
	var positions : Array[int] = []
	var index = 0
	while bitmask > 0:
		if bitmask & 1:
			positions.append(index)
		bitmask >>= 1
		index += 1
	return positions
	

static func enum_to_dict(e: Dictionary) -> Dictionary[String, int]:
	var d: Dictionary[String, int] = {}
	for key in e.keys():
		d[str(key)] = int(e[key])
	return d
