extends Node
#Switches between one and other hand on pickup
#
@export var hand_to_disable : XRToolsCollisionHand
@export var function_pickup : XRToolsFunctionPickup

@export var pickup_class : String = "XRToolsInteractableHandle"


func _ready() -> void:
	function_pickup.has_picked_up.connect(on_pickup)
	function_pickup.has_dropped.connect(on_drop)
	

func on_pickup(what : Node) -> void:
	if not (what.is_class(pickup_class)) : return
	hand_to_disable.mode = XRToolsCollisionHand.CollisionHandMode.DISABLED
	pass
	
func on_drop() -> void:
	hand_to_disable.mode = XRToolsCollisionHand.CollisionHandMode.COLLIDE
	pass
