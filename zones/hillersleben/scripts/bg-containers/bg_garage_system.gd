extends Node

const GarageState = preload("uid://d2x1a26haj0vt")

@export var state : GarageState
var _state_changed : bool = false
signal state_changed

func step(delta: float) -> void:
	_enforce_rules()
	if _state_changed : state_changed.emit()

func _enforce_rules() -> void:
	_state_changed = false
	# Handle door requests first
	if state.door_requested_open:
		state.door_state = GarageState.DoorState.OPENING
		state.door_requested_open = false
		_state_changed = true
		
	if state.door_requested_close:
		# Only close if no container is moving
		var can_close = true
		for c in state.container_states:
			if c in [GarageState.ContainerState.INBETWEEN,
					 GarageState.ContainerState.MOVING_IN,
					 GarageState.ContainerState.MOVING_OUT]:
				can_close = false
				break
		if can_close:
			state.door_state = GarageState.DoorState.CLOSING
			_state_changed = true
		state.door_requested_close = false

	# Prevent door from closing if any container is moving
	if state.door_state == GarageState.DoorState.CLOSING:
		for container_state in state.container_states:
			if container_state in [GarageState.ContainerState.INBETWEEN,
									GarageState.ContainerState.MOVING_IN,
									GarageState.ContainerState.MOVING_OUT]:
				state.door_state = GarageState.DoorState.OPEN
				_state_changed = true
				break

	# Process container requests
	for i in range(state.container_states.size()):
		# Move OUT
		if state.container_requested_out[i]:
			if state.door_state == GarageState.DoorState.OPEN:
				state.container_states[i] = GarageState.ContainerState.MOVING_OUT
				_state_changed = true
			state.container_requested_out[i] = false

		# Move IN
		if state.container_requested_in[i]:
			if state.door_state == GarageState.DoorState.OPEN:
				state.container_states[i] = GarageState.ContainerState.MOVING_IN
				_state_changed = true
			state.container_requested_in[i] = false
