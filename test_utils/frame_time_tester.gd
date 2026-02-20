extends Node3D
## Watch frame time in ms. For 60 FPS it has to stay under 16ms. We can assume that processing
## will take about 6ms, so this leaves us a budget of 10ms for graphics, and to be consistent
## should stay under 8 ms maybe.


@onready var mm_instance: MultiMeshInstance3D = $MultiMeshInstance3D
@onready var slider: HSlider = $CanvasLayer/HSlider
@onready var label: Label = $CanvasLayer/Label

var triangles_per_instance := 100
var multimesh := MultiMesh.new()

func _ready():
	create_base_mesh(triangles_per_instance)
	configure_multimesh()
	slider.value_changed.connect(_on_slider_changed)
	_on_slider_changed(slider.value)

func create_base_mesh(tri_count: int):
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()

	for i in range(tri_count):
		var offset = Vector3(
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5)
		)

		vertices.append(offset)
		vertices.append(offset + Vector3(0.1, 0, 0))
		vertices.append(offset + Vector3(0, 0.1, 0))

		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)

	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	multimesh.mesh = mesh

func configure_multimesh():
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = 0
	mm_instance.multimesh = multimesh

func _on_slider_changed(value: float):
	var instance_count = pow(2,int(value))
	multimesh.instance_count = instance_count

	for i in range(instance_count):
		var t = Transform3D()
		t.origin = Vector3(
			randf_range(-20, 20),
			randf_range(-20, 20),
			randf_range(-20, 20)
		)
		multimesh.set_instance_transform(i, t)

	update_label(instance_count)

func update_label(instance_count: int):
	var total_tris = triangles_per_instance * instance_count
	label.text = "Instances: %d\nTris per instance: %d\nTotal tris: %d" % [
		instance_count,
		triangles_per_instance,
		total_tris
	]
