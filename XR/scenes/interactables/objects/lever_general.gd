extends Node3D
class_name XRToolsInteractableLeverGeneral

@onready var il : XRToolsInteractableHinge = %InteractableLever
signal hinge_moved(angle)


## Hinge minimum limit
@export var hinge_limit_min : float = -45.0:
	set(value): if is_instance_valid(il): il._set_hinge_limit_min(value)

## Hinge maximum limit
@export var hinge_limit_max : float = 45.0:
	set(value): if is_instance_valid(il): il._set_hinge_limit_max(value)

## Hinge step size (zero for no steps)
@export var hinge_steps : float = 0.0:
	set(value): if is_instance_valid(il): il._set_hinge_steps(value)

## Hinge position
@export var hinge_position : float = 0.0:
	set(value): if is_instance_valid(il): il._set_hinge_position(value)

## Default position
@export var default_position : float = 0.0:
	set(value): if is_instance_valid(il): il._set_default_position(value)

## If true, the hinge moves to the default position when releases
@export var default_on_release : bool = false:
	set(value): if is_instance_valid(il): il.default_on_release = value

func _ready()-> void:
	if is_instance_valid(il):
		il._set_hinge_limit_min(hinge_limit_min)
		il._set_hinge_limit_max(hinge_limit_max)
		il._set_hinge_steps(hinge_steps)
		il._set_hinge_position(hinge_position)
		il._set_default_position(default_position)
		il.default_on_release = default_on_release
		il._set_hinge_limit_min(hinge_limit_min)
		
		il.default_on_release = default_on_release
		il.hinge_moved.connect(hinge_moved.emit)
