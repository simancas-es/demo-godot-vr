extends Interaction
class_name MachineToggleable ##Generic name

##Simple machine that turns on and off. No complex logic for entering or exiting states.
signal turned_on
signal turned_off

enum STATE{NOT_INITIALIZED, ON, OFF}
@export var initial_state = STATE.OFF
var current_state = STATE.NOT_INITIALIZED
var _next_state

@export var time_rest_s : float = 1.0 #seconds between activations
var _can_activate := true

func _ready() -> void:
	activated.connect(toggle_activation)
	_next_state = initial_state
	toggle_activation()

func toggle(on : bool) -> void:
	if not _can_activate: return
	if not on:
		current_state = STATE.OFF
		turned_off.emit()
		_next_state = STATE.ON
	if on:
		current_state = STATE.ON
		turned_on.emit()
		_next_state = STATE.OFF
	
	#rest
	_can_activate = false
	await get_tree().create_timer(time_rest_s).timeout
	_can_activate = true
			
func toggle_activation(...args) -> void:
	match _next_state:
		STATE.OFF:
			toggle(false)
		STATE.ON:
			toggle(true)
	pass
	
