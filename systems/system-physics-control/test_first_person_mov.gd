extends CharacterBody3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.1
@export var jump_velocity: float = 4.5
@export var gravity: float = 9.8

var mouse_delta := Vector2.ZERO

@onready var camera = $Camera3D
var y_rotation: float = 0.0  # For yaw (left/right)
var x_rotation: float = 0.0  # For pitch (up/down)

var grabber : SystemPhysicalControlGrabber

func _init() -> void:
	
	platform_floor_layers = SYSTEMPHYSICALCONTROLSETTINGS.LAYER_FLOOR
	platform_wall_layers = SYSTEMPHYSICALCONTROLSETTINGS.LAYER_WALLS
	
	set_collision_mask_value(SYSTEMPHYSICALCONTROLUTILS.log2_int(SYSTEMPHYSICALCONTROLSETTINGS.LAYER_FLOOR) + 1, true)
	set_collision_mask_value(SYSTEMPHYSICALCONTROLUTILS.log2_int(SYSTEMPHYSICALCONTROLSETTINGS.LAYER_WALLS) + 1, true)	
	set_collision_layer_value(SYSTEMPHYSICALCONTROLUTILS.log2_int(SYSTEMPHYSICALCONTROLSETTINGS.LAYER_FPVPLAYER) + 1, true)
	
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	#INIT GRABBER
	grabber = %SystemPhysicalControlGrabber
	grabber.init($Camera3D)
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _process(delta):
	_update_camera_rotation(delta)

func _physics_process(delta):
	_apply_gravity(delta)
	_process_movement(delta)

func _update_camera_rotation(_delta):
	y_rotation -= mouse_delta.x * mouse_sensitivity
	x_rotation -= mouse_delta.y * mouse_sensitivity
	x_rotation = clamp(x_rotation, -90, 90)

	rotation_degrees.y = y_rotation
	camera.rotation_degrees.x = x_rotation

	mouse_delta = Vector2.ZERO  # Reset after applying

func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_key_pressed(KEY_SPACE):
			velocity.y = jump_velocity

func _process_movement(_delta):
	var direction = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction -= transform.basis.z
	if Input.is_key_pressed(KEY_S):
		direction += transform.basis.z
	if Input.is_key_pressed(KEY_A):
		direction -= transform.basis.x
	if Input.is_key_pressed(KEY_D):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
			
	move_and_slide()
