class_name ControlledObject extends CharacterBody3D

#Receives and activates inputs from the controller


##var wants_mousepos : bool = true
#var mouse_captured : bool = true
##var wants_lookdir : bool = true
#var lookdir : Vector2 
#var mousepos : Vector2 
#
#var wants_movement : bool = true
#var movedir : Vector3
#
##effects
#var is_jumping : bool = false
#var is_shift : bool = false



	


#Reimplement in subclass
func interact() -> void:
	push_warning("function interact() from %s not implemented" % self)
	pass

func mousewheelup() -> void:
	push_warning("function mousewheelup() from %s not implemented" % self)
	pass

func mousewheeldown() -> void:
	push_warning("function mousewheeldown() from %s not implemented" % self)

	pass
	
