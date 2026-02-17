extends Node
class_name XR_LAYER_SETTINGS

#Layer defaults: 
#[1] Static World - for fixed scenery objects that never move
#[2] Dynamic World - for scenery objects which may move
#[3] Pickable Objects - for pickable objects
#[4] Wall Walking Surface - for objects the player can wall walk on
#[5] Grappling Target - for grappling movement
#[17] Held Objects - for pickable objects held by the player
#[18] Player Hand - for the players physical hand bones
#[19] Grab handles - for pickable objects
#[20] Player Body - for the players body
#[21] Pointable - for objects the player can interact with using the pointer
#[22] Hand Pose Area - for areas enforcing hand poses
#[23] UI Objects - for physically touchable UIs using the pointer or finger poke

#Layers used by external modules:
#1, 2, 3, 4, 5, 11, 12, 20
const EXTERNAL_LAYERS : Array[int] = [1, 2, 3, 4, 5, 11, 12, 20]

#Changed:
#1 -> 24,  -(1<<(4-1)) | (1<<(24-1))
#2 -> 25,  -(1<<(2-1)) | (1<<(25-1))
#3 -> 26,  -(1<<(3-1)) | (1<<(26-1))
#4 -> 27,  -(1<<(4-1)) | (1<<(27-1))
#5 -> 28,  -(1<<(5-1)) | (1<<(28-1))
#20 -> 29  -(1<<(20-1)) | (1<<(29-1))
#11 -> 30  -(1<<(11-1)) | (1<<(30-1))
#12 -> 31  -(1<<(12-1)) | (1<<(31-1))

const LAYERNAMES : Dictionary[int, String] = {
	24:"Static World",
	25:"Dynamic World",
	26:"Pickable Objects",
	27:"Wall Walking Surface",
	28:"Grappling Target",
	17:"Held Objects",
	18:"Player Hand",
	19:"Grab handles",
	29:"Player Body",
	21:"Pointable",
	22:"Hand Pose Area",
	23:"UI Objects",
}

#movement_gravity_zones
class MOVEMENT_GRAVITY_ZONES:
	# Default wall-walk mask of 4:wall-walk
	const DEFAULT_MASK := 0b0000_0000_0000_0000_0000_0000_0000_1000 -(1<<(4-1)) | (1<<(27-1))
	
#function_desktop_pointer
class FUNCTION_DESKTOP_POINTER:
	## Default pointer collision mask of 21:pointable and 23:ui-objects
	const DEFAULT_MASK := 0b0000_0000_0101_0000_0000_0000_0000_0000

	## Default pointer collision mask of 23:ui-objects
	const SUPPRESS_MASK := 0b0000_0000_0100_0000_0000_0000_0000_0000
	pass

#movement_wind
class MOVEMENT_WIND:
	# Default wind area collision mask of 20:player-body
	const DEFAULT_MASK := 0b0000_0000_0000_1000_0000_0000_0000_0000 -(1<<(20-1)) | (1<<(29-1))
	pass

#movement_wall_walk
class MOVEMENT_WALL_WALK:
	# Default wall-walk mask of 4:wall-walk
	const DEFAULT_MASK := 0b0000_0000_0000_0000_0000_0000_0000_1000 -(1<<(4-1)) | (1<<(27-1))
	pass

#movement_grapple
class MOVEMENT_GRAPPLE:
	# Default grapple collision mask of 1-5 (world)
	#const DEFAULT_COLLISION_MASK := 0b0000_0000_0000_0000_0000_0000_0001_1111
	#Modified
	const DEFAULT_COLLISION_MASK := (0b0000_0000_1000_0000_0000_0000_0001_1110
	-(1<<(2-1))-(1<<(3-1))-(1<<(4-1))-(1<<(5-1))
	| (1<<(25-1)) | (1<<(26-1)) | (1<<(27-1)) | (1<<(28-1))
)


	# Default grapple enable mask of 5:grapple-target
	const DEFAULT_ENABLE_MASK := 0b0000_0000_0000_0000_0000_0000_0001_0000 -(1<<(5-1)) | (1<<(28-1))
	pass

