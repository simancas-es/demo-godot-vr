extends Area3D

signal detected_rc(position, event)

var raycast: FPVENVRAYCAST

func _ready():
	_find_raycast.call_deferred()  # important
	get_tree().node_added.connect(_on_node_added)
		
func _on_node_added(node):
	if raycast: 	return 
	
	if node.is_in_group("FPVRAYCAST"):
		raycast = node
		get_tree().node_added.disconnect(_on_node_added)		
		
func _find_raycast():
	var rays = get_tree().get_nodes_in_group("FPVRAYCAST")
	if rays.size() > 0:
		raycast = rays[0] #HACK Assume only 1


var _was_hovering := false
func _input(event):
	if not (event is InputEventMouseMotion or event is InputEventMouseButton):
		return

	var hovering = raycast and raycast.is_colliding() and raycast.get_collider() == self

	if hovering:
		detected_rc.emit(raycast.get_collision_point(), event)
	elif _was_hovering:
		detected_rc.emit(null, event)

	_was_hovering = hovering
