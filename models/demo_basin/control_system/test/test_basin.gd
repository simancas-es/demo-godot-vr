extends Node

class DummyValve extends Node:
	var target_flow: float = 0.0
	var current_throughput: float
	func _init(flow: float) -> void:
		target_flow = flow
		current_throughput = flow

	
class DummyBlower extends Node:
	var blower_number: int
	var state: DEMO_BASIN.BasinState
	func _init(num: int, st: DEMO_BASIN.BasinState) -> void:
		blower_number = num
		state = st
	func sync_with_state() -> void:
		var should_be_on = state.blower_target_on[blower_number]
	
	
func _ready() -> void:
	print("Starting Basin System Tests")
	
	var state = DEMO_BASIN.BasinState.new()
	var system = DEMO_BASIN.BasinSystem.new()
	system.state = state
	
	# Create dummy blower controllers
	var blower1 = DummyBlower.new(0, state)
	var blower2 = DummyBlower.new(1, state)
	
	# Register valves in system
	system.register_inflow_controller(DummyValve.new(1.0)) # arbitrary inflow
	system.register_outflow_controller(DummyValve.new(0.0)) # no outflow
	
	# Test 1: Empty tank, try to turn blowers on
	print("Test 1: Empty tank, blowers should fail to turn on")
	state.water_volume = 0.0
	state.blower_target_on = [true, true] as Array[bool]
	system.step(0.1) # enforce safety
	
	assert(state.blower_target_on[0] == false)
	assert(state.blower_target_on[1] == false)
	print("Test 1 passed!")
	
	# Test 2: Second aerator broken, full tank, try to turn it on
	print("Test 2: Second aerator broken, full tank")
	state.water_volume = state.max_volume
	state.aerator_ok = [true, false] as Array[bool]
	state.blower_target_on = [true, true] as Array[bool]
	system.step(0.1)
	
	assert(state.blower_target_on[0] == true)
	assert(state.blower_target_on[1] == false)
	print("Test 2 passed!")
	
	
	print("End of tests")
