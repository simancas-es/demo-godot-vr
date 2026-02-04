extends Interaction

signal falcon_started

func _ready() -> void:
	if not activated.is_connected(on_activate_falcon):
		activated.connect(on_activate_falcon)
		
func on_activate_falcon(by_player : PlayerData, _il : FPVInteractionLogic) -> void:
	falcon_started.emit()
