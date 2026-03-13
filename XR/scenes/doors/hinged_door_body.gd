extends RigidBody3D
const XR_DOORS_UID_CLASSREF = preload("uid://dbtdc5f1qkd3m")
##
## VR Hinged Door Body
##
## Door receives torque depending on how the grabbed handle moves.
## HingeJoint3D constrains the rotation axis.
##

@onready var parent : XR_DOORS_UID_CLASSREF.DoorHingedAPI = get_parent()

@export var DoorHandleGrab: XRToolsPickable
@export var DoorHandleOrigin: Node3D
@export var Hinge: HingeJoint3D #The door rotates on the XY plane of this joint
@export var DoorHandleModel : Node3D #A handle that will rotate with code

@export var requires_handle_turn: bool = true
@export var handle_turn_threshold_deg: float = 90.0
@export var latch_on_close: bool = true

@export var torque_multiplier: float = 40.0
@export var friction: float = 0.2
@export var close_force: float = 4.0

@export var velocity_average_samples: int = 5

var _handle_minimum_angle : float = 0.0
var _handle_maximum_angle : float = 0.0

var _handle_grabbed := false
var _latched := true

var _handle_base_basis: Basis
var _handle_base_position : Vector3 # Position of the handle when door is closed
var _handle_rotation_rad : float

var _body_a : CollisionObject3D
var _body_b : CollisionObject3D

var _deadzone = deg_to_rad(1.0)  # Dont move door when hand in the deadzone

var _initial_transform : Transform3D
var _closed_vec : Vector3
var _current_vec : Vector3
var _current_angle : float
var _target_angle : float



func _ready():
	_handle_base_basis = DoorHandleOrigin.global_transform.basis
	_handle_base_position = DoorHandleOrigin.global_transform.origin	


	DoorHandleGrab.picked_up.connect(_on_handle_grabbed)
	DoorHandleGrab.dropped.connect(_on_handle_released)
	
	_body_a = Hinge.get_node(Hinge.get_node_a())
	_body_b = Hinge.get_node(Hinge.get_node_b())
	
	_closed_vec = Hinge.global_transform.basis.y.normalized()
	_initial_transform = global_transform
	
	setup()

func setup() -> void:
	#Upper Limit of Hinge: XY Plane -> directon towards -Y.
	#So 45 Upper lets the door front (towards local +z, handle towards local +x) to half open.
	Hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(parent.door_maximum_angle))
	Hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(parent.door_minimum_angle))
	_handle_minimum_angle = deg_to_rad(parent.handle_minimum_angle)
	_handle_maximum_angle = deg_to_rad(parent.handle_maximum_angle)
	handle_turn_threshold_deg = parent.latch_angle
	
	pass
	
func reset_door():
	freeze = true
	global_transform = _initial_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = false

func _physics_process(delta):
	if _latched: angular_velocity.y = 0.0
	
	_current_vec = project_point_to_hinge_xy(Hinge, DoorHandleOrigin.global_transform.origin)
	_current_angle = get_signed_hinge_angle(Hinge, _current_vec, _closed_vec)
	
	if _handle_grabbed:
		# Handle latch logic
		if requires_handle_turn:
			_handle_rotation_rad = compute_handle_rotation()
			DoorHandleModel.rotation.z = clampf(_handle_rotation_rad, _handle_minimum_angle, _handle_maximum_angle)
			if not (parent.door_locked) and _latched and abs(rad_to_deg(_handle_rotation_rad)) >= handle_turn_threshold_deg:
				unlatch_door()
		else:
			_latched = false

		if not _latched:
			# Current vector from hinge to grabbed handle, projected onto hinge plane
			_target_angle = compute_target_door_angle()
			# Angle error for control
			var angle_error := _current_angle - _target_angle
			# Deadzone: stop if very close
			if abs(angle_error) < _deadzone:
				angular_velocity.y = 0
				return

			# Desired angular velocity proportional to angle error
			const max_angular_speed := 3.0  # rad/s, tune for responsiveness
			var desired_angular_velocity : float = clamp(angle_error * 5.0, -max_angular_speed, max_angular_speed)

			# Smoothly interpolate angular velocity for stability
			angular_velocity.y = lerp(angular_velocity.y, desired_angular_velocity, 0.6)

	elif not _latched:
		# Auto-close when not grabbed
		_apply_auto_close(delta)
		if parent.latch_on_close and (abs(_current_angle) < 0.02):
			latch_door()
			reset_door()

