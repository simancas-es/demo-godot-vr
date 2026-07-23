@tool
extends Control

signal ok
signal repeat


func _ready() -> void:
	$VBoxContainer/HBoxContainer/OK.pressed.connect(ok.emit)
	$VBoxContainer/HBoxContainer/REPEAT.pressed.connect(repeat.emit)

func set_text(text : String) -> void:
	$VBoxContainer/ScrollContainer/Label.text = text
	pass
