extends Node3D
#class_name ItemInspect
const InventoryUtils := INVENTORY_UIDCLASSREF.InventoryUtils
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation

@onready var camera : Camera3D = %Camera3D
@onready var rotationnode : Node3D = %RotationNode
var current_model : Node3D = null

var distance_m : float = 0.2 #meters #TODO AUTOMATE

var rot_speed : float = 1
var camera_horizontal : Vector3 ##Horizontal axis for rotation
var camera_vertical : Vector3 ##Vertical axis for rotation

#rotate on its own
var auto : bool = false

##Gets the size of the object
static func get_obj_size(model_ : Node3D) -> float:
	#var sizem = (model.get_aabb().size.length())**0.33
	var aabb = InventoryUtils.get_node_aabb(model_).size
	var vector_len = aabb.length_squared()
	var sizem = (vector_len)**(1.0/3.0)
	return sizem

	
func init(model : Node3D):

	var children = rotationnode.get_children()
	if current_model in children:
		current_model.queue_free()
		rotationnode.remove_child(current_model)
		assert (current_model.is_queued_for_deletion())
		
	current_model = model
	if model == null : return
	
	rotationnode.add_child(current_model)
	current_model.visible = true	
	rotationnode.rotation = Vector3.ZERO
	
	#Move model so that its center is in the middle... #TODO HACK
	#Maybe just do this manually for each item. i.e. different item inspects
	var aabb = InventoryUtils.get_node_aabb(current_model)
	current_model.position = -aabb.get_center()
	
	
	
	
	var distance_m_ = get_obj_size(model)
	#Camera
	distance_m = distance_m_/3.5	
	camera.current = true
	#
	#var light = OmniLight3D.new()
	#light.omni_range = distance_m*3
	#light.omni_attenuation = 0.0
	#camera.add_child(light)
	
	camera.position = rotationnode.position + Vector3(-1,1,0) * distance_m
	camera.rotation = Vector3(deg_to_rad(-30), deg_to_rad(-90),0) ##Always look down using this angle
	reposition_camera()
	camera_horizontal = camera.get_global_transform().basis.x
	camera_vertical = camera.get_global_transform().basis.y

	start()
	
##Displays the 3D model of the object reprsented by ObjectInformation
func show_object(info : InventoryObjectInformation) -> void:
	if info == null:
		init(null)
		return
	var model_scene = info.inspect_model
	if model_scene == null:
		push_error("Missing model in % InventoryObjectInformation!!!" % info)
	
	var model = model_scene.instantiate()
	init(model)
	#TODO Animation
	
	pass
	
func stop():
	visible = false
	auto = false
	
func start():
	visible = true
	auto = false
	#Small pause between loading the inspect and starting to spin
	var timer = InventoryUtils.create_timer(self,1, true, func(): self.auto = true)
	timer.start()
	
func reposition_camera():
	var normal : Vector3 = camera.get_global_transform().basis.z #normal camera
	var objxyz : Vector3 = rotationnode.global_transform.origin

	var new_pos = InventoryUtils.ray_intersects_at(objxyz, normal, distance_m)
	camera.position = new_pos
	return

func process_physics(delta: float) -> void:
	var horizontal =  Input.get_axis(INVENTORYUISETTINGS.ACTION_LEFT, INVENTORYUISETTINGS.ACTION_RIGHT) ##TODO Inyect input somewhere else
	var vertical = Input.get_axis(INVENTORYUISETTINGS.ACTION_DOWN, INVENTORYUISETTINGS.ACTION_UP)
	#var vector : Vector3 = Vector3(vertical, 0, horizontal)

	if current_model != null:
		rotationnode.rotate(camera_vertical, PI/2 * delta * horizontal)
		rotationnode.rotate(camera_horizontal, PI/2 * delta * -vertical) #TODO maybe rotate differently
	
func process_frame(delta: float) -> void:
	if auto:
		rotationnode.rotate(Vector3.UP, PI/2 * delta * 1)
