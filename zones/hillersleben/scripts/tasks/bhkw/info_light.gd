extends MeshInstance3D

@export var pulse_speed: float = 3.0
@export var pulse_strength: float = 2.0
@export var base_energy: float = 1.0
@export var active: bool = true

var mat: StandardMaterial3D
var current_color: Color = Color(0, 1, 0) # default green

func _ready():
	# Get and duplicate material so it's unique to this instance
	mat = get_active_material(0)
	if mat:
		mat = mat.duplicate()
		set_surface_override_material(0, mat)
	else:
		push_error("No material found on mesh surface 0")
		return

	# Ensure emission is enabled
	mat.emission_enabled = true

	# Apply initial color
	_apply_color(current_color)


func _process(delta):
	if not active or mat == null:
		return

	var t = Time.get_ticks_msec() / 1000.0
	var pulse = sin(t * pulse_speed) * pulse_strength
	mat.emission_energy = base_energy + pulse


func change_color(color: Color):
	current_color = color
	_apply_color(color)


func activate():
	active = true


func deactivate():
	active = false
	if mat:
		mat.emission_energy = base_energy


func _apply_color(color: Color):
	if mat == null:
		return

	mat.albedo_color = color
	mat.emission = color
