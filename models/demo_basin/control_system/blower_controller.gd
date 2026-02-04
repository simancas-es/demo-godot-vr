extends Node
signal blower_state_changed(on: bool)

@export var state: DEMO_BASIN.BasinState
@export var blower_number: int = 0 # 0,1,2...

@export var blower_machine: MachineToggleable #Receives the interaction

signal alarm(code : CODE)
enum CODE {MANUAL_ACTIVATION_WITHOUT_WATER,
			BROKEN_AERATOR}

func _ready() -> void:
	blower_machine.activated.connect(on_activated)

#TODO put these into an array in the controller...
func on_activated(...args) -> void:
	var blower_target = state.blower_target_on[blower_number]
	
	if blower_machine.current_state == MachineToggleable.STATE.OFF:
		var water_ratio := state.water_volume / state.max_volume
		if water_ratio < state.safety_blower_volume_fraction:
			#alarm.emit(CODE.MANUAL_ACTIVATION_WITHOUT_WATER)
			Signals.ui_msg_top.emit(tr("Not enough water to activate the blower!"))
			return
	
	if not state.aerator_ok[blower_number]:
		#alarm.emit(CODE.BROKEN_AERATOR)
		Signals.ui_msg_top.emit(tr("Aerator is broken!"))
	

	if blower_machine.current_state == MachineToggleable.STATE.ON:
		state.blower_target_on[blower_number] = false
	else:
		state.blower_target_on[blower_number] = true
	pass
	
func sync_with_state() -> void:
	var should_be_on = state.blower_target_on[blower_number]

	if should_be_on and blower_machine.current_state != blower_machine.STATE.ON:
		blower_machine.toggle(true)
	elif not should_be_on and blower_machine.current_state != blower_machine.STATE.OFF:
		blower_machine.toggle(false)

	blower_state_changed.emit(should_be_on)
