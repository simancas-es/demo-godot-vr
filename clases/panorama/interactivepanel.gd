class_name InteractivePanel extends Interaction

var activatable  : bool = true
var collisionshape3d : CollisionShape3D = null
var visible_mesh : MeshInstance3D = null
var mesh_color : Color = Color(255,0,0,1)



func _ready()->void:
	#self.looked_at.connect(on_looked_at)
	#self.activated.connect(on_activated)
	add_child(collisionshape3d)
	add_child(visible_mesh)	
	monitoring = false
	pass # Replace with function body.

func load_interactive_surface(points_array : PackedVector3Array) -> void:
	#points_array is the collection of surface points
	var convexpoly = ConvexPolygonShape3D.new()
	convexpoly.points = points_array
	collisionshape3d.shape = convexpoly
	var meshhull = convexpoly.get_debug_mesh()
	var triangles : PackedVector3Array = meshhull.get_faces()
	visible_mesh = UTILS.draw_surface(triangles, mesh_color)
	
	##TODO Optimize, remove unused faces.

func load_interactive_faces(triangles : PackedVector3Array) -> void:
	var convexpoly = ConvexPolygonShape3D.new()
	convexpoly.points = triangles #TODO HORRIBLE
	collisionshape3d.shape = convexpoly
	#self.visible_mesh = UTILS.draw_surface(triangles)
	return

func _init(points_array : PackedVector3Array, mesh_color_ : Color, triangles : bool = false,  visible_debug : bool = false) -> void:
	collisionshape3d = CollisionShape3D.new()
	visible_mesh = MeshInstance3D.new() #Redundant
	mesh_color = mesh_color_
	if !triangles:
		load_interactive_surface(points_array)
	else:
		load_interactive_faces(points_array)
	set_visible(visible_debug)


	
#func set_visible(activate : bool):
	#self.visible_mesh.visible = activate
