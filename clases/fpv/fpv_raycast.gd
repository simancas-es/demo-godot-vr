extends RayCast3D
class_name FPVENVRAYCAST
##Raycast for the environmental Camera, has a range of 1.5 meters.


#signal not_looking_at_anything
signal changed_collide(node : Node)
signal changed_collides(nodes : Array[Node])
 
var _previous_collides: Array[Node] = [] :
	set(value):
		_previous_collides = value
	get():
		return _previous_collides

func check_collide(rc : RayCast3D):
	if not rc.is_colliding():
		changed_collide.emit(null) #HACK
		return
	
	#HACK
	var hits = get_all_interactions(rc)
	if hits != _previous_collides:
		changed_collides.emit(hits)
		_previous_collides = hits
	else:
		changed_collides.emit(hits) #HACK
		pass
	pass

func get_all_interactions(rc : RayCast3D) -> Array[Node]:
	var space_state = get_world_3d().direct_space_state
	var results: Array[Node] = []
	var exclude: Array[RID] = []

	var from = rc.global_position
	var to = rc.to_global(rc.target_position)

	while true:
		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = exclude
		query.collision_mask = rc.collision_mask
		query.collide_with_areas = true
		
		var result = space_state.intersect_ray(query)
		if result.is_empty():
			break

		var collider = result["collider"]		
		if collider is Interaction:
			results.append(collider)
			
		exclude.append(collider)

	return results
