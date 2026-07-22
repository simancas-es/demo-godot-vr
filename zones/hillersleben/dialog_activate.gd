extends Area3D

const DIALOG := preload("uid://go8lcfvxa3df")
@export var dialog : DIALOG = null

func _ready() -> void:
	area_entered.connect(_on_entered)
	body_entered.connect(_on_entered)
	

func _on_entered(..._args) -> void:
	dialog.up()
	pass
