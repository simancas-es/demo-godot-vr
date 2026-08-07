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
@onready var nh4_label : Label3D = $nh4_dynamic

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
	

var timer := 0.0
func _process(delta: float) -> void:
	timer += delta
	if timer >= 2.0:
		timer = 0.0
		#HACK
		var current_value_nh4 = self.get_target_nh4()
		var random := randf_range(-0.4, +0.4)
		current_value_nh4 += random
		pid_screen.set_nh4_value ("%.1f" % current_value_nh4)
		
		match current_value_nh4:
			var x when x < 2.0:
				pid_screen.set_nh4_info_color(Color.hex(0x191c40ff))
				pass # keep the blue color
			var x when x < 10.0:
				pid_screen.set_nh4_info_color(0xf7a717ff)
			var x:
				pid_screen.set_nh4_info_color(Color.RED)
		
