extends Label3D

@onready var wheel : XRToolsInteractableWheelGeneral = $"../WheelGeneral"
const VALVECONTROLLER = preload("uid://l02y45ybnafb")
@onready var _valve_controller : VALVECONTROLLER = $".."  #parent

@export var debugging : bool = false:
	set(value):
		debugging = value
		set_process(debugging)
		
		
func _ready() -> void:
	visible = debugging

func _process(delta: float) -> void:
	if not debugging: return
	var txt = ""
	if _valve_controller:
		txt += "VC(fr) = %0.1f " % _valve_controller.state.valve_fraction
	if wheel:
		txt += "VW(fr) = %0.1f" % wheel.wheel.hinge_position
	self.text = txt