#function_pose_detector
class FUNCTION_POSE_DETECTOR:
	# Default pose detector collision mask of 22:pose-area
	const DEFAULT_MASK := 0b0000_0000_0010_0000_0000_0000_0000_0000
	pass

#function_pointer
class FUNCTION_POINTER:
	## Default pointer collision mask of 21:pointable and 23:ui-objects
	const DEFAULT_MASK := 0b0000_0000_0101_0000_0000_0000_0000_0000

	## Default pointer collision mask of 23:ui-objects
	const SUPPRESS_MASK := 0b0000_0000_0100_0000_0000_0000_0000_0000

#function_pickup
class FUNCTION_PICKUP:
	# Default pickup collision mask of 3:pickable and 19:handle
	const DEFAULT_GRAB_MASK := 0b0000_0000_0000_0100_0000_0000_0000_0100 -(1<<(3-1)) | (1<<(26-1))
	# Default pickup collision mask of 3:pickable
	const DEFAULT_RANGE_MASK := 0b0000_0000_0000_0000_0000_0000_0000_0100 -(1<<(3-1)) | (1<<(26-1))


#function_gaze_pointer
class FUNCTION_GAZE_POINTER:
	## Default pointer collision mask of 21:pointable and 23:ui-objects
	const DEFAULT_MASK := 0b0000_0000_0101_0000_0000_0000_0000_0000

	## Default pointer collision mask of 23:ui-objects
	const SUPPRESS_MASK := 0b0000_0000_0100_0000_0000_0000_0000_0000

#Teleport
class FUNCTION_TELEPORT:
	const DEFAULT_MASK := (0b1111_1111_1111_1111_1111_1111_1111_1111
	-(1<<(1-1))-(1<<(2-1))-(1<<(3-1))  -(1<<(4-1)) -(1<<(5-1)) -(1<<(20-1))  -(1<<(11-1)) -(1<<(12-1)) 
	| (1<<(24-1)) | (1<<(25-1)) | (1<<(26-1))| (1<<(27-1))| (1<<(28-1))| (1<<(29-1))  | (1<<(30-1))| (1<<(31-1))
	
	)

#physics_hand
class PHYSICS_HAND:
	# Default hand bone layer of 18:player-hand
	const DEFAULT_LAYER := 0b0000_0000_0000_0010_0000_0000_0000_0000


#collision_hand
class COLLISION_HAND:
	# Default layer of 18:player-hands
	const DEFAULT_LAYER := 0b0000_0000_0000_0010_0000_0000_0000_0000

	# Default mask of 0xFFFF (1..16)
	# - 1:static-world
	# - 2:dynamic-world
	# - 3:pickable-objects
	# - 4:wall-walking
	# - 5:grappling-target
	const DEFAULT_MASK := (0b0000_0000_0000_0101_0000_0000_0001_1111
	 -(1<<(1-1))  -(1<<(2-1)) -(1<<(3-1)) -(1<<(4-1)) -(1<<(5-1)) 
	| (1<<(24-1)) | (1<<(25-1)) | (1<<(26-1))| (1<<(27-1))| (1<<(28-1))
	) 

#viewport_2d_in_3d
class VIEWPORT_2D_IN_3D:
	# Default layer of 1:static-world, 21:pointable, 23:ui-objects
	const DEFAULT_LAYER := 0b0000_0000_0101_0000_0000_0000_0000_0001 -(1<<(1-1)) | (1<<(24-1))

#pickable
class PICKABLE:
	# Default layer for held objects is 17:held-object
	const DEFAULT_LAYER := 0b0000_0000_0000_0001_0000_0000_0000_0000
#poke
class POKE:
	# Default layer of 18:player-hands
	const DEFAULT_LAYER := 0b0000_0000_0000_0010_0000_0000_0000_0000

	# Default mask [1..16] and 23:ui-objects
	const DEFAULT_MASK := (0b0000_0000_0100_0000_1111_1111_1111_1111
	 -(1<<(1-1)) -(1<<(2-1))  -(1<<(3-1))  -(1<<(4-1))  -(1<<(5-1))    -(1<<(11-1)) -(1<<(12-1)) 
	 | (1<<(24-1))| (1<<(25-1))| (1<<(26-1))| (1<<(27-1))| (1<<(28-1)))     | (1<<(30-1))| (1<<(31-1))