func _on_handle_grabbed(_pickable):
	_handle_grabbed = true


func _on_handle_released(_pickable):
	_handle_grabbed = false

func latch_door() -> void:
	if not _latched:
		parent._on_door_closed()
		_latched = true
		angular_velocity.y = 0.0
	pass
	
func unlatch_door() -> void:
	if _latched:
		parent._on_door_opened()
		_latched = false
	pass

func compute_target_door_angle() -> float:
	# Get the handle vector in hinge plane
	var t_vec = project_point_to_hinge_xy(Hinge, DoorHandleGrab.global_transform.origin)
	var t_angle = get_signed_hinge_angle(Hinge, t_vec, _closed_vec)
	return t_angle


func compute_handle_rotation() -> float:
	"""
	Returns rotation of the grabbed handle (DoorHandleGrab) around the local Z axis
	of the DoorHandleOrigin, scaled by how aligned the grabber's Z is with the handle Z.
	"""
	
	 # Local Z axis of the handle
	var handle_z := DoorHandleOrigin.global_transform.basis.z.normalized()
	 # Local Z axis of the grabber cube
	var grab_z := DoorHandleGrab.global_transform.basis.z.normalized()
	 # Alignment factor: dot product (1 = perfectly aligned, 0 = perpendicular)
	var alignment : float = clamp(handle_z.dot(grab_z), 0.0, 1.0)
	 # Relative rotation from handle to grabber
	var relative_basis := DoorHandleGrab.global_transform.basis.inverse() * DoorHandleOrigin.global_transform.basis
	 # Project the rotation around handle Z
	 # Formula: angle = atan2( Y_proj, X_proj ) in the plane perpendicular to Z
	 # Extract X and Y axes of grabber in handle space
	var x_axis := relative_basis.x
	var y_axis := relative_basis.y
	 # Compute rotation around Z in radians
	var angle := atan2(y_axis.dot(Vector3.RIGHT), x_axis.dot(Vector3.RIGHT))
	 # Scale by alignment so misaligned grabs contribute less
	return angle * alignment



static func get_hinge_angle(hinge: HingeJoint3D, current_vec: Vector3, closed_vec: Vector3) -> float:
	var hinge_axis := hinge.global_transform.basis.y.normalized() #y axis is the horizontal on the floor for the door plane
	return closed_vec.signed_angle_to(current_vec, hinge_axis)
	
	
func _apply_auto_close(delta):
	var angle_error := _current_angle
	var hinge_axis := Hinge.global_transform.basis.z.normalized()
	#Summing some torque to make it faster
	var torque : float = -(_current_angle + (sign(_current_angle)*0.7)) * (close_force / mass)

	apply_torque_impulse(hinge_axis * torque * delta)
	#angular_velocity *= (1.0 - friction * delta)
	
	
static func project_point_to_hinge_xy(hinge: HingeJoint3D, point: Vector3) -> Vector3:
	"""
	Projects a 3D world-space point onto the hinge's local XY plane and normalizes it.
	
	hinge: the HingeJoint3D whose XY plane we project onto
	point: world-space point to project
	returns: normalized vector from hinge origin to projected point in world space
	"""
	# Hinge origin and axes
	var hinge_origin := hinge.global_transform.origin
	var hinge_basis := hinge.global_transform.basis
	# Vector from hinge to point
	var vec := point - hinge_origin
	# Hinge Z axis = normal of the hinge XY plane
	var hinge_normal := hinge_basis.z.normalized()  # local Z axis is perpendicular to XY plane
	# Project vector onto XY plane (remove component along hinge Z axis)
	vec -= vec.dot(hinge_normal) * hinge_normal
	vec = vec.normalized()
	return vec
	
static func get_signed_hinge_angle(hinge: HingeJoint3D, current_vec: Vector3, reference_vec: Vector3) -> float:
	"""
	Returns the signed angle in radians between reference_vec and current_vec around the hinge axis.
	"""
	var hinge_axis := hinge.global_transform.basis.z.normalized()
	return reference_vec.signed_angle_to(current_vec, hinge_axis)
