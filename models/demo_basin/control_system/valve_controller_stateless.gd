extends Node
signal valve_changed(new_fraction: float)

@export var state: DEMO_BASIN.BasinState

func spin_to_left(...args) -> bool:
	state.valve_fraction = clamp(state.valve_fraction + 0.1, 0.0, 1.0)
	valve_changed.emit(state.valve_fraction)
	return true

func spin_to_right(...args) -> bool:
	state.valve_fraction = clamp(state.valve_fraction - 0.1, 0.0, 1.0)
	valve_changed.emit(state.valve_fraction)
	return true
