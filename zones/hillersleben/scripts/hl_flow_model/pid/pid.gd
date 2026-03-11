extends RefCounted

var kp : float = 0.0
var ki : float = 0.0
var kd : float = 0.0

var setpoint : float = 0.0

var min_output : float = -INF
var max_output : float = INF

var _integral := 0.0
var _prev_error := 0.0
var initialized := false

func _init(_setpoint : float = 0.0, _kp : float = 0.0, _ki : float = 0.0, _kd : float = 0.0,
			 _min_output : float = -INF, _max_output : float = +INF)->void:
	kp = _kp
	ki = _ki
	kd = _kd
	setpoint = _setpoint
	min_output = _min_output
	max_output = _max_output
	pass

func reset() -> void:
	_integral = 0.0
	_prev_error = 0.0
	initialized = false


func update(measurement : float, dt : float) -> float:
	var error := setpoint - measurement

	if not initialized:
		_prev_error = error
		initialized = true

	_integral += error * dt
	
	var derivative := 0.0
	if dt>0.0:
		derivative = (error - _prev_error) / dt
	_prev_error = error

	var output :=(
		kp * _prev_error +
		ki * _integral +
		kd * derivative)

	return clamp(output, min_output, max_output)
