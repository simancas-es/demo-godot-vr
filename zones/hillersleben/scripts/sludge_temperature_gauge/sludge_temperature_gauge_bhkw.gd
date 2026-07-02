extends Node3D

@export var calibration_values : Array[float]
@onready var calibration_curve : Path3D = $Calibration
var calibration_angles : Array[float]
@onready var pointer : MeshInstance3D = $pointer

@export var pointer_mesh : Node3D = null

var current_temp : float = 40.0
signal temp_changed(temp : float)

var tween : Tween

func _ready() -> void:
	#Get the angles with respect to z according to calibration values.
	for p in calibration_values.size():
		var raw_point : Vector3 = calibration_curve.curve.get_point_position(p)
		var angle_deg = rad_to_deg(atan2(raw_point.y, raw_point.x))
		calibration_angles.append(fposmod(angle_deg, 360.0))
		
	#testing
	#set_temperature(38.0)
	#await get_tree().create_timer(2.0).timeout
	#set_temperature(40.0)
	#await get_tree().create_timer(0.4).timeout
	#set_temperature(38.2)
	pass


func get_angle(value: float) -> float:
	var n = calibration_values.size()

	value = clampf(value, calibration_values[0], calibration_values[n - 1])

	for i in range(n - 1):
		var v0 = calibration_values[i]
		var v1 = calibration_values[i + 1]

		if value >= v0 and value <= v1:
			var a0 = calibration_angles[i]
			var a1 = calibration_angles[i + 1]

			var t = (value - v0) / (v1 - v0)
			var angle = lerp_angle(deg_to_rad(a0), deg_to_rad(a1), t)

			return rad_to_deg(angle)

	return fposmod(calibration_angles[n - 1], 360.0)
	
func set_temperature(temperature : float) -> void:
	var target_deg = get_angle(temperature)
	if tween: tween.kill()	
	tween = get_tree().create_tween()
	if pointer_mesh:
		tween.tween_property(pointer_mesh, "rotation_degrees:z", target_deg, 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(pointer, "rotation_degrees:z", target_deg, 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	current_temp = temperature
	temp_changed.emit(temperature)
