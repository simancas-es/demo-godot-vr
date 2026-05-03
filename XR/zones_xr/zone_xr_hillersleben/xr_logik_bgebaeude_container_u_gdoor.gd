extends Node
#Logic adapter for the garage with the Sand and Garbage container

@export var basemap : Node3D
@export var xrbuttondoor : XRToolsInteractablePushbuttonGeneral
@export var xrbuttonsandout : XRToolsInteractablePushbuttonGeneral
@export var xrbuttonsandin : XRToolsInteractablePushbuttonGeneral
@export var xrbuttonsandhalt : XRToolsInteractablePushbuttonGeneral
@export var xrbuttongarbageout : XRToolsInteractablePushbuttonGeneral
@export var xrbuttongarbagein : XRToolsInteractablePushbuttonGeneral
@export var xrbuttongarbagehalt : XRToolsInteractablePushbuttonGeneral

@export var buttondoor : MachineToggleable 
@export var buttonsandout : MachineToggleable
@export var buttonsandin : MachineToggleable
@export var buttonsandhalt : MachineToggleable
@export var buttongarbageout : MachineToggleable
@export var buttongarbagein : MachineToggleable
@export var buttongarbagehalt : MachineToggleable


func _enter_tree() -> void:
	basemap.ready.connect(initialize)

func initialize() -> void:
	xrbuttondoor.button_pressed.connect(func (..._args): buttondoor.activated.emit(_create_context()) )
	xrbuttonsandout.button_pressed.connect(func (..._args): buttonsandout.activated.emit(_create_context()) )
	xrbuttonsandin.button_pressed.connect(func (..._args): buttonsandin.activated.emit(_create_context()) )
	xrbuttonsandhalt.button_pressed.connect(func (..._args): buttonsandhalt.activated.emit(_create_context()) )
	xrbuttongarbageout.button_pressed.connect(func (..._args): buttongarbageout.activated.emit(_create_context()) )
	xrbuttongarbagein.button_pressed.connect(func (..._args): buttongarbagein.activated.emit(_create_context()) )
	xrbuttongarbagehalt.button_pressed.connect(func (..._args): buttongarbagehalt.activated.emit(_create_context()) )

func _create_context() -> InteractionContext:
	return InteractionContext.compatibility(self, &"xr")
