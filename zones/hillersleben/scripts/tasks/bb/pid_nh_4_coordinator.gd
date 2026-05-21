extends Node3D

@onready var button_s : Interaction = $inter_s
@onready var button_up : Interaction = $inter_up
@onready var button_down : Interaction = $inter_down
@onready var button_left : Interaction = $inter_left
@onready var button_right : Interaction = $inter_right
@onready var button_esc : Interaction = $inter_esc
@onready var button_ok : Interaction = $inter_ok
@onready var button_m : Interaction = $inter_m
@onready var button_c : Interaction = $inter_c

const PID_SCREEN := preload("uid://nyrobrw4gmu1")

@onready var pid_screen : PID_SCREEN = $"SubViewport/PID-NH4"

@onready var pairs : Dictionary [Interaction, PID_SCREEN.BUTTONS] = {
	button_s : PID_SCREEN.BUTTONS.S,
	button_up : PID_SCREEN.BUTTONS.UP,
	button_down : PID_SCREEN.BUTTONS.DOWN,
	button_left : PID_SCREEN.BUTTONS.LEFT,
	button_right : PID_SCREEN.BUTTONS.RIGHT,
	button_esc : PID_SCREEN.BUTTONS.ESC,
	button_ok : PID_SCREEN.BUTTONS.OK,
	button_m : PID_SCREEN.BUTTONS.M,
	button_c : PID_SCREEN.BUTTONS.C,
}


func _ready() -> void:
	for key : Interaction in pairs.keys():
		key.turned_on.connect(on_click.bind(pairs[key]))
		
	pid_screen.show_settings(false)
	pass
	
func on_click(...args) -> void:
	pid_screen.pass_controls(args[0])
	pass
	

func set_target_nh4(value : float) -> void:
	pid_screen.settings_target_current_values[pid_screen.POS_NH4] = value


func get_target_nh4() -> float:
	return pid_screen.settings_target_current_values[pid_screen.POS_NH4]
	
