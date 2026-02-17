extends XROrigin3D


@onready var left_hand : XRToolsHand = $LeftHand/XRToolsCollisionHand/LeftHand #$LeftHand/XRToolsCollisionHand/LeftHand
@onready var left_ghost_hand : XRToolsHand = $LeftHand/GhostHand
@onready var right_hand : XRToolsHand = $RightHand/XRToolsCollisionHand/RightHand#$RightHand/XRToolsCollisionHand/RightHand
@onready var right_ghost_hand : XRToolsHand = $RightHand/GhostHand


@export var enable_ghosthands : bool = true


func _process(_delta):
	if Engine.is_editor_hint():
		return
	if not enable_ghosthands :
		left_ghost_hand.visible = false
		right_ghost_hand.visible = false
		return
		
	
	# Show our ghost hands when when our visible hands aren't where our hands are...
	if left_hand and left_ghost_hand:
		var offset = left_hand.global_position - left_ghost_hand.global_position
		left_ghost_hand.visible = offset.length() > 0.01

	if right_hand and right_ghost_hand:
		var offset = right_hand.global_position - right_ghost_hand.global_position
		right_ghost_hand.visible = offset.length() > 0.01
