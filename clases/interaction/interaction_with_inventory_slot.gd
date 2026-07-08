extends Interaction
class_name InteractionWithInventorySlotSelected
##Reacts with the selected item

@export var reaction_id : INVENTORYSETTINGS.ID 
@export var quantity : int = 0

@export var remove_item_on_interaction : bool = true ##Remove qty from selected inventory id

@export var disable_time_s : float = 1.0 ##Disable before being able to use again
@export var one_time : bool = false ##Queues free. Disables forever after validation


signal validated_item_interaction
signal failed_item_interaction

func _ready() -> void:
	activated.connect(on_activated)
	
func on_activated(context: InteractionContext) -> void:
	if context == null or context.playerdata == null:
		return
	var pd := context.playerdata
	var info = pd.inventory.check_at_selected()
	if info == null : return
	var id = info.id
	var qty = info.qty
	if id == reaction_id and qty >= quantity:
		validated_item_interaction.emit()
		var original_collision_layer = collision_layer
		if remove_item_on_interaction:
			var error = pd.inventory.remove_at_selected(quantity)
		if one_time:
			queue_free()
			monitorable = false
			collision_layer = 0
		else:
			monitorable = false
			collision_layer = 0
			await get_tree().create_timer(disable_time_s).timeout
			monitorable = true
			collision_layer = original_collision_layer
	else:
		failed_item_interaction.emit()
	pass
