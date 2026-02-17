extends XRToolsInteractableHandle

func _ready() -> void:
	super()
	set_interaction_layers(XR_LAYER_SETTINGS.FUNCTION_PICKUP.DEFAULT_GRAB_MASK)

func set_interaction_layers(bitmask : int) -> void:
	self.collision_layer = bitmask
	pass
