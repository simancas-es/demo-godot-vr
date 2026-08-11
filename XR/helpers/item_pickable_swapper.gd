extends Node

@export var kbm_grabable : SystemPhysicalControlObject
@export var xr_grabable : XRToolsPickable


var root : GameRoot

func _ready() -> void:
	root = get_tree().current_scene
	root.updated.connect(check_xr)
	#check_xr()
	self.ready.connect(check_xr.call_deferred)
	
func check_xr() -> void:
	if root is GameRoot:
		if root.is_xr():
			#in xr, we substitute the kbm_grabable for our class
			print("ItemPickable Swapper XR") # This works...
			if kbm_grabable != null or not kbm_grabable.is_queued_for_deletion():
				replace_node(kbm_grabable, xr_grabable)
		else:
			#xr_grabable disappears
			if xr_grabable and not xr_grabable.is_queued_for_deletion():
				xr_grabable.queue_free()
	pass

#Destructive
func replace_node(old_node: Node, new_node: Node):
	var parent = old_node.get_parent()
	
	for child in old_node.get_children():
		if child != new_node:
			old_node.remove_child.call_deferred(child) #HACKs
			new_node.add_child.call_deferred(child)
		
	new_node.reparent(parent)

	# Remove old node
	old_node.queue_free()
