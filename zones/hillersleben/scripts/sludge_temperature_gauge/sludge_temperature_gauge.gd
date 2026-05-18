extends Node3D

var angle_deg_40 : float = 60
var angle_deg_38 : float = 120

@onready var pointer : MeshInstance3D = $pointer
@onready var pointer38 : MeshInstance3D = $pointer38
@onready var pointer40 : MeshInstance3D = $pointer40

var current_temp : float = 40.0
signal temp_changed(temp : float)

var tween : Tween

func _ready() -> void:
	pointer38.rotation_degrees.z = angle_deg_38
	pointer40.rotation_degrees.z = angle_deg_40
	
	#testing
	#set_temperature(38.0)
	#await get_tree().create_timer(2.0).timeout
	#set_temperature(40.0)
	#await get_tree().create_timer(0.4).timeout
	#set_temperature(38.2)
	pass
	

func set_temperature(temperature : float) -> void:
	var target_deg = (temperature - 38.0)/(40.0 - 38.0)*(angle_deg_40 - angle_deg_38) + angle_deg_38
	target_deg = clampf(target_deg, -45.0, 270.0-45.0)
	#pointer.rotation_degrees.z = target_deg
	if tween: tween.kill()	
	tween = get_tree().create_tween()
	tween.tween_property(pointer, "rotation_degrees:z", target_deg, 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	current_temp = temperature
	temp_changed.emit(temperature)
