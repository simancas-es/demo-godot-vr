extends Area3D

@export var disappear_on_enter : bool = true


func _ready() -> void:
	if disappear_on_enter:
		body_entered.connect(_on_body_entered)
	monitoring = false
	visible = false

func _on_body_entered(_body) -> void:
	queue_free()

func activate() -> void:
	visible = true
	monitoring = true
	set_process(true)
