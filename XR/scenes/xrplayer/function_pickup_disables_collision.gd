extends Node
#Switches between one and other hand on pickup
#
@export var hand_to_disable : XRToolsCollisionHand
@export var function_pickup : XRToolsFunctionPickup

#@export var pickup_class : String = "XRToolsPickable" #HACK

@onready var base_collision_layer : int = hand_to_disable.collision_layer
@onready var base_collision_mask : int = hand_to_disable.collision_mask

func _ready() -> void:
	function_pickup.has_picked_up.connect(on_pickup)
	function_pickup.has_dropped.connect(on_drop)
	

func on_pickup(what : Node) -> void:
	if not (what is XRToolsPickable): return #HACK
	hand_to_disable.mode = XRToolsCollisionHand.CollisionHandMode.DISABLED
	hand_to_disable.collision_mask = 0
	hand_to_disable.collision_layer = 0
	pass
	
func on_drop() -> void:
	 #hack to prevent that an item that was just picked up overlapped with the hand that just dropped it
	await get_tree().create_timer(2.0).timeout
	if function_pickup.picked_up_object: return	
	hand_to_disable.mode = XRToolsCollisionHand.CollisionHandMode.COLLIDE
	hand_to_disable.collision_mask = base_collision_mask
	hand_to_disable.collision_layer = base_collision_layer

	pass
