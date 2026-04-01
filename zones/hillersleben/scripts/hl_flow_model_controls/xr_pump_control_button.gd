extends Node

@onready var button : MachineToggleable = $"../../MachineToggleable"
var parent : XRToolsInteractablePushbuttonGeneral

var root : GameRoot

func _ready() -> void:
	parent = get_parent()
	root = get_tree().current_scene
	root.updated.connect(check_xr)
	parent.ready.connect(setup)

func check_xr() -> void:
	if root is GameRoot:
		if not root.is_xr():
			parent.queue_free(); return
	pass
	
func setup() -> void:
	button.turned_on.connect(_on_on)
	button.turned_off.connect(_on_off)
	if button.is_on():
		_on_on()
	else:
		_on_off()	
	pass


func _on_on(...args) -> void:
	parent.modulate_color(Color(0, 1, 0))  # RGB: green
	pass
	
func _on_off(...args) -> void:
	parent.modulate_color(Color(1, 0, 0.0))  # RGB: green
	pass
