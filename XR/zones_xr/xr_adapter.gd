extends Node
#Adapts the BaseZone elements to XR.
#This adaptation might be for instance removing all elements with a specific class
#So that they can be substituted by elements from the XR module


@export var basezone : Node3D = null #Object containing the world, could be a basezone.

@export var delete_vans : bool = false
@export var delete_inventorypickups : bool = false #deletes the kbm inventory pickups


func _ready() -> void:
	if basezone == null: push_error("Missing zone to adapt!!")
	
	var player : XRToolsPlayerBody = XRTools.find_xr_child(get_parent(), "*", "XRToolsPlayerBody")
	adapt_collision_mask(player)		
	
	var hands = XRTools.find_xr_children(get_parent(), "*", "XRToolsCollisionHand")
	for h in hands: adapt_collision_mask(h)
	
	do_delete_vans()
	do_delete_inventorypickups()

func do_delete_vans() -> void:
	if delete_vans:
		var vans = basezone.find_children("*", "SelectEnvironmentVan")
		for v in vans: v.queue_free()

func do_delete_inventorypickups() -> void:
	if delete_inventorypickups:
		var ips = basezone.find_children("*", "InventoryPickup")
		for ob in ips:
			ob.queue_free()

func adapt_collision_mask(obj : CollisionObject3D) -> void:
	obj.collision_mask |= (1 << (15-1)) | (1 <<(16-1))
	
	pass
