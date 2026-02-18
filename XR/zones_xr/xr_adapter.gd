extends Node
#Adapts the BaseZone elements to XR.
#This adaptation might be for instance removing all elements with a specific class
#So that they can be substituted by elements from the XR module


@export var zone : Node3D = null



func _ready() -> void:
	if zone == null: push_error("Missing zone to adapt!!")
	
	var player : XRToolsPlayerBody = XRTools.find_xr_child(get_parent(), "*", "XRToolsPlayerBody")
	adapt_collision_mask(player)		
	
	var hands = XRTools.find_xr_children(get_parent(), "*", "XRToolsCollisionHand")
	for h in hands: adapt_collision_mask(h)


func adapt_collision_mask(obj : CollisionObject3D) -> void:
	obj.collision_mask |= (1 << (15-1)) | (1 <<(16-1))
	
	pass
