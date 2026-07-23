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

func _input(event):
	if not (event is InputEventMouseMotion or event is InputEventMouseButton):
		return
	
	if not raycast:		return	
	if not raycast.is_colliding():		return	
	if raycast.get_collider() != self:		return	
	
	detected_rc.emit(raycast.get_collision_point(), event)
