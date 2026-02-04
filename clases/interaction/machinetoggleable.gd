extends Interaction
class_name MachineToggleable ##Generic name

##Simple machine that turns on and off. No complex logic for entering or exiting states.

signal request_turn(enabled : bool)##Blower requests to be turned on by the controller
signal turned_on
signal turned_off

enum STATE{NOT_INITIALIZED, ON, OFF}
@export var initial_state = STATE.OFF
var current_state = STATE.NOT_INITIALIZED
var _next_state

func _ready() -> void:
	activated.connect(toggle_activation)
	_next_state = initial_state
	toggle_activation(null, null)
	#HACK. Doesnt work if its child of its controller since its a signal.
	#Only as standalone
	

func toggle(on : bool) -> void:
	if not on:
		current_state = STATE.OFF
		turned_off.emit()
		_next_state = STATE.ON
	if on:
		current_state = STATE.ON
		turned_on.emit()
		_next_state = STATE.OFF
			
func toggle_activation(_pd : PlayerData, _il : FPVInteractionLogic) -> void:
	match _next_state:
		STATE.OFF:
			request_turn.emit(false)
		STATE.ON:
			request_turn.emit(true)
	pass
	
	
