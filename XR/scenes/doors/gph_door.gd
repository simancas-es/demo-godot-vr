@tool
class_name GrabPointStaticHand
extends XRToolsGrabPoint


## XR Tools Grab Point Hand Script
##
## This script allows specifying a grab point for a specific hand. Additionally
## the grab point can be used to control the pose of the hand, and to allow the
## grab point position to be fine-tuned in the editor.


## Hand for this grab point
enum Hand {
	LEFT,	## Left hand
	RIGHT,	## Right hand
}

## Grab mode for this grab point
enum Mode {
	GENERAL,	## General grab point
	PRIMARY,	## Primary-hand grab point
	SECONDARY	## Secondary-hand grab point
}

## Hand preview option
enum PreviewMode {
	CLOSED,	## Preview hand closed
	OPEN,	## Preview hand open
}


## Left hand scene path (for editor preview)
const LEFT_HAND_PATH := "res://addons/godot-xr-tools/hands/scenes/lowpoly/left_hand_low.tscn"

## Right hand scene path (for editor preview)
const RIGHT_HAND_PATH := "res://addons/godot-xr-tools/hands/scenes/lowpoly/right_hand_low.tscn"


## Grab-point handle
@export var handle : String

## Which hand this grab point is for
@export var hand : Hand: set = _set_hand

## Hand grab mode
@export var mode : Mode = Mode.GENERAL

## Snap the hand mesh to the grab-point
@export var snap_hand : bool = true

## Hand pose
@export var hand_pose : XRToolsHandPoseSettings: set = _set_hand_pose

## If true, the hand is shown in the editor
@export var editor_preview_mode : PreviewMode = PreviewMode.CLOSED: set = _set_editor_preview_mode

## How much this grab-point drives the position
@export var drive_position : float = 1.0

## How much this grab-point drives the angle
@export var drive_angle : float = 1.0

## How much this grab-point drives the aim
@export var drive_aim : float = 0.0


## Hand to use for editor preview
var _editor_preview_hand : XRToolsHand


## Called when the node enters the scene tree for the first time.
func _ready():
	return
	var hand_path := LEFT_HAND_PATH if hand == Hand.LEFT else RIGHT_HAND_PATH
	var hand_scene : PackedScene = load(hand_path)
	if !hand_scene:
		return

	# Construct the model
	_editor_preview_hand = hand_scene.instantiate()

	# Set the pose
	if hand_pose:
		_editor_preview_hand.add_pose_override(self, 0.0, hand_pose)

	# Set the grip override
	if editor_preview_mode == PreviewMode.CLOSED:
		_editor_preview_hand.force_grip_trigger(1.0, 1.0)
	else:
		_editor_preview_hand.force_grip_trigger(0.0, 0.0)

	# Add the editor-preview hand as a child
	add_child(_editor_preview_hand)

func _set_hand(new_value : Hand) -> void:
	return
	hand = new_value
	if Engine.is_editor_hint():
		_update_editor_preview()


func _set_hand_pose(new_value : XRToolsHandPoseSettings) -> void:
	return
	# Unsubscribe from the old hand-pose changed signal
	if Engine.is_editor_hint() and hand_pose:
		hand_pose.changed.disconnect(_update_editor_preview)

	# Save the hand pose
	hand_pose = new_value

	# Update the editor preview
	if Engine.is_editor_hint() and hand_pose:
		hand_pose.changed.connect(_update_editor_preview)
		_update_editor_preview()


func _set_editor_preview_mode(new_value : PreviewMode) -> void:
	return
	editor_preview_mode = new_value
	if Engine.is_editor_hint():
		_update_editor_preview()


func _update_editor_preview() -> void:
	return
	# Discard any existing hand model
	if _editor_preview_hand:
		remove_child(_editor_preview_hand)
		_editor_preview_hand.queue_free()
		_editor_preview_hand = null

	# Pick the hand scene
	var hand_path := LEFT_HAND_PATH if hand == Hand.LEFT else RIGHT_HAND_PATH
	var hand_scene : PackedScene = load(hand_path)
	if !hand_scene:
		return

	# Construct the model
	_editor_preview_hand = hand_scene.instantiate()

	# Set the pose
	if hand_pose:
		_editor_preview_hand.add_pose_override(self, 0.0, hand_pose)

	# Set the grip override
	if editor_preview_mode == PreviewMode.CLOSED:
		_editor_preview_hand.force_grip_trigger(1.0, 1.0)
	else:
		_editor_preview_hand.force_grip_trigger(0.0, 0.0)

	# Add the editor-preview hand as a child
	add_child(_editor_preview_hand)
