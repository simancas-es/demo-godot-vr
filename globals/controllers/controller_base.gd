extends Node
class_name ControllerBase
#Controller 1
##TODO Make it available for other keyboard layouts etc.
##This would mean redoing the global signals.

#Abstraction to capture controls and pass them to the object being controlled.

var _movedir : Vector3
var lookdir : Vector2 
var mousepos : Vector2 
var is_mouse_captured : bool

var reading_movement : bool = true
var movedir : Vector3
var _movedir_precalculation : Vector3

#effects
var is_jumping : bool = false
var is_shift : bool = false

signal interact
signal mouse_captured ##Or equivalent
signal mouse_released ##Or equivalent
signal mousewheelup ##Or equivalent
signal mousewheeldown ##Or equivalent

func _ready() -> void:
	pass

func enable(enable_) -> void:
	set_process(enable_)
	set_process_unhandled_key_input(enable_)
	set_process_unhandled_input(enable_)
	set_process_shortcut_input(enable_)

func enable_movement() -> void:
	reading_movement = true
	pass
func disable_movement() -> void:
	reading_movement = false
	pass

func get_look_delta() -> Vector2:
	return lookdir

func consume_look_delta() -> Vector2:
	var current_lookdir := lookdir
	lookdir = Vector2.ZERO
	return current_lookdir

func get_mouse_position() -> Vector2:
	return mousepos

func get_movement_direction() -> Vector3:
	return movedir

func is_jump_pressed() -> bool:
	return is_jumping

func is_sprint_pressed() -> bool:
	return is_shift

func is_crouch_pressed() -> bool:
	return false

func is_panorama_exit_requested() -> bool:
	return false
	
##Override
func _input(event: InputEvent) -> void:
	pass
##Override
func _unhandled_input(event: InputEvent) -> void:
	pass

##Override
func _unhandled_key_input(_event: InputEvent) -> void:
	pass
	
##Override movement direction calculation
func _process(_delta: float) -> void:
	pass
