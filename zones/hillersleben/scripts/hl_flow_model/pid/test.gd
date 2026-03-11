extends Node

const PID = preload("uid://b56vhusy3ty4s")
const PIDBinding = preload("uid://dcimoti8vbbyo")

static func assert_float(a: float, b: float, epsilon: float = 0.0001) -> void:
	if abs(a - b) > epsilon:
		push_error("assert_float failed: expected %f got %f" % [b, a])
		assert(false)

		
func test_pid_zero_error():
	var pid = PID.new(10.0, 1.0, 1.0, 1.0)
	var output = pid.update(10.0, 1.0)
	assert_float(output, 0.0)


func test_pid_proportional_response():
	var pid = PID.new(10.0, 2.0, 0.0, 0.0)
	var output = pid.update(8.0, 1.0)
	# error = 2
	# kp = 2 → output = 4
	assert_float(output, 4.0)


func test_pid_integral_accumulates():
	var pid = PID.new(10.0, 0.0, 1.0, 0.0)

	var o1 = pid.update(8.0, 1.0)
	var o2 = pid.update(8.0, 1.0)

	# integral grows each update
	assert(o2 > o1)


func test_pid_derivative_response():
	var pid = PID.new(10.0, 0.0, 0.0, 1.0)

	pid.update(8.0, 1.0) # initialize

	var output = pid.update(9.0, 1.0)

	# error changed from 2 → 1
	# derivative = -1
	assert_float(output, -1.0)


func test_pid_output_clamp_max():
	var pid = PID.new(10.0, 10.0, 0.0, 0.0, -INF, 5.0)

	var output = pid.update(0.0, 1.0)

	assert_float(output, 5.0)


func test_pid_output_clamp_min():
	var pid = PID.new(10.0, 10.0, 0.0, 0.0, -5.0, INF)

	var output = pid.update(20.0, 1.0)

	assert_float(output, -5.0)


func test_pid_reset():
	var pid = PID.new(10.0, 0.0, 1.0, 0.0)

	pid.update(8.0, 1.0)
	pid.update(8.0, 1.0)

	pid.reset()

	var output = pid.update(8.0, 1.0)

	# after reset integral should start fresh
	assert_float(output, 2.0)
	

func test_pid_binding_calls_output():

	var measurement_value := 8.0
	var output_value := [0.0]

	var pid = PID.new(10.0, 1.0, 0.0, 0.0)

	var binding = PIDBinding.new(
		pid,
		func(): return measurement_value,
		func(v): output_value[0] = v
	)

	binding.update(1.0)

	# error = 2 → output = 2
	assert_float(output_value[0], 2.0)
	
	
func test_pid_binding_reads_measurement():

	var measurement_value := 5.0
	var output_value := [0.0]

	var pid = PID.new(10.0, 1.0, 0.0, 0.0)

	var binding = PIDBinding.new(
		pid,
		func(): return measurement_value,
		func(v): output_value[0] = v
	)

	binding.update(1.0)

	# error = 5
	assert_float(output_value[0], 5.0)
	

func test_pid_binding_respects_output_limits():

	var measurement_value := 0.0
	var output_value := [0.0]

	var pid = PID.new(10.0, 10.0, 0.0, 0.0, 0.0, 3.0)

	var binding = PIDBinding.new(
		pid,
		func(): return measurement_value,
		func(v): output_value[0] = v
	)

	binding.update(1.0)

	assert_float(output_value[0], 3.0)
	
	
func test_pid_converges():

	var pid = PID.new(10.0, 0.5, 0.1, 0.0)

	var measurement := 0.0

	for i in range(50):
		var control = pid.update(measurement, 1.0)
		measurement += control * 0.1

	assert(abs(measurement - 10.0) < 2.0)
	
func _ready() -> void:
	test_pid_zero_error()
	test_pid_proportional_response()
	test_pid_proportional_response()
	test_pid_integral_accumulates()
	test_pid_derivative_response()
	test_pid_output_clamp_min()
	test_pid_output_clamp_max()
	test_pid_reset()
	test_pid_converges()
	test_pid_binding_respects_output_limits()
	test_pid_binding_reads_measurement()
	test_pid_binding_calls_output()

	pass
	
