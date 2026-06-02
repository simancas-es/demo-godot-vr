extends Node3D
class_name XRToolsInteractableWheelGeneral

@onready var wheel : XRToolsInteractableHinge = %InteractableHinge

signal hinge_moved(angle : float)

## Hinge minimum limit
@export var hinge_limit_min : float = -45.0:
	set(value): hinge_limit_min=value;  if is_instance_valid(wheel):wheel._set_hinge_limit_min(value)

## Hinge maximum limit
@export var hinge_limit_max : float = 45.0:
	set(value): hinge_limit_max=value;   if is_instance_valid(wheel):wheel._set_hinge_limit_max(value)

## Hinge step size (zero for no steps)
@export var hinge_steps : float = 0.0:
	set(value): hinge_steps=value;   if is_instance_valid(wheel):wheel._set_hinge_steps(value)

## Hinge position
@export var hinge_position : float = 0.0:
	set(value): hinge_position=value;  if is_instance_valid(wheel): wheel._set_hinge_position(value)

## Default position
@export var default_position : float = 0.0:
	set(value): default_position=value;   if is_instance_valid(wheel):hinge_limit_min=value;  wheel._set_default_position(value)

## If true, the hinge moves to the default position when releases
@export var default_on_release : bool = false:
	set(value): default_on_release=value;   if is_instance_valid(wheel):wheel.default_on_release = value
	

func _ready() -> void:	
	if is_instance_valid(wheel):
		wheel._set_hinge_limit_min(hinge_limit_min)
		wheel._set_hinge_limit_max(hinge_limit_max)
		wheel._set_hinge_steps(hinge_steps)
		wheel._set_hinge_position(hinge_position)
		wheel._set_default_position(default_position)
		wheel.default_on_release = default_on_release
		wheel._set_hinge_limit_min(hinge_limit_min)
		
		
		wheel.hinge_moved.connect(hinge_moved.emit)
		
func get_hinge_rotation() -> Vector3:
	return wheel.rotation
