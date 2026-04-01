extends Node

@onready var button : MachineToggleable = $"../../MachineToggleable"
var parent : XRToolsInteractablePushbuttonGeneral

var root : GameRoot

func _ready() -> void:
	parent = get_parent()
	root = get_tree().current_scene
	root.updated.connect(check_xr)
	parent.ready.connect(setup)
	
	parent.button_pressed.connect(_on_on)
	parent.button_released.connect(_on_off)

func check_xr() -> void:
	if root is GameRoot:
		if not root.is_xr():
			parent.queue_free(); return
		else:
			$"../../MeshInstance3D-Button".visible = false
	pass
	
func setup() -> void:
	if button.is_on():
		parent.toggle(true)
	else:
		parent.toggle(false)
	pass


func _on_on(...args) -> void:
	parent.modulate_color(Color(0, 1, 0))  # RGB: green
	pass
	
func _on_off(...args) -> void:
	parent.modulate_color(Color(1, 0, 0.0))  # RGB: green
	pass
