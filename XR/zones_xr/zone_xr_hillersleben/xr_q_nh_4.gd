extends Node3D

const CONTROLLER := preload("uid://dbb00gqpvldte")
#var q_controller : CONTROLLER
@export var q_controller : CONTROLLER = null
const XRBUTTON := preload("uid://bskfg6cqrrb1w")

@onready var button_s : XRBUTTON = $Buttons/ButtonS
@onready var button_up : XRBUTTON = $Buttons/ButtonUP
@onready var button_down : XRBUTTON = $Buttons/ButtonDOWN
@onready var button_left : XRBUTTON = $Buttons/ButtonLEFT
@onready var button_right : XRBUTTON = $Buttons/ButtonRIGHT
@onready var button_esc : XRBUTTON = $Buttons/ButtonESC
@onready var button_ok : XRBUTTON = $Buttons/ButtonOK
@onready var button_m : XRBUTTON = $Buttons/ButtonM
@onready var button_c : XRBUTTON = $Buttons/ButtonC

@onready var pairs : Dictionary [XRBUTTON, CONTROLLER.PID_SCREEN.BUTTONS] = {
	button_s : CONTROLLER.PID_SCREEN.BUTTONS.S,
	button_up : CONTROLLER.PID_SCREEN.BUTTONS.UP,
	button_down : CONTROLLER.PID_SCREEN.BUTTONS.DOWN,
	button_left : CONTROLLER.PID_SCREEN.BUTTONS.LEFT,
	button_right : CONTROLLER.PID_SCREEN.BUTTONS.RIGHT,
	button_esc : CONTROLLER.PID_SCREEN.BUTTONS.ESC,
	button_ok : CONTROLLER.PID_SCREEN.BUTTONS.OK,
	button_m : CONTROLLER.PID_SCREEN.BUTTONS.M,
	button_c : CONTROLLER.PID_SCREEN.BUTTONS.C,
}

func _ready() -> void:
	#find_q()
	for key : XRBUTTON in pairs.keys():
		key.on.connect(q_controller.on_click.bind(pairs[key]))
	pass
	
	
#func find_q() -> void:
	#q_controller = get_tree().current_scene.find_child("PID_NH4", true, false)
