extends Node3D
class_name XRToolsInteractablePushbuttonGeneral

@onready var iab : XRToolsInteractableAreaButton = %InteractableAreaButton
@onready var rumbler : XRToolsRumbler = %Rumbler

## Button pressed event
signal button_pressed(button)

## Button released event
signal button_released(button)


@export var rumbles : bool = true
@export var only_once : bool = false


func _ready() -> void:
	if iab == null: return
	iab.button_pressed.connect(button_pressed.emit)
	iab.button_released.connect(button_released.emit)
	
	if not rumbles:
		if not rumbler: return
		rumbler.queue_free() #HACK
