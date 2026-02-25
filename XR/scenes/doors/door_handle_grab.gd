extends XRToolsPickable

##
## Door Handle Grab script
##
## @desc:
##     This script handles an invisible grabber representing the users hold
##     on the door handle. The door handle grab should be configured with:
##      - Static physics mode (no movement until the player grabs it)
##      - No collision mask as this does not process collisions
##      - Separate layer from the door to prevent door self-collisions
##
##     The door body script monitors the door handle for:
##      - Door handle grabbed - using the 'picked_up' signal
##      - Door handle dropped - using the 'handle_dropped' signal
##      - Rotation for updating the handle model and opening the door
##

## Distance from the handle origin to auto-snap the grab
@export var snap_distance: float = 0.3

@export var pick_01: Node3D
@export var pick_02: Node3D
@export var pick_01_hand_right: Node3D
@export var pick_01_hand_left: Node3D
@export var pick_02_hand_right: Node3D
@export var pick_02_hand_left: Node3D

# Node references
@onready var _origin : Node3D = get_parent()
var _handled = false

# Handle auto-snapping the grab
func _process(_delta):
	if is_picked_up():
		# Measure the distance of the handle from the origin
		var origin_pos = _origin.global_transform.origin
		var handle_pos = global_transform.origin
		var distance = handle_pos.distance_to(origin_pos)
		
		#Hide the hand
		var hand = self.get_picked_up_by().get_parent()
		hand.visible = false

		#picker touched
		var d_p01 = hand.global_transform.origin.distance_to(pick_01.global_transform.origin)
		var d_p02 = hand.global_transform.origin.distance_to(pick_02.global_transform.origin)
		
		var hand_used = 1;
		var pick_used = 1;
		
		if hand.name == 'RightHand':
			hand_used = 1
		if hand.name == 'LeftHand':
			hand_used = 2
		
		if d_p01 < d_p02:
			pick_used = 1
		else:
			pick_used = 2
			
		if _handled == false:
			if hand_used == 1:
				if pick_used == 1:
					pick_01_hand_right.visible = true
				if pick_used == 2:
					pick_02_hand_right.visible = true
					
			if hand_used == 2:
				if pick_used == 1:
					pick_01_hand_left.visible = true
				if pick_used == 2:
					pick_02_hand_left.visible = true
			
			_handled = true
			
		# If too far then drop the handle
		if distance > snap_distance:
			drop()

# Handle letting go of the door handle grab
func let_go(grabber: Node3D, _linear_velocity: Vector3, _angular_velocity: Vector3) -> void:
	#Show hand
	grabber.get_parent().visible = true
	
	pick_01_hand_right.visible = false
	pick_01_hand_left.visible = false
	pick_02_hand_right.visible = false
	pick_02_hand_left.visible = false
	_handled = false
	
	super.let_go(grabber, _linear_velocity, _angular_velocity)
	transform = Transform3D.IDENTITY
