extends Node3D

@onready var button : MachineToggleable = $MachineToggleable
@onready var xr_button : XRToolsInteractablePushbuttonGeneral = $PushButton

@export var init_state : bool = true

signal on
signal off

func _ready() -> void:
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	
	xr_button.button_pressed.connect(_on_on)
	xr_button.button_released.connect(_on_off)	
	
	button.toggle(init_state)
	pass

func _on_off() -> void:
	off.emit()
	pass
	
func _on_on() -> void:
	on.emit()
	pass
	
