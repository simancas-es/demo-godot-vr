extends Node
class_name SystemPhysicalControlGrabber

signal grabbed_stationary ##Object that stays on the ground, recommended to fix the camera. Levers, Doors...
signal grabbed_object ##Object that follows the camera center
signal stopped_grabbing 

enum STATE{NOT_GRABBING, GRABBING}
var current_state : STATE = STATE.NOT_GRABBING

var camera_active : Camera3D
var max_distance_m : float = SYSTEMPHYSICALCONTROLSETTINGS.DEFAULT_MAX_DISTANCE_GRAB #max distance to grabbed object
#const attraction_min_distance : float = 0.9 #attract objects to this distance if grabbed

#Detection
var mousepos_delta : Vector2i
var last_hovered_obj : SystemPhysicalControlObject = null

##Interrupting the line of sight drops the object.
##Except if its one of these objects (Character model for instance)
##Add items here or through add_raycast_excluded_object
@export var line_of_sight_drop_exclusion : Array[Node3D] = []
@export var body_movement_object : PhysicsBody3D = null ##Body that will collide with the objects, usually the CharacterBody3D.

#Physicsobject
var current_obj : SystemPhysicalControlObject = null
var _current_dist : float = 0.0 #current distance to grabbed object
var _current_obj_original_relative_rotation : Vector3 = Vector3.UP #Relative rotation of the camera

const MAX_DISTANCE_RAYCAST = 10000.0 #Assuming grabber isnt bigger than this number


func _ready():
	set_process_input(false)
	pass

func init(camera : Camera3D) -> void:
	camera_active = camera
	if camera: set_process_input(true)

func _input(event):
	if (current_state == STATE.NOT_GRABBING) and event.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_GRAB_NAME):
		var hit = get_obj_under_cursor(get_viewport().get_mouse_position())
		if hit: #Dictionary not empty
			var obj = hit.collider
			if obj is SystemPhysicalControlObject:
				var last_hit_pos = obj.to_local(hit.position)
				if hit.position.distance_to(camera_active.global_position) < max_distance_m:
					grab_object(obj, last_hit_pos)

	if (current_state == STATE.GRABBING) and not Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_GRAB_NAME): release_current_object()
	
	if event is InputEventMouseMotion and (current_state == STATE.GRABBING):		
		event = event as InputEventMouseMotion
		mousepos_delta = event.relative
		if event.relative.is_zero_approx():
			mousepos_delta = Vector2i.ZERO
			
	elif event is InputEventMouseMotion and (current_state == STATE.NOT_GRABBING):
		event = event as InputEventMouseMotion
		raycast_for_available_object(event.position)
		
	elif event.is_action(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_SEND_FURTHER) and (current_state == STATE.GRABBING):
		_current_dist = clampf(_current_dist + 0.1, 0.4, max_distance_m*0.8)
		get_viewport().set_input_as_handled()
	elif event.is_action(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_SEND_CLOSER) and (current_state == STATE.GRABBING):
		_current_dist = clampf(_current_dist - 0.1, 0.4, max_distance_m*0.8)
		get_viewport().set_input_as_handled()	


##Moves and collides the current_object so that going forward also moves this forward
##Do this in the physics step.
func correct_movement(expected_movement_delta : Vector3) -> void:
	if current_obj:
		current_obj.move_and_collide(expected_movement_delta)
		
		
func raycast_for_available_object(screenpos : Vector2) -> bool:
	var hit = get_obj_under_cursor(screenpos)
	if hit: #Dictionary not empty
		var obj = hit.collider
		if obj is SystemPhysicalControlObject:
			var last_hit_pos = obj.to_local(hit.position)
			if hit.position.distance_to(camera_active.global_position) < max_distance_m:
				if is_instance_valid(last_hovered_obj): last_hovered_obj.hide_available_icon()
				obj.show_available_icon_at(last_hit_pos)
				last_hovered_obj = obj
		return true
	else:
		if is_instance_valid(last_hovered_obj): last_hovered_obj.hide_available_icon()
		return false
		
func release_current_object() -> void:
	if current_obj:
		current_obj.release()
		current_obj = null
		stopped_grabbing.emit()
	current_state = STATE.NOT_GRABBING
	raycast_for_available_object(get_viewport().get_mouse_position())
	

	
