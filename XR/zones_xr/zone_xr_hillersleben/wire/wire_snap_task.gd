extends "res://XR/scenes/interactables/snap_interaction.gd"

const Q_FENCE_CHECK := preload("uid://bayvpsaetj4iw")
var q_fence_check : Node

func _ready() -> void:
	super()
	ready.connect(find_check)
	correct_item_snapped.connect(on_snap_repair)
	pass

func find_check() -> void:
	q_fence_check = get_tree().current_scene.find_child("Q_FENCE_CHECK", true, false)
	pass
	
func on_snap_repair() -> void:
	if not q_fence_check: return
	q_fence_check._on_wire_interaction()
	for c in get_children():
		c.visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	pass
