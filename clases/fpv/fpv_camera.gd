extends Camera3D
class_name FPVCamera

@onready var interaction_logic : FPVInteractionLogic = %InteractionLogic

#Labels in the middle of the screen.
@onready var center_aim_x : Label = %CenterAim
@onready var action_hints : VBoxContainer = %ActionHints

var sensitivity : float = 1 ##Injected from parent?
#var lookdir : Vector2 = Vector2.ZERO

var raycast_fixed : RayCast3D = RayCast3D.new() ##Fixed camera ray #TODO:Optimize
#var _DEBUG_ray_fixed : bool = true

func _ready() -> void:
	add_child(raycast_fixed)	
	#setup_rayfixed()
	setup_actionhints()
	interaction_logic.updated_interactables.connect(update_actionhints)
	
func set_background(image : CompressedTexture2D):
	#Sets the background to a specific image
	if not image:
		environment = null
		return
	environment = load(RESOURCES.CAMERA_PANO_SKY) #4.5
	if not environment:
		push_error("Missing camera environment!! at %s . Couldn't load %s " % [self, RESOURCES.CAMERA_PANO_SKY])
		return
	environment.sky.sky_material.panorama = image #4.5
	
	
##pre-populates the hints depending on the number of actions
func setup_actionhints() -> void:
	for action in ENUMS.ACTION_KW.keys(): #Always in the same order
		var label = Label.new() ##TODO: Add label style
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		action_hints.add_child(label)
	return
	

##Gets for each available action an object that has it
func update_actionhints()-> void:
	var i = -1
	var hint_labels_camera = action_hints.get_children()
	var updated_hint_texts = interaction_logic.get_updated_interactable_action_hints()
	
	if updated_hint_texts.size() > hint_labels_camera.size():
		push_error("Mismatch between Camera hints and Action_KW!!!")
		return
		
	for c in range(hint_labels_camera.size()):
		var l : Label = hint_labels_camera[c]
		l.text = "" # NO_TRANSLATE
		l.visible = false
		l.label_settings = center_aim_x.label_settings
		
		l.text = updated_hint_texts[c]
		if l.text != "": l.visible = true
	
	return

##For Fixed Camera. Casts a ray from the mouse position on the screen.
func cast_ray(mousepos_ : Vector2, ray_length : float = 200.0) -> void:
	var dir = project_local_ray_normal(mousepos_) * ray_length
	raycast_fixed.target_position = dir	
	if raycast_fixed.is_colliding():
		var item = raycast_fixed.get_collider()
		if not (item is Interaction):  return
		interaction_logic._update_eye_collision(item)
	else:
		interaction_logic._update_eye_collision(null) ##HACK. TODO: multiple collisions



func mousewheelup() -> void:
	fov = max(fov * 0.9, 5.0)
func mousewheeldown() -> void:
	fov = min(fov * 1.1, 179.0)
