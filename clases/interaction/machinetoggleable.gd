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
@onready var _base_monitoring = monitoring
@onready var _base_monitorable = monitorable 

@export var momentary_button : bool = false #Turns on, then automatically turns off.

@export_category("Interaction Strings")
@export var string_on : String = "Press [E] to turn off"
@export var string_off : String = "Press [E] to turn on"
@export var string_not_initialized : String = "Press [E] to initialize."



func _ready() -> void:
	activated.connect(toggle_activation)
	_next_state = initial_state
	toggle_activation()

func is_on() -> bool:
	match current_state:
		STATE.OFF: return false
		STATE.ON: return true
		STATE.NOT_INITIALIZED: return false
	return false
	
func toggle(on : bool) -> void:
	if not _can_activate:
		return
	if not on:
		current_state = STATE.OFF
		turned_off.emit()
		hint_text[ENUMS.ACTION.INTERACT] = string_off
		_next_state = STATE.ON
	elif on:
		current_state = STATE.ON
		turned_on.emit()
		hint_text[ENUMS.ACTION.INTERACT] = string_on
		_next_state = STATE.OFF
		if momentary_button:
			current_state = STATE.OFF
			hint_text[ENUMS.ACTION.INTERACT] = string_off
			_next_state = STATE.ON
	#rest
	_can_activate = false
	monitoring = false
	monitorable = false
	var _cur_hint =  hint_text[ENUMS.ACTION.INTERACT] #HACK. TODO Refactor into a disable property.
	hint_text[ENUMS.ACTION.INTERACT] = ""
	await get_tree().create_timer(time_rest_s).timeout
	_can_activate = true
	hint_text[ENUMS.ACTION.INTERACT] = _cur_hint

	monitoring = _base_monitoring
	monitorable = _base_monitorable

			
func toggle_activation(..._args) -> void:
	match _next_state:
		STATE.OFF:
			toggle(false)
		STATE.ON:
			toggle(true)
	pass
	
