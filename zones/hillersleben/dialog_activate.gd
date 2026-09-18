extends Area3D

const DIALOG := preload("uid://go8lcfvxa3df")
@export var dialog : DIALOG = null ## Dialog cutout object, if nothing, it will use its parent.

func _ready() -> void:
	area_entered.connect(_on_entered)
	body_entered.connect(_on_entered)
	

func _on_entered(..._args) -> void:
	if dialog != null:
		dialog.up()
	else:
		var p = get_parent()
		if is_instance_of(p, DIALOG):
			p.up()
	pass
