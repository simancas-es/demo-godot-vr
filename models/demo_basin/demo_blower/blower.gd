extends MachineToggleable
#Just the visuals
#class_name quest_concrete_basin_blower
var screen_mat : StandardMaterial3D

#Handles the visualiyation of being on and off

func _ready() -> void:
	set_material()
	
	
	turned_on.connect(on_on)
	turned_off.connect(on_off)
	super() ##Make sure we have the connections before we trigger the initial state

##Materials are shaded among all instances so we have to override the screen material
func set_material() -> void:
	screen_mat = $blower/schrank.get_active_material(1).duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	$blower/schrank.set_surface_override_material(1, screen_mat)


func on_on() -> void:
	screen_mat.albedo_color = Color(0, 1.0, 0.06, 1.0)
	pass
	
func on_off() -> void:
	screen_mat.albedo_color = Color(1.0, 0.0, 0.06, 1.0)
	pass
