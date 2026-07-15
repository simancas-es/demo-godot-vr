extends Area3D
const ICEWEDGE := preload("uid://tkkfmgm7bgqe")


func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Node3D) -> void:
	if is_instance_of(area, ICEWEDGE):
		area.try_break()
	elif is_instance_of(area, InteractionWithInventorySlotSelected): #HACK
		if area.reaction_id == INVENTORYSETTINGS.ID.ICE_BREAKER:
			area.validated_item_interaction.emit()
	pass
