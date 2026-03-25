extends Area3D

@export var disappear_on_enter : bool = true


func _ready() -> void:
	if disappear_on_enter: body_entered.connect(func(_body): queue_free())
