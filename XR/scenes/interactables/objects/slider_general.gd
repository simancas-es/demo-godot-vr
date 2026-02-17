extends Node3D
class_name XRToolsInteractableSliderGeneral

@onready var isli : XRToolsInteractableSlider = %InteractableSlider

## Slider minimum limit
@export var slider_limit_min : float = 0.0:
	set(value): if is_instance_valid(isli): isli.slider_limit_min = value
	
## Slider maximum limit
@export var slider_limit_max : float = 1.0:
	set(value): if is_instance_valid(isli): isli.slider_limit_max = value

## Slider step size (zero for no steps)
@export var slider_steps : float = 0.0:
	set(value): if is_instance_valid(isli): isli.slider_steps = value

## Slider position
@export var slider_position : float = 0.0:
	set(value): if is_instance_valid(isli): isli._set_slider_position(value)


## Default position
@export var default_position : float = 0.0:
	set(value): if is_instance_valid(isli): isli.default_position = value
	
## If true, the slider moves to the default position when released
@export var default_on_release : bool = false:
	set(value): if is_instance_valid(isli): isli.default_on_release = value
