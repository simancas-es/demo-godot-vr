extends Node
# Enforces Safety
@export var state: DEMO_BASIN.BasinState

#TODO: Define a flow controller class for type hints.
var inflow_controllers: Array = [] # inflow controllers must have a variable named current_throughput in m3s
var outflow_controllers: Array = [] # outflow controllers must have a variable named current_throughput in m3s


signal state_changed

# Call from _process or manually
func step(delta: float) -> void:
	_apply_dynamic_flows(delta)
	_enforce_safety()
	state_changed.emit()
	
	
#Dynamic registration
func register_inflow_controller(ctrl) -> void:
	if ctrl not in inflow_controllers:
		inflow_controllers.append(ctrl)

func register_outflow_controller(ctrl) -> void:
	if ctrl not in outflow_controllers:
		outflow_controllers.append(ctrl)

# inflow controllers must have a variable named current_throughput in m3s
func _apply_dynamic_flows(delta: float) -> void:
	var total_inflow = 0.0
	for ctrl in inflow_controllers:
		# Each controller exposes a "current_flow" target
		total_inflow += ctrl.current_throughput

	var total_outflow = 0.0
	for ctrl in outflow_controllers:
		total_outflow += ctrl.current_throughput
	# Update tank volume
	state.water_volume = clamp(state.water_volume + (total_inflow - total_outflow) * delta, 0.0, state.max_volume)
	
	
# Safety rules
func _enforce_safety() -> void:
	# Never allow blowers ON when empty
	if state.water_volume / state.max_volume < state.safety_blower_volume_fraction:
		for i in state.blower_target_on.size():
			state.blower_target_on[i] = false

	# Aerator failures
	for n in state.aerator_ok.size(): #BUG: Possible mismatch
		if not state.aerator_ok[n]: state.blower_target_on[n] = false
