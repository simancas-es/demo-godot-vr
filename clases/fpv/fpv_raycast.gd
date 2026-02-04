extends RayCast3D
class_name FPVENVRAYCAST
##Raycast for the environmental Camera, has a range of 1.5 meters.


#signal not_looking_at_anything
signal changed_collide(node : Node)
 
#Emit a signal whenever it changes. Allows only one collider?
var _previous_collide : get = _get_previous_collide, set = _set_previous_collide

func _get_previous_collide() -> Interaction:
	if !is_instance_valid(_previous_collide): return null
	return _previous_collide
func _set_previous_collide(value) -> void:
	if (value == null) and (_previous_collide == null): return
	if value != _previous_collide: changed_collide.emit(value)
	_previous_collide = value	


func check_collide(rc : RayCast3D):
	if rc.is_colliding():
		var collision = rc.get_collider()
		if !is_instance_valid(self._previous_collide):
			self._previous_collide = null
		if collision != self._previous_collide:
			if collision is Interaction: #TODO better
				var collision_ : Interaction = collision
				self._previous_collide = collision_
	else:
		#not_looking_at_anything.emit()
		self._previous_collide = null
	pass
	
func _process(_delta: float) -> void:
	check_collide(self)
