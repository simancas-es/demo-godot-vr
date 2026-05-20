extends MeshInstance3D

@onready var button : MachineToggleable = $"../MachineToggleable"


func _ready() -> void:
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	
	if button.is_on():
		_on_on()
	else:
		_on_off()
	
	#print("Button State: %s, Mesh color: %s" % [button.current_state, get_active_material(0).albedo_color])
	pass


func _on_on(...args) -> void:
	modulate(Color(0, 1, 0))  # RGB: green
	pass
	
func _on_off(...args) -> void:
	modulate(Color(1, 0, 0.0))  # RGB: green
	pass


func modulate(color : Color) -> void:
	var mat = self.get_active_material(0)
	if mat: 
		# If it's a StandardMaterial3D, change the albedo color
		if mat is StandardMaterial3D:
			mat.albedo_color = color
		else:
			print("Material is not a StandardMaterial3D")
	else:
		# If no material exists, create one
		var new_mat = StandardMaterial3D.new()
		new_mat.albedo_color = color
		self.set_surface_override_material(0, new_mat)
