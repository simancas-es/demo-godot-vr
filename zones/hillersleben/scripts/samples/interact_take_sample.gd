extends InteractionWithInventorySlotSelected

@export var which_sample : INVENTORYSETTINGS.ID
@export var qty : int = 1

func _ready() -> void:
	super()
	validated_item_interaction_with.connect(on_validate)
	

func on_validate(context : InteractionContext) -> void:
	#Check inventory space
	var inv = context.get_inventory()
	var result = inv.add_item(which_sample, qty) #TODO check for multiple additions.
	if result != inv.ERROR.SUCCESS:
		pass
	else:
		#self.disabled = true #HACK		
		pass	
	
	pass
