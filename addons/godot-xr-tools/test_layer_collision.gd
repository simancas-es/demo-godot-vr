extends Node

#bits from the physics layer that are already being used by other modules.
const externally_used_bits : Array[int] =XR_LAYER_SETTINGS.EXTERNAL_LAYERS



func has_forbidden_layers(mask: int, layers: Array[int]) -> bool:
	for layer in layers:
		var bit = layer - 1
		if mask & (1 << bit):
			return true
	return false


func _ready() -> void:
	#Test function
	assert( has_forbidden_layers(0b1000, [4]))
	assert( has_forbidden_layers(0b1000, [4, 1]))
	assert( has_forbidden_layers(0b1000, [1, 4]))
	assert( not has_forbidden_layers(0b0100, [1, 2, 4]))
	
	
	#Check values against:	
	#movement_gravity_zones
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.MOVEMENT_GRAVITY_ZONES.DEFAULT_MASK, externally_used_bits))
		
	#function_desktop_pointer
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_DESKTOP_POINTER.DEFAULT_MASK, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_DESKTOP_POINTER.SUPPRESS_MASK, externally_used_bits))

	#movement_wind
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.MOVEMENT_WIND.DEFAULT_MASK, externally_used_bits))
	#movement_wall_walk
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.MOVEMENT_WALL_WALK.DEFAULT_MASK, externally_used_bits))

	#movement_grapple
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.MOVEMENT_GRAPPLE.DEFAULT_COLLISION_MASK, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.MOVEMENT_GRAPPLE.DEFAULT_ENABLE_MASK, externally_used_bits))

	#function_pose_detector
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_POSE_DETECTOR.DEFAULT_MASK, externally_used_bits))

	#function_pointer
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_POINTER.DEFAULT_MASK, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_POINTER.SUPPRESS_MASK, externally_used_bits))

	#function_pickup
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_PICKUP.DEFAULT_GRAB_MASK, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_PICKUP.DEFAULT_RANGE_MASK, externally_used_bits))


	#function_gaze_pointer
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_GAZE_POINTER.DEFAULT_MASK, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_GAZE_POINTER.SUPPRESS_MASK, externally_used_bits))

	#Teleport
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.FUNCTION_TELEPORT.DEFAULT_MASK, externally_used_bits))

	#physics_hand
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.PHYSICS_HAND.DEFAULT_LAYER, externally_used_bits))


	#collision_hand
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.COLLISION_HAND.DEFAULT_LAYER, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.COLLISION_HAND.DEFAULT_MASK, externally_used_bits))

	#viewport_2d_in_3d
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.VIEWPORT_2D_IN_3D.DEFAULT_LAYER, externally_used_bits))

	#pickable
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.PICKABLE.DEFAULT_LAYER, externally_used_bits))
	#poke
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.POKE.DEFAULT_LAYER, externally_used_bits))
	assert( not has_forbidden_layers(XR_LAYER_SETTINGS.POKE.DEFAULT_MASK, externally_used_bits))
	
	
	print("Passed all tests! No collisions in the default layers")
	
	
