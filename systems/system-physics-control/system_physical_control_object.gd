extends RigidBody3D
class_name SystemPhysicalControlObject

##Icons for showing the grabbing position and whether it is grabable
##The scenes must be set up so that it is rendered on top of everything else at constant size
const icon_grab_on : PackedScene = SYSTEMPHYSICALCONTROLSETTINGS.GRAB_ACTIVATED_ICON
const icon_grab_available : PackedScene = SYSTEMPHYSICALCONTROLSETTINGS.GRAB_AVAILABLE_ICON

var icon_available_obj : Node3D = null

@export var type : FREEDOM = FREEDOM.STATIONARY_XZ

#var _get_camera_force : Callable#[Vector2i, Camera3D]

var is_grabbed : bool = false
var grabbed_from_local : Vector3 = Vector3.ZERO

signal stopped_being_grabbed

enum FREEDOM {
	OBJECT, ##Objects move vertically and horizontally at a fixed distance from the camera (boxes)
	STATIONARY_XZ, ##Stationary object that reacts to forces in the XZ plane (doors)
	STATIONARY_XY, ##Stationary object that reacts to forces in the XY Plane (levers)
}
enum ERROR {
	FAILED,
	SUCCESS
}



func _ready() -> void:
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	set_collision_layer_value(SYSTEMPHYSICALCONTROLUTILS.log2_int(SYSTEMPHYSICALCONTROLSETTINGS.COLLISION_LAYER) + 1, true)
	set_collision_mask_value(SYSTEMPHYSICALCONTROLUTILS.log2_int(SYSTEMPHYSICALCONTROLSETTINGS.COLLISION_LAYER) + 1, true)
	
	for bit in SYSTEMPHYSICALCONTROLUTILS.get_set_bit_positions(SYSTEMPHYSICALCONTROLSETTINGS.OTHER_COLLISION_LAYER_MASK):
		set_collision_mask_value(bit + 1, true)
		set_collision_layer_value(bit + 1, true)

	icon_available_obj = icon_grab_available.instantiate()
	add_child(icon_available_obj)
	icon_available_obj.visible = false
	pass
##Shows and hides the icon
func show_available_icon_at(local_position : Vector3) -> void:
	icon_available_obj.position = local_position
	icon_available_obj.visible = true
	
func hide_available_icon() -> void:
	icon_available_obj.visible = false

	
##Sets an object at the grabbing position.
static func set_grabbing_icon_at(obj : SystemPhysicalControlObject, local_position : Vector3) -> void:
	var icon = icon_grab_on.instantiate()
	obj.add_child(icon)
	icon.global_position = obj.to_global(local_position) 	
	obj.stopped_being_grabbed.connect(icon.queue_free, CONNECT_ONE_SHOT)

	
func is_being_grabbed() -> bool:
	return is_grabbed

func grab(local_position : Vector3) -> ERROR:
	if false: return ERROR.FAILED # TODO Add conditions
	
	is_grabbed = true
	grabbed_from_local = local_position
	#DEBUG #Could be an icon
	set_grabbing_icon_at(self, local_position)
	hide_available_icon()
	gravity_scale = 0.0
	
	match type:
		FREEDOM.OBJECT:
			linear_damp = 10.0

	return ERROR.SUCCESS

func release() -> ERROR:
	is_grabbed = false
	grabbed_from_local = Vector3.ZERO
	stopped_being_grabbed.emit()
	gravity_scale = 1.0
	match type:
		FREEDOM.OBJECT:
			linear_damp = 0.0

	return ERROR.SUCCESS

##Normal objects stop moving when the moouse stops moving
##They do not rotate as they move
##Moves the item up and down but doesnt follow the camera center
static func apply_force_from_camera_object(object : SystemPhysicalControlObject,
									 mousepos_delta: Vector2,
									 camera : Camera3D,
									 delta: float,
									strength : float = 100.0) -> void:
	
	var force = SystemPhysicalControlObject.get_force_vector_vertical(mousepos_delta, camera)
	object.apply_force(force*delta*strength, object.to_global(object.grabbed_from_local))


##Forces are locally applied
static func apply_force_from_camera_stationary(object : SystemPhysicalControlObject,
												 mousepos_delta: Vector2,
												 camera : Camera3D,
												 delta: float,
												strength : float = 100.0) -> void:
	if mousepos_delta.is_zero_approx():
		object.angular_damp = 1.0
	else:
		object.angular_damp = 20.0
		
	var force = SystemPhysicalControlObject.get_force_vector_horizontal(mousepos_delta, camera)
	object.apply_force(force*delta*strength, object.to_global(object.grabbed_from_local))


#Applies force so that the grab point goes to another point in 3d space
static func apply_force_to_follow_point(object : SystemPhysicalControlObject,
										 point_global : Vector3,
										_delta : float,
										strength : float = 100.0) -> void:
	#The further away the stronger the force
	var force_dir = point_global - object.to_global(object.grabbed_from_local)
	var force = force_dir*strength
	#object.apply_force(force, object.to_global(object.grabbed_from_local))
	object.apply_central_force(force) #No rotation
	return
		
func apply_force_from_camera( mousepos_delta: Vector2,
							 camera : Camera3D,
							 delta: float,
							strength : float = 100.0) -> void:
	apply_force_from_camera_stationary(self, mousepos_delta, camera, delta, strength)

func force_follow_point(point_global : Vector3,
						delta : float,
						strength : float = 100.0) -> void:
	apply_force_to_follow_point(self, point_global, delta, strength)
	
	pass

func apply_force_from_movement(movdir_global : Vector3,
								 delta: float,
								strength : float = 100.0):
	if type == FREEDOM.OBJECT:
		var force = movdir_global * delta * strength
		self.apply_force(force, self.to_global(self.grabbed_from))

##Transforms the mousepos_delta coordinates into a force vector.
##The direction left and right are left and right with respect to the camera
##The direction up and down represent forward and backwards with repect to the camera
static func get_force_vector_horizontal(mousepos_delta : Vector2i, camera : Camera3D) -> Vector3:
	var cambasis := camera.global_transform.basis
	var forward := -cambasis.z.normalized()
	var right := cambasis.x.normalized()
	var result = forward * -mousepos_delta.y + right*mousepos_delta.x #Up->forward.
	return result

static func get_force_vector_vertical(mousepos_delta : Vector2i, camera : Camera3D) -> Vector3:
	var cambasis := camera.global_transform.basis
	var up := cambasis.y.normalized()
	#var up := Vector3.UP
	var right := cambasis.x.normalized()
	var result = up * -mousepos_delta.y + right*mousepos_delta.x #Up->forward.
	return result
