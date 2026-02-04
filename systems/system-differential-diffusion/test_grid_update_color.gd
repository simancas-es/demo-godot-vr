extends MeshInstance3D

var label : Label3D
var vol : SystemDifferentialDiffusionVolume
var current_conc : float = 0.0
func _ready() -> void:
	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.text = " -1.0"
	label.fixed_size = true
	label.no_depth_test = true
	
	add_child(label)
	
	for child in get_children():
		if child is SystemDifferentialDiffusionVolume:
			vol = child
			vol.updated_concentration.connect(update_color)
			break
	update_color(-1.0)
	
	
func on_clicked():
	vol.set_concentration(vol.current_concentration + 2.0)

func update_color(_new_concentration : float) -> void:
	current_conc = vol.current_concentration
	#current_conc = _new_concentration
	var mat : StandardMaterial3D = get_active_material(0)
	var color : Color = Color(clampf(1.0 - current_conc/6.0, 0.0, 1.0), clampf(current_conc/6.0, 0.0, 1.0), 0.0, 1.0)
	mat.albedo_color = color
	label.text = "%.2f" % current_conc
	print("Changed color of ", self, " to ",  color)
	
