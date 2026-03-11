extends RefCounted
const PID := preload("uid://b56vhusy3ty4s")
var pid : PID
var measurement_callable : Callable
var output_callable : Callable

func _init(_pid, _measurement_callable: Callable, _output_callable: Callable):
	pid = _pid
	measurement_callable = _measurement_callable
	output_callable = _output_callable


func update(dt: float) -> void:
	var measurement = measurement_callable.call()
	var control = pid.update(measurement, dt)
	output_callable.call(control)
