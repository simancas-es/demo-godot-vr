extends Node3D
class_name XRToolsInteractableJoystickGeneral

@onready var ij : XRToolsInteractableJoystick = %InteractableJoystick
signal joystick_moved(x_angle, y_angle)

#Hacky
## Joystick X minimum limit
@export var joystick_x_limit_min : float = -45.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_x_limit_min(value)

## Joystick X maximum limit
@export var joystick_x_limit_max : float = 45.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_x_limit_max(value)

## Joystick Y minimum limit
@export var joystick_y_limit_min : float = -45.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_y_limit_min(value)

## Joystick Y maximum limit
@export var joystick_y_limit_max : float = 45.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_y_limit_max(value)

## Joystick X step size (zero for no steps)
@export var joystick_x_steps : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_x_steps(value)

## Joystick Y step size (zero for no steps)
@export var joystick_y_steps : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_y_steps(value)

## Joystick X position
@export var joystick_x_position : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_x_position(value)

## Joystick Y position
@export var joystick_y_position : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_joystick_y_position(value)

## Default X position
@export var default_x_position : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_default_x_position(value)

## Default Y position
@export var default_y_position : float = 0.0:
	set(value): if is_instance_valid(ij): ij._set_default_y_position(value)

## If true, the joystick moves to the default position when released
@export var default_on_release : bool = false:
	set(value): if is_instance_valid(ij): ij.default_on_release = value


func _ready() -> void:
	if is_instance_valid(ij):
		ij._set_joystick_x_limit_min(joystick_x_limit_min)
		ij._set_joystick_x_limit_max(joystick_x_limit_max)
		ij._set_joystick_y_limit_min(joystick_y_limit_min)
		ij._set_joystick_y_limit_max(joystick_y_limit_max)
		ij._set_joystick_x_steps(joystick_x_steps)
		ij._set_joystick_y_steps(joystick_y_steps)
		ij._set_joystick_x_position(joystick_x_position)
		ij._set_joystick_y_position(joystick_y_position)
		ij._set_default_x_position(default_x_position)
		ij._set_default_y_position(default_y_position)
		
		ij.default_on_release = default_on_release
		ij.joystick_moved.connect(joystick_moved.emit)
	