func grab_object(obj : SystemPhysicalControlObject, local_obj_position : Vector3) -> void:
	if is_instance_valid(obj) : obj.grab(local_obj_position)
	else: return
	current_obj = obj
	current_state = STATE.GRABBING
	_current_dist = camera_active.global_position.distance_to(obj.to_global(local_obj_position))
	
	#Get original rotation when grabbed
	_current_obj_original_relative_rotation = current_obj.global_rotation - Vector3(0, camera_active.global_rotation.y, 0)
	
	if current_obj.type == SystemPhysicalControlObject.FREEDOM.OBJECT:
		grabbed_object.emit()
	else:
		grabbed_stationary.emit()
		
#Returns x,0,z with -z being 1, x being 1
static func get_input_movement() -> Vector3:
	var x : float = 0.0
	var z : float = 0.0
	if Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_MOVE_UP): z -= 1.0
	if Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_MOVE_DOWN): z += 1.0
	if Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_MOVE_RIGHT): x += 1.0
	if Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_MOVE_RIGHT): x -= 1.0
	
	return Vector3(x, 0, z)

static func get_input_zneg() -> Vector3:
	var v : Vector3 = Vector3(0,0,0)
	if Input.is_action_pressed(SYSTEMPHYSICALCONTROLSETTINGS.ACTION_MOVE_UP): v.z = -1.0
	return v
	
func get_obj_under_cursor(mousepos : Vector2i) -> Dictionary:
	var space = camera_active.get_world_3d().direct_space_state
	var ray_from = camera_active.global_position
	var ray_to = camera_active.project_position(mousepos, 1.5)	
	var query_params = PhysicsRayQueryParameters3D.create(ray_from, ray_to, SYSTEMPHYSICALCONTROLSETTINGS.COLLISION_LAYER) #Collision Layer
	var result = space.intersect_ray(query_params)
	return result

##Is the grabbed object inside or outside of the grabbing region,
##Or too far from us?
func is_inside_grab_region(object : SystemPhysicalControlObject) -> bool:
	if object and object.is_being_grabbed():
		var dist_to_point = object.to_global(object.grabbed_from_local).distance_to(camera_active.global_position)
		if dist_to_point > max_distance_m: return false
	#var grab_point = camera_active.unproject_position(object.to_global(object.grabbed_from_local))
	#var size = get_viewport().size
	#if grab_point.x > size.x*0.99 or grab_point.x < size.x*0.01: return false
	#if grab_point.y > size.y*0.99 or grab_point.y < size.y*0.01: return false
	return true

##Return closest collision that isnt the grabbed object, camera or others
##Either returns a collision against a wall or the target_point_global itself 
static func get_closest_line_of_sight_collision(target_point_global : Vector3, object : SystemPhysicalControlObject, camera: Camera3D, excluded_bodies : Array[Node3D]) -> Dictionary:
	var from = camera.global_transform.origin
	var to = target_point_global
	var space_state = object.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.hit_back_faces = false
	params.exclude = [camera, object] + excluded_bodies
	var combined_collision_mask = SYSTEMPHYSICALCONTROLSETTINGS.OTHER_COLLISION_LAYER_MASK
	params.collision_mask = combined_collision_mask
	var result = space_state.intersect_ray(params)
	return result
	
static func is_object_between(object: SystemPhysicalControlObject, camera: Camera3D, excluded_bodies : Array[Node3D]) -> bool:
	var from = camera.global_transform.origin
	var to = object.to_global(object.grabbed_from_local)
	var space_state = object.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.hit_back_faces = false
	params.exclude = [camera, object] + excluded_bodies
	var combined_collision_mask = SYSTEMPHYSICALCONTROLSETTINGS.OTHER_COLLISION_LAYER_MASK
	params.collision_mask = combined_collision_mask
	var result = space_state.intersect_ray(params)

	if result:
		return true
	return false


