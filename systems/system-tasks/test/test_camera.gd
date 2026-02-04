extends Camera3D

@export var ray_length: float = 20.0

var line_mesh: ImmediateMesh
var line_instance: MeshInstance3D

func _ready() -> void:
	# Create a line mesh to visualize the ray
	line_mesh = ImmediateMesh.new()
	line_instance = MeshInstance3D.new()
	line_instance.mesh = line_mesh
	add_child(line_instance)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#var mousepos = get_viewport().get_mouse_position()
		_cast_ray(event.position)

func _cast_ray(screen_pos: Vector2) -> void:
	var from = self.project_ray_origin(screen_pos)
	var to = from + self.project_ray_normal(screen_pos) * ray_length

	# Perform raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	# If something was hit → change color
	if result:
		var collider = result["collider"]
		to = result.position # ray stops at hit point
		if collider is StaticBody3D:
			var mesh: MeshInstance3D = collider.get_parent()
			if mesh:
				_change_color(mesh)
				mesh.clicked.emit() #TEST
			
	# Draw ray line permanently
	_draw_ray(from, to)

func _draw_ray(from: Vector3, to: Vector3) -> void:
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	line_mesh.surface_add_vertex(to_local(from)) #line_mesh is children of camera.
	line_mesh.surface_add_vertex(to_local(to))
	line_mesh.surface_set_color(Color(1, 0, 0)) # red
	line_mesh.surface_end()

func _change_color(mesh: MeshInstance3D) -> void:
	var mat = mesh.get_active_material(0)

	# Duplicate material if it's shared
	if mat and not mat.resource_local_to_scene:
		mat = mat.duplicate()
		mat.resource_local_to_scene = true
		mesh.set_surface_override_material(0, mat)

	if mat is StandardMaterial3D:
		mat.albedo_color = Color(randf(), randf(), randf())
		print("Emitting signal...", mat.albedo_color)
		
