extends Node3D

#if tried to do anything, go back.
const VALVE := preload("uid://l02y45ybnafb")
@onready var valve2  : VALVE = $"2026-05-19-Vorklärbecken/ablauf-belebung2/ValveXRExtended2"
@onready var valve1  : VALVE = $"2026-05-19-Vorklärbecken/ablauf-belebung1/ValveXRExtended"

@onready var warn1 : Label3D = $Warn1
@onready var warn2 : Label3D = $Warn2
var color_a = Color(1.0, 1.0, 0.0) # yellow
var color_b = Color(1.0, 0.0, 0.0) # red

func _ready() -> void:
	valve1.valve_changed.connect(alarm)
	valve2.valve_changed.connect(alarm)
	pass
	
func alarm(...args) -> void:
	warn1.visible = true
	warn2.visible = true
	pass
	

var time := 0.0
var duration := 1.0
func _process(delta: float) -> void:
	time = fmod(time + delta, duration * 2.0)
	var t = (sin(time * PI / duration) + 1.0) * 0.5
	warn1.modulate = color_a.lerp(color_b, t)
	
	pass