func _physics_process(delta: float) -> void:
	if not current_obj: return
	if (
		(not is_inside_grab_region(current_obj))
		or
		(is_object_between(current_obj, camera_active, line_of_sight_drop_exclusion))
		):
		release_current_object()
		return
		
	#BUG: If the object is in front of the camera, the movement gets stuck,
	#Dont Replicate movement with keys:	Parent is responsible for implementing this movement forward.
	#var mov_input = get_input_movement()
	#var mov_input = get_input_zneg()
	#var movdir = camera_active.to_global(mov_input);# movdir.y = 0; movdir.x = 0; movdir.z = min(movdir.z, 0)
	
	if current_obj.type == SystemPhysicalControlObject.FREEDOM.STATIONARY_XZ:		
			#If the item is stationary, dont let the camera move, and apply movement by mousepos_delta
			current_obj.apply_force_from_camera(mousepos_delta, camera_active, delta)

	elif current_obj.type == SystemPhysicalControlObject.FREEDOM.STATIONARY_XY:
			#If the item is stationary, dont let the camera move, and apply movement by mousepos_delta
			current_obj.apply_force_from_camera(mousepos_delta, camera_active, delta)
	
	if current_obj.type == SystemPhysicalControlObject.FREEDOM.OBJECT:
			#1- If it's a normal object, apply the force in the direction of a point in the center of the camera
			var _center_point = camera_active.project_position(get_viewport().size/2, _current_dist)
			var current_obj_global_grabpoint = current_obj.to_global(current_obj.grabbed_from_local)
			
			##Check if there is a wall closer than the center point and correct for it
			var _target_point = get_closest_line_of_sight_collision(_center_point, current_obj, camera_active, line_of_sight_drop_exclusion)
			if _target_point:
				_center_point = _target_point.position
			
			##CHECK FOR COLLISIONS WHEN GETTING CLOSER TO CENTER POINT
			if body_movement_object:
				#Correct center point. So that if the object is closer than the body, it should get pushed back.
				#Center point could be inside of the body, which gives a -1 distance.
				var point_far_away = camera_active.project_position(get_viewport().size/2, MAX_DISTANCE_RAYCAST)
				var distance_to_body = SYSTEMPHYSICALCONTROLUTILS.get_distance_to_body(camera_active.global_position, point_far_away, body_movement_object)
				
				var distance_to_object = SYSTEMPHYSICALCONTROLUTILS.get_distance_to_body(camera_active.global_position, _center_point, current_obj)
				if distance_to_object == -1: #Object is further away from the centerpoint
					pass
				else:
					var margin = max(0, distance_to_body - distance_to_object)
					if margin > 0 :
						_center_point = camera_active.project_position(get_viewport().size/2, _current_dist + margin * 1.01)
						_current_dist = _current_dist + margin * 1.01
				
				#Moving the item in a diagonal can make it that the corners collide
				#with the body and thus can not continue and get stuck.
				#In this case try to separate the object from the body
				#Check if moving the centerpoint towards the player creates any collisions.
				##Objects do not rotate while picked up, so its just move and collide
				var step = (max_distance_m - _current_dist) / 10 #Try 10 times
				for s in range(10):
					var collides = true
					var extra_distance = s*step
					_center_point = camera_active.project_position(get_viewport().size/2, _current_dist + extra_distance)
					var collision : KinematicCollision3D = current_obj.move_and_collide(_center_point - current_obj_global_grabpoint , true)
					if collision and (collision.get_collision_count() > 0): #Centerpoint is too close
						for c in range(collision.get_collision_count()):
							collides = false
							if collision.get_collider(c) == body_movement_object:
								##Collides and therefore it is not a valid centerpoint at this moment.
								#Ṭry again moving outwards
								collides = true
								break #We break the for look						
						#If we get here then we didnt collide with the body
					else: break #No collisions so all good.
					if not collides: break
				##BUG: If the camera moves too fast then the objects get stuck behind the camera.
				##Solved if we create a curve with centerpoints and make objects follow it
				##Or just drop if the objects are too far away from the center.
			
			current_obj.force_follow_point(_center_point, delta)
			
			
			
			##2- Rotate to keep the rotation it had when it was first grabbed
			##We go from current angular velocity to the desired one until the desired_yaw is 0
			var desired_rotation = Vector3(0, camera_active.global_rotation.y, 0) + _current_obj_original_relative_rotation
			var current_rotation = current_obj.global_rotation
			var rotation_error = Vector3(
									0, #UTILS.wrap_angle(desired_rotation.x - current_rotation.x),  # X-axis (pitch)
									SYSTEMPHYSICALCONTROLUTILS.wrap_angle(desired_rotation.y - current_rotation.y),  # Y-axis (yaw) 
									0, #UTILS.wrap_angle(desired_rotation.z - current_rotation.z)   # Z-axis (roll)
									)
			
			#print("Rotation error : %s" % rotation_error)
			if rotation_error.length() > 0.001:
				var correction_strength_s = 1.0 #seconds to correct
				var target_angular_velocity = rotation_error / correction_strength_s #rad/s
				var current_angular_velocity = current_obj.angular_velocity #rad/s
				var torque = (target_angular_velocity - current_angular_velocity) * current_obj.mass
				if current_angular_velocity.length() > 1:
					pass
				var max_torque = current_obj.mass * 1.0
				if torque.length() > max_torque:
					torque = torque.normalized() * max_torque
				var damping = current_angular_velocity * 0.3 * current_obj.mass
				torque -= damping
				current_obj.apply_torque(torque)
