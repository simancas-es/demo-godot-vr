extends Node

@onready var pb1 : XRToolsInteractablePushbuttonGeneral = $"../PushButton"
@onready var pb2 : XRToolsInteractablePushbuttonGeneral = $"../PushButton2"

@onready var basinsystem : Node3D = $"../ZoneObservatorio"

#Interactables
@onready var blower1 : MachineToggleable = basinsystem.get_node("DemoConcreteBasin/Aerator1Controller/blower")
@onready var blower2 : MachineToggleable = basinsystem.get_node("DemoConcreteBasin/Aerator2Controller/blower")

func _ready() -> void:
	pb1.button_pressed.connect(on_pressed1)
	pb2.button_pressed.connect(on_pressed2)
	
	
	
func on_pressed1(...args) -> void:
	blower1.activated.emit(null,null)
	pass
	
func on_pressed2(...args) -> void:
	blower2.activated.emit(null,null)

	pass
