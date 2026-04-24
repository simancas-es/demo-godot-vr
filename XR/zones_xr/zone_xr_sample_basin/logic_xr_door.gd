extends Node
const SnapInteraction := preload("uid://bjh03qtuyod2f") #snap_interaction
const TemporaryDoorFunctions := preload("uid://bgyendvlud0ak")

@onready var snapdoor : SnapInteraction = $".."
@export var basesystem : Node3D
@export var door : TemporaryDoorFunctions 

func _ready() -> void:
	
	snapdoor.correct_item_snapped.connect(on_correct_snap)
	snapdoor.has_dropped.connect(on_dropped)
	
func on_correct_snap() -> void:
	if door == null:
		push_warning("Missing InteractionDoor")
		return
	door.unlock(snapdoor.item_id, true)
	door.open()
	pass

func on_dropped() -> void:
	if door == null:
		push_warning("Missing InteractionDoor")
		return
	door.close()
	door.lock(0, true)
