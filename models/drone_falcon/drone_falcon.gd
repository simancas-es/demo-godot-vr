extends Interaction

signal falcon_started

func _ready() -> void:
	if not activated.is_connected(on_activate_falcon):
		activated.connect(on_activate_falcon)
		
func on_activate_falcon(_context: InteractionContext) -> void:
	falcon_started.emit()
